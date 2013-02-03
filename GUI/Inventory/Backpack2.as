import com.Components.ItemComponent;
import com.Components.ItemSlot;
import com.Components.SplitItemPopup;
import com.GameInterface.DialogIF;
import com.GameInterface.DistributedValue;
import com.GameInterface.EscapeStackNode;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Loot;
import com.GameInterface.ProjectUtils;
import com.GameInterface.ShopInterface;
import com.GameInterface.Tradepost;
import com.Utils.Archive;
import com.Utils.DragObject;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.StringUtils;
import GUI.Inventory.IconBox;
import GUI.Inventory.ItemIconBox;
import GUI.Inventory.ShortcutsIconBox;
import GUIFramework.SFClipLoader;
import mx.utils.Delegate;
import flash.geom.Point;

var m_ModuleActivated:Boolean;

var STATE_NONE:Number = 0;
var STATE_DRAGGING_WINDOW:Number = 1;
var STATE_RESIZING_WINDOW:Number = 2;
var STATE_WRITING_NAME:Number = 3;
var DEFAULT_INVENTORY_WINDOW:Number = 0;
var SHORTCUTS_INVENTORY_WINDOW:Number = -1;

var m_HighestBoxDepth:Number = 0;

var m_DefaultInventoryBox:ItemIconBox;
var m_ShortcutsInventoryBox:ShortcutsIconBox;
var m_IconBoxes:Array;

var m_NextBoxId = 0;
var m_ActiveBox:IconBox;
var m_GlowingMergeBox:ItemIconBox;
var m_State:Number = STATE_NONE;
var m_MaxNumBoxes:Number = 20;

var m_Inventory:Inventory;
var m_InventoryVisible:Boolean;

var m_ChangeVisibliltyMonitor:DistributedValue;
var m_ScaleMonitor:DistributedValue;
var m_PinnedWindowsOpacityMonitor:DistributedValue;
var m_LockPositionWhenPinnedMonitor:DistributedValue;
var m_EnableShortcutsWindowMonitor:DistributedValue;
var m_RightClickVendorSale:DistributedValue;

var m_EnableRightClickVendorSale:Boolean;
var m_EscapeStackNode:EscapeStackNode;
var m_SlotToBoxBindings:Object;
var m_CurrentDialog:DialogIF;
var m_SaveConfigTimer:Number;
var m_SelectedItems:Array;
var m_DraggedItems:Array;
var m_ItemsToDelete:Array;
var m_SplitItemPopup:MovieClip;
var m_OpenShop:ShopInterface;


function onLoad()
{
    gfx.managers.DragManager.instance.addEventListener("dragBegin", this, "SlotDragBegin");
    gfx.managers.DragManager.instance.addEventListener("dragEnd", this, "SlotDragEnd");
    
    m_InventoryMaxItems = GetInventoryMaxItems();
    
    m_ModuleActivated = false;
    tabChildren = false;
    m_SaveConfigTimer = 0;
    
    m_ChangeVisibliltyMonitor = DistributedValue.Create("inventory_visible");
    m_ChangeVisibliltyMonitor.SignalChanged.Connect(UpdateVisibility, this);
	
	m_ScaleMonitor = DistributedValue.Create("GUIScaleInventory");
	m_ScaleMonitor.SignalChanged.Connect(SlotScaleChanged, this);
    
    m_PinnedWindowsOpacityMonitor = DistributedValue.Create("InventoryPinnedWindowOpacity");
    m_PinnedWindowsOpacityMonitor.SignalChanged.Connect(SlotPinnedWindowsOpacityChanged, this);
    
    m_LockPositionWhenPinnedMonitor = DistributedValue.Create("InventoryLockPositionWhenPinned");
    m_LockPositionWhenPinnedMonitor.SignalChanged.Connect(SlotLockPositionWhenPinnedChanged, this);
    
    m_EnableShortcutsWindowMonitor = DistributedValue.Create("InventoryEnableShortcutsWindow");
    m_EnableShortcutsWindowMonitor.SignalChanged.Connect(SlotEnableShortcutsWindowChanged, this);
    
    m_RightClickVendorSale = DistributedValue.Create("InventoryRightClickVendorSale");
    m_RightClickVendorSale.SignalChanged.Connect(SlotRightClickVendorSaleChanged, this); 
    
    SlotRightClickVendorSaleChanged();
    
    SFClipLoader.SignalDisplayResolutionChanged.Connect(Layout, this);
    
	var clientCharacter:Character = Character.GetClientCharacter();
	clientCharacter.SignalStatChanged.Connect(SlotCharacterStatChanged, this);
	
    var clientCharID:ID32 = Character.GetClientCharID();
    m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, clientCharID.GetInstance()));

    m_ItemsToDelete = new Array();
    m_SelectedItems = new Array();
    m_DraggedItems = new Array();
    m_IconBoxes = new Array();
    m_InventoryVisible = false;
    m_DefaultInventoryBox = CreateBox(5, 4, true, false, false, false);
    m_DefaultInventoryBox.SetPos(300, 75);
    m_DefaultInventoryBox.SignalNewButtonPressed.Connect(SlotNewPressed, this);
	m_DefaultInventoryBox.SignalCloseButtonPressed.Connect(SlotCloseInventory, this);
        
    m_ShortcutsInventoryBox = ShortcutsIconBox(CreateBox(1, ShortcutsIconBox.MAX_POCKET_SIZE, false, false, true));
    var shortcutsBoxPos:Point = FindNewPosition(m_ShortcutsInventoryBox.GetWidth());
    m_ShortcutsInventoryBox.SetPos(shortcutsBoxPos.x, shortcutsBoxPos.y);
    m_ShortcutsInventoryBox.SetResizable(false);
    m_ShortcutsInventoryBox.SignalUpdateInventoryLabelAndAnimation.Connect(SlotSignalUpdateInventoryLabelAndAnimation, this);
    m_ShortcutsInventoryBox.SignalAnimateInventoryShortcut.Connect(SlotSignalAnimateInventoryShortcut, this);
    
    m_IconBoxes[m_DefaultInventoryBox.GetBoxID()] = m_DefaultInventoryBox;
    m_IconBoxes[m_ShortcutsInventoryBox.GetBoxID()] = m_ShortcutsInventoryBox;
    
    m_Inventory.SignalItemAdded.Connect(SlotItemAdded, this);
    m_Inventory.SignalItemLoaded.Connect(SlotItemLoaded, this);
    m_Inventory.SignalItemMoved.Connect(SlotItemMoved, this);
    m_Inventory.SignalItemRemoved.Connect(SlotItemRemoved, this);
    m_Inventory.SignalItemChanged.Connect(SlotItemChanged, this);
    m_Inventory.SignalItemStatChanged.Connect(SlotItemStatChanged, this);
    m_Inventory.SignalItemCooldown.Connect(SlotItemCooldown, this);
    m_Inventory.SignalItemCooldownRemoved.Connect(SlotItemCooldownRemoved, this);
    m_Inventory.SignalInventoryExpanded.Connect(UpdateTotalNumItems, this);

    ShopInterface.SignalOpenShop.Connect(SlotOpenShop, this);
}

function onUnload()
{
    gfx.managers.DragManager.instance.removeEventListener("dragBegin", this, "SlotDragBegin");
    gfx.managers.DragManager.instance.removeEventListener("dragEnd", this, "SlotDragEnd");

    SFClipLoader.SignalDisplayResolutionChanged.Disconnect(Layout, this);
    ShopInterface.SignalOpenShop.Disconnect(SlotOpenShop, this);
    
	CloseSplitItemPopup();
    
    if (m_CurrentDialog != undefined)
    {
        m_CurrentDialog.Close();
    }
}

function SlotCharacterStatChanged(stat:Number)
{
    if (stat == _global.Enums.Stat.e_ExtraItemInventorySlots || stat == _global.Enums.Stat.e_ExpandInventory)
    {
        UpdateTotalNumItems();
        m_DefaultInventoryBox.UpdateBuySlotsButton();
    }
}

function CheckSaveConfig()
{
    if (m_SaveConfigTimer == 0)
    {
        m_SaveConfigTimer = setInterval(SaveConfig, 5000);
    }
}

