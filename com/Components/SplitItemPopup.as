import com.GameInterface.InventoryItem;
import com.Components.ItemSlot;
import com.Utils.GlobalSignal;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import gfx.core.UIComponent;
import gfx.controls.Slider;
import gfx.controls.Button;
import mx.utils.Delegate;

import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;

class com.Components.SplitItemPopup extends UIComponent
{
    
    private var m_Background:MovieClip;
    private var m_Icon:MovieClip;
    private var m_Title:TextField;
    private var m_Name:TextField;
    private var m_Type:TextField;
    private var m_Rank:TextField;
    private var m_Stack:TextField;
    private var m_MaxStack:TextField;
    
    private var m_CancelButton:Button;
    private var m_AcceptButton:Button;
    private var m_CloseButton:Button;
    
	private var m_ItemSlot:ItemSlot;
    
    private var m_Slider:MovieClip;
    
    public var SignalAcceptSplitItem:Signal;
    public var SignalCancelSplitItem:Signal;
    
    private var m_SourceItemSlot:ItemSlot;
    
    private var m_MaxStackSize:Number;
    
    
    function SplitItemPopup()
    {
        super();
        
        SignalAcceptSplitItem = new Signal();
        SignalCancelSplitItem = new Signal();
    }
    
    function configUI()
    {
        super.configUI();
        
        m_AcceptButton.label = LDBFormat.LDBGetText("GenericGUI", "Accept");
        m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
        m_Title.text = LDBFormat.LDBGetText("MiscGUI", "SplitItemTitle");
        
        m_AcceptButton.addEventListener("click", this, "OnAccept");
        m_CancelButton.addEventListener("click", this, "OnCancel");
        m_CloseButton.addEventListener("click", this, "OnCancel");
        m_Slider.addEventListener("change", this, "OnSliderChange");
		m_Slider.addEventListener("focusIn", this, "SlotRemoveFocus");
        
        
        m_Background.onPress = Delegate.create(this, SlotStartDragWindow);
        m_Background.onMouseUp = Delegate.create(this, SlotStopDragWindow);
		
		m_Stack.restrict = "0-9";
		m_Stack.maxChars = m_MaxStackSize.toString().length;
        
        m_Slider.minimum = 1;
        m_Slider.snapping = true;
        m_Slider.snapInterval = 1;
        m_Slider.liveDragging = true;
        m_Slider.maximum = m_MaxStackSize;
        m_Slider.position = Math.floor(m_MaxStackSize / 2);
		
		m_Stack.text = m_Slider.position.toString(); 
		m_Stack.onChanged = Delegate.create(this, SlotTextChanged);
		
        Key.addListener(this);
    }
	
	function onKeyDown()
	{
		if (Selection.getFocus() == m_Stack && Key.getCode() == Key.ENTER)
		{
			Selection.setFocus(null);
		}
	}
	
	function SlotTextChanged()
	{
		if (m_Stack.text.length > 0)
		{
			var split:Number = Math.min(parseInt(m_Stack.text, 10), m_MaxStackSize);
			m_Stack.text = split.toString();
			m_Slider.position = split;
		}
	}
	
	function SlotRemoveFocus()
	{
		Selection.setFocus(null);
	}
	
    private function SlotStartDragWindow()
    {
        this.startDrag();
    }
    
    private function SlotStopDragWindow()
    {
        this.stopDrag();
    }
    
    function OnAccept()
    {
        SignalAcceptSplitItem.Emit(m_SourceItemSlot, parseInt(m_Stack.text, 10));
        this.removeMovieClip();
    }
    
    function OnCancel()
    {
        SignalCancelSplitItem.Emit(m_SourceItemSlot);
        this.removeMovieClip();
    }
    
    function OnSliderChange( event:Object )
    {
        m_Stack.text = event.target.position;       
    }
    
    public function SetItemSlot(itemSlot:ItemSlot)
    {
        m_SourceItemSlot = itemSlot;
        
        var item:InventoryItem = itemSlot.GetData();
        
        m_ItemSlot = new ItemSlot(m_SourceItemSlot.GetInventoryID(), item.m_InventoryPos, m_Icon);
        m_ItemSlot.SetData(item);

		m_Name.text = item.m_Name;
        if (item.m_ItemTypeGUI > 0)
        {
            m_Type.text = LDBFormat.LDBGetText("ItemTypeGUI", item.m_ItemTypeGUI);
        }
        var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip(itemSlot.GetInventoryID(), item.m_InventoryPos);
        if (tooltipData.m_ItemRank != undefined && tooltipData.m_ItemRank.length > 0 && Number(tooltipData.m_ItemRank) != 0)
		{
			m_Rank.htmlText = "<font size='11' color='#AAAAAA'>" + LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "QualityLevel"), tooltipData.m_ItemRank) + "</font>"
		}
        m_MaxStackSize = item.m_StackSize;
        
        m_MaxStack.text = item.m_StackSize.toString();
		if (m_Slider.initialized)
		{
			m_Slider.position = Math.floor(m_MaxStackSize / 2);
			m_Stack.text = m_Slider.position.toString(); 
			m_Stack.maxChars = m_MaxStackSize.toString().length;
		}
        
    }
}