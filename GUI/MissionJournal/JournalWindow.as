//import flash.geom.Rectangle;
import mx.controls.Label;
//import mx.data.encoders.Num;
import mx.utils.Delegate;
import com.GameInterface.MathLib.Vector3;
import com.GameInterface.Game.Character;
import com.GameInterface.Quests;
import com.GameInterface.Quest;
import com.GameInterface.QuestTask;
import com.GameInterface.QuestGoal;
import com.GameInterface.DistributedValue;
import com.GameInterface.Log;
import com.GameInterface.Utils;
import com.Components.WindowComponent;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.Utils.Archive;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.Utils.Format;
import flash.geom.Point;
import gfx.core.UIComponent;
import gfx.controls.Button;
import GUI.Mission.MissionUtils;

class GUI.MissionJournal.JournalWindow extends com.Components.WindowComponentContent
{
    
    //var m_MovieClip:MovieClip = this;
   //var m_IconSizes:Number = 500; // just a magic number used to control icon sizes, the higher the number, the bigger the icons (not pixel by pixel)
    var m_ResolutionScaleMonitor:DistributedValue;
   // var m_WindowOpenState:DistributedValue; //Value that controls opening and closing of the journalwindow
    var m_Missions:Array;
   // var m_SelectedType:Number = 0;
    var m_ExpandedTiersArray:Array = new Array();
    var m_PowerRank:Number; // the players power rank, set when loading the UI, and updated when it changes
    var m_Character:Character; // the client character
    var m_ContentSize:Point;

   // var m_HeadlineFormat:TextFormat;
    var m_MissionDescFormat:TextFormat;
    private var m_HeaderNameFormat:TextFormat;
    
  //  var m_TierNumFormat:TextFormat;
  //  var m_TierNumFormatSelected:TextFormat;

    var m_HeaderSubTextFormat:TextFormat;
    var m_HeaderTimerTextFormat:TextFormat;

    var m_GoalFormat:TextFormat;
    var m_CashFormat:TextFormat;
    var m_DropDownFormat:TextFormat;
    var m_TooltipTextFormat:TextFormat;

    var m_DebugFormat:TextFormat;

   // var m_DragPadding:Number = 40;
    var m_ExpandedMissionID:Number = -123456789;
    var m_TooltipController:Object;
    var m_TooltipTimeoutId:Number;

    var m_DeltaMultiplier:Number = 10;  // the speed of the scrolling with mousewheel

    /// controllers
    var m_IsResizing:Boolean; // = false;
    var m_NeedRedraw:Boolean = false;

    /// Window Layout
    var m_DropdownHeight:Number = 22;

    /// General Positioning 
    var m_ScrollBarArchivedPosition:Number;

    /// Strings
    private var m_TDB_Tier;
    private var m_TDB_Tier_MixedCase;
    private var m_TDB_AllRegions;
    private var m_TDB_CurrentMisionons;
    private var m_TDB_FinishedMissions;
    private var m_TDB_AbandonedMissions;

    private var m_TDB_PlayAudio;
    private var m_TDB_PlayVideo;
    private var m_TDB_ShowImage;
    
    var m_ScrollBar:MovieClip;
    var m_Mask:MovieClip;
    
    var m_Content:MovieClip; // the actual content of tmissions
    var m_Menu:MovieClip; // the dropdown menus
    var m_Background:MovieClip; // the canvas where content and menu is placed
    var m_DeleteMissionButton:MovieClip;
    var m_ShareButton:MovieClip;
    var m_LocationButton:MovieClip;

    // Journal Type Dropdown
    var m_MissionDropdown:MovieClip;
    var m_CloseButton:MovieClip;
    var m_JournalTypeIndexSelected:Number = 0;
    var m_JournalTypeCurrentMissionIndex:Number = 0; // magic value for the current mission index, used to check if we hide or show the Location dropdown
    var m_JournalTypeFinishedMissionIndex:Number = 1; // the index of finished missions
    var m_JournalTypeAbandonedMissionIndex:Number = 2; // index of the abandoned missions option

    // Playfield Dropdown
    var m_PlayfieldDropdown:MovieClip;
    var m_PlayfieldNames:Array = [ "" ]
    var m_PlayfieldIndexSelected:Number = 0;
    var m_LastPlayfieldNameSelected = "";

    
    public function JournalWindow()
    {
        super();
        
        m_TDB_Tier = LDBFormat.LDBGetText( "MiscGUI", "Mission_Tier" );
        m_TDB_Tier_MixedCase = LDBFormat.LDBGetText( "MiscGUI", "Mission_Tier_MixedCase") ;
        m_TDB_AllRegions = LDBFormat.LDBGetText( "MiscGUI", "Mission_AllRegions");
        m_TDB_CurrentMisionons = LDBFormat.LDBGetText( "MiscGUI", "Mission_CurrentMissions");
        m_TDB_FinishedMissions = LDBFormat.LDBGetText( "MiscGUI", "Mission_FinishedMissions");
        m_TDB_AbandonedMissions = LDBFormat.LDBGetText( "MiscGUI", "Mission_PausedMissions");

        m_TDB_PlayAudio = LDBFormat.LDBGetText( "MiscGUI", "PlayAudio");
        m_TDB_PlayVideo = LDBFormat.LDBGetText( "MiscGUI", "PlayVideo");
        m_TDB_ShowImage = LDBFormat.LDBGetText( "MiscGUI", "ShowImage");
        
        m_ContentSize = new Point(100,100)
    }
    
    public function SetModuleData(archive:Archive)
    {
        m_JournalTypeIndexSelected = archive.FindEntry("JournalTypeIndexSelected", 0);
        m_LastPlayfieldNameSelected = archive.FindEntry("LastPlayfieldNameSelected", "");
        m_PlayfieldIndexSelected = archive.FindEntry("PlayfieldIndexSelected", 0);
        m_ScrollBarArchivedPosition = archive.FindEntry("ScrollBarPosition", 0);
        
        var expandedTiers:Array = archive.FindEntryArray("ExpandedTiersArray");
    
        if (expandedTiers != undefined) 
        {   
            m_ExpandedTiersArray = expandedTiers;
        }
        
        var openJournalQuest = DistributedValue.GetDValue("OpenJournalQuest", -1);

        if (openJournalQuest == -1)
        {
            openJournalQuest = archive.FindEntry("ExpandedMissionID", -1);
        }
        else
        {
            m_JournalTypeIndexSelected = m_JournalTypeCurrentMissionIndex;
            DistributedValue.SetDValue("OpenJournalQuest", -1);
        }
        
        SetExpandedMissionID( openJournalQuest );
    }

    function GetModuleData() : Archive
    {
        Log.Info2("MissionJournalWindow", "OnModuleDeactivated()")  
        
        var archive:Archive = new Archive();
            
        archive.AddEntry("JournalTypeIndexSelected", m_JournalTypeIndexSelected);
        archive.AddEntry("LastPlayfieldNameSelected", (m_LastPlayfieldNameSelected ? m_LastPlayfieldNameSelected : ""));
        archive.AddEntry("PlayfieldIndexSelected", m_PlayfieldIndexSelected);
        archive.AddEntry("ExpandedMissionID", m_ExpandedMissionID);
        archive.AddEntry("ScrollBarPosition", (m_ScrollBar ? m_ScrollBar.position : 0));
       

        for (var i:Number = 0; i < m_ExpandedTiersArray.length; i++)
        {
            archive.AddEntry("ExpandedTiersArray", m_ExpandedTiersArray[i]);
        }

        return archive;
    }