function SaveConfig()
{
    if (m_ModuleActivated)
    {
        DistributedValue.SetDValue("InventoryWindowConfig", CreateConfig());
        clearInterval(m_SaveConfigTimer);
        m_SaveConfigTimer = 0;
    }
}

function OnModuleDeactivated()
{
    return CreateConfig();
}

function CreateConfig():Archive
{
    var archive:Archive = new Archive();
    for(var key:String in m_IconBoxes)
    {
        var iconBox:ItemIconBox = m_IconBoxes[key];
        if (iconBox != undefined)
        {
            var iconBoxArchive = new Archive();
            iconBoxArchive.AddEntry("Name", iconBox.GetName());
            iconBoxArchive.AddEntry("BoxId", iconBox.GetBoxID());

            var numRows:Number = iconBox.GetNumRows();
            numRows = (numRows < 1)? 1 : (numRows > 45)? 45: numRows;
            iconBoxArchive.AddEntry("NumRows", numRows);

            var numColumns:Number = iconBox.GetNumColumns();
            numColumns = (numColumns < 1)? 1 : (numColumns > 45)? 45: numColumns;
            iconBoxArchive.AddEntry("NumColumns",numColumns);
            
            iconBoxArchive.AddEntry("X", Number(iconBox.GetWindowMC()._x));
            iconBoxArchive.AddEntry("Y", Number(iconBox.GetWindowMC()._y));
            var bindings:Array = iconBox.GetSlotBindings();
            for (var bindingIndex:Number = 0; bindingIndex < bindings.length; bindingIndex++)
            {
                iconBoxArchive.AddEntry("BindingIndexArray",bindings[bindingIndex].m_Index);
                iconBoxArchive.AddEntry("BindingItemArray",Number(bindings[bindingIndex].m_Item));
            }
            iconBoxArchive.AddEntry("IsPinned",iconBox.IsPinned());
            archive.AddEntry("Boxes", iconBoxArchive);
        }
    }
    return archive;    
}

function OnModuleActivated(config:Archive)
{
    m_SlotToBoxBindings = new Object();
 
    var boxArray:Array = config.FindEntryArray("Boxes");
    
    if (boxArray != undefined)
    {
        var iconBox:ItemIconBox = undefined;
        
        for (var i:Number = 0; i < boxArray.length; i++)
        {
            var boxConfig:Archive = boxArray[i];
            
            if (boxConfig != undefined)
            {
                var boxId:Number = boxConfig.FindEntry("BoxId", i);
                
                if (boxId == DEFAULT_INVENTORY_WINDOW || boxId == SHORTCUTS_INVENTORY_WINDOW)
                {
                    iconBox = m_IconBoxes[boxId];
                    if (iconBox.GetBoxID() == DEFAULT_INVENTORY_WINDOW)
                    {
                        iconBox.ResizeBoxTo(boxConfig.FindEntry("NumRows"), boxConfig.FindEntry("NumColumns"), true);
                    }
                }
                else
                {
                    iconBox = CreateBox(boxConfig.FindEntry("NumRows"), boxConfig.FindEntry("NumColumns"), false, false, false);
                    m_IconBoxes[iconBox.GetBoxID()] = iconBox;
                }

                if (iconBox)
                {
                    if (iconBox.GetBoxID() != SHORTCUTS_INVENTORY_WINDOW)
                    {
                        iconBox.SetName(boxConfig.FindEntry("Name"));
                        UpdateSlotToBoxBindings(iconBox.GetBoxID(), boxConfig.FindEntryArray("BindingIndexArray"), boxConfig.FindEntryArray("BindingItemArray"));
                    }
    
                    iconBox.SetPos(boxConfig.FindEntry("X", 0), boxConfig.FindEntry("Y", 0));
                    iconBox.SetPinned(boxConfig.FindEntry("IsPinned"));
                }
            }
        }
    }
    
    var unboundArray:Array = [];
    var maxItems:Number = m_Inventory.GetMaxItems();
    
    //Read all items from the inventory and put them in their respective places
	if (m_Inventory != undefined && m_DefaultInventoryBox != undefined && maxItems != undefined)
	{
		for (var i:Number = 0; i < maxItems; i++)
		{
			if (m_Inventory.GetItemAt(i) != undefined)
			{
				var slotBinding:Object = GetSlotBinding(i);
				if (slotBinding != undefined)
				{
                    if (m_IconBoxes[slotBinding.boxID])
                    {
                        m_IconBoxes[slotBinding.boxID].AddItemAtGridPosition(i, m_Inventory.GetItemAt(i), slotBinding.internalID);
                    }
				}
				else
				{
					//Add it to an unbound array, since we should not put it in the first possible slot, since that can be bound to another item
					unboundArray.push(i);
				}
			}            
		}

		for (var i:Number = 0; i < unboundArray.length; i++)
		{
			m_DefaultInventoryBox.AddItem(unboundArray[i], m_Inventory.GetItemAt(unboundArray[i]));
		}
	}
    
    m_SlotToBoxBindings = new Object;
    
    UpdateTotalNumItems();    
	SlotScaleChanged();
    UpdateVisibility();
    SlotPinnedWindowsOpacityChanged();
    SlotLockPositionWhenPinnedChanged();
    UpdateInventoryItemLabelAndAnimation();
    
    Layout();
    
    m_ModuleActivated = true;
}

function Layout()
{
    var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
    _x = visibleRect.x;
    _y = visibleRect.y;
    
    ClampIconBoxes();
}

function SlotScaleChanged()
{
    for( var key:String in m_IconBoxes )
	{
        if (m_IconBoxes[key])
        {
            m_IconBoxes[key].GetWindowMC()._xscale = m_ScaleMonitor.GetValue();
            m_IconBoxes[key].GetWindowMC()._yscale = m_ScaleMonitor.GetValue();
        }
	}
}

function SlotPinnedWindowsOpacityChanged():Void
{
    for( var key:String in m_IconBoxes )
	{
        if (m_IconBoxes[key])
        {
            m_IconBoxes[key].SetPinnedBackgroundOpacity(m_PinnedWindowsOpacityMonitor.GetValue());
        }
    }
}

function SlotLockPositionWhenPinnedChanged():Void
{
    for( var key:String in m_IconBoxes )
	{
        if (m_IconBoxes[key])
        {
            m_IconBoxes[key].SetLockPositionWhenPinned(m_LockPositionWhenPinnedMonitor.GetValue());
        }
    }
}

function SlotEnableShortcutsWindowChanged():Void
{
    m_ShortcutsInventoryBox.SetOnScreenVisibility(m_EnableShortcutsWindowMonitor.GetValue());
}

function SlotRightClickVendorSaleChanged():Void
{
    m_EnableRightClickVendorSale = m_RightClickVendorSale.GetValue();
}

function SlotCloseInventory()
{
    var character:Character = Character.GetClientCharacter();
    
	if (character != undefined)
    {
        character.AddEffectPackage("sound_fxpackage_GUI_click_tiny.xml");
    }
	
    DistributedValue.SetDValue("inventory_visible", false);
}

function ClampIconBoxes()
{
    for( var key:String in m_IconBoxes )
    {
        if (m_IconBoxes[key])
        {
            ClampPos(m_IconBoxes[key]);
        }
    }
}

function ClampPos(iconBox:IconBox)
{
    var pos:Point = iconBox.GetPos();
    var width:Number = iconBox.GetWidth();
    var height:Number = iconBox.GetHeight();
		
    if (pos.x + width <= 50)
    {
        pos.x = 0;
    }
    
    if (pos.x >= Stage.width - 40)
    {
        pos.x = Stage.width - width;
    }
    
    if (pos.y + height <= 80)
    {
        pos.y = 0;
    }
    
    if (pos.y >= Stage.height - 50)
    {
        pos.y = Stage.height - height;
    }

    iconBox.SetPos(pos.x, pos.y);
}

