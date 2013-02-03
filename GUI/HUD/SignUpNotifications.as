//Imports
import com.GameInterface.CharacterLFG;
import com.GameInterface.Game.Character;
import com.GameInterface.LookingForGroup;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;

//Constants
var ALL_DUNGEONS:String = LDBFormat.LDBGetText("GroupSearchGUI", "allDungeons");
var ALL_ADVENTURE_PLAYFIELDS:String = LDBFormat.LDBGetText("GroupSearchGUI", "allAdventurePlayfields");
var DIFFICULTY_NORMAL:String = LDBFormat.LDBGetText("GroupSearchGUI", "normalDifficulty");
var DIFFICULTY_ELITE:String = LDBFormat.LDBGetText("GroupSearchGUI", "eliteDifficulty");
var DIFFICULTY_NIGHTMARE:String = LDBFormat.LDBGetText("GroupSearchGUI", "nightmareDifficulty");
var ICON_GAP:Number = 45;

//Properties
var m_PvPIcon:MovieClip;
var m_LFGIcon:MovieClip;

//Variables
var m_Character:Character;
var m_VisibleNotificationsArray:Array;
var m_PvPQueue:Array;
var m_LFGQueue:Array;
var m_IconWidth:Number;
var m_IconHeight:Number;
var m_DifficultyData:Array;

//On Load
function onLoad():Void
{
    PvPMinigame.SignalYouAreInMatchMaking.Connect(SlotSignUpPvP, this);
	PvPMinigame.SignalNoLongerInMatchMaking.Connect(SlotLeavePvP, this);
    
    LookingForGroup.SignalClientJoinedLFG.Connect(SlotSignUpLFG, this);
    LookingForGroup.SignalClientLeftLFG.Connect(SlotLeaveLFG, this);
    
    m_VisibleNotificationsArray = new Array();
    m_PvPQueue = new Array();
    m_LFGQueue = new Array();
    m_DifficultyData = new Array();
    
    m_DifficultyData.push({label:DIFFICULTY_NORMAL, data:_global.Enums.LFGDifficulty.e_Mode_Normal});
    
    if (LookingForGroup.CanCharacterJoinEliteDungeons())
    {
        m_DifficultyData.push({label:DIFFICULTY_ELITE, data:_global.Enums.LFGDifficulty.e_Mode_Elite});
    }
    
    if (LookingForGroup.CanCharacterJoinNightmareDungeons())
    {
        m_DifficultyData.push({label:DIFFICULTY_NIGHTMARE, data:_global.Enums.LFGDifficulty.e_Mode_Nightmare});
    }
        
    m_IconWidth = m_PvPIcon._width;
    m_IconHeight = m_PvPIcon._height;
    
    SetVisible(m_PvPIcon, false);
    SetVisible(m_LFGIcon, false);
    
    AttatchBadge(m_PvPIcon);
    AttatchBadge(m_LFGIcon);
    
    Character.SignalClientCharacterAlive.Connect(SlotCharacterAlive, this);
    
    SlotCharacterAlive();
}

//Slot Character Alive
function SlotCharacterAlive():Void
{
    PvPMinigame.RequestIsInMatchMaking();
    
    if (LookingForGroup.HasCharacterSignedUp())
    {
        SlotSignUpLFG();        
    }
}

//Slot Sign Up PvP
function SlotSignUpPvP(mapID:Number, asTeamMember:Number):Void
{
	var isQueued:Boolean = false;
    
	for (var i:Number = 0; i < m_PvPQueue.length; i++)
	{
		if (m_PvPQueue[i].mapID == mapID)
		{
			isQueued = true;
			break;
		}
	}
	
	if (!isQueued)
	{
		m_PvPQueue.push({mapID:mapID, asTeamMember:asTeamMember});
	}
    
	UpdatePvPQueue();
}

//Slot Leave PvP
function SlotLeavePvP():Void
{
	m_PvPQueue.pop();

	UpdatePvPQueue();
}

//Update PvP Queue
function UpdatePvPQueue():Void
{
	var queuedItemsTotal:Number = m_PvPQueue.length;

	if (queuedItemsTotal > 0)
	{
		SetVisible(m_PvPIcon, true);

        var title:String = LDBFormat.LDBGetText("WorldDominationGUI", "secretWar");
		var message:String = LDBFormat.LDBGetText("GenericGUI", "You_are_queued");
		
		for (var i:Number = 0; i < queuedItemsTotal; i++)
		{
			message += "<br/>- " + LDBFormat.LDBGetText("Playfieldnames", m_PvPQueue[i].mapID);
		}

		CreateTooltip(m_PvPIcon, title, message);
        
		m_PvPIcon.m_Badge.SetCharge(queuedItemsTotal);
	}
	else
	{
		SetVisible(m_PvPIcon, false);
	}
}

