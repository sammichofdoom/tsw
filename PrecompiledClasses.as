import com.GameInterface.*;
import com.Utils.HUDController;
import com.Utils.Draw;

trace("Actionscript GamecodeInterface loaded. ");

// Movieclip prototype for generating a session unique id. Usefull for giving a moviclip a unique name.
_global.m_UID = 0;
MovieClip.prototype.UID = function() : Number
{
  return _global.m_UID++;
}

var hudController:HUDController = new HUDController;
gfx.managers.DragManager.instance.addEventListener( "dragEnd", com.Utils.DragObject, "onDragEnd" );

var dragObject = new com.Utils.DragObject();
dragObject.DragHandled();

///Workaround to make masks not flicker... Not sure why it works...
var m_Window = this.createEmptyMovieClip("m_Window", this.getNextHighestDepth());
var m_Background = m_Window.createEmptyMovieClip("m_Background", m_Window.getNextHighestDepth());
Draw.DrawRectangle(m_Background, 0, 0, 5, 5, 0xFFFF00, 0);
var mask = ProjectUtils.SetMovieClipMask(m_Background, m_Window, 5, 5, false);
ResizeHandler()

function ResizeHandler()
{
	m_Window._x = Stage["visibleRect"].x;
	m_Window._y = Stage["visibleRect"].y;
}

return;

// Make the part of the .swf
var dummy;


dummy = new com.Utils.Signal();
dummy = new com.Utils.Slot();
dummy = new com.Utils.GlobalSignal();
dummy = new com.GameInterface.Game.Camera();
dummy = new com.GameInterface.Game.Shortcut();
dummy = new com.GameInterface.Targeting();
dummy = new com.GameInterface.Quests();
dummy = new com.GameInterface.Game.Shortcut();
dummy = new com.GameInterface.Dynels();
//dummy = new com.GameInterface.Command(); (Gives a "Unknown baseclass" error)
dummy = new com.GameInterface.Input();
dummy = new com.GameInterface.Spell();
dummy = new com.GameInterface.ProjectSpell();
dummy = new com.GameInterface.SpellData();
dummy = new com.GameInterface.ProjectFeatInterface(); 
dummy = new com.GameInterface.SkillWheel.SkillWheel(); 
dummy = new com.GameInterface.FeatData();
dummy = new com.GameInterface.Waypoint();
dummy = new com.GameInterface.WaypointInterface();
dummy = new com.GameInterface.Skills();
dummy = new com.GameInterface.InventoryBase();
dummy = new com.GameInterface.Inventory();
dummy = new com.GameInterface.InventoryItem;
dummy = new com.GameInterface.ACGItem;
dummy = new com.GameInterface.GearDataAbility;
dummy = new com.GameInterface.GearDataItem;
dummy = new com.GameInterface.GearData;
dummy = new com.GameInterface.GearManager;
dummy = new com.GameInterface.CharacterPointRowData;
dummy = new com.GameInterface.EscapeStack(); 
dummy = new com.GameInterface.EscapeStackNode();
dummy = new com.GameInterface.DialogueBase();
dummy = new com.Components.ItemSlot();
dummy = com.Components.HealthBar;
dummy = com.Components.WindowComponent;
dummy = new com.GameInterface.Game.Character.GetClientCharacter();
dummy = new com.GameInterface.Utils();
dummy = new com.GameInterface.Log();
dummy = GUI.Debug.Debug;
dummy = com.Components.ListHeader;
dummy = GUI.HUD.AbilityCooldown;
dummy = GUI.HUD.ActiveAbility;
dummy = GUI.HUD.AbilityBase;
dummy = GUI.HUD.PassiveAbility;
dummy = GUI.HUD.AbilitySlot;
dummy = GUI.HUD.ActiveAbilitySlot;
dummy = com.GameInterface.DistributedValue.Create("");
dummy = com.GameInterface.GUIModuleIF.FindModuleIF("");
dummy = new com.Utils.ID32();
dummy = new com.Utils.StringUtils();
dummy = new com.GameInterface.Chat();
dummy = new com.GameInterface.Guild.GuildBase;
dummy = com.GameInterface.Guild.GuildPermission;
dummy = com.GameInterface.Guild.GuildFeat;
dummy = com.GameInterface.Guild.GuildRank;
dummy = com.GameInterface.Guild.GuildRankingEntry;
dummy = com.GameInterface.Guild.GuildMember;
dummy = com.GameInterface.Guild.GuildMemberRenownStatus;
dummy = com.GameInterface.Guild.GuildRankingEntry;
dummy = com.GameInterface.Guild.GuildRenownHistoryEntry;
dummy = com.GameInterface.Guild.GuildRenownStatus;
dummy = com.Components.WeaponResources.WeaponResourcePoint;
dummy = com.Components.WeaponResources.WeaponResourceBar;
dummy = com.Components.ResourceBase;
dummy = new com.GameInterface.ShopInterface();
dummy = new com.GameInterface.AccountManagement();
dummy = new com.GameInterface.Resource;
dummy = new com.GameInterface.Game.TeamInterface;
dummy = new com.GameInterface.Game.Team;
dummy = new com.GameInterface.Game.Raid;
dummy = new com.GameInterface.Game.TargetingInterface;
dummy = new com.GameInterface.Game.BuffData;
dummy = new com.GameInterface.Tooltip.Tooltip();
dummy = new com.GameInterface.Tooltip.TooltipManager();
dummy = new com.GameInterface.Tooltip.TooltipUtils();
dummy = new com.GameInterface.Tooltip.TooltipData();
dummy = new com.Utils.Destructor();
dummy = new com.Utils.Draw();
dummy = com.Utils.Faction;
dummy = new com.GameInterface.ProjectUtils();
dummy = new com.GameInterface.DialogIF();
dummy = new GUI.Mission.MissionUtils();
dummy = new GUI.Mission.MissionSignals();
dummy = new com.Utils.Colors();
dummy = com.Components.StatBar;
dummy = new com.Components.ItemComponent();
dummy = new com.Components.BuffComponent();
dummy = new com.Components.Numbers();
dummy = com.Components.CastBar;
dummy = com.Utils.Text;
dummy = new com.Utils.DragManager;
dummy = com.Components.NameBox;
dummy = com.Components.Resources;
dummy = com.Components.States;
dummy = com.Components.Buffs;
dummy = com.Components.SplitItemPopup;
dummy = new com.GameInterface.PvPMinigame.PvPMinigame();
dummy = new com.GameInterface.Puzzle;
dummy = new com.GameInterface.ComputerPuzzleIF;
dummy = new com.GameInterface.CraftingInterface;
dummy = new com.Components.MultiStateButton;
dummy = new com.Components.FCButton;
dummy = new com.Components.FCSlider;
dummy = new com.GameInterface.PlayerDeath;
dummy = new com.GameInterface.NeedGreed;
dummy = new com.GameInterface.Nametags;
dummy = new com.GameInterface.Lore;
dummy = new com.GameInterface.LoreNode;
dummy = new com.GameInterface.RespawnPoint;
dummy = new com.Components.Window;
dummy = new com.Components.SearchBox;
dummy = new com.Components.VideoPlayer;
dummy = new com.Components.RightClickItem;
dummy = new com.Components.RightClickMenu;
dummy = new com.Components.RightClickItemRenderer;
dummy = new com.Components.WinComp;
dummy = new com.Components.WindowComponentContent;
dummy = new com.Components.SplitItemPopup;