function UpdateVisibility()
{
    var shouldShow:Boolean = Boolean(m_ChangeVisibliltyMonitor.GetValue());
    
    if (shouldShow == undefined)
    {
        shouldShow = false;
    }
    
    m_InventoryVisible = shouldShow;
	
    for( var key:String in m_IconBoxes )
    {
        if (m_IconBoxes[key])
        {
            m_IconBoxes[key].SetOnScreenVisibility(shouldShow);
        }
    }
    
    if (m_InventoryVisible)
    {
		SFClipLoader.MoveToFront(SFClipLoader.GetClipIndex(this));
        m_EscapeStackNode = new com.GameInterface.EscapeStackNode;
        m_EscapeStackNode.SignalEscapePressed.Connect(SlotEscapePressed, this);
        com.GameInterface.EscapeStack.Push(m_EscapeStackNode);
    }
    else
    {
        if (m_EscapeStackNode != undefined)
        {
            m_EscapeStackNode.SignalEscapePressed.Disconnect(SlotEscapePressed, this);
            m_EscapeStackNode = undefined;
        }

		CloseSplitItemPopup();
    }
    
    if (!m_InventoryVisible && m_CurrentDialog != undefined)
    {
        m_CurrentDialog.Close();
    }

    if (!shouldShow)
    {
        SaveConfig();
    }
}

function SlotEscapePressed()
{
    m_ChangeVisibliltyMonitor.SetValue(false);
}

function UpdateTotalNumItems()
{
    m_DefaultInventoryBox.SetNumTotalItems(CalcNumItems(), m_Inventory.GetMaxItems());
}

function UpdateSlotToBoxBindings(boxID:Number, bindingsIndexArray:Array, bindingsItemArray:Array)
{
    for (var i:Number = 0; i < bindingsIndexArray.length; i++)
    {
        m_SlotToBoxBindings[bindingsItemArray[i]] = { boxID : boxID, internalID:bindingsIndexArray[i] }
    }
}

function GetSlotBinding(slotID:Number):Object
{
    return m_SlotToBoxBindings[slotID];
}

function SlotNewPressed(parentBox:ItemIconBox)
{
    if (GetBoxCount() < m_MaxNumBoxes)
    {
        m_ActiveBox = CreateNewBox();
        m_IconBoxes[m_ActiveBox.GetBoxID()] = m_ActiveBox;
        
        CheckSaveConfig();
        SlotPinnedWindowsOpacityChanged();
        SlotLockPositionWhenPinnedChanged();
    }
    else
    {
        //FIFO
        var fifoMessage:String = LDBFormat.LDBGetText("GenericGUI", "MaxInventoryWindows");
        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(fifoMessage, 0)        
    }
}

function GetBoxCount():Number
{
    var count:Number = 0;
    for ( var key:String in m_IconBoxes )
    {
        if (m_IconBoxes[key] != undefined)
        {
            count++;
        }
    }
    return count;
}

function SlotTrashPressed(parentBox:ItemIconBox)
{
    if ( IsShortcutsBox(parentBox.GetBoxID()) )
    {
        m_ShortcutsInventoryBox.RemoveAllShortcuts();
    }
    else
    {
        if (parentBox.GetNumItems() > 0)
        {
            var bagName:String = LDBFormat.Translate(parentBox.GetName());
            var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "Inventory_confirmDeleteBag"), bagName);
            
            m_CurrentDialog = new com.GameInterface.DialogIF(dialogText, Enums.StandardButtons.e_ButtonsYesNo, "DeleteBox");
            m_CurrentDialog.SignalSelectedAS.Connect(SlotDeleteBox, this);
            m_CurrentDialog.Go(parentBox.GetBoxID()); 
        }
        else
        {
            RemoveBox(parentBox);
            CheckSaveConfig();
        }
    }
}

function SlotDeleteBox(buttonID:Number, boxIdx:Number)
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        if (m_IconBoxes[boxIdx])
        {
            m_IconBoxes[boxIdx].MergeInto(m_DefaultInventoryBox);
            RemoveBox(m_IconBoxes[boxIdx]);
            CheckSaveConfig();
        }
    }
}

function DragBox(activebox:IconBox)
{
    m_State = STATE_DRAGGING_WINDOW;
    m_ActiveBox = activebox;
    m_ActiveBox.GetWindowMC().swapDepths(m_HighestBoxDepth);
    startDrag(m_ActiveBox.GetWindowMC(), false, -m_ActiveBox.GetWindowMC()._width + 50, - m_ActiveBox.GetWindowMC()._height + 80, Stage.width - 40, Stage.height - 50);
}

function SlotBuySlots()
{
	ProjectUtils.BuyInventorySlots(m_Inventory.GetInventoryID());
}


function SlotSearch(searchText:String)
{
    ResetFilter();
    
    var searchArray:Array = StringUtils.Strip(searchText).toLowerCase().split(" ");
    
    for (var searchIndex:Number = 0; searchIndex < searchArray.length; searchIndex++)
    {
        var searchString:String = StringUtils.Strip(searchArray[searchIndex]);

        for (var i:Number = 0; i < m_Inventory.m_Items.length; i++)
        {
            if (m_Inventory.GetItemAt(i) != undefined)
            {
                var item:InventoryItem = m_Inventory.GetItemAt(i);
                var inFilter = item.m_Name.toLowerCase().indexOf(searchString) != -1 || 
                                LDBFormat.LDBGetText("ItemTypeGUI", item.m_ItemTypeGUI).toLowerCase().indexOf(searchString) != -1;
                if (inFilter)
                {
                    item.m_InFilter = true;
                }
            }
        }
    }
    for ( var key:String in m_IconBoxes )
    {
        if (m_IconBoxes[key])
        {
            m_IconBoxes[key].UpdateFilteredItems();
        }
    }

}

function ResetFilter()
{
    for (var i:Number = 0; i < m_Inventory.m_Items.length; i++)
    {
        if (m_Inventory.GetItemAt(i) != undefined)
        {
            m_Inventory.GetItemAt(i).m_InFilter = false;
        }
    }
}

/// creates a new inventory box and defines wether or not to start writing a name in the box
/// @param numRows:Number - number of rows in the inventory
/// @param numColumns:Number - number of columns in the inventory
/// @param isDefaultBox:Boolean - if defaultbox, add an "add" button and do not start writing
/// @param isNew:Boolean - is it a new inventory, then generate a new name.
function CreateBox(numRows:Number, numColumns:Number, isDefaultBox:Boolean, isNew:Boolean, isShortcutsBox:Boolean):ItemIconBox
{
    var name:String = "InvBackground" + m_NextBoxId;
    
    if (isShortcutsBox)
    {
        name = "ShortcutsBag";
    }
    
    m_HighestBoxDepth = getNextHighestDepth();
    
    var newBox:MovieClip = attachMovie("InventoryBackground", name, m_HighestBoxDepth);
	
	newBox._xscale = m_ScaleMonitor.GetValue();
	newBox._yscale = m_ScaleMonitor.GetValue();
	
    var newIconBox:ItemIconBox;
    
    if (isShortcutsBox)
    {
        newIconBox = new ShortcutsIconBox(SHORTCUTS_INVENTORY_WINDOW, m_Inventory.m_InventoryID, newBox, numRows, numColumns, isDefaultBox, isNew, isShortcutsBox);
    }
    else
    {
        newIconBox = new ItemIconBox(m_NextBoxId, m_Inventory.m_InventoryID, newBox, numRows, numColumns, isDefaultBox, isNew, isShortcutsBox);
    }
    
    if (isDefaultBox)
    {
        newIconBox.SignalSearch.Connect(SlotSearch, this);
        newIconBox.SignalBuySlots.Connect(SlotBuySlots, this);
    }
    
    newIconBox.SignalStartDragging.Connect(DragBox, this);
    newIconBox.SignalDeleteItem.Connect(SlotDeleteItem, this);
    newIconBox.SignalMouseDownItem.Connect(SlotMouseDownItem, this);
    newIconBox.SignalMouseUpItem.Connect(SlotMouseUpItem, this);
    newIconBox.SignalStartDragItem.Connect(SlotStartDragItem, this);
    newIconBox.SignalStartSplitItem.Connect(SlotStartSplitItem, this);
    newIconBox.SignalMouseDownEmptySlot.Connect(SlotMouseDownEmptySlot, this);
    newIconBox.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
    newIconBox.SignalTrashButtonPressed.Connect(SlotTrashPressed, this);

    if (!isShortcutsBox)
    {
        m_NextBoxId++;
    }
    
    return newIconBox;
}

