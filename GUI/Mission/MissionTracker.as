import com.GameInterface.Quests;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.GameInterface.Quest;
import com.Utils.Colors;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import mx.utils.Delegate;
import GUI.Mission.MissionTrackerItem;
import com.Utils.LDBFormat;
import com.GameInterface.Utils;
import com.GameInterface.Log;
import com.GameInterface.Game.CharacterBase;
import com.Utils.DragObject;
import com.Utils.ID32;
import flash.filters.GlowFilter;

var m_GuiModeMonitor:DistributedValue;
var m_IsMissionJournalActive:DistributedValue;
var m_ActiveMission:Number;
var m_MissionTrackerItem:MissionTrackerItem
var m_HitArea:MovieClip;
var m_MissionBar:MovieClip;
var m_IsBarActive:Boolean;
var m_LastCompletedMission:Number;

var m_IsDragIconHighlighted:Boolean;
var m_IsDraggingIcon:Boolean;

var m_ForceShowMissionTrackerValue:DistributedValue;
var m_ForceShowMissionTracker:Boolean;

var m_ReportsButton:MovieClip;

var m_MissionTypeTextFormat:TextFormat;

var SLOT_STORY:Number = 0;
var SLOT_DUNGEON:Number = 1;
var SLOT_MAIN:Number = 2;
var SLOT_SIDE_1:Number = 3;
var SLOT_SIDE_2:Number = 4;
var SLOT_SIDE_3:Number = 5;
var SLOT_COUNT:Number = 6;

var m_MissionTrackerItemArray:Array;
var m_MissionTypeArray:Array;
var m_MissionOutline:MovieClip;

gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "SlotDragEnd" );

function onLoad()
{
    m_IsBarActive = false;
	m_MissionTypeTextFormat = new TextFormat();
	m_MissionTypeTextFormat.font = "_StandardFont";
	m_MissionTypeTextFormat.size = 15;
	m_MissionTypeTextFormat.color = 0xCCCCCC;
	
	m_MissionTrackerItemArray = new Array();
	m_MissionTypeArray = new Array();

    Quests.SignalTaskAdded.Connect( SlotTaskAdded, this );
    Quests.SignalMissionCompleted.Connect( SlotMissionCompleted, this );
	Quests.SignalMissionRemoved.Connect(SlotMissionRemoved, this);
    Quests.SignalQuestChanged.Connect( SlotQuestChanged, this );
    Quests.SignalQuestRewardMakeChoice.Connect(SlotQuestRewardMakeChoice, this);
    GUI.Mission.MissionSignals.SignalMissionReportWindowClosed.Connect( SlotMissionReportWindowClosed, this );
    GUI.Mission.MissionSignals.SignalMissionRewardsAnimationDone.Connect( SlotMissionRewardsAnimationDone, this );
	GUI.Mission.MissionSignals.SignalHighlightMissionType.Connect( SlotHighlightSlot, this );
	
    m_GuiModeMonitor = DistributedValue.Create( "guimode" );
	m_GuiModeMonitor.SignalChanged.Connect( SlotGuiModeChanged, this );
    
    m_IsMissionJournalActive = DistributedValue.Create( "mission_journal_window" );
	
	m_ForceShowMissionTrackerValue = DistributedValue.Create( "ForceShowMissionTracker" );
	m_ForceShowMissionTrackerValue.SignalChanged.Connect(SlotForceShowMissionTracker, this);
	m_ForceShowMissionTrackerValue.SetValue(false);
   
	com.GameInterface.Utils.SignalObjectUnderMouseChanged.Connect(SlotObjectUnderMouseChanged, this);
	m_IsDragIconHighlighted = false;
	m_IsDraggingIcon = false;
    
    CreateSlotTooltips();
	CreateSlotAnimations();

    m_ActiveMission = 0
    
    DrawReportButton();
	
    m_HitArea.onMouseMove = Delegate.create(this, MissionBarFocus);
	CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
	SlotClientCharacterAlive();
	
}

function SlotClientCharacterAlive()
{
	ShowNextMission();
}

function CreateSlotTooltips()
{
    for (var i:Number = 0; i < SLOT_COUNT; i++ )
    {
        AddSingleTooltip( i, m_MissionBar["Slot" + i].m_Background );

    }
}

