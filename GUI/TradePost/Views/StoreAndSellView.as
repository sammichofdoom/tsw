//Imports
import com.Utils.LDBFormat;
import com.Utils.DragObject;
import com.Utils.DragManager;
import com.GameInterface.Inventory;
import com.GameInterface.Game.Character;
import com.GameInterface.Tradepost;
import com.GameInterface.ItemPrice;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Utils;
import gfx.core.UIComponent;
import mx.data.types.Int;
import mx.utils.Delegate;

//Class
class GUI.TradePost.Views.StoreAndSellView extends UIComponent
{
    //Constants
    public static var CHANGE_ITEM_PRICE:String = "changeItemPrice";
    public static var SELL_ITEM:String = "sellItem";
    
    private static var EXPANSION_LIMIT_REACHED:String = LDBFormat.LDBGetText("MiscGUI", "BuySlotsLimitReachedTooltip");
    private static var PAGE_OF:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_pageOf");
    private static var COLUMNS:Number = 12;
    private static var ROWS:Number = 6;
 
    //Properties
    private var m_StoreAndSellHeader:MovieClip;
    private var m_BankContainer:MovieClip;
    private var m_SellItemPromptWindow:MovieClip;
    private var m_BuySlotButton:MovieClip;
    private var m_PaginatePrevious:MovieClip;
    private var m_PaginateNext:MovieClip;
    private var m_CurrentPage:Number;
    private var m_PageNumber:TextField;
    private var m_TotalPages:Number;
    private var m_BankSlotID:Number;
    private var m_DraggingItemInterval:Number;
    private var m_Inventory:Inventory;
    private var m_MaxBankSlots:Number;
    
