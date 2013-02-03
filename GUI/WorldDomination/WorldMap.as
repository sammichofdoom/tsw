//Imports
import com.GameInterface.Game.BuffData;
import com.GameInterface.Game.Character;
import com.GameInterface.Spell;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Utils.LDBFormat;
import flash.geom.Rectangle;
import GUI.WorldDomination.Marker;
import GUI.WorldDomination.MarkerInfo;
import GUI.WorldDomination.SidePanel;
import GUI.WorldDomination.MiniMapReward;

//Class
class GUI.WorldDomination.WorldMap extends MovieClip
{
    //Constants
    private static var EL_DORADO_INSTRUCTIONS:String = LDBFormat.LDBGetText("WorldDominationGUI", "elDoradoInstructions");
    private static var STONEHENGE_INSTRUCTIONS:String = LDBFormat.LDBGetText("WorldDominationGUI", "stonehengeInstructions");
    private static var FUSANG_PROJECTS_INSTRUCTIONS:String = LDBFormat.LDBGetText("WorldDominationGUI", "forbiddenCityInstructions");
    private static var ACTIVE_BUFFS_LABEL:String = LDBFormat.LDBGetText("WorldDominationGUI", "activeBuffsLabel");
    
    private static var BUFF_SUPPORT_DRAGON:String = "PvPFusangUnderDogBotActivatedDragon";
    private static var BUFF_SUPPORT_TEMPLARS:String = "PvPFusangUnderDogBotActivatedTemplar";
    private static var BUFF_SUPPORT_ILLUMINATI:String = "PvPFusangUnderDogBotActivatedIlluminati";
    
    private static var MARKER_INFO_SCALE:Number = 21;
    private static var LINE_THICKNESS:Number = 2;
    private static var LINE_COLOR:Number = 0xFFFFFF;
    private static var LINE_ALPHA:Number = 10;
    private static var MAP_HEIGHT_PERCENTAGE:Number = 0.955;
    private static var MAP_HEIGHT_ADDITIONAL_PERCENTAGE:Number = 0.107;
    
    //Properties
    public var m_SidePanelWidth:Number;
    
    public var m_MarkerArray:Array;
    public var m_ElDoradoMarker:Marker;
    public var m_StonehengeMarker:Marker;
    public var m_FusangProjectsMarker:Marker;
    
    private var m_MarkerInfoArray:Array;
    private var m_ElDoradoMarkerInfo:MovieClip;
    private var m_StonehengeMarkerInfo:MovieClip;
    private var m_FusangProjectsMarkerInfo:MovieClip;
    
    private var m_Instructions:MovieClip;
    
    private var m_MapBackground:MovieClip;
    private var m_Map:MovieClip;
    private var m_Grid:MovieClip;
    private var m_SineWave1:MovieClip;
    private var m_SineWave2:MovieClip;
    private var m_CouncilLogo:MovieClip;
    private var m_BackgroundCouncilLogo:MovieClip;
    private var m_BorderShadow:MovieClip;
    
    private var m_ActiveBuffsLabel:TextField;
    private var m_WorldDominationBuff:MovieClip;
    private var m_CouncilSupportBuff:MovieClip;
    private var m_CustodianBuff:MovieClip;
    
    private var m_ElDoradoInQueue:Boolean;
    private var m_ElDoradoInZone:Boolean;
    private var m_StonehengeInQueue:Boolean;
    private var m_StonehengeInZone:Boolean;
    private var m_FusangProjectsInQueue:Boolean;
    private var m_FusangProjectsInZone:Boolean;
    
    private var m_InstructionsAreVisible:Boolean;
    
    private var m_BuffSupport:String;
    
    //Constructor
    public function WorldMap()
    {
        super();
    }
    
    //On Load
    private function onLoad():Void
    {
        Init();
        Layout();
    }

