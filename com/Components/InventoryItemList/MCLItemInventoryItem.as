import com.GameInterface.InventoryItem
import com.Utils.ID32;
import com.Components.MultiColumnList.MCLItem;

class com.Components.InventoryItemList.MCLItemInventoryItem extends MCLItem
{
	public static var INVENTORY_ITEM_COLUMN_ICON			= 0;
	public static var INVENTORY_ITEM_COLUMN_NAME			= 1;
	public static var INVENTORY_ITEM_COLUMN_BUY_PRICE		= 2;
	public static var INVENTORY_ITEM_COLUMN_SELL_PRICE		= 3;
	public static var INVENTORY_ITEM_COLUMN_REPAIR_PRICE	= 4;
    public static var INVENTORY_ITEM_COLUMN_RANK            = 5;
    public static var INVENTORY_ITEM_COLUMN_SELLER          = 6;
    public static var INVENTORY_ITEM_COLUMN_EXPIRES         = 7;
    public static var INVENTORY_ITEM_COLUMN_RECURRENT       = 8;
    public static var INVENTORY_ITEM_COLUMN_ORIGIN          = 9;
	
	public var m_InventoryItem:InventoryItem
	public var m_InventoryId:ID32
    public var m_Seller:String;
    public var m_Expires:String;
    public var m_Recurrent:Boolean;
    public var m_Origin:String;
	
	public function MCLItemInventoryItem(inventoryItem:InventoryItem, inventoryId:ID32)
	{
		super(inventoryItem.m_InventoryPos);

		m_InventoryItem = inventoryItem;
		m_InventoryId = inventoryId;
	}
	
	public function Compare(sortColumn:Number, item:MCLItem)
	{
		var otherItem:MCLItemInventoryItem = MCLItemInventoryItem(item);
		
		switch(sortColumn)
		{
        case INVENTORY_ITEM_COLUMN_ICON:
            {
                return CompareItems(m_InventoryItem, otherItem.m_InventoryItem);
            }
		case INVENTORY_ITEM_COLUMN_NAME:
			{
				return CompareString(m_InventoryItem.m_Name, otherItem.m_InventoryItem.m_Name);
			}
		case INVENTORY_ITEM_COLUMN_BUY_PRICE:
			{
				return CompareBuyPrice(m_InventoryItem, otherItem.m_InventoryItem);
			}
		case INVENTORY_ITEM_COLUMN_SELL_PRICE:
			{
				return CompareSellPrice(m_InventoryItem, otherItem.m_InventoryItem);
			}
		case INVENTORY_ITEM_COLUMN_REPAIR_PRICE:
			{
				return CompareNumber(m_InventoryItem.m_RepairPrice, otherItem.m_InventoryItem.m_RepairPrice);
			}
        case INVENTORY_ITEM_COLUMN_RANK:
            {
                return CompareNumber(m_InventoryItem.m_Rank, otherItem.m_InventoryItem.m_Rank);
            }
        case INVENTORY_ITEM_COLUMN_SELLER:
            {
                return CompareString(m_Seller, otherItem.m_Seller);
            }
        case INVENTORY_ITEM_COLUMN_EXPIRES:
            {
                return CompareString(m_Expires, otherItem.m_Expires);
            }
        case INVENTORY_ITEM_COLUMN_RECURRENT:
            {
                return CompareString(m_Recurrent.toString(), otherItem.m_Recurrent.toString());
            }   
        case INVENTORY_ITEM_COLUMN_ORIGIN:
            {
                return CompareString(m_Origin, otherItem.m_Origin);
            }   
		}
		
		return super.Compare(sortColumn, item);
	}
	
	public function CompareSellPrice(item1:InventoryItem, item2:InventoryItem)
	{
		var compare:Number = CompareNumber(item1.m_TokenCurrencySellPrice1, item2.m_TokenCurrencySellPrice1);
		if (compare == 0)
		{
			compare = CompareNumber(item1.m_TokenCurrencySellPrice2, item2.m_TokenCurrencySellPrice2);
		}
		return compare;
	}
	
	public function CompareBuyPrice(item1:InventoryItem, item2:InventoryItem)
	{
		var compare:Number = CompareNumber(item1.m_TokenCurrencyPrice1, item2.m_TokenCurrencyPrice1);
		if (compare == 0)
		{
			compare = CompareNumber(item1.m_TokenCurrencyPrice2, item2.m_TokenCurrencyPrice2);
		}
		return compare;
	}
    
    public function CompareItems(item1:InventoryItem, item2:InventoryItem):Number
    {
        var valueItem1:Number = ((item1.m_CanUse)?1000:0) + (item1.m_Rarity * 100) + (item1.m_Rank * 10 -1) + item1.m_StackSize;
        var valueItem2:Number = ((item2.m_CanUse)?1000:0) + (item2.m_Rarity * 100) + (item2.m_Rank * 10 -1) + item2.m_StackSize;
        
        //Change sign to  show bigger values first
        valueItem1 *= -1;
        valueItem2 *= -1;
        
        var compare:Number = CompareNumber(valueItem1, valueItem2);

        return compare;
    }
}