function CreateSlotAnimations()
{
	for (var i:Number = 0; i < SLOT_COUNT; i++ )
	{
		var animation = m_MissionBar["Slot" + i].attachMovie("MissionIconAnimation", "m_Animation", m_MissionBar["Slot" + i].getNextHighestDepth());
		animation._xscale = 80;
		animation._yscale = 80;
	}
}

function AddSingleTooltip( slotId:Number, clip:MovieClip )
{
    var headline:String = "";
    var bodyText:String = "";
    var descriptionText:String = "";
    var htmlText:String = "";
    
    switch( slotId )
    {
        case SLOT_STORY:
            headline = LDBFormat.LDBGetText( "Quests", "StoryMissionAllCaps" );
            bodyText = LDBFormat.LDBGetText( "Quests", "TooltipStoryMission" );
        break;
        case SLOT_DUNGEON:
            headline = LDBFormat.LDBGetText( "Quests", "DungeonMissionAllCaps" );
            bodyText = LDBFormat.LDBGetText( "Quests", "TooltipDungeonMission" );
        break;
        case SLOT_MAIN:
            headline = LDBFormat.LDBGetText( "Quests", "MainMissionAllCaps" );
            bodyText = LDBFormat.LDBGetText( "Quests", "TooltipMainMission" );
            descriptionText = LDBFormat.LDBGetText( "Quests", "TooltipMainMissionDescription" );
        break;
        case SLOT_SIDE_1:
        case SLOT_SIDE_2:
        case SLOT_SIDE_3:
            headline = LDBFormat.LDBGetText( "Quests", "SideMissionAllCaps" );
            bodyText = LDBFormat.LDBGetText( "Quests", "TooltipSideMission" );
    }
    
    htmlText = "<b>" + com.GameInterface.Utils.CreateHTMLString( headline, { face:"_StandardFont", color: "#FFFFFF", size: 14 } )+"</b>";
    if (descriptionText != "")
    {
        htmlText += "<br/>" + com.GameInterface.Utils.CreateHTMLString( descriptionText, { face:"_StandardFont", color: "#AAAAAA", size: 10 } );
    }
    
    htmlText += "<br/> <br/>" + com.GameInterface.Utils.CreateHTMLString( bodyText,{ face:"_StandardFont", color: "#FFFFFF", size: 12 }  );
    
    com.GameInterface.Tooltip.TooltipUtils.AddTextTooltip( clip, htmlText, 210,  com.GameInterface.Tooltip.TooltipInterface.e_OrientationHorizontal, true );
}

function FocusBarIn()
{
    if (!m_IsBarActive)
    {

    }
}

function SlotForceShowMissionTracker()
{
	m_ForceShowMissionTracker = Boolean(m_ForceShowMissionTrackerValue.GetValue());
	if (m_ForceShowMissionTracker && !m_IsBarActive)
	{
		ShowMissionTracker(true);
	}
	else if (!m_ForceShowMissionTracker && m_IsBarActive)
	{
		ShowMissionTracker(false);
	}
}

function SlotHighlightSlot(missionType:Number, highlight:Boolean)
{
	if (!highlight)
	{
		for (var i:Number = 0; i < SLOT_COUNT; i++ )
		{
			m_MissionBar["Slot" + i].m_Animation.gotoAndStop("normal");
		}
	}
	else
	{
		var slotID:Number = GetMissionSlot(missionType);
		if (slotID != -1 && highlight)
		{
			m_MissionBar["Slot" + slotID].m_Animation.gotoAndPlay("throttle");
		}
	}	
}

function MissionBarFocus()
{
    var isOutside:Boolean = ((_xmouse < 0 || _xmouse > m_HitArea._width) || (_ymouse <= 0 || _ymouse > m_HitArea._height+50));
    
    if (isOutside && m_IsBarActive && !m_ForceShowMissionTracker)
    {
        ShowMissionTracker(false);
    }
    else if(!isOutside && !m_IsBarActive)
    {
        ShowMissionTracker(true);
    }
}

