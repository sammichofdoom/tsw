//Imports
import flash.display.BitmapData;
import mx.utils.Delegate;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.ClientServerPerfTracker;
import com.GameInterface.Tradepost;
import com.Utils.LDBFormat;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.Utils.HUDController;
import com.Utils.ID32;
import com.Utils.Format;
import com.Utils.Colors;

var STANDARD_FONT:String = "_Headline";
var FONT_SIZE:Number = 11;
var COLOR:Number = 0xFFFFFF;

var ICON_MARGIN:Number = 8;
var ICON_LABEL_Y:Number = 1;
var STARTING_Y_POSITION:Number = 41;
var ANIMATION_DURATION:Number = 0.2;
var BLINK_ANIMATION_DURATION:Number = 0.1;
var MAX_BLINK_AMOUNT:Number = 4;

var RECEIVE_MAIL_SOUND_EFFECT:String = "sound_fxpackage_GUI_receive_tell.xml";

var m_TDB_CharacterSheet:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_CharacterSheet");
var m_TDB_AbilityWheel:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_AbilityWheelLabel");
var m_TDB_CharacterSkillPoints:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_CharacterSkillPoints");
var m_TDB_Inventory:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Inventory");
var m_TDB_Journal:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Journal");
var m_TDB_PvP:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_PvP");
var m_TDB_Settings:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Settings");
var m_TDB_Shop:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_ItemShop");
var m_TDB_Shop_DisabledTooltip:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_ItemShop_DisabledTooltip");
var m_TDB_Exit:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Exit");
var m_TDB_Achievement:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Achievement");
var m_TDB_Help:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Help");
var m_TDB_Crafting:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Crafting");
var m_TDB_Petition:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Petition");
var m_TDB_Cabal:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Cabal");
var m_TDB_Friends:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Friends");
var m_TDB_LFG:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_LFG");
var m_TDB_Claim:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Claim");
var m_TDB_WebBrowser:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_WebBrowser");
var m_TDB_Leaderboards:String = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Leaderboards");

//Properties
var m_MenuIconContainer:MovieClip;
var m_MenuIcon:MovieClip;

var m_FPSIconContainer:MovieClip;
var m_FPSIcon:MovieClip;

var m_MailIconContainer:MovieClip;
var m_MailIcon:MovieClip;

var m_ClockIconContainer:MovieClip;
var m_ClockIcon:MovieClip;

var m_DownloadingIconContainer:MovieClip;
var m_DownloadingIcon:MovieClip;

var m_IsMenuOpen:Boolean;

var m_Character:Character;

var m_CharacterSkillPointsMonitor:DistributedValue;
var m_CharacterSheetMonitor:DistributedValue;
var m_AnimaWheelMonitor:DistributedValue;
var m_InventoryMonitor:DistributedValue;
var m_JournalMonitor:DistributedValue;
var m_PvPMonitor:DistributedValue;
var m_ItemShopMonitor:DistributedValue;
var m_AchievementMonitor:DistributedValue;
var m_HelpMonitor:DistributedValue;
var m_CraftingMonitor:DistributedValue;
var m_PetitionMonitor:DistributedValue;
var m_CabalMonitor:DistributedValue;
var m_FriendsMonitor:DistributedValue;
var m_LFGMonitor:DistributedValue;
var m_ItemShopMonitor:DistributedValue;
var m_ClaimMonitor:DistributedValue;
var m_BrowserMonitor:DistributedValue;
var m_LeaderboardsMonitor:DistributedValue;

var m_ClockShowRealTimeMonitor:DistributedValue;

var m_ResolutionScaleMonitor:DistributedValue;

var m_InvisibleButton:MovieClip;
var m_CharacterSheetButton:MovieClip;
var m_CharacterSkillPointsButton:MovieClip;
var m_ExitButton:MovieClip;
var m_InventoryButton:MovieClip;
var m_PvPButton:MovieClip;
var m_SettingsButton:MovieClip;
var m_JournalButton:MovieClip;
var m_AnimaWheelButton:MovieClip;
var m_ShopButton:MovieClip;
var m_CraftingButton:MovieClip;
var m_AchievementButton:MovieClip;
var m_HelpButton:MovieClip;
var m_PetitionButton:MovieClip;
var m_CabalButton:MovieClip;
var m_FriendsButton:MovieClip;
var m_LFGButton:MovieClip;
var m_ClaimButton:MovieClip;
var m_BrowserButton:MovieClip;
var m_LeaderboardsButton:MovieClip;

var m_BackgroundBar:MovieClip;
var m_MenuItems:Array;

var m_ServerFramerate:Number;
var m_ClientFramerate:Number;
var m_Latency:Number;
var m_CurrentDate:Date;
var m_Tooltip:TooltipInterface;
var m_EscapeNode:com.GameInterface.EscapeStackNode = undefined;

