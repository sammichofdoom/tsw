//Imports
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Game.Team;
import com.GameInterface.ProjectUtils;
import com.Utils.LDBFormat;
import gfx.controls.DropdownMenu;
import GUI.WorldDomination.UniformTypes;
import flash.geom.Rectangle;
import mx.utils.Delegate;

//Class
class GUI.WorldDomination.SidePanel extends MovieClip
{
    //Constants
    public static var CAPTURE_THE_RELICS:String = LDBFormat.LDBGetText("WorldDominationGUI", "captureTheRelics");
    public static var PRERSISTENT_WARZONE:String = LDBFormat.LDBGetText("WorldDominationGUI", "presistentWarzone");
    
    private static var SIDE_PANEL_LEFT_MARGIN:Number = 23;
    private static var SIDE_PANEL_HEIGHT_PERCENTAGE:Number = 0.955;
    
    private static var FVF_RADIO_GROUP:String = "fvfRadioGroup";
    private static var JOIN_RADIO_GROUP:String = "joinRadioGroup";
    
    private static var EL_DORADO_ID:Number = 5820;
    private static var STONEHENGE_ID:Number = 5840;
    private static var FUSANG_PROJECTS_ID:Number = 34171;
    
    private static var UNCONTROLLED:String = LDBFormat.LDBGetText("WorldDominationGUI", "uncontrolled");
    private static var DRAGON_FACTION_NAME:String = LDBFormat.LDBGetText("FactionNames", "Dragon");
    private static var ILLUMINATI_FACTION_NAME:String = LDBFormat.LDBGetText("FactionNames", "Illuminati");
    private static var TEMPLARS_FACTION_NAME:String = LDBFormat.LDBGetText("FactionNames", "Templars");
    private static var SIGN_IN:String = LDBFormat.LDBGetText("WorldDominationGUI", "signIn");
    private static var ENTER_WARZONE:String = LDBFormat.LDBGetText("WorldDominationGUI", "enterWarzone");
    private static var LEAVE_QUEUE:String = LDBFormat.LDBGetText("WorldDominationGUI", "leaveQueue");
    private static var LEAVE_ZONE:String = LDBFormat.LDBGetText("WorldDominationGUI", "leaveZone");
    
    private static var SIGN_IN_SOUND_EFFECT:String = "sound_fxpackage_GUI_PvP_sign_in.xml";

    //Properties
    public var m_SelectedIndex:Number;
    public var m_MiniMapSelectedState:Number;
    public var m_StatusResultsSelectedState:Number;
    public var m_UniformTypesSelectionArray:Array;
    public var m_JoinTypeSelection:Number;
    
    private var m_Content:MovieClip;
    private var m_DropdownMenu:MovieClip;
    private var m_PlayfieldSubtitle:MovieClip;
    private var m_MiniMap:MovieClip;
    private var m_StatusResults:MovieClip;
    private var m_UniformTypes:MovieClip;
    private var m_JoinType:MovieClip;
    private var m_JoinLeaveButton:MovieClip;
    
    private var m_Character:Character;
    private var m_CurrentMatchMakingMap:Number;
    private var m_SelectedID:Number;
    
    //Constructor
    public function SidePanel()
    {
        super();
        
        m_Character = Character.GetClientCharacter();
        
        PvPMinigame.SignalYouAreInMatchMaking.Connect(SlotYouAreInMatchMaking, this);
        PvPMinigame.SignalNoLongerInMatchMaking.Connect(SlotNoLongerInMatchMaking, this);
        PvPMinigame.RequestIsInMatchMaking();
        
        TeamInterface.SignalClientJoinedTeam.Connect(SlotClientJoinedTeam, this);
        TeamInterface.SignalClientLeftTeam.Connect(SlotClientLeftTeam, this);
    
        m_Content = attachMovie("SidePanelContent", "m_Content", getNextHighestDepth());

        Init();
        Layout();
    }
    