function ShowMissionTracker(show:Boolean)
{
	if (show)
	{
        m_IsBarActive = true;
        m_MissionBar.tweenEnd(false);
        
        ShowAllMissions();
        
        m_MissionBar.tweenTo(0.3, { _x:0, _alpha:100 }, None.easeNone);
        m_MissionBar.onTweenComplete = undefined; // Delegate.create(this,  );

        m_MissionTrackerItem.SetGoalVisibility(false);
	}
	else
	{
        m_IsBarActive = false;
        m_MissionBar.tweenEnd(false);
        
        RemoveAllMissions();

        m_MissionBar.tweenTo(0.3, { _x:60, _alpha:0 }, None.easeNone);
        m_MissionBar.onTweenComplete = Delegate.create(this, RemoveAllMissions );
        
        m_MissionTrackerItem.SetGoalVisibility(true);
		
	}
	
}

function ShowNextMission()
{
    Log.Info2("MissionTracker", "MissionTracker:ShowNextMission()");
	
    var currentActiveTier:Number = DistributedValue.GetDValue("ActiveQuestID")
    if (currentActiveTier == m_LastCompletedMission)
    {
        currentActiveTier = 0;
    }
    var nextTier = 0;
    var fetch = true;

    var quests:Array = Quests.GetAllActiveQuests();
    for ( var i = 0; i < quests.length; ++i )
    {
        var quest:com.GameInterface.Quest = quests[i];
        var missionId:Number = quest.m_ID;

        // Get the first.
        if( fetch )
        {
            nextTier = missionId;
            fetch = false;
        }

        if( missionId == currentActiveTier )
        {
            nextTier = currentActiveTier;
            break;

        } 
        else
        {
            // Get the next one, unless we are at the end.
            fetch = true;
            nextTier = missionId;      
        }
    }
	
	//Remove last one if exists
	if (m_MissionTrackerItem != undefined)
	{
		m_MissionTrackerItem.removeMovieClip();
		m_MissionTrackerItem = undefined;
	}
	
	if (nextTier != 0 && nextTier != undefined)
	{
		var quest:Quest = GetMission(nextTier);
		ShowMission(nextTier, 0);
	}
    
    Quests.SignalQuestChanged.Emit(nextTier);

}

function ShowAllMissions( )
{
    var quests:Array = Quests.GetAllActiveQuests();
    for ( var i = 0; i < quests.length; ++i )
    {
        var quest:Quest = quests[i];
        var missionId:Number = quest.m_ID;
        var quest:Quest = GetMission(missionId);
        var slotID:Number = GetMissionSlot(quest.m_MissionType);
        var targetClip:MovieClip = m_MissionBar["Slot" + slotID];
        
        if (targetClip["m_MissionTrackerItem"] != undefined)
        {
            targetClip["m_MissionTrackerItem"].removeMovieClip();
            targetClip["m_MissionTrackerItem"] = undefined;
        }
        var targetWidth:Number = targetClip._width * (1/0.8); // store this now, as it will increase before we use it
        
        var tracker:MissionTrackerItem = MissionTrackerItem( targetClip.attachMovie("MissionTrackerItem", "m_MissionTrackerItem", targetClip.getNextHighestDepth()));
        tracker.ShowProgress( false )
        tracker.SetData(quest)
        tracker.Draw();
        tracker.SignalSetAsMainMission.Connect(ShowMission, this);
  //      tracker.SignalDoubleClicked.Connect(IconDoubleClickHandler, this);
        tracker._x = targetWidth;
        
        AddSingleTooltip( slotID, tracker );
   
        tracker.onRelease = function()
        {
            this.SignalSetAsMainMission.Emit( this.GetMissionId() );
        }
		
		if (missionId == m_ActiveMission)
		{
			m_MissionOutline = targetClip.attachMovie("MissionSlotOutline", "m_Outline", targetClip.getNextHighestDepth());
			m_MissionOutline._xscale = m_MissionOutline._yscale = 80;
		}
		m_MissionTrackerItemArray.push(tracker);
    }
	
	//Add mission types for empty slots
	for (var i:Number = 0; i < SLOT_COUNT; i++ )
    {
        if (m_MissionBar["Slot" + i].m_MissionTrackerItem == undefined)
        {
            var missionTypeTextField:TextField = m_MissionBar["Slot" + i].createTextField("m_MissionType", m_MissionBar["Slot" + i].getNextHighestDepth(), 0, 0, 0, 0);
			missionTypeTextField.setNewTextFormat(m_MissionTypeTextFormat);
			var missionType:String = "";
			switch( i )
			{
				case SLOT_STORY:
					missionType = LDBFormat.LDBGetText( "Quests", "StoryMissionMixedCase" );
				break;
				case SLOT_DUNGEON:
					missionType = LDBFormat.LDBGetText( "Quests", "DungeonMissionMixedCase" );
				break;
				case SLOT_MAIN:
					missionType = LDBFormat.LDBGetText( "Quests", "MainMissionMixedCase" );
				break;
				case SLOT_SIDE_1:
				case SLOT_SIDE_2:
				case SLOT_SIDE_3:
					missionType = LDBFormat.LDBGetText( "Quests", "SideMissionMixedCase" );
			}
			
			missionTypeTextField.text = missionType;
			missionTypeTextField._alpha = 70;
			missionTypeTextField.selectable = false;
			missionTypeTextField._width = missionTypeTextField.textWidth + 4;
			missionTypeTextField._height = missionTypeTextField.textHeight + 3;
			
			missionTypeTextField._x = -missionTypeTextField.textWidth - 25;
			missionTypeTextField._y = 7;
			m_MissionTypeArray.push(missionTypeTextField);
        }
    }
}

