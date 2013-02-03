import com.Utils.ID32;
import com.Components.WinComp;
import com.Utils.LDBFormat;
import com.GameInterface.Utils;

class GUI.Trade.TradeWindow extends WinComp
{
    
    function TradeWindow()
    {
        super();
		
		SetTitle(LDBFormat.LDBGetText("TradeGUI", "TradeView_Trade"));
        SetContent("TradeWindowContent");
        SetPadding(8);
    
        ShowCloseButton(true);
        ShowStroke(false);
        ShowFooter(true);
        ShowResizeButton(false);
    }
	
	public function SetTradePartner(tradePartner:ID32)
	{
		m_Content.SetTradePartner(tradePartner);
	}
	public function ClearItems()
    {
		m_Content.ClearItems();
	}
	
	private function CloseButtonHandler()
	{
		Utils.AbortTrade();
	}
}