    private function onEnterFrame()
    {
        if (m_NeedRedraw)
        {
            Redraw();
            m_NeedRedraw = false;
        }
    }

    private function SetRedrawFlag()
    {
        m_NeedRedraw = true;
    }
    
    public function SetSize(width:Number, height:Number)
    {
        m_ContentSize = new Point(width, height);
        
        m_Background._width = m_ContentSize.x;
        m_Background._height = m_ContentSize.y;
        
        SetRedrawFlag();
        SignalSizeChanged.Emit();
    }
    
    public function GetSize() : Point
    {
        return m_ContentSize;
        /*
        /// adding extra padding (5px) at the bottom
        var size:Point = m_ContentSize.clone();
        size.y += 5;
        return size;
        */
    }
    /// INSTANCIATION
    public function configUI()
    {
        m_IsResizing = false;
        m_TooltipController = { isVisible:false, target:null };
        m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
        
        m_ContentSize = new Point(m_Content._width, m_Content._height);
        
        m_DropDownFormat = new TextFormat;
        m_DropDownFormat.font = "_Headline";
        m_DropDownFormat.size = 11;

        /// goal info
        m_MissionDescFormat = new TextFormat;
        m_MissionDescFormat.font = "_StandardFont";
        m_MissionDescFormat.size = 12;
        m_MissionDescFormat.color = 0xE5E5E5;

        // Goal style
        m_GoalFormat = new TextFormat;
        m_GoalFormat.font = "_StandardFont";
        m_GoalFormat.size = 12;
        m_GoalFormat.color = 0xAAAAAA;       

        m_DebugFormat = new TextFormat;
        m_DebugFormat.font = "_StandardFont";
        m_DebugFormat.size = 12;
        m_DebugFormat.color = 0xFF0000;   
        
        // Name of a mission
        m_HeaderNameFormat = new TextFormat;
        m_HeaderNameFormat.font = "_StandardFont";
        m_HeaderNameFormat.size = 17;
        m_HeaderNameFormat.color = 0xFFFFFF;
        
        // Goal style
        m_HeaderSubTextFormat = new TextFormat;
        m_HeaderSubTextFormat.font = "_StandardFont";
        m_HeaderSubTextFormat.size = 10;
        m_HeaderSubTextFormat.color = 0xAAAAAA;

        m_HeaderTimerTextFormat = new TextFormat;
        m_HeaderTimerTextFormat.font = "_TimerFont";
        m_HeaderTimerTextFormat.size = 12;
        m_HeaderTimerTextFormat.color = Colors.e_ColorLightOrange;
        
        m_TooltipTextFormat = new TextFormat;
        m_TooltipTextFormat.font = "_StandardFont";
        m_TooltipTextFormat.size = 10;
        m_TooltipTextFormat.color = 0xFFFFFF;     
        
        // Cash / Skillpoint number style
        m_CashFormat = new TextFormat;
        m_CashFormat.font = "_StandardFont";
        m_CashFormat.size = 15;
        m_CashFormat.color = 0xFFFFFF;    
        
        CreateInitialWindow();
        
        // Redraw on all quest signals that are not quest goals.
        Quests.SignalQuestAvailable.Connect(SetRedrawFlag, this)
        Quests.SignalQuestEvent.Connect(SetRedrawFlag, this)
        Quests.SignalTaskAdded.Connect(SetRedrawFlag, this)
        Quests.SignalMissionRemoved.Connect(SetRedrawFlag, this)
        Quests.SignalPlayerTiersChanged.Connect(SetRedrawFlag, this)
        Quests.SignalQuestChanged.Connect(SetRedrawFlag, this)
        Quests.SignalTierCompleted.Connect(SetRedrawFlag, this)
        Quests.SignalTierFailed.Connect(SetRedrawFlag, this)
        Quests.SignalMissionCompleted.Connect(SetRedrawFlag, this)
        Quests.SignalCompletedQuestsChanged.Connect(SetRedrawFlag, this)
        Quests.SignalGoalProgress.Connect(SetRedrawFlag, this );
        Quests.SignalGoalPhaseUpdated.Connect(SetRedrawFlag, this );
        Quests.SignalQuestCooldownChanged.Connect( SetRedrawFlag, this );       
        Quests.SignalMissionRequestFocus.Connect( SlotFocusMission, this);
        
        m_Character = Character.GetClientCharacter();
        m_Character.SignalStatChanged.Connect(SlotStatUpdated, this);
        SlotStatUpdated( _global.Enums.Stat.e_PowerRank);

        m_Background.onPress = function() {  }; // capture mouse for scrolling 
        
        Selection["captureFocus"](false);
        Selection["disableFocusAutoRelease"] = false;
    }

    private function SlotStatUpdated(statId:Number)
    {
        if (statId == _global.Enums.Stat.e_PowerRank)
        {
            m_PowerRank = m_Character.GetStat(statId, 2);
        }
    }

    private function CreateInitialWindow()
    {
        /// Change this data to real data, where does it come from?
        var missionData:Array = [m_TDB_CurrentMisionons, m_TDB_FinishedMissions, m_TDB_AbandonedMissions];
        
        /// dropdowns
        m_MissionDropdown = AttachDropdown("m_MissionDropdown", m_Menu, missionData, 0);
        m_MissionDropdown.addEventListener("select", this, "OnJournalTypeSelection");
        m_MissionDropdown.selectedIndex = m_JournalTypeIndexSelected;
        
        m_PlayfieldDropdown  = AttachDropdown("m_PlayfieldDropdown", m_Menu, m_PlayfieldNames, 0);
        m_PlayfieldDropdown.addEventListener("select", this, "OnPlayfieldSelection");
        m_PlayfieldDropdown._visible = false;
        //m_PlayfieldDropdown._y = m_ContentSize.y - m_PlayfieldDropdown._height - 20;
        
        m_Menu.createEmptyMovieClip("m_Divider", m_Menu.getNextHighestDepth());
        m_Menu.m_Divider._y = m_DropdownHeight + 10;
       
        UpdateMissionDropdownBoxes();

    }

    private function OnJournalTypeSelection(event:Object)
    {
        var index:Number = event.target.selectedIndex;

        if (m_JournalTypeIndexSelected != index)
        {
            m_JournalTypeIndexSelected = index;
            SetRedrawFlag();
            Selection.setFocus(null);
        }
        else if (!event.target.isOpen)
        {
            Selection.setFocus(null);
        }
        
        /// hide the playfield selector if necessary
        m_PlayfieldDropdown._visible = (m_MissionDropdown.selectedIndex == m_JournalTypeCurrentMissionIndex || m_MissionDropdown.selectedIndex == m_JournalTypeAbandonedMissionIndex) ? false : true;
    }