var m_BlinkAmount:Number;
var m_ClockShowRealTime:Boolean;
var m_AnimateDownload:Boolean;

var m_UpdateInterval:Number;

//On Load
function onLoad()
{
    m_Character = Character.GetClientCharacter();
    
    //Create Distributed Values
    m_CharacterSheetMonitor 		= DistributedValue.Create("character_sheet");
    m_AnimaWheelMonitor 			= DistributedValue.Create("skillhive_window");
    m_CharacterSkillPointsMonitor	= DistributedValue.Create("character_points_gui");
	m_InventoryMonitor 				= DistributedValue.Create("inventory_visible");
    m_JournalMonitor 				= DistributedValue.Create("mission_journal_window");
    m_PvPMonitor 					= DistributedValue.Create("pvp_minigame_window");
    m_AchievementMonitor 		    = DistributedValue.Create("achievement_lore_window");
    m_HelpMonitor 					= DistributedValue.Create("tutorial_window");
    m_CraftingMonitor               = DistributedValue.Create("CraftingWindow");
    m_PetitionMonitor               = DistributedValue.Create("petition_browser");
    m_CabalMonitor                  = DistributedValue.Create("guild_window");
    m_FriendsMonitor                = DistributedValue.Create("friends_window");
    m_LFGMonitor                    = DistributedValue.Create("group_search_window");
    m_ItemShopMonitor               = DistributedValue.Create("itemshop_window");
    m_ClaimMonitor                  = DistributedValue.Create("claim_window");
    m_BrowserMonitor                = DistributedValue.Create("web_browser");
    m_LeaderboardsMonitor           = DistributedValue.Create("leaderboards_browser");
    
    m_ResolutionScaleMonitor        = DistributedValue.Create("GUIResolutionScale");
	
	m_ClockShowRealTimeMonitor		= DistributedValue.Create("ClockShowRealTime");
	
    m_ServerFramerate = 0;
    m_ClientFramerate = 0;
    m_Latency = 0;
    m_Tooltip = undefined;
    
    //Signal Listeners
    m_CharacterSheetMonitor.SignalChanged.Connect(SlotCharacterSheetState, this);
    m_AnimaWheelMonitor.SignalChanged.Connect(SlotAnimaWheelState, this);
	m_CharacterSkillPointsMonitor.SignalChanged.Connect(SlotCharacterSkillPoints, this);
    m_InventoryMonitor.SignalChanged.Connect(SlotInventoryState, this);
    m_JournalMonitor.SignalChanged.Connect(SlotJournalState, this);
	m_PvPMonitor.SignalChanged.Connect(SlotPvPState, this);
	m_HelpMonitor.SignalChanged.Connect(SlotHelpState, this);
    m_AchievementMonitor.SignalChanged.Connect(SlotAchievementState, this);
    m_CraftingMonitor.SignalChanged.Connect(SlotCraftingState, this);
    m_PetitionMonitor.SignalChanged.Connect(SlotPetitionState, this);
    m_CabalMonitor.SignalChanged.Connect(SlotCabalState, this);
    m_FriendsMonitor.SignalChanged.Connect(SlotFriendsState, this);
    m_LFGMonitor.SignalChanged.Connect(SlotLookingForGroupState, this);
    m_ItemShopMonitor.SignalChanged.Connect(SlotItemShopState, this);
    m_ClaimMonitor.SignalChanged.Connect(SlotClaimState, this);
    m_BrowserMonitor.SignalChanged.Connect(SlotBrowserState, this);
    m_LeaderboardsMonitor.SignalChanged.Connect(SlotLeaderboardsState, this);
    
    m_ResolutionScaleMonitor.SignalChanged.Connect(Layout, this);
	
	m_ClockShowRealTimeMonitor.SignalChanged.Connect(SlotClockTypeChanged, this);
    
    m_MenuIconContainer = createEmptyMovieClip("m_MenuIconContainer", getNextHighestDepth());
    m_InvisibleButton.swapDepths(m_MenuIconContainer);
    m_MenuIcon = m_MenuIconContainer.attachMovie("MenuIcon", "m_MenuIcon", m_MenuIconContainer.getNextHighestDepth());
    m_MenuIconContainer._x = ICON_MARGIN;
    
    var label:TextField = m_MenuIconContainer.createTextField("m_Label", m_MenuIconContainer.getNextHighestDepth(), 17, ICON_LABEL_Y, 0, 0);
    label.autoSize = "left";
    label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
    label.text = LDBFormat.LDBGetText("GenericGUI", "MainMenu_Menu");
    
    m_ClockIconContainer = createEmptyMovieClip("m_ClockIconContainer", getNextHighestDepth());
    m_ClockIcon = m_ClockIconContainer.attachMovie("ClockIcon", "m_ClockIcon", m_ClockIconContainer.getNextHighestDepth());
	m_ClockIconContainer.onPress = Delegate.create(this, SlotToggleClockType);
    
    label = m_ClockIconContainer.createTextField("m_Label", m_ClockIconContainer.getNextHighestDepth(), 14, ICON_LABEL_Y, 0, 0);
    label.autoSize = "left";
    label.setNewTextFormat(new TextFormat(STANDARD_FONT, FONT_SIZE, COLOR, true));
    label.text = "00:00"
	
	TooltipUtils.AddTextTooltip(m_ClockIconContainer, LDBFormat.LDBGetText("GenericGUI", "MainMenuClockTooltip"), 160, TooltipInterface.e_OrientationHorizontal,  true);
	
	SlotClockTypeChanged();
    
    m_FPSIconContainer = createEmptyMovieClip("m_FPSIconContainer", getNextHighestDepth());
    m_FPSIcon = m_FPSIconContainer.attachMovie("LatencyIcon", "m_FPSIcon", m_FPSIconContainer.getNextHighestDepth());
    
    m_FPSIconContainer.onPress = function() { };
    m_FPSIconContainer.onRollOver = Delegate.create(this, SlotRollOverLatency);
    m_FPSIconContainer.onRollOut = m_FPSIconContainer.onDragOut = Delegate.create(this, SlotRollOutIcon);
    
    m_MailIconContainer = createEmptyMovieClip("m_MailIconContainer", getNextHighestDepth());
    m_MailIcon = m_MailIconContainer.attachMovie("MailIcon", "m_MailIcon", m_MailIconContainer.getNextHighestDepth());
    m_MailIconContainer.onPress = function() { if(this.enabled) DistributedValue.SetDValue("show_mail_tab", true); };
    m_MailIconContainer.onRollOver = Delegate.create(this, SlotRollOverMail);
    m_MailIconContainer.onRollOut = m_MailIconContainer.onDragOut = Delegate.create(this, SlotRollOutIcon);

    m_MailIconContainer._alpha = (Tradepost.HasUnreadMail()) ? 100 : 0;
    m_MailIcon.enabled = (Tradepost.HasUnreadMail()) ? true : false;

    Tradepost.SignalAllMailRead.Connect(SlotAllMailReadNotification, this);
    Tradepost.SignalNewMailNotification.Connect(SlotNewMailNotification, this);
    
    m_BlinkAmount = MAX_BLINK_AMOUNT;
    
    m_DownloadingIconContainer = createEmptyMovieClip("m_DownloadingIconContainer", getNextHighestDepth());
    m_DownloadingIcon = m_DownloadingIconContainer.attachMovie("DownloadingIcon", "m_DownloadingIcon", m_DownloadingIconContainer.getNextHighestDepth());
    m_DownloadingIconContainer.onRollOver = Delegate.create(this, SlotRollOverDownloading);
    m_DownloadingIconContainer.onRollOut = m_DownloadingIconContainer.onDragOut = Delegate.create(this, SlotRollOutIcon);
    m_DownloadingIcon._visible = false;
    
    Layout();
    
    UpdateMainMenuItems();
    
	m_PvPQueueMarker._visible = false;
    m_ButtonsBackground._visible = false;
    m_IsMenuOpen = false;
    
    m_UpdateInterval = setInterval(SlotUpdateInterval, 1000);
    
    ClientServerPerfTracker.SignalLatencyUpdated.Connect(SlotLatencyUpdated, this);
    ClientServerPerfTracker.SignalServerFramerateUpdated.Connect(SlotServerFramerateUpdated, this);
    ClientServerPerfTracker.SignalClientFramerateUpdated.Connect(SlotClientFramerateUpdated, this);
    
    SlotLatencyUpdated(ClientServerPerfTracker.GetLatency());
    SlotClientFramerateUpdated(ClientServerPerfTracker.GetClientFramerate());
    SlotServerFramerateUpdated(ClientServerPerfTracker.GetServerFramerate());
}