    //Initialize
    private function Init():Void
    {
        //Status Results
        m_StatusResults = m_Content.attachMovie("StatusResults", "m_StatusResults", m_Content.getNextHighestDepth());
        m_StatusResults.SignalStateChanged.Connect(SlotStatusResultsStateChanged, this);
        
        //Dropdown Menu
        m_DropdownMenu = m_Content.attachMovie("SidePanelDropdownMenu", "m_DropdownMenu", m_Content.getNextHighestDepth());
        m_DropdownMenu.dataProvider = _parent.m_PlayfieldNameData;
        m_DropdownMenu.direction = "down";
        m_DropdownMenu.rowCount = _parent.m_PlayfieldNameData.length;
        m_DropdownMenu.dropdown = "SidePanelScrollingList";
        m_DropdownMenu.itemRenderer = "SidePaneltemRenderer";

        m_DropdownMenu.addEventListener("select", this, "ConfigureVisibility");
        m_DropdownMenu.addEventListener("stateChange", this, "ConfigureVisibility");

        //Playfield Subtitle
        m_PlayfieldSubtitle = m_Content.attachMovie("SidePanelSubtitle", "m_PlayfieldSubtitle", m_Content.getNextHighestDepth());

        UpdateSubtitle();
        
        //Mini Map
        m_MiniMap = m_Content.attachMovie("MiniMap", "m_MiniMap", m_Content.getNextHighestDepth());
        m_MiniMap.SignalStateChanged.Connect(SlotMiniMapStateChanged, this);

        
        //Uniform Types
        m_UniformTypes = m_Content.attachMovie("UniformTypes", "m_UniformTypes", m_Content.getNextHighestDepth());
        m_UniformTypes.selection = m_UniformTypesSelectionArray;
        m_UniformTypes.SignalControlSelectionChanged.Connect(SlotUniformTypesSelectionChanged, this);
        
        //Join Type
        m_JoinType = m_Content.attachMovie("JoinType", "m_JoinType", m_Content.getNextHighestDepth());
        m_JoinType.selection = m_JoinTypeSelection;
        m_JoinType.SignalJoinTypeSelectionChanged.Connect(SlotJoinTypeSelectionChanged, this);
        
        //Join Response Button
        m_JoinLeaveButton = m_Content.attachMovie("PvPResponseButton", "m_JoinLeaveButton", m_Content.getNextHighestDepth());
        m_JoinLeaveButton.onRelease = Delegate.create(this, JoinLeaveButtonClickHandler);
    }
    
    private function onLoad():Void
    {
        m_DropdownMenu.selectedIndex = m_SelectedIndex;
    }
    

    //Slot Mini Map State Changed
    private function SlotMiniMapStateChanged(selectedState:Number):Void
    {
        m_MiniMapSelectedState = selectedState;
    }
    
    //Slot Status Results State Changed
    private function SlotStatusResultsStateChanged(selectedState:Number):Void
    {
        m_StatusResultsSelectedState = selectedState;
    }
    
    //Slot Uniform Types Selection Changes
    private function SlotUniformTypesSelectionChanged(selectionArray:Array):Void
    {
        m_UniformTypesSelectionArray = selectionArray;
    }
    
    //Slot Join Type Selection Changed
    private function SlotJoinTypeSelectionChanged(selection:Number):Void
    {
        m_JoinTypeSelection = selection;
    }
    
    //Layout
    private function Layout():Void
    {
        //Dropdown Menu
        m_DropdownMenu.setSize(270, 28);
        m_DropdownMenu._x = SIDE_PANEL_LEFT_MARGIN;
        m_DropdownMenu._y = 20;
        
        //Playfield Subtitle
        m_PlayfieldSubtitle._y = 52;
        m_PlayfieldSubtitle._x = SIDE_PANEL_LEFT_MARGIN - 2.0;;
        
        //Seperator 1
        AttachSeparator(78);
        
        //Mini Map
        m_MiniMap._x = SIDE_PANEL_LEFT_MARGIN;
        m_MiniMap._y = 91;
        
        //Seperator 2
        AttachSeparator(365);
        
        //Results Status
        m_StatusResults._x = SIDE_PANEL_LEFT_MARGIN;
        m_StatusResults._y = 381;
        
        //Seperator 3
        AttachSeparator(625);
        
        //Uniform Types
        m_UniformTypes._x = SIDE_PANEL_LEFT_MARGIN;
        m_UniformTypes._y = 637;

        //Seperator 4
        AttachSeparator(767);
        
        //Join Type
        m_JoinType._x = SIDE_PANEL_LEFT_MARGIN;
        m_JoinType._y = 780;
        
        //Join Response Button
        m_JoinLeaveButton._x = SIDE_PANEL_LEFT_MARGIN;
        m_JoinLeaveButton._y = 812;

        Resize();
    }
    