function CreateNewBox():ItemIconBox
{
    var newBox:ItemIconBox = CreateBox(2, 5, false, true, false);
    var newPos:Point = FindNewPosition(newBox.GetWidth());
    
    newBox.SetPos(newPos.x, newPos.y);
    newBox.SignalTrashButtonPressed.Connect(SlotTrashPressed, this);
    return newBox;
}

///Finds where to position a new window

function FindNewPosition(newWindowWidth:Number):Point
{
    var newPos:Point = m_DefaultInventoryBox.GetPos();
    newPos.x += m_DefaultInventoryBox.GetWidth() + 10;
    newPos.y += 20;
    
    var xInterval:Number = 40;
    var yInterval:Number = 40;
    
    if (newPos.x +newWindowWidth > Stage["visibleRect"].x + Stage["visibleRect"].width)
    {
        newPos = m_DefaultInventoryBox.GetPos();
        newPos.x -= newWindowWidth - 20;
        xInterval = -40;
    }
    
    /// increment the position by 20 till we do not overlap any windows
    var numIterations:Number = 0
    while (IsBoxAtPos(newPos) && numIterations < m_MaxNumBoxes)
    {
        newPos.offset(xInterval, yInterval);
        numIterations++;
    }
    
    return newPos;
    
}

function IsBoxAtPos(point:Point)
{
    for ( var key:String in m_IconBoxes )
    {
        if (m_IconBoxes[key] && m_IconBoxes[key].GetPos().equals(point))
        {
            return true;
        }
    }
    return false;
}

function RemoveBox(box:ItemIconBox)
{
    if (box != undefined)
    {
        box.GetWindowMC().removeMovieClip();
        if (box == m_DefaultInventoryBox)
        {
            box.SignalNewButtonPressed.Disconnect(SlotNewPressed, this);
        }
        else
        {
            box.SignalTrashButtonPressed.Disconnect(SlotTrashPressed, this);
        }
        box.CloseAllTooltips();
        
        m_IconBoxes[box.GetBoxID()] = undefined;
        //m_IconBoxes.splice(box.GetBoxID(), 1);
    }
}

function SlotUseItem(itemSlot:ItemSlot)
{
	if (!itemSlot.IsLocked())
	{
		m_Inventory.UseItem(itemSlot.GetSlotID());
		if (DragObject.GetCurrentDragObject() != undefined)
		{
			gfx.managers.DragManager.instance.cancelDrag();
		}
	}
}

function SlotDeleteItem(itemSlot:ItemSlot)
{
    var isGM:Boolean = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0;

    if (itemSlot.GetData().m_Deleteable || isGM)
    {
        var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ConfirmDeleteItem"), itemSlot.GetData().m_Name);
        m_CurrentDialog = new com.GameInterface.DialogIF(dialogText, Enums.StandardButtons.e_ButtonsYesNo, "DeleteItem");
        m_CurrentDialog.SignalSelectedAS.Connect(SlotDeleteItemDialog, this);
        m_CurrentDialog.Go(itemSlot.GetSlotID()); // <-  the slotid is userdata.
    }
	else if (!itemSlot.GetData().m_Deleteable)
	{
		var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ItemNotDeleteable"));
        m_CurrentDialog = new com.GameInterface.DialogIF(dialogText, Enums.StandardButtons.e_ButtonsOk, "DeleteItem");
        m_CurrentDialog.Go(); // <-  the slotid is userdata.
	}
}

function SlotDeleteItemDialog(buttonID:Number, itemSlotID:Number)
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        m_Inventory.DeleteItem(itemSlotID);
    }
    else
    {
        var box:ItemIconBox = GetIconBoxContainingItemSlot(m_Inventory.m_InventoryID, itemSlotID);
        var slot:ItemSlot = box.GetItemSlot(itemSlotID)
        slot.UpdateFilter();
    }
}

function SlotMouseDownItem(iconBox:IconBox, itemSlot:ItemSlot, buttonIndex:Number, clickCount:Number)
{
    if (Key.isDown(Key.CONTROL) && buttonIndex == 1)
    {
        //Check if its already selected and should be deselected
        for (var i:Number = 0; i < m_SelectedItems.length; i++)
        {
            if (m_SelectedItems[i].m_ItemSlot == itemSlot)
            {
                itemSlot.SetGlow(false);
                m_SelectedItems.splice(i, 1);
                return;
            }
        }
        itemSlot.SetGlow(true);
        m_SelectedItems.push({ m_IconBox:iconBox, m_ItemSlot:itemSlot });
    }
	else if (clickCount == 2 && buttonIndex == 1 && !itemSlot.IsLocked())
	{
        if (IsShortcutsBox(iconBox.GetBoxID()))
        {
            m_ShortcutsInventoryBox.UseShortcut(itemSlot.GetSlotID());
        }
        else
        {
            m_Inventory.UseItem(itemSlot.GetSlotID());
        }
		if (DragObject.GetCurrentDragObject() != undefined)
		{
			gfx.managers.DragManager.instance.cancelDrag();
		}
	}
}

function SlotMouseUpItem(iconBox:IconBox, itemSlot:ItemSlot, buttonIndex:Number)
{
    if (!Key.isDown(Key.CONTROL) && buttonIndex == 1)
    {
        ClearSelectedItems();
    }
    
    if (buttonIndex == 2)
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        if (currentDragObject != undefined && currentDragObject.type == "item")
        {
            if (currentDragObject.stack_size > 1)
            {
                if (m_Inventory.SplitItem(currentDragObject.inventory_id, currentDragObject.inventory_slot, itemSlot.GetSlotID(), 1))
                {
                    currentDragObject.stack_size = currentDragObject.stack_size - 1;
                    currentDragObject.GetDragClip().SetStackSize(currentDragObject.stack_size);   
                }
            }
            else
            {
                gfx.managers.DragManager.instance.stopDrag();
            }
        }
		else
		{
			if (m_OpenShop != undefined)
			{
                if (CanSellItem(itemSlot.GetData()) && m_EnableRightClickVendorSale)
                {
                    m_OpenShop.SellItem(m_Inventory.m_InventoryID, itemSlot.GetSlotID());
                    
                    var sellMessage:String = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "Inventory_SellToVendorMessage"), itemSlot.GetData().m_Name);
                    com.GameInterface.Chat.SignalShowFIFOMessage.Emit(sellMessage, 0);
                    Character.GetClientCharacter().AddEffectPackage("sound_fxpackage_GUI_trade_success.xml");                    
                }
			}
			else if(!Key.isDown(Key.CONTROL) && !itemSlot.IsLocked())
			{
                if (IsShortcutsBox(iconBox.GetBoxID()))
                {
                    m_ShortcutsInventoryBox.UseShortcut(itemSlot.GetSlotID());
                }
                else
                {
                    m_Inventory.UseItem(itemSlot.GetSlotID());
                }
			}
		}
    }
}

function CanSellItem(inventoryItem:InventoryItem):Boolean
{
    return 	((inventoryItem.m_TokenCurrencySellType1 != undefined && inventoryItem.m_TokenCurrencySellType1 > 0 && inventoryItem.m_TokenCurrencySellPrice1 != undefined && inventoryItem.m_TokenCurrencySellPrice1 > 0) ||
            (inventoryItem.m_TokenCurrencySellType2 != undefined && inventoryItem.m_TokenCurrencySellType2 > 0 && inventoryItem.m_TokenCurrencySellPrice2 != undefined && inventoryItem.m_TokenCurrencySellPrice2 > 0));
}