//On Unload
function onUnload():Void
{
    clearInterval(m_UpdateInterval);
}

//Update Main Menu Items
function UpdateMainMenuItems():Void
{
    MainMenuToggleMouseListeners(true);

    m_MenuItems = new Array();

    m_InvisibleButton._alpha = 0;
    m_InvisibleButton.onRelease = Delegate.create(this, MainMenuReleaseEventHandler);
    m_InvisibleButton.disableFocus = true;
    
    var allowedToReceiveItems:Boolean = m_Character.CanReceiveItems();
    
    SetupMenuItem(m_CharacterSheetButton, "character_sheet", "CharacterSheetHandler", m_TDB_CharacterSheet + " (<variable name='hotkey:Toggle_SP_Character'/ >)");
    SetupMenuItem(m_AnimaWheelButton, "skillhive_window", "AnimaWheelHandler", m_TDB_AbilityWheel + " (<variable name='hotkey:Toggle_SkillHive'/ >)");
    SetupMenuItem(m_CharacterSkillPointsButton, "character_points_gui", "CharacterSkillPointsHandler", m_TDB_CharacterSkillPoints + " (<variable name='hotkey:Toggle_CharacterPoints'/ >)");
    SetupMenuItem(m_InventoryButton, "inventory_visible", "InventoryHandler", m_TDB_Inventory + " (<variable name='hotkey:Toggle_InventoryView'/ >)");
    SetupMenuItem(m_JournalButton, "mission_journal_window", "JournalHandler", m_TDB_Journal + " (<variable name='hotkey:Toggle_MissionJournalWindow'/ >)");
    SetupMenuItem(m_PvPButton, "pvp_minigame_window", "PvPHandler", m_TDB_PvP + " (<variable name='hotkey:Toggle_PvPStatWindow'/ >)");
    SetupMenuItem(m_AchievementButton, "achievement_lore_window", "AchievementHandler", m_TDB_Achievement + " (<variable name='hotkey:Toggle_AchievementWindow'/ >)");
    SetupMenuItem(m_CraftingButton, "CraftingWindow", "CraftingHandler", m_TDB_Crafting + " (<variable name='hotkey:Toggle_CraftingWindow'/ >)");
    SetupMenuItem(m_FriendsButton, "friends_window", "FriendsHandler", m_TDB_Friends + " (<variable name='hotkey:Toggle_FriendsView'/ >)");
    SetupMenuItem(m_LFGButton, "group_search_window", "LFGHandler", m_TDB_LFG + " (<variable name='hotkey:Toggle_GroupSearchWindow'/ >)");
    SetupMenuItem(m_CabalButton, "guild_window", "CabalHandler", m_TDB_Cabal + " (<variable name='hotkey:Toggle_GuildWindow'/ >)");
    
    if ( allowedToReceiveItems )
    {
        SetupMenuItem(m_ClaimButton, "claim_window", "ClaimHandler", m_TDB_Claim);
    }
    
    SetupMenuItem(m_BrowserButton, "web_browser", "BrowserHandler", m_TDB_WebBrowser + " (<variable name='hotkey:Toggle_Browser'/ >)");
    SetupMenuItem(m_HelpButton, "petition_browser", "PetitionHandler", m_TDB_Help);
    
    SetupMenuItem(m_ShopButton, "itemshop_window", "ShopHandler", m_TDB_Shop + " (<variable name='hotkey:Toggle_ItemShop'/ >)", allowedToReceiveItems, m_TDB_Shop_DisabledTooltip);
    
    var enableChronicle:Number = com.GameInterface.Utils.GetGameTweak("GUIEnableChronicle");
    if (enableChronicle != 0) 
    {
        SetupMenuItem(m_LeaderboardsButton, "leaderboards_browser", "LeaderboardsHandler", m_TDB_Leaderboards + " (<variable name='hotkey:Toggle_Leaderboards'/ >)");
    }

    SetupMenuItem(m_SettingsButton, null, "SettingsHandler", m_TDB_Settings + " (<variable name='hotkey:Toggle_Options'/ >)");
    SetupMenuItem(m_ExitButton, null, "ExitHandler", m_TDB_Exit);
}

