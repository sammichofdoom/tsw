//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Team;
import com.GameInterface.Game.Raid;
import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.Utils.Signal;
import flash.geom.Point;
import flash.geom.Rectangle;
import GUI.Team.TeamMember;
import GUI.Team.TeamMenu;
import mx.data.to.ValueListIterator;
import mx.transitions.easing.*;
import mx.utils.Delegate;

//Class
class GUI.Team.RaidClip extends MovieClip
{
    //Constants
    public static var MENU_ALIGNMENT_LEFT:Number = 0;
    public static var MENU_ALIGNMENT_RIGHT:Number = 1;

    public static var STATE_NONE:Number = 0;
    public static var STATE_DRAGGING:Number = 1;
    public static var STATE_RESIZING:Number = 2;
    
    public static var SIZE_AUTO:Number = 0;
    public static var SIZE_SMALL:Number = 1;
    public static var SIZE_MEDIUM:Number = 2;
    public static var SIZE_LARGE:Number = 3;
    
    private static var COLLAPSED_PADDING:Number = 6;
    
    //Properties
    public var SignalSizeChanged:Signal;
    
    private var m_Content:MovieClip;
    private var m_MenuButton:MovieClip;
    private var m_CollapsedBackground:MovieClip;
    private var m_CollapsedInvisibleButton:MovieClip;
    private var m_SidePadding:Number;
    private var m_TeamPadding:Number;
    private var m_MenuAlignment:Number;
    private var m_RaidLabel:TextField;
    private var m_Raid:Raid;
    private var m_Teams:Array;
    
    private var m_TeamClips:Array;
    private var m_NumColumns:Number;
    private var m_MovementState:Number;
    private var m_MemberSizeState:Number = TeamMember.STATE_LARGE;
    
    private var m_TeamMenu:TeamMenu;
    
    private var m_ShowingBackground:Boolean;
    private var m_ResizeOffsetPoint:Point; 
    private var m_IsMenuOpen:Boolean;
    private var m_WindowSize:Number;
    private var m_WindowFrameLocked:Boolean;
    private var m_ShowWindow:Boolean;
    private var m_ShowWindowFrame:Boolean;
    private var m_ShowGroupNames:Boolean;
    private var m_ShowHPNumbers:Boolean;
    private var m_ShowHealthBar:Boolean;
    private var m_ShowNametagIcons:Boolean;
    private var m_IsGroupDetached:Boolean;
    
    //Constructor
    public function RaidClip()
    {
        super();
        
        m_Teams = new Array();
        m_TeamClips = new Array();
        SignalSizeChanged = new Signal();
        
        m_NumColumns = 5;
        m_SidePadding = 10;
        m_TeamPadding = 5;
        m_MenuAlignment = MENU_ALIGNMENT_RIGHT;
        m_MovementState = STATE_NONE;
        m_IsMenuOpen = false;
        
        m_ShowingBackground = false;

        m_Content.m_ResizeButton._alpha = 0;
        m_Content.m_InvisibleButton._alpha = 100;
        m_Content.m_Background._alpha = 0;
        m_Content._x = 0;
        m_Content._y = 0;
        m_Content.m_InvisibleButton._x = 0;
        m_Content.m_InvisibleButton._y = 0;
        m_Content.m_TeamClips._x = 0;
        m_Content.m_TeamClips._y = 0;
        m_Content.m_Background._x = 0;
        m_Content.m_Background._y = 0;
    
        m_WindowFrameLocked = false;
        m_ShowWindowFrame = true;
        m_ShowGroupNames = true;
        m_WindowSize = SIZE_AUTO;
        m_ShowHPNumbers = true;
        m_ShowHealthBar = true;
        m_ShowNametagIcons = true;
        m_IsGroupDetached = false;
        
        m_RaidLabel.htmlText = LDBFormat.LDBGetText("TeamGUI", "Raid");
        m_RaidLabel.autoSize = "right";

        SetShowWindow(true);

        m_ResizeOffsetPoint = new Point();
        
        m_Content.m_ResizeButton.onMousePress = Delegate.create(this, SlotStartResizing);
        m_MenuButton.onRelease = Delegate.create(this, ToggleRaidMenu);
    }
    
