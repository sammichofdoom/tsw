//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.Team;
import com.GameInterface.Game.Raid;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.Team.RaidClip;
import GUI.Team.TeamMember;
import flash.geom.Point;
import mx.transitions.easing.*;
import mx.utils.Delegate;

//Class
class GUI.Team.TeamClip extends MovieClip
{
    //Properties
    public var SignalSizeChanged:Signal;
    
    private var m_Content:MovieClip;
    
    private var m_Team:Team;
    private var m_Raid:Raid;
    private var m_IsRaidGroup:Boolean;
    private var m_MaxTeamMembers;
    private var m_IsTeamVisible:Boolean;
    private var m_TeamMemberState:Number;
    private var m_TeamWidth:Number;
    private var m_ShowGroupNames:Boolean;
    private var m_ShowHPNumbers:Boolean;
    private var m_MenuButton:MovieClip;   
    private var m_IsMinimized:Boolean; 
    private var m_ShowTeamMemberHealthBar:Boolean;
    private var m_TeamMembers:Array;
    private var m_ClientCharacter:Character;
    private var m_BackgroundPos:Point;
    private var m_BackgroundSize:Point;
    
    private var m_ShowTeamBuffMonitor:DistributedValue;
    private var m_ShowTeamDebuffsMonitor:DistributedValue;
    private var m_ShowTeamStatesMonitor:DistributedValue;
      
    //Constructor
    public function TeamClip()
    {
        super();
        
        m_IsRaidGroup = false;
        m_MaxTeamMembers = 5;
        m_TeamMembers = new Array();
        m_ShowTeamMemberHealthBar = true;
        m_ShowGroupNames = true;
        m_ShowHPNumbers = true;
        m_IsTeamVisible = true;
        m_TeamMemberState = TeamMember.STATE_MEDIUM;
        m_TeamWidth = 0;
        m_BackgroundPos = new Point(0, 0);
        m_BackgroundSize = new Point(0, 0);
        
        SetIsMinimized(false);
        
        m_ShowTeamBuffMonitor = DistributedValue.Create("ShowTeamBuffs");
        m_ShowTeamBuffMonitor.SignalChanged.Connect(SlotShowTeamBuffChanged, this);
        
        m_ShowTeamDebuffsMonitor = DistributedValue.Create("ShowTeamDebuffs");
        m_ShowTeamDebuffsMonitor.SignalChanged.Connect(SlotShowTeamDebuffChanged, this);
        
        m_ShowTeamStatesMonitor = DistributedValue.Create("ShowTeamTokens");
        m_ShowTeamStatesMonitor.SignalChanged.Connect(SlotShowTeamStatesChanged, this);
        
        SignalSizeChanged = new Signal();
        
        CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
        SlotClientCharacterAlive();
        
        m_MenuButton.onRelease = Delegate.create(this, ToggleIsMinimized);
    }

    //Initialize Team
    function InitializeTeam():Void
    {        
        for (var i:Number = 0; i < m_MaxTeamMembers; i++)
        {
            var memberID:ID32 = m_Team.GetTeamMemberID(i);

            if (memberID != undefined && !memberID.IsNull())
            {
                AddTeamMember(i, memberID, false);
            }
            else
            {
                m_TeamMembers[i] = undefined;
            }
            
            Layout();
        }
    }
    
    //Add Team Member
    function AddTeamMember(index:Number, charID:ID32):Void
    {
        if (m_TeamMembers[index] != undefined)
        {
            var oldID:ID32 = m_TeamMembers[index].GetID();
            
            RemoveTeamMember(index);
            
            if (!oldID.Equal(charID))
            {
                AddTeamMember(m_Team.GetTeamMemberIndex(oldID), oldID);
            }
        }
       
        m_TeamMembers[index] = m_Content.attachMovie("TeamMember", "m_Member_" + index, m_Content.getNextHighestDepth());
        m_TeamMembers[index].SetIsInRaid(m_IsRaidGroup);//needs to be set before calling to SetGroupElement
        m_TeamMembers[index].SetGroupElement(m_Team.m_TeamMembers[charID.toString()]);
        m_TeamMembers[index].SetShowHealthBar(m_ShowTeamMemberHealthBar);
        
        if (m_IsRaidGroup) 
        {
            m_TeamMembers[index].SetRaidLeader( m_Raid.IsRaidLeader(charID));
            m_TeamMembers[index].SetLayoutState(m_TeamMemberState);    
        }

        m_TeamMembers[index].SignalSizeChanged.Connect(Layout, this);
        
        var clientChar:Character = Character.GetClientCharacter();
        
        if (clientChar != undefined)
        {
            var defensiveTarget:ID32 = clientChar.GetDefensiveTarget();
            
            if (!defensiveTarget.IsNull() && defensiveTarget == charID)
            {
                m_TeamMembers[index].SetIsTarget(true);
            }
        }
    }