//Setup Menu Item
function SetupMenuItem(item:MovieClip, distributedValue:String, eventHandler:String, label:String, enable:Boolean, disabledTooltip:String):Void
{
	if (enable == undefined)
	{
		enable = true;
	}
	
    if (distributedValue)
    {
        SetDotState(item, DistributedValue.GetDValue(distributedValue));
    }
    
    item.m_TextField.text = label;
	item.disableFocus = true;
	
	if (enable)
	{
		item.addEventListener("click", this, eventHandler);
	}
	else
	{
		if (disabledTooltip != undefined)
		{
			// explain why the item is disabled
			TooltipUtils.AddTextTooltip(item, disabledTooltip);
		}
		item.m_TextField.textColor = 0xAAAAAA;
		item.disabled = true;
	}
    
	m_MenuItems.push(item);
}

//Layout
function Layout():Void
{
    var fullScreenWidth = Stage["visibleRect"].width;
    m_BackgroundBar._x = 0;
    m_BackgroundBar._width = fullScreenWidth;
        
    var baseSize:Number = m_BackgroundBar._height;
    
    m_MenuIcon._xscale = m_MenuIcon._yscale = baseSize * 0.70;
    m_InvisibleButton._x = m_InvisibleButton._y = 0;
    m_InvisibleButton._height = m_BackgroundBar._height;
    m_InvisibleButton._width = m_MenuIconContainer._width + ICON_MARGIN;
    m_MenuIcon._y = 4;

    m_ClockIcon._xscale = m_ClockIcon._yscale = baseSize * 0.65;
    m_ClockIconContainer._x = m_BackgroundBar._width - m_ClockIconContainer._width - ICON_MARGIN;
    m_ClockIcon._y = 4;

    m_FPSIcon._xscale = m_FPSIcon._yscale = baseSize * 0.65;
    m_FPSIconContainer._x = m_ClockIconContainer._x - m_FPSIconContainer._width - 12;
    m_FPSIcon._y = 5;
    
    m_MailIcon._xscale = m_MailIcon._yscale  = baseSize * 0.65;
    m_MailIconContainer._x = m_FPSIconContainer._x - m_MailIconContainer._width - 12;
    m_MailIcon._y = 5;

    m_DownloadingIcon._xscale = m_DownloadingIcon._yscale  = baseSize * 0.65;
    m_DownloadingIconContainer._x = (m_MailIcon.enabled) ? m_MailIconContainer._x - m_DownloadingIconContainer._width - 6 : m_FPSIconContainer._x - m_DownloadingIconContainer._width - 6;
    m_DownloadingIcon._y = 9;
}

