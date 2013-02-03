//Imports
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Game.Character;
import com.GameInterface.InventoryItem;
import com.GameInterface.Inventory;
import com.GameInterface.ProjectUtils;
import com.Components.ItemSlot;
import com.Utils.ID32;
import com.Utils.Signal;
import flash.geom.Point;
import GUI.Inventory.ItemIconBox;
import mx.data.encoders.Num;

//Class
class GUI.Inventory.ShortcutsIconBox extends ItemIconBox
{
    //Constants
    public static var MAX_POCKET_SIZE:Number = 5; //Find the correct gametweak
    
    private static var START_SLOT_POCKET:String = "PlayerStartSlotPocket";
    
    //Properties
    public var SignalUpdateInventoryLabelAndAnimation:Signal;
    public var SignalAnimateInventoryShortcut:Signal;
    
    private var m_ShortcutSlotsArray:Array;
    private var m_StartSlot:Number;
    private var m_Slots:Array; 
    
    //Constructor
    public function ShortcutsIconBox(boxId:Number, inventoryId:ID32, windowMC:MovieClip, numRows:Number, numColumns:Number, isDefaultBox:Boolean, isNew:Boolean, isShortcutsBox:Boolean)
    {
        super(boxId, inventoryId, windowMC, numRows, numColumns, isDefaultBox, isNew, isShortcutsBox);
        
        Init();
    }
    
    //Init
    private function Init():Void
    {
        SignalUpdateInventoryLabelAndAnimation = new Signal();
        SignalAnimateInventoryShortcut = new Signal();
        
        m_StartSlot = ProjectUtils.GetUint32TweakValue(START_SLOT_POCKET);
        m_ShortcutSlotsArray = new Array();
        m_Slots = new Array();

        for (var i:Number = 0; i < MAX_POCKET_SIZE; i++)
        {
            var shortcutSlot:MovieClip = m_WindowMC.i_Content.attachMovie("ShortcutSlot", "m_ShortcutSlot_" + i, m_WindowMC.i_Content.getNextHighestDepth());
            shortcutSlot._x = CalculateSlotPosX(i);
            shortcutSlot._y = CalculateSlotPosY(0);
            shortcutSlot.disabled = true;
            shortcutSlot.disableFocus = true;
            shortcutSlot
            
            m_ShortcutSlotsArray.push(shortcutSlot);
        }

        Shortcut.SignalHotkeyChanged.Connect(SlotHotkeyChanged, this);
        Shortcut.SignalShortcutAdded.Connect( SlotShortcutAdded, this  );
        Shortcut.SignalShortcutRemoved.Connect( SlotShortcutRemoved, this );
        Shortcut.SignalShortcutMoved.Connect( SlotShortcutMoved, this );
        Shortcut.SignalSwapShortcut.Connect( SlotSwapShortcut, this);
        Shortcut.SignalShortcutStatChanged.Connect( SlotShortcutStatChanged, this );
        Shortcut.SignalCooldownTime.Connect( SlotCooldownTime, this );
        Shortcut.SignalShortcutUsed.Connect( SlotShortcutUsed, this );
        Shortcut.SignalShortcutsRefresh.Connect( ShortcutsRefresh, this );
   /*  
        Shortcut.SignalShortcutEnabled.Connect( SlotShortcutEnabled, this );
        Shortcut.SignalShortcutRangeEnabled.Connect( SlotShortcutRangeEnabled, this );
        Shortcut.SignalShortcutAddedToQueue.Connect( SlotShortcutAddedToQueue, this );
        Shortcut.SignalShortcutRemovedFromQueue.Connect( SlotShortcutRemovedFromQueue, this );
    */
        
        Shortcut.RefreshShortcuts( m_StartSlot, MAX_POCKET_SIZE );
        SlotHotkeyChanged();
    }

