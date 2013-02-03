import gfx.controls.Label;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.*;
import com.Utils.ID32;

class GUI.Inspection.ClothingLabel extends Label
{
    var m_ItemData:InventoryItem;
    var m_InventoryID:ID32;
    var m_Tooltip:TooltipInterface;
    
    function SetData(inventoryID:ID32, inventoryItem:InventoryItem)
    {
        m_InventoryID = inventoryID;
        m_ItemData = inventoryItem;
        if (initialized)
        {
            UpdateData();
        }
    }
    
    function configUI()
    {
        super.configUI();
        autoSize = "left";
        if (m_ItemData != undefined)
        {
            UpdateData();
        }
        
        onRollOver = SlotRollOver;
        onRollOut = onDragOut = SlotRollOut;
    }
    
    function UpdateData()
    {
        text = m_ItemData.m_Name;
    }
    
    function SlotRollOver()
    {
        OpenTooltip();
    }
    
    function SlotRollOut()
    {
        CloseTooltip();
    }
    
    	
    public function OpenTooltip() : Void
    {
        if (m_Tooltip == undefined)
        {
            var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip(m_InventoryID, m_ItemData.m_InventoryPos);
            m_Tooltip = TooltipManager.GetInstance().ShowTooltip( this, TooltipInterface.e_OrientationHorizontal, -1, tooltipData);
        }
    }
    
    public function CloseTooltip() : Void
    {
        if ( m_Tooltip != undefined && !m_Tooltip.IsFloating() )
        {
            m_Tooltip.Close();
        }
        m_Tooltip = undefined;
    }
    
} 