//Main Menu Toggle Mouse Listeners
function MainMenuToggleMouseListeners(enabled:Boolean):Void
{
    if (enabled)
    {
        m_InvisibleButton.onRollOver = function() {Colors.ApplyColor(m_MenuIconContainer.m_MenuIcon, 0xFFFFFF)};
        m_InvisibleButton.onRollOut = m_InvisibleButton.onReleaseOutside = function() {Colors.ApplyColor(m_MenuIconContainer.m_MenuIcon, COLOR)};  
    }
    else
    {
        m_InvisibleButton.onRollOver = null;
        m_InvisibleButton.onRollOut = m_InvisibleButton.onReleaseOutside = null;
    }
}

//Slot Roll Over Latency
function SlotRollOverLatency()
{
    if (m_Character != undefined && m_Character.GetStat(_global.Enums.Stat.e_GmLevel) != 0) 
    {
        if (m_Tooltip != undefined)
        {
            m_Tooltip.Close();
        }
        
        var tooltipData:TooltipData = new TooltipData();
        tooltipData.m_Descriptions.push(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "MainMenu_LatencyTooltip"), Math.floor(m_Latency * 1000)));
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 100;
        
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
    }
}

//Slot Roll Over Mail
function SlotRollOverMail()
{
    if (m_Tooltip != undefined)
    {
        m_Tooltip.Close();
    }

    if (m_MailIcon.enabled)
    {
        var tooltipData:TooltipData = new TooltipData();
        tooltipData.AddAttribute("", LDBFormat.LDBGetText("GenericGUI", "MainMenu_MailTooltipTitle"));
        tooltipData.AddAttributeSplitter();
        tooltipData.AddAttribute("", LDBFormat.LDBGetText("GenericGUI", "MainMenu_MailTooltip"));
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 160;
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
    }
}

//Slot Roll Over Downloading
function SlotRollOverDownloading()
{
    if (m_Tooltip != undefined)
    {
        m_Tooltip.Close();
    }

    if (m_DownloadingIcon.enabled)
    {
        var t:Number = ClientServerPerfTracker.GetDownloadSecondsRemaining();
        var tooltipData:TooltipData = new TooltipData();
        tooltipData.m_Descriptions.push(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "MainMenu_DownloadingTooltip"), Math.floor(t / 3600), Math.floor((t / 3600) / 60), Math.floor((t / 3600) % (60)))); //Download Time Remaining: %d:$d:%d
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 160;
        
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
    }
}

//Slot Roll Out Icon
function SlotRollOutIcon()
{
    if (m_Tooltip != undefined)
    {
        m_Tooltip.Close();
    }
}

//Slot Update Interval
function SlotUpdateInterval():Void
{
    DownloadContent(ClientServerPerfTracker.GetTotalRemainingDownloads() != 0);
    
    var timeOfDay:Number;
    var hours:Number = 0;
    var minutes:Number = 0;
    
	if (m_ClockShowRealTime)
	{
        m_CurrentDate = new Date();
        
		hours = m_CurrentDate.getHours();
		minutes = m_CurrentDate.getMinutes();
	}
	else
	{
		timeOfDay = com.GameInterface.Utils.GetTimeOfDay();        
        hours = Math.floor(timeOfDay / 60 / 60);
        minutes = Math.floor(timeOfDay / 60 % 60);
	}
    
    m_ClockIconContainer.m_Label.text = com.Utils.Format.Printf("%02d:%02d", hours ,minutes);
}

