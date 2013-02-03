//Imports
import com.GameInterface.DialogIF;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.Raid;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Game.Team;
import com.GameInterface.ProjectUtils;
import com.Utils.Archive;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import flash.geom.Point;
import flash.geom.Rectangle;
import GUI.Team.TeamClip;
import GUI.Team.RaidClip;
import GUI.Team.TeamMember;

//Constants
var PVP_PLAYFIELD_ID_GAMETWEAK:String = "PvP_FactionVSFactionVSFactionPlayfieldID";

var PVP_WINDOW_FRAME_LOCKED:String = "PVPWindowFrameLocked";
var PVP_SHOW_WINDOW_FRAME:String = "PVPShowWindowFrame";
var PVP_SHOW_GROUP_NAMES:String = "PVPShowGroupNames";
var PVP_SHOW_WINDOW:String = "PVPShowWindow";
var PVP_WINDOW_SIZE:String = "PVPWindowSize";
var PVP_WINDOW_ALIGNMENT:String = "PVPWindowAlignment";
var PVP_SHOW_HP_NUMBERS:String = "PVPShowHPNumbers";
var PVP_SHOW_HEALTH_BAR:String = "PVPShowHealthBar";
var PVP_SHOW_NAMETAG_ICONS:String = "PVPShowNametagIcons";
var PVP_IS_GROUP_DETACHED:String = "PVPIsGroupDetatched";
var PVP_NUMBER_OF_COLUMNS:String = "PVPNumberOfColumns";

var WINDOW_FRAME_LOCKED:String = "WindowFrameLocked";
var SHOW_WINDOW_FRAME:String = "ShowWindowFrame";
var SHOW_GROUP_NAMES:String = "ShowGroupNames";
var SHOW_WINDOW:String = "ShowWindow";
var WINDOW_SIZE:String = "WindowSize";
var WINDOW_ALIGNMENT:String = "WindowAlignment";
var SHOW_HP_NUMBERS:String = "ShowHPNumbers";
var SHOW_HEALTH_BAR:String = "ShowHealthBar";
var SHOW_NAMETAG_ICONS:String = "ShowNametagIcons";
var IS_GROUP_DETACHED:String = "IsGroupDetatched";
var NUMBER_OF_COLUMNS:String = "NumberOfColumns";

//Properties
var SizeChanged:Signal;
var m_ResolutionScaleMonitor:DistributedValue;

var m_ClientCharacter:Character;
var m_DefensiveTargetClip:MovieClip;

var m_CurrentRaid:RaidClip;
var m_CurrentTeam:TeamClip;

var m_InviteDialogIF:DialogIF;

var m_RaidArchive:Archive;
var m_RaidPosition:Point;

//On Load
function onLoad():Void
{
    SizeChanged = new Signal();
    
    m_ResolutionScaleMonitor = DistributedValue.Create("GUIResolutionScale");
    m_ResolutionScaleMonitor.SignalChanged.Connect(Resize, this);
    
    TeamInterface.SignalClientJoinedTeam.Connect(SlotClientJoinedTeam, this);
    TeamInterface.SignalClientLeftTeam.Connect(SlotClientLeftTeam, this);
    
    TeamInterface.SignalClientJoinedRaid.Connect(SlotClientJoinedRaid, this);
    TeamInterface.SignalClientLeftRaid.Connect(SlotClientLeftRaid, this);
        
    CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
    
    m_ClientCharacter = Character.GetClientCharacter();
    
    if (m_ClientCharacter != undefined)
    {
        m_ClientCharacter.SignalDefensiveTargetChanged.Connect(SlotDefensiveTargetChanged, this);
        m_ClientCharacter.SignalCharacterDied.Connect(UpdateRaidArchive, this);
    }
    
    TeamInterface.SignalTeamInvite.Connect(SlotTeamInvite, this);
    TeamInterface.SignalTeamInviteTimedOut.Connect(SlotInviteTimedOut, this);
    
    TeamInterface.SignalRaidInvite.Connect(SlotRaidInvite, this);
    TeamInterface.SignalRaidInviteTimedOut.Connect(SlotInviteTimedOut, this);
}