    //Remove
    public function Remove():Void
    {
        for (var i:Number = m_TeamMembers.length - 1; i >= 0; i--)
        {
            RemoveTeamMember(i);
        }
    }
    
    //Remove Team Member
    function RemoveTeamMember(index:Number):Void
    {
        if (m_TeamMembers[index])
        {
            m_TeamMembers[index].SignalSizeChanged.Disconnect(Layout, this);
            m_TeamMembers[index].DisconnectSignals();
            m_TeamMembers[index].removeMovieClip();
            m_TeamMembers[index] = undefined;
        }
    }

    //Remove Team Member Recursively
    function RemoveTeamMemberRecursively(index:Number):Void
    {
        RemoveTeamMember(index);
        
        var nextID:ID32 = m_Team.GetTeamMemberID(index);
        
        if (!nextID.IsNull())
        {
            RemoveTeamMemberRecursively(index + 1);
            AddTeamMember(index, nextID);
        } 
    }
    
    //Layout
    function Layout():Void
    {
        var lastVisibleMemberIndex = 0;
        var ypos:Number
        
        m_Content.m_TeamName._x = 2;
        
        if (m_ShowGroupNames)
        {
            m_Content.m_TeamName._visible = true;
            m_Content.m_TeamName.text = GetTeamName();

            ypos = 30;
        }
        else
        {
            m_Content.m_TeamName._visible = false;
            ypos = 10;
        }

        for (var i:Number = m_TeamMembers.length - 1; i >= 0; i--)
        {
            if (m_TeamMembers[i] != undefined)
            {
                lastVisibleMemberIndex = i;
                break;
            }
        }
        
        var currentHeight:Number = 0;
        var isTeamWidthSet:Boolean = false;
        
        for(var i = 0; i < m_TeamMembers.length; i++)
        {
            var teamMemberClip:MovieClip = m_TeamMembers[i]
            
            if (teamMemberClip != undefined)
            {
                teamMemberClip.SetShowHPNumbers(m_ShowHPNumbers);
                teamMemberClip.SetShowHealthBar(m_ShowTeamMemberHealthBar);
                teamMemberClip.SetIsInRaid(m_IsRaidGroup);
                teamMemberClip.SetRaidLeader( m_IsRaidGroup ? m_Raid.IsRaidLeader(teamMemberClip.GetID()) : false);
                teamMemberClip.SetTeamLeader(m_Team.IsTeamLeader(teamMemberClip.GetID()), false);
                teamMemberClip._y = Math.round(currentHeight + ypos);
                teamMemberClip.Layout();
                
                if (!isTeamWidthSet)
                {
                    isTeamWidthSet = true;
                    m_TeamWidth = teamMemberClip.GetWidth();
                }
                
                currentHeight += teamMemberClip._height;
                teamMemberClip.SetPos(i, lastVisibleMemberIndex);
            }
        }
        
        _visible = m_IsTeamVisible;
        
        if (m_Content && m_BackgroundSize.x != Math.round(m_TeamWidth) || m_BackgroundSize.y != Math.round(currentHeight) || m_BackgroundPos.y != Math.round(ypos))
        {
            m_BackgroundSize.x = Math.round(m_TeamWidth);
            m_Content.m_Background._width = m_BackgroundSize.x;
            
            m_BackgroundSize.y = Math.round(currentHeight);
            m_Content.m_Background._height = m_BackgroundSize.y;
            
            m_BackgroundPos.y = Math.round(ypos);
            m_Content.m_Background._y = m_BackgroundPos.y;
            
            m_Content._x = -6;
            m_MenuButton._x = 0;
            m_MenuButton._y = ypos-m_MenuButton._height - 2;
            
            m_Content.clear();
            m_Content.lineStyle(1, 0xFFFFFF, 100);
            
            var lineY:Number = ypos + m_Content._y;
            
            for (var i = 0; i < m_TeamMembers.length - 1; i++)
            {
                if (m_TeamMembers[i] != undefined && m_TeamMembers[i+1] != undefined)
                {
                    lineY += m_TeamMembers[i]._height;
                    m_Content.moveTo(m_Content.m_Background._x + 1, Math.round(lineY));
                    m_Content.lineTo(m_Content.m_Background._x + m_TeamWidth - 2, Math.round(lineY));
                }
            }
            
            m_Content.m_TeamName._width = m_TeamWidth - 4;
            
            SignalSizeChanged.Emit();
        }
    }
    