//Slot Latency Update
function SlotLatencyUpdated(latency:Number):Void
{
    m_Latency = latency;
    m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = false;
    m_FPSIconContainer.m_FPSIcon.m_LatencyBar2._visible = false;
    m_FPSIconContainer.m_FPSIcon.m_LatencyBar3._visible = false;
    m_FPSIconContainer.m_FPSIcon.m_LatencyBar4._visible = false;
    
    if (m_Latency < 0.05)
    {
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar2._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar3._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar4._visible = true;
    }
    else if (m_Latency < 0.15)
    {
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar2._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar3._visible = true;
    }
    else if (m_Latency < 0.5)
    {
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = true;
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar2._visible = true;
    }
    else
    {
        m_FPSIconContainer.m_FPSIcon.m_LatencyBar1._visible = true;
    }
}

//Slot Server Framerate Update
function SlotServerFramerateUpdated(framerate:Number):Void
{
    m_ServerFramerate = framerate;
}

//Slot Client Framerate Update
function SlotClientFramerateUpdated(framerate:Number):Void
{
    m_ClientFramerate = framerate;
}

//Slot New Mail notification
function SlotNewMailNotification():Void
{
    if (m_MailIconContainer != undefined)
    {
        BlinkMailIcon();
    
        m_Character.AddEffectPackage(RECEIVE_MAIL_SOUND_EFFECT);

        m_MailIcon.enabled = true;
        
        Layout();
    }
}

//Slot Mail Read Notification
function SlotAllMailReadNotification():Void
{
    if (m_MailIconContainer != undefined)
    {
        m_BlinkAmount = MAX_BLINK_AMOUNT;
        
        m_MailIconContainer.tweenTo(BLINK_ANIMATION_DURATION, { _alpha: 0 }, None.easeNone);
        m_MailIconContainer.onTweenComplete = undefined;
        
        m_MailIcon.enabled = false;
        
        Layout();
    }
}

//Blink Mail Icon
function BlinkMailIcon():Void
{
    m_MailIconContainer.tweenTo(BLINK_ANIMATION_DURATION, { _alpha: 100 }, None.easeNone);
    
    if (m_BlinkAmount > 0)
    {
        m_BlinkAmount--;
        m_MailIconContainer.onTweenComplete = BlinkMailIconCallback;
    }
    else
    {
        m_BlinkAmount = MAX_BLINK_AMOUNT;
        m_MailIconContainer.onTweenComplete = undefined;
    }
}

//Blink Mail Notification
function BlinkMailIconCallback():Void
{
    m_MailIconContainer.tweenTo(BLINK_ANIMATION_DURATION, { _alpha: 0 }, None.easeNone);
    m_MailIconContainer.onTweenComplete = BlinkMailIcon;
}

//Download Content
function DownloadContent(contentAvaliable:Boolean):Void
{
    if (m_DownloadingIconContainer != undefined)
    {
        m_DownloadingIcon._visible = contentAvaliable;
        m_AnimateDownload = contentAvaliable;
        
        AnimateDownloadingIcon();
    }
}

//Animate Downloading Icon
function AnimateDownloadingIcon():Void
{
    if (m_AnimateDownload)
    {
        m_DownloadingIcon.tweenTo(1.0, {_rotation: 360}, None.easeNone);
        m_DownloadingIcon.onTweenComplete = CheckDownloadingProgress;
    }
    else
    {
        m_DownloadingIcon.onTweenComplete = undefined;
    }
}

//Check Downloading Progress
function CheckDownloadingProgress():Void
{
    if (ClientServerPerfTracker.GetTotalRemainingDownloads() <= 0)
    {
        m_AnimateDownload = false;
    }
    
    DownloadContent(m_AnimateDownload);
}

//Set Dot State
function SetDotState(button:MovieClip, isOpen:Boolean)
{
	var label:String = (isOpen ? "open" : "close");
    button.i_OnOff.gotoAndStop(label);
}