dummy = new com.Components.MultiColumnListView;
dummy = new com.Components.MultiColumnList.ColumnData;
dummy = new com.Components.MultiColumnList.HeaderButton;

dummy = new com.Components.MultiColumnList.MCLBaseCellRenderer;
dummy = new com.Components.MultiColumnList.MCLTextCellRenderer;
dummy = new com.Components.MultiColumnList.MCLMovieClipCellRenderer;
dummy = new com.Components.MultiColumnList.MCLMovieClipAndTextCellRenderer;
dummy = new com.Components.MultiColumnList.MCLItem;
dummy = new com.Components.MultiColumnList.MCLItemDefault;
dummy = new com.Components.MultiColumnList.MCLItemRenderer;
dummy = new com.Components.MultiColumnList.MCLItemRendererDefault;
dummy = new com.Components.MultiColumnList.MCLItemValue;
dummy = new com.Components.MultiColumnList.MCLItemValueData;

dummy = new com.Components.InventoryItemList.MCLItemIconCellRenderer;
dummy = new com.Components.InventoryItemList.MCLItemPriceCellRenderer;
dummy = new com.Components.InventoryItemList.MCLItemInventoryItem;
dummy = new com.Components.InventoryItemList.MCLItemRendererInventoryItem;

dummy = new com.Components.FeatList.MCLItemFeat;
dummy = new com.Components.FeatList.MCLItemRendererFeat;
dummy = new com.Components.FeatList.MCLFeatCostCellRenderer;
dummy = new com.Components.FeatList.MCLFeatTypeCellRenderer;
dummy = new com.Components.FeatList.MCLFeatIconCellRenderer;

dummy = new gfx.controls.ButtonBar;