//On Module Activated
function OnModuleActivated(config:Archive):Void
{
    if ( config != undefined )
    {
        m_RaidArchive = config.FindEntry("RaidWindowConfig");
        m_RaidPosition = config.FindEntry("RaidPosition");
    }

    if (m_ClientCharacter != undefined)
    {
        SlotDefensiveTargetChanged(m_ClientCharacter.GetDefensiveTarget());
    }
    
    TeamInterface.RequestTeamInformation();   

    Resize();
}

//On Module Deactivated
function OnModuleDeactivated():Archive
{
    var archive:Archive = new Archive();
    
    if (m_CurrentRaid != undefined)
    {
        m_RaidPosition.x = m_CurrentRaid._x;
        m_RaidPosition.y = m_CurrentRaid._y;

        var startPosition:Point = new Point();
        startPosition.x = Stage["visibleRect"].x + Stage["visibleRect"].width - 300;
        startPosition.y = 40;

        archive.AddEntry("RaidPosition", m_RaidPosition);
        
        if (m_RaidArchive != undefined)
        {
            UpdateRaidArchive();
            archive.AddEntry("RaidWindowConfig", m_RaidArchive); 
        }
        
        m_CurrentRaid.removeMovieClip();
        m_CurrentRaid = undefined;
    }
    
    SlotClientLeftTeam();

    return archive;
}

//Slot Client Character Alive
function SlotClientCharacterAlive():Void
{
    m_ClientCharacter = Character.GetClientCharacter();
    m_ClientCharacter.SignalDefensiveTargetChanged.Connect(SlotDefensiveTargetChanged, this);
    
    SlotDefensiveTargetChanged(m_ClientCharacter.GetDefensiveTarget());
}

//Slot Client Joined Team
function SlotClientJoinedTeam(team:Team):Void
{
    SlotClientLeftTeam();
    
    m_CurrentTeam = attachMovie("TeamClip", "team", getNextHighestDepth());
    m_CurrentTeam.SetShowGroupNames(false);
    m_CurrentTeam.SetTeam(team);
    m_CurrentTeam.SignalSizeChanged.Connect(PlaceTeam, this);
    
    PlaceTeam();
    
    if (m_RaidArchive != undefined)
    {
        m_CurrentTeam.SetIsMinimized(m_RaidArchive.FindEntry("TeamWindowMinimized", false));
    }
}

//Slot Client Left Team
function SlotClientLeftTeam():Void
{
    UpdateRaidArchive();
    
    if (m_CurrentTeam != undefined)
    {
        m_CurrentTeam.SignalSizeChanged.Disconnect(PlaceTeam, this);
        m_CurrentTeam.Remove();
        m_CurrentTeam.removeMovieClip();
        m_CurrentTeam = undefined;
    }
}

