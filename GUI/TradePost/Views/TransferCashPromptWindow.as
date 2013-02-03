//Imports
import com.Utils.LDBFormat;
import gfx.controls.Button;
import gfx.core.UIComponent;
import GUI.TradePost.ItemCounter;
import com.GameInterface.Tradepost;

//Class
class GUI.TradePost.Views.TransferCashPromptWindow extends UIComponent
{
    //Constants
    private static var TRANSFER_CASH:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_TransferCash");
    private static var TRANSFER_CASH_MESSAGE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_TransferCashMessage");
    private static var WITHDRAW_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Withdraw");
    private static var DEPOSIT_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Deposit");
    private static var CANCEL_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
    
    //Properties
    private var m_Background:MovieClip;
    private var m_Title:TextField;
    private var m_Message:TextField;
    private var m_ItemCounter:ItemCounter;
    private var m_WithdrawButton:Button;
    private var m_DepositButton:Button;
    private var m_CancelButton:Button;
    
    //Constructor
    public function TransferCashPromptWindow()
    {
        super();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        _visible = false;
        
        m_Title.text = TRANSFER_CASH;
        m_Message.htmlText = TRANSFER_CASH_MESSAGE;
        m_Message.autoSize = "center";
        
        m_ItemCounter._x = m_Background._width / 2 - m_ItemCounter._width / 2;
        m_ItemCounter.icon = "PaxRomana";
        m_ItemCounter.ShowBackground(false);
        m_ItemCounter.minAmount = 0;
        m_ItemCounter.maxAmount = ItemCounter.MAX_VALUE;
        m_ItemCounter.SignalValueChanged.Connect(SlotCashAmountChanged, this);
        
        m_WithdrawButton.label = WITHDRAW_LABEL;
        m_WithdrawButton.disableFocus = true;
        m_WithdrawButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_DepositButton.label = DEPOSIT_LABEL;
        m_DepositButton.disableFocus = true;
        m_DepositButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_CancelButton.label = CANCEL_LABEL;
        m_CancelButton.disableFocus = true;
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        _x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;        
    }
    
    //Show Prompt
    public function ShowPrompt():Void
    {
        if (_visible)
        {
            return;
        }
        
        _visible = true;
        swapDepths(_parent.getNextHighestDepth());
        
        m_ItemCounter.amount = 0;
        m_ItemCounter.TakeFocus();
        
        m_WithdrawButton.disabled = true;
        m_DepositButton.disabled = true;
    }
    
    //Text Change Event Handler
    private function SlotCashAmountChanged(newValue:Number):Void
    {
        m_WithdrawButton.disabled = m_DepositButton.disabled = (newValue == 0) ? true : false;
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_WithdrawButton:      Tradepost.GuildWithdrawMoney(m_ItemCounter.amount);
                                        break;
                                        
            case m_DepositButton:       Tradepost.GuildTransferMoney(m_ItemCounter.amount);
                                        break;
        }
        
        _visible = false;
    }
}