//Slot Sign Up LFG
function SlotSignUpLFG():Void
{
    var characterLFGData:CharacterLFG = LookingForGroup.GetPlayerSignedUpData(); 
    var playfield:String = GetLFGPlayfieldName(characterLFGData.m_Playfields); 
    var difficulty:String = GetLFGDifficultyName(characterLFGData.m_Mode);

    var isQueued:Boolean = false;
	for (var i:Number = 0; i < m_LFGQueue.length; i++)
	{
        trace("-------------- " + m_LFGQueue.length);
		if (m_LFGQueue[i].playfield == playfield)
		{
			isQueued = true;
			break;
		}
	}
	
	if (!isQueued)
	{
        m_LFGQueue.push({playfield:playfield, difficulty:difficulty});
	}
    
	UpdateLFGQueue();
}

//Slog Leave LFG
function SlotLeaveLFG():Void
{
    m_LFGQueue.pop();

	UpdateLFGQueue();
}

//Get LFG Playfield Name
function GetLFGPlayfieldName(playfields:Array):String
{
    if (playfields != undefined && playfields.length > 0)
    {
        if (playfields.length == 1 && playfields[0] != undefined)
        {
            return LDBFormat.LDBGetText("Playfieldnames", playfields[0]);
        }

        for (var i:Number = 0; i < LookingForGroup.m_DungeonPlayfields.length; ++i)
        {
            if (playfields[0] == LookingForGroup.m_DungeonPlayfields[i].m_InstanceId)
            {
                return ALL_DUNGEONS;
            }
        }
        
        for (var i:Number = 0; i < LookingForGroup.m_AdventurePlayfields.length; ++i)
        {
            if (playfields[0] == LookingForGroup.m_AdventurePlayfields[i].m_InstanceId)
            {
                return ALL_ADVENTURE_PLAYFIELDS;
            }
        }
    }
    
    return "";
}

//Get LFG Difficulty Name
function GetLFGDifficultyName(value:Number):String
{
    var index:Number = GetDifficultyIndex(value);
    
    if (index != undefined)
    {
        return m_DifficultyData[index].label;
    }
    
    return undefined;
}

//Get Difficulty Index
function GetDifficultyIndex(value:Number):Number
{
    for (var i:Number = 0; i < m_DifficultyData.length; i++)
    {
        if (value == m_DifficultyData[i].data)
        {
            return i;
        }
    }
    
    return undefined;
}

//Update LFG Queue
function UpdateLFGQueue():Void
{
	var queuedItemsTotal:Number = m_LFGQueue.length;

	if (queuedItemsTotal > 0)
	{
		SetVisible(m_LFGIcon, true);

        var title:String = LDBFormat.LDBGetText("GroupSearchGUI", "GroupSearch_WindowTitle");
		var message:String = LDBFormat.LDBGetText("GenericGUI", "You_are_queued");
		
		for (var i:Number = 0; i < queuedItemsTotal; i++)
		{
            message += "<br/>- " + m_LFGQueue[i].playfield + " (" + m_LFGQueue[i].difficulty + ")";
		}

		CreateTooltip(m_LFGIcon, title, message);

		m_LFGIcon.m_Badge.SetCharge(queuedItemsTotal);
	}
	else
	{
		SetVisible(m_LFGIcon, false);
	}
}

//Set Visible
function SetVisible(targetIcon:MovieClip, visible:Boolean):Void
{
    if (visible == targetIcon._visible)
    {
        return;
    }
    
    if (visible)
    {
        m_VisibleNotificationsArray.push(targetIcon);
    }
    else
    {
        
        for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++)
        {
            if (m_VisibleNotificationsArray[i] == targetIcon)
            {
                m_VisibleNotificationsArray.splice(i, 1);
            }
        }
    }

    targetIcon._visible = visible;
    
    m_VisibleNotificationsArray.sort(Array.DESCENDING);
    
    for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++)
    {
        m_VisibleNotificationsArray[i]._x = 0 + ICON_GAP * i;
    }
}

//Attach Badge
function AttatchBadge(target:MovieClip):Void
{
    var badge:MovieClip = target.attachMovie("_Numbers", "m_Badge", target.getNextHighestDepth());
    badge.UseSingleDigits = true;
    badge.SetColor(0x666666);
    
    badge._x = target._x + m_IconWidth;
    badge._y = target._y + m_IconHeight + 2;
    badge._xscale = badge._yscale = 110;
}

//Create Tooltip
function CreateTooltip(target:MovieClip, title:String, message:String):Void
{
    var htmlText:String = "<b>" + Utils.CreateHTMLString(title, {face: "_StandardFont", color: "#FFFFFF", size: 12}) + "</b>";
    htmlText += "<br/>" + Utils.CreateHTMLString(message, {face: "_StandardFont", color: "#FFFFFF", size: 11});

    TooltipUtils.AddTextTooltip(target, htmlText, 210, TooltipInterface.e_OrientationVertical, false);
}