    //Slot Character Joined
    private function SlotCharacterJoined(charID:ID32):Void
    {
        var groupElement:GroupElement = m_Team.m_TeamMembers[charID.toString()];
        
        if (groupElement != undefined)
        {
            AddTeamMember(groupElement.m_GroupIndex, charID);
        }
        
        Layout();   
    }

    //Slot Character Left
    private function SlotCharacterLeft(charID:ID32):Void
    {
        var index:Number = GetCharacterIndex(charID);
        
        if (index > -1)
        {
            RemoveTeamMemberRecursively(index);
        }
        
        Layout()
    }
    
    //Slot Team Leader Changed
    private function SlotTeamLeaderChanged(charID:ID32):Void
    {
        for (var i:Number = 0; i < m_TeamMembers.length; i++)
        {
            var teamMember:TeamMember = m_TeamMembers[i];
            
            if (teamMember != undefined)
            {
                //Change team lead is changing raid lead too
                if (charID.Equal(teamMember.GetID()))
                {
                    if (m_IsRaidGroup)
                    {
                        teamMember.SetRaidLeader(true);
                    }
                    teamMember.SetTeamLeader(true);
                }
                else if (teamMember.GetIsTeamLeader())
                {
                    if (m_IsRaidGroup)
                    {
                        m_TeamMembers[i].SetRaidLeader(false);
                    }
                    m_TeamMembers[i].SetTeamLeader(false);
                }
            }
        }
    }
    
    //Slot Client Character Alive
    function SlotClientCharacterAlive():Void
    {
        m_ClientCharacter = Character.GetClientCharacter();
        m_ClientCharacter.SignalDefensiveTargetChanged.Connect(SlotDefensiveTargetChanged, this);
        
        SlotDefensiveTargetChanged(m_ClientCharacter.GetDefensiveTarget());

    }
    
    //Slot Defensive Target Changed
    function SlotDefensiveTargetChanged(targetID:ID32):Void
    {
        for (var i:Number = 0; i < m_TeamMembers.length; i++)
        {
            if (m_TeamMembers[i] != undefined && m_TeamMembers[i].IsTarget() && !targetID.Equal(m_TeamMembers[i].GetID()))
            {
                m_TeamMembers[i].SetIsTarget(false);
            }
        }
        
        if (!targetID.IsNull())
        {
            var teamIndex:Number = GetCharacterIndex(targetID);
            
            if (teamIndex >= 0)
            {
                m_TeamMembers[teamIndex].SetIsTarget(true);
            }
        }
        
        Layout();
    }
    
    //Slot Show Team Buff Changed
    private function SlotShowTeamBuffChanged():Void
    {
        var newValue:Boolean = m_ShowTeamBuffMonitor.GetValue();
        
        for(var i = 0; i < m_TeamMembers.length; i++)
        {
            if (m_TeamMembers[i] != undefined)
            {
                m_TeamMembers[i].ShowBuffs(newValue);
            }
        }
    }

    //Slot Show Team Debuff Changed
    private function SlotShowTeamDebuffChanged():Void
    {
        var newValue:Boolean = m_ShowTeamDebuffsMonitor.GetValue();
        
        for(var i = 0; i < m_TeamMembers.length; i++)
        {
            if (m_TeamMembers[i] != undefined)
            {
                m_TeamMembers[i].ShowDebuffs(newValue);
            }
        }
    }

    //Slot Show Team States Changed
    private function SlotShowTeamStatesChanged():Void
    {
        var newValue:Boolean = m_ShowTeamStatesMonitor.GetValue();
        
        for(var i = 0; i < m_TeamMembers.length; i++)
        {
            if (m_TeamMembers[i] != undefined)
            {
                m_TeamMembers[i].ShowStates(newValue);
            }
        }
    }
    
    //Toggle Is Minimized
    public function ToggleIsMinimized():Void
    {
        SetIsMinimized(!GetIsMinimized());
    }
    
    //Set Is Minimized
    public function SetIsMinimized(mini:Boolean):Void
    {
        if (mini)
        {
            m_Content.onTweenComplete = function()
            {
                this._visible = false;
                this.onTweenComplete = undefined;
            }
            
            m_Content.tweenTo(0.3, { _alpha:0 }, None.easeNone);
        }
        else
        {
            m_Content.onTweenComplete = undefined;
            m_Content._visible = true;
            m_Content.tweenTo(0.3, { _alpha:100 }, None.easeNone);
        }
        
        m_IsMinimized = mini;
    }
    