    //Attach Separator
    private function AttachSeparator(y:Number):Void
    {
        var separator:MovieClip = m_Content.attachMovie("SidePanelSeparator", "m_Separator_" + y, m_Content.getNextHighestDepth());
        separator._x = 0;
        separator._y = y;
    }
    
    //Resize
    public function Resize():Void
    {
        _yscale = _xscale = (_parent.STAGE.height * SIDE_PANEL_HEIGHT_PERCENTAGE) / _height * 100;
    }

    //Configure Visibility
    private function ConfigureVisibility(event:Object):Void
    {
        switch (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex])
        {
            case _parent.EL_DORADO:         m_SelectedID = EL_DORADO_ID;        
                                            m_MiniMap.playfield = _parent.EL_DORADO;
                                            m_StatusResults.playfield = _parent.EL_DORADO;
                                            m_UniformTypes.mode = UniformTypes.PVP_MODE;
            
                                            break;
                                            
            case _parent.STONEHENGE:        m_SelectedID = STONEHENGE_ID;
                                            m_MiniMap.playfield = _parent.STONEHENGE;
                                            m_StatusResults.playfield = _parent.STONEHENGE;
                                            m_UniformTypes.mode = UniformTypes.PVP_MODE;
                                            
                                            break;
                                            
            case _parent.FUSANG_PROJECTS:   m_SelectedID = FUSANG_PROJECTS_ID;
                                            m_MiniMap.playfield = _parent.FUSANG_PROJECTS;
                                            m_StatusResults.playfield = _parent.FUSANG_PROJECTS;
                                            m_StatusResults.state = m_StatusResultsSelectedState;
                                            m_UniformTypes.mode = UniformTypes.FVF_MODE;
        }
        
        m_MiniMap.state = m_MiniMapSelectedState;
        
        if (!event.target.isOpen && event.type != "stateChange")
        {
            RemoveFocus();
        }
        
