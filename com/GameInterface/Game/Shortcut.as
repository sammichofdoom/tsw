import flash.external.ExternalInterface;
import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.Game.Shortcut 
{ 
    /// Associavite array of all the shortcut the player has
    public static var m_ShortcutList:Object;
  
    /// Get information about the item equipped at itemPos in the shortcut interface.
    /// @param fromPos:Number   The position pf the item to query
    ///public static function GetShortcutData( itemPos:Number ) : Object;

    /// Forces the client to send add or remove signal for each of the slots in the range.
    /// @param fromPos:Number   The position to start the refersh from.
    /// @param count:Number     Number of positions to refresh.
    public static function RefreshShortcuts( fromPos:Number, count:Number ) : Void;

    /// Try to move a shortcut to a new pos.
    /// If the move was allowed, SignalShortcutMoved will be triggered.
    /// @param fromPos:Number   The position to move from.
    /// @param toPos:Number     The position to move to.
    public static function MoveShortcut( fromPos:Number, toPos:Number ) : Void;

    /// Try to remove a shortcut.
    /// SignalShortcutRemoved will be triggered if the remove was legal.
    /// @param itemPos:Number   The shortcut to remove.
    public static function RemoveFromShortcutBar( itemPos:Number ) : Boolean;

    /// Try to use a shortcut.
    /// You will not know the outcome, but you might get a SignalCooldownTime.
    /// @param itemPos:Number   The shortcut to use.
    public static function UseShortcut( itemPos:Number ) : Void;

    /// Add a spell to a slot. SignalShortcutAdded will be called on success.
    /// @param itemPos:Number   The position on the bar.
    /// @param spellId:Number   The spell to auto add.
    public static function AddSpell( itemPos:Number, spellId:Number ) : Void;
    
    /// Add an item to a slot. SignalShortcutAdded will be called on success.
    /// @param shortcutPos:Number   The position on the bar.
    /// @param inventoryId:Number   From which inventory its added.
    /// @param itemPos:Number   The itemposition in the inventory to add.
    public static function AddItem( shortcutPos:Number, inventoryId:ID32, itemPos:Number) : Void;
    
    /// Gets the number of usable pocket slots
    public static function GetNumPocketSlots( ) : Number;
    
    /// Gets the max number of pocket slots
    public static function GetMaxPocketSlots( ) : Number;
    
	//Checks wether an ability is equipped
    public static function IsSpellEquipped(spellId:Number):Boolean;
	
    /// Signal sent when a shortcut has been added.
    /// This also happens when you teleport to a new pf.
    /// Note that you might get an SignalShortcutEnabled right afterward if the shortcut is disabled. And SignalCooldownTime if it's in cooldown.
    /// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
    /// @param name:String      The name of the item in LDB format.
    /// @param icon:String      The icon resource information.
    /// @param itemClass:Number The type of shortcut. See Enums.StatItemClass
    public static var SignalShortcutAdded:Signal; // -> OnSignalShortcutAdded( itemPos:Number, name:String, icon:String, itemClass:Number, colorLine:Number )

    /// Signal sent when a shortcut has been removed.
    /// This will not be sent if the shortcut changes position, moved.
    /// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
    public static var SignalShortcutRemoved:Signal; // -> OnSignalShortcutRemoved( itemPos:Number )

    /// Signal sent when a shortcut has been move to some other spot.
    /// No add/remove signal will be triggered.
    /// @param fromPos:Number   The position the item was move from.
    /// @param toPos:Number     The position the item was move to.
    public static var SignalShortcutMoved:Signal; // -> OnSignalShortcutMoved( fromPos:Number, toPos:Number )
    
    /// Signal sent when a hotkey is changed
    /// @param hotkeyId:Number  ID of the changed hotkey
    public static var SignalHotkeyChanged:Signal;

    /// Signal sent when a shortcut changed one of it's stats. Probably most usefull for stacksize changes.
    /// @param itemPos:Number   The position of the item.
    /// @param stat:Number      The stat that changed. See Enums/Stats.as
    /// @param value:Number     The new value for the stat.
    public static var SignalShortcutStatChanged:Signal; // -> OnSignalShortcutStatChanged( itemPos:Number, stat:Number, value:Number )

    /// Signal sent when a shortcut is enabled/disabled.
    /// Will also be send when you enter a new playfield.
    /// @param itemPos:Number   The position of the item.
    /// @param enabled:Boolean    Enabled/Disabled
    public static var SignalShortcutEnabled:Signal; // -> OnSignalShortcutEnabled( itemPos:Number, enabled:Boolean )
    
        /// Signal sent when a shortcut is enabled/disabled via range.
    /// @param itemPos:Number   The position of the item.
    /// @param enabled:Boolean   Enabled/Disabled
    public static var SignalShortcutRangeEnabled:Signal; // -> OnSignalShortcutRangeEnabled( itemPos:Number, enabled:Boolean )

    /// Signal sent when a shortcut is enabled/disabled via resource.
    /// @param itemPos:Number   The position of the item.
    /// @param enabled:Boolean   Enabled/Disabled
//    public static var SignalShortcutResourceEnabled:Signal; // -> SlotSignalShortcutResourceEnabled:( itemPos:Number, enabled:Boolean )
    
    /// Signal sent when a shortcut is used
    /// @param itemPos:Number   The position of the item.
    public static var SignalShortcutUsed:Signal; // -> OnSignalShortcutUsed( itemPos:Number)
    
    /// Signal sent when a shortcut is added to the queue
    /// @param itemPos:Number   The position of the item.
    public static var SignalShortcutAddedToQueue:Signal;
    
    /// Signal sent when a shortcut is removed from the queue
    /// @param itemPos:Number   The position of the item.
    public static var SignalShortcutRemovedFromQueue:Signal;

    /// Signal sent when a shortcut enters cooldown.
    /// Will also be send when you enter a new playfield.
    /// @param itemPos:Number   The position of the item.
    /// @param seconds:Number   The cooldown time in seconds left.
    /// @param cooddownType:Number  The cooldown type from Enums.TemplateLock...
    public static var SignalCooldownTime:Signal; // -> OnSignalCooldownTime( itemPos:Number, seconds:Number, cooldownType:Number )

    /// Signal sent when the shortcut list has been loaded or when something else has forced it to be refreshed.
    /// So this will be called on login at least.
    /// Normal response to this call is RefreshShortcuts( fromPos, count )
    public static var SignalShortcutsRefresh:Signal; // -> OnSignalShortcutsRefresh() 

    /// Signal sent when a shortcut enters or exits max momentum (all resources filled up or not).
    /// @param itemPos:Number   The position of the item.
//    public static var SignalShortcutMaxMomentumEnabled:Signal; // -> SlotSignalShortcutMaxMomentumEnabled( itemPos:Number, enabled:Boolean )

    //Signal set when a shortcut should be swapped with another one.
    //@param itemPos:Number the position of the item to swap
    //@param templateID:Number the id of the new shortcut
    public static var SignalSwapShortcut:Signal; //itemPos:Number, templateID:Number
    
    
    ///Signal sent when the number of pocket slots changes
    public static var SignalNumPocketSlotsChanged;
}
