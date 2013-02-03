import com.Utils.ID32;
intrinsic class com.GameInterface.Game.ShortcutBase
{
    /// Get information about the item equipped at itemPos in the shortcut interface.
    /// @param fromPos:Number   The position pf the item to query
    public static function GetShortcutData( itemPos:Number ) : Object;

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
    public static function RemoveFromShortcutBar( itemPos:Number ) : Void;

    /// Try to use a shortcut.
    /// You will not know the outcome, but you might get a SignalCooldownTime.
    /// @param itemPos:Number   The shortcut to use.
    public static function UseShortcut( itemPos:Number, target:ID32 ) : Void;

    /// Add a spell to a slot. SignalShortcutAdded will be called on success.
    /// @param itemPos:Number   The position on the bar.
    /// @param spellId:Number   The spell to auto add.
    public static function AddSpell( itemPos:Number, spellId:Number ) : Void;
}
