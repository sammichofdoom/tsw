import flash.filters.DropShadowFilter;
import mx.utils.Delegate;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.GameInterface.QuestGoal
import gfx.core.UIComponent
import com.GameInterface.Quests;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.Log;

class GUI.Mission.MissionGoalItem extends UIComponent
{
    private var m_GoalNameWidth:Number;
    private var m_GoalNameAnim:MovieClip;
    private var m_GoalNumAnim:MovieClip;
    private var m_GoalProgressCursor:MovieClip;
    private var m_GoalCompleteCursor:MovieClip;
    private var m_GoalFailedCursor:MovieClip;
    private var m_Timer:MovieClip;
    
    private var m_IsAnimating:Boolean;    
    private var m_IsComplete:Boolean;
    private var m_IsFailed:Boolean;
    private var m_GoalProgressAnimationActive:Boolean; // determines if a goal is in progress when we receive a goal in progress
    private var m_SolvedTimes:Number;
    private var m_RepeatCount:Number;
    
    private var m_WillTimeoutSucceed:Boolean;
    //private var m_IsAnimationSetup:Boolean;
    private var m_GoalNumSwitchNumbersFrame:Number = 11; // the frame when we rewrite the numbers of the goal progress;
    private var m_GoalProgressEnableNumbersFrame:Number = 57; // the frame where we start tweening the numbers
    private var m_GoalCompleteTweenNameFrame:Number = 100; // the frame where we start tweening the goal text down

    private var m_MaxNameWidth:Number = 260;

    public var SignalGoalAnimationCompleted:Signal;
    public var SignalGoalAnimationStarted:Signal;
    public var SignalGoalCompleted:Signal;
    
    private var m_QueuedProgress:Array;
    
    public var m_UID:Number;
    public var m_GoalID:Number
    private var m_Goal:QuestGoal;
    private var m_TierID:Number;
    
    public function MissionGoalItem()
    {
        super();
        SignalGoalAnimationCompleted = new Signal();
        SignalGoalAnimationStarted = new Signal();
        SignalGoalCompleted = new Signal();
        Quests.SignalGoalProgress.Connect( SlotGoalProgress, this );   
        Quests.SignalGoalFinished.Connect( SlotGoalFinished, this );
        Quests.SignalTierFailed.Connect( SlotTierFailed, this);
        m_QueuedProgress = [];
        
        //m_IsAnimationSetup = false;
        m_IsAnimating = false;
        m_IsComplete = false;
        m_IsFailed = false;
    }
    
    private function configUI()
    {
        m_GoalNameAnim.m_GoalName.textField.autoSize = "right";
    }
    
    /// sometimes a goal is completed (tier or mission completes but forgets to tell the goal)
    /// this is a fallback, manually calling the Goal complete 
    public function ForceGoalComplete(tierId:Number)
    {
        Log.Info2("MissionTracker", "MissionGoalItem:ForceGoalComplete(" + tierId + ")");
        if (tierId != m_TierID)
        {
            SlotGoalFinished(tierId, m_GoalID);
        }
    }

    /// will this goal item self destruct after animation is done?
    public function WillSelfDetruct() : Boolean
    {
        return m_IsAnimating && (m_IsComplete || m_IsFailed);
    }

    public function SetData( goal:QuestGoal, willTimeoutSucceed:Boolean, uid:Number, tierId:Number )
    {
        m_Goal = goal;
        m_GoalID = m_Goal.m_ID;
        m_UID = uid;
        m_TierID = tierId;
        m_WillTimeoutSucceed = willTimeoutSucceed;
    }
    
