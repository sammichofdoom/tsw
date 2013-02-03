import com.GameInterface.InventoryItem;
import com.Components.ItemComponent;
import com.GameInterface.Tooltip.*;
import com.Utils.ID32;
import mx.utils.Delegate;

class com.Components.InventoryItemList.MCLItemIconCellRenderer extends com.Components.MultiColumnList.MCLBaseCellRenderer
{
	private var m_Icon:ItemComponent;
	private var m_Tooltip:TooltipInterface;
	private var m_InventoryItem:InventoryItem;
	private var m_InventoryId:ID32;
	
	
	public function MCLItemIconCellRenderer(parent:MovieClip, id:Number)
	{
		super(parent, id);
		
		m_MovieClip = m_Parent.createEmptyMovieClip("m_Column_" +id,  m_Parent.getNextHighestDepth());
		
		m_Icon = ItemComponent(m_MovieClip.attachMovie( "Item", "m_Column_" + id, m_MovieClip.getNextHighestDepth()));
		m_Icon.onPress = function() { };
        m_Icon.onMouseMove = Delegate.create(this, SlotMouseMove);
       	m_MovieClip.onUnload = Delegate.create(this, SlotUnload);
	}
	
	function SlotUnload()
	{
		CloseTooltip();
	}
	
	public function SetInventoryItem(inventoryId:ID32, inventoryItem:InventoryItem)
	{
		m_InventoryItem = inventoryItem;
		m_InventoryId = inventoryId;
				
        m_Icon.SetData( inventoryItem , Math.random() * 750);
        m_Icon.SetStackSize(inventoryItem.m_StackSize);
	}
	
	public function SetVisible(visible:Boolean)
	{
		m_MovieClip._visible = visible;
	}
	
	public function SetSize(width:Number, height:Number)
	{
		var heightPercentage:Number = (height - 10) / m_MovieClip._height;
		var widthPercentage:Number = (width - 10) / m_MovieClip._width;
		
		var percentage:Number = Math.min(heightPercentage, widthPercentage);
		
		m_MovieClip._width *= percentage;
		m_MovieClip._height *= percentage;
		m_Icon._x = ((width - m_MovieClip._width) / 2) * (100 / m_MovieClip._xscale);
		m_Icon._y = ((height - m_MovieClip._height) / 2) * (100 / m_MovieClip._yscale);
	}
	
	public function GetDesiredWidth() : Number
	{
		return m_MovieClip._width; 
	}
	
	public function Remove()
	{
		SetVisible(false);
		CloseTooltip();
		if (m_Icon != undefined)
		{
			//only unload icon, dont remove this
			m_Icon.UnloadIcon();
		}
	}
	
	private function SlotMouseMove()
	{
		if (m_Icon.hitTest(_root._xmouse, _root._ymouse))
		{
			if (m_Tooltip == undefined)
			{
				OpenTooltip();
			}
		}
		else
		{
			if (m_Tooltip != undefined)
			{
				CloseTooltip();
			}
		}
	}
	
	public function SetAlpha(alpha:Number )
	{
		if (m_Icon != undefined)
		{
			m_Icon.SetAlpha(alpha);
		}
	}
	
	public function OpenTooltip() : Void
    {
		var tooltipData:TooltipData;
		if (m_InventoryId == undefined)
		{
			tooltipData = TooltipDataProvider.GetACGItemTooltip(m_InventoryItem.m_ACGItem);
		}
		else
		{
			tooltipData = TooltipDataProvider.GetInventoryItemTooltip(m_InventoryId, m_InventoryItem.m_InventoryPos);
		}
		
		var equippedItems:Array = [];
		for ( var i:Number = 0 ; i < tooltipData.m_CurrentlyEquippedItems.length ; ++i )
		{
			var equippedData:TooltipData =  TooltipDataProvider.GetInventoryItemTooltip( new com.Utils.ID32( _global.Enums.InvType.e_Type_GC_WeaponContainer, 0 ), 
											tooltipData.m_CurrentlyEquippedItems[i] );
			equippedData.m_IsEquipped = true;
			equippedItems.push( equippedData);
		}
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_Icon, TooltipInterface.e_OrientationHorizontal, -1, tooltipData, equippedItems );
	
    }
    
    public function CloseTooltip() : Void
    {
        if ( m_Tooltip != undefined && !m_Tooltip.IsFloating() )
        {
            m_Tooltip.Close();
        }
        m_Tooltip = undefined;
    }
	
	
	public function SetPos(x:Number, y:Number)
	{
		m_MovieClip._x = x;
		m_MovieClip._y = y;
	}
}