    //Initialize
    private function Init():Void
    {
        m_ElDoradoMarker.m_Name = _parent.EL_DORADO;
        m_ElDoradoMarkerInfo = attachMovie("MarkerInfo", "m_ElDoradoMarkerInfo", getNextHighestDepth());
        m_ElDoradoMarkerInfo.SetupInfo(MarkerInfo.RIGHT, _parent.EL_DORADO, SidePanel.CAPTURE_THE_RELICS, "MarkerInfoButton");
        
        m_StonehengeMarker.m_Name = _parent.STONEHENGE;
        m_StonehengeMarkerInfo = attachMovie("MarkerInfo", "m_StonehengeMarkerInfo", getNextHighestDepth());
        m_StonehengeMarkerInfo.SetupInfo(MarkerInfo.RIGHT, _parent.STONEHENGE, SidePanel.CAPTURE_THE_RELICS, "MarkerInfoButton");
        
        m_FusangProjectsMarker.m_Name = _parent.FUSANG_PROJECTS;
        m_FusangProjectsMarkerInfo = attachMovie("MarkerInfo", "m_FusangProjectsMarkerInfo", getNextHighestDepth());
        m_FusangProjectsMarkerInfo.SetupInfo(MarkerInfo.LEFT, _parent.FUSANG_PROJECTS, SidePanel.PRERSISTENT_WARZONE, "MarkerInfoButton");
        
        m_MarkerArray = new Array(m_ElDoradoMarker, m_StonehengeMarker, m_FusangProjectsMarker);
        
        for (var i:Number = 0; i < m_MarkerArray.length; i++)
        {
            m_MarkerArray[i].SignalMarkerSelected.Connect(SlotMarkerSelected, this);

            if (_parent.m_SidePanel.m_SelectedIndex == i)
            {
                DropdownSelected(m_MarkerArray[i].m_Name);
            }
        }
        
        m_MarkerInfoArray = new Array(m_ElDoradoMarkerInfo, m_StonehengeMarkerInfo, m_FusangProjectsMarkerInfo);
        
        for (var i:Number = 0; i < m_MarkerInfoArray.length; i++)
        {
            m_MarkerInfoArray[i].m_Button.SignalButtonSelected.Connect(SlotMarkerInfoSelected, this);
            
            m_MarkerInfoArray[i]._xscale = m_MarkerInfoArray[i]._yscale = MARKER_INFO_SCALE;
            m_MarkerInfoArray[i]._x = m_MarkerArray[i]._x;
            m_MarkerInfoArray[i]._y = m_MarkerArray[i]._y;
            
            Marker.m_SelectSound = false;
            
            m_MarkerInfoArray[_parent.m_SidePanel.m_SelectedIndex].selected = true;
        }
        
        Marker.m_SelectSound = true;
        
        CreateWorldDominationBuffs();
    
        m_Instructions = attachMovie("Instructions", "m_Instructions", getNextHighestDepth());
        m_Instructions.SignalInstructionsAreVisible.Connect(SlotInstructionsAreVisible, this);
        
        m_InstructionsAreVisible = false;
        
        m_CouncilLogo = createEmptyMovieClip("m_CouncilLogoLoader", getNextHighestDepth());
        
        var m_CouncilLogoLoader:MovieClipLoader = new MovieClipLoader();
        m_CouncilLogoLoader.loadClip("CouncilLogoPvpMap.swf", m_CouncilLogo);
    }

    private function CreateWorldDominationBuffs():Void
    {
        m_ActiveBuffsLabel.autoSize = "left";
        m_ActiveBuffsLabel.text = ACTIVE_BUFFS_LABEL;

        m_WorldDominationBuff = attachMovie("BuffComponent", "m_WorldDominationBuff", getNextHighestDepth());
        m_WorldDominationBuff.SetBuffData(Spell.GetBuffData(7241309));
        m_WorldDominationBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        
        var faction:Number = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_PlayerFaction);
        
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon: 
                m_BuffSupport = BUFF_SUPPORT_DRAGON; 
                break;
                                        
            case _global.Enums.Factions.e_FactionTemplar: 
                m_BuffSupport = BUFF_SUPPORT_TEMPLARS; 
                break;
                                        
