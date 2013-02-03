import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.NeedGreed
{	
    // NEED/GREED functions
	public static function Need(lootBagId:ID32, itemPos:Number):Void;
	public static function Greed(lootBagId:ID32, itemPos:Number):Void;
	public static function Pass(lootBagId:ID32, itemPos:Number):Void;
    public static function AcceptMasterLooterItem(lootBagId:ID32, itemPos:Number, acceptItem:Boolean):Void;

    // NEED/GREED signals
	public static var CloseNonModuleControlledGui:Signal; // no parameters - All NeedGreed windows must close. We're teleporting or something!
	public static var SignalNeedGreedForItemFromClientChar:Signal; // lootBagId:ID32, itemPos:Number - The client charater (us) used need, greed or pass on an item - close the window.
	public static var SignalCloseNeedGreedWindows:Signal; // lootBagId:ID32 - Close all NeedGreed items for this lootBagId (all itemPositions) - happens when the lootBag has been made Free4All or similar
	public static var SignalCreateNeedGreedWindow:Signal; // lootBagId:ID32, itemPos:Number, item:InventoryItem, timeout:Number (seconds) - Create a new NeedGreed window for the given lootBagId, position and with the given item
    
    // LOOT OPTION functions
    public static function SetLootOptions(lootMode:Number, needGreed:Boolean, lootThreshold:Number):Void;
    public static function GetCanChangeLootOptions():Boolean;
    public static function IsMasterLooter(characterId:ID32):Boolean;
    public static function GetLootMode():Number; // GroupLootMode (enum)
    public static function GetNeedGreed():Boolean;
    public static function GetLootThreshold():Number; // ItemPowerLevel_e (enum)
    
    // LOOT OPTION signals
    public static var SignalCanChangeLootOptionsChanged:Signal; // canChangeLootOptions:Boolean - Sets whether or not you are currently allowed to change the loot options (you are the group/raid leader)
    public static var SignalLootModeChanged:Signal; // newLootMode:GroupLootMode (enum) - Sets new loot mode
    public static var SignalNeedGreedChanged:Signal; // needGreed:Boolean - sets if need/greed is in use or not
    public static var SignalLootThresholdChanged:Signal; // newLootThreshold:ItemPowerLevel_e (enum) - Sets the new loot threshold
    public static var SignalItemOffered:Signal; //name:String, lootBagId:ID32, itemPosition:Number - Master Looter is offering an item
}