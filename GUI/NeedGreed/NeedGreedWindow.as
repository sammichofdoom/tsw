//Imports
import com.Components.ItemSlot;
import com.GameInterface.DialogIF;
import com.GameInterface.InventoryItem;
import com.GameInterface.NeedGreed;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.GameInterface.Utils;
import com.Utils.ID32;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import gfx.controls.Button;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;

//Class
class GUI.NeedGreed.NeedGreedWindow extends UIComponent
{
    //Properties
    public var SignalWindowSelected:Signal;
    
    private var m_Background:MovieClip;
    private var m_CloseButton:Button;
	
	private var m_TimeoutBar:MovieClip;
	private var m_IconSlot:MovieClip;
	private var m_ItemName:TextField;
	private var m_ItemType:TextField;
	private var m_ItemRequirement:TextField;
	private var m_ItemBindingInfo:TextField;
	private var m_NeedButton:Button;
	private var m_GreedButton:Button;
	private var m_PassButton:Button;
    
    private var m_CurrentDialog:DialogIF;
	
    private var m_Initialized:Boolean;
	private var m_TimeToCloseWindow:Number;
	private var m_CountdownTimer:Number;
    
    private var m_LootBagId:ID32;
    private var m_ItemPos:Number;
    private var m_Item:InventoryItem;
    
    private var m_ItemTypeIcon:MovieClip;   
	private var m_ItemSlot:ItemSlot;
    
    //Constructor
    public function NeedGreedWindow()
    {
        super();
        
        m_Initialized = false;
		
        SignalWindowSelected = new Signal();
        
        m_Background.onPress = Delegate.create(this, SlotStartDragWindow);
        m_Background.onMouseUp = Delegate.create(this, SlotStopDragWindow);
    }
    
    //Config UI
    private function configUI():Void
    {
        m_Initialized = true;
		
		SetLabels();
		
        m_NeedButton.disableFocus = true;
        m_GreedButton.disableFocus = true;
        m_PassButton.disableFocus = true;
        m_CloseButton.disableFocus = true;
        
		m_NeedButton.addEventListener("click", this, "NeedHandler");
		m_GreedButton.addEventListener("click", this, "GreedHandler");
		m_PassButton.addEventListener("click", this, "PassHandler");
		m_CloseButton.addEventListener("click", this, "PassHandler");
    }
    
    //Close
    public function Close():Void
    {
        if (m_CurrentDialog != undefined)
        {
            m_CurrentDialog.Close();
        }
        
        removeMovieClip(this);
    }
    
    //Set Labels
	private function SetLabels():Void
	{
		m_NeedButton.label = LDBFormat.LDBGetText("MiscGUI", "NeedButtonLabel");
		m_GreedButton.label = LDBFormat.LDBGetText("MiscGUI", "GreedButtonLabel");
		m_PassButton.label = LDBFormat.LDBGetText("MiscGUI", "Pass");
	}
	
    //Update Data
    public function UpdateData(lootBagId:ID32, itemPos:Number, item:InventoryItem, timeout:Number):Void
    {
        m_LootBagId = lootBagId;
        m_ItemPos = itemPos;
        m_Item = item;
        
        m_ItemSlot = new ItemSlot(lootBagId, 0, m_IconSlot);
        m_ItemSlot.SetData(m_Item);
		
		m_TimeoutBar.m_ActiveProgressBar.tweenTo(timeout-1, {_xscale: 0}, None.easeInOut);
		m_TimeoutBar.m_ActiveProgressBar.onTweenComplete = Delegate.create (this, function()
		{
			CountdownTimeout();
		});
        
	    var key:String = lootBagId.toString() + "-" + itemPos;
        
		m_ItemName.text = m_Item.m_Name;
        m_ItemType.text = LDBFormat.LDBGetText("ItemTypeGUI", m_Item.m_ItemTypeGUI);
        
        var tooltipData:TooltipData = TooltipDataProvider.GetACGItemTooltip(item.m_ACGItem);
		
        if (tooltipData.m_ItemCriteriaLevel != undefined && tooltipData.m_ItemCriteriaLevel > 0)
		{
			if (tooltipData.m_ItemCriteriaType != undefined && tooltipData.m_ItemCriteriaType > 0)
			{
                m_ItemRequirement.htmlText = "<font color='#FF0000'>" + LDBFormat.Printf(LDBFormat.LDBGetText("CharacterSkillsGUI", "RequireSkillPoints"), LDBFormat.LDBGetText("CharacterSkillsGUI", tooltipData.m_ItemCriteriaType), tooltipData.m_ItemCriteriaLevel) + "</font>";
			}
		}
        
        if ( tooltipData.m_ItemBindingDesc != undefined && tooltipData.m_ItemBindingDesc != "")
        {
            m_ItemBindingInfo.htmlText =  "<font color='#ffffff'>" + tooltipData.m_ItemBindingDesc + "</font>";
        }
        
        var iconHasType:Boolean = TooltipUtils.CreateItemIconFromType(m_ItemTypeIcon, m_Item.m_ItemTypeGUI, {_xscale:23, _yscale:23, _x:1, _y:1});
        
        if (!iconHasType)
        {
            m_ItemTypeIcon._visible = false;
        }
    }
    
    //Countdown Timeout
	private function CountdownTimeout():Void
	{
		PassHandler();
	}
	
    //Slot Start Drag Window
    private function SlotStartDragWindow():Void
    {
        SignalWindowSelected.Emit(this);
        
        this.startDrag();
    }
    
    //Slot Stop Drag Window
    private function SlotStopDragWindow():Void
    {
        this.stopDrag();
    }
	
    //Need Handler
	private function NeedHandler():Void
	{
        if (m_Item.m_IsBindOnPickup)
        {
            if (m_CurrentDialog == undefined)
            {
                var dialogText:String = LDBFormat.LDBGetText("GenericGUI", "BindsOnPickupQuestion");
                
                m_CurrentDialog = new com.GameInterface.DialogIF(dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "BoPBox");
                m_CurrentDialog.SignalSelectedAS.Connect(SlotBoPDialog, this);
				m_CurrentDialog.SetIgnoreHideModule(true);
                m_CurrentDialog.Go();
            }
        }
        else
        {
            NeedGreed.Need(m_LootBagId, m_ItemPos);
        }
	}
    
    //Slot BoP Dialog
    function SlotBoPDialog(buttonID:Number, boxIdx:Number):Void
    {
        if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
        {
            NeedGreed.Need(m_LootBagId, m_ItemPos);
        }
        m_CurrentDialog = undefined;
    }
	
    //Greed Handler
	private function GreedHandler():Void
	{
        NeedGreed.Greed(m_LootBagId, m_ItemPos);
	}
	
    //Pass Handler
	private function PassHandler():Void
	{
        NeedGreed.Pass(m_LootBagId, m_ItemPos);
	}
}