//Slot Client Joined Raid
function SlotClientJoinedRaid(raid:Raid):Void
{
    ClearRaid();
    
    m_CurrentRaid = attachMovie("RaidClip", "raid", getNextHighestDepth());
    m_CurrentRaid.SetRaid(raid);
    
    if (m_RaidArchive != undefined)
    {
        if (m_ClientCharacter.GetPlayfieldID() == ProjectUtils.GetUint32TweakValue(PVP_PLAYFIELD_ID_GAMETWEAK))
        {
            m_CurrentRaid.SetWindowFrameLocked(m_RaidArchive.FindEntry(PVP_WINDOW_FRAME_LOCKED, false), false);
            m_CurrentRaid.SetShowWindowFrame(m_RaidArchive.FindEntry(PVP_SHOW_WINDOW_FRAME, true), false);
            m_CurrentRaid.SetShowGroupNames(m_RaidArchive.FindEntry(PVP_SHOW_GROUP_NAMES, true));
            m_CurrentRaid.SetShowWindow(m_RaidArchive.FindEntry(PVP_SHOW_WINDOW, false));
            m_CurrentRaid.SetWindowSize(m_RaidArchive.FindEntry(PVP_WINDOW_SIZE, RaidClip.SIZE_AUTO));
            m_CurrentRaid.SetMenuAlignment(m_RaidArchive.FindEntry(PVP_WINDOW_ALIGNMENT, RaidClip.MENU_ALIGNMENT_RIGHT));
            m_CurrentRaid.SetShowHPNumbers(m_RaidArchive.FindEntry(PVP_SHOW_HP_NUMBERS, true),false);
            m_CurrentRaid.SetShowHealthBar(m_RaidArchive.FindEntry(PVP_SHOW_HEALTH_BAR, true), false);
            m_CurrentRaid.SetShowNametagIcons(m_RaidArchive.FindEntry(PVP_SHOW_NAMETAG_ICONS, false), false);
            m_CurrentRaid.SetIsGroupDetached(m_RaidArchive.FindEntry(PVP_IS_GROUP_DETACHED, false), false);
            m_CurrentRaid.SetNumberOfColumns(m_RaidArchive.FindEntry(PVP_NUMBER_OF_COLUMNS, 5), false);
        }
        else
        {
            m_CurrentRaid.SetWindowFrameLocked(m_RaidArchive.FindEntry(WINDOW_FRAME_LOCKED, false), false);
            m_CurrentRaid.SetShowWindowFrame(m_RaidArchive.FindEntry(SHOW_WINDOW_FRAME, true), false);
            m_CurrentRaid.SetShowGroupNames(m_RaidArchive.FindEntry(SHOW_GROUP_NAMES, true));
            m_CurrentRaid.SetShowWindow(m_RaidArchive.FindEntry(SHOW_WINDOW, true));
            m_CurrentRaid.SetWindowSize(m_RaidArchive.FindEntry(WINDOW_SIZE, RaidClip.SIZE_AUTO));
            m_CurrentRaid.SetMenuAlignment(m_RaidArchive.FindEntry(WINDOW_ALIGNMENT, RaidClip.MENU_ALIGNMENT_RIGHT));
            m_CurrentRaid.SetShowHPNumbers(m_RaidArchive.FindEntry(SHOW_HP_NUMBERS, true),false);
            m_CurrentRaid.SetShowHealthBar(m_RaidArchive.FindEntry(SHOW_HEALTH_BAR, true), false);
            m_CurrentRaid.SetShowNametagIcons(m_RaidArchive.FindEntry(SHOW_NAMETAG_ICONS, false), false);
            m_CurrentRaid.SetIsGroupDetached(m_RaidArchive.FindEntry(IS_GROUP_DETACHED, false), false);
            m_CurrentRaid.SetNumberOfColumns(m_RaidArchive.FindEntry(NUMBER_OF_COLUMNS, 5), false);
        }
    }

    m_CurrentRaid.SignalSizeChanged.Connect(PlaceTeam, this);
    m_CurrentRaid._xscale = 80;
    m_CurrentRaid._yscale = 80;
    
    if (m_RaidPosition == undefined)
    {
        var startPosition:Point = new Point();
        startPosition.x = Stage["visibleRect"].x + Stage["visibleRect"].width - 300;
        startPosition.y = 45;
        m_RaidPosition = startPosition;
    }
    
    m_CurrentRaid._x = m_RaidPosition.x;
    m_CurrentRaid._y = m_RaidPosition.y;
    
    CapRaidPosition();
    PlaceTeam();
}

