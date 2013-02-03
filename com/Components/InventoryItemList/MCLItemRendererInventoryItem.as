import com.Components.InventoryItemList.MCLItemIconCellRenderer;
import com.Components.InventoryItemList.MCLItemPriceCellRenderer;
import com.Components.InventoryItemList.MCLItemInventoryItem;
import com.Components.MultiColumnList.MCLBaseCellRenderer;
import com.Components.MultiColumnList.MCLItemValueData;
import com.Components.MultiColumnList.MCLItem;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.MCLItemRenderer;
import com.Utils.ID32;

import com.GameInterface.Game.Character;
import com.GameInterface.InventoryItem;

class com.Components.InventoryItemList.MCLItemRendererInventoryItem extends MCLItemRenderer
{
	var m_IconRenderer:MCLItemIconCellRenderer;
	public function MCLItemRendererInventoryItem()
	{
		super();
		//Need to only make the iconbackground once, as it is heavy
		m_IconRenderer = CreateIconRenderer(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ICON, 40);
		SetSelected(false);
		m_IconRenderer.SetVisible(false);
		
	}
	
	public function SetSelected(selected:Boolean)
	{
		if (selected)
		{
			m_Background._alpha = 100;
		}
		else
		{
			m_Background._alpha = 0;
		}
	}
	
