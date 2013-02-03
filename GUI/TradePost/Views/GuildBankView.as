//Imports
import com.Utils.LDBFormat;
import com.GameInterface.Inventory;
import com.GameInterface.Tradepost;
import com.GameInterface.Guild.Guild;
import com.GameInterface.Game.CharacterBase;
import gfx.controls.Button;

//Class
class GUI.TradePost.Views.GuildBankView extends MovieClip
{
    //Constants
    private static var COLUMNS:Number = 12;
    private static var ROWS:Number = 6;
    private static var GAP:Number = 20;
    
    private static var YOUR_GUILDS_ITEMS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_YourGuildsItems");
    private static var GUILDS_CASH:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_GuildsCash");
    private static var TRANSFER_CASH:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_TransferCash");
    private static var PAGE_OF:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_pageOf");
    
    //Properties
    private var m_GuildBankHeader:MovieClip;
    private var m_GuildContainer:MovieClip;
    private var m_TransferCashButton:Button;
    private var m_GuildsCashTitle:TextField;
    private var m_GuildCash:MovieClip;
    private var m_TransferCashPromptWindow:MovieClip;
    private var m_PaginatePrevious:MovieClip;
    private var m_PaginateNext:MovieClip;
    private var m_CurrentPage:Number;
    private var m_PageNumber:TextField;
    private var m_TotalPages:Number;
    
    //Constructor
    public function GuildBankView()
    {
        super();
    }
    
    //On Load
    private function onLoad():Void
    {
        m_GuildBankHeader.m_Title.text = YOUR_GUILDS_ITEMS;
        
        var inventory:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_GuildContainer, Guild.GetInstance().GetGuildID.GetInstance()));
     
        m_TotalPages = Math.ceil( inventory.GetMaxItems() / (COLUMNS * ROWS) );
        m_CurrentPage = 0;
        m_PageNumber.text = LDBFormat.Printf(PAGE_OF, m_CurrentPage + 1, m_TotalPages);
        
        m_GuildContainer.SetItemSlotTemplate("StoreAndSellItemTemplate");
        m_GuildContainer.SetInventory(inventory);
        m_GuildContainer.SetSize(COLUMNS, ROWS, m_TotalPages);
        
        m_TransferCashButton.textField.autoSize = "center";
        m_TransferCashButton.label = TRANSFER_CASH;
        m_TransferCashButton.disableFocus = true;
        m_TransferCashButton.addEventListener("click", this, "ButtonClickHandler");

        SlotGuildCashUpdated(Tradepost.GetGuildCash());
        m_GuildCash._x = m_TransferCashButton._x - m_GuildCash._width - GAP;
        
        Tradepost.SignalGuildCashUpdated.Connect(SlotGuildCashUpdated, this);
        
        m_GuildsCashTitle.autoSize = "left";
        m_GuildsCashTitle.text = GUILDS_CASH;
        m_GuildsCashTitle._x = m_GuildCash._x - m_GuildsCashTitle._width - 5;

        m_PaginatePrevious.disableFocus = true;
        m_PaginatePrevious.addEventListener("click", this, "SlotPreviousPage");
        m_PaginatePrevious.disabled = true;
        
        m_PaginateNext.disableFocus = true;
        m_PaginateNext.addEventListener("click", this, "SlotNextPage");
        m_PaginateNext.disabled = ( m_TotalPages <= 1 );
        
        m_TransferCashPromptWindow = attachMovie("TransferCashPromptWindow", "m_TransferCashPromptWindow", getNextHighestDepth());
        
        _parent.SignalViewChanged.Connect(HidePromptIfVisible, this);
    }
    
    //Button Click Handler
    private function ButtonClickHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_TransferCashButton:  m_TransferCashPromptWindow.ShowPrompt();
                                        break;
        }
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
        m_GuildContainer.GotoPage(m_CurrentPage);
        
        HidePromptIfVisible();
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
        m_GuildContainer.GotoPage(m_CurrentPage);
        
        HidePromptIfVisible();
    }
    
    //Slot Guild Cash Updated
    private function SlotGuildCashUpdated(newCash:Number)
    {
        m_GuildCash.m_Label.text = newCash;
        m_GuildCash.m_Label._width = m_GuildCash.m_Label.textWidth + 5;        
        m_GuildCash._x = m_TransferCashButton._x - m_GuildCash._width - GAP;
        m_GuildsCashTitle._x = m_GuildCash._x - m_GuildsCashTitle._width - 5;
        
        Selection.setFocus(null);
    }
    
    //Hide Prompt If Visible
    private function HidePromptIfVisible():Void
    {
        if (m_TransferCashPromptWindow._visible)
        {
            m_TransferCashPromptWindow._visible = false;
        }
    }
}