function RemoveAllMissions()
{
	for (var i:Number = 0; i < m_MissionTrackerItemArray.length; i++)
	{
		m_MissionTrackerItemArray[i].removeMovieClip();
	}
	for (var i:Number = 0; i < m_MissionTypeArray.length; i++)
	{
		m_MissionTypeArray[i].removeTextField();
	}
	
	m_MissionOutline.removeMovieClip();
	
	m_MissionTrackerItemArray = [];
	m_MissionTypeArray = [];	
}


//Returns false if it doesnt actually update anything
function ShowMission(tierId:Number, goalId:Number, isActive:Boolean) :Boolean
{
    Log.Info2("MissionTracker", "MissionTracker:ShowMission(" + tierId + ", "+goalId+", "+isActive+")");
	if (tierId == 0)
	{
		return;
	}
	var mission:Quest = GetMission(tierId);
	
    if ( mission != undefined)
    {
        if (m_MissionTrackerItem != undefined)
        {
            m_MissionTrackerItem.removeMovieClip();
            m_MissionTrackerItem = undefined;
        }
		
		if (m_MissionOutline != undefined)
		{
			m_MissionOutline.removeMovieClip();
			
			for (var i:Number = 0; i < SLOT_COUNT; i++ )
			{
				if (m_MissionBar["Slot" + i].m_MissionTrackerItem != undefined && m_MissionBar["Slot" + i].m_MissionTrackerItem.GetMissionId() == tierId)
				{
					m_MissionOutline = m_MissionBar["Slot" + i].attachMovie("MissionSlotOutline", "m_Outline", m_MissionBar["Slot" + i].getNextHighestDepth());
					m_MissionOutline._xscale = m_MissionOutline._yscale = 80;
				}
			}
		}
        
        m_MissionTrackerItem = MissionTrackerItem( attachMovie("MissionTrackerItem", "m_MissionTrackerItem " + UID(), getNextHighestDepth()) );
        m_MissionTrackerItem.SetData( mission )
        m_MissionTrackerItem.Draw();
        m_MissionTrackerItem.SetGoalVisibility(!m_IsBarActive, true)
        m_MissionTrackerItem._x = 50;
        m_MissionTrackerItem._xscale = 90;
        m_MissionTrackerItem._yscale = 90;

        // FIXME: icon is not defined here, figure out where it went and connect the event handler again.
//        icon.addEventListener("dragOut", this, "IconMouseDragHandler");
        m_MissionTrackerItem.onRelease = Delegate.create( this, OpenMissionJournal);

        DistributedValue.SetDValue("ActiveQuestID", tierId);
		DistributedValue.SetDValue("OpenJournalQuest", tierId );
		m_ActiveMission = tierId;
		return true;
    }
	return false;
}

function OpenMissionJournal()
{
    
    m_IsMissionJournalActive.SetValue( true );
}

