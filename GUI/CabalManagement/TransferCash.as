import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.TextInput;

import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;

class GUI.CabalManagement.TransferCash extends UIComponent
{
	private var m_Title:TextField;
	private var m_UserTip:TextField;
	private var m_CashTransferInput:TextInput;
	private var m_IncreaseButton:Button;
	private var m_DecreaseButton:Button;
	
	
	private var m_DepositButton:Button;
	private var m_WithdrawButton:Button;
	private var m_CancelButton:Button;
	
	public var m_CashAmount:Number;
	
	private var SignalCancel:Signal;
	private var SignalSendCash:Signal;
	private var SignalWithdrawCash:Signal;
	
	private function TransferCash()
	{
		SignalCancel = new Signal;
		SignalSendCash = new Signal;
		SignalWithdrawCash = new Signal;
		m_CashAmount = 0;
	}
	
	private function configUI()
	{
		m_CashTransferInput.textField.restrict = "0-9";
		SetLabels();
		
		SetCashAmount(m_CashAmount);
		
		m_IncreaseButton.addEventListener("click", this, "IncreaseCashAmount");
		m_DecreaseButton.addEventListener("click", this, "DecreaseCashAmount");
		m_DepositButton.addEventListener("click", this, "DepositCash");
		m_WithdrawButton.addEventListener("click", this, "WithdrawCash");
		m_CancelButton.addEventListener("click", this, "CancelCashTransferring");
		m_CashTransferInput.addEventListener("change", this, "ChangeAmountByInput");
		m_CashTransferInput.addEventListener("focusOut", this, "ChangeAmountByInput");
		m_CashTransferInput.addEventListener("focusIn", this, "SlotFocusInput");
	}
	
	private function SlotFocusInput()
	{
		Selection.setSelection(0, m_CashTransferInput.textField.text.length);
	}
	
	private function ChangeAmountByInput()
	{
		m_CashAmount = Number(m_CashTransferInput.text);
		SetCashAmount(m_CashAmount);
	}
	
	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}

	private function SetCashAmount(m_CashAmount)
	{	
		m_CashTransferInput.text = m_CashAmount;
	}
	
	private function SetLabels()
	{
		m_Title.text = LDBFormat.LDBGetText("GuildGUI","TransferCash");
		m_UserTip.htmlText = LDBFormat.LDBGetText("GuildGUI","TransferCash_UserTip");
		
		m_DepositButton.label = LDBFormat.LDBGetText("GuildGUI","TransferCash_Deposit");
		m_WithdrawButton.label = LDBFormat.LDBGetText("GuildGUI","TransferCash_Withdraw");
		m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI","Cancel");
	}
	
	private function IncreaseCashAmount()
	{
		m_CashAmount++;
		SetCashAmount(m_CashAmount);
	}
	
	private function DecreaseCashAmount()
	{
		m_CashAmount--;
		SetCashAmount(m_CashAmount);
	}
	
	private function DepositCash()
	{
		SignalSendCash.Emit(parseInt(m_CashTransferInput.text, 10));
	}
	
	private function WithdrawCash()
	{
		SignalWithdrawCash.Emit(parseInt(m_CashTransferInput.text, 10));
	}
	
	private function CancelCashTransferring()
	{
		SignalCancel.Emit();
	}
}