    public function Draw()
    {
        m_GoalNameAnim.m_GoalName.textField.htmlText = m_Goal.m_Name
        
        m_GoalNameWidth  = m_GoalNameAnim.m_GoalName.textField.textWidth;
        
        if ( m_GoalNameWidth > m_MaxNameWidth)
        {
            m_GoalNameAnim.m_GoalName.textField.multiline = true;
            m_GoalNameAnim.m_GoalName.textField.wordWrap = true;
            m_GoalNameAnim.m_GoalName.textField._width = m_MaxNameWidth;
            m_GoalNameWidth = m_MaxNameWidth;
            m_GoalNameAnim._x = -( m_GoalNameWidth ); // if size is set explicitly, it retains its x position, if not the textfield grows from the current position
        }
        
        m_GoalNumAnim._x = -( m_GoalNameWidth + m_GoalNumAnim._width + 5);
        
        if (m_Goal.m_RepeatCount > 1)
        {
            m_GoalNumAnim.m_GoalNum.textField.htmlText = m_Goal.m_SolvedTimes +"/" + m_Goal.m_RepeatCount;
        }
        
    
        // timer
        if (m_Goal.m_ExpireTime > 0)
        {
            m_Timer = attachMovie("MissionTimer", "M_GoalTimer", getNextHighestDepth(), { _y:6, _xscale:30, _yscale:30 } );
            
			m_Timer._x = m_GoalNumAnim._x;
			if (m_GoalNumAnim.m_GoalNum.textField.text.length > 0)
			{
				m_Timer._x -= 40;
			}

            m_Timer.SetTimer( m_Goal.m_ExpireTime );
            m_Timer.SetSuccessType( m_WillTimeoutSucceed );            
        }
    }
    
       
    private function SlotGoalProgress(tierId:Number, goalId:Number, solvedTimes:Number, repeatCount:Number)
    {
        Log.Info2("MissionTracker", "MissionGoalItem:SlotGoalProgress(" + tierId + ", " + goalId + " )");
        if (m_GoalProgressAnimationActive)
        {
            m_SolvedTimes = solvedTimes;
            m_RepeatCount = repeatCount;
            return;
        }
        
        if (goalId == m_GoalID && !m_IsComplete && !m_IsFailed && solvedTimes != repeatCount)
        {
            if (m_IsAnimating)
			{
				m_GoalNumAnim.onEnterFrame = null;
            }
			else
			{
				m_IsAnimating = true;
				SignalGoalAnimationStarted.Emit( m_UID );
			}
            
            /// Remove any other progressindicators running
            if (m_GoalProgressCursor != undefined)
            {
                RemoveProgressCursor();
            }
            
            m_SolvedTimes = solvedTimes;
            m_RepeatCount = repeatCount;
            
            m_GoalProgressCursor = attachMovie("GoalProgressCursor", "m_GoalProgressCursor", getNextHighestDepth());
            m_GoalProgressCursor.swapDepths( m_GoalNumAnim );
            m_GoalProgressCursor.m_GoalText.textField.text = LDBFormat.LDBGetText("Quests", "UpdatedAllCaps");
            m_GoalProgressCursor._x = m_GoalNumAnim._x;
            m_GoalProgressCursor._y = 4;
            m_GoalProgressCursor.gotoAndPlay("endAnimation");
            m_GoalProgressCursor.onEnterFrame = Delegate.create(this, GoalProgressFrameMonitor);

        }
    }
    

    private function SlotTierFailed(tierId:Number, showFeedback:Boolean )
    {
		if (showFeedback)
		{
			m_IsFailed = true;
			if (m_IsAnimating)
			{
				m_GoalNumAnim.onEnterFrame = null;
			}
			else
			{
				m_IsAnimating = true;
				SignalGoalAnimationStarted.Emit( m_UID );
			}
            
            /// Remove any other progressindicators running
            if (m_GoalProgressCursor != undefined)
            {
                RemoveProgressCursor()
            }
            if (m_GoalCompleteCursor != undefined)
            {
                m_GoalCompleteCursor.onEnterFrame = null;
                m_GoalCompleteCursor.removeMovieClip();
            }
            
            
            m_GoalNumAnim.tweenTo(0.2, { _alpha:0 }, None.easeNone);
            m_GoalNumAnim.onTweenComplete = undefined;
            
            if (m_Timer != undefined)
            {
                m_Timer.tweenTo(0.2, { _alpha:0 }, None.easeNone);
                m_Timer.onTweenComplete = undefined;
            }
            m_GoalFailedCursor = attachMovie("GoalFailedCursor", "m_GoalFailedCursor", getNextHighestDepth());
			m_GoalFailedCursor._x = m_GoalNameAnim._x - m_GoalNameAnim._width - 20;
            m_GoalFailedCursor._y = 4;
            m_GoalFailedCursor.m_FailedText.textField.text = LDBFormat.LDBGetText("Quests", "FailedAllCaps");
            m_GoalFailedCursor.gotoAndPlay("endAnimation");
            m_GoalFailedCursor.onEnterFrame = Delegate.create(this, GoalFailedFrameMonitor)
		}
		else
		{	
			SignalGoalAnimationCompleted.Emit(m_UID);
			SignalGoalCompleted.Emit( m_UID )
		}
    }

    private function SlotGoalFinished(tierId:Number, goalId:Number )
    {
        Log.Info2("MissionTracker", "MissionGoalItem:SlotGoalFinished(" + tierId + ", " + goalId + " )");
       
        if (goalId == m_GoalID)
        { 
			m_IsFailed = false;
			if (m_IsAnimating)
			{
				m_GoalNumAnim.onEnterFrame = null;
			}
			else
			{
				m_IsAnimating = true;
				SignalGoalAnimationStarted.Emit( m_UID );
			}
            
            /// Remove any other progressindicators running
            if (m_GoalProgressCursor != undefined)
            {
                RemoveProgressCursor()
            }
            if (m_GoalCompleteCursor != undefined)
            {
                m_GoalCompleteCursor.onEnterFrame = null;
                m_GoalCompleteCursor.removeMovieClip();
            }
            
            m_GoalNumAnim.tweenTo(0.2, { _alpha:0 }, None.easeNone);
            m_GoalNumAnim.onTweenComplete = undefined;
            
            if (m_Timer != undefined)
            {
                m_Timer.tweenTo(0.2, { _alpha:0 }, None.easeNone);
                m_Timer.onTweenComplete = undefined;
            }
            
            m_GoalCompleteCursor = attachMovie("GoalCompleteCursor", "m_GoalCompleteCursor", getNextHighestDepth());
		    m_GoalCompleteCursor._x = m_GoalNumAnim._x + 20;
            m_GoalCompleteCursor._y = 4;
            m_GoalCompleteCursor.m_CompleteText.textField.text = LDBFormat.LDBGetText("Quests", "CompletedAllCaps"); 
            m_GoalCompleteCursor.gotoAndPlay("endAnimation");
            m_GoalCompleteCursor.onEnterFrame = Delegate.create(this, GoalCompleteFrameMonitor)

        }
    }
 
