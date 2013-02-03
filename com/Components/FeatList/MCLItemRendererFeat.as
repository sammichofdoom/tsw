import com.Components.MultiColumnList.MCLItemRenderer;
import com.Components.MultiColumnList.MCLBaseCellRenderer;
import com.Components.MultiColumnList.MCLItem;
import com.Components.MultiColumnList.MCLItemValueData;
import com.Components.FeatList.MCLItemFeat;
import com.Components.FeatList.MCLFeatCostCellRenderer;
import com.Components.FeatList.MCLFeatTypeCellRenderer;
import com.Components.FeatList.MCLFeatIconCellRenderer;

import com.Components.MultiColumnListView;

import com.GameInterface.FeatData;

class com.Components.FeatList.MCLItemRendererFeat extends MCLItemRenderer
{
	public function MCLItemRendererFeat()
	{
		super();
		m_Background.m_PassiveStripes._visible = false;
	}
	
	public function SetData(listView:MultiColumnListView, data:MCLItem)
	{
		super.SetData(listView, data);
		var featItem:MCLItemFeat = MCLItemFeat(data);
		var featData:FeatData = featItem.m_FeatData;
		
		if (featData.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility || featData.m_SpellType == _global.Enums.SpellItemType.ePassiveAbility )
        {
			m_Background.m_PassiveStripes._visible = true;

		}
		
		if (featData != undefined)
		{
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
				case MCLItemFeat.FEAT_COLUMN_ICON:
					{
						columnRenderer = CreateIconRenderer(columns[i].m_Id, columns[i].m_Width, featData, false)
						MCLFeatIconCellRenderer(columnRenderer).SignalMouseDown.Connect(SlotIconMouseDown, this);
						MCLFeatIconCellRenderer(columnRenderer).SignalMouseUp.Connect(SlotIconMouseUp, this);		
					}
					break;
				case MCLItemFeat.FEAT_COLUMN_ICON_WITH_SYMBOL:
					{
						columnRenderer = CreateIconRenderer(columns[i].m_Id, columns[i].m_Width, featData, true)
						MCLFeatIconCellRenderer(columnRenderer).SignalMouseDown.Connect(SlotIconMouseDown, this);
						MCLFeatIconCellRenderer(columnRenderer).SignalMouseUp.Connect(SlotIconMouseUp, this);						
					}
					break;
				case MCLItemFeat.FEAT_COLUMN_NAME:
					{
						var valueData = new MCLItemValueData();
						valueData.m_Text = featData.m_Name;
						columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width)
					}
					break;
				case MCLItemFeat.FEAT_COLUMN_CATEGORY:
					{
						var valueData = new MCLItemValueData();
						valueData.m_Text = featItem.m_Category;
						columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width)
					}
					break;
				case MCLItemFeat.FEAT_COLUMN_TYPE:
					{
						columnRenderer = CreateTypeRenderer(columns[i].m_Id, columns[i].m_Width, featItem.m_WeaponType, featItem.m_WeaponRequirement)
					}
					break;
				case MCLItemFeat.FEAT_COLUMN_SUBTYPE:
					{
						var valueData = new MCLItemValueData();
						valueData.m_Text = featItem.m_SubType;
						columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width)
					}
					break;
				case MCLItemFeat.FEAT_COLUMN_EFFECT:
					{
						var valueData = new MCLItemValueData();
						valueData.m_Text = featItem.m_Effect;
						columnRenderer = CreateTextRenderer(columns[i].m_Id, valueData, columns[i].m_Width)
					}
					break;
				case MCLItemFeat.FEAT_COLUMN_COST:
					{
						columnRenderer = CreateCostRenderer(columns[i].m_Id, columns[i].m_Width, featData.m_Cost)
					}
					break;
				}
				
				columnRenderer.SetPos(columnX, 0);
				m_ColumnViews.push(columnRenderer);
				columnX += columns[i].m_Width + listView.GetHeaderSpacing();
			}
		}
		
	}
	
	private function SlotIconMouseUp(buttonindex:Number)
	{
		SlotMouseRelease(buttonindex);
	}
	
	private function SlotIconMouseDown(buttonindex:Number)
	{
		SlotMousePress(buttonindex);
	}
	
	private function CreateIconRenderer(id:Number, width:Number, featData:FeatData, addSymbol:Boolean) : MCLBaseCellRenderer
	{
		var clipRenderer:MCLFeatIconCellRenderer = new MCLFeatIconCellRenderer(this, id, featData, addSymbol);
		clipRenderer.SetSize(width, m_Background._height);
		return clipRenderer;
	}
	
	private function CreateTypeRenderer(id:Number, width:Number, weaponName:String, weaponRequirement:Number) : MCLBaseCellRenderer
	{
		var clipRenderer:MCLFeatTypeCellRenderer = new MCLFeatTypeCellRenderer(this, id, weaponName, weaponRequirement );
		clipRenderer.SetSize(width, m_Background._height);
		return clipRenderer;
	}
	
	private function CreateCostRenderer(id:Number, width:Number, featCost:Number) : MCLBaseCellRenderer
	{
		var clipRenderer:MCLFeatCostCellRenderer = new MCLFeatCostCellRenderer(this, id, featCost);
		clipRenderer.SetSize(width, m_Background._height);
		return clipRenderer;
	}
}