    private function OnPlayfieldSelection(event:Object)
    {
        var index:Number = event.target.selectedIndex;
        
        Log.Info2("MissionJournalWindow", "OnPlayfieldSelection(index=" + index + ")");
            
        if (m_PlayfieldIndexSelected != index)
        {
            SetSelectedPlayfieldIndex(index);
            SetRedrawFlag();
            Selection.setFocus(null);
        }
        else if (!event.target.isOpen)
        {
            Selection.setFocus(null);
        }
    }

    private function SetSelectedPlayfieldIndex(index:Number) : Void
    {
        m_PlayfieldIndexSelected = index
        
        // Store the last non-empty playfield name selected.
        var selectedPlayfieldName = m_PlayfieldNames[ m_PlayfieldIndexSelected ].name;
        
        Log.Info2("MissionJournalWindow", "SetSelectedPlayfieldIndex(index=" + index + ")");
        Log.Info2("MissionJournalWindow", "selectedPlayfieldName = "+selectedPlayfieldName+" m_PlayfieldIndexSelected = "+m_PlayfieldIndexSelected );
        
        if (selectedPlayfieldName != "")
        {
            m_LastPlayfieldNameSelected = m_PlayfieldNames[ m_PlayfieldIndexSelected ].name
        }
    }
    private function AreRewardsVisible() : Boolean
    {
        return m_JournalTypeIndexSelected == 0
    }

    /// @param name:String - the instance name of the new clip
    /// @param contentArray:Array - the dataprovider with the values for the dropdown
    /// @param parent:MovieClip - the context / scope where the clip is created
    /// @param selectedIndex:Number - the selected index when creating the dropdown
    /// @return dropDowm:MovieClip - reference to the newly crated dropdown
    private function AttachDropdown(name:String, parent:MovieClip, contentArray:Array, selectedIndex:Number) : MovieClip
    {
        
        var dropDown:MovieClip = parent.attachMovie("DropdownGray", name, parent.getNextHighestDepth());
        dropDown.dataProvider = contentArray;
        dropDown.direction = "down";
        dropDown.rowCount = contentArray.length;
        dropDown.selectedIndex = selectedIndex;
        dropDown.dropdown = "ScrollingListGray";
        dropDown.itemRenderer = "ListItemRendererGray";
        
        return dropDown;
    }

    private function FindMissionByID(id:Number) : Object
    {
        for ( var i = 0; i < m_Missions.length; ++i )
        {
            var mission:com.GameInterface.Quest = m_Missions[i];
            
            if (mission.m_ID == id)
            {
                return mission;
            }
        }
        
        return null;
    }

    private function FindCurrentTier(missionId:Number) : Object
    {
        var mission:Object = FindMissionByID(missionId);
        var currentTierIdx:Number = mission.m_CurrentTask.m_Tier;
        var currentTier:Object = mission.m_Tiers[currentTierIdx - 1];
        
        return currentTier;
    }

    /**
     * Create the header for each Mission Tier with buttons and methods for expanding
     * @param	parent:MovieClip - reference to the journal window
     * @param	mission:com.GameInterface.Quest) - the mission object for this item
     * @return MovieClip - reference to the clip created in this method
     */
    private function CreateSingleMissionClip(parent:MovieClip, mission:com.GameInterface.Quest) : MovieClip
    {
        var gmlevel:Number = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel, 2);
        
        var isAbandonedMissions:Boolean = (m_JournalTypeIndexSelected == m_JournalTypeAbandonedMissionIndex);
        var isCurrentMissions:Boolean = (m_JournalTypeIndexSelected == m_JournalTypeCurrentMissionIndex);
        var isFinishedMissions:Boolean = (m_JournalTypeIndexSelected == m_JournalTypeFinishedMissionIndex);
        
        var missionType:String = MissionUtils.MissionTypeToString( mission.m_MissionType );
        var missionSubText:String = m_TDB_Tier + " " + mission.m_CurrentTask.m_Tier + "/" + mission.m_TierMax;
        var missionSubTextFormat:TextFormat = m_HeaderSubTextFormat;
        var missionSubColor:Number = Colors.e_ColorJournalUnrepeatableFont; //(mission) ? Colors.e_ColorJournalRepetableFont : Colors.e_ColorJournalUnrepeatableFont;
        
        var isTimer:Boolean = false;
        
        var allowedWidth:Number = m_ContentSize.x - 10 ;
        /// name container
        var headerClip:MovieClip = parent.createEmptyMovieClip("m_HeaderClip", parent.getNextHighestDepth());
        headerClip.MissionID = mission.m_ID;  

        Log.Info1("MissionJournalWindow", "Mission type: " + missionType + "(" + mission.m_MissionType + "), isFinishedMissions = "+isFinishedMissions+", isCurrentMissions = "+isCurrentMissions+", isAbandonedMissions = "+isAbandonedMissions);
        var missionIcon:MovieClip = headerClip.attachMovie("_Icon_Mission_" + missionType, "m_MissionIcon", headerClip.getNextHighestDepth());
        missionIcon.MissionID = mission.m_ID;
        missionIcon._yscale = 60;
        missionIcon._xscale = 60;
        missionIcon.addEventListener("click", this, "ToggleExpandMissionEventHandler");
        missionIcon.state = "up"
        missionIcon.disableFocus = true;
        
        /// the missionIconModifier
        if ( Quests.IsMissionActive( mission.m_ID ) )
        {
            var inProgress:MovieClip = headerClip.attachMovie("_Icon_Modifier_InProgress", "m_InProgress", headerClip.getNextHighestDepth());
            inProgress._xscale = 90;
            inProgress._yscale = 90;
            inProgress._x = missionIcon._width - 16;
            inProgress._y = missionIcon._height - 16;
        }
        else if(isAbandonedMissions)
        {
            var paused:MovieClip = headerClip.attachMovie("_Icon_Modifier_Paused", "m_Paused", headerClip.getNextHighestDepth());
            paused._xscale = 90;
            paused._yscale = 90;
            paused._x = missionIcon._width - 16;
            paused._y = missionIcon._height - 16;
        }
        else if (isFinishedMissions)
        {
            Log.Info1("MissionJournalWindow", "mission.m_CooldownExpireTime: " + mission.m_CooldownExpireTime);
            if (mission.m_CooldownExpireTime != undefined)
            {
                var cooldown:MovieClip = headerClip.attachMovie("_Icon_Modifier_Cooldown", "m_CooldownTimer", headerClip.getNextHighestDepth());
                cooldown._xscale = 90;
                cooldown._yscale = 90;
                cooldown._x = missionIcon._width - 16;
                cooldown._y = missionIcon._height - 16;

                missionSubTextFormat = m_HeaderTimerTextFormat;
                isTimer = true;

                headerClip.m_Cooldown = mission.m_CooldownExpireTime;
               
                headerClip.onEnterFrame = function()
                {
                    var t:Number = (this.m_Cooldown - Utils.GetServerSyncedTime()) * 1000;
                    if (t < 1000)
                    {
                        this.onEnterFrame = undefined;
                    }
                    this["m_HeaderSubText"].htmlText = Utils.CreateHTMLString((Format.Printf( "%02.0f:%02.0f:%02.0f", Math.floor(t / 3600000), Math.floor(t / 60000) % 60, Math.floor(t / 1000) % 60 )),
                                                {face:"_TimerFont", color: Colors.ColorToHtml(Colors.e_ColorLightOrange), size: 12}); 
                }
            }
            else if (mission.m_IsRepeatable)
            {
                missionSubText = LDBFormat.LDBGetText( "MiscGUI", "Mission_Repeatable");      
            }
            else
            {
                missionSubText = LDBFormat.LDBGetText( "MiscGUI", "Mission_Unrepeatable");
            }
        }

