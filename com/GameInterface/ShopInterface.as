import com.Utils.ID32;
import com.Utils.Signal;
intrinsic class com.GameInterface.ShopInterface
{
	
	public function ShopInterface(shopID:ID32);
	public function BuyItem(itemPos:Number);
    public function SellItem(inventoryID:ID32, itemPos:Number);
    public function RepairItem(inventoryID:ID32, itemPos:Number);
    public function RepairAllItems();
	public function PreviewItem(itemPos:Number);
    public function CanPreview(itemPos:Number):Boolean;
    public function CloseShop();
    public function UndoSell();
    public function GetNumUndoItems() : Number;
    public function UpdateShopItems();
    public function IsVendorSellOnly():Boolean;
	
	public var SignalCloseShop:Signal;
	public var SignalShopItemsUpdated:Signal;
	
	public static var SignalOpenShop:Signal;
	
	public var m_Items:Array;
}