//Imports
import com.Components.Buffs;
import com.Components.NameBox;
import com.Components.StatBar;
import com.Components.States;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.TargetingInterface;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.ProjectUtils;
import com.GameInterface.NeedGreed;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Utils.ID32;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import flash.geom.Point;
import mx.utils.Delegate;

//Class
class GUI.Team.TeamMember extends MovieClip
{
    //Constants
    public static var STATE_SMALL:Number = 0;
    public static var STATE_MEDIUM:Number = 1;
    public static var STATE_LARGE:Number = 2;
    
    public static var s_BackgroundAlpha:Number = 20;
    public static var s_BackgroundColor:Number = 0x333333;
    public static var s_BackgrundSelectedColor:Number = 0x555555;
    public static var s_StrokeColor:Number = 0xFFFFFF;
    public static var s_StrokeWidth:Number = 2;
    public static var s_StrokeAlpha:Number = 5;
    public static var s_Curve:Number = 6;
    
    public var ROLE_NONE:Number = -2;
    public var ROLE_TANK:Number;
    public var ROLE_HEALER:Number;
    public var ROLE_DPS:Number;
    public var ROLE_SUPPORT:Number;

    private static var LARGE_SIZE:Number = 235;
    private static var MEDIUM_SIZE:Number = 201;
    private static var SMALL_SIZE:Number = 120;

    //Properties
    public var SignalSizeChanged:Signal;
    
    private var m_TeamMemberWidth:Number;    
    
    private var m_Background:MovieClip;
    private var m_SelectedForMoveBackground:MovieClip;
    private var m_Name:MovieClip;
    private var m_HealthBar:MovieClip;
    private var m_States:MovieClip;
    private var m_Buffs:MovieClip;
    private var m_RoleIcon:MovieClip;
    private var m_LeaderIcon:MovieClip;
    private var m_RaidLeaderIcon:MovieClip;
    private var m_MasterLooterIcon:MovieClip;
    
    private var m_HasBuffs:Boolean;
    private var m_HasStates:Boolean;
    
    private var m_PaddingSmall:Number;

    private var m_LastReportedSize:Point 
    private var m_TeamRoleIconPos:Point;
    private var m_TeamRoleIconScale:Number;
    
    private var m_GroupElement:GroupElement;
    private var m_Character:Character;
    private var m_Interval:Number;
    private var m_IsLastMember:Boolean;
    private var m_BackgroundVisible:Boolean;
    private var m_IsTarget:Boolean;
    private var m_IsInRaid:Boolean;
    private var m_IsTeamLeader:Boolean;
    private var m_IsRaidLeader:Boolean;

    private var m_IsDefensiveTarget:Boolean;
    private var m_ShowHealthBar:Boolean;
    private var m_ShowHPNumbers:Boolean;
    private var m_LayoutState:Number
    private var m_TeamMemberRole:Number;

    //Constructor
    public function TeamMember()
    {
        SignalSizeChanged = new Signal();

        m_TeamRoleIconPos = new Point(0,0);
        m_TeamRoleIconScale = 100;
        m_TeamMemberWidth = LARGE_SIZE;
        
        m_LastReportedSize = new Point();
        
        ROLE_TANK = ProjectUtils.GetUint32TweakValue("PvP_Armor_Tank_Buff");
        ROLE_HEALER = ProjectUtils.GetUint32TweakValue("PvP_Armor_Healer_Buff");
        ROLE_DPS = ProjectUtils.GetUint32TweakValue("PvP_Armor_DamageDealer_Buff");
        ROLE_SUPPORT = ProjectUtils.GetUint32TweakValue("PvP_Armor_Support_Buff");
        
        m_IsTarget = false;
        m_LayoutState = STATE_LARGE
        m_IsLastMember = false;
        m_IsInRaid = false;
        m_IsTeamLeader = false;
        m_IsRaidLeader = false;
        m_TeamMemberRole = ROLE_NONE;
        
        var y:Number = 0;
        var x:Number = 12;

        m_Name = attachMovie("NameBox", "name", getNextHighestDepth());
        m_Name.UseUpperCase(false);
        m_Name.Init();
        m_Name._x = x;
        m_Name._y = y;
        
        y += m_Name._height + 5;
        
        m_ShowHealthBar = true;
        m_ShowHPNumbers = true;

        m_Background._alpha = 0;
        m_Background.onPress = function(){}
        
        y += 15;
        
        AddStates(x, y);
        
        y += 25;
        
        m_SelectedForMoveBackground._visible = false;
        
        AddBuffs(x, y);
        
        NeedGreed.SignalLootModeChanged.Connect(SlotLootModeChanged,this);
    }