        /// Right Position Initial Value
        var rightPos:Number = allowedWidth;
        /// Pause Icon
        if ((gmlevel != 0) && isCurrentMissions)
        {
            m_DeleteMissionButton = headerClip.attachMovie("PauseButton", "m_PauseButton", headerClip.getNextHighestDepth());
            
            rightPos -= m_DeleteMissionButton._width + 3;
            SetupButton(m_DeleteMissionButton, rightPos, mission, "TrashcanHandler");
        }
        
        /// Share Icon
        if (isCurrentMissions)
        {
            m_ShareButton = headerClip.attachMovie("ShareButton", "m_ShareButton", headerClip.getNextHighestDepth());
            
            rightPos -= m_ShareButton._width + 3;
            SetupButton(m_ShareButton, rightPos, mission, "ShareHandler");
        }
        
        /// Location Icon
        if (mission.m_CanLocateOnMap)
        {
            m_LocationButton = headerClip.attachMovie("LocationButton", "m_LocationButton", headerClip.getNextHighestDepth());
            
            rightPos -= m_LocationButton._width + 3;
            SetupButton(m_LocationButton, rightPos, mission, "LocationHandler");
        }

        /// Header text
        var headerMainText:TextField = headerClip.createTextField("m_HeaderMainText", headerClip.getNextHighestDepth(), 0, 0, 0, 0)
        headerMainText.selectable = false;
        headerMainText.html = true;
        headerMainText.htmlText = Utils.CreateHTMLString(mission.m_MissionName, { face:"_StandardFont", color:"#FFFFFF", size:16 } ) 
								+ Utils.CreateHTMLString("   "+ MissionUtils.GetMissionSlotTypeName(mission.m_MissionType), { face:"_StandardFont", color:MissionUtils.GetMissionSlotTypeColor(mission.m_MissionType), size:16 } );
        headerMainText._x = 35;
        headerMainText._y = -5;
        headerMainText._width = allowedWidth - ((allowedWidth - rightPos) + headerMainText._x + 5) ;
        headerMainText._height = 27;
		
        /// Sub text
        var headerSubText:TextField = headerClip.createTextField("m_HeaderSubText", headerClip.getNextHighestDepth(), 0, 0, 0, 0);
        headerSubText.selectable = false;
        headerSubText.autoSize = "left";

        headerSubText.html = true;
		
		var htmlText:String = "";

        if (!isTimer)
        {
            htmlText = "<b>" + com.GameInterface.Utils.CreateHTMLString(missionSubText+" ", { face:"_StandardFont", color:"#AAAAAA", size:10 } );
            htmlText += GUI.Mission.MissionUtils.GetMissionDifficultyText( mission.m_CurrentTask.m_Difficulty - m_PowerRank,  {face: "_StandardFont", size:10}  ) + "</b>";
        }
        else
        {
            htmlText = com.GameInterface.Utils.CreateHTMLString("00:00", {face:"_TimerFont", color: Colors.ColorToHtml(Colors.e_ColorLightOrange), size: 12});
        }
		
		headerSubText.htmlText = htmlText;
		
        headerSubText._x = 35
        headerSubText._y = headerMainText._y + headerMainText._height -4;
		
        var baseX:Number = headerSubText._x + headerSubText._width + 5;
        var baseY:Number = headerSubText._y + 5;

        /// Invisible button for main textfield, sub textfiend and difficult display
        var invisibleButton:MovieClip = headerClip.createEmptyMovieClip("invisibleButton", headerClip.getNextHighestDepth());
        invisibleButton.beginFill(0xFF0000, 0);
        invisibleButton.moveTo(0, 0);
        invisibleButton.lineTo(headerMainText.textWidth, 0);
        invisibleButton.lineTo(headerMainText.textWidth, headerMainText.textHeight);
        invisibleButton.lineTo(headerSubText.textWidth + 5 + (10 * mission.m_CurrentTask.m_Difficulty), headerMainText.textHeight);
        invisibleButton.lineTo(headerSubText.textWidth + 5 + (10 * mission.m_CurrentTask.m_Difficulty), headerMainText.textHeight + headerSubText.textHeight - 4);
        invisibleButton.lineTo(0, headerMainText.textHeight + headerSubText.textHeight - 4);
        invisibleButton.lineTo(0, 0);
        invisibleButton.endFill();
        invisibleButton._x = headerMainText._x + 2;
        
        invisibleButton.ref = this;
        invisibleButton.m_ID = mission.m_ID;
        
        invisibleButton.onPress = function() 
        {
            this["ref"].ToggleExpandMission( this["m_ID"] );
        }
       
