import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.DropdownMenu;
import gfx.controls.ScrollingList;
import gfx.controls.TextArea;
import gfx.controls.Label;
import gfx.controls.TextInput;
import gfx.controls.ButtonGroup;

import com.Components.SearchBox;
import com.Components.DataGridHeader;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import com.GameInterface.Guild.*;
import com.Components.FCButton;

class GUI.CabalManagement.CabalMembers extends UIComponent
{
	private var m_MembersInfoHeader:Label;
	private var m_YourRoleLabel:Label;
	private var m_YourRole:Label;
	private var m_GovernmentTypeLabel:Label;
	private var m_GovernmentType:Label;
	private var m_TotalMembersLabel:Label;
	private var m_TotalMembers:MovieClip;
	
	private var m_RolePermissionsHeader:Label;
	private var m_RolePermissionsTextArea:TextArea;
	private var m_RoleButton:FCButton;
	private var m_PermissionsButton:FCButton;
	private var m_RoleDropdown:MovieClip;
	private var m_PermissionsDropdown:MovieClip;
	private var m_RolePermissionButtonGroup:ButtonGroup;
	
	private var m_MembersListHeader:Label;
	private var m_Header1:DataGridHeader;
	private var m_Header2:DataGridHeader;
	private var m_Header3:DataGridHeader;
	private var m_MembersScrollingList:ScrollingList;
	private var m_MembersSearchBox:SearchBox;

	private var m_KickButtton:Button;
	private var m_DemoteButton:Button;
	private var m_PromoteButton:Button;
	
	private var m_RoleHeader:Array;
	private var m_PermissionHeader:Array;
	private var m_Permissions:Array;
	private var m_Roles:Array;
	
	private var m_MembersQuickList:Array;
	private var m_FullMemberList:Array;
	private var m_Members:Array;
	private var m_Guild:Guild;
	
	private function CabalMembers()
	{
		Guild.GetInstance().GetGuildMembers();
		m_Guild = Guild.GetInstance();
		
		m_Guild.SignalMembersUpdate.Connect( SlotMemberUpdated, this );
		m_Guild.SignalRankUpdated.Connect( SlotRankUpdated, this);
		m_Guild.SignalGoverningformUpdated.Connect( SlotGoverningformUpdated, this);
	}
	
	private function configUI()
	{
		m_RoleDropdown.disableFocus = true;
		m_PermissionsDropdown.disableFocus = true;
		m_RoleDropdown.addEventListener("change", this, "RemoveFocus");
		m_PermissionsDropdown.addEventListener("change", this, "RemoveFocus");
		
		m_MembersSearchBox.SetSearchOnInput(true);
		m_MembersSearchBox.SetDefaultText(LDBFormat.LDBGetText("GenericGUI", "SearchText"));
		m_MembersSearchBox.addEventListener("search", this, "SearchTextChanged");
		
		m_RolePermissionButtonGroup = new ButtonGroup;
		
		m_RoleButton.group = m_RolePermissionButtonGroup;
		m_RoleButton.SetTooltipText(LDBFormat.LDBGetText("GenericGUI", "RankButtonTooltip"));
		
		m_PermissionsButton.group = m_RolePermissionButtonGroup;
		m_PermissionsButton.SetTooltipText(LDBFormat.LDBGetText("GuildGUI", "PermissionButtonTooltip"));
		
		SetLabels();
		
		FillMembersInfo();
		FillRolePermissions();
		FillMemberList();
		
		m_KickButtton.addEventListener("click", this, "KickMembers");
		m_DemoteButton.addEventListener("click", this, "DemoteMembers");
		m_PromoteButton.addEventListener("click", this, "PromoteMembers");
		
		m_KickButtton.disableFocus = true;
		m_DemoteButton.disableFocus = true;
		m_PromoteButton.disableFocus = true;
		
		m_MembersScrollingList.addEventListener("itemClick", this, "SelectMember");
		
		m_Header1.data = "nickName";
		m_Header2.data = "playfield";
		m_Header3.data = "guildRank";
		
		m_Header1.addEventListener("sort", this, "SlotSortMembers");
		m_Header2.addEventListener("sort", this, "SlotSortMembers");
		m_Header3.addEventListener("sort", this, "SlotSortMembers");
	}
	
	function SlotSortMembers(event:Object)
	{
		m_MembersQuickList.sortOn(event.field, event.flags);
		m_MembersScrollingList.dataProvider = m_MembersQuickList;
		m_MembersScrollingList.invalidateData();
	}
	
	function SelectMember(event:Object)
	{
		var isSelected = !m_MembersScrollingList.dataProvider[event.index].selected;
		m_MembersScrollingList.dataProvider[event.index].selected = isSelected;
		m_MembersScrollingList.invalidateData();
		Guild.GetInstance().SetMemberSelected(m_MembersScrollingList.dataProvider[event.index].id, isSelected);
	}
	
