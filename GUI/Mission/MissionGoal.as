import flash.filters.GradientBevelFilter;
import gfx.core.UIComponent;
import com.GameInterface.Quest;
import com.GameInterface.QuestTask;
import com.GameInterface.Quests;
import com.GameInterface.QuestGoal
import GUI.Mission.MissionGoalItem;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.Utils.Signal;
import com.GameInterface.Log;

class GUI.Mission.MissionGoal extends UIComponent
{
    private var m_Quest:Quest;
    private var m_MissionId:Number;
    private var m_GoalPhase:Number;
    
    private var m_GoalList:Array;
    private var m_GoalsAnimating:Array;
    private var m_CurrentlyDisplayedGoalIDs:Array;
    private var m_GoalTrackers:Array;  
    
    private var m_Main
    
    public var SignalAnimationsDone:Signal;
    
    public function MissionGoal()
    {
        super();
        Quests.SignalGoalPhaseUpdated.Connect( SlotGoalPhaseUpdated, this);
        m_GoalsAnimating = [];
        m_GoalTrackers = [];
		
		m_MissionId = 0;
        
        SignalAnimationsDone = new Signal();
    }
    
    public function SetData(missionId:Number)
    {
		m_MissionId = missionId;
        m_Quest = Quests.GetQuest(missionId, true, false);
        m_GoalList = m_Quest.m_CurrentTask.m_Goals;
        m_GoalList.sortOn( "m_SortOrder");
        m_GoalPhase = m_Quest.m_CurrentTask.m_CurrentPhase;
    }
    
    public function Draw(  )
    {
        m_CurrentlyDisplayedGoalIDs = [];
        
        var goalY:Number = 0;
        for (var i:Number = 0; i < m_GoalTrackers.length; i++ )
        {
            goalY += m_GoalTrackers[i]._height;
        }
        /// iterate and write the goal info
        for ( var i:Number = 0; i < m_GoalList.length; i++)
        {
            var goal:QuestGoal = m_GoalList[i]; 
            if ( m_GoalPhase == goal.m_Phase && (goal.m_SolvedTimes < goal.m_RepeatCount) && GoalCreationAllowed(goal) )
            { 
                m_CurrentlyDisplayedGoalIDs.push(goal.m_ID);
                
                var uid:Number = this["UID"]();/// goals can be failed and readded before the goal completed animation is done, so we add an UID to it.
                var goalTracker:MissionGoalItem = MissionGoalItem( attachMovie("SingleGoal", "m_GoalTracker" + uid, getNextHighestDepth() ) );
                var willTimeoutComplete:Boolean = (m_Quest.m_CurrentTask.m_IsTimeoutSuccess != undefined) ? m_Quest.m_CurrentTask.m_IsTimeoutSuccess : false;
 
                goalTracker.SetData( goal, willTimeoutComplete, uid, m_Quest.m_CurrentTask.m_ID );
                goalTracker.Draw( );
                goalTracker.SignalGoalAnimationStarted.Connect(SlotGoalAnimationStarted, this);
                goalTracker.SignalGoalAnimationCompleted.Connect(SlotGoalAnimationCompleted, this);
                goalTracker.SignalGoalCompleted.Connect(SlotRemoveGoal, this);
                goalTracker._y = goalY;
                goalY += goalTracker._height + 10;

                m_GoalTrackers.push( goalTracker );
            }
        }
    }
    
    private function GoalCreationAllowed(goal:QuestGoal) : Boolean
    {
        var isAllowed:Boolean = true;
        for (var i:Number = 0; i < m_GoalTrackers.length; i++ )
        {
            if (m_GoalTrackers[i].m_GoalID == goal.m_ID )
            {
                isAllowed = m_GoalTrackers[i].WillSelfDetruct()
            }
        }
        return isAllowed;
    }
    
    public function IsAnimationsPending():Boolean
    {
        return (m_GoalsAnimating.length > 0);
    }
    
    /// when a phase is updated
    private function SlotGoalPhaseUpdated( missionId:Number) :Void
    {
        Log.Info2("MissionTracker", "MissionGoal:SlotGoalPhaseUpdated(" + missionId + ")");
		if (m_MissionId == missionId)
		{
			SetData(missionId);
			Draw( );
		}
    }
    
    // when a new task is dished out
    // all goals will be finished when this is received, 
    public function TaskAdded( )
    {
		for (var i:Number = 0; i < m_GoalTrackers.length; i++ )
        {
            m_GoalTrackers[i].ForceGoalComplete(m_Quest.m_ID);
        }
		
        SetData(m_Quest.m_ID);
        Draw(  );
    }
    
    /// when a goal has finished some internal tweening
    private function SlotGoalAnimationCompleted(uid:Number)
    {
        Log.Info2("MissionTracker", "MissionGoal:SlotGoalAnimationCompleted( " + uid + ")");
        
        for (var i:Number = 0; i < m_GoalsAnimating.length; i++ )
        {
            if (m_GoalsAnimating[i] == uid)
            {
                m_GoalsAnimating.splice(i, 1);
            }
        }
        if (!IsAnimationsPending())
        {
            SignalAnimationsDone.Emit();
        }

    }
    
    /// when a goal is currently doing some animation
    /// add the id if its not there
    private function SlotGoalAnimationStarted(uid:Number)
    {
        for (var i:Number = 0; i < m_GoalsAnimating.length; i++ )
        {
            if (m_GoalsAnimating[i] == uid )
            {
                return;
            }
        }
        m_GoalsAnimating.push( uid )
    }
    
    // removes one specific goal from the goal trackers
    // The goal receives the 
    private function SlotRemoveGoal(uid:Number)
    {
        Log.Info2("MissionTracker", "MissionGoal:SlotRemoveGoal(" + uid + ")");
        var removeIndex:Number = -1;
        var targetY:Number; 
        var compress:Boolean = false;
        
        for (var i:Number = 0; i < m_GoalTrackers.length; i++ )
        {
            if (m_GoalTrackers[i].m_UID == uid)
            {
                removeIndex = i;
                targetY = m_GoalTrackers[i]._y;
                compress = true;
            }
            else if (compress)
            {
                
                m_GoalTrackers[i].tweenTo(0.6, { _y:targetY }, None.easeNone);
                m_GoalTrackers[i].onTweenComplete = undefined;
                targetY += m_GoalTrackers[i]._height;
            }
        }
        
        if (removeIndex > -1)
        {
            m_GoalTrackers[removeIndex].removeMovieClip();
            m_GoalTrackers.splice(removeIndex, 1);
        }
    }
}