    //Get Is Minimized
    public function GetIsMinimized():Boolean
    {
        return m_IsMinimized;
    }
    
    //Get Character Index
    function GetCharacterIndex(charID:ID32):Number
    {
        for(var i = 0; i < m_TeamMembers.length; i++)
        {
            if (m_TeamMembers[i] != undefined && m_TeamMembers[i].GetID().Equal(charID))
            {
                return i;
            }
        }
        
        return -1;
    }
    
    //Set Is In Raid
    public function SetIsInRaid(isInRaid:Boolean):Void
    {
        m_IsRaidGroup = isInRaid;
        m_MenuButton._visible = !isInRaid;
    }
    
    //Set Team
    public function SetTeam(team:Team):Void
    {
        if (m_Team)
        {
            m_Team.SignalCharacterJoinedTeam.Disconnect(SlotCharacterJoined, this);
            m_Team.SignalCharacterLeftTeam.Disconnect(SlotCharacterLeft, this);
            m_Team.SignalNewTeamLeader.Disconnect(SlotTeamLeaderChanged, this);
            m_Team.SignalTeamDisband.Disconnect(Remove, this);
            m_Team.SignalMasterLooterChanged.Disconnect(SlotMasterLooterChanged, this);
        }
        
        m_Team = team;
       
        m_Team.SignalCharacterJoinedTeam.Connect(SlotCharacterJoined, this);
        m_Team.SignalCharacterLeftTeam.Connect(SlotCharacterLeft, this);
        m_Team.SignalNewTeamLeader.Connect(SlotTeamLeaderChanged, this);
        m_Team.SignalTeamDisband.Connect(Remove, this);
        m_Team.SignalMasterLooterChanged.Connect(SlotMasterLooterChanged, this);
        
        InitializeTeam();
    }
    
    public function SetRaid(raid:Raid):Void
    {
        if (m_Raid)
        {
            m_Raid.SignalMasterLooterChanged.Disconnect(SlotMasterLooterChanged, this);
        }
        
        m_Raid = raid;
        
        m_Raid.SignalMasterLooterChanged.Connect(SlotMasterLooterChanged, this);
        
        SetIsInRaid(raid != undefined);
    }
    
    private function SlotMasterLooterChanged():Void
    {
        Layout();
    }
    
    //Get Team ID
    public function GetTeamID():ID32
    {
        return m_Team.m_TeamId;
    }
    
    //Get Width
    public function GetWidth():Number
    {
        return m_TeamWidth; 
    }
    
    //Get Team Name
    public function GetTeamName():String
    {
        if (m_Team != undefined && m_Team.m_TeamId != undefined)
        {
            return LDBFormat.LDBGetText("TeamGUI", "Team") + " " + m_Team.m_TeamId.GetInstance();
        }
        else
        {
            return "";
        }
    }
    
    //Set Team Visibility
    public function SetTeamVisibility(visible:Boolean):Void
    {
        m_IsTeamVisible = visible;
    }
    
    //Get Team Visibility
    public function GetTeamVisibility():Boolean
    {
        return m_IsTeamVisible;
    }
    
    //Set Member State
    public function SetMemberState(memberState:Number):Void
    {
        if (memberState != m_TeamMemberState)
        {
            m_TeamMemberState = memberState;
            
            for (var i = 0; i < m_TeamMembers.length; i++)
            {
                if (m_TeamMembers[i] != undefined)
                {
                    m_TeamMembers[i].SetLayoutState(m_TeamMemberState);
                }
            } 
        }
    }
    
    //Set Show Group Names
    public function SetShowGroupNames(showGroupNames:Boolean):Void
    {
        m_ShowGroupNames = showGroupNames;
    }
    
    //Set Show Health Bar
    public function SetShowHealthBar(showHealthBar:Boolean):Void
    {
        m_ShowTeamMemberHealthBar = showHealthBar;
        
        for (var i:Number = 0; i < m_TeamMembers.length; i++)
        {
            if (m_TeamMembers[i] != undefined)
            {
                m_TeamMembers[i].SetShowHealthBar(m_ShowTeamMemberHealthBar);
            }
        }
    }
    
    //Set Show HP Numbers
    public function SetShowHPNumbers(showHPNumbers:Boolean):Void
    {
        m_ShowHPNumbers = showHPNumbers
        
        for (var i:Number = 0; i < m_TeamMembers.length; i++)
        {
            if (m_TeamMembers[i] != undefined)
            {
                m_TeamMembers[i].SetShowHealthBar(m_ShowHPNumbers);
            }
        }
    }
}