            case _global.Enums.Factions.e_FactionIlluminati: 
                m_BuffSupport = BUFF_SUPPORT_ILLUMINATI; 
                break;
        }
        
        m_CouncilSupportBuff = attachMovie("BuffComponent", "m_CouncilSupportBuff", getNextHighestDepth());
        m_CouncilSupportBuff.SetBuffData(Spell.GetBuffData(MiniMapReward.GetCouncilSupportBuffSpellID(faction)));
        m_CouncilSupportBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        m_CouncilSupportBuff._visible = false;
    
        m_CustodianBuff = attachMovie("BuffComponent", "m_CustodianBuff", getNextHighestDepth());
        m_CustodianBuff.SetBuffData(Spell.GetBuffData(MiniMapReward.GetCustodianBuffSpellID(faction)));
        m_CustodianBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        m_CustodianBuff._visible = false;

    }
    
    //Layout
    public function Layout():Void
    {
        //Resize Map Background
        m_MapBackground._width = _parent.STAGE.width - m_SidePanelWidth;
        m_MapBackground._height = _parent.STAGE.height * MAP_HEIGHT_PERCENTAGE;
        m_MapBackground._x = 0;
        m_MapBackground._y = _parent.STAGE.height - m_MapBackground._height;
        
        //Scale Down Map
        var originalMapWidth:Number = m_Map._width;
        var originalMapHeight:Number = m_Map._height;
        
        m_Map._width = _parent.STAGE.width - m_SidePanelWidth - _parent.MARGIN * 2;
        m_Map._height = _parent.STAGE.height - _parent.STAGE.height * MAP_HEIGHT_ADDITIONAL_PERCENTAGE;
        m_Map._x = _parent.MARGIN;
        m_Map._y = _parent.STAGE.height - m_Map._height;
    
        //Draw Grid
        m_Grid.clear();
        m_Grid.lineStyle(LINE_THICKNESS, LINE_COLOR, LINE_ALPHA, true, "none");
        
        var totalLongitudeLines:Number = 23;
        var longitudeWidth:Number = (m_Map._width + _parent.MARGIN * 2) / totalLongitudeLines;
        
        var totalLatitudeLines:Number = 20;
        var latitudeHeight:Number = _parent.STAGE.height / totalLatitudeLines;
        
        for (var i:Number = 1; i < totalLongitudeLines + 1; i++)
        {
            m_Grid.moveTo(longitudeWidth * i - longitudeWidth / 2, 0);
            m_Grid.lineTo(longitudeWidth * i - longitudeWidth / 2, _parent.STAGE.height);
        }
        
        for (var i:Number = 1; i < totalLatitudeLines + 1; i++)
        {
            m_Grid.moveTo(0, latitudeHeight * i - latitudeHeight / 2);
            m_Grid.lineTo(m_Map._width + _parent.MARGIN * 2, latitudeHeight * i - latitudeHeight / 2);
        }
        
        //Draw Sine Waves
        var sineWidth:Number = m_Map._width + _parent.MARGIN * 2;
        var sineHeight:Number = _parent.STAGE.height / 5 - latitudeHeight;
        var sineY:Number = _parent.STAGE.height - sineHeight / 2 - _parent.MARGIN * 2;
        var offsetWidth:Number = _parent.MARGIN * 4;
        
        CreateSineWave(m_SineWave1, sineY, sineWidth, 0, sineHeight, 3);
        CreateSineWave(m_SineWave2, sineY, sineWidth, offsetWidth, sineHeight, 3);
        
        m_SineWave2._x = -offsetWidth;
        
        //Reposition Markers and Marker Info
        var repositionMarkers:Array = m_MarkerArray.concat(m_MarkerInfoArray);
        for (var i:Number = 0; i < repositionMarkers.length; i++)
        {
            repositionMarkers[i]._x = m_Map._width / originalMapWidth * repositionMarkers[i]._x + _parent.MARGIN;
            repositionMarkers[i]._y = m_Map._height / originalMapHeight * repositionMarkers[i]._y + _parent.STAGE.height - m_Map._height;
        }
        
        //Reposition Border Shadow
        m_BorderShadow._x = m_MapBackground._x + m_MapBackground._width;
        m_BorderShadow._y = _parent.STAGE.height * _parent.HEADER_HEIGHT_PERCENTAGE;
        m_BorderShadow._height = _parent.STAGE.height - m_BorderShadow._y;
        
        //Active Buffs
        m_ActiveBuffsLabel._x = m_MapBackground._x + 10;
        m_ActiveBuffsLabel._y = m_MapBackground._y + m_MapBackground._height - m_ActiveBuffsLabel._height - 5;
        
        var buffScale:Number = 80;
        var buffGap:Number = 8;
        
        m_WorldDominationBuff._xscale = m_WorldDominationBuff._yscale = buffScale;
        m_WorldDominationBuff._x = m_ActiveBuffsLabel._x + 1;
        m_WorldDominationBuff._y = m_ActiveBuffsLabel._y - m_WorldDominationBuff._height;
        
        m_CouncilSupportBuff._xscale = m_CouncilSupportBuff._yscale = buffScale;
        m_CouncilSupportBuff._x = m_WorldDominationBuff._x + m_WorldDominationBuff._width + buffGap;
        m_CouncilSupportBuff._y = m_ActiveBuffsLabel._y - m_CouncilSupportBuff._height;
        
        m_CustodianBuff._xscale = m_CustodianBuff._yscale = buffScale;
        m_CustodianBuff._x = m_CouncilSupportBuff._x;// + m_CouncilSupportBuff._width + buffGap;
        m_CustodianBuff._y = m_CouncilSupportBuff._y;// - m_CustodianBuff._height;
        
        if (m_BuffSupport != undefined)
        {
            switch (PvPMinigame.GetWorldStat(m_BuffSupport, 0, 0, PvPMinigame.GetCurrentDimensionId()))
            {
                case 2:     m_CouncilSupportBuff._visible = true;
                            m_CustodianBuff._visible = false;
                            break;
                            
                case 3:     m_CouncilSupportBuff._visible = false;
                            m_CustodianBuff._visible = true;
                            break;
            }
        }
        
        //Resize Instructions
        m_Instructions.SetSize  (
                                m_MapBackground._x,
                                _parent.STAGE.height * _parent.HEADER_HEIGHT_PERCENTAGE,
                                m_MapBackground._width,
                                m_MapBackground._height
                                )
                                
        //Council Logo
        m_CouncilLogo._x = m_MapBackground._x - 35;
        m_CouncilLogo._y = m_MapBackground._y - 30;
        m_CouncilLogo._alpha = 60;
        
        //Backgtround Council Logo
        m_BackgroundCouncilLogo._xscale = m_BackgroundCouncilLogo._yscale = (m_MapBackground._width * 0.8 / m_BackgroundCouncilLogo._width) * 100;
        m_BackgroundCouncilLogo._x = m_MapBackground._width / 2 - m_BackgroundCouncilLogo._width / 2;
        m_BackgroundCouncilLogo._y = m_MapBackground._height / 2 - m_BackgroundCouncilLogo._height / 2;
    }
    
    //Create Sine Wave
    private function CreateSineWave(target:MovieClip, y:Number, width:Number, offsetWidth:Number, height:Number, frequency:Number):Void
    {
        target.lineStyle(LINE_THICKNESS, LINE_COLOR, LINE_ALPHA);
        target.moveTo(0, y);
        
        for (var i:Number = 0; i <= width + offsetWidth; i++)
        {
            var angle:Number = 2 * Math.PI * frequency * i / width;
            
            target.lineTo(i, y + height / 2 * Math.sin(angle));
        }
    }
    
    //Slot Marker Selected
    public function SlotMarkerSelected(name:String):Void
    {
        for (var i:Number = 0; i < m_MarkerArray.length; i++)
        {
            if (m_MarkerArray[i].m_Name != name)
            {
                m_MarkerArray[i].selected = m_MarkerInfoArray[i].selected = false;
            }
            else
            {
                _parent.m_SidePanel.MarkerSelected(name)
                m_MarkerInfoArray[i].selected = true;
            }
        }
    }
    
    //Slot Marker Info Selected
    public function SlotMarkerInfoSelected(name:String):Void
    {
        switch (name)
        {
            case _parent.EL_DORADO:         m_Instructions.SetContent(_parent.EL_DORADO, SidePanel.CAPTURE_THE_RELICS, EL_DORADO_INSTRUCTIONS);
                                            break;
                                        
            case _parent.STONEHENGE:        m_Instructions.SetContent(_parent.STONEHENGE, SidePanel.CAPTURE_THE_RELICS, STONEHENGE_INSTRUCTIONS);
                                            break;
                                        
            case _parent.FUSANG_PROJECTS:   m_Instructions.SetContent(_parent.FUSANG_PROJECTS, SidePanel.PRERSISTENT_WARZONE, FUSANG_PROJECTS_INSTRUCTIONS);
        }
        
        m_Instructions.Show();
    }
    
    //Slot Instructions Visibility Toggle
    public function SlotInstructionsAreVisible(visible:Boolean):Void
    {
        m_InstructionsAreVisible = visible;
        
        EnableMarkers(!visible);
    }
    
    //Enable Markers
    public function EnableMarkers(value:Boolean):Void
    {
        for (var i:Number = 0; i < m_MarkerArray.length; i++)
        {
            m_MarkerArray[i].enabled = value;
            m_MarkerInfoArray[i].m_Button.enabled = value;
        }
    }
    
    //Dropdown Selected
    private function DropdownSelected(name:String):Void
    {
        for (var i:Number = 0; i < m_MarkerArray.length; i++)
        {
            if (m_MarkerArray[i].m_Name == name)
            {
                m_MarkerArray[i].selected = m_MarkerInfoArray[i].selected = true;
            }
            else
            {
                m_MarkerArray[i].selected = m_MarkerInfoArray[i].selected = false;
            }
        }
        
        if (m_InstructionsAreVisible)
        {
            SlotMarkerInfoSelected(name);
        }
    }
}