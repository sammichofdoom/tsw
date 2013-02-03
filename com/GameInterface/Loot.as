import com.Utils.ID32;
import com.Utils.Signal;

intrinsic class com.GameInterface.Loot
{
    public function Loot( lootBagID:ID32 );
    
    public function TryLootCash():Void;

	public function TryLootItem(itemPos:Number, charID:ID32, desiredPosition:Number) : Void;

    public function TryLootAll():Void;
    
    //public function IsInMasterLootTransaction(itemPos:Number):Boolean;

    public function GetPersonalItemDropStat(itemPos:Number):Number;
    
    public function Close():Void;

    public var SignalChanged:Signal; // -> SlotChanged( lootBagID:com.Utils.ID32 )
    
    public var SignalClose:Signal; // -> SlotClose( )
    
    public static var SignalNewLockedItem:Signal;
}
