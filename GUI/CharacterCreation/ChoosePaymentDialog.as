import gfx.controls.Button;
import gfx.controls.RadioButton;
import gfx.controls.ButtonGroup;

import com.Utils.LDBFormat;
import com.Utils.Signal;

import com.GameInterface.Game.Character;

class GUI.CharacterCreation.ChoosePaymentDialog extends com.Components.WindowComponentContent
{
	private var m_CostLabel:TextField;
	private var m_Cost:TextField;
	private var m_PaymentLabel:TextField;
	
	private var m_CouponRadioButton:RadioButton;
	private var m_CashRadioButton:RadioButton;
	
	private var m_CurrentCoupons:TextField;
	private var m_CurrentCash:TextField;
	
	private var m_CancelButton:Button;
	private var m_ConfirmButton:Button;
	private var m_RadioButtonGroup:ButtonGroup;
	
	private var m_CashTokenClip:MovieClip;
    private var m_SelectedToken:Number;
	
	public var SignalConfirmPayment:Signal;
	public var SignalCancelPayment:Signal;
	
	public var m_CashCost:Number
	public var m_TokenCost:Number
	
	private var m_ConfirmButtonSound:String;
	
	public function ChoosePaymentDialog()
	{
		super();
		
		SignalConfirmPayment = new Signal();
		SignalCancelPayment = new Signal();
		
		m_CashCost = 0;
		m_TokenCost = 0;
	}
		
	public function configUI()
	{
		super.configUI();
		
		//var clientCharacter:Character = Character.GetClientCharacter();
		
		m_CostLabel.text = LDBFormat.LDBGetText("CharCreationGUI", "Cost");
		m_PaymentLabel.text = LDBFormat.LDBGetText("CharCreationGUI", "PaymentChoice");
		
		
		m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
		m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "Confirm");
		
		m_CancelButton.addEventListener("click", this, "SlotCancel");
		m_ConfirmButton.addEventListener("click", this, "SlotConfirm");
        
        m_CancelButton.disableFocus = true;
        m_ConfirmButton.disableFocus = true;
		
		m_RadioButtonGroup = new ButtonGroup("TokenGroup", this);
        m_RadioButtonGroup.addEventListener("change", this, "SlotChangeRadioButtonSelection");
		
		m_CouponRadioButton.label = LDBFormat.LDBGetText("CharCreationGUI", "UseCoupons");
		m_CouponRadioButton.autoSize = "left";
		m_CouponRadioButton.group = m_RadioButtonGroup;
		m_CouponRadioButton.disableFocus = true;
		m_CashRadioButton.selected = true;
		m_CashRadioButton.label = LDBFormat.LDBGetText("CharCreationGUI", "UsePaxRomana");
		m_CashRadioButton.autoSize = "left";
		m_CashRadioButton.disableFocus = true;
		m_CashRadioButton.group = m_RadioButtonGroup;
	}
	
    private function SlotChangeRadioButtonSelection(event:Object):Void
    {
        UpdateConfirmButton();
    }
    
    private function UpdateConfirmButton():Void
    {
        m_ConfirmButton.disabled = m_RadioButtonGroup.selectedButton.disabled;
    }
    
	public function SlotCancel()
	{
		SignalCancelPayment.Emit();
	}
	
	public function SlotConfirm()
	{
		var character:Character = Character.GetClientCharacter();
		
		var selectedToken:Number = _global.Enums.Token.e_Cash;
		
		if (m_CouponRadioButton.selected)
		{
			selectedToken = m_SelectedToken;
		}
		SignalConfirmPayment.Emit(selectedToken);
		
		_parent.unloadMovie();
	}
	
	public function SetCost(cost:Number)
	{
		m_CashCost = cost;
		m_Cost.text = cost.toString();
	}
	
	public function SetToken(token:Number)
	{
		var tokenClip:MovieClip = attachMovie("T" + token, "m_PaymentToken", getNextHighestDepth());
		
		tokenClip._x = m_CashTokenClip._x + 1;
		tokenClip._y = m_CurrentCoupons._y - 4;
		m_TokenCost = 1;
        
        m_SelectedToken = token;
	}
	
	public function SetPlayerCash(cash:Number)
	{
		m_CurrentCash.text = cash.toString();
		if (cash < m_CashCost)
		{
            m_CashRadioButton.selected = false;
            m_CouponRadioButton.selected = true;
            m_RadioButtonGroup.setSelectedButton(m_CouponRadioButton);
			m_CashRadioButton.disabled = true;
		}
		
		UpdateConfirmButton();
	}
	
	public function SetPlayerTokens(tokens:Number)
	{
		m_CurrentCoupons.text = tokens.toString();
		if (tokens < m_TokenCost)
		{
            m_RadioButtonGroup.setSelectedButton(m_CashRadioButton);
			m_CashRadioButton.selected = true;
			m_CouponRadioButton.disabled = true;
		}
		
		UpdateConfirmButton();
	}
}