    //Set Raid
    public function SetRaid(raid:Raid):Void
    {
        m_Raid = raid;
                
        m_Raid.SignalRaidDisbanded.Connect(SlotRaidDisbanded, this);
        m_Raid.SignalRaidGroupAdded.Connect(SlotRaidGroupAdded, this);
        m_Raid.SignalRaidGroupRemoved.Connect(SlotRaidGroupRemoved, this);
        m_Raid.SignalNewRaidLeader.Connect(SlotNewRaidLeader, this);
        
        com.Utils.GlobalSignal.SignalShowFriendlyMenu.Connect(SlotMouseRelease, this);
        
        for (var prop in m_Raid.m_Teams)
        {
            AddTeam(m_Raid.m_Teams[prop], false);
        }
    }
    
    //Add Team
    public function AddTeam(team:Team, forceLayout:Boolean):Void
    {
        var teamClip = m_Content.attachMovie("TeamClip", "team" + team.m_TeamId.toString(), m_Content.getNextHighestDepth());
        teamClip.SetShowGroupNames(m_ShowGroupNames, false);
        teamClip.SetShowHealthBar(m_ShowHealthBar, false);
        teamClip.SetRaid(m_Raid);
        teamClip.SetTeam(team);
        teamClip.SignalSizeChanged.Connect(TeamClipSizeChanged, this);
        
        teamClip.swapDepths(m_Content.m_InvisibleButton);
        m_Content.m_InvisibleButton.swapDepths(m_Content.m_ResizeButton);
        
        m_TeamClips.push(teamClip);

        if (forceLayout)
        {
            Layout();
        }
    }
    
    //Missed Button
    public function MissedButton():Boolean
    {
        return !m_MenuButton.hitTest(_root._xmouse, _root._ymouse);
    }
    
    //Toggle Raid Menu
    private function ToggleRaidMenu():Void
    {
        if (m_IsMenuOpen)
        {
            m_TeamMenu.RemoveMenu();
        }
        else
        {
            m_TeamMenu = TeamMenu(this.attachMovie("TeamMenu", "m_TeamMenu", this.getNextHighestDepth(), { m_RaidClip: this }));
            m_TeamMenu.SetWindowFrameLocked(m_WindowFrameLocked);
            m_TeamMenu.SetShowWindowFrame(m_ShowWindowFrame);
            m_TeamMenu.SetShowGroupNames(m_ShowGroupNames);
            m_TeamMenu.SetShowHPNumbers(m_ShowHPNumbers);
            m_TeamMenu.SetShowHealthBar(m_ShowHealthBar);
            m_TeamMenu.SetShowWindow(m_ShowWindow);
            m_TeamMenu.SetShowNametagIcons(m_ShowNametagIcons);
            m_TeamMenu.Initialize();
            
            if (m_MenuAlignment == MENU_ALIGNMENT_RIGHT)
            {
                m_TeamMenu._x = m_MenuButton._x + m_MenuButton._width - m_TeamMenu._width;                
            }
            else if (m_MenuAlignment == MENU_ALIGNMENT_LEFT)
            {
                m_TeamMenu._x = m_MenuButton._x;
            }
            
            m_TeamMenu._y = m_MenuButton._y + m_MenuButton._height;
            
            m_IsMenuOpen = !m_IsMenuOpen;
            
            if (m_ShowWindow == false)
            {
                m_Content._visible = true;
                m_Content.tweenTo(0.3, { _alpha: 25 }, None.easeNone);
            }
        }
    }

    //Raid Menu Removed
    public function RaidMenuRemoved():Void
    {
        m_IsMenuOpen = false;
        
        if (m_ShowWindow == false)
        {
            m_MovementState = STATE_DRAGGING;
        }
            
        SlotMouseRelease();
    }
    
    //Get Biggest Team
    public function GetBiggestTeam():Point
    {
        var biggestTeam:Point = new Point(0, 0);
        
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            if (m_TeamClips[i].GetTeamVisibility())
            {
                biggestTeam.x = Math.max(biggestTeam.x, m_TeamClips[i]._width);
                biggestTeam.y = Math.max(biggestTeam.y, m_TeamClips[i]._height);
            }
        }
        
