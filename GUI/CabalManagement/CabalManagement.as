import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.ButtonBar;
import gfx.controls.ViewStack;

import mx.utils.Delegate;
import com.Utils.Archive;
import flash.geom.Rectangle;

import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import com.GameInterface.Guild.*;

class GUI.CabalManagement.CabalManagement extends UIComponent
{
	private var m_CloseButton:Button;
	private var m_Background:MovieClip;
	private var m_Title:TextField;
	private var m_GuildName:TextField;
	private var m_ButtonBar:ButtonBar;
	private var m_Divider:MovieClip;
	private var m_ViewStack:ViewStack;
	private var m_LeaveButton:Button;
	
	public function CabalManagement()
	{
		Guild.GetInstance().GetGeneralGuildInfo();
		
		var visibleRect = Stage["visibleRect"];
		
		_x = visibleRect.x + (Stage.width / 2) - (_width / 2);
		_y = visibleRect.y + (Stage.height / 2) - (_height / 2);
		
		m_Background.onRelease = Delegate.create(this, SlotStopDrag);
		m_Background.onReleaseOutside = Delegate.create(this, SlotStopDrag);
		m_Background.onPress = Delegate.create(this, SlotStartDrag);
	}	
	
	private function configUI()
	{
		m_Title.text = LDBFormat.LDBGetText("GuildGUI","Guild_GuildManagementView_GuildManagment");
		m_LeaveButton.label = LDBFormat.LDBGetText("GuildGUI","Guild_GuildManagementView_Leave");
		Guild.GetInstance().SignalGuildNameUpdated.Connect( SlotGuildNameUpdated, this );
		Guild.GetInstance().SignalGuildCreated.Connect( SlotGuildCreated, this );
		SlotGuildNameUpdated();
		
		m_CloseButton.addEventListener("click", this, "CloseWindow");
		m_ButtonBar.addEventListener("focusIn", this, "RemoveSelection");
		m_LeaveButton.addEventListener("click", this, "LeaveGuild");

		m_LeaveButton.disableFocus = true;
		
		InitializeTabs();
	}
	
	private function SlotGuildCreated()
	{
		InitializeTabs();
	}
	
	private function SlotGuildNameUpdated()
	{
		m_GuildName.text = Guild.GetInstance().m_GuildName;
	}
	
	private function InitializeTabs()
	{
		if(!GuildBase.HasGuild())
		{
			m_LeaveButton._visible = false;
			m_GuildName._visible = false;
			m_ButtonBar._alpha = 0;
			m_Divider._visible = false;
			m_ButtonBar.disabled = true;
			m_ViewStack._y = 50;
			
			m_ButtonBar.dataProvider =[{ label: LDBFormat.LDBGetText("GuildGUI", "CreateGuild"), data:"CreateCabal" }];
		}
		else
		{
			m_ButtonBar.dataProvider = 	[ 	{ label: LDBFormat.LDBGetText("GuildGUI", "Info"), data:"InfoView" },							
											{ label: LDBFormat.LDBGetText("GuildGUI", "Members"), data:"MembersView" }
										];
		}
	}
	
	private function CloseWindow()
	{
		GuildBase.CloseGuildWindow();
	}
	
	private function LeaveGuild()
	{
		GuildBase.LeaveGuild();
	}
	
	private function RemoveSelection():Void
	{
		Selection.setFocus(null);
	}

	private function SlotStartDrag()
	{
		this.startDrag();
	}

	private function SlotStopDrag()
	{
		this.stopDrag();
	}
}