//Main Menu Release Event Handler
function MainMenuReleaseEventHandler():Void
{
    if (m_IsMenuOpen)
    {
        m_IsMenuOpen = false;
		
        for (var i:Number = 0; i < m_MenuItems.length; i++)
		{
			var menuItem:MovieClip = m_MenuItems[i];

			menuItem.tweenTo(ANIMATION_DURATION, { _alpha: 0, _y: 0 }, None.easeNone);
			menuItem.onTweenComplete = function()
			{
				this._visible = false;
			}
		}
        
		m_ButtonsBackground.tweenTo(ANIMATION_DURATION, { _yscale: 0 }, None.easeNone);
		m_ButtonsBackground.onTweenComplete = function()
		{
			this._visible = false;
            Colors.ApplyColor(m_MenuIconContainer.m_MenuIcon, COLOR);
            MainMenuToggleMouseListeners(true);
		}
        if ( m_EscapeNode != undefined )
        {
            m_EscapeNode.SignalEscapePressed.Disconnect( RemoveMenu, this );
            m_EscapeNode = undefined;
        }
    }
    else
    {
        UpdateMainMenuItems();
        
        m_EscapeNode = new com.GameInterface.EscapeStackNode;
        m_EscapeNode.SignalEscapePressed.Connect( SlotEscapePressed, this );
        com.GameInterface.EscapeStack.Push( m_EscapeNode );
        
        MainMenuToggleMouseListeners(false);
        Colors.ApplyColor(m_MenuIconContainer.m_MenuIcon, 0xFFFFFF);
		
        m_IsMenuOpen = true;
        
		var yPos:Number = STARTING_Y_POSITION;
		
        for (var i:Number = 0; i < m_MenuItems.length; i++)
		{
			var menuItem:MovieClip = m_MenuItems[i];
			menuItem._visible = true;
			menuItem._alpha = 0;
			menuItem.tweenTo(ANIMATION_DURATION, { _alpha: 100, _y:yPos }, None.easeNone);
			menuItem.onTweenComplete = undefined;
			yPos += menuItem._height
		}
		
        m_ButtonsBackground._visible = true;
		m_ButtonsBackground._yscale = 0;
		m_ButtonsBackground.tweenTo(ANIMATION_DURATION, { _yscale: yPos + STARTING_Y_POSITION - m_BackgroundBar._height}, None.easeNone);
		m_ButtonsBackground.onTweenComplete = undefined;
    }
}

function SlotEscapePressed()
{
    if ( m_IsMenuOpen )
    {
        MainMenuReleaseEventHandler();
    }
}

//Character Sheet Handler
function CharacterSheetHandler():Void
{
	DistributedValue.SetDValue("character_sheet",!DistributedValue.GetDValue("character_sheet") );
	MainMenuReleaseEventHandler();
}

//Anima Wheel Handler
function AnimaWheelHandler():Void
{
	DistributedValue.SetDValue("skillhive_window", !DistributedValue.GetDValue("skillhive_window"));
	MainMenuReleaseEventHandler();
}

//Character Skill Points Handler
function CharacterSkillPointsHandler():Void
{
	DistributedValue.SetDValue("character_points_gui", !DistributedValue.GetDValue("character_points_gui"));
	DistributedValue.SetDValue("skillhive_window", !DistributedValue.GetDValue("skillhive_window"));
	MainMenuReleaseEventHandler();
}

//Journal Handler
function JournalHandler():Void
{
	DistributedValue.SetDValue("mission_journal_window", !DistributedValue.GetDValue("mission_journal_window"));
	MainMenuReleaseEventHandler();
}

//PvP Handler
function PvPHandler():Void
{
	DistributedValue.SetDValue("pvp_minigame_window", !DistributedValue.GetDValue("pvp_minigame_window"));
	MainMenuReleaseEventHandler();
}

//Achievements Handler
function AchievementHandler():Void
{
	DistributedValue.SetDValue("achievement_lore_window", !DistributedValue.GetDValue("achievement_lore_window"));
	MainMenuReleaseEventHandler();
}

//Help Handler
function HelpHandler():Void
{
	DistributedValue.SetDValue("tutorial_window", !DistributedValue.GetDValue("tutorial_window"));
	MainMenuReleaseEventHandler();
}

//Browser Handler
function BrowserHandler():Void
{
	DistributedValue.SetDValue("web_browser", !DistributedValue.GetDValue("web_browser"));
	MainMenuReleaseEventHandler();
}

//Petition Handler
function PetitionHandler():Void
{
	DistributedValue.SetDValue("petition_browser", !DistributedValue.GetDValue("petition_browser"));
	MainMenuReleaseEventHandler();
}

//Crafting Handler
function CraftingHandler():Void
{
	DistributedValue.SetDValue("CraftingWindow", !DistributedValue.GetDValue("CraftingWindow"));
	MainMenuReleaseEventHandler();
}

//Friends Handler
function FriendsHandler():Void
{
    DistributedValue.SetDValue("friends_window", !DistributedValue.GetDValue("friends_window"));
    MainMenuReleaseEventHandler();
}

function LFGHandler():Void
{
    DistributedValue.SetDValue("group_search_window", !DistributedValue.GetDValue("group_search_window"));
    MainMenuReleaseEventHandler();
}

//Cabal Handler
function CabalHandler():Void
{
	DistributedValue.SetDValue("guild_window", !DistributedValue.GetDValue("guild_window"));
	MainMenuReleaseEventHandler();
}

//Claim Handler
function ClaimHandler():Void
{
    DistributedValue.SetDValue("claim_window", !DistributedValue.GetDValue("claim_window"));
	MainMenuReleaseEventHandler();
}