        return biggestTeam;
    }

    //Remove
    public function Remove():Void
    {
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            m_TeamClips[i].Remove();
            m_TeamClips[i].removeMovieClip();
        }
        
        m_TeamClips = [];
    }
    
    //Get Visible Team Count
    public function GetVisibleTeamCount():Number
    {
        var count:Number = 0;
        
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            if (m_TeamClips[i].GetTeamVisibility())
            {
                count++;
            }
        }
        
        return count;
    }
    
    //Layout
    public function Layout(sendSignal:Boolean):Void
    {
        sendSignal = (sendSignal == undefined) ? false : sendSignal;
        
        var numTeams:Number = GetVisibleTeamCount();
        
        var teamsPrColumn = Math.ceil(numTeams / m_NumColumns);
        teamsPrColumn = Math.min(teamsPrColumn, Math.max(1, Math.floor(Stage.height / GetBiggestTeam().y * _yscale / 100)));
        
        m_NumColumns = Math.ceil(numTeams / teamsPrColumn);
        
        var j:Number = 0;
        var previousX:Number = _x;
        
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            m_TeamClips[i].Layout(false);
            
            if (m_TeamClips[i].GetTeamVisibility())
            {
                var column:Number = Math.floor(j / teamsPrColumn);
                var row:Number = j % teamsPrColumn;
                var biggestTeam:Point = GetBiggestTeam();
                
                m_TeamClips[i]._x = Math.round(m_SidePadding + (column * (biggestTeam.x + m_TeamPadding)));
                m_TeamClips[i]._y = Math.round(m_SidePadding + (row * (biggestTeam.y + m_TeamPadding)));
                
                j++;
            }
        }
        
        DrawBackground();
        
        if (sendSignal)
        {
            SignalSizeChanged.Emit();
        }
    }
    
    //Team Clip Size Changed
    private function TeamClipSizeChanged():Void
    {
        Layout();
    }
    
    //Slot Raid Disbanded
    private function SlotRaidDisbanded():Void
    {
        Remove();
    }
    
    //Slot Raid Group Added
    private function SlotRaidGroupAdded(teamID:ID32):Void
    {
        AddTeam(m_Raid.m_Teams[teamID.toString()], true);
        
        UpdateWindowSize(m_WindowSize);
    }
    
    //Slot Raid Group Removed
    private function SlotRaidGroupRemoved(teamID:ID32):Void
    {
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            if (m_TeamClips[i].GetTeamID().Equal(teamID))
            {
                m_TeamClips[i].swapDepths(getNextHighestDepth());
                m_TeamClips[i].Remove();
                m_TeamClips[i].removeMovieClip();
                m_TeamClips.splice(i, 1);

                break;
            }
        }

        UpdateWindowSize(m_WindowSize);
    }
    
    //Slot New Raid Leader
    private function SlotNewRaidLeader(teamID:ID32):Void
    {
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            if ( m_TeamClips[i].GettTeamID() == teamID )
            {
                m_TeamClips[i].Layout();
            }
        }
    }
    
    //Slot Mouse Press
    private function SlotMousePress():Void
    {
        m_Content.m_InvisibleButton._visible = false;
        
        if (!m_WindowFrameLocked)
        {
            m_MovementState = STATE_DRAGGING;
         
            if (m_ShowWindow == false)
            {
                m_Content._visible = true;
                m_Content.tweenTo(0.3, { _alpha: 25 }, None.easeNone);
            }

            var scale:Number = DistributedValue.GetDValue("GUIResolutionScale", 100);
            var width:Number = getBounds(_root).xMax - getBounds(_root).xMin - 3;
            var height:Number = getBounds(_root).yMax - getBounds(_root).yMin - 10;
            
            this.startDrag(false, 0, 50, (Stage.width - width) / scale, (Stage.height - height) / scale);
        }
    }

    //Slot Start Resizing
    private function SlotStartResizing():Void
    {
        m_MovementState = STATE_RESIZING;
        
        StartResizing();
    }
    
    //Slot Mouse Release
    private function SlotMouseRelease():Void
    {
        if (m_MovementState == STATE_RESIZING)
        {
            m_MovementState = STATE_NONE;
            
            StopResizing();
        }
        else if(m_MovementState == STATE_DRAGGING)
        {
            m_MovementState = STATE_NONE;
            
            if (m_ShowWindow == false)
            {
                m_Content.tweenTo(0.3, {_alpha: 0}, None.easeNone);
                m_Content.onTweenComplete = function()
                {
                    this._visible = false;
                    this.onTweenComplete = undefined;
                }
            }            
            
            this.stopDrag();
            m_Content.m_InvisibleButton._visible = true;
        }      
    }
    
    //On Mouse Move
    public function onMouseMove():Void
    {
        if (m_MovementState == STATE_RESIZING)
        {
            UpdateResizing();
        }
        else if (m_MovementState == STATE_NONE)
        {
            if (this.hitTest(_root._xmouse, _root._ymouse, false))
            {
                if (!m_ShowingBackground)
                {
                    m_ShowingBackground = true;
                    
                    m_Content.m_Background.tweenTo(0.3, { _alpha:100 }, None.easeNone);
                    m_Content.m_ResizeButton.tweenTo(0.3, { _alpha:100 }, None.easeNone);
                }
            }
            else
            {
                if (m_ShowingBackground && !m_WindowFrameLocked)
                {
                    m_ShowingBackground = false;
                    
                    m_Content.m_Background.tweenTo(0.3, { _alpha:0 }, None.easeNone);
                    m_Content.m_ResizeButton.tweenTo(0.3, { _alpha:0 }, None.easeNone);
                }
            }
        }
    }
    
    //Start Resizing
    private function StartResizing():Void
    {
        m_ResizeOffsetPoint.x = m_Content.m_ResizeButton._xmouse;
        m_ResizeOffsetPoint.y = m_Content.m_ResizeButton._ymouse;
    }
    
    //Stop Resizing
    private function StopResizing():Void
    {
        DrawBackground();
    }
    
    //Update Resizing
    private function UpdateResizing():Void
    {
        if  (
            _xmouse < GetBiggestTeam().x + m_TeamPadding ||
            _ymouse < GetBiggestTeam().y + m_TeamPadding ||
            _root._xmouse > Stage.width - m_ResizeOffsetPoint.x ||
            _root._ymouse > Stage.height - m_ResizeOffsetPoint.y
            )
        {
            return;
        }
        
        ForceResize();
    }
    
    private function ForceResize():Void
    {
        var columns:Number = Math.max(1, Math.floor((_xmouse - m_SidePadding * 2) / (m_TeamClips[0]._width)));
        var teamsPrColumn = Math.ceil(GetVisibleTeamCount() / columns);
        
        columns = Math.min(columns, Math.ceil(GetVisibleTeamCount() / teamsPrColumn));
        
        if (columns != m_NumColumns)
        {
            m_NumColumns = columns;

            Layout();
        }
        
        DrawBackground();
    }
    
    //Draw Background
    function DrawBackground():Void
    {
        m_Content.m_Background.clear();
        m_Content.m_InvisibleButton.clear();
  
        var teamsPrColumn = Math.ceil(GetVisibleTeamCount() / m_NumColumns);
        var width:Number = m_TeamClips[0]._width * m_NumColumns + m_SidePadding * 2 + ((m_NumColumns - 1) * m_TeamPadding);
        var height:Number = GetBiggestTeam().y * teamsPrColumn + m_SidePadding * 2 + ((teamsPrColumn - 1) * m_TeamPadding);

        if (m_ShowWindowFrame)
        {
            var corners = [6, 6, 6, 6];
            var alpha:Number = 60;
            var backgroundOffset:Number = -3;

            com.Utils.Draw.DrawRectangle(m_Content.m_Background, backgroundOffset, 0, width, height, 0x000000, alpha, corners, 1, 0xFFFFFF, 40);
            com.Utils.Draw.DrawRectangle(m_Content.m_InvisibleButton, backgroundOffset, 0, width, height, 0x00FF00, 0, corners, 1, 0x00FF00, 0);
            
            if (m_MovementState == STATE_RESIZING)
            {
                width = _xmouse + m_Content.m_ResizeButton._width - m_ResizeOffsetPoint.x;
                height = _ymouse + m_Content.m_ResizeButton._height - m_ResizeOffsetPoint.y;
                
                com.Utils.Draw.DrawRectangle(m_Content.m_Background, 0, 0, width, height, 0xFFFFFF, 15, corners, 1, 0xFFFFFF, 70);
            }
            
            if (!m_WindowFrameLocked)
            {
                m_Content.m_ResizeButton._visible = true;
                m_Content.m_ResizeButton._x = width - m_Content.m_ResizeButton._width + backgroundOffset;
                m_Content.m_ResizeButton._y = height - m_Content.m_ResizeButton._height;
            }
            else
            {
                m_Content.m_ResizeButton._visible = false;
            }
        }
        else
        {
            m_Content.m_ResizeButton._visible = false;
        }
        
        DrawMenu(m_MenuAlignment);
    }
    
    //Draw Menu
    private function DrawMenu(alignment:Number):Void
    {
        var teamsPrColumn = Math.ceil(GetVisibleTeamCount() / m_NumColumns);
        var width:Number = m_TeamClips[0]._width * m_NumColumns + m_SidePadding * 2 + ((m_NumColumns - 1) * m_TeamPadding);
        
        if (alignment == MENU_ALIGNMENT_RIGHT)
        {
            m_MenuButton._x = width - m_MenuButton._width - 2;
            m_RaidLabel._x = m_MenuButton._x - m_RaidLabel._width - COLLAPSED_PADDING;
            
            m_CollapsedBackground._x = m_CollapsedInvisibleButton._x = m_RaidLabel._x - COLLAPSED_PADDING;
            m_CollapsedBackground._y = m_CollapsedInvisibleButton._y = m_RaidLabel._y - COLLAPSED_PADDING;
        }
        else if (alignment == MENU_ALIGNMENT_LEFT)
        {
            m_MenuButton._x = -2;
            m_RaidLabel._x = m_MenuButton._x + m_MenuButton._width + COLLAPSED_PADDING;
            
            m_CollapsedBackground._x = m_CollapsedInvisibleButton._x = m_MenuButton._x - COLLAPSED_PADDING;
            m_CollapsedBackground._y = m_CollapsedInvisibleButton._y = m_RaidLabel._y - COLLAPSED_PADDING;            
        }

        m_RaidLabel._y = m_MenuButton._y + (m_MenuButton._height / 2) - (m_RaidLabel._height / 2);
        m_CollapsedBackground._width = m_CollapsedInvisibleButton._width = m_RaidLabel._width + m_MenuButton._width + COLLAPSED_PADDING * 3 + 1;
        m_CollapsedBackground._height = m_CollapsedInvisibleButton._height = m_RaidLabel._height + COLLAPSED_PADDING * 2;
            
        if (!m_WindowFrameLocked && m_ShowWindowFrame)
        {
            m_Content.m_InvisibleButton.onPress = m_CollapsedInvisibleButton.onPress = function() { };
            m_Content.m_InvisibleButton.onMousePress = m_CollapsedInvisibleButton.onMousePress = Delegate.create(this, SlotMousePress);
            m_Content.m_InvisibleButton.onMouseUp = m_Content.m_Background.onMouseUp = m_CollapsedInvisibleButton.onMouseUp = Delegate.create(this, SlotMouseRelease);
        }
        else
        {
            delete m_Content.m_InvisibleButton.onPress;
            delete m_Content.m_InvisibleButton.onMousePress;
            delete m_Content.m_InvisibleButton.onMouseUp;
        }
    }
    
    //Set Group Visibility
    public function SetGroupVisibility(index:Number, value:Boolean, forceUpdate:Boolean):Void
    {
        m_TeamClips[index].SetTeamVisibility(value);
        
        if (forceUpdate)
        {
            Layout();
        }
    }
    
    //Update Window Size
    private function UpdateWindowSize(size:Number):Void
    {
        m_WindowSize = size;
        
        switch (m_WindowSize)
        {
            case SIZE_AUTO:     if (GetVisibleTeamCount() > 2)
                                {
                                    m_MemberSizeState = TeamMember.STATE_SMALL;
                                }
                                else
                                {
                                    m_MemberSizeState = TeamMember.STATE_MEDIUM;
                                }

                                break;
                            
            case SIZE_SMALL:    m_MemberSizeState = TeamMember.STATE_SMALL;
                                break;
                            
            case SIZE_MEDIUM:   m_MemberSizeState = TeamMember.STATE_MEDIUM;
                                break;
                            
            case SIZE_LARGE:    m_MemberSizeState = TeamMember.STATE_LARGE;
                                break;
        }
        
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            m_TeamClips[i].SetMemberState(m_MemberSizeState);
        }

        Layout();
    }

    //Get Team Clips
    public function GetTeamClips():Array
    {
        return m_TeamClips;
    }
    
    //Set Show Window
    public function SetShowWindow(show:Boolean):Void
    {
        if (show)
        {
            m_Content.onTweenComplete = undefined;
            m_Content._visible = true;
            m_RaidLabel._visible = false;
            m_CollapsedInvisibleButton._visible = false;
            m_CollapsedBackground.tweenTo(0.3, {_alpha:0}, None.easeNone);
            m_MenuButton.m_CollapsedFill.tweenTo(0.3, {_alpha:0}, None.easeNone);
            m_Content.tweenTo(0.3, {_alpha:100}, None.easeNone);
        }
        else
        {
            m_Content.onTweenComplete = function ()
            {
                this._visible = false;
                this.onTweenComplete = undefined;
            }
            
            m_RaidLabel._visible = true;
            m_CollapsedInvisibleButton._visible = true;
            m_CollapsedBackground.tweenTo(0.3, {_alpha:100}, None.easeNone);
            m_MenuButton.m_CollapsedFill.tweenTo(0.3, {_alpha:100}, None.easeNone);
            m_Content.tweenTo(0.3, {_alpha:0}, None.easeNone);
        }
        m_ShowWindow = show;
    }

    //Get Show Window
    public function GetShowWindow():Boolean
    {
        return m_ShowWindow;
    }

    //Set Window Frame Locked
    public function SetWindowFrameLocked(value:Boolean, forceUpdate:Boolean):Void
    {
        m_WindowFrameLocked = value;
        
        m_CollapsedBackground.m_Fill.tweenTo(0.3, { _alpha: (value == true) ? 0 : 100 }, None.easeNone);
        
        m_Content.m_InvisibleButton._visible = (value) ? false : true;
            
        if (forceUpdate)
        {
            m_ShowWindowFrame = (m_WindowFrameLocked ? m_WindowFrameLocked : m_ShowWindowFrame);
            
            DrawBackground();
        }
    }
    
    //Get Window Frame Locked
    public function GetWindowFrameLocked():Boolean
    {
        return m_WindowFrameLocked;
    }

    //Set Show Window Frame
    public function SetShowWindowFrame(value:Boolean, forceUpdate:Boolean):Void
    {
        m_ShowWindowFrame = value;
        
        if (forceUpdate)
        {
            DrawBackground();
        }
    }
    
    //Get Show Window Frame
    public function GetShowWindowFrame():Boolean
    {
        return m_ShowWindowFrame;
    }

    //Set Show Group Names
    public function SetShowGroupNames(value:Boolean):Void
    {
        m_ShowGroupNames = value;
        
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            if (m_TeamClips[i] != undefined)
            {
                m_TeamClips[i].SetShowGroupNames(m_ShowGroupNames);
            }
        }
    }
    
    //Get Show Group Names
    public function GetShowGroupNames():Boolean
    {
        return m_ShowGroupNames;
    }
    
    //Set Window Size
    public function SetWindowSize(value:Number):Void
    {
        UpdateWindowSize(value);
    }
    
    //Get Window Size
    public function GetWindowSize():Number
    {
        return m_WindowSize;
    }
    
    //Set Menu Alignment
    public function SetMenuAlignment(value:Number):Void
    {
        m_MenuAlignment = value;
        DrawMenu(m_MenuAlignment);
    }
    
    //Get Menu Alignment
    public function GetMenuAlignment():Number
    {
        return m_MenuAlignment;
    }
    
    //Set Number of Columns
    public function SetNumberOfColumns(value:Number):Void
    {
        m_NumColumns = value;
        Layout();
    }
    
    //Get Number of Columns
    public function GetNumberOfColumns():Number
    {
        return m_NumColumns;
    }

    //Set Show HP Numbers
    public function SetShowHPNumbers(value:Boolean, forceUpdate:Boolean):Void
    {
        m_ShowHPNumbers = value;
        
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            if (m_TeamClips[i] != undefined)
            {
                m_TeamClips[i].SetShowHPNumbers(m_ShowHPNumbers);
            }
        }
        
        if (forceUpdate)
        {
            Layout();
        }
    }
    
    //Get Show HP Numbers
    public function GetShowHPNumbers():Boolean
    {
        return m_ShowHPNumbers;
    }

    //Set Show Health Bar
    public function SetShowHealthBar(value:Boolean, forceUpdate:Boolean):Void
    {
        m_ShowHealthBar = value;
        
        for (var i:Number = 0; i < m_TeamClips.length; i++)
        {
            if (m_TeamClips[i] != undefined)
            {
                m_TeamClips[i].SetShowHealthBar(m_ShowHealthBar);
            }
        }
        
        if (forceUpdate)
        {
            Layout();
        }
    }
    
    //Get Show Health Bar
    public function GetShowHealthBar():Boolean
    {
        return m_ShowHealthBar;
    }

    //Set Show Nametag Icons
    public function SetShowNametagIcons(value:Boolean):Void
    {
        m_ShowNametagIcons = value;
    }
    
    //Get Show Nametag Icons
    public function GetShowNametagIcons():Boolean
    {
        return m_ShowNametagIcons;
    }

    //Set Is Group Detatched
    public function SetIsGroupDetached(value:Boolean):Void
    {
        m_IsGroupDetached = value;
    }
    
    //Get Is Group Detatched
    public function GetIsGroupDetached():Boolean
    { 
        return m_IsGroupDetached;
    }
}