    private function RemoveProgressCursor()
    {
        m_GoalProgressCursor.onEnterFrame = null;
        m_GoalProgressCursor.swapDepths( m_GoalNumAnim ); // swap detpths back so we can delete it
        m_GoalProgressCursor._alpha = 0;
        m_GoalProgressCursor.removeMovieClip();
        m_GoalProgressCursor = undefined;
    }
    //
    //  GOAL PROGRESS FRAME MONITORS
    //
    
    /// dispatches a signal after the animation is done,
    private function GoalProgressFrameMonitor()
    {
        if (m_GoalProgressCursor._currentframe == m_GoalProgressEnableNumbersFrame)
        {
            m_GoalNumAnim.gotoAndPlay("counterChange");
            m_GoalNumAnim.onEnterFrame = Delegate.create( this, GoalNumFrameMonitor)
        }
        else if (m_GoalProgressCursor._currentframe == m_GoalProgressCursor._totalframes)
        {
            m_GoalProgressCursor.onEnterFrame = null;
            m_GoalProgressCursor.swapDepths( m_GoalNumAnim ); // swap so that we can delete
            m_GoalProgressCursor.removeMovieClip();
            m_GoalProgressCursor = undefined;
            m_GoalProgressAnimationActive = false;
        }
        m_GoalProgressCursor.nextFrame(); // force playback

    }
    
    private function GoalNumFrameMonitor()
    {
        if (m_GoalNumAnim._currentframe == m_GoalNumSwitchNumbersFrame)
        {
            m_GoalNumAnim.m_GoalNum.textField.htmlText = m_SolvedTimes + "/" + m_RepeatCount;
        }
        else if (m_GoalNumAnim._currentframe == m_GoalNumAnim._totalframes)
        {
            m_IsAnimating = false;
            SignalGoalAnimationCompleted.Emit( m_UID );
            m_GoalNumAnim.onEnterFrame = null;
            m_GoalNumAnim.m_GoalNum.textField.htmlText = m_SolvedTimes + "/" + m_RepeatCount; // do it again on complete in case we had a non visual update while animating
        }
    }
    
    //
    //  GOAL FAILED FRAME MONITORS
    //
    
    /// dispatches a signal after the animation is done,
    private function GoalFailedFrameMonitor()
    {
        /// when the goal completed animation is finished
        if (m_GoalFailedCursor._currentframe == m_GoalCompleteTweenNameFrame)
        {
            m_GoalNameAnim.gotoAndPlay("goalCompleted");
            m_GoalNameAnim.onEnterFrame = Delegate.create(this, GoalNameFrameMonitor);
        }
        else if (m_GoalFailedCursor._currentframe == m_GoalFailedCursor._totalframes)
        {
            m_GoalFailedCursor.onEnterFrame = null;
        }
        m_GoalFailedCursor.nextFrame(); // force playback
    }
    
    //
    //  GOAL COMPLETE FRAME MONITORS
    //
    
 
    /// dispatches a signal after the animation is done,
    private function GoalCompleteFrameMonitor()
    {
        /// when the goal completed animation is finished
        if (m_GoalCompleteCursor._currentframe == m_GoalCompleteTweenNameFrame)
        {
            m_GoalNameAnim.gotoAndPlay("goalCompleted");
            m_GoalNameAnim.onEnterFrame = Delegate.create(this, GoalNameFrameMonitor);
        }
        else if (m_GoalCompleteCursor._currentframe == m_GoalCompleteCursor._totalframes)
        {
            m_GoalCompleteCursor.onEnterFrame = null;
        }
        m_GoalCompleteCursor.nextFrame(); // force playback
    }
    
    private function GoalNameFrameMonitor()
    {
        if (m_GoalNameAnim._currentframe == m_GoalNameAnim._totalframes)
        {
            m_IsAnimating = false;
            SignalGoalAnimationCompleted.Emit( m_UID );
            SignalGoalCompleted.Emit( m_UID );
            m_GoalNameAnim.onEnterFrame = null;
        }
    }

}