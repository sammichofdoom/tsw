import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;

import gfx.controls.Button;
import gfx.controls.TextInput;
import gfx.controls.DropdownMenu;
import gfx.controls.TextArea;
import gfx.controls.Label;

import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import com.GameInterface.Guild.*;

class GUI.CabalManagement.CabalInfo extends UIComponent
{
	private var m_TransferCashWindow:MovieClip;
	private var m_PopupOverlay:MovieClip;
	
	private var m_CreateGuildHeader:Label;
	private var m_TotalMembersLabel:Label;
	private var m_TotalMembers:MovieClip;
	private var m_GuildNameLabel:Label;
	private var m_GuildNameTextInput:TextInput;
	private var m_GovernmentTypeLabel:Label;
	private var m_GovernmentTypeDropdown:DropdownMenu;
	
	private var m_GuildMessageHeader:Label;
	private var m_GuildMessageTextBox:TextArea;
	
	private var m_BankBalanceHeader:Label;
	private var m_BankBalance:TextField;
	private var m_TransferCashButton:Button;
	
	private var m_ApplyButton:Button;
	
	private function configUI()
	{
		m_GovernmentTypeDropdown.disableFocus = true;
		m_GovernmentTypeDropdown.addEventListener("change", this, "RemoveFocus");
		
		SetLabels();
		SetData();
		
		m_TransferCashButton.addEventListener("click", this, "OpenTransferCashWindow");
		m_ApplyButton.disableFocus = true;
		m_ApplyButton.addEventListener("click", this, "UpdateChanges");
	}
	
	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}
	
	private function SetLabels()
	{
		m_CreateGuildHeader.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildInfoView_GeneralInformation");
		m_TotalMembersLabel.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildInfoView_TotalMembers");
		m_GuildNameLabel.text = LDBFormat.LDBGetText("GuildGUI", "GuildName");
		m_GovernmentTypeLabel.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_GovernmentType");
		
		m_GuildMessageHeader.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildInfoView_MessageOfTheDay");
		
		m_BankBalanceHeader.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildInfoView_BankBalance");
		m_TransferCashButton.label = LDBFormat.LDBGetText("GuildGUI", "TransferCash");
		
		m_ApplyButton.label = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_Change");
	}
	
	private function SetData()
	{
		Guild.GetInstance().GetGeneralGuildInfo();
		
		m_TotalMembers.text = Guild.GetInstance().m_NumMembers;
		
		m_GovernmentTypeDropdown.dataProvider = Guild.GetInstance().m_GoverningFormArray;
		m_GovernmentTypeDropdown.selectedIndex = Guild.GetInstance().m_GoverningformID;
		m_GovernmentTypeDropdown.rowCount = m_GovernmentTypeDropdown.dataProvider.length;
		
		
		Guild.GetInstance().SignalGuildCashUpdated.Connect( SlotBankBalanceUpdated, this );
		Guild.GetInstance().SignalGuildNameUpdated.Connect( SlotGuildNameUpdated, this );
		Guild.GetInstance().SignalMessageOfTheDayUpdated.Connect( SlotGuildMessageUpdated, this );
		Guild.GetInstance().SignalGoverningformUpdated.Connect( SlotGoverningformUpdated, this );
		
		SlotBankBalanceUpdated();
		SlotGuildNameUpdated();
		SlotGuildMessageUpdated();
		SlotGoverningformUpdated();
		
		m_GuildNameTextInput.maxChars = 40;
		
		if(!Guild.GetInstance().CanChangeName())
		{
			m_GuildNameTextInput.editable = false;
			m_GuildNameTextInput.disabled = true;
		}
		if(!Guild.GetInstance().CanChangeMessageOfTheDay())
		{
			m_GuildMessageTextBox.editable = false;
		}

		if(!Guild.GetInstance().CanChangeGoverningform())
		{
			m_GovernmentTypeDropdown.disabled = true;
		}
	}
	
	private function OpenTransferCashWindow()
	{
		m_TransferCashButton.disabled = true;
		_parent._parent._parent.m_LeaveButton.disabled = true;
		_parent._parent._parent.m_LeaveButton._alpha = 50;
		_parent._parent._parent.m_ButtonBar.disabled = true;
		_parent._parent.currentView.m_ApplyButton.disabled = true;
		
		
		m_PopupOverlay = attachMovie("WindowBackground", "m_PopupOverlay", getNextHighestDepth() );
		m_PopupOverlay._x = -10;
		m_PopupOverlay._y = -90;
		m_PopupOverlay._alpha = 0;
		m_PopupOverlay.tweenTo(1, { _alpha: 80 }, Strong.easeOut );
		
		m_TransferCashWindow = attachMovie("TransferCashPopup", "m_TransferCashWindow", getNextHighestDepth() );
		m_TransferCashWindow._visible = true;
		m_TransferCashWindow._alpha = 0;
		m_TransferCashWindow._x = 35;
		m_TransferCashWindow._y = 100;
		m_TransferCashWindow.tweenTo(1.2, { _alpha: 100, _y: 90 }, Strong.easeOut );
		
		m_TransferCashWindow.SignalCancel.Connect( CloseTranserCashWindow, this );
		m_TransferCashWindow.SignalSendCash.Connect( SlotSendCash, this );
		m_TransferCashWindow.SignalWithdrawCash.Connect( SlotWithdrawCash, this );
	}
	
	private function CloseTranserCashWindow()
	{
		_parent._parent._parent.m_LeaveButton.disabled = false;
		_parent._parent._parent.m_LeaveButton._alpha = 100;
		_parent._parent._parent.m_ButtonBar.disabled = false;
		_parent._parent.currentView.m_ApplyButton.disabled = false;
		
		m_PopupOverlay.tweenTo(1.2, { _alpha: 0 }, Strong.easeOut );
		m_TransferCashWindow.tweenTo(1, { _alpha: 0, _y: 100 }, Strong.easeOut );
		
		m_TransferCashWindow.onTweenComplete = Delegate.create(this, SlotRemoveTransferCashWindow);
	}
	
	private function SlotSendCash(amount:Number)
	{
		Guild.GetInstance().SendCash(amount);
		CloseTranserCashWindow();
	}
	
	private function SlotWithdrawCash(amount:Number)
	{
		Guild.GetInstance().WithdrawCash(amount);
		CloseTranserCashWindow();
	}
	
	private function SlotRemoveTransferCashWindow()
	{
		m_TransferCashWindow.removeMovieClip();
		m_PopupOverlay.removeMovieClip();
		m_TransferCashButton.disabled = false;
	}
	
	private function SlotGuildNameUpdated()
	{
		m_GuildNameTextInput.text  = Guild.GetInstance().m_GuildName;
	}
	
	private function SlotGoverningformUpdated()
	{
		m_GovernmentTypeDropdown.selectedIndex = Guild.GetInstance().m_GoverningformID;
	}
	
	private function SlotGuildMessageUpdated()
	{
		m_GuildMessageTextBox.text = Guild.GetInstance().m_MessageOfTheDay;
		
	}
	
	private function SlotBankBalanceUpdated()
	{
		m_BankBalance.text = Guild.GetInstance().m_Cash.toString();
	}
	
	public function UpdateChanges()
	{
		Guild.GetInstance().UpdateGuildInfoData(	m_GuildNameTextInput.text, 
													m_GuildMessageTextBox.text,
													0, 
													m_GovernmentTypeDropdown.selectedIndex );
	}	
}