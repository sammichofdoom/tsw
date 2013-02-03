import com.Utils.ID32;
import com.Utils.Signal;

/// One instance of this class represent an inventory.
/// First you create it, then you regsiter it, then you use it, and in the end when about to delete it, you unregister it.
/// The idea is that you should extend/inherit from this class. Override the empty callback functions, like ItemAdded and such, to do your stuff.
intrinsic class com.GameInterface.InventoryBase
{
  /// This is the array of items in this inventory.
  /// The arrays size represent the maxsize of this inventory. The size may change. Signals will be sent in that case.
  /// Gamecode handles the members and content will automaticaly change to reflect the GC inventory.
  /// Signals will be sent right after changes has occurred to the array.
  /// The array is populated with com.GameInterface.InventoryItem objects.
    
  public var m_Items:Array;


  /// Type of inventory. ex. Enums.InvType.e_Type_GC_WeaponContainer is what you wear.
  /// e_Type_GC_WeaponContainer
  /// e_Type_GC_BackpackContainer
  /// e_Type_GC_BankContainer
  /// e_Type_GC_ChestContainer
  /// e_Type_GC_TradeContainer
  /// e_Type_GC_GuildContainer
  /// e_Type_GC_OverflowContainer
  /// e_Type_GC_ShopContainer
  /// e_Type_GC_ResourceContainer
  /// e_Type_GC_QuestContainer
  /// e_Type_MailInventory
  /// e_Type_LootInventory
  /// e_Type_GC_BeltInventory
  /// e_Type_GC_TradepostContainer
    public function get m_InventoryID():ID32;

  /// Constructor.
    public function InventoryBase( invID:ID32 );
  

  /// Move an item from an inventory to another or the same.
  /// Note that when you add the item to the wear inventory (e_Type_GC_WeaponContainer) you can use dstPos = Enums.ItemEquipLocation.Wear_DefaultLocation
  /// to put the item at it's default location.
  /// @param srcInv  [in]  The inventory the move was done from.
  /// @param srcPos  [in]  The pos the item came from.
  /// @param dstPos  [in]  The position the item will have in this inventory.
  /// @param         [out] Returns an enum indicating if the move succeed or if it's not done yet (it's in a dialog).
    public function AddItem( srcInvID:com.Utils.ID32, srcPos:Number, dstPos:Number ) : Number;
    
  ///Equip temporarily the player with an item (until any server call is done)
  /// @param itemPos [in]  The item to preview.
  public function PreviewItem(itemPos:Number) : Void;
  ///Equip temporarily all the items from another player (until any server call is done)
  public function PreviewCharacter(characterID:ID32) : Boolean;

  /// Delete an item from this inventory. A confirmation dialog box will be shown from gamecode as a security meassure.
  /// @param itemPos [in]  The item to delete.
    public function DeleteItem( itemPos:Number ) : Void;
    
  /// Tries to use the given item. 
  /// @param itemPos [in]  The item to use.
  public function UseItem( itemPos:Number ) : Void;
    
  public function CanAddItemToShortcuts( itemPos:Number ) : Boolean;
  
  /// Tries to split a given item
  /// @param srcInvID [in] The id of the source inventory
  /// @param srcPos   [in]  The item to split.
  /// @param dstPos   [in]  where to split it to.
  /// @param itemPos  [in]  How much to split (How big will the resulting stack be).
  public function SplitItem(srcInvID:com.Utils.ID32, srcPos:Number, dstPos:Number, split:Number ) : Boolean;
  
  /// Tries to make a item link of the given item
  /// @param itemPos [in]  The item to make item link of.
  public function MakeItemLink( itemPos:Number) : Void;

  ///Gets the first free slot in this inventory, returns -1 if full
  public function GetFirstFreeItemSlot():Number;
  
  public function GetMaxItems():Number;
  
  public function GetInventoryID():ID32;
  
  public function IsInitialized():Boolean;
  
  private function CreateItem() : Void;
  
  /// Called from gamecode when an item is finished async loaded at the given pos.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param itemPos [in]  The position for this new item.
  public var SignalItemLoaded:Signal;
  
  /// Called from gamecode when an item is added to this inventory at the given pos.
  /// This will be called both when you get an item and if an item is moved from a different inventory to this.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param itemPos [in]  The position for this new item.
  public var SignalItemAdded:Signal; // -> SlotItemAdded( inventoryID:com.Utils.ID32, itemPos:Number )
  
  /// Called from gamecode when an item is moved within this inventory.
  /// If the toPos contains an item, then the two items swap position.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param fromPos [in]  Where the item was moved from.
  /// @param toPos   [in]  The items new position.
  public var SignalItemMoved:Signal; // -> SlotItemMoved( inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number )
  
  /// Called from gamecode when an item is removed from this inventory, either as a move or as a delete.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param itemPos [in]  Where the item was removed from.
  /// @param moved   [in]  True if the item moved to some other inventory.
  public var SignalItemRemoved:Signal; // -> SlotItemRemoved( inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
  
  /// Called from gamecode when an item changed somehow.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param itemPos [in]  The item in question.
  public var SignalItemChanged; // -> SlotItemChanged( inventoryID:com.Utils.ID32, itemPos:Number )
  
  /// Called from gamecode when a stat on an item changes.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param itemPos  [in]  Item in question.
  /// @param stat     [in]  The stat that changed.
  /// @param newValue [in]  The new value of for this stat.
  public var SignalItemStatChanged; // -> SlotItemStatChanged( inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number  )
  
  /// Called from gamecode when the inventory is expanded.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param newSize [in]  The new total size of the inventory. The m_Items will already have the new size.
  public var SignalInventoryExpanded; // -> SlotInventoryExpanded( inventoryID:com.Utils.ID32, newSize:Number  )
    /// Called from gamecode when the inventory is expanded.
	
    /// Called from gamecode when an item is on cooldown.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param itemPos [in]  The position in the inventory the item is
  /// @param seconds [in]  the number of seconds left in cooldown
  public var SignalItemCooldown; // -> SlotItemCooldownRemoved( inventoryID:com.Utils.ID32, itemPos;Number, seconds:Number)
  
    /// Called from gamecode when an item is removed from cooldown.
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param itemPos [in]  The position in the inventory the item is
  public var SignalItemCooldownRemoved; // -> SlotItemCooldownRemoved( inventoryID:com.Utils.ID32, itemPos )
}