function SlotMouseUpEmptySlot(iconBox:IconBox, gridPos:Point, buttonIdx:Number)
{
    //If you release right button with a drag item, deposit one
    if (buttonIdx == 2)
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();

        if (currentDragObject != undefined && currentDragObject.type == "item")
        {
            if (currentDragObject.stack_size > 1)
            {
                var nextFreeItemSlot:Number = m_Inventory.GetFirstFreeItemSlot();
                iconBox.CreateEmptySlot(gridPos, nextFreeItemSlot);
                if (m_Inventory.SplitItem(currentDragObject.inventory_id, currentDragObject.inventory_slot, nextFreeItemSlot, 1))
                {
                    currentDragObject.stack_size = currentDragObject.stack_size - 1;
                    currentDragObject.GetDragClip().SetStackSize(currentDragObject.stack_size);            
                }
				else
				{
					iconBox.RemoveItem(nextFreeItemSlot);
				}
            }
            else
            {
                gfx.managers.DragManager.instance.stopDrag();
            }
        }
    }
}

function SlotMouseDownEmptySlot(iconBox:IconBox, gridPos:Point, buttonIdx:Number)
{
}


function ClearSelectedItems()
{
    for (var i:Number = 0; i < m_SelectedItems.length; i++)
    {
        m_SelectedItems[i].m_ItemSlot.SetGlow(false);
    }
    m_SelectedItems = [];
}
    
function SlotStartSplitItem(iconBox:IconBox, itemSlot:ItemSlot, stackSize:Number)
{
    if (m_SplitItemPopup == undefined)
    {
        m_SplitItemPopup = attachMovie("SplitItemPopup", "m_SplitItemPopup", getNextHighestDepth());
        var iconPos:Point = new Point(itemSlot.GetIcon()._width, 0);
        itemSlot.GetSlotMC().localToGlobal(iconPos);
        this.globalToLocal(iconPos);
        m_SplitItemPopup._x = iconPos.x;
        m_SplitItemPopup._y = iconPos.y;
        m_SplitItemPopup.SignalAcceptSplitItem.Connect(SlotAcceptSplitItem, this);
        m_SplitItemPopup.SignalCancelSplitItem.Connect(SlotCancelSplitItem, this);
        m_SplitItemPopup.SetItemSlot(itemSlot);
    }
}

function SlotAcceptSplitItem(itemSlot:ItemSlot, stackSplit:Number)
{
    if (itemSlot != undefined)
    {
        var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSplit);
		gfx.managers.DragManager.instance.dragOffsetX = -dragObject.GetDragClip()._width / 2;
		gfx.managers.DragManager.instance.dragOffsetY = -dragObject.GetDragClip()._height / 2;
        dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
        dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
    }
	CloseSplitItemPopup();
}

function CloseSplitItemPopup()
{
	if (m_SplitItemPopup != undefined)
	{
		m_SplitItemPopup.removeMovieClip();
		m_SplitItemPopup = undefined;
	}
}

function SlotCancelSplitItem(slotID:Number)
{
	CloseSplitItemPopup();
}

function SlotStartDragItem(iconBox:IconBox, itemSlot:ItemSlot, stackSize:Number)
{
    SlotCancelSplitItem(itemSlot.GetSlotID());
    var inventoryItem:InventoryItem = itemSlot.GetData();
    if (m_SelectedItems.length <= 1)
    {
        var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSize);
        
        if (IsShortcutsBox(iconBox.GetBoxID()))
        {
            dragObject.type = "shortcut_items";
        }
        
        dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
        dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
    }
    else if (m_SelectedItems.length > 1)
    {
        var dragObject:DragObject = new DragObject();
        dragObject.type = "inventory_items";
        dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
        dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
        
        var dragItems:Array = new Array();
        
        dragItems.push({ inventory_id:itemSlot.GetInventoryID(), inventory_slot:itemSlot.GetSlotID() });

        //Add the icon of the main drag clip
        var originalIcon:MovieClip = itemSlot.GetIcon();
        var dragClip:ItemComponent = ItemComponent(gfx.managers.DragManager.instance.startDrag(originalIcon, itemSlot.GetIconTemplateName(), dragObject, dragObject, originalIcon, false));
        dragClip.SetData(inventoryItem);
        dragClip.SetStackSize(inventoryItem.m_StackSize);
        
        var mainIconPos:Point = new Point(originalIcon._x, originalIcon._y);
        originalIcon.localToGlobal(mainIconPos);
        
        for (var i:Number = 0; i < m_SelectedItems.length; i++)
        {
            if (m_SelectedItems[i].m_ItemSlot != itemSlot)
            {
                dragItems.push({ inventory_id:m_SelectedItems[i].m_ItemSlot.GetInventoryID(), inventory_slot:m_SelectedItems[i].m_ItemSlot.GetSlotID() });
                
                var localItemSlot:ItemSlot = m_SelectedItems[i].m_ItemSlot;
                var localInventoryItem:InventoryItem = localItemSlot.GetData();
                
                var icon:MovieClip = localItemSlot.GetIcon();
                var iconPos:Point = new Point(icon._x, icon._y);
                icon.localToGlobal(iconPos);
                
				var scale:Number = com.GameInterface.DistributedValue.GetDValue("GUIScaleInventory");
                var relativePos:Point = mainIconPos.subtract(iconPos);
				relativePos.x = relativePos.x * 100 / scale;
				relativePos.y = relativePos.y * 100 / scale

                var newClip:ItemComponent = ItemComponent(dragClip.attachMovie(localItemSlot.GetIconTemplateName(), "m_Icon_" + i, dragClip.getNextHighestDepth(), { _x: -relativePos.x, _y: -relativePos.y }));
                newClip.SetData(localInventoryItem);
                newClip.SetStackSize(localInventoryItem.m_StackSize);
                
                var dist:Number = relativePos.length;
                dist = Math.min(dist, 200);
                
                var alpha:Number = Math.max((200 - dist) / 200 * 100, 10);
                newClip._alpha = alpha;
            }
        }
        
        dragObject.items = dragItems;
        m_DraggedItems = dragItems;
    }
}

function SlotDragHandled()
{
    var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
    var box:ItemIconBox = GetIconBoxContainingItemSlot(m_Inventory.m_InventoryID, currentDragObject.inventory_slot);
    
    if (box != undefined)
    {
        var slot:ItemSlot = box.GetItemSlot(currentDragObject.inventory_slot)
        if (slot != undefined)
        {
            slot.SetAlpha(100);
            slot.UpdateFilter();
        }
    }
    
    if (m_ShortcutsInventoryBox)
    {
        var shortcutSlot:ItemSlot = m_ShortcutsInventoryBox.GetItemSlot(currentDragObject.inventory_slot);
        if (shortcutSlot)
        {
            shortcutSlot.SetAlpha(100);
            shortcutSlot.UpdateFilter();
        }
    }
}

function SlotItemDroppedOnDesktop()
{
    var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
    var isGM:Boolean = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0;
    if (currentDragObject.type == "inventory_items")
    {
        var dialogText:String = LDBFormat.LDBGetText("Gamecode", "ConfirmDeleteItems");
        m_CurrentDialog = new com.GameInterface.DialogIF(dialogText, Enums.StandardButtons.e_ButtonsYesNo, "DeleteItems");
        m_CurrentDialog.SignalSelectedAS.Connect(SlotDeleteItemsDialog, this);
        m_ItemsToDelete = [];
        for (var i:Number = 0; i < currentDragObject.items.length; i++)
        {
            if (isGM || m_Inventory.GetItemAt(currentDragObject.items[i].inventory_slot).m_Deleteable)
            {
                m_ItemsToDelete.push(currentDragObject.items[i].inventory_slot);
            }
        }
        m_CurrentDialog.Go();
    }
    else if (currentDragObject.type == "item")
    {
        if (isGM || m_Inventory.GetItemAt(currentDragObject.inventory_slot).m_Deleteable)
        {
            var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ConfirmDeleteItem"), m_Inventory.GetItemAt(currentDragObject.inventory_slot).m_Name);
            var dialogIF = new com.GameInterface.DialogIF(dialogText, Enums.StandardButtons.e_ButtonsYesNo, "DeleteItem");
            dialogIF.SignalSelectedAS.Connect(SlotDeleteItemDialog, this);
            dialogIF.Go(currentDragObject.inventory_slot); // <-  the slotid is userdata.
        }
		else if (!m_Inventory.GetItemAt(currentDragObject.inventory_slot).m_Deleteable)
		{
			var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ItemNotDeleteable"));
			m_CurrentDialog = new com.GameInterface.DialogIF(dialogText, Enums.StandardButtons.e_ButtonsOk, "DeleteItem");
			m_CurrentDialog.Go(); // <-  the slotid is userdata.
		}
    }
    else if (currentDragObject.type == "shortcut_items")
    {
        m_ShortcutsInventoryBox.RemoveShortcut(currentDragObject.inventory_slot);
    }
    
}