    private function SlotLootModeChanged(groupLootMode:Number):Void
    {
        Layout();
    }
    
    //Add Health Bar
    public function AddHealthBar(x:Number, y:Number):Void
    {
        if (m_HealthBar == undefined)
        {
            m_HealthBar = attachMovie("HealthBar2", "health", getNextHighestDepth());
            m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_NUMBER);
            
            if (m_Character != undefined)
            {
                m_HealthBar.SetDynel(m_Character);
            }
            else if (m_GroupElement != undefined)
            {
                m_HealthBar.SetGroupElement(m_GroupElement);
            }
        }
        
        m_HealthBar.Show();
        m_HealthBar._x = x;
        m_HealthBar._y = y;
    }
    
    //Add States
    public function AddStates(x:Number, y:Number, scale:Number):Void
    {
        if (!m_HasStates)
        {
            m_States = attachMovie("States", "states", getNextHighestDepth());
            
            if (m_Character != undefined)
            {
                m_States.SetCharacter(m_Character);
            }
            else if (m_GroupElement != undefined)
            {
                m_States.SetGroupElement(m_GroupElement);
            }
        }
        
        m_States._x = x;
        m_States._y = y;
        
        if (!isNaN(scale))
        {
            m_States._xscale = scale;
            m_States._yscale = scale;
        }
        
        m_HasStates = true;
    }
    
    //Remove States
    public function RemoveStates():Void
    {
        if (m_States != undefined)
        {
            m_States.SetCharacter(undefined);
            m_States.SetGroupElement(undefined);
            m_States.removeMovieClip();
            m_States = undefined;
        }
        
        m_HasStates = false;
    }
    
    //Add Buffs
    public function AddBuffs(x:Number, y:Number, scale:Number):Void
    {
        if (!m_HasBuffs)
        {
            m_Buffs = attachMovie("Buffs", "buffs", getNextHighestDepth());
            m_Buffs.SetDirectionDown();
            m_Buffs.SetMaxPerLine(4);
            
            m_Buffs.ShowCharges(m_IsDefensiveTarget);
            m_Buffs.ShowTimers(m_IsDefensiveTarget);
            m_Buffs.SetMultiline(m_IsDefensiveTarget);

            //m_Buffs.SizeChanged.Connect(SlotBuffSizeChanged, this);
            m_Buffs.SignalBuffAdded.Connect(SlotBuffCountUpdated, this);
            m_Buffs.SignalBuffRemoved.Connect(SlotBuffCountUpdated, this);
            
            if (m_Character != undefined)
            {
                m_Buffs.SetCharacter(m_Character);
            }
            else if (m_GroupElement != undefined)
            {
                m_Buffs.SetGroupElement(m_GroupElement);
            }
        }
        
        m_Buffs._x = x;
        m_Buffs._y = y;
        
        if (!isNaN(scale))
        {
            m_Buffs._xscale = scale;
            m_Buffs._yscale = scale;
        }
        
        m_HasBuffs = true;
    }
    
    //Remove Buffs
    public function RemoveBuffs():Void
    {
        m_HasBuffs = false;
        
        if (m_Buffs != undefined)
        {
            m_Buffs.SetCharacter(undefined);
            m_Buffs.SetGroupElement(undefined);
            m_Buffs.removeMovieClip();
            m_Buffs = undefined;
        }

    }
    
    //Slot Buff Count Updated
    private function SlotBuffCountUpdated():Void
    {
        SlotBuffSizeChanged();
        Layout();
    }
    
    //Slot Buff Size Changed
    public function SlotBuffSizeChanged():Void
    {
        if (m_LastReportedSize.x != this._width && m_LastReportedSize.y != this._height)
        {
            SignalSizeChanged.Emit();
        }
    }
    
    private function SlotMarkForTeamMove(id:ID32):Void
    {
        if (m_IsInRaid && !id.IsNull() && GetID().Equal(id) )
        {
            m_SelectedForMoveBackground._visible = true;
        }
    }
    
    private function SlotUnmarkForTeamMove(id:ID32):Void
    {
        if (m_GroupElement && !id.IsNull() && m_GroupElement.m_CharacterId.Equal(id))
        {
            m_SelectedForMoveBackground._visible = false;
        }
    }
    
    //Add Team Member Roll Icon
    private function AddTeamMemberRoleIcon() : Boolean
    {
        if (m_IsTeamLeader && !m_IsRaidLeader)
        {
            if (m_LeaderIcon == undefined )
            {
                m_LeaderIcon = attachMovie("TeamLeaderIcon", "leaderIcon", getNextHighestDepth());
            }
            
            var xpos:Number = (m_HealthBar != undefined) ? m_HealthBar._x : 5;
            
            m_LeaderIcon._xscale = m_TeamRoleIconScale;
            m_LeaderIcon._yscale = m_TeamRoleIconScale;
            m_LeaderIcon._x = xpos;
            m_LeaderIcon._y = 3;

            m_Name._x = xpos + m_LeaderIcon._width + 2;
        }
        else
        {
            if (m_LeaderIcon != undefined )
            {
                //m_Name._x = m_LeaderIcon._x;
                m_LeaderIcon.removeMovieClip();
                m_LeaderIcon = undefined;
            }
        }
        
        if (m_IsRaidLeader)
        {
            if (m_RaidLeaderIcon == undefined )
            {
                m_RaidLeaderIcon = attachMovie("RaidLeaderIcon", "raidLeaderIcon", getNextHighestDepth());
            }
            var xpos:Number = (m_HealthBar != undefined) ? m_HealthBar._x : 5;
           
            m_RaidLeaderIcon._xscale = m_TeamRoleIconScale;
            m_RaidLeaderIcon._yscale = m_TeamRoleIconScale;
            m_RaidLeaderIcon._x = xpos;
            m_RaidLeaderIcon._y = 3;

            m_Name._x = xpos + m_RaidLeaderIcon._width + 2;
        }
        else
        {
            if (m_RaidLeaderIcon != undefined )
            {
                m_RaidLeaderIcon.removeMovieClip();
                m_RaidLeaderIcon = undefined;
            }
        }
        
        if (!m_RaidLeaderIcon && !m_LeaderIcon)
        {
            m_Name._x = xpos;
        }
        
        var charId:ID32 = (m_Character)?m_Character.GetID():m_GroupElement.m_CharacterId;
        var isMasterLooter:Boolean = NeedGreed.IsMasterLooter(charId);
        if ( isMasterLooter )
        {
            if (m_MasterLooterIcon == undefined)
            {
                m_MasterLooterIcon = attachMovie("MasterLooterIcon", "masterLooterIcon", getNextHighestDepth());
                //Master Looter tooltip
                TooltipUtils.AddTextTooltip( m_MasterLooterIcon, LDBFormat.LDBGetText("MiscGUI", "GroupLootMode_2"), 20, TooltipInterface.e_OrientationHorizontal,  true);
            }
            
            m_MasterLooterIcon._xscale = m_TeamRoleIconScale;
            m_MasterLooterIcon._yscale = m_TeamRoleIconScale;
            m_MasterLooterIcon._x = m_Background._width - m_MasterLooterIcon._width;
            m_MasterLooterIcon._y = 3;
        }
        else
        {
            if (m_MasterLooterIcon != undefined )
            {
                m_MasterLooterIcon.removeMovieClip();
                m_MasterLooterIcon = undefined;
            }
        }
        
        
        if (m_RoleIcon.type != m_TeamMemberRole || m_TeamMemberRole == undefined)
        {
            if (m_RoleIcon != undefined)
            {
                m_RoleIcon.removeMovieClip();
                m_RoleIcon = undefined;
            }
            
            if (m_TeamMemberRole == ROLE_TANK)
            {
                m_RoleIcon = attachMovie("RoleIconTank", "m_RoleIconTank", getNextHighestDepth());
            }
            else if (m_TeamMemberRole == ROLE_DPS)
            {
                m_RoleIcon = attachMovie("RoleIconDPS", "m_RoleIconDPS", getNextHighestDepth());
            }
            else if (m_TeamMemberRole == ROLE_HEALER)
            {
                m_RoleIcon = attachMovie("RoleIconHeal", "m_RoleIconHeal", getNextHighestDepth());
            }
            else if (m_TeamMemberRole == ROLE_SUPPORT)
            {
                m_RoleIcon = attachMovie("RoleIconSupport", "m_RoleIconSupport", getNextHighestDepth());
            }
        }

        if (m_RoleIcon != undefined)
        {
            m_RoleIcon.type = m_TeamMemberRole;
            m_RoleIcon._xscale = m_TeamRoleIconScale;
            m_RoleIcon._yscale = m_TeamRoleIconScale;
            
            if (m_HealthBar != undefined)
            {
                m_RoleIcon._x = m_HealthBar._x +  m_HealthBar._width - m_RoleIcon._width;    
            }
            else
            {
                m_RoleIcon._x = m_TeamMemberWidth - m_RoleIcon._width - 5;
            }
            
            if (m_Name != undefined)
            {
                
                m_Name.SetMaxWidth( m_RoleIcon._x - m_Name._x); 
            }
            m_RoleIcon._y = 5;
            
            return true;
        }
        
        return false;
    }

    
    //Toggle Background Visibility
    private function ToggleBackgroundVisibility():Void
    {
        m_BackgroundVisible = !m_BackgroundVisible;
        m_Background._alpha = (m_BackgroundVisible ? 100 : 0);
    }
    
    //Layout
    public function Layout():Void
    {
        var ypos:Number;
        
        clear();
        
        if (m_LayoutState == STATE_SMALL)
        {
            ypos = 25;
            
            m_Name.SetMaxWidth(110);
            m_Name._y = 4
            m_Name._xscale = 85;
            m_Name._yscale = 85;
            
            m_TeamRoleIconScale = 85;
            
            var hasIcon:Boolean = AddTeamMemberRoleIcon();

            if (m_ShowHealthBar)
            {
                AddHealthBar(8, ypos);
                
                m_HealthBar.SetBarScale(36, 50, 60);
                m_HealthBar.SetShowText(m_ShowHPNumbers);
                m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_PERCENT);
                
                ypos += 12;
            }
            else
            {
                m_HealthBar.Hide();
            }

            if (m_HasBuffs)
            {
                RemoveBuffs();
            }
            
            if (m_HasStates)
            {
                RemoveStates();
            }
            
            ypos += 5
        }

        else if (m_LayoutState == STATE_MEDIUM)
        {
            ypos = 25
            
            m_Name.SetMaxWidth(180);
            m_Name._y = 2;
            
            m_TeamRoleIconScale = 90;
            
            var hasIcon:Boolean = AddTeamMemberRoleIcon();

            if (m_ShowHealthBar)
            {
                
                AddHealthBar(15, ypos);
                
                m_HealthBar.SetBarScale(58, 58, 70);
                m_HealthBar.SetShowText(m_ShowHPNumbers);
                m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_NUMBER);
                
                ypos += 15
            }
            else
            {
                m_HealthBar.SetBarScale(58, 58);
                m_HealthBar.Hide();
            }
            
            AddStates(17, ypos, 57.5);

            if (m_HasBuffs)
            {
                RemoveBuffs();
            }
            
            ypos += 17

        }
        
        else if (m_LayoutState == STATE_LARGE)
        {
            ypos = 23
            m_Name.SetMaxWidth(220);
            m_TeamRoleIconScale = 100;

            var hasIcon:Boolean = AddTeamMemberRoleIcon();

            if (m_ShowHealthBar)
            {
                AddHealthBar(15, ypos);
                
                m_HealthBar.SetBarScale(70, 70, 80);
                m_HealthBar.SetShowText(m_ShowHPNumbers);
                m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_NUMBER);
                
                ypos += 14;
            }
            else
            {
                m_HealthBar.Hide();
            }

            AddStates(16, ypos, 69.5);
            ypos += 18;
            AddBuffs(10, ypos, 60);
            
            var buffSize:Number = m_Buffs._height + 1;
            
            ypos += (m_Buffs.GetBuffCount() > 0) ? buffSize : 15;

            break;
        }
        
        m_Background._height = ypos;
        m_Background._width = m_TeamMemberWidth;
        
        m_SelectedForMoveBackground._height = ypos
        m_SelectedForMoveBackground._width = m_TeamMemberWidth;

        if (m_Buffs != undefined)
        {
            m_Buffs.SetWidth((m_TeamMemberWidth-20) * 100 / 50);
        }
        
        m_LastReportedSize.x = this._width;
        m_LastReportedSize.y = this._height;
    }
    
    //On Mouse Release
    public function onMouseRelease(buttonIdx:Number):Void
    {
        if (buttonIdx == 1)
        {
            if (m_GroupElement != undefined)
            {
                TargetingInterface.SetTarget(m_GroupElement.m_CharacterId);
            }
            else if (m_Character != undefined)
            {
                TargetingInterface.SetTarget(m_Character.GetID());
            }
        }
        else if (buttonIdx == 2)
        {
            var characterId:ID32;
            var name:String = "";

            if (m_GroupElement != undefined)
            {
                characterId = m_GroupElement.m_CharacterId;
                name = m_GroupElement.m_Name;
            }
            else if (m_Character != undefined)
            {
                characterId = m_Character.GetID();
                name = m_Character.GetName();
            }

            if (characterId != undefined)
            {
                com.Utils.GlobalSignal.SignalShowFriendlyMenu.Emit(characterId, name);
            }           
        }   
    }
    
    //Filter Roll Buff
    private function FilterRoleBuff(buffId:Number):Void
    {
        if (buffId == ROLE_DPS || buffId == ROLE_HEALER || buffId == ROLE_TANK || buffId == ROLE_SUPPORT)
        {
            m_TeamMemberRole = buffId;
            AddTeamMemberRoleIcon();
            
            Layout();
        }
    }
    
    //Is Target
    public function IsTarget():Boolean
    {
        return m_IsTarget;
    }
    
    //Set Is Target
    public function SetIsTarget(isTarget:Boolean):Void
    {
        m_IsTarget = isTarget;
        SetTargetBackground();
    }
    
    //Set Is Defensive Target
    public function SetIsDefensiveTarget(isTarget:Boolean):Void
    {
        m_IsDefensiveTarget = isTarget;
        SetDefensiveTargetBackground();
        
        if (m_Buffs != undefined)
        {
            m_Buffs.ShowCharges(true);
            m_Buffs.ShowTimers(true);
            m_Buffs.SetMultiline(true);
        }
    }
    
    //Set Target Background
    private function SetTargetBackground():Void
    {
        m_Background._width = m_TeamMemberWidth;
        m_Background._alpha = (m_IsTarget) ? 100 : 0;
    }

    //Set Pos
    public function SetPos(pos:Number, maxPos:Number):Void
    {
        m_IsLastMember = (pos == maxPos);
    }
    
    //Set Defensive Target background
    private function SetDefensiveTargetBackground():Void
    {
        if (m_IsDefensiveTarget)
        {
            m_Background._alpha = 100;
            m_Background._width = (m_LayoutState == STATE_LARGE) ? m_TeamMemberWidth + 3 : m_TeamMemberWidth;
        }
        else
        {
            SetTargetBackground();
        }
    }   
    
    //Set Layout State
    public function SetLayoutState(state:Number):Void
    {
        m_LayoutState = state;
        
        switch(m_LayoutState)
        {
            case STATE_LARGE:   m_TeamMemberWidth = LARGE_SIZE;
                                break;

            case STATE_MEDIUM:  m_TeamMemberWidth = MEDIUM_SIZE;
                                break;
                                
            case STATE_SMALL:   m_TeamMemberWidth = SMALL_SIZE;
        }
        
        Layout();
    }
    
    //Set Group Element
    public function SetGroupElement(groupElement:GroupElement):Void
    {
        m_GroupElement = groupElement; 
        m_TeamMemberRole = m_GroupElement.m_Role;
        m_Name.SetGroupElement(m_GroupElement);
        
        if (m_Buffs != undefined)
        {
            m_Buffs.SetGroupElement(m_GroupElement);
        }
        
        if (m_States != undefined)
        {
            m_States.SetGroupElement(m_GroupElement);
        }
        
        if (m_HealthBar != undefined)
        {
            m_HealthBar.SetGroupElement(m_GroupElement);
        }
        else
        {
            AddHealthBar(0, 0);
            
            Layout();
        }
        
        var character:Character = Dynel.GetDynel(m_GroupElement.m_CharacterId)
        character.SignalBuffAdded.Connect(FilterRoleBuff, this);
        
        for (var prop in character.m_BuffList)
        {
            FilterRoleBuff(prop);
        }
        
        TeamInterface.SignalMarkForTeamMove.Connect(SlotMarkForTeamMove,this);
        TeamInterface.SignalUnmarkForTeamMove.Connect(SlotUnmarkForTeamMove, this);
        var characterMarked:ID32 = TeamInterface.GetCharacterMarkedForTeamMove();
        if (!characterMarked.IsNull() && characterMarked.Equal(m_GroupElement.m_CharacterId))
        {
            SlotMarkForTeamMove(TeamInterface.GetCharacterMarkedForTeamMove());
        }
    }
    
    public function DisconnectSignals():Void
    {
        NeedGreed.SignalLootModeChanged.Disconnect(Layout,this);
        TeamInterface.SignalMarkForTeamMove.Disconnect(SlotMarkForTeamMove, this);
        TeamInterface.SignalUnmarkForTeamMove.Disconnect(SlotUnmarkForTeamMove, this);
    }
    
    public function SetIsInRaid(val:Boolean):Void
    {
        m_IsInRaid = val;
    }
    
    //Set Team Leader
    public function SetTeamLeader(value:Boolean):Void
    {
        m_IsTeamLeader = value;
        AddTeamMemberRoleIcon();
    }
    
    public function SetRaidLeader(value:Boolean):Void
    {
        m_IsRaidLeader = value;
        if (value)
        {
            AddTeamMemberRoleIcon();
        }
    }
    
    //Get Is Team Leader
    public function GetIsTeamLeader():Boolean
    {
        return m_IsTeamLeader;
    }

    public function GetIsRaidLeader():Boolean
    {
        return m_IsRaidLeader;
    }
    
    //Get Width
    public function GetWidth():Number
    {
        return m_TeamMemberWidth;
    }
    
    //Set Character
    public function SetCharacter(character:Character, forceLayout:Boolean):Void
    {
        m_Character = character;
        
        m_HealthBar.SetDynel(character);
        m_Name.SetDynel(character);
        
        if (m_Buffs != undefined)
        {
            m_Buffs.SetCharacter(character);
        }
        
        if (m_States != undefined)
        {
            m_States.SetCharacter(character);
        }
        
        if (m_HealthBar != undefined)
        {
            m_HealthBar.SetCharacter(character);
        }
        else
        {
            AddHealthBar(0, 0)
            forceLayout = true;
        }

        m_Character.SignalBuffAdded.Connect(FilterRoleBuff, this);
        
        for (var prop in m_Character.m_BuffList)
        {
            FilterRoleBuff(prop);
        }

        if (forceLayout == true)
        {
            Layout();
        }
    }
    
    //Set Show Health Bar
    public function SetShowHealthBar(value:Boolean):Void
    {
        m_ShowHealthBar = value;
    }
    
    //Set Show HP Numbers
    public function SetShowHPNumbers(value:Boolean):Void
    {
        m_ShowHPNumbers = value;
    }
    
    //Get ID
    public function GetID():ID32
    {
        if (m_GroupElement != undefined)
        {
            return m_GroupElement.m_CharacterId;
        }
        else
        {
            return m_Character.GetID();
        }
    }
}