function GetMissionSlot(missionType:Number)
{
	var slotId:Number = -1;
    
	switch( missionType )
	{
		case    _global.Enums.MainQuestType.e_Action:
		case    _global.Enums.MainQuestType.e_Sabotage:
		case    _global.Enums.MainQuestType.e_Challenge:
		case    _global.Enums.MainQuestType.e_Investigation:
			slotId = SLOT_MAIN;
		break;
		case    _global.Enums.MainQuestType.e_Lair:
		case    _global.Enums.MainQuestType.e_Group:
        case    _global.Enums.MainQuestType.e_Raid:
			slotId = SLOT_DUNGEON;
		break;
		case    _global.Enums.MainQuestType.e_Story:
			slotId = SLOT_STORY;
		break;
		case    _global.Enums.MainQuestType.e_Item:
		case    _global.Enums.MainQuestType.e_PvP:
		case    _global.Enums.MainQuestType.e_Massacre:
			if (m_MissionBar["Slot" + SLOT_SIDE_1].m_MissionTrackerItem == undefined)
			{
				slotId = SLOT_SIDE_1
			}
			else if (m_MissionBar["Slot" + SLOT_SIDE_2].m_MissionTrackerItem == undefined)
			{
				slotId = SLOT_SIDE_2
			}
			else
			{
				slotId = SLOT_SIDE_3
			}
		break;
	}
    
    
    return slotId;
}

function GetMission(missionID) : Quest
{
   var quests:Array = Quests.GetAllActiveQuests();
    for ( var i = 0; i < quests.length; ++i )
    {
        if (quests[i].m_ID == missionID)
        {
            return quests[i];
        }
    }
    
    return null;
}


function IconDoubleClickHandler(missionId)
{
    if (m_IsMissionJournalActive.GetValue())
    {
       Quests.SignalMissionRequestFocus.Emit( missionId );   
    }
    else
    {
        DistributedValue.SetDValue("OpenJournalQuest", missionId );
        m_IsMissionJournalActive.SetValue( true );
    }
}


/// When a new mission has been spawned, shift focus to this
function SlotTaskAdded( missionID:Number) :Void
{
    Log.Info2("MissionTracker", "MissionTracker:SlotTaskAdded(" + missionID + ")");

	var activeMission:Number = DistributedValue.GetDValue("ActiveQuestID", 0);
	//Call DisplayTier no matter what, but only show the new one if you have autoselectquests set to true (Or you have none set before)
	if (activeMission == missionID || DistributedValue.GetDValue("AutoSelectQuests"))
	{
		if (!ShowMission(missionID, 0))
		{
			m_MissionTrackerItem.TaskAdded( missionID );
		}
	}
    Utils.PlayFeedbackSound("sfx/gui/gui_mission_get.wav")
}

function SlotQuestChanged()
{
    Log.Info2("MissionTracker", "MissionTracker:SlotQuestChanged()");
}

function SlotMissionCompleted( missionId:Number )
{
    Log.Info2("MissionTracker", "MissionTracker:SlotMissionCompleted()");
    if (missionId != undefined)
    {
        m_LastCompletedMission = missionId;
    }

    if (m_MissionTrackerItem.IsAnimationPending(true))
    {
        m_MissionTrackerItem.SignalAnimationsDone.Connect(SlotMissionCompleted, this);
    }
    else
    {
        m_MissionTrackerItem.SignalAnimationsDone.Disconnect(SlotMissionCompleted);
        var newY:Number = m_MissionTrackerItem._y + m_MissionTrackerItem._height;
        m_MissionTrackerItem["tweenTo"](0.2, { _alpha:0, _xscale:200, _yscale:200, _y:newY  }, None.easeNone);
        m_MissionTrackerItem["onTweenComplete"] = Delegate.create(this, RemoveMainMission);
    }
}

function SlotMissionRemoved(missionId:Number)
{
	if (m_MissionTrackerItem.GetMissionId() == missionId)
	{
		var newY:Number = m_MissionTrackerItem._y + m_MissionTrackerItem._height;
		m_MissionTrackerItem["tweenTo"](0.2, { _alpha:0, _xscale:200, _yscale:200, _y:newY  }, None.easeNone);
		m_MissionTrackerItem["onTweenComplete"] = Delegate.create(this, RemoveMainMission);
	}
}


function RemoveMainMission()
{
    m_MissionTrackerItem.removeMovieClip();
    m_MissionTrackerItem = undefined;
	DistributedValue.SetDValue("ActiveQuestID", 0);
	m_ActiveMission = 0;
    ShowNextMission();
}