function SlotDeleteItemsDialog(buttonID:Number)
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        for (var i:Number = 0; i < m_ItemsToDelete.length; i++)
        {
            m_Inventory.DeleteItem(m_ItemsToDelete[i]);
        }
    }
    m_ItemsToDelete = [];
}

onMouseMove = function()
{
    if (m_State == STATE_DRAGGING_WINDOW)
    {
        if (m_ActiveBox != m_DefaultInventoryBox && m_ActiveBox != m_ShortcutsInventoryBox)
        {
            for ( var key:String in m_IconBoxes )
            {
                var currentBox = m_IconBoxes[key];
                
                if (currentBox != undefined)
                {
                    if (currentBox.HitTestTopBar(_xmouse, _ymouse) && currentBox.IsVisible() && currentBox != m_ActiveBox && currentBox != m_ShortcutsInventoryBox)
                    {
                        if (currentBox != m_GlowingMergeBox)
                        {
                            if (m_GlowingMergeBox)
                            {
                                m_GlowingMergeBox.SetGlowing(false);
                            }
                            
                            m_GlowingMergeBox = currentBox;
                            m_GlowingMergeBox.SetGlowing(true);
                        }
                        break;
                    }
                    else if (currentBox == m_GlowingMergeBox)
                    {
                        m_GlowingMergeBox.SetGlowing(false);
                        m_GlowingMergeBox = undefined;
                    }
                }
            }
        }
    }
    else
    {
        for ( var key:String in m_IconBoxes )
        {
            var currentBox = m_IconBoxes[key];
            if (currentBox != undefined)
            {
                if (currentBox.HitTest(_xmouse, _ymouse))
                {
                    if (!currentBox.HasGrid())
                    {
                        currentBox.DrawGrid(parseInt(key) == 0);
                    }
                }
                else if (currentBox.HasGrid())
                {
                    currentBox.RemoveGrid();
                }
            }
        }
    }
}

onMouseUp = function(buttonIdx:Number, targetPath:String)
{
    //Clear selection if clicking outside an item
    var iconBox:ItemIconBox = m_IconBoxes[GetIconBoxIndexAt(_xmouse, _ymouse)];
    if (!Key.isDown(Key.CONTROL) && (iconBox == undefined || iconBox.GetItemAt(_root._xmouse, _root._ymouse) == undefined))
    {
        ClearSelectedItems();
    }
    
    if (m_State == STATE_DRAGGING_WINDOW)
    {
        m_ActiveBox.GetWindowMC().stopDrag();
        m_State = STATE_NONE;
        if (m_GlowingMergeBox != undefined)
        {
            ItemIconBox(m_ActiveBox).MergeInto(m_GlowingMergeBox);
            RemoveBox(ItemIconBox(m_ActiveBox));
            m_GlowingMergeBox.SetGlowing(false);
            m_GlowingMergeBox = undefined;
        }
        m_ActiveBox = undefined;
    }
}


function SlotDragBegin(event:Object)
{

}

function SlotDragEnd(event:Object)
{
	if (event.cancelled)
	{
		event.data.DragHandled();
		return;
	}

	if (Mouse["IsMouseOver"](this, false))
    {
		var succeed:Boolean = false;
		var iconBoxIdx = GetIconBoxIndexAt(_xmouse, _ymouse);
		//If we have a valid destination box
		if (iconBoxIdx != undefined)
		{
			if (event.data.type == "item" || event.data.type == "mailAttachment")
			{
				var x:Number = _xmouse;
				var y:Number = _ymouse;
				if (event.data.split)
				{
					SplitItem(event.data.inventory_id, event.data.inventory_slot, event.data.stack_size, iconBoxIdx, _root._xmouse, _root._ymouse);
                    succeded = true;
				}
				else
				{
                    if (IsShortcutsBox(iconBoxIdx))
                    {
                        if (m_Inventory.CanAddItemToShortcuts(event.data.inventory_slot))
                        {
                            AddShortcut(event.data.inventory_id, event.data.inventory_slot, _root._xmouse, _root._ymouse);
                            succeed = true;
                        }
                    }
                    else
                    {
                        if (event.data.type == "mailAttachment" && event.data.inventory_id.GetType() == _global.Enums.InvType.e_Type_GC_BankContainer)
                        {
                            Tradepost.DetachItemFromMail(event.data.inventory_slot); //Needed before it could be moved to backpack
                        }
                        succeed = MoveItem(event.data.inventory_id, event.data.inventory_slot, iconBoxIdx, _root._xmouse, _root._ymouse);
                    }
				}
				CheckSaveConfig();
			}
			else if (event.data.type == "lootitem")
			{
				var lootbag:Loot = new Loot(event.data.inventory_id);
				var dstIconBox:ItemIconBox = m_IconBoxes[iconBoxIdx];
				if (dstIconBox != undefined)
				{  
					var gridPosition:Point = dstIconBox.GetGridPositionAt(_root._xmouse, _root._ymouse);
					var itemSlot:Number = 0
						if (gridPosition != undefined)
						{
							//We need to create an empty itemslot before we loot item, so we know where to put it when item is looted
							itemSlot = m_Inventory.GetFirstFreeItemSlot();
							if (dstIconBox.GetItemAtGridPosition(gridPosition) != undefined)
							{
								dstIconBox.CreateEmptySlot(dstIconBox.GetFirstFreeGridPosition(), itemSlot);
							}
							else
							{
								dstIconBox.CreateEmptySlot(gridPosition, itemSlot);
							}
						}
					var characterID:com.Utils.ID32 = Character.GetClientCharID();
					lootbag.TryLootItem(event.data.inventory_slot, characterID, itemSlot);   
				}
				CheckSaveConfig();
			}
			else if (event.data.type == "tradeitem")
			{
				//Tradeitems never leaves the inventory, so will be automatically sorted out by just calling AddItem
				m_Inventory.AddItem(event.data.inventory_id, event.data.inventory_slot, 0);
			}
			else if (event.data.type == "inventory_items")
			{
				var dstIconBox:ItemIconBox = m_IconBoxes[iconBoxIdx];
				if (dstIconBox != undefined)
				{
					MoveItemsToBox(dstIconBox, event.data.items);
				}
				m_SelectedItems = [];
				m_DraggedItems = [];
			}
            else if (event.data.type == "shortcut_items")
            {
                if ( IsShortcutsBox(iconBoxIdx) )
                {
                    var gridPosition:Point = m_ShortcutsInventoryBox.GetGridPositionAt(_root._xmouse, _root._ymouse);
                    m_ShortcutsInventoryBox.MoveShortcut(event.data.inventory_slot,gridPosition.x);
                    succeed = true;
                }
                else
                {
                    m_ShortcutsInventoryBox.RemoveShortcut(event.data.inventory_slot);
                }
                CheckSaveConfig();
            }
		}
		event.data.DragHandled();
        Character.GetClientCharacter().AddEffectPackage((succeed) ? "sound_fxpackage_GUI_item_slot.xml" : "sound_fxpackage_GUI_item_slot_fail.xml");
	}
}