    //Slot Hotkey Changed
    private function SlotHotkeyChanged(hotkeyID:Number):Void
    {
        for (var i:Number = 0; i < MAX_POCKET_SIZE; i++)
        {
            var hotkeyLabel:TextField = m_WindowMC.i_Content["m_ShortcutSlot_" + i].m_HotkeyLabel.m_HotkeyText;
            hotkeyLabel.text = "";
            hotkeyLabel.text = GetHotkeyLabel(i);

            if (m_Slots[i])
            {
                var shortcutLabel:String = GetHotkeyLabel(i);
                
                m_Slots[i].GetSlotMC().m_HotkeyLabel.m_HotkeyText.text = "";
                m_Slots[i].GetSlotMC().m_HotkeyLabel.m_HotkeyText.text = shortcutLabel;
                
                var inventoryID:ID32 = m_Slots[i].GetInventoryID();
                var inventoryPosition:Number = m_Slots[i].GetData().m_InventoryPos;
                
                SignalUpdateInventoryLabelAndAnimation.Emit(true, inventoryID, inventoryPosition, shortcutLabel);
            }
        }
    }
    
    //Get Hotkey Label
    private function GetHotkeyLabel(index:Number):String
    {
        return "<variable name=\"hotkey_short:InventoryShortcuts_" + (index + 1) + "\"/>";
    }

    public function CreateSlot(gridPosition:Point, slotID:Number, itemData:InventoryItem, x:Number, y:Number)
    {
        if (gridPosition.y >= m_NumRows)
        {
            return;
        }
        
        var mc:MovieClip = m_WindowMC.i_Content.attachMovie("IconSlotTransparent", "slot_" + m_WindowMC.UID(), m_WindowMC.i_Content.getNextHighestDepth());
        mc._x += x;
        mc._y += y;
        
        var itemSlot:ItemSlot = new ItemSlot(m_InventoryId, slotID, mc);
        itemSlot.SetFilteringSupport( true );
        itemSlot.SetData(itemData);
        itemSlot.SignalDelete.Connect(SlotDeleteItem, this);
        itemSlot.SignalMouseDown.Connect(SlotMouseDownItem, this);
        itemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
        itemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
        itemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
        m_Slots[slotID] = itemSlot;
        
        m_NumItems++;

        UpdateItemLabelAndAnimation(slotID);
    }
    
    //Get Shortcut Slot At Index
    public function GetShortcutSlotAtIndex(shortcutsSlotIndex:Number):ItemSlot
    {
        return m_Slots[shortcutsSlotIndex];
    }
    
    //Update Item Label And Animation
    public function UpdateItemLabelAndAnimation(shortcutSlotIndex:Number):Void
    {
        var itemSlotClip:MovieClip = m_Slots[shortcutSlotIndex].GetSlotMC();
        var inventoryID:ID32 = m_Slots[shortcutSlotIndex].GetInventoryID();
        var inventoryPosition:Number = m_Slots[shortcutSlotIndex].GetData().m_InventoryPos;
        var shortcutLabel:String = GetHotkeyLabel(shortcutSlotIndex);
        
        if (!itemSlotClip.m_HotkeyLabel)
        {
            itemSlotClip.attachMovie("HotkeyLabel", "m_HotkeyLabel", itemSlotClip.getNextHighestDepth());
            itemSlotClip.m_HotkeyLabel.m_HotkeyText.text = "";
            itemSlotClip.m_HotkeyLabel.m_HotkeyText.text = shortcutLabel;
        }
        
        if (!itemSlotClip.m_UseAnimation)
        {
            itemSlotClip.attachMovie("UseAnimation", "m_UseAnimation", itemSlotClip.getNextHighestDepth());
            itemSlotClip.m_UseAnimation._width = itemSlotClip.i_Background._width;
            itemSlotClip.m_UseAnimation._height = itemSlotClip.i_Background._height;
        }
        
        SignalUpdateInventoryLabelAndAnimation.Emit(true, inventoryID, inventoryPosition, shortcutLabel);
    }
    