        return headerClip;
    }


    private function SetupButton(target:MovieClip, positionX:Number, mission:com.GameInterface.Quest, clickHandler:String):Void
    {
        target.gotoAndStop("over");
        target.MissionID = mission.m_ID;
        target.disableFocus = true;
        target._x = positionX;
        target._y = 2;

        target.addEventListener("click", this, clickHandler);
        target.addEventListener("press", this, "ToggleToolTip");
        target.addEventListener("rollOut", this, "ToggleToolTip");
        target.addEventListener("rollOver", this, "ToggleToolTip");
    }

    private function CreateOpenMission( parent:MovieClip, mission:com.GameInterface.Quest ) : Void
    {
        var openMissionClip:MovieClip = parent.createEmptyMovieClip("m_MainTierBackground", parent.getNextHighestDepth());
        var tiers:Object = mission.m_Tiers;

        /// create the mission description
        var missionDescTF:TextField = openMissionClip.createTextField("m_Desc", openMissionClip.getNextHighestDepth(), 0, 0, 0, 0);  
        missionDescTF.selectable = false
        missionDescTF.multiline = true
        missionDescTF.wordWrap = true
        missionDescTF.autoSize = "left"
        missionDescTF.text = mission.m_MissionDesc; 
        missionDescTF.setTextFormat( m_MissionDescFormat );
        missionDescTF._height = missionDescTF.textHeight
        missionDescTF._width = m_ContentSize.x - 50;    
       
        var tierY:Number = openMissionClip._height+ 5;

        // If showing active missions, do not show any tiers after the active one.
        var lastVisibleTier:Number = tiers.length;
        Log.Info1("MissionJournalWindow", "The mission has " + tiers.length + " tier(s).");        

        if ((m_JournalTypeIndexSelected == 0 || m_JournalTypeIndexSelected == 2) && mission.m_CurrentTask.m_Tier < lastVisibleTier)
        {
            Log.Info1("MissionJournalWindow", "Limiting shown tiers to the active tier (tier " + mission.m_CurrentTask.m_Tier + ")");        
            lastVisibleTier = mission.m_CurrentTask.m_Tier;
        }
        
        Log.Info1("MissionJournalWindow", "Showing tier index 0 to " + lastVisibleTier);
        
        /// iterate and create the tier
        for ( var tierIdx = 0; tierIdx < lastVisibleTier; tierIdx++ )
        {
            Log.Info2("MissionJournalWindow", "tierIdx  " + tierIdx);
            var tierMC:MovieClip = CreateSingleTierClip(openMissionClip, mission, tierIdx);
            tierMC._y = tierY;
            tierY = tierY + tierMC._height;
        }
        
        /// draw the rewards
        if ( AreRewardsVisible() )
        {
            CreateRewards( openMissionClip, mission );
        }
        
        /// draw the surrounding frame
        com.Utils.Draw.DrawRectangle(openMissionClip, -3, -2, openMissionClip._width +10, openMissionClip._height+10, Colors.e_ColorJournalMainTier, 80, [4, 4, 4, 4]);
        openMissionClip._x = 35;
        openMissionClip._y = 40;
    }

    private function CreateRewards(parent:Object, mission:Object) : Void
    {
        Log.Info1("MissionJournalWindow", "Cash=" + mission.m_Cash+ ", XP=" + mission.m_Xp)

        var rewardY:Number = parent._height + 10
        
        if (mission.m_Cash > 0)
        {
            var cashIcon = parent.attachMovie("_Icon_Cash", "m_Icon", parent.getNextHighestDepth());
            cashIcon._x = 3;
            cashIcon._y = rewardY         
            
            var cashTF = parent.createTextField("m_Cash", parent.getNextHighestDepth(), 0, 0, 0, 0);
            cashTF.selectable = false
            cashTF.autoSize = "left"
            cashTF.setNewTextFormat( m_CashFormat )
            cashTF.text = mission.m_Cash.toString();
            cashTF._height = cashTF.textHeight
            cashTF._x = cashIcon._x + cashIcon._width + 5;
            cashTF._y = rewardY;
        }
        if (mission.m_Xp > 0)
        {
            var xpIcon = parent.attachMovie("_Icon_XP", "m_XPIcon", parent.getNextHighestDepth());
            xpIcon._x = cashTF._x + cashTF._width + 10;
            xpIcon._y = rewardY                     
            
            var xpTF = parent.createTextField("m_SkillPoints", parent.getNextHighestDepth(), 0, 0, 0, 0);
            xpTF.selectable = false
            xpTF.autoSize = "left"
            xpTF.setNewTextFormat( m_CashFormat )
            xpTF.text = mission.m_Xp
            xpTF._height = xpTF.textHeight
            xpTF._x = xpIcon._x + xpIcon._width + 5;
            xpTF._y = rewardY;
        }
    }

    private function CreateSingleTierClip(parent:MovieClip, mission:com.GameInterface.Quest, index:Number) : MovieClip
    {
        var currentTask:QuestTask = mission.m_CurrentTask;
        var tiers:Array = mission.m_Tiers;
        var currentTierIdx:Number = currentTask.m_Tier;
        var currentTier:Object = tiers[currentTierIdx - 1];
        var questTask:com.GameInterface.QuestTask = tiers[index];
        var isActiveTask:Boolean = (currentTier.m_ID == questTask.m_ID && (m_JournalTypeIndexSelected == m_JournalTypeCurrentMissionIndex) );
        
        Log.Info2("MissionJournalWindow", "currentTierIdx " + currentTierIdx + " index = " + index+", mission.m_Tiers["+index+"].m_Tier = " + mission.m_Tiers[index].m_Tier);
            
        var tierMC:MovieClip = parent.createEmptyMovieClip("m_TierMC" + index, parent.getNextHighestDepth());
        tierMC.MissionID = mission.m_ID
        tierMC.TierID = questTask.m_ID
        tierMC._x = 0;
        tierMC._y = 5;
        
        var tierNameMC:MovieClip = tierMC.createEmptyMovieClip("m_TierNameMC" + index, tierMC.getNextHighestDepth());
        tierNameMC.MissionID = mission.m_ID
        tierNameMC.TierID = questTask.m_ID
        
        var tierNameButton:Button = Button( tierNameMC.attachMovie("TierNameButton", "m_TierNameButton", tierNameMC.getNextHighestDepth(), { _y:5 } ) );
        tierNameButton["TierID"] = questTask.m_ID
        tierNameButton.addEventListener("click", this, "TierNameClickHandler");
        tierNameButton.autoSize = "left";
        if (isActiveTask)
        {
            ExpandCurrentTier(mission.m_ID);
        }

        if (IsTierExpanded(questTask.m_ID))
        {
            tierNameButton.selected = true
        }
        var labelString:String = m_TDB_Tier_MixedCase +" " + questTask.m_Tier;
        var textWidth:Number = tierNameButton.textField.getTextFormat().getTextExtent( labelString ).width;/// Ah Scaleform, thy name is workarounds.
        tierNameButton.label = labelString;
        
    
        if (isActiveTask)
        {
            var inProgress:MovieClip = tierNameMC.attachMovie("_Icon_Modifier_InProgress", "m_InProgress", tierNameMC.getNextHighestDepth());
            inProgress._xscale = 70;
            inProgress._yscale = 70;
          //  inProgress._x = tierNameTF._x + tierNameTF._width + 4;
         // trace("tierNameButton.textField.text = " + tierNameButton.textField.text);
          //trace("tierNameButton.label.text = " + tierNameButton.label.text);
            inProgress._x = tierNameButton._x + textWidth + 10; 
            inProgress._y = 5;
        }

        if (IsTierExpanded(questTask.m_ID))
        {
            var tierDescTF:TextField = tierMC.createTextField("m_TierDescTF" + index, tierMC.getNextHighestDepth(), 0, 0, 0, 0);  
            tierDescTF.selectable = false
            tierDescTF.multiline = true
            tierDescTF.wordWrap = true
            tierDescTF.autoSize = "left"
            tierDescTF.setNewTextFormat( m_MissionDescFormat );
            
            if (questTask == null)
            {
                tierDescTF.htmlText = "[quest task is null]";
            }
            else if(questTask.m_TierDesc == null)
            {
                tierDescTF.htmlText = "[quest task desc is null]";                        
            }
            else if(questTask.m_TierDesc == "")
            {
                tierDescTF.htmlText = "[quest task desc is empty]";                        
            }
            else
            {
                if (isActiveTask)
                {
                    tierDescTF.htmlText =  LDBFormat.Translate(currentTask.m_TierDesc);
                }
                else
                {
                    tierDescTF.htmlText =  LDBFormat.Translate(questTask.m_TierDesc);
                }
            }
            tierDescTF.setTextFormat( m_MissionDescFormat );
            
            //Code swaps out text now.
            //if (tierIdx + 1 == currentTask.m_Tier && currentTask.m_Tier == currentTier.m_Tier)
            //{
            //    Log.Info1("MissionJournalWindow", "Showing current task description for tier " + currentTier.m_Tier);                        
            //    tierDescTF.text = currentTask.m_Desc;
            //}
            
            tierDescTF._height = tierDescTF.textHeight
            tierDescTF._x = 8;
            tierDescTF._y = 24;
            tierDescTF._width = parent._width - tierDescTF._x - 5;
            
            if (isActiveTask)
            {
                var goals:Array = currentTask.m_Goals;    
                var goalY:Number = tierDescTF._y + tierDescTF._height + 7;
                goals.sortOn( "m_SortOrder");
                for (var goalIdx = 0; goalIdx < goals.length; ++goalIdx)
                {
                    var goal:com.GameInterface.QuestGoal = goals[ goalIdx ];
                   
                    if ( currentTask.m_CurrentPhase == goal.m_Phase )
                    {
                        var goalMC:MovieClip = CreateSingleGoal(tierMC, goal);
                        goalMC._y = goalY;
                        goalMC._x = 10;
                        goalY += goalMC._height;
                    }
                }
            }
            
            var mediaTask = tiers[index];
            
            if (isActiveTask)
            {
                mediaTask = currentTask;
            }
			
            if (mediaTask.m_MediaRDBID != 0)
            {
                var mediaType:Number = mediaTask.m_MediaType;
                var buttonLink:String = "";
                var buttonText:String = "";
                
                switch (mediaType)
                {
                    case _global.Enums.QuestMediaType.QuestGiverList_QuestMediaType_Image:  buttonLink = "PlayImageButton";
                                                                                            buttonText = m_TDB_ShowImage;
                                                                                            break;
                                                                                            
                    case _global.Enums.QuestMediaType.QuestGiverList_QuestMediaType_Audio:  buttonLink = "PlayAudioButton"
                                                                                            buttonText = m_TDB_PlayAudio;
                                                                                            break;
                                                                                            
                    case _global.Enums.QuestMediaType.QuestGiverList_QuestMediaType_Video:  buttonLink = "PlayVideoButton"
                                                                                            buttonText = m_TDB_PlayVideo
                }

                var tierButton:MovieClip = tierMC.attachMovie(buttonLink, "i_MediaButton", tierMC.getNextHighestDepth());
                tierButton._x = 10;
                tierButton._y = tierMC._height + 10;
                tierButton.label = buttonText.toUpperCase();
                tierButton.addEventListener("click", this, "MediaButtonHandler");
				tierButton.m_MediaRdbID = mediaTask.m_MediaRDBID;
				tierButton.m_MediaType = mediaType;
                tierButton.disableFocus = true;
            }
            
            com.Utils.Draw.DrawRectangle(tierMC, 5, 20, tierMC._width, tierMC._height - tierNameMC._height + 5, Colors.e_ColorJournalSubTier, 80, [4, 4, 4, 4]);
        }
        
        return tierMC;
    }

    private function CreateSingleGoal(parent:MovieClip, goal:com.GameInterface.QuestGoal) : MovieClip
    {
        var goalMC:MovieClip = parent.createEmptyMovieClip("i_GoalMC" + goal.m_ID, parent.getNextHighestDepth());
        var dot:MovieClip = goalMC.attachMovie("Dot", "i_Dot", goalMC.getNextHighestDepth(), { _y:7 } );
        
        var maxWidth:Number = m_ContentSize.x - 70; 
        var goalDesc:String = com.Utils.LDBFormat.Translate( goal.m_Name );
        
        // Numbers.. (x / y)
        if (goal.m_RepeatCount > 1 && goal.m_SolvedTimes < goal.m_RepeatCount)
        {
            var numDesc:String = "(" + goal.m_SolvedTimes + "/" + goal.m_RepeatCount + ")";
            
            var numDescTextExtent:Object = m_GoalFormat.getTextExtent(numDesc);
            
            maxWidth -= (numDescTextExtent.width + 5);
            
            var numDescTF:TextField = goalMC.createTextField("i_NumDescTF", goalMC.getNextHighestDepth(),0,0,0,0);
            
            numDescTF.setNewTextFormat( m_GoalFormat );
     //       numDescTF.filters = [ m_Shadow ];
            numDescTF._width = numDescTextExtent.width + 1; //Added a 1 because the *depreciated* (Flash 8) getTextExtent method isn't working so well
            numDescTF._height = numDescTextExtent.height;
            numDescTF.text = numDesc;
            numDescTF._x = maxWidth;
        }
        
        maxWidth -= 10;
        
        var textExtent:Object = m_GoalFormat.getTextExtent( goalDesc, maxWidth );
        var singleLineTextExtent:Object = m_GoalFormat.getTextExtent( goalDesc );
        var lineHeight:Number = singleLineTextExtent.textFieldHeight;
        
        var goalDescTF:TextField = goalMC.createTextField("i_GoalDescTF", goalMC.getNextHighestDepth(), 0, 0, 0, 0); 
        goalDescTF.wordWrap = true;
        goalDescTF.setNewTextFormat( m_GoalFormat );
     //   goalDescTF.filters = [ m_Shadow ];
        goalDescTF._width = maxWidth;
        goalDescTF._height = textExtent.height + 5;
        goalDescTF.text = goalDesc;   
        goalDescTF._x = 10;
        
        // if goal is complete, draw an overline
        if (goal.m_RepeatCount == goal.m_SolvedTimes )
        {
            var numLines:Number = Math.round( textExtent.height / lineHeight );
            var goalLines:MovieClip = goalMC.createEmptyMovieClip("line", goalMC.getNextHighestDepth());
            goalLines.beginFill( 0xFFFFFF, 70); // white line, alpha set on parent

            for (var currentLine:Number = 1; currentLine <= numLines; currentLine++ )
            {
                var endpos:Number = (currentLine == numLines) ? (singleLineTextExtent.width % maxWidth) + 15 : maxWidth;
                var ypos:Number = (lineHeight * currentLine) - (lineHeight / 2);

                goalLines.moveTo(10, ypos);
                goalLines.lineTo(endpos + 5, ypos);
                goalLines.lineTo(endpos + 5, ypos + 2);
                goalLines.lineTo(10, ypos + 2);
                goalLines.lineTo(10, 0)
            }

            /// numbers.. (x / y)
            if ( numDescTF )
            {
                goalLines.moveTo(numDescTF._x, numDescTF._y+10)
                goalLines.lineTo(numDescTF._x + numDescTF._width, numDescTF._y+10);
            }
            
            goalLines.endFill();
      //      goalLines.filters = [ m_Shadow ];     
            goalMC._alpha = 60;
        }
        return goalMC;
    }


    private function UpdateMissionDropdownBoxes()
    {
        var dropDownWidth:Number = (m_ContentSize.x * 0.5) - 5
        m_MissionDropdown.setSize(dropDownWidth, m_DropdownHeight);
        m_MissionDropdown.dropdownWidth = dropDownWidth;

        /// Current missions
        if (m_JournalTypeIndexSelected == m_JournalTypeCurrentMissionIndex)
        {
            m_Missions = Quests.GetAllActiveQuests();
			
            m_PlayfieldNames = [ "" ]
            m_PlayfieldDropdown.disabled = true
        }
        /// Abandoned quests
        else if ( m_JournalTypeIndexSelected == m_JournalTypeAbandonedMissionIndex)
        {
            m_Missions = Quests.GetAllAbandonedQuests();
            m_PlayfieldNames = [ "" ]
            m_PlayfieldDropdown.disabled = true
        }
        // Completed missions
        else if (m_JournalTypeIndexSelected == m_JournalTypeFinishedMissionIndex)
        {
            var isAllRegionsSelected:Boolean = ((m_PlayfieldIndexSelected == 0) ? true : false);
            
            m_PlayfieldDropdown._visible = true;
            m_Missions = [];
            m_PlayfieldNames = [ "" ]; // adding index 0 at the end

            var missionObject:Object = Quests.GetAllCompletedQuestsByRegion();
            
            var firstSelected:Boolean = false;
            var nameWidth:Number = m_DropDownFormat.getTextExtent( m_TDB_AllRegions + " (100)" ).width;
            var totalNumQuest:Number = 0;
            
            for (var name in missionObject)
            {
                var missionArray:Array = missionObject[name];
                var pfName:String = name.toUpperCase() + " (" + missionArray.length + ")";

                nameWidth = Math.max(m_DropDownFormat.getTextExtent( pfName ).width, nameWidth);

                m_PlayfieldNames.push( { label: pfName, name:name } );
                totalNumQuest += missionArray.length;

                if ( isAllRegionsSelected )
                {
                    m_Missions = m_Missions.concat( missionArray );
                    SetSelectedPlayfieldIndex( 0 ); 
                }
                else
                {
                    // Select the missions from the first entry in the list.
                    if (!firstSelected)
                    {
                        m_Missions = missionArray
                        firstSelected = true
                    }
                    
                    // If the last selected playfield name still exists in the list, select it instead.            
                    if (name == m_LastPlayfieldNameSelected)
                    {
                        m_Missions = missionArray
                        SetSelectedPlayfieldIndex( m_PlayfieldNames.length - 1 ); 
                    }
                }
            }

            m_PlayfieldNames[0] = { label:m_TDB_AllRegions + " (" + totalNumQuest + ")", name: m_TDB_AllRegions };

            m_PlayfieldDropdown.setSize(dropDownWidth, m_DropdownHeight);
            m_PlayfieldDropdown.dropdownWidth = dropDownWidth;
            m_PlayfieldDropdown._x = m_ContentSize.x - m_PlayfieldDropdown.width;
            m_PlayfieldDropdown.disabled = (m_PlayfieldNames.length == 0);
            m_PlayfieldDropdown.dataProvider = m_PlayfieldNames;
            m_PlayfieldDropdown.rowCount = m_PlayfieldNames.length;
            m_PlayfieldDropdown.selectedIndex = m_PlayfieldIndexSelected;
        }
    }

    private function Redraw() : Void
    {
        Log.Info1("MissionJournalWindow", "Redraw(): m_ExpandedMissionID=" + m_ExpandedMissionID)         
        
        var contentHeight:Number = m_ContentSize.y - m_Content._y;
        var gmlevel:Number = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel, 2);
        var gm:Boolean = (gmlevel != 0);
        
        // Remove the current text fields.
        if (m_Content.m_MissionWindow)
        {
            m_Content.m_MissionWindow.removeMovieClip();
        }
        
        // remove the mask if any
        if (m_Content["mask"])
        {
            m_Content.setMask(null);
            m_Content["mask"].removeMovieClip();
        }
        
        // remove the scrollbar if any
        if (m_ScrollBar)
        {
            m_ScrollBar.removeMovieClip();
        }
        
        // redraw the divider line in the header
        m_Menu.m_Divider.clear();
        m_Menu.m_Divider.lineStyle(1, 0xFFFFFF, 50);
        m_Menu.m_Divider.moveTo(0, 0);
        m_Menu.m_Divider.lineTo( m_ContentSize.x, 0);

        // update position and size of dropdownboxes
        UpdateMissionDropdownBoxes();

        //recreate the mission window
        var missionWindow:MovieClip = m_Content.createEmptyMovieClip("m_MissionWindow", m_Content.getNextHighestDepth());
        
        var contentY:Number = 5;
        
        m_Missions.sortOn( "m_MissionName" );
        // iterate missions and draw
        for ( var i = 0; i < m_Missions.length; ++i )
        {
            var mission:com.GameInterface.Quest = m_Missions[i];
           
            /// container
            var missionMC:MovieClip = missionWindow.createEmptyMovieClip("m_MissionMC" + i, missionWindow.getNextHighestDepth());
            missionMC.MissionID = mission.m_ID;
            missionMC._y = contentY;
            missionMC._x = 5;
            var header:MovieClip = CreateSingleMissionClip(missionMC, mission);
          
            // if the mission is selected and open
            if (m_ExpandedMissionID == mission.m_ID )
            {
                CreateOpenMission(missionMC, mission);
            }
            
            contentY += missionMC._height + 20;
        }
        
       // m_Content.m_Background._x;
       // m_Content.m_Background._y;
        
        m_Content.m_Background._width = m_ContentSize.x
        m_Content.m_Background._height = contentHeight;
        
        /// add scrollbar
        
        if (missionWindow._height > contentHeight)
        {
            
            com.GameInterface.ProjectUtils.SetMovieClipMask(missionWindow, m_Content, contentHeight);
            
            m_ScrollBar = m_Content.attachMovie("ScrollBar", "m_ScrollBar", m_Content.getNextHighestDepth());
            m_ScrollBar._y = 0
            m_ScrollBar._x = m_ContentSize.x;  

            m_ScrollBar.setScrollProperties( contentHeight, 0, missionWindow._height - contentHeight); 
            m_ScrollBar._height = contentHeight;
            m_ScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
            m_ScrollBar.position = m_ScrollBarArchivedPosition; 
            m_ScrollBar.trackMode = "scrollPage"
            m_ScrollBar.trackScrollPageSize = contentHeight;
            m_ScrollBar.disableFocus = true;
            
            // adds the mouse listener if we scroll
            Mouse.addListener( this );

        }
        else
        {
            // removes the mouselistener if we do not need it
            // there is no way of knowing if there is a listener, so we attempt to remove it even if it does not exist
            Mouse.removeListener( this );
            
            m_ScrollBarArchivedPosition = 0;
        }
    }

    private function ToggleToolTip(event:Object) : Void
    {
        Log.Info2("MissionJournalWindow", "ToggleToolTip event.type = " + event.type + " event.target " + event.target + " event.target._name " + event.target._name);
        var target:MovieClip = event.target;
        var name:String = target._name;
        
        if (event.type == "rollOut" || event.type == "press")
        {
            if (m_TooltipController.tooltip)
            {
                var tooltip:MovieClip = m_TooltipController.tooltip;
                tooltip.tweenTo(1, { _alpha:0 }, None.easeNone);
                tooltip.onTweenComplete = function()
                {
                    tooltip.removeMovieClip();
                }
            }
            
            m_TooltipController = { isVisible: false, target: null, tooltip:null };

            // kill the timeout
            if (m_TooltipTimeoutId)
            {
               clearTimeout( m_TooltipTimeoutId );
            }
           
            return;
        }
        
        /// a tooltip is present
        if (m_TooltipController.isVisible)
        {
            if (m_TooltipController.target != target)
            {
                m_TooltipController.target = target;    
            }
        }
        else
        {
            m_TooltipController.target = target;
            m_TooltipController.isVisible = true;
            m_TooltipTimeoutId = setTimeout( Delegate.create(this, DrawTooltip), 1000 );
        }
    }

    private function DrawTooltip():Void
    {
        clearTimeout( m_TooltipTimeoutId );
        if (!m_TooltipController.tooltip)
        {
            var target:MovieClip = m_TooltipController.target;

            var txt:String = "";

            switch (target._name)
            {
                case "i_LocationButton":    txt = LDBFormat.LDBGetText( "MiscGUI", "Mission_ShowOnMap");
                                            break;
                
                case " i_ShareButton":       txt = LDBFormat.LDBGetText( "MiscGUI", "Mission_ShareMission");
                                            break;
                
                case "i_PauseButton":       txt = LDBFormat.LDBGetText( "MiscGUI", "Mission_Abandon");
                                            break;
            }
            
            var textExtent:Object = m_TooltipTextFormat.getTextExtent( txt );
            var tooltip:MovieClip = this.createEmptyMovieClip("i_Tooltip", this.getNextHighestDepth());
            tooltip._x = this._xmouse;
            tooltip._y = this._ymouse - 30;
            
            var tf:TextField = tooltip.createTextField("i_TooltipTextField", tooltip.getNextHighestDepth(), 5, 2, textExtent.textFieldWidth, textExtent.textFieldHeight);
            tf.setNewTextFormat( m_TooltipTextFormat );
            tf.text = txt;
            com.Utils.Draw.DrawRectangle(tooltip, 0, 0, tf._width + 10, tf._height + 4, Colors.e_ColorPanelsBackground, 80, [3, 3, 3, 3], 1, Colors.e_ColorPanelsLine);

            m_TooltipController.tooltip = tooltip;
        }
        
    }

    private function MediaButtonHandler( event:Object ) : Void
    {
        Log.Info2("MissionJournalWindow", "Showing media for quest task " + event.target.m_QuestTaskID + ".");
		var mediaType:Number = 0;
		switch(event.target.m_MediaType)
		{
			case  _global.Enums.QuestMediaType.QuestGiverList_QuestMediaType_Video:
				mediaType = _global.Enums.RDBID.e_RDB_USM_Movie;
				break;
			case  _global.Enums.QuestMediaType.QuestGiverList_QuestMediaType_Image:
				mediaType = _global.Enums.RDBID.e_RDB_GUI_Image;
				break;
			case  _global.Enums.QuestMediaType.QuestGiverList_QuestMediaType_Audio:
				mediaType = _global.Enums.RDBID.e_RDB_FlashFile;
				break;
		}
        Quests.ShowMedia(mediaType, event.target.m_MediaRdbID);
    }

    private function CloseWindowHandler() : Void
    {
        Log.Info2("MissionJournalWindow", "closing button");
        DistributedValue.SetDValue("mission_journal_window", false);
    }

    private function TrashcanHandler(event:Object)
    {
        Log.Info2("MissionJournalWindow", "Deleting mission " + event.target.MissionID + ".");
        Quests.DeleteCurrentQuestOfMainQuest( event.target.MissionID );
    }

    private function ShareHandler(event:Object)
    {
        Log.Info2("MissionJournalWindow", "Sharing mission " + event.target.MissionID + ".");
        
        Quests.ShareQuest( event.target.MissionID );
    }

    private function LocationHandler(event:Object)
    {
        Log.Info2("MissionJournalWindow", "Showing location of mission " + event.target.MissionID + " on full screen map.");
        Quests.ShowQuestOnMap( event.target.MissionID );
    }

    private function OnScrollbarUpdate(event:Object) : Void
    {
        var target:MovieClip = event.target;
        var pos:Number = event.target.position;
        
        m_Content.m_MissionWindow._y = -pos;
        m_ScrollBarArchivedPosition = m_ScrollBar.position;
        
        Selection.setFocus(null);
    }

    private function SetExpandedMissionID(id:Number)
    {
        Log.Info1("MissionJournalWindow", "SetExpandedMissionID(id=" + id + ")")       
        
        m_ExpandedMissionID = id;
    }
    
    private function TierNameClickHandler(event:Object)
    {
        var tierId:Number = event.target.TierID;
        if (IsTierExpanded(tierId))
        {
            m_ExpandedTiersArray.splice( SearchArray( m_ExpandedTiersArray, tierId), 1);        
        }
        else
        {
            m_ExpandedTiersArray.push(tierId);
        }

        SetRedrawFlag();
    }

    private function ToggleExpandMissionEventHandler(evt:Object):Void
    {
        ToggleExpandMission(evt.target.MissionID);
    }

    private function ToggleExpandMission(id:Number):Void
    {
        Log.Info1("MissionJournalWindow", "ToggleExpandMission(): id=" + id + " m_ExpandedMissionID=" + m_ExpandedMissionID);     
        
        if (m_ExpandedMissionID == id)
        {
            Log.Info1("MissionJournalWindow", "ToggleExpandMission(): Collapsing " + id);        
            SetExpandedMissionID( -1);
        }
        else
        {
            Log.Info1("MissionJournalWindow", "ToggleExpandMission(): Expanding " + id);              
            
            SetExpandedMissionID(id);
            ExpandCurrentTier(id);
        }
        
        Log.Info1("MissionJournalWindow", "ToggleExpandMission(): id=" + id + " m_ExpandedMissionID=" + m_ExpandedMissionID)       
        
        SetRedrawFlag();
    }
    

    // When expanding a current mission clip or expanding/collapsing tiers of a current mission,
    // automatically expand the current mission tier if all tiers within the mission clip are collapsed
    private function ExpandCurrentTier(missionID:Number):Void
    {
        if (Quests.IsMissionActive(missionID))
        {
            var missionTiers:Array = FindMissionByID(missionID).m_Tiers;
            var currentTierID:Number = FindCurrentTier(missionID).m_ID;
            var expandCurrentTier:Boolean = true;
        
            for (var i:Number = 0; i < missionTiers.length; i++)
            {
                if (IsTierExpanded(missionTiers[i].m_ID))
                {
                    expandCurrentTier = false;
                    break;
                }
            }
            
            if (expandCurrentTier)
            {
                m_ExpandedTiersArray.push(currentTierID);
            }
        }
    }

    private function SlotFocusMission(missionId:Number)
    {
        SetExpandedMissionID( missionId );
        m_JournalTypeIndexSelected = m_JournalTypeCurrentMissionIndex;
        m_MissionDropdown.selectedIndex = m_JournalTypeIndexSelected;
        m_PlayfieldNames = [ "" ]
        m_PlayfieldDropdown.disabled = true
        m_PlayfieldDropdown._visible = false;
        
        SetRedrawFlag();
    }

    private function onMouseWheel( delta:Number )
    {
        if ( Mouse["IsMouseOver"]( m_Content ) )
        {
            var newPos:Number = m_ScrollBar.position + -(delta* m_DeltaMultiplier);
            var event:Object = { target : m_ScrollBar };
            
            m_ScrollBar.position = Math.min(Math.max(0.0, newPos), m_ScrollBar.maxPosition);
            
            OnScrollbarUpdate(event);
        }
    }

    private function IsTierExpanded(item:Object):Boolean
    {
        if (SearchArray(m_ExpandedTiersArray, item) != -1)
        {
            return true;
        }
        
        return false;
    }

    private function SearchArray(target:Array, item:Object):Number
    {
        for (var i:Number = 0; i < target.length; i++)
        {
            if (target[i] == item)
            {
                return i;
            }
        }
        
        return -1;
    }
}