function MoveItemsToBox(dstIconBox:ItemIconBox, dragItems:Array)
{
    //If you drag them to the top bar, just drop them at the first available
    if (dstIconBox.HitTestTopBar(_xmouse, _ymouse))
    {
        for (var i:Number = 0; i < dragItems.length; i++)
        {
            var srcIconBox:ItemIconBox = GetIconBoxContainingItemSlot(dragItems[i].inventory_id, dragItems[i].inventory_slot);
            if (srcIconBox != undefined)
            {
                MoveItemToFirstFreeSlot(srcIconBox, dstIconBox, dragItems[i].inventory_slot);
            }
        }
    }
    else
    {
        var mouseGridPosition:Point = dstIconBox.GetGridPositionAt(_root._xmouse, _root._ymouse);
        if (mouseGridPosition != undefined && dstIconBox.IsValidGridPosition(mouseGridPosition))
        {
            //Drop items related to where the first is (So they keep the formation)
            var iconBoxOfFirstItem:IconBox = GetIconBoxContainingItemSlot(dragItems[0].inventory_id, dragItems[0].inventory_slot);
            if (iconBoxOfFirstItem != undefined)
            {
                var gridPositionOfFirstItem:Point = iconBoxOfFirstItem.GetGridPositionFromSlotID(dragItems[0].inventory_slot);
                //Go through the dragitems until its empty
                while (dragItems.length > 0)
                {
                    for (var i:Number = 0; i < dragItems.length;)
                    {
                        var srcIconBox:IconBox = GetIconBoxContainingItemSlot(dragItems[i].inventory_id, dragItems[i].inventory_slot);
                        //Only keep formation for items from the same box as the first item
                        if (srcIconBox == iconBoxOfFirstItem)
                        {
                            var sourceGridPos:Point = srcIconBox.GetGridPositionFromSlotID(dragItems[i].inventory_slot);
                            var gridPosition:Point = new Point( mouseGridPosition.x - (gridPositionOfFirstItem.x - sourceGridPos.x),
                                                                mouseGridPosition.y - (gridPositionOfFirstItem.y - sourceGridPos.y));
                            
                            var dstItemSlot:ItemSlot = dstIconBox.GetItemAtGridPosition(gridPosition);
                            if (dstItemSlot != undefined && dstItemSlot.GetSlotID() == dragItems[i].inventory_slot)
                            {
                                //this is self item, just remove and continue
                                dragItems.splice(i, 1);
                                continue;
                            }
                            else if (dstItemSlot != undefined && IsDraggedItem(dstItemSlot.GetSlotID()))
                            {
                                //go to next as the item slot is occupied by a dragged item, the slot might be free in the next turn
                                i++;
                                continue;
                            }
                            //Only add items to a relative position if the position is valid and does not contain an item
                            if (gridPosition != undefined && dstIconBox.IsValidGridPosition(gridPosition) && dstIconBox.GetItemAtGridPosition(gridPosition) == undefined)
                            {
                                if ( IsShortcutsBox(dstIconBox.GetBoxID()) || srcIconBox.RemoveItem(dragItems[i].inventory_slot))
                                {
                                    dstIconBox.AddItemAtGridPosition(dragItems[i].inventory_slot, m_Inventory.GetItemAt(dragItems[i].inventory_slot), gridPosition);
                                    dragItems.splice(i, 1);
                                    continue;
                                }
                            }
                        }
                        //Add items that did not fit in the formation
                        if (srcIconBox != undefined)
                        {
                            MoveItemToFirstFreeSlot(srcIconBox, dstIconBox, dragItems[i].inventory_slot);
                        }
                        dragItems.splice(i, 1);
                    }
                }
            }
        }
    }
}

function MoveItemToFirstFreeSlot(srcBox:IconBox, dstBox:ItemIconBox, itemSlot:Number)
{
    if ( IsShortcutsBox(dstIconBox.GetBoxID()) || srcBox.RemoveItem(itemSlot) )
    {
        dstBox.AddItem(itemSlot, m_Inventory.GetItemAt(itemSlot));
    }
}

function SplitItem(srcInventoryID:ID32, srcInventorySlot:Number, stackSize:Number, dstBoxIdx:Number, dstX:Number, dstY:Number)
{
    var itemSlot:ItemSlot = (m_IconBoxes[dstBoxIdx]) ? m_IconBoxes[dstBoxIdx].GetItemAt(dstX, dstY) : undefined;
    if (itemSlot != undefined)
    {
        //We have an item in the destination slot, just use the splititem to add
        m_Inventory.SplitItem(srcInventoryID, srcInventorySlot, itemSlot.GetSlotID(), stackSize);
    }
    else
    {
        var dstIconBox:ItemIconBox = m_IconBoxes[dstBoxIdx];
        if (dstIconBox != undefined)
        {
            if (dstIconBox.HitTestTopBar(_xmouse, _ymouse))
            {
                SplitItemToEmptySlot(dstIconBox, dstIconBox.GetFirstFreeGridPosition(), srcInventoryID, srcInventorySlot, stackSize);
            }
            else
            {
                var gridPosition:Point = dstIconBox.GetGridPositionAt(_root._xmouse, _root._ymouse);
                if (gridPosition != undefined)
                {
                    SplitItemToEmptySlot(dstIconBox, gridPosition, srcInventoryID, srcInventorySlot, stackSize);
                }
            }
        }
    }
}

function SplitItemToEmptySlot(iconBox:IconBox, gridPos:Point, srcInventoryID:ID32, sourcePos:Number, stackSize:Number)
{
    var nextFreeItemSlot:Number = m_Inventory.GetFirstFreeItemSlot();
    iconBox.CreateEmptySlot(gridPos, nextFreeItemSlot);
    if (!m_Inventory.SplitItem(srcInventoryID, sourcePos, nextFreeItemSlot, stackSize))
	{
		iconBox.RemoveItem(nextFreeItemSlot);
	}
    
}

function AddShortcut(srcInventoryID:ID32, srcInventorySlot:Number, dstX:Number, dstY:Number):Void
{
    //var itemSlot:ItemSlot = m_ShortcutsInventoryBox.GetItemAt(dstX, dstY);
    var gridPosition:Point = m_ShortcutsInventoryBox.GetGridPositionAt(dstX, dstY);
    m_ShortcutsInventoryBox.AddShortcut(srcInventoryID, srcInventorySlot, gridPosition);
}

function MoveItem(srcInventoryID:ID32, srcInventorySlot:Number, dstBoxIdx:Number, dstX:Number, dstY:Number):Boolean
{
    var isItemMoved:Boolean = false;
    var itemSlot:ItemSlot = (m_IconBoxes[dstBoxIdx]) ? m_IconBoxes[dstBoxIdx].GetItemAt(dstX, dstY) : undefined;
    if (itemSlot != undefined && itemSlot.HasItem())
    {
        //We have an item in the destination slot, just use the additem to switch the item with gamecode
        var addItemResult:Number = m_Inventory.AddItem(srcInventoryID, srcInventorySlot, itemSlot.GetSlotID());
        isItemMoved = (addItemResult == _global.Enums.InventoryAddItemResponse.e_AddItem_Success);
    }
    else
    {
        var srcIconBox:IconBox = GetIconBoxContainingItemSlot(srcInventoryID, srcInventorySlot);
        if (srcIconBox != undefined)
        {
            var dstIconBox:ItemIconBox = m_IconBoxes[dstBoxIdx];
            if (dstIconBox != undefined)
            {
                if (dstIconBox.HitTestTopBar(_xmouse, _ymouse))
                {
                    if ( IsShortcutsBox(dstIconBox.GetBoxID()) || srcIconBox.RemoveItem(srcInventorySlot))
                    {
                        dstIconBox.AddItem(srcInventorySlot, m_Inventory.GetItemAt(srcInventorySlot));
                        isItemMoved = true;
                    }
                }
                else
                {
                    var gridPosition:Point = dstIconBox.GetGridPositionAt(dstX, dstY);
                    if (gridPosition != undefined)
                    {
                        if ( IsShortcutsBox(dstIconBox.GetBoxID()) || srcIconBox.RemoveItem(srcInventorySlot))
                        {
							//Just to catch weird cases
							if (gridPosition.x < 0 || gridPosition.y < 0)
							{
								dstIconBox.AddItem(srcInventorySlot, m_Inventory.GetItemAt(srcInventorySlot));
							}
							else
							{
								dstIconBox.AddItemAtGridPosition(srcInventorySlot, m_Inventory.GetItemAt(srcInventorySlot), gridPosition);
							}
                            isItemMoved = true;
                        }
                    }
                }
                
                UpdateInventoryItemLabelAndAnimation();
            }
        }
        else
        {
            var dstIconBox:ItemIconBox = m_IconBoxes[dstBoxIdx];
            if (dstIconBox != undefined)
            {
                var gridPosition:Point = dstIconBox.GetGridPositionAt(dstX, dstY);
                if (gridPosition != undefined)
                {
                    var nextFreeItemSlot:Number = m_Inventory.GetFirstFreeItemSlot();
                    dstIconBox.CreateEmptySlot(gridPosition, nextFreeItemSlot);
                    var addItemResult:Number = m_Inventory.AddItem(srcInventoryID, srcInventorySlot, nextFreeItemSlot);
                    isItemMoved = (addItemResult == _global.Enums.InventoryAddItemResponse.e_AddItem_Success);
                }
            }
        }
    }
    return isItemMoved;
}