function SlotMissionRewardsAnimationDone()
{
    DrawReportButton(true);
}
/*
function SlotQuestRewardMakeChoice()
{
    Log.Info2("MissionTracker", "MissionTracker:SlotQuestRewardMakeChoice()");
    DrawReportButton();
}
*/
/// checks if there are any unsent reports and draws the report button if not
function DrawReportButton(animate:Boolean)
{
    Log.Info2("MissionTracker", "MissionTracker:DrawReportButton()");
   if (!Quests.AnyUnsentReports())
    {
        Log.Info2("MissionTracker", "MissionTracker:No unsent reports, aborting!"); 
        return;
    }
    
    /// if there is a button present
    if (m_ReportsButton != undefined)
    {
        m_ReportsButton.SetText();
    }
    else
    {
        m_ReportsButton = this.attachMovie("MissionReportButton", "m_ReportsButton", this.getNextHighestDepth());
        m_ReportsButton._y = -35 
        m_ReportsButton._x = -121;

        if (animate == true)
        {
            m_ReportsButton.Snap();
        }
        else
        {
            m_ReportsButton.Snap();
        }
        GUI.Mission.MissionSignals.SignalMissionReportSent.Connect(RemoveMissionReportButton, this);
    }
    
    SlotGuiModeChanged();
}

function RemoveMissionReportButton()
{
    m_ReportsButton.removeMovieClip();
    m_ReportsButton = undefined;
}

function SlotGuiModeChanged()
{

    var guimode:Number = m_GuiModeMonitor.GetValue();
    if (m_ReportsButton != undefined)
    {
        m_ReportsButton._visible = (guimode & (_global.Enums.GuiModeFlags.e_GUIModeFlags_PlayerGhosting | _global.Enums.GuiModeFlags.e_GUIModeFlags_PlayerDead)) == 0;
    }
}

/// when all MissionRewardWindows has been closed, dispatch this to see if we need to redraw the windows
function SlotMissionReportWindowClosed()
{
    
    setTimeout( Delegate.create(this, DrawReportButton), 3000);
   // DrawReportButton();
}

function IconMouseDragHandler(event:Object)
{
    var dragData:DragObject = new DragObject();
    dragData.type = "mission";
    
    var quest:com.GameInterface.Quest = Quests.GetQuest( Quests.m_CurrentMissionId, true );
    var missionType:String = GUI.Mission.MissionUtils.MissionTypeToString( quest.m_MissionType );
    
    var dragClip:MovieClip = createEmptyMovieClip("m_DragClip", getNextHighestDepth());
    var icon:MovieClip = dragClip.attachMovie("_Icon_Mission_" + missionType, "dragClip", dragClip.getNextHighestDepth(), { _xscale:80, _yscale:80, _alpha:50 } );
    var frame:MovieClip = dragClip.attachMovie("DragDecal", "frame", dragClip.getNextHighestDepth());
    var modifier:MovieClip = dragClip.attachMovie("ShareSymbol", "share", dragClip.getNextHighestDepth(),{_xscale:25, _yscale:25, _x:27, _y:27});
    
    gfx.managers.DragManager.instance.startDrag( event.target, dragClip, dragData, dragData, null, true );
    gfx.managers.DragManager.instance.removeTarget = true;
	m_IsDraggingIcon = true;
}


function IconMouseOverCharacter()
{
	m_IsDragIconHighlighted = true;
    this["m_DragClip"].frame.gotoAndStop("enabled");
}


function IconMouseOutCharacter()
{
	m_IsDragIconHighlighted = false;
    this["m_DragClip"].frame.gotoAndStop("disabled");
}

function SlotObjectUnderMouseChanged(targetID:ID32)
{
	if (m_IsDraggingIcon)
	{
		if (com.GameInterface.Game.TeamInterface.IsInTeam(targetID) && !targetID.Equal(com.GameInterface.Game.Character.GetClientCharID()))
		{
			IconMouseOverCharacter();
		}
		else if (m_IsDragIconHighlighted)
		{
			IconMouseOutCharacter();
		}
	}
}


function SlotDragEnd( event:Object )
{
    if ( event.data.type == "mission" )
    {
        Quests.ShareQuestUnderMouse(Quests.m_CurrentMissionId);   
    }
	m_IsDraggingIcon = false;
   
}
