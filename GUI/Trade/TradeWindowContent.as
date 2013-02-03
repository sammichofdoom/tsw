import com.GameInterface.Inventory;
import com.Utils.ID32;
import com.GameInterface.Game.Character;
import mx.utils.Delegate;
import com.GameInterface.Utils;
import com.Components.ItemSlot;
import com.Utils.LDBFormat;
import com.Utils.DragObject;
import com.Components.WindowComponentContent;
import gfx.controls.Button;
import GUI.Trade.ItemCounter;

class GUI.Trade.TradeWindowContent extends WindowComponentContent
{
    var m_ClientInventory:Inventory;
    var m_PartnerInventory:Inventory;
	
	var m_ClientCharacter:Character;
    
    var m_ItemCounter:MovieClip;
    
    var m_ClientItemSlots:Array;
    var m_PartnerItemSlots:Array;
    
    var m_NumSlots:Number;
	var m_HasAcceptedTrade:Boolean;
    
    var m_IsClientSlotLit:Boolean;
    
	var m_IconBoxHighlight:MovieClip;		
    var m_Background:MovieClip;
    var m_AcceptButton:Button;
    var m_AbortButton:Button;
    var m_ClientSlots:MovieClip;
    var m_PartnerSlots:MovieClip;
    var m_ClientAccepted:MovieClip;
    var m_PartnerAccepted:MovieClip;
    var m_PartnerMoneyClip:MovieClip;;
    var m_ClientName:TextField;
    var m_PartnerName:TextField;

    
    function TradeWindowContent()
    {
        super();
				
        m_IconBoxHighlight._visible = false;
        m_ClientItemSlots = [];
        m_PartnerItemSlots = [];
        
        m_NumSlots = 9;
		m_HasAcceptedTrade = false;
				
        var clientID:ID32 = Character.GetClientCharID();
                
        m_ClientCharacter = Character.GetCharacter(clientID);
        m_ClientCharacter.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
        
        if (m_ClientCharacter != undefined)
        {
            m_ClientName.text = m_ClientCharacter.GetName();
        }
        
        m_ClientInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_TradeContainer,  Character.GetClientCharID().GetInstance()));
           
        m_ClientInventory.SignalItemAdded.Connect( SlotClientItemAdded, this);
        m_ClientInventory.SignalItemMoved.Connect( SlotClientItemMoved, this);
        m_ClientInventory.SignalItemRemoved.Connect( SlotClientItemRemoved, this);
        m_ClientInventory.SignalItemChanged.Connect( SlotClientItemChanged, this);
        
        for (var i:Number = 0; i < m_NumSlots; i++)
        {
            InitializeSlot(m_ClientInventory.m_InventoryID, m_ClientItemSlots, i, m_ClientSlots["i_ClientSlot_" + (i + 1)], true);
        }
        
        gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "SlotDragBegin" );
        gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "SlotDragEnd" );
        
        m_Background.onPress =  Delegate.create(this, SlotStartDragWindow);
        m_Background.onRelease =  Delegate.create(this, SlotStopDragWindow);
        
        Utils.SignalPartnerAccepted.Connect(SlotPartnerAccepted, this);
        Utils.SignalPartnerNoLongerAccepted.Connect(SlotPartnerNoLongerAccepted, this);
        Utils.SignalClientCharAccepted.Connect(SlotClientAccepted, this);
        Utils.SignalClientCharNoLongerAccepted.Connect(SlotClientNoLongerAccepted, this);
        Utils.SignalPartnerCashUpdated.Connect(SlotPartnerCashUpdated, this);
        
        m_ClientAccepted._visible = false;
        m_PartnerAccepted._visible = false;
    }
	
	function configUI()
	{
		super.configUI();
		
        m_ItemCounter.icon = "PaxRomana";
        m_ItemCounter.ShowBackground(false);
        m_ItemCounter.minAmount = 0;
        m_ItemCounter.maxAmount = m_ClientCharacter.GetTokens(_global.Enums.Token.e_Cash);
        m_ItemCounter.disableFocus = true;
        m_ItemCounter.m_TextInput.disableFocus = true;
        m_ItemCounter.SignalValueChanged.Connect(SlotItemCounterValueChanged, this);
        
        m_AcceptButton.label = LDBFormat.LDBGetText("GenericGUI", "Confirm");
        m_AcceptButton.addEventListener("click", this, "SlotAcceptTrade");
		m_AcceptButton.disableFocus = true;

        m_AbortButton.label  = LDBFormat.LDBGetText("GenericGUI", "Cancel");
        m_AbortButton.addEventListener("click", this, "SlotAbortTrade");
		m_AbortButton.disableFocus = true;

	}
	
	function SlotAcceptTrade()
	{
		if (!m_HasAcceptedTrade)
		{
			Utils.AcceptTrade();
		}
		else
		{
			Utils.NoLongerAcceptTrade();			
		}
	}
	
	function SlotAbortTrade()
	{
		Utils.AbortTrade();
	}
    
    function InitializeSlot(inventoryID:ID32, slotArray:Array,  itemPos:Number, slotMC:MovieClip, supportDrag:Boolean)
    {
        slotArray[ itemPos ] = new ItemSlot(inventoryID, itemPos, slotMC);
        slotArray[ itemPos ].SetDragItemType("tradeitem");
        if (supportDrag)
        {
            slotArray[itemPos].SignalStartDrag.Connect(SlotStartDragItem, this);
        }
    }
    
    private function SlotStartDragItem(itemSlot:ItemSlot, stackSize:Number)
    {
        var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSize);
        dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
    }
    
    function SlotDragHandled()
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();

        if (m_ClientItemSlots[currentDragObject.inventory_slot] != undefined)
        {
            m_ClientItemSlots[currentDragObject.inventory_slot].SetAlpha(100);
        }
    }
    
    function SetTradePartner(partnerID:ID32)
    {
        m_PartnerInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_TradeContainer, partnerID.GetInstance()));
                   
        m_PartnerInventory.SignalItemAdded.Connect( SlotPartnerItemAdded, this);
        m_PartnerInventory.SignalItemMoved.Connect( SlotPartnerItemMoved, this);
        m_PartnerInventory.SignalItemRemoved.Connect( SlotPartnerItemRemoved, this);
        m_PartnerInventory.SignalItemChanged.Connect( SlotPartnerItemChanged, this);
        
        var partnerChar:Character = Character.GetCharacter(partnerID);
        if (partnerChar != undefined)
        {
            m_PartnerName.text = partnerChar.GetName();
        }
        
        for (var i:Number = 0; i < m_NumSlots; i++)
        {
            InitializeSlot(m_PartnerInventory.m_InventoryID, m_PartnerItemSlots, i, m_PartnerSlots["i_PartnerSlot_" + (i + 1)], false);
        }
    }
    
    private function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number):Void
    {
        if (id == 10) //Cash
        {
            m_ItemCounter.maxAmount = m_ClientCharacter.GetTokens(_global.Enums.Token.e_Cash);
        }
    }

    private function SlotItemCounterValueChanged(value:Number):Void
    {
        Utils.SetTradeCash(value);
    }
    
    function SlotDragBegin( event:Object )
    {
    }

    function SlotDragEnd( event:Object )
    {
        //No point supporting "moving" items as it has no impact since they are added sequentially
        if ( event.data.type == "item" && !event.data.inventory_id.Equal(m_ClientInventory.m_InventoryID))
        {
            var dstID = GetNextFreeSlot();
            if ( dstID >= 0 )
            {
                m_ClientInventory.AddItem(event.data.inventory_id, event.data.inventory_slot, dstID);
                event.data.DragHandled();
            }
        }
        ToggleClientSlotsHighlight(false);
    }
    
    function onMouseMove()
    {
        if (DragObject.GetCurrentDragObject() != undefined && DragObject.GetCurrentDragObject().type == "item" )
        {
            if (!m_IsClientSlotLit)
            {
                ToggleClientSlotsHighlight(true);
            }
        }
        else if (m_IsClientSlotLit)
        {
            ToggleClientSlotsHighlight(false);
        }   
    }

    function GetNextFreeSlot() : Number
    {
        if (m_ClientSlots.hitTest(_root._xmouse, _root._ymouse))
        {
            for ( var i:Number = 0; i < m_ClientItemSlots.length;i++ )
            {
                if (!m_ClientItemSlots[i].HasItem())
                {
                    return i;
                }
            }
        }
        
        return -1;
    }
    
    function ToggleClientSlotsHighlight(highlight:Boolean)
    {
        if (highlight)
        {
			m_IconBoxHighlight._visible = true;
        }
        else
        {
			m_IconBoxHighlight._visible = false;
        }
        
        m_IsClientSlotLit = highlight;
    }
    
    function SlotStartDragWindow()
    {
        this.startDrag();
    }
    
    function SlotStopDragWindow()
    {
        this.stopDrag();
    }
    
    function SlotClientItemAdded( inventoryID:com.Utils.ID32, itemPos:Number )
    {
        m_ClientItemSlots[itemPos].SetData(m_ClientInventory.GetItemAt( itemPos ) );
    }
      
    function SlotClientItemMoved( inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number )
    {
        m_ClientItemSlots[fromPos].SetData(m_ClientInventory.GetItemAt( fromPos ));
        m_ClientItemSlots[toPos].SetData(m_ClientInventory.GetItemAt( toPos ));
    }
      
    function SlotClientItemRemoved( inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
    {
        m_ClientItemSlots[itemPos].Clear(); 
    }
      
    function SlotClientItemChanged( inventoryID:com.Utils.ID32, itemPos:Number )
    {
        m_ClientItemSlots[itemPos].SetData(m_ClientInventory.GetItemAt( itemPos ));    
    }
    
    function SlotPartnerItemAdded( inventoryID:com.Utils.ID32, itemPos:Number )
    {
        m_PartnerItemSlots[itemPos].SetData(m_PartnerInventory.GetItemAt( itemPos ));
    }
      
    function SlotPartnerItemMoved( inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number )
    {
        m_PartnerItemSlots[fromPos].SetData(m_PartnerInventory.GetItemAt( fromPos ));
        m_PartnerItemSlots[toPos].SetData(m_PartnerInventory.GetItemAt( toPos ));
    }
      
    function SlotPartnerItemRemoved( inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
    {
        m_PartnerItemSlots[itemPos].Clear(); 
    }
      
    function SlotPartnerItemChanged( inventoryID:com.Utils.ID32, itemPos:Number )
    {
        m_PartnerItemSlots[itemPos].SetData(m_PartnerInventory.GetItemAt( itemPos ));    
    }
    
    function SlotPartnerAccepted()
    {
        m_PartnerAccepted._visible = true;
    }
    
    function SlotPartnerNoLongerAccepted()
    {
        m_PartnerAccepted._visible = false;
    }
        
    function SlotClientAccepted()
    {
		m_AcceptButton.label = LDBFormat.LDBGetText("GenericGUI", "Modify");
		m_HasAcceptedTrade = true
        m_ClientAccepted._visible = true;
        m_ClientSlots._alpha = 30;
        m_ItemCounter.disabled = true;
    }
        
    function SlotClientNoLongerAccepted()
    {
		m_AcceptButton.label = LDBFormat.LDBGetText("GenericGUI", "Confirm");
		m_HasAcceptedTrade = false;
        m_ClientAccepted._visible = false;
        m_ClientSlots._alpha = 100;
        m_ItemCounter.disabled = false;
    }
    
    function SlotPartnerCashUpdated(newCash:Number)
    {
        m_PartnerMoneyClip.i_Money.text = newCash;
    }
    
    function ClearItems()
    {
        for (var i:Number = 0; i < m_PartnerItemSlots.length; i++)
        {
            if (m_PartnerItemSlots[i] != undefined)
            {
                m_PartnerItemSlots[i].Clear()
            }
        }
        for (var i:Number = 0; i < m_ClientItemSlots.length; i++)
        {
            if (m_ClientItemSlots[i] != undefined)
            {
                m_ClientItemSlots[i].Clear()
            }
        }
    }
}