        if (event.type == "select")
        {
            _parent.m_WorldMap.DropdownSelected(_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex]);
        }
        
        ConfigurePanel();
    }
    
    //Configure Panel
    private function ConfigurePanel():Void
    {
        //Subtitle
        UpdateSubtitle(m_DropdownMenu.selectedIndex);
        
        //Disable or Enable Controls
        var playfieldID:Number = m_Character.GetPlayfieldID();
        var enabledPlayfields:Number = ProjectUtils.GetUint32TweakValue("PvP_Minigame_EnabledPlayfields");
        
        var disableJoinButton:Boolean = false;
        
        if ((_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex] == _parent.EL_DORADO         && ((enabledPlayfields & 1) == 0))                          ||
            (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex] == _parent.STONEHENGE        && ((enabledPlayfields & 2) == 0))                          ||
            (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex] == _parent.FUSANG_PROJECTS   && ((enabledPlayfields & 4) == 0))                          ||
            (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex] == _parent.EL_DORADO         && !PvPMinigame.CanSignUpForMinigame(EL_DORADO_ID))         ||
            (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex] == _parent.STONEHENGE        && !PvPMinigame.CanSignUpForMinigame(STONEHENGE_ID))        ||
            (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex] == _parent.FUSANG_PROJECTS   && !PvPMinigame.CanSignUpForMinigame(FUSANG_PROJECTS_ID)))
            {
                m_UniformTypes.disabled = true;
                m_JoinType.disabled = true;
                
                disableJoinButton = true;
            }
            else
            {
                var isDisabled:Boolean = (playfieldID == m_SelectedID || m_CurrentMatchMakingMap == m_SelectedID);
                var isInTeam:Boolean = TeamInterface.IsInTeam(Character.GetClientCharID());
        
                m_UniformTypes.disabled = isDisabled;
                m_JoinType.disabled = (isDisabled || !isInTeam);
            }
            
        // * TEMP REMOVE JOIN AS PARTY OPTION FROM FvFvF * //  
        // * TEMP REMOVE JOIN AS PARTY OPTION FROM FvFvF * //    
        
        m_JoinType.hideJoinAsParty = (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex] == _parent.FUSANG_PROJECTS) ? true : false;      

        // * TEMP REMOVE JOIN AS PARTY OPTION FROM FvFvF * //
        // * TEMP REMOVE JOIN AS PARTY OPTION FROM FvFvF * //
        
        //Response Button
        var playfieldID:Number = m_Character.GetPlayfieldID();
        
        switch (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex])
        {
            case _parent.EL_DORADO:         if(playfieldID == EL_DORADO_ID)
                                            {
                                                m_JoinLeaveButton.SetLabel(LEAVE_ZONE, true, 0xFFFFFF);
                                                disableJoinButton = false;
                                            }
                                            else if(m_CurrentMatchMakingMap == EL_DORADO_ID)
                                            {
                                                m_JoinLeaveButton.SetLabel(LEAVE_QUEUE, true, 0xFFFFFF);
                                                disableJoinButton = false;
                                            }
                                            else
                                            {
                                                m_JoinLeaveButton.SetLabel(SIGN_IN, false, 0x000000);
                                            }
                                        
                                            break;
                                        
            case _parent.STONEHENGE:        if(playfieldID == STONEHENGE_ID)
                                            {
                                                m_JoinLeaveButton.SetLabel(LEAVE_ZONE, true, 0xFFFFFF);
                                                disableJoinButton = false;
                                            }
                                            else if (m_CurrentMatchMakingMap == STONEHENGE_ID)
                                            {
                                                m_JoinLeaveButton.SetLabel(LEAVE_QUEUE, true, 0xFFFFFF);
                                                disableJoinButton = false;
                                            }
                                            else                                                    
                                            {
                                                m_JoinLeaveButton.SetLabel(SIGN_IN, false, 0x000000);
                                            }
                                        
                                            break;
                                        
            case _parent.FUSANG_PROJECTS:    if(playfieldID == FUSANG_PROJECTS_ID)
                                            {
                                                m_JoinLeaveButton.SetLabel(LEAVE_ZONE, true, 0xFFFFFF);
                                                disableJoinButton = false;
                                            }
                                            else if (m_CurrentMatchMakingMap == FUSANG_PROJECTS_ID)
                                            {
                                                m_JoinLeaveButton.SetLabel(LEAVE_QUEUE, true, 0xFFFFFF);
                                                disableJoinButton = false;
                                            }
                                            else
                                            {
                                                m_JoinLeaveButton.SetLabel(ENTER_WARZONE, false, 0x000000);
                                            }
        }
        
        if (disableJoinButton)
        {
                m_JoinLeaveButton.disabled = true;
                m_JoinLeaveButton.onRelease = null;
                m_JoinLeaveButton._alpha = 50;
        }
        else
        {
                m_JoinLeaveButton.disabled = false;
                m_JoinLeaveButton.onRelease = Delegate.create(this, JoinLeaveButtonClickHandler);
                m_JoinLeaveButton._alpha = 100;
        }
        
        m_SelectedIndex = m_DropdownMenu.selectedIndex;
    }
    
    //Update Subtitle
    private function UpdateSubtitle(selectedIndex:Number):Void
    {
        m_PlayfieldSubtitle.textField.text = (_parent.m_PlayfieldNameData[selectedIndex] == _parent.FUSANG_PROJECTS) ? PRERSISTENT_WARZONE : CAPTURE_THE_RELICS;
    }

    //Slot You Are In Match Making
    private function SlotYouAreInMatchMaking(mapID:Number, joinAsGroup:Boolean):Void
    {
        m_CurrentMatchMakingMap = mapID;
        
        ConfigurePanel();
    }
    
    //Slot No Longer In Match Making
    private function SlotNoLongerInMatchMaking():Void
    {
        m_CurrentMatchMakingMap = 0;
        
        ConfigurePanel();
    }
    
    //Slot Client Joined Team
    private function SlotClientJoinedTeam(team:Team):Void
    {
        if (m_JoinType.disabled)
        {
            if (m_Character.GetPlayfieldID() != m_SelectedID || m_CurrentMatchMakingMap != m_SelectedID)
            {
                m_JoinType.disabled = false;
            }
        }
    }
    
    //Slot Client Left Team
    private function SlotClientLeftTeam():Void
    {
        if (!m_JoinType.disabled)
        {
            m_JoinType.disabled = true;
        }
    }
    
    //Marker Selected
    private function MarkerSelected(name:String):Void
    {
        for (var i:Number = 0; i < _parent.m_PlayfieldNameData.length; i++)
        {
            if (_parent.m_PlayfieldNameData[i] == name)
            {
                m_DropdownMenu.selectedIndex = i;
            }
        }
    }
    
    //Join Leave Button Click Handler
    private function JoinLeaveButtonClickHandler():Void
    {
        var playfieldID:Number = m_Character.GetPlayfieldID();
        var classesTotal:Number = 0;

        switch (_parent.m_PlayfieldNameData[m_DropdownMenu.selectedIndex])
        {
            case _parent.EL_DORADO:         if      (m_UniformTypes.m_HighPoweredWeaponryCheckBox.selected)         classesTotal += _global.Enums.Class.e_Damage;
                                            if      (m_UniformTypes.m_ReinforcedArmorCheckBox.selected)             classesTotal += _global.Enums.Class.e_Tank;
                                            if      (m_UniformTypes.m_IntegratedAnimaConduitsCheckBox.selected)     classesTotal += _global.Enums.Class.e_Heal;
                                            if      (classesTotal == 0)                                             classesTotal  = _global.Enums.Class.e_Damage + _global.Enums.Class.e_Tank + _global.Enums.Class.e_Heal;
                                            
                                            if      (playfieldID == EL_DORADO_ID)                                   {
                                                                                                                    PvPMinigame.LeaveMatch();
                                                                                                                    _parent.m_Header.CloseWorldDomination();
                                                                                                                    }
                                                                                                                    
                                            else if (m_CurrentMatchMakingMap == EL_DORADO_ID)                       PvPMinigame.RemoveFromMatchMaking();
                                            
                                            else                                                                    {
                                                                                                                    PvPMinigame.SignUpForMinigame(EL_DORADO_ID, classesTotal, (m_JoinType.m_JoinAsPartyRadioButton.selected) ? true : false, true);
                                                                                                                    m_Character.AddEffectPackage(SIGN_IN_SOUND_EFFECT);
                                                                                                                    }
                                            break;
                                        
            case _parent.STONEHENGE:        if      (m_UniformTypes.m_HighPoweredWeaponryCheckBox.selected)         classesTotal += _global.Enums.Class.e_Damage;
                                            if      (m_UniformTypes.m_ReinforcedArmorCheckBox.selected)             classesTotal += _global.Enums.Class.e_Tank;
                                            if      (m_UniformTypes.m_IntegratedAnimaConduitsCheckBox.selected)     classesTotal += _global.Enums.Class.e_Heal;
                                            if      (classesTotal == 0)                                             classesTotal  = _global.Enums.Class.e_Damage + _global.Enums.Class.e_Tank + _global.Enums.Class.e_Heal;
                                            
                                            if      (playfieldID == STONEHENGE_ID)                                  {
                                                                                                                    PvPMinigame.LeaveMatch();
                                                                                                                    _parent.m_Header.CloseWorldDomination();
                                                                                                                    }
                                                                                                                    
                                            else if (m_CurrentMatchMakingMap == STONEHENGE_ID)                      PvPMinigame.RemoveFromMatchMaking();
                                            
                                            else                                                                    {
                                                                                                                    PvPMinigame.SignUpForMinigame(STONEHENGE_ID, classesTotal, (m_JoinType.m_JoinAsPartyRadioButton.selected) ? true : false, true);
                                                                                                                    m_Character.AddEffectPackage(SIGN_IN_SOUND_EFFECT);
                                                                                                                    }
                                            break;
                                        
            case _parent.FUSANG_PROJECTS:   if      (m_UniformTypes.m_HighPoweredWeaponryRadioButton.selected)     classesTotal = _global.Enums.Class.e_Damage;
                                            else if (m_UniformTypes.m_ReinforcedArmorRadioButton.selected)          classesTotal = _global.Enums.Class.e_Tank;
                                            else                                                                    classesTotal = _global.Enums.Class.e_Heal;
                                            
                                            if      (playfieldID == FUSANG_PROJECTS_ID)                             {
                                                                                                                    PvPMinigame.LeaveMatch();
                                                                                                                    _parent.m_Header.CloseWorldDomination();
                                                                                                                    }
                                                                                                                    
                                            else if (m_CurrentMatchMakingMap == FUSANG_PROJECTS_ID)                  PvPMinigame.RemoveFromMatchMaking();
                                            
                                            else                                                                    {
                                                                                                                    PvPMinigame.SignUpForMinigame(FUSANG_PROJECTS_ID, classesTotal, (m_JoinType.m_JoinAsPartyRadioButton.selected) ? true : false, true);
                                                                                                                    m_Character.AddEffectPackage(SIGN_IN_SOUND_EFFECT);
                                                                                                                    }
        }
        
        RemoveFocus();
    }
    
    //Remove Focus
    private function RemoveFocus():Void
    {
        Selection.setFocus(null);
    }
}