//Update Raid Archive
function UpdateRaidArchive():Void
{
    if (m_RaidArchive == undefined)
    {
        m_RaidArchive = new Archive();
    }

    if (m_CurrentTeam != undefined)
    {
        m_RaidArchive.ReplaceEntry("TeamWindowMinimized", m_CurrentTeam.GetIsMinimized());
    }
    
    if (m_CurrentRaid != undefined)
    {
        if (m_ClientCharacter.GetPlayfieldID() == ProjectUtils.GetUint32TweakValue(PVP_PLAYFIELD_ID_GAMETWEAK))
        {
            m_RaidArchive.ReplaceEntry(PVP_WINDOW_FRAME_LOCKED, m_CurrentRaid.GetWindowFrameLocked());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_WINDOW_FRAME, m_CurrentRaid.GetShowWindowFrame());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_GROUP_NAMES, m_CurrentRaid.GetShowGroupNames());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_WINDOW, m_CurrentRaid.GetShowWindow());
            m_RaidArchive.ReplaceEntry(PVP_WINDOW_SIZE, m_CurrentRaid.GetWindowSize());
            m_RaidArchive.ReplaceEntry(PVP_WINDOW_ALIGNMENT, m_CurrentRaid.GetMenuAlignment());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_HP_NUMBERS, m_CurrentRaid.GetShowHPNumbers());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_HEALTH_BAR, m_CurrentRaid.GetShowHealthBar());
            m_RaidArchive.ReplaceEntry(PVP_SHOW_NAMETAG_ICONS, m_CurrentRaid.GetShowNametagIcons());
            m_RaidArchive.ReplaceEntry(PVP_IS_GROUP_DETACHED, m_CurrentRaid.GetIsGroupDetached());
            m_RaidArchive.ReplaceEntry(PVP_NUMBER_OF_COLUMNS, m_CurrentRaid.GetNumberOfColumns());
        }
        else
        {
            m_RaidArchive.ReplaceEntry(WINDOW_FRAME_LOCKED, m_CurrentRaid.GetWindowFrameLocked());
            m_RaidArchive.ReplaceEntry(SHOW_WINDOW_FRAME, m_CurrentRaid.GetShowWindowFrame());
            m_RaidArchive.ReplaceEntry(SHOW_GROUP_NAMES, m_CurrentRaid.GetShowGroupNames());
            m_RaidArchive.ReplaceEntry(SHOW_WINDOW, m_CurrentRaid.GetShowWindow());
            m_RaidArchive.ReplaceEntry(WINDOW_SIZE, m_CurrentRaid.GetWindowSize());
            m_RaidArchive.ReplaceEntry(WINDOW_ALIGNMENT, m_CurrentRaid.GetMenuAlignment());
            m_RaidArchive.ReplaceEntry(SHOW_HP_NUMBERS, m_CurrentRaid.GetShowHPNumbers());
            m_RaidArchive.ReplaceEntry(SHOW_HEALTH_BAR, m_CurrentRaid.GetShowHealthBar());
            m_RaidArchive.ReplaceEntry(SHOW_NAMETAG_ICONS, m_CurrentRaid.GetShowNametagIcons());
            m_RaidArchive.ReplaceEntry(IS_GROUP_DETACHED, m_CurrentRaid.GetIsGroupDetached());
            m_RaidArchive.ReplaceEntry(NUMBER_OF_COLUMNS, m_CurrentRaid.GetNumberOfColumns());
        }
    }
}

//Slot Client Left Raid
function SlotClientLeftRaid():Void
{
    if (m_ClientCharacter.GetPlayfieldID() != ProjectUtils.GetUint32TweakValue(PVP_PLAYFIELD_ID_GAMETWEAK))
    {
        //Force show Raid for the next raid
        m_CurrentRaid.SetShowWindow(true); 
    }
    
    ClearRaid();
}

function ClearRaid():Void
{
    if (m_CurrentRaid != undefined)
    {
        UpdateRaidArchive();
        
        m_RaidPosition.x = m_CurrentRaid._x;
        m_RaidPosition.y = m_CurrentRaid._y;
        
        m_CurrentRaid.SignalSizeChanged.Disconnect(PlaceTeam, this);
        m_CurrentRaid.Remove();
        m_CurrentRaid.removeMovieClip();
        m_CurrentRaid = undefined;
    }
    
    
}

//Slot Defensive Target Changed
function SlotDefensiveTargetChanged(targetID:ID32):Void
{
    var currentTarget:ID32 = undefined;
    var teamIndex = -1;
    
    if (m_DefensiveTargetClip != undefined)
    {
        currentTarget = m_DefensiveTargetClip.GetID()
        
        if (currentTarget.Equal(targetID))
        {
            return;
        }
        else
        {
            m_DefensiveTargetClip.removeMovieClip();
            m_DefensiveTargetClip = undefined;
        }
    }

    if (!targetID.IsNull())
    {
        var character:Character = Character.GetCharacter(targetID);
        m_DefensiveTargetClip = attachMovie("TeamMember", "m_DefensiveTarget" , getNextHighestDepth());
        m_DefensiveTargetClip.SetCharacter(character);
        m_DefensiveTargetClip.SetLayoutState(TeamMember.STATE_LARGE);
        m_DefensiveTargetClip.SetIsDefensiveTarget(true);
    }

    PlaceTeam();
}

