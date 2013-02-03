//Imports
import mx.utils.Delegate;
import com.Components.ItemSlot;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tradepost;
import com.GameInterface.ItemPrice;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;

//Class
class com.Components.BankItemSlot extends ItemSlot
{
    private var m_IsItemForSale:Boolean;
    private var m_Price:Number;
    private var m_AttachedToComposeMail:Boolean;
    private var m_IconsTooltip:TooltipInterface;
    private var m_CanReactOnNextMouseRelease:Boolean;
        
    //Constructor
    public function BankItemSlot(inventoryID:com.Utils.ID32, slotID:Number, slotMC:MovieClip, iconTemplateName:String)
    {
        super(inventoryID, slotID, slotMC, iconTemplateName);
        
        m_SlotMC.m_Price._visible = false;
        m_SlotMC.m_MailIcon._visible = false;
        
        m_SlotMC.m_Price.onRollOver = Delegate.create(this, SlotRollOverCash);
        m_SlotMC.m_Price.onRollOut = m_SlotMC.m_Price.onDragOut = Delegate.create(this, SlotRollOutIcon);
        
        m_SlotMC.m_MailIcon.onRollOver = Delegate.create(this, SlotRollOverMail);
        m_SlotMC.m_MailIcon.onRollOut = m_SlotMC.m_MailIcon.onDragOut = Delegate.create(this, SlotRollOutIcon);
        
        m_CanReactOnNextMouseRelease = true;
        m_AttachedToComposeMail = false;
    }
    
    //Set Data
    public function SetData(newData:InventoryItem):Void
    {
        super.SetData(newData);

        m_Icon._x = m_SlotMC.m_IconContent._x;
        m_Icon._y = m_SlotMC.m_IconContent._y;
        
        m_SlotMC.m_Price._visible = false;
        m_SlotMC.m_MailIcon._visible = false;
        
        if ( newData!= undefined &&  m_InventoryID.GetType() == _global.Enums.InvType.e_Type_GC_BankContainer ) //Do not show buy/mail icons for guildbank
        {
            var isItemAttachedToMail:Boolean = Tradepost.IsItemAttachedToMail(newData.m_InventoryPos);
            m_SlotMC.m_MailIcon._visible = isItemAttachedToMail;
            
            if (!isItemAttachedToMail && Tradepost.IsItemInComposeMail(newData.m_InventoryPos))
            {
                m_SlotMC.m_MailIcon._visible = true;
                com.Utils.Colors.ApplyColor(m_SlotMC.m_MailIcon, 0x999999);
                m_AttachedToComposeMail = true;
            }
            else
            {
                com.Utils.Colors.ApplyColor(m_SlotMC.m_MailIcon, 0xFFFFFF);
                m_AttachedToComposeMail = false;
            }
            
            m_IsItemForSale = Tradepost.IsItemForSale(newData.m_InventoryPos);
            if ( m_IsItemForSale )
            {
                var price:ItemPrice = Tradepost.GetItemSalePrice(newData.m_InventoryPos);
                m_Price = price.m_TokenType1_Amount;
            }
            m_SlotMC.m_Price._visible = m_IsItemForSale;
        }
    }
    
    function onMouseRelease(buttonIdx:Number)
    {
        if ( m_CanReactOnNextMouseRelease )
        {
            super.onMouseRelease(buttonIdx);
        }
        m_CanReactOnNextMouseRelease = true;
    }
    
    //To avoid the drag effect with the first click
    public function CanReactOnNextMouseRelease(canAct:Boolean)
    {
        m_CanReactOnNextMouseRelease = canAct;
    }
    
    public function OpenTooltip() : Void
    {
        var isMouseOverIcons:Boolean = m_SlotMC.m_Price.hitTest(_root._xmouse, _root._ymouse) || m_SlotMC.m_MailIcon.hitTest(_root._xmouse, _root._ymouse)
        if (m_Tooltip == undefined && !isMouseOverIcons)
        {
            var tooltipData:TooltipData = GetTooltipData();
            
            var equippedItems:Array = [];
            if (m_InventoryID.GetType() != _global.Enums.InvType.e_Type_GC_WeaponContainer)
            {
                for ( var i:Number = 0 ; i < tooltipData.m_CurrentlyEquippedItems.length ; ++i )
                {
                    var equippedData:TooltipData;
                    if (m_IsACGItem)
                    {
                        equippedData =  TooltipDataProvider.GetInventoryItemTooltipCompareACGItem( new com.Utils.ID32( _global.Enums.InvType.e_Type_GC_WeaponContainer, 0 ), 
                                            tooltipData.m_CurrentlyEquippedItems[i], m_ItemData.m_ACGItem);
                    }
                    else
                    {
                        equippedData =  TooltipDataProvider.GetInventoryItemTooltipCompareInventoryItem( new com.Utils.ID32( _global.Enums.InvType.e_Type_GC_WeaponContainer, 0 ), 
                                            tooltipData.m_CurrentlyEquippedItems[i], m_InventoryID, m_SlotID);
                    }
                    equippedData.m_IsEquipped = true;
                    equippedItems.push( equippedData);
                }
            }
            
            m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_SlotMC, TooltipInterface.e_OrientationHorizontal, -1, tooltipData, equippedItems );
        }
    }
    
    //Slot Roll Over Cash Icon
    function SlotRollOverCash()
    {
        CloseTooltip(); //Close Item tooltip
        if (m_IconsTooltip != undefined)
        {
            m_IconsTooltip.Close();
        }

        if (m_SlotMC.m_Price._visible)
        {
            var tooltipData:TooltipData = new TooltipData();
            tooltipData.m_PlayerSellPrice = m_Price;
            tooltipData.m_Padding = 4;
            tooltipData.m_MaxWidth = 100;
            m_IconsTooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, 
                                                                      DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
        }
    }
    
    //Slot Roll Over Mail Icon
    function SlotRollOverMail()
    {
        CloseTooltip(); //Close Item tooltip
        if (m_IconsTooltip != undefined)
        {
            m_IconsTooltip.Close();
        }

        if (m_SlotMC.m_MailIcon._visible)
        {
            if (m_AttachedToComposeMail)
            {
                var tooltipData:TooltipData = new TooltipData();
                tooltipData.AddAttribute("", LDBFormat.LDBGetText("MiscGUI", "Tradepost_ItemAttchedToComposeMail"));
                tooltipData.m_Padding = 4;
                tooltipData.m_MaxWidth = 100;
                m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
            }
            else
            {
                var tooltipData:TooltipData = new TooltipData();
                tooltipData.m_ItemSentTo = Tradepost.GetSentToName(m_ItemData.m_InventoryPos);
                tooltipData.m_Padding = 4;
                tooltipData.m_MaxWidth = 100;
                m_IconsTooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, 
                                                                          DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
            }
        }
    }

    //Slot Roll Out Icon
    function SlotRollOutIcon()
    {
        if (m_IconsTooltip != undefined)
        {
            m_IconsTooltip.Close();
        }
    }
    
    public function CloseTooltip() : Void
    {
        SlotRollOutIcon();
        super.CloseTooltip();
    }
    
    public function Clear() : Void
    {
        super.Clear();

        m_SlotMC.m_Price._visible = false;
        m_SlotMC.m_MailIcon._visible = false;
    }
}