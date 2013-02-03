//import com.Utils.SignalGroup;
import com.GameInterface.Quests;
import com.GameInterface.Quest;
import com.GameInterface.Game.Character;
import com.GameInterface.Log;
import com.Utils.LDBFormat;
//var m_SignalGroup:SignalGroup;

var TDB_MissionFailedText:String = LDBFormat.LDBGetText("Quests", "Mission_MissionFailed");
var TDB_TierCompleteText:String = LDBFormat.LDBGetText("Quests", "Mission_TierComplete");
var TDB_TierFailedText:String = LDBFormat.LDBGetText("Quests", "Mission_TierFailed");
var m_TDB_SendFactionReport:String = LDBFormat.LDBGetText("Quests", "Mission_SendFactionReport");
var m_TDB_MissionComplete:String = LDBFormat.LDBGetText("Quests", "Mission_MissionComplete");

var m_CurrentMission:Quest;
/*
 * Shows the Tier complete, Mission Complete and Mission Failed animations when a player 
 * completes or failes a mission or a tier.
 * The file is loaded with the Modules.xml and positions itself using values
 * from visibleRect, deletion of the attached movieclips are done in the imported clips
 * that are located in the fla. 
 */


function onLoad()
{
    Log.Info2("MissionTierTextEffect", "2 onLoad()");
    
    Quests.SignalQuestChanged.Connect( SlotQuestChanged, this );
    Quests.SignalGoalPhaseUpdated.Connect( SlotGoalPhaseUpdated, this);
    Quests.SignalGoalProgress.Connect( SlotGoalProgress, this );
    Quests.SignalGoalFinished.Connect( SlotGoalFinished, this );
    Quests.SignalTaskAdded.Connect( SlotTaskAdded, this );
    Quests.SignalMissionRemoved.Connect( SlotTierRemoved, this ); 
    Quests.SignalGoalTimeLimitChanged.Connect( SlotGoalTimeLimitChanged, this );

    Quests.SignalQuestRewardMakeChoice.Connect(SlotMissionCompleted, this);
    
}

/// when unloading, delete all signals;
function onUnload()
{
    Log.Info2("MissionTierTextEffect", "onUnload()");    
    //m_SignalGroup.DisconnectAll();
}

function AnimateText(txt:String) : MovieClip
{
    var scale = (arguments.length > 1) ? arguments[1] : 100;
    var y = (arguments.length > 2) ? arguments[2] : (Stage.visibleRect["height"] * 0.35);
    
    var animation:MovieClip = this.attachMovie("CompleteAnimation", "amimation"+MovieClip.UID, this.getNextHighestDepth() );
    animation.i_AnimationText_1.i_Text.autoSize = "center";
    animation.i_AnimationText_1.i_Text.text = txt;
    animation.i_AnimationText_2.i_Text.autoSize = "center";
    animation.i_AnimationText_2.i_Text.text = txt;
    animation.i_AnimationText_3.i_Text.autoSize = "center";
    animation.i_AnimationText_3.i_Text.text = txt;
	
    animation._xscale = scale;
    animation._yscale = scale;
    animation._x = Stage.visibleRect["x"] + ( Stage.visibleRect["width"] / 2 ) ;
    animation._y = Stage.visibleRect["y"] + y
    
    return animation;
}

function SlotMissionFailed() : Void
{
    Log.Info2("MissionTierTextEffect", "OnMissionFailed()");
    var animation:MovieClip = AnimateText( TDB_MissionFailedText ) ;
    

}

function SlotTierCompleted(p_tierId:Number) : Void
{
    Log.Info2("MissionTierTextEffect", "OnTierCompleted(" + + p_tierId + ")");
    AnimateText( TDB_TierCompleteText) ;
}


function SlotTierFailed(p_tierId:Number) : Void
{
    Log.Info2("MissionTierTextEffect", "OnTierFailed(" + + p_tierId + ")");
    AnimateText( TDB_TierFailedText ) ;
}

function SlotQuestChanged(questID:Number) : Void
{
    m_CurrentMission =  Quests.GetQuest( Quests.m_CurrentMissionId );
    
    Log.Info2("MissionTierTextEffect", "SlotQuestChanged("+questID+")");
}
function SlotGoalPhaseUpdated(tierId:Number) : Void
{
    Log.Info2("MissionTierTextEffect", "SlotGoalPhaseUpdated("+tierId+")");
}

function SlotGoalProgress(tierId:Number, goalId:Number, solvedTimes:Number, repeatCount:Number) : Void
{
    Log.Info2("MissionTierTextEffect", "SlotGoalProgress("+tierId+", "+goalId+", "+solvedTimes+", "+repeatCount+")");
}

function SlotGoalFinished( tierId:Number, goalId:Number ) : Void
{
    Log.Info2("MissionTierTextEffect", "SlotGoalFinished("+tierId+", "+goalId+")");
}

function SlotTaskAdded(tierId:Number) : Void
{
    Log.Info2("MissionTierTextEffect", "SlotTaskAdded("+tierId+")");
}
function SlotTierRemoved(tierId:Number) : Void
{
    Log.Info2("MissionTierTextEffect", "SlotTierRemoved("+tierId+")");
}
function SlotGoalTimeLimitChanged(tierId:Number) : Void
{
    Log.Info2("MissionTierTextEffect", "SlotGoalTimeLimitChanged("+tierId+")");
}
function SlotQuestRewardMakeChoice() : Void
{
    Log.Info2("MissionTierTextEffect", "SlotQuestRewardMakeChoice()");
}