    public function CreateEmptySlot(gridPosition:Point, slotID:Number)
    {
    }
    
    public function AddItemAt(slotID:Number, itemData:InventoryItem, dstX:Number, dstY:Number)
    {
    }
    
    public function AddItem(slotID:Number, itemData:InventoryItem)
    {
    }
    
    public function AddItemToExistingSlot(slotID:Number, itemData:Object)
    {
    }
    
    public function AddItemAtGridPosition(slotID:Number, itemData:InventoryItem, gridPosition:Point)
    {
    }

    public function RemoveItem(itemID:Number):Boolean
    {
        var itemSlot:ItemSlot = m_Slots[itemID];

        if (itemSlot)
        {
            var inventoryID:ID32 = itemSlot.GetInventoryID();
            var inventoryPosition:Number = itemSlot.GetData().m_InventoryPos;

            SignalUpdateInventoryLabelAndAnimation.Emit(false, inventoryID, inventoryPosition, undefined);
            
            itemSlot.Clear();
            
            var mc = itemSlot.GetSlotMC();
            
            if (mc != undefined)
            {
                mc.removeMovieClip();
            }
            
            m_Slots[itemID] = undefined;
            m_NumItems--;
            
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public function UseShortcut(position:Number):Void
    {
        Shortcut.UseShortcut( position+m_StartSlot);
    }
    
    public function AddShortcut(srcInventoryID:ID32, srcInventorySlot:Number, gridPosition:Point):Void
    {
        var inventory:Inventory = new Inventory(srcInventoryID);
        var itemData:InventoryItem = inventory.GetItemAt(srcInventorySlot);

        Shortcut.AddItem( m_StartSlot + gridPosition.x, srcInventoryID, itemData.m_InventoryPos);
    }

    public function MoveShortcut(from:Number, to:Number):Void
    {
        Shortcut.MoveShortcut( from+m_StartSlot, to+m_StartSlot);
    }

    public function RemoveShortcut(position:Number):Void
    {
        Shortcut.RemoveFromShortcutBar(position+m_StartSlot);
    }
    
    private function IsItemShortcut(itemPos:Number):Boolean
    {
        var slotNo:Number = itemPos - m_StartSlot;
        var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
        
        if ( slotNo >= 0 && slotNo < MAX_POCKET_SIZE /*&& shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_ItemShortcut*/)
        {
            return true;
        }
        return false;
    }
    
    private function SlotCooldownTime( itemPos:Number, cooldownStart:Number, cooldownEnd:Number,  cooldownFlags:Number ) : Void
    {
        var shortcutSlot:Number = itemPos - m_StartSlot;
        
        var currentTime = com.GameInterface.Utils.GetGameTime()
        var currentDuration =  currentTime - cooldownStart;
        var timeLeft = cooldownEnd - currentTime;
        
        SetCooldown(shortcutSlot, timeLeft);
    }
    
    public function SetCooldownInventoryItem(inventoryPos:Number, time:Number)
    {
        for (var key:String in m_Slots )
        {
            var itemData:InventoryItem = m_Slots[key].GetData()
            if (itemData.m_InventoryPos == inventoryPos)
            {
                if (time > 0)
                {
                    SetCooldown(m_Slots[key].GetSlotID(), time);
                }
                else
                {
                    RemoveCooldown(m_Slots[key].GetSlotID());
                }
            }
        }
    }
    
    public function SetCooldown(slotID:Number, seconds:Number)
    {
        var itemSlot:ItemSlot = m_Slots[slotID];
        
        if (itemSlot && seconds > 0)
        {
            itemSlot.SetCooldown(seconds);
        }
    }
    
    public function RemoveCooldown(slotID:Number)
    {
        var itemSlot:ItemSlot = m_Slots[slotID];
        if (itemSlot)
        {
            itemSlot.RemoveCooldown();
        }        
    }
    
    public function ShortcutsRefresh() : Void
    { 
        Shortcut.RefreshShortcuts( m_StartSlot, MAX_POCKET_SIZE );
    }
    
    /// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
    private function SlotShortcutAdded( itemPos:Number) : Void
    {
        var slotNo:Number = itemPos - m_StartSlot;
        var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];

        if ( slotNo >= 0 && slotNo < MAX_POCKET_SIZE && shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_ItemShortcut)
        {
            var inventory:Inventory = new Inventory(shortcutData.m_InventoryId);
            if (m_Slots[slotNo] != undefined)
            {
                SlotShortcutRemoved(itemPos);
            }
            CreateSlot(new Point(slotNo,0), slotNo, inventory.GetItemAt(shortcutData.m_InventoryPos), CalculateSlotPosX(slotNo), CalculateSlotPosY(0));
        }
    }
    
    private function SlotShortcutMoved( p_from:Number, p_to:Number ) : Void
    { 
        SlotShortcutRemoved(p_to);
        SlotShortcutRemoved(p_from);
        
        SlotShortcutAdded(p_to);
        if (Shortcut.m_ShortcutList.hasOwnProperty(p_from+""))
        {
            SlotShortcutAdded(p_from);
        }
    }
    
    private function SlotSwapShortcut(itemPos:Number, templateID:Number):Void
    {
        ShortcutsRefresh();
    }
    
    public function RemoveAllShortcuts():Void
    {
        for (var i:Number = m_StartSlot; i < m_StartSlot+ MAX_POCKET_SIZE; ++i )
        {
            Shortcut.RemoveFromShortcutBar(i);
        }
    }
    
    private function SlotShortcutRemoved(itemPos:Number):Void
    {
        if (IsItemShortcut(itemPos))
        {
            RemoveItem(itemPos - m_StartSlot);
        }
    }
    
    private function SlotShortcutStatChanged( itemPos:Number, stat:Number, value:Number ) : Void
    {
        if (IsItemShortcut(itemPos))
        {
            if (stat == _global.Enums.Stat.e_StackSize)
            {
                var shortcutSlot:Number = itemPos - m_StartSlot;
                var itemSlot:ItemSlot = m_Slots[shortcutSlot];
                if (itemSlot != undefined)
                {
                    var inventory:Inventory = new Inventory(itemSlot.GetInventoryID());
                    var inventoryPosition:Number = itemSlot.GetData().m_InventoryPos
                    itemSlot.UpdateStackSize(inventory.GetItemAt(inventoryPosition));
                    return;
                }
            }
            else
            {
                Shortcut.RefreshShortcuts(itemPos, 1);
            }
        }
    }
    
    public function GetItemSlot(itemID:Number):ItemSlot
    {
        return m_Slots[itemID];
    }
    
    public function CloseAllTooltips()
    {
        for (var i:Number = 0; i < MAX_POCKET_SIZE; i++ )
        {
            if (m_Slots[i] != undefined)
            {
                m_Slots[i].CloseTooltip();
            }
        }
    }

    private function SlotShortcutUsed(itemPos:Number) : Void
    {
        if (IsItemShortcut(itemPos))
        {
            var shortcutSlotIndex:Number = itemPos - m_StartSlot;
            var targetItem:MovieClip = m_Slots[shortcutSlotIndex].GetSlotMC();
            var inventoryID:ID32 = m_Slots[shortcutSlotIndex].GetInventoryID();
            var inventoryPosition:Number = m_Slots[shortcutSlotIndex].GetData().m_InventoryPos;
            
            targetItem.m_UseAnimation.gotoAndPlay("Start");
            
            SignalAnimateInventoryShortcut.Emit(inventoryID, inventoryPosition);
        }
    }
    
    private function SlotStartSplitItem(itemSlot:ItemSlot)
    {
    }
}