function UpdateInventoryItemLabelAndAnimation():Void
{
    for (var i:Number = 0; i < ShortcutsIconBox.MAX_POCKET_SIZE; i++)
    {
        if (m_ShortcutsInventoryBox.GetShortcutSlotAtIndex(i))
        {
            m_ShortcutsInventoryBox.UpdateItemLabelAndAnimation(i);
        }
    }
}

function GetIconBoxIndexAt(x:Number, y:Number)
{
	var returnIndex:Number = undefined;
	var highestDepth:Number = -320000; //Below the lowest depth
    for ( var key:String in m_IconBoxes )
    {
        if (m_IconBoxes[key] && m_IconBoxes[key].HitTest(x, y) && m_IconBoxes[key].GetWindowMC().getDepth() > highestDepth)
        {
			highestDepth = m_IconBoxes[key].GetWindowMC().getDepth();
            returnIndex = parseInt(key);
        }
    }

    return returnIndex;
}

function GetInventoryMaxItems():Number
{
    return (com.GameInterface.Utils.GetGameTweak("Inventory_BackpackSize") + Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_ExtraItemInventorySlots));
}

function GetIconBoxContainingItemSlot(inventoryID:ID32, slotIdx:Number):ItemIconBox
{
    for ( var key:String in m_IconBoxes )
    {
        if (m_IconBoxes[key] && !IsShortcutsBox(parseInt(key)) &&
            m_IconBoxes[key].GetInventoryID() && m_IconBoxes[key].GetInventoryID().Equal(inventoryID) && 
            m_IconBoxes[key].GetGridPositionFromSlotID(slotIdx) != undefined)
        {
            return m_IconBoxes[key];
        }
    }
    return undefined;
}

function IsShortcutsBox(iconBoxId:Number):Boolean
{
    return iconBoxId == m_ShortcutsInventoryBox.GetBoxID();
}

function CalcNumItems():Number
{
    var numItems:Number = 0;
    for ( var key:String in m_IconBoxes )
    {
        if (m_IconBoxes[key] != undefined && !IsShortcutsBox(m_IconBoxes[key].GetBoxID()))
        {
            numItems+=  m_IconBoxes[key].GetNumItems();
        }
    }
    return numItems;
}

function SlotSignalUpdateInventoryLabelAndAnimation(isAdded:Boolean, inventoryID:ID32, inventoryPosition:Number, shortcutLabel:String):Void
{
    var iconBox:ItemIconBox = GetIconBoxContainingItemSlot(inventoryID, inventoryPosition);
    
    if (iconBox)
    {
        if (isAdded)
        {
            iconBox.AddShortcutLabelAndAnimation(inventoryPosition, shortcutLabel);
        }
        else
        {
            iconBox.RemoveShortcutLabelAndAnimation(inventoryPosition);            
        }
    }
}

function SlotSignalAnimateInventoryShortcut(inventoryID:ID32, inventoryPosition:Number):Void
{
    var iconBox:ItemIconBox = GetIconBoxContainingItemSlot(inventoryID, inventoryPosition);
    
    if (iconBox)
    {
        iconBox.AnimateShortcut(inventoryPosition);        
    }
}

function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number)
{ 
    var iconBox:ItemIconBox = GetIconBoxContainingItemSlot(inventoryID, itemPos);
    if (iconBox != undefined)
    {
        iconBox.AddItemToExistingSlot(itemPos, m_Inventory.GetItemAt(itemPos));
    }
    else
    {
        m_DefaultInventoryBox.AddItem(itemPos, m_Inventory.GetItemAt(itemPos));
    }
    UpdateTotalNumItems();
}

function SlotItemLoaded(inventoryID:com.Utils.ID32, itemPos:Number)
{
	//Only do this if the module is activated, if not, it will be done later anyway
	if (m_ModuleActivated)
	{
		var slotBinding:Object = GetSlotBinding(itemPos);
		if (slotBinding != undefined && m_IconBoxes[slotBinding.boxID])
		{
			m_IconBoxes[slotBinding.boxID].AddItemAtGridPosition(itemPos, m_Inventory.GetItemAt(itemPos),slotBinding.internalID);
		}
		else
		{
			SlotItemAdded(inventoryID, itemPos);
		}    
	}
}
  
function SlotItemMoved(inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number)
{
    _global.setTimeout(Delegate.create(this,RefreshShortcuts), 100);
}

function RefreshShortcuts():Void
{
    m_ShortcutsInventoryBox.ShortcutsRefresh();
    //UpdateInventoryItemLabelAndAnimation();
}
  
function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean)
{
    var iconBox:ItemIconBox = GetIconBoxContainingItemSlot(inventoryID, itemPos);
    if (iconBox != undefined)
    {
        iconBox.RemoveItem(itemPos);
    }
    else
    {
        trace("SlotItemAdded on nonexisting itemslot");
    }
    UpdateTotalNumItems();
}
  
function SlotItemChanged(inventoryID:com.Utils.ID32, itemPos:Number)
{
    var iconBox:ItemIconBox = GetIconBoxContainingItemSlot(inventoryID, itemPos);
    if (iconBox != undefined)
    {
        iconBox.ChangeItem(itemPos,  m_Inventory.GetItemAt(itemPos));
    }
}
  
function SlotItemCooldown(inventoryID:com.Utils.ID32, itemPos:Number, seconds:Number)
{
    m_ShortcutsInventoryBox.SetCooldownInventoryItem(itemPos, seconds);
    
    var iconBox:ItemIconBox = GetIconBoxContainingItemSlot(inventoryID, itemPos);
    if (iconBox != undefined)
    {
        iconBox.SetCooldown(itemPos, seconds);
    }
}

function SlotItemCooldownRemoved(inventoryID:com.Utils.ID32, itemPos:Number)
{
    m_ShortcutsInventoryBox.SetCooldownInventoryItem(itemPos, 0);

    var iconBox:ItemIconBox = GetIconBoxContainingItemSlot(inventoryID, itemPos);
    if (iconBox != undefined)
    {
        iconBox.RemoveCooldown(itemPos);
    }
}

function SlotItemStatChanged(inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number)
{  
    //Special case for stacksize as we want to run an animation instead of reinitializing the slot
    if (stat == _global.Enums.Stat.e_StackSize)
    {
        var iconBox:ItemIconBox = GetIconBoxContainingItemSlot(inventoryID, itemPos);
        if (iconBox != undefined)
        {
            var itemSlot:ItemSlot = iconBox.GetItemSlot(itemPos);
            if (itemSlot != undefined)
            {
                itemSlot.UpdateStackSize(m_Inventory.GetItemAt(itemPos));
                return;
            }
        }
    }
	else
	{
		SlotItemChanged(inventoryID, itemPos);
	}
    
}

function SlotOpenShop(shopInterface:ShopInterface)
{
    m_OpenShop = shopInterface;
    m_OpenShop.SignalCloseShop.Connect(SlotCloseShop, this);
}

function SlotCloseShop()
{
    m_OpenShop = undefined;
}

function IsDraggedItem(itemSlotID:Number):Boolean
{
    for (var i:Number = 0; i < m_DraggedItems.length; i++)
    {
        if (m_DraggedItems[i].inventory_slot == itemSlotID)
        {
            return true;
        }
    }
    
    return false;
}
