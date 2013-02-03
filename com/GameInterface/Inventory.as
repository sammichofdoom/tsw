import com.Utils.ID32;
import com.Utils.Signal;
import com.GameInterface.InventoryItem;
import com.GameInterface.InventoryBase;

class com.GameInterface.Inventory extends InventoryBase
{
	
	public function Inventory( invID:ID32)
	{
		super(invID);
	}
	//Can return undefinded, if either the item does not exist in the slot, or it hasnt been loaded yet
	public function GetItemAt(index:Number) : InventoryItem
	{
		if (m_Items[index] != undefined)
		{
			return m_Items[index];
		}
		else
		{
			CreateItem(index);
			return m_Items[index];
		}
	}
}