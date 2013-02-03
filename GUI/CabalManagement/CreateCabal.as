import gfx.core.UIComponent;
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

class GUI.CabalManagement.CreateCabal extends UIComponent
{
	private var m_CreateGuildHeader:Label;
	private var m_GuildNameLabel:Label;
	private var m_GuildNameTextInput:TextInput;
	private var m_GovernmentTypeLabel:Label;
	private var m_GovernmentTypeDropdown:DropdownMenu;
	
	private var m_CreateGuildGuideHeader:Label;
	private var m_CreateGuildGuideText:TextArea;
	
	private var m_CreateButtton:Button;
	
	private function configUI()
	{
		SetLabels();
		
		m_GuildNameTextInput.text = "";
		m_GuildNameTextInput.textField.maxChars = 40;
		
		Guild.GetInstance().GetGeneralGuildInfo();
		
		m_GovernmentTypeDropdown.disableFocus = true;
		m_GovernmentTypeDropdown.addEventListener("change", this, "RemoveFocus");
				
		m_GovernmentTypeDropdown.dataProvider = Guild.GetInstance().m_GoverningFormArray;
		m_GovernmentTypeDropdown.selectedIndex = 0;
		m_GovernmentTypeDropdown.rowCount = m_GovernmentTypeDropdown.dataProvider.length;
		
		m_CreateButtton.addEventListener("click", this, "CreatingGuild");
		m_CreateButtton.disableFocus = true;
	}
	
	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}
	
	private function SetLabels()
	{
		m_CreateGuildHeader.text = LDBFormat.LDBGetText("GuildGUI","CreateGuild");
		m_GuildNameLabel.text = LDBFormat.LDBGetText("GuildGUI","GuildName");
		m_GovernmentTypeLabel.text = LDBFormat.LDBGetText("GuildGUI","Guild_GuildManagementView_GovernmentType");
		
		m_CreateGuildGuideHeader.text = LDBFormat.LDBGetText("GuildGUI","GuideCreateGuild");
		m_CreateGuildGuideText.text = LDBFormat.LDBGetText("GuildGUI", "CreateGuildGuide");
		
		m_CreateButtton.label = LDBFormat.LDBGetText("GuildGUI", "CreateButton");
	}
	
	public function CreatingGuild()
	{
		Guild.GetInstance().UpdateGuildInfoData(	m_GuildNameTextInput.text, 
													"",
													0, 
													m_GovernmentTypeDropdown.selectedIndex );
	}	
}