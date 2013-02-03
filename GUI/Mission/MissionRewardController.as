import com.Utils.Archive;
import com.GameInterface.Quests;
import com.GameInterface.Log;
import com.Utils.Signal;
//import GUI.Mission.MissionRewardWindow;
import com.Components.WinComp;
import com.Components.WindowComponentContent;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;

var m_RewardWindows:Array = [];
var m_StageResizeListener:Object = new Object();

function onLoad()
{
    Log.Info2("MissionReward", "MissionRewardController.onLoad()");    
    
    Quests.SignalQuestRewardMakeChoice.Connect(SlotQuestRewardMakeChoice, this);
    GUI.Mission.MissionSignals.SignalMissionReportSent.Connect( SlotMissionReportSent, this );
    
    m_StageResizeListener.onResize = function()
    {
       StageResizeEventHandler();
    }
    
    Stage.addListener(m_StageResizeListener);
}

function StageResizeEventHandler():Void
{
    if (m_RewardWindows.length > 0)
    {
        var visibleRect:Object = Stage["visibleRect"];
        var centerStageX:Number = (visibleRect.width / 2) - (10 * m_RewardWindows.length);
        var centerStageY:Number = (visibleRect.height / 2) - (10 * m_RewardWindows.length); 
    
        for (var i:Number = 0; i < m_RewardWindows.length; i++)
        {
            var missionRewardWin:MovieClip = m_RewardWindows[i];
            missionRewardWin._x = centerStageX - (missionRewardWin._width / 2) + (20 * i);
            missionRewardWin._y = centerStageY - (missionRewardWin._height / 2) + (20 * i);
        }
    }
}

function onUnload()
{
    Stage.removeListener(m_StageResizeListener);
}

/// pushed the selected window to the front. Swapping place with the front one 
function BringToFront(clip:MovieClip)
{
	var clipDepth:Number = clip.getDepth();
	var highestDepth:Number = clipDepth;
	var frontClip:MovieClip

	for (var i:Number = 0; i < m_RewardWindows.length; i++ )
	{
		if (m_RewardWindows[i].getDepth() > highestDepth)
		{
			frontClip = m_RewardWindows[i];
			highestDepth = frontClip.getDepth();
		}
	}
	
	if (highestDepth > clipDepth)
	{
        frontClip.ShowStroke( false );
        clip.ShowStroke( true );
		clip.swapDepths( frontClip );
	}
}

function SlotMissionReportSent() : Void
{
    trace("SlotMissionReportSent");
    Log.Info2("MissionReward", "SlotMissionReportSent()");
    
    var rewardList:Array = Quests.GetAllRewards();
    var numRewards:Number = rewardList.length;
    
    var visibleRect:Object = Stage["visibleRect"];
    var centerStageX:Number = (visibleRect.width / 2) - (10 * numRewards);
    var centerStageY:Number = (visibleRect.height / 2) - (10 * numRewards);  
    
    Log.Info2("MissionReward", "Num Rewards = " + numRewards);
    
    for (var i:Number = 0; i < rewardList.length; i++ )
    {
        var rewardObject:Object = rewardList[i];
        var rewardId:Number = rewardObject.m_QuestTaskID;
        
        Log.Info2("MissionReward", "rewardId = "+rewardId); 
        
        var missionReward:WinComp = attachMovie( "MissionRewardWindowComponent", "m_RewardWindow_" + rewardId, getNextHighestDepth());
        missionReward.SetContent( "MissionRewardWindow" );
        missionReward.SignalClose.Connect( SlotMissionWindowClosed, this );
        missionReward.SignalSelected.Connect( BringToFront, this );
        missionReward.ShowResizeButton( true );
        missionReward.ShowStroke( false );
        missionReward.SetMinWidth( 400 );
        missionReward.SetSize( 450, 250 );
        
        missionReward._x = centerStageX - (missionReward._width / 2) + (20 * i);
        missionReward._y = centerStageY - (missionReward._height / 2) + (20 * i);
        
        var content:WindowComponentContent = missionReward.GetContent();
        content.SetData( rewardObject );
        content["SignalClose"].Connect( SlotMissionWindowClosed, this); // compiler warning due to type confusion
        
        m_RewardWindows.push( missionReward );
    }
    m_RewardWindows[m_RewardWindows.length - 1].ShowStroke( true )
	var character:Character = Character.GetClientCharacter();
    if (character != undefined) { character.AddEffectPackage( "sound_fxpackage_GUI_send_report.xml" ); }
}

function SlotMissionWindowClosed(rewardId:Number)
{
    for (var i:Number = 0 ; i < m_RewardWindows.length; i++)
    {
        if (m_RewardWindows[i].GetContent().GetID() == rewardId)
        {
            removeMovieClip( MovieClip( m_RewardWindows[i] ) );
            m_RewardWindows.splice(i, 1);
            break;
        }
    }
    
    if (m_RewardWindows.length == 0)
    {
        GUI.Mission.MissionSignals.SignalMissionReportWindowClosed.Emit();
    }
}