//Resize
function Resize():Void
{
    _x = Stage["visibleRect"].x;
    _y = Stage["visibleRect"].y;
    
    var scale:Number = m_ResolutionScaleMonitor.GetValue();
    _xscale = Math.round(scale * 100);
    _yscale = Math.round(scale * 100);

    PlaceTeam();
    CapRaidPosition();
}

//Place Team
function PlaceTeam():Void
{
    var y:Number = Stage.height * 0.40;
    var upwardsGrowth:Number = 0.4;
    
    if (m_CurrentTeam != undefined)
    {
        m_CurrentTeam._x = 0;
        m_CurrentTeam._y = Math.round(y - (m_CurrentTeam._height * upwardsGrowth));
        
        y += (m_CurrentTeam._height * (1 - upwardsGrowth)) + 20;
    }
    
    if (m_DefensiveTargetClip != undefined)
    {
        m_DefensiveTargetClip._y = Math.round(y);
    }
}

//Cap Raid Position
function CapRaidPosition():Void
{
    if (m_CurrentRaid != undefined)
    {
        if (m_CurrentRaid._x < 0)
        {
            m_CurrentRaid._x = 0;
        }
        
        var maxPosX:Number = Stage.width * 100 / _xscale - m_CurrentRaid._width;
        if (m_CurrentRaid._x > maxPosX)
        {
            m_CurrentRaid._x = maxPosX;
        } 
        
        if (m_CurrentRaid._y < 40)
        {
            m_CurrentRaid._y = 40;
        }
        
        var maxPosY:Number = Stage.height * 100 / _yscale - m_CurrentRaid._height;
        if (m_CurrentRaid._y > maxPosY)
        {
            m_CurrentRaid._y = maxPosY;
        }
    }
    
    m_CurrentRaid._x = Math.round(m_CurrentRaid._x);
    m_CurrentRaid._y = Math.round(m_CurrentRaid._y);
}

//Slot Team Invite
function SlotTeamInvite(inviterID:ID32, inviterName:String):Void
{
    m_InviteDialogIF = new com.GameInterface.DialogIF(LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "JoinTeamWith"), inviterName), Enums.StandardButtons.e_ButtonsYesNo, "JoinTeam");
    m_InviteDialogIF.SignalSelectedAS.Connect(SlotTeamInviteSelected, this)
    m_InviteDialogIF.Go(inviterID);
    m_InviteDialogIF.SignalSelectedAS.Connect(SlotTeamInviteSelected, this)
}

//Slot Invite Time Out
function SlotInviteTimedOut():Void
{
    if (m_InviteDialogIF != undefined)
    {
        m_InviteDialogIF.Close();
        m_InviteDialogIF = null;
    }
}

//Slot Team Invite Selected
function SlotTeamInviteSelected(buttonID:Number, inviterID:ID32):Void
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        TeamInterface.AcceptTeamInvite(inviterID);
    }
    else
    {
        TeamInterface.DeclineTeamInvite(inviterID);
    }
}

//Slot Raid Invite
function SlotRaidInvite(inviterID:ID32, inviterName:String):Void
{
    m_InviteDialogIF = new com.GameInterface.DialogIF("Join raid with " + inviterName, Enums.StandardButtons.e_ButtonsYesNo, "JoinTeam");
    m_InviteDialogIF.SignalSelectedAS.Connect(SlotRaidInviteSelected, this)
    m_InviteDialogIF.Go(inviterID);
}

//Slot Raid Invite Selected
function SlotRaidInviteSelected(buttonID:Number, inviterID:ID32):Void
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        TeamInterface.AcceptRaidInvite(inviterID);
    }
    else
    {
        TeamInterface.DeclineRaidInvite(inviterID);
    }
}