    //Constructor
    public function StoreAndSellView()
    {
        super();
        
        gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "onDragStart" );   
        gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );
        
        m_MaxBankSlots = com.GameInterface.Utils.GetGameTweak("Inventory_BankMaxSize");
    }
    
    //Config UI
    private function configUI():Void
    {
        var clientCharacter:Character = Character.GetClientCharacter();
        clientCharacter.SignalStatChanged.Connect(SlotCharacterStatChanged, this);
        
        m_StoreAndSellHeader.m_Title.htmlText = LDBFormat.LDBGetText("MiscGUI", "TradePost_YourStoredItems") + " " + LDBFormat.LDBGetText("MiscGUI", "TradePost_RightClickInstruction");
        
        m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BankContainer, Character.GetClientCharID().GetInstance()));
        m_Inventory.SignalInventoryExpanded.Connect(SlotBankExpanded, this);

        m_TotalPages = Math.ceil( m_Inventory.GetMaxItems() / (COLUMNS * ROWS) );
        m_CurrentPage = 0;
        m_PageNumber.text = LDBFormat.Printf(PAGE_OF, m_CurrentPage + 1, m_TotalPages);
         
        m_SellItemPromptWindow = attachMovie("SellItemPromptWindow", "m_SellItemPromptWindow", getNextHighestDepth());
        m_SellItemPromptWindow.SignalPromptResponse.Connect(SlotSellPromptResponse, this);
        
        m_BuySlotButton.autoSize = "right";
        m_BuySlotButton.label = LDBFormat.LDBGetText("MiscGUI",  "BuyMoreSlots");
        m_BuySlotButton.disableFocus = true;
        m_BuySlotButton.addEventListener("rollOver", this, "SlotExpandBankTooltip");
        m_BuySlotButton.addEventListener("click", this, "SlotBuySlots");
        m_BuySlotButton._x = this._width - m_BuySlotButton._width - 2;
        m_BuySlotButton.SetTooltipText(EXPANSION_LIMIT_REACHED);
        
        m_PaginatePrevious.disableFocus = true;
        m_PaginatePrevious.addEventListener("click", this, "SlotPreviousPage");
        m_PaginatePrevious.disabled = true;
        
        m_PaginateNext.disableFocus = true;
        m_PaginateNext.addEventListener("click", this, "SlotNextPage");
        m_PaginateNext.disabled = ( m_TotalPages <= 1 );

        m_BankContainer.SetItemSlotTemplate("StoreAndSellItemTemplate");
        m_BankContainer.SetInventory(m_Inventory);
        m_BankContainer.SetSize(COLUMNS, ROWS, m_TotalPages);
        m_BankContainer.CreateRightClickMenu();
        m_BankContainer.SignalRightClickBankContainer.Connect(SlotRightClickBankContainer, this);
        m_BankContainer.SignalItemPressed.Connect(HidePromptIfVisible, this);
        m_BankContainer.swapDepths(m_StoreAndSellHeader);
        
        m_BuySlotButton.disabled = !BankIsExpandable();
        
        _parent.SignalViewChanged.Connect(HidePromptIfVisible, this);
    }
    
    //Bank Is Expandable
    private function BankIsExpandable():Boolean
    {
        var inventoryInGamePurchasedSlots:Number = Utils.GetGameTweak("Inventory_BankSize") + 
                                                   Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_ExpandBankInventory);
        return inventoryInGamePurchasedSlots < m_MaxBankSlots;
    }
    
    //On Drag Start
    private function onDragStart(event:Object):Void
    {
        if ( event.data.type == "item" || event.data.type == "mailAttachment" )
        {
            m_DraggingItemInterval = setInterval(Delegate.create(this, CheckItemOverPageButtons), 1500, this);
        }
    }
    
    //On Drag End
    private function onDragEnd(event:Object):Void
    {
        clearInterval(m_DraggingItemInterval);
    }
    
    //Check Item Over Page Button
    private function CheckItemOverPageButtons():Void
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        if (currentDragObject != undefined && currentDragObject.type == "item")
        {
            var dragClip:MovieClip = currentDragObject.GetDragClip();
            if ( m_PaginateNext.hitTest(dragClip) && !m_PaginateNext.disabled )
            {
                SlotNextPage();
            }
            else if ( m_PaginatePrevious.hitTest(dragClip) && !m_PaginatePrevious.disabled )
            {
                SlotPreviousPage();
            }
        }
    }
    
    //Slot Expand Bank Tooltip
    private function SlotExpandBankTooltip():Void
    {
        var nextExpansionSize:Number = ProjectUtils.GetUint32TweakValue("Inventory_BankExpansionIncrement");
        var nextExpansionPrice:Number = ProjectUtils.CalculateNextExpansionPrice(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BankContainer, Character.GetClientCharID().GetInstance()));
        var tokenName:String = LDBFormat.LDBGetText("Tokens", "CashToken");
        
        m_BuySlotButton.SetTooltipText(LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "BuyMoreSlotsTooltip"), nextExpansionSize, nextExpansionPrice, tokenName, m_MaxBankSlots) );
    }

    private function SlotCharacterStatChanged(stat:Number)
    {
        if (stat == _global.Enums.Stat.e_ExtraBankInventorySlots)
        {
            SlotBankExpanded(_global.Enums.InvType.e_Type_GC_BankContainer, Character.GetClientCharacter().GetStat(stat));
        }
    }
    
    //Slot Buy Slots
    private function SlotBuySlots():Void
    {
        m_BankContainer.BuySlots();
        
        HidePromptIfVisible();
    }
    
    //Slot Previous Page
    private function SlotPreviousPage():Void
    {
        m_CurrentPage--;

        m_PageNumber.text = LDBFormat.Printf(PAGE_OF, m_CurrentPage + 1, m_TotalPages);
        
        if ( m_CurrentPage <= 0 )
        {
            m_PaginatePrevious.disabled = true;
        }
        
        m_PaginateNext.disabled = false;
        m_BankContainer.GotoPage(m_CurrentPage);
        
        HidePromptIfVisible();
    }
    
    //Slot Bank Expanded
    private function SlotBankExpanded(inventoryID:com.Utils.ID32, size:Number):Void
    {
        m_TotalPages = Math.ceil( size / (COLUMNS * ROWS) );
        m_BankContainer.SetSize(COLUMNS, ROWS, m_TotalPages, m_CurrentPage);
        m_PaginateNext.disabled = ( m_CurrentPage >= (m_TotalPages-1) );
        m_PageNumber.text = LDBFormat.Printf(PAGE_OF, m_CurrentPage + 1, m_TotalPages);
        
        m_BuySlotButton.disabled = !BankIsExpandable();
    }
    
    //Slot Next Page
    private function SlotNextPage():Void
    {
        m_CurrentPage++;
        m_PageNumber.text = LDBFormat.Printf(PAGE_OF, m_CurrentPage + 1, m_TotalPages);
        
        if ( m_CurrentPage >= m_TotalPages -1 )
        {
            m_PaginateNext.disabled = true;
        }
        
        m_PaginatePrevious.disabled = false;
        m_BankContainer.GotoPage(m_CurrentPage);
        
        HidePromptIfVisible();
    }
    
    //Slot Right Click Bank Container
    private function SlotRightClickBankContainer(task:String, bankSlotID:Number):Void
    {
        switch (task)
        {
            case SELL_ITEM:     m_SellItemPromptWindow.ShowPrompt();
                                break;
        }
        
        m_BankSlotID = bankSlotID;
    }
    
    //Slot Prompt Response
    private function SlotSellPromptResponse(price:Number):Void
    {
        Tradepost.SellItem(m_BankSlotID, m_BankContainer.GetItemPriceFromCash(price));
    }
    
    //Hide Prompt If Visible
    private function HidePromptIfVisible():Void
    {
        if (m_SellItemPromptWindow._visible)
        {
            m_SellItemPromptWindow._visible = false;
        }
    }
}