	public function SetData(listView:MultiColumnListView, data:MCLItem)
	{
		super.SetData(listView, data); 
        var inventoryData:MCLItemInventoryItem = MCLItemInventoryItem(data);
		var inventoryItem:InventoryItem = inventoryData.m_InventoryItem;
		var inventoryId:ID32 = inventoryData.m_InventoryId;
		m_IconRenderer.SetVisible(false);
		
		var clientChar:Character = Character.GetClientCharacter();

		if (inventoryItem != undefined)
		{
			var canBuy:Boolean = inventoryItem.m_CanBuy == undefined || inventoryItem.m_CanBuy;
			var columns:Array = listView.GetColumnTable();
			var columnX:Number = 0;
			for (var i:Number = 0; i < columns.length; i++)
			{
				if (columns[i].IsDisabled())
				{
					continue;
				}
				
				var columnRenderer:MCLBaseCellRenderer;
				switch(columns[i].m_Id)
				{
				case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ICON:
					{
						m_IconRenderer.SetInventoryItem(inventoryId, inventoryItem);
						m_IconRenderer.SetVisible(true);
						m_IconRenderer.SetPos(columnX, 0);
						m_IconRenderer.SetAlpha(canBuy ? 100 : 30);
					}
					break;
				case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_NAME:
					{
						var valueData = new MCLItemValueData();
						valueData.m_Text = inventoryItem.m_Name;
						valueData.m_TextColor = !inventoryItem.m_CanUse ? 0xFF0000 : com.Utils.Colors.GetItemRarityColor(inventoryItem.m_Rarity);
						columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width);
					}
					break;
				case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_BUY_PRICE:
					{
						var priceColor1:Number = 0xFFFFFF
						var priceColor2:Number = 0xFFFFFF; 
						if (inventoryItem.m_TokenCurrencyType1 != undefined && inventoryItem.m_TokenCurrencyType1 != 0)
						{
							priceColor1 = clientChar.GetTokens(inventoryItem.m_TokenCurrencyType1) >= inventoryItem.m_TokenCurrencyPrice1 ? 0xFFFFFF : 0xFF0000;
						}
						if (inventoryItem.m_TokenCurrencyType2 != undefined && inventoryItem.m_TokenCurrencyType2 != 0)
						{
							priceColor2 = clientChar.GetTokens(inventoryItem.m_TokenCurrencyType2) >= inventoryItem.m_TokenCurrencyPrice2 ? 0xFFFFFF : 0xFF0000;
						}
						columnRenderer = CreatePriceRenderer(columns[i].m_Id, columns[i].m_Width, inventoryItem.m_TokenCurrencyType1, inventoryItem.m_TokenCurrencyPrice1, inventoryItem.m_TokenCurrencyType2, inventoryItem.m_TokenCurrencyPrice2, priceColor1, priceColor2);
					}
					break;
				case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_SELL_PRICE:
					{
						columnRenderer = CreatePriceRenderer(columns[i].m_Id, columns[i].m_Width, inventoryItem.m_TokenCurrencySellType1, inventoryItem.m_TokenCurrencySellPrice1, inventoryItem.m_TokenCurrencySellType2, inventoryItem.m_TokenCurrencySellPrice2, 0xFFFFFF, 0xFFFFFF);
					}
					break;
				case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_REPAIR_PRICE:
					{
						var priceColor1:Number = clientChar.GetTokens(_global.Enums.Token.e_Cash) >= inventoryItem.m_RepairPrice ? 0xFFFFFF : 0xFF0000;
						columnRenderer = CreatePriceRenderer(columns[i].m_Id, columns[i].m_Width, _global.Enums.Token.e_Cash, inventoryItem.m_RepairPrice, undefined, undefined, priceColor1, undefined);
					}
					break;
                case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_RANK:
					{   
                        var valueData = new MCLItemValueData();
						valueData.m_Number = inventoryItem.m_Rank;
                        
                        valueData.m_TextColor = inventoryItem.m_CanUse ? 0xFFFFFF : 0xFF0000;
                        
                        columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width);
					}
					break;
                case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_SELLER:
					{
						var valueData = new MCLItemValueData();
						valueData.m_Text = inventoryData.m_Seller;
                        
                        columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width);
					}
					break;
                case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_EXPIRES:
					{
						var valueData = new MCLItemValueData();
						valueData.m_Text = inventoryData.m_Expires;
                        
                        columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width);
					}
					break;
                case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_RECURRENT:
					{
                        if (inventoryData.m_Recurrent)
                        {
                            columnRenderer = CreateMovieClipRenderer(columns[i].m_Id, "RecurrentCheck", columns[i].m_Width);                            
                        }
					}
					break;
                case MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ORIGIN:
					{
						var valueData = new MCLItemValueData();
						valueData.m_Text = inventoryData.m_Origin;
                        
                        columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width);
					}
					break;                    
				}
				if (columnRenderer != undefined)
				{
					columnRenderer.SetAlpha(canBuy ? 100 : 50);
					columnRenderer.SetPos(columnX, 0);
					m_ColumnViews.push(columnRenderer);
				}
				columnX += columns[i].m_Width + listView.GetHeaderSpacing();
			}
		}
	}
	
	private function CreateIconRenderer(id:Number, width:Number) : MCLItemIconCellRenderer
	{
		var clipRenderer:MCLItemIconCellRenderer = new MCLItemIconCellRenderer(this, id);
		clipRenderer.SetSize(width, m_Background._height);
		return clipRenderer;
	}
	
	private function CreatePriceRenderer(id:Number, width:Number, type1:Number, price1:Number, type2:Number, price2:Number, priceColor1:Number, priceColor2:Number) : MCLBaseCellRenderer
	{
		var clipRenderer:MCLItemPriceCellRenderer = new MCLItemPriceCellRenderer(this, id, type1, price1, type2, price2, priceColor1, priceColor2);
		clipRenderer.SetSize(width, m_Background._height);
		return clipRenderer;
	}
	
	public function Clear()
	{
		super.Clear();
		m_IconRenderer.Remove();
	}
	
	public function UpdateLayout(listView:MultiColumnListView)
	{
		super.UpdateLayout(listView);
		var columns:Array = listView.GetColumnTable();		
		
		for (var i:Number = 0; i < columns.length; i++)
		{
			if (columns[i].m_Id == MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ICON)
			{
				m_IconRenderer.SetSize(columns[i].m_Width, m_Background._height);
			}
		}
	}
}