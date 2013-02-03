import gfx.core.UIComponent;
import com.GameInterface.Quest;
import com.GameInterface.QuestTask;
import com.GameInterface.Quests;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.Mission.MissionGoal;
import com.GameInterface.Log;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.GameInterface.DistributedValue;

class GUI.Mission.MissionTrackerItem extends UIComponent
{
    private var m_TierName:TextField;
    private var m_TierNumbers:TextField;
	private var m_MissionTimer:MovieClip;
    private var m_Quest:Quest;
    private var m_QuestId:Number;
    private var m_EnableProgress:Boolean
    
    private var m_Goals:MissionGoal; 

    private var m_IsMissionJournalActive:DistributedValue;
    
    public var SignalSetAsMainMission:Signal;
    public var SignalDoubleClicked:Signal;
    public var SignalAnimationsDone:Signal;
    
    public function MissionTrackerItem()
    {
        super();
        
        SignalSetAsMainMission = new Signal();
        SignalDoubleClicked = new Signal();
        SignalAnimationsDone = new Signal();
        m_EnableProgress = true;


        m_IsMissionJournalActive = DistributedValue.Create( "mission_journal_window" );
	}
    
    private function configUI()
    {
        m_TierName.autoSize = "right";
        m_TierNumbers.autoSize = "right";
    }
	
	public function GetMissionId() : Number
	{
		return m_QuestId;
	}
    
    // wether or not to shhow the full tracker with its gual updates and stuff
    public function ShowProgress( show:Boolean )
    {
        m_EnableProgress = show;
    }
    
    public function SetData(quest:Quest)
    {
        m_Quest = quest;
        m_QuestId = quest.m_ID
    }
    
    public function SetGoalVisibility(visible:Boolean, snap:Boolean)
    {
        var alpha:Number = (visible) ? 100 : 0;
        
        if (snap == true)
        {
            m_Goals["tweenEnd"](false);
            m_Goals._alpha = alpha;
        }
        else
        {
            m_Goals["tweenEnd"](false);
            m_Goals["tweenTo"](0.4, { _alpha: alpha }, None.easeNone);
            m_Goals["onTweenComplete"] = undefined
        }
    }
    
    public function Draw()
    {
        var missionType:String = GUI.Mission.MissionUtils.MissionTypeToString( m_Quest.m_MissionType );
        var icon:MovieClip = attachMovie( "_Icon_Mission_" + missionType, "icon", getNextHighestDepth());
        icon._xscale = 80;
        icon._yscale = 80;

        icon._x = -icon._width;
    //    icon.doubleClickEnabled = true;
    //    icon.addEventListener("click", this, "IconClickHandler");
    //    icon.addEventListener("doubleClick", this, "IconClickHandler"); // IconDoubleClickHandler
 
     //   com.GameInterface.Tooltip.TooltipUtils.AddTextTooltip( icon, "testing this", 210, com.GameInterface.Tooltip.TooltipInterface.e_OrientationHorizontal, true );
              /*    */    
     
        icon.disableFocus = true;
        
        DrawTierInfo()
        
        if (m_EnableProgress)
        {
            m_Goals = MissionGoal( attachMovie( "Goals", "m_Goals", getNextHighestDepth()));
            m_Goals.SetData( m_QuestId );
            m_Goals.Draw();
            m_Goals._y = 50;
            m_Goals._x = -60;
        }
    }
    
    public function DrawTierInfo()
    {
            
        m_TierName.text = m_Quest.m_MissionName;
        m_TierNumbers.text = LDBFormat.LDBGetText("Quests", "Mission_Tier") + " " + m_Quest.m_CurrentTask.m_Tier + "/" + m_Quest.m_TierMax
        
        if (m_Quest.m_CurrentTask.m_Timeout > 0)
        {
			if (m_MissionTimer != undefined)
			{
				m_MissionTimer.removeMovieClip();
			}
            m_MissionTimer = attachMovie("MissionTimer", "m_MissionTimer", getNextHighestDepth(), {_xscale:30, _yscale:30 });
            m_MissionTimer._x = -70 - m_MissionTimer._width - m_TierName.textWidth;
            m_MissionTimer._y = m_TierName._y + 3;
            m_MissionTimer.SetTimer( m_Quest.m_CurrentTask.m_Timeout );
            m_MissionTimer.SetSuccessType( m_Quest.m_CurrentTask.m_IsTimeoutSuccess );            
        }
    }
    
    public function IsAnimationPending(attachListener:Boolean)
    {
        var isAnimationsPending:Boolean = m_Goals.IsAnimationsPending();

        if (isAnimationsPending && attachListener)
        {
            m_Goals.SignalAnimationsDone.Connect( DispatchAnimationDone, this);
        }
        return isAnimationsPending;
    }

    /// when a task is added to a parent that is present, see if there are goals animating
    // if not just draw the new information
    public function TaskAdded(tierId:Number)
    {
        Log.Info2("MissionTracker", "MissionTrackerItem:SlotTaskAdded(" + tierId + ") m_QuestId = "+m_QuestId);
        if (tierId == m_QuestId)
        {
            m_Quest = Quests.GetQuest(m_QuestId, false, false);//RefreshData();
            DrawTierInfo();
            m_Goals.TaskAdded();
        }
    }
    
    // dispatches a signal 
    private function DispatchAnimationDone()
    {
        SignalAnimationsDone.Emit();
    }

    
    private function IconDoubleClickHandler(event:Object, controllerIdx:Number)
    { 
        if (m_IsMissionJournalActive.GetValue())
        {
         //  Quests.SignalMissionRequestFocus.Emit( Quests.m_CurrentMissionId );
           DistributedValue.SetDValue("OpenJournalQuest", m_QuestId );
        }
        else
        {
            DistributedValue.SetDValue("OpenJournalQuest", Quests.m_CurrentMissionId );
            m_IsMissionJournalActive.SetValue( true );
        }
  
    }

    private function IconClickHandler(event:Object)
    {
        Log.Info2("MissionTracker", "MissionTrackerItem:IconClickHandler()");
        if ( m_QuestId != Quests.m_CurrentMissionId )
        {
            SignalSetAsMainMission.Emit(m_QuestId);
        }
        else
        {
            DistributedValue.SetDValue("OpenJournalQuest", Quests.m_CurrentMissionId );
            m_IsMissionJournalActive.SetValue( true );
        }
        
    }
}