	private function RemoveFocus():Void
	{
		Selection.setFocus(null);
	}
	
	private function GetSelectedMembers():Array
	{
		var memberArray:Array = new Array();
		for(var i = 0; i < m_MembersScrollingList.dataProvider.length; i++)
		{
			if(m_MembersScrollingList.dataProvider[i].selected)
			{
				memberArray.push(m_MembersScrollingList.dataProvider[i].id);
			}
		}
		return memberArray;
	}
	
	private function KickMembers()
	{
		var memberArray:Array = GetSelectedMembers();
		Guild.GetInstance().KickMembers(memberArray);
	}
	
	private function DemoteMembers()
	{
		var memberArray:Array = GetSelectedMembers();
		Guild.GetInstance().DemoteMembers(memberArray);
	}
	
	private function PromoteMembers()
	{
		var memberArray:Array = GetSelectedMembers();
		Guild.GetInstance().PromoteMembers(memberArray);
	}
	
	private function SetLabels()
	{
		m_MembersInfoHeader.text = LDBFormat.LDBGetText("GuildGUI", "MembersInfo");
		m_YourRoleLabel.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_YourRole");
		m_GovernmentTypeLabel.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_GovernmentType");
		m_TotalMembersLabel.text = LDBFormat.LDBGetText("GuildGUI", "TotalMembers");
		
		m_RolePermissionsHeader.text = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_GuildMembershipRights");
		
		m_MembersListHeader.text = LDBFormat.LDBGetText("GuildGUI", "MembersList");
		m_Header1.label = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_Name");
		m_Header2.label = LDBFormat.LDBGetText("GuildGUI", "CurrentPlayfield");
		m_Header3.label = LDBFormat.LDBGetText("GuildGUI", "GuildRank");
		
		m_KickButtton.label = LDBFormat.LDBGetText("GuildGUI", "Kick");
		m_DemoteButton.label = LDBFormat.LDBGetText("GuildGUI", "DemoteMember");
		m_PromoteButton.label = LDBFormat.LDBGetText("GuildGUI", "PromoteMember");
		
	}
	
	private function SlotMemberUpdated()
	{
		FillMemberList();
		SearchTextChanged();
	}
	
	function SlotGoverningformUpdated()
	{
		FillMembersInfo();
		FillRolePermissions();
	}
	
	private function SlotRankUpdated()
	{
		FillMembersInfo();
	}
	
	private function FillMemberList()
	{
		m_Members = m_Guild.GetMembers();
		
		m_MembersQuickList = new Array();
		m_FullMemberList = new Array();
		
		for(var i:Number = 0; i < m_Members.length;i++)
		{
			AddGuildMemberToArray(m_Members[i], m_FullMemberList);
		}
		m_MembersQuickList = m_FullMemberList;
		m_MembersScrollingList.dataProvider = m_MembersQuickList;
		m_TotalMembers.text = m_FullMemberList.length;
		m_Header1.label = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_Name") + " ("+m_MembersQuickList.length+")";
		
	}
	
	///Helper function to add a guild member to a given array (To be dataprovider for the members list)
	private function AddGuildMemberToArray(guildMember:GuildMember, addArray:Array)
	{
		var memberObject:Object = 
		{
			id: guildMember.m_Instance,
			nickName: guildMember.m_Name,
			playfield: guildMember.m_Playfield,
			guildRank: guildMember.m_Role + 1,
			selected: guildMember.m_IsSelected
		};
		addArray.push(memberObject);
	}
	
	private function SearchTextChanged()
	{ 
		var searchText:String = m_MembersSearchBox.GetSearchText().toLowerCase();
		if(searchText == "")
		{
			m_MembersQuickList = m_FullMemberList;
		}
		else
		{
			var guild:Guild = Guild.GetInstance();
			var members:Array = guild.GetMembers();
			var searchMemberList:Array = new Array();
			
			var searchForLevel:Boolean = false;
			var levelToSearchFrom:Number = 0;
			var levelToSearchTo:Number = 0;
			var searchForLevelRange:Boolean = false;
			
			if(Number(searchText) != NaN)
			{
				searchForLevel = true;
				levelToSearchFrom = Number(searchText);
			}
			var splitString:Array = searchText.split('-');
			if(splitString.length == 2 && Number(splitString[0]) != NaN && Number(splitString[1]) != NaN)
			{
				searchForLevelRange = true;
				levelToSearchFrom = Number(splitString[0]);
				levelToSearchTo = Number(splitString[1]);
			}
			
			for(var i:Number = 0; i < members.length;i++)
			{
				if(searchForLevel)
				{
					if(levelToSearchFrom == members[i].m_Level)
					{
						AddGuildMemberToArray(members[i], searchMemberList);
					}
				}
				else if(searchForLevelRange)
				{
					if(levelToSearchFrom <= members[i].m_Level && levelToSearchTo >= members[i].m_Level)
					{
						AddGuildMemberToArray(members[i], searchMemberList);
					}
				}
				else
				{
					var gmName:String = members[i].m_Name.toLowerCase();
					if(gmName.indexOf(searchText) >= 0)
					{
						AddGuildMemberToArray(members[i], searchMemberList);
					}
				}
			}
			m_MembersQuickList = searchMemberList;
		}
		m_Header1.label = LDBFormat.LDBGetText("GuildGUI", "Guild_GuildManagementView_Name") + " ("+m_MembersQuickList.length+")";
		m_MembersScrollingList.dataProvider = m_MembersQuickList;
	}

	private function FillMembersInfo()
	{
		m_YourRole.text = m_Guild.GetRankName();
		m_GovernmentType.text = m_Guild.GetGuildGoverningForm();
		m_TotalMembers.text = m_Guild.m_NumMembers;
	}
	
	private function FillRolePermissions()
	{
		m_RoleHeader = new Array();
		m_Permissions = new Array();
		m_PermissionHeader = new Array();
		m_Roles = new Array();
		
		var maxRank = m_Guild.GetMaxRank();
		
		var rankArray = m_Guild.GetRankArray();
		
		for(var i = 0; i < rankArray.length; ++i)
		{
			m_RoleHeader.push(rankArray[i].GetName() + " (" + rankArray[i].GetRankNr() + "/" + maxRank + ")");
			m_Permissions.push(CreatePermissionsForRank(rankArray[i]));
		}
		
		m_RoleDropdown.dataProvider = m_RoleHeader;
		m_RoleDropdown.addEventListener("select", this, "RoleClicked");
		
		var permissionArray:Array = m_Guild.GetGuildPermissions();
		for(var i = 0; i < permissionArray.length; ++i)
		{
			m_PermissionHeader.push(permissionArray[i].GetPermissionText());
			m_Roles.push(CreateRanksForPermission(permissionArray[i].GetPermissionID()));
		}
		
		m_PermissionsDropdown.dataProvider = m_PermissionHeader;
		
		m_PermissionsDropdown.selectedIndex = 0;
		m_PermissionsDropdown.addEventListener("select", this, "PermissionClicked");
		m_PermissionsDropdown.label = m_PermissionHeader[0];
		
		m_RoleButton.selected = true;
		ShowRoleMenu();
		
		m_RolePermissionButtonGroup.addEventListener("change", this, "RolePermissionViewSwitch");
	}
	
	private function RolePermissionViewSwitch(event:Object)
	{
		if (event.item == m_RoleButton)
		{
			ShowRoleMenu();
		}
		else if (event.item == m_PermissionsButton)
		{
			ShowPermissionsMenu();
		}
	}
	
	private function CreatePermissionsForRank(rank:GuildRank):String
	{
		if(rank.GetAccess() == 0)
		{
			return "<li>" + LDBFormat.LDBGetText("GuildGUI", "NoPermissions");
		}
		
		var permString:String = "";
		var permissions = m_Guild.GetGuildPermissions();
		
		for(var i = 0; i < permissions.length; ++i)
		{
			if(rank.HasAccess(permissions[i].GetPermissionID()) == true)
			{
				permString += "<li>" + permissions[i].GetPermissionText(); 
			}
		}
			
		return permString;
	}
	
	function CreateRanksForPermission(permission:Number):String
	{
		var rankString:String = "";
		
		var ranks = m_Guild.GetRankArray();
		var maxRank = m_Guild.GetMaxRank();
		
		for(var i = 0; i < ranks.length; ++i)
		{
			if(ranks[i].HasAccess(permission) == true)
			{
				rankString += "<li>" + ranks[i].GetName() + " (" + ranks[i].GetRankNr() + "/" + maxRank + ")"; 
			}
		}
			
		return rankString;
	}
	
	private function ShowRoleMenu()
	{
		m_PermissionsDropdown._visible = false;
		m_RoleDropdown._visible = true;
		m_RoleDropdown.selectedIndex = (Guild.GetInstance().GetRankID() - 1);
		m_RolePermissionsTextArea.htmlText = m_Permissions[m_RoleDropdown.selectedIndex];
	}

	private function ShowPermissionsMenu()
	{
		m_PermissionsDropdown._visible = true;
		m_PermissionsDropdown.selectedIndex = 0;
		m_RoleDropdown._visible = false;
		m_RolePermissionsTextArea.htmlText = m_Roles[m_PermissionsDropdown.selectedIndex];
	}
	
	function PermissionClicked(event:Object)
	{
		m_RolePermissionsTextArea.htmlText = m_Roles[m_PermissionsDropdown.selectedIndex];
	}
	
	function RoleClicked(event:Object)
	{
		m_RolePermissionsTextArea.htmlText = m_Permissions[m_RoleDropdown.selectedIndex];
	}
}