//Inventory Handler
function InventoryHandler():Void
{
	DistributedValue.SetDValue("inventory_visible", !DistributedValue.GetDValue("inventory_visible"));
	MainMenuReleaseEventHandler();
}

//Shop handler
function ShopHandler():Void
{
    DistributedValue.SetDValue("itemshop_window", !DistributedValue.GetDValue("itemshop_window"));
	MainMenuReleaseEventHandler();
}

//Leaderboards Handler
function LeaderboardsHandler():Void
{
    DistributedValue.SetDValue("leaderboards_browser", !DistributedValue.GetDValue("leaderboards_browser"));
	MainMenuReleaseEventHandler();
}

//Settings Handler
function SettingsHandler():Void
{
    DistributedValue.SetDValue("mainmenu_window", true);
    MainMenuReleaseEventHandler();
}

//Exit Handler
function ExitHandler():Void
{
    com.GameInterface.ProjectUtils.StartQuitGame();
}

//Slot Character Sheet State
function SlotCharacterSheetState():Void
{
	var isOpen = DistributedValue.GetDValue("character_sheet")
	SetDotState(m_CharacterSheetButton, isOpen);
}

//Slot Anima Wheel State
function SlotAnimaWheelState():Void
{
	var isOpen = DistributedValue.GetDValue("skillhive_window")
 	SetDotState(m_AnimaWheelButton, isOpen);
}

//Slot Character Skill Points State
function SlotCharacterSkillPointsState():Void
{
	var isOpen = DistributedValue.GetDValue("character_points_gui")
 	SetDotState(m_CharacterSkillPointsButton, isOpen);
}

//Slot Inventory State
function SlotInventoryState():Void
{
	var isOpen = DistributedValue.GetDValue("inventory_visible")
	SetDotState(m_InventoryButton, isOpen);
}

//Slot Journal State
function SlotJournalState():Void
{
	var isOpen = DistributedValue.GetDValue("mission_journal_window")
    SetDotState(m_JournalButton, isOpen);
}

//Slot PvP State
function SlotPvPState():Void
{
	var isOpen = DistributedValue.GetDValue("pvp_minigame_window");
	SetDotState(m_PvPButton, isOpen);	
}

//Slot Achievement State
function SlotHelpState():Void
{
	var isOpen = DistributedValue.GetDValue("tutorial_window");
	SetDotState(m_HelpButton, isOpen);	
}

//Slot Crafting State
function SlotCraftingState():Void
{
	var isOpen = DistributedValue.GetDValue("CraftingWindow");
	SetDotState(m_CraftingButton, isOpen);	
}

//Slot Friends State
function SlotFriendsState():Void
{
    var isOpen = DistributedValue.GetDValue("friends_window");
    SetDotState(m_FriendsButton, isOpen);
}

//Slot LFG State
function SlotLookingForGroupState():Void
{
    var isOpen = DistributedValue.GetDValue("group_search_window");
    SetDotState(m_LFGButton, isOpen);
}

//Slot Item Shop State
function SlotItemShopState():Void
{
    var isOpen = DistributedValue.GetDValue("itemshop_window");
    SetDotState(m_ShopButton, isOpen);   
}

//Slot Cabal State
function SlotCabalState():Void
{
	var isOpen = DistributedValue.GetDValue("guild_window");
	SetDotState(m_CabalButton, isOpen);	
}

//Slot Petition State
function SlotPetitionState():Void
{
	var isOpen = DistributedValue.GetDValue("petition_browser");
	SetDotState(m_PetitionButton, isOpen);	
}

//Slot Help State
function SlotAchievementState():Void
{
	var isOpen = DistributedValue.GetDValue("achievement_lore_window");
	SetDotState(m_AchievementButton, isOpen);	
}

//Slot Claim State
function SlotClaimState():Void
{
	var isOpen = DistributedValue.GetDValue("claim_window");
	SetDotState(m_ClaimButton, isOpen);
}

//Slot Browser State
function SlotBrowserState():Void
{
	var isOpen = DistributedValue.GetDValue("web_browser");
	SetDotState(m_BrowserButton, isOpen);	
}

//Slot Leaderboards State
function SlotLeaderboardsState():Void
{
	var isOpen = DistributedValue.GetDValue("leaderboards_browser");
	SetDotState(m_LeaderboardsButton, isOpen);	
}


function SlotToggleClockType() : Void
{
	m_ClockShowRealTimeMonitor.SetValue(!m_ClockShowRealTime);
}

function SlotClockTypeChanged()
{
	m_ClockShowRealTime = m_ClockShowRealTimeMonitor.GetValue();
    
	m_ClockIconContainer.m_Label.textColor = (m_ClockShowRealTime) ? 0xAAFFAA : 0xFFFFFF;
    
	SlotUpdateInterval();
}