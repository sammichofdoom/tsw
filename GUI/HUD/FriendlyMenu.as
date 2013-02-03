import mx.transitions.easing.*;
import com.GameInterface.Tooltip.*;
import com.Utils.ID32;
import com.GameInterface.Utils;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.LDBFormat;
import com.Components.RightClickMenu;
import com.Components.RightClickItem;
import com.GameInterface.Friends;

var m_RightClickMenu:RightClickMenu;
var m_CharID:ID32;
var m_Name:String;

function onLoad()
{
    com.Utils.GlobalSignal.SignalShowFriendlyMenu.Connect( SlotShowFriendlyMenu, this );
}

function SlotShowFriendlyMenu( charID:ID32, name:String )
{
    m_CharID = charID;
	m_Name = name;
  
    if (m_RightClickMenu != undefined)
    {
      m_RightClickMenu.removeMovieClip();
    }
  
    m_RightClickMenu = attachMovie("RightClickMenu", "m_RightClickMenu", getNextHighestDepth());
    m_RightClickMenu.width = 200;
    m_RightClickMenu._x = _xmouse;
    m_RightClickMenu._y = _ymouse;
    
    var dataProvider:Array = new Array();
    
    var clientId = CharacterBase.GetClientCharID();
    var isClient = charID.Equal(clientId);
	
	var isGm:Boolean = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0;
    var groupElementAdded:Boolean = false;
    // Invite. If not the client and client is leader or not already in a team. And the target shouldn't be in a team.
    if ( !isClient && charID.IsPlayer() && Friends.CanInviteToGroup(charID) )
    //!TeamInterface.IsInTeam(charID) && ( TeamInterface.IsClientTeamLeader(clientId) || !TeamInterface.IsInTeam(clientId) ) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "InviteToGroup"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotAddTeamMember, this);
        dataProvider.push(item);
        groupElementAdded = true;
    }
    
    // Kick.
    if ( !isClient && charID.IsPlayer() && Friends.CanKickFromGroup(charID) )
    //&& TeamInterface.IsInClientTeam(charID) && TeamInterface.IsClientTeamLeader() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "RemoveFromGroup"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotRemoveTeamMember, this);
        dataProvider.push(item);
        groupElementAdded = true;
    }
    //Summon.
    if ( !isClient && charID.IsPlayer() && TeamInterface.IsInClientTeam(charID) && TeamInterface.IsClientTeamLeader() && TeamInterface.CanSummonHere() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "Summon"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotSummonTeamMember, this);
        dataProvider.push(item);
        groupElementAdded = true;
    }
  
    //Promote.
    if( !isClient && charID.IsPlayer() && TeamInterface.IsInClientTeam(charID) && TeamInterface.IsClientTeamLeader() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "MakeLeader"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotMakeTeamLeader, this);
        dataProvider.push(item);
        groupElementAdded = true;
    }
  
    //Leave.
    if( isClient && TeamInterface.IsInTeam(charID) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "LeaveGroup"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotLeaveTeam, this);
        dataProvider.push(item);
        groupElementAdded = true;
    }
    
    //Loot options.
    if( isClient && TeamInterface.IsInTeam(charID) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("TeamGUI", "LootOptions"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotToggleLootOptions, this);
        dataProvider.push(item);
        groupElementAdded = true;
    }
    
    if (groupElementAdded)
    {
        dataProvider.push(RightClickItem.MakeSeparator() );
    }
    
    var raidElementAdded:Boolean = false;
    //Raid
    if( isClient && TeamInterface.IsClientTeamLeader() && !TeamInterface.IsInRaid(charID))
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "CreateRaid"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotCreateRaid, this);
        dataProvider.push(item);
        raidElementAdded = true;
    }
  
    if ( !isClient && TeamInterface.IsClientRaidLeader() && 
         !TeamInterface.IsInClientTeam(charID) && !TeamInterface.IsInClientRaid(charID) &&
         (!TeamInterface.IsInTeam(charID) || TeamInterface.IsTeamLeader(charID))
        )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("Gamecode", "InviteToRaid"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotInviteToRaid, this);
        dataProvider.push(item);
        raidElementAdded = true;
    }
    
    var moveCharId:ID32 = TeamInterface.GetCharacterMarkedForTeamMove();
    var moveChar:CharacterBase = new CharacterBase(moveCharId);
    
    if( !isClient && TeamInterface.IsClientRaidLeader() && moveCharId.IsNull() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "ChangeTeam"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotMarkForTeamSwap, this);
        dataProvider.push(item);
        raidElementAdded = true;
    }
    
    if( !isClient && TeamInterface.IsClientRaidLeader() && moveCharId.Equal(charID))
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "CancelChangeTeam"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotCancelTeamSwap, this);
        dataProvider.push(item);
        raidElementAdded = true;
    }
    
    var newTeam:ID32 = TeamInterface.GetTeamIDFromRaid(m_CharID);
    var oldTeam:ID32 = TeamInterface.GetTeamIDFromRaid(moveCharId);
    
    if( !isClient && TeamInterface.IsClientRaidLeader() && !moveCharId.IsNull() && !newTeam.Equal(oldTeam) )
    {
        var itemText:String = LDBFormat.Printf(LDBFormat.LDBGetText("CharacterMenuGUI", "SwapTeamsWithCharacter"),moveChar.GetName())
        var item = new RightClickItem(itemText, false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotTeamSwap, this);
        dataProvider.push(item);
        raidElementAdded = true;
    }
    
    if( TeamInterface.IsClientRaidLeader() && !moveCharId.IsNull() && !newTeam.Equal(oldTeam) )
    {
        var itemText:String = LDBFormat.Printf(LDBFormat.LDBGetText("CharacterMenuGUI", "MoveCharacterToTeam"),moveChar.GetName())
        var item = new RightClickItem(itemText, false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotTeamMove, this);
        dataProvider.push(item);
        raidElementAdded = true;
    }
  
    if( isClient && TeamInterface.IsInRaid(charID) && TeamInterface.IsClientTeamLeader() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "LeaveRaid"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotLeaveRaid, this);
        dataProvider.push(item);
        raidElementAdded = true;
    }
    
    if( !isClient && TeamInterface.IsClientTeamLeader() && TeamInterface.IsClientRaidLeader() && !TeamInterface.IsInClientTeam(charID) && TeamInterface.IsInClientRaid(charID) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "RemoveFromRaid"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotKickFromRaid, this);
        dataProvider.push(item);
        raidElementAdded = true;
    }
    
    if (raidElementAdded)
    {
        dataProvider.push(RightClickItem.MakeSeparator() );
    }
    
    var miscElementAdded:Boolean = false;
    // Trade. Assuming trading with npc is going to be done similar to mission givers.
    if( !isClient && charID.IsPlayer() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "Trade"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotTrade, this);
        dataProvider.push(item);
        miscElementAdded = true;
    }

    // Meet up
    if( !isClient && charID.IsPlayer() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "meetUpMenuItem"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotMeetUp, this);
        dataProvider.push(item);
        miscElementAdded = true;
    }
    
    // Send a Message
    if( !isClient && charID.IsPlayer() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "sendAMessageMenuItem"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotSendMessage, this);
        dataProvider.push(item);
        miscElementAdded = true;
    }

    // Inspect.
    if( !isClient && charID.IsPlayer() )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "Inspect"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotInspect, this);
        dataProvider.push(item);
        miscElementAdded = true;
    }
    
    if (miscElementAdded)
    {
        dataProvider.push(RightClickItem.MakeSeparator() );
    }
       
    var guildElementAdded:Boolean = false;
    //Invite to guild.
	if ( !isClient && charID.IsPlayer()  && Friends.CanInviteToGuild(charID) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "InviteToGuild"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotInviteToGuild, this);
        dataProvider.push(item);
        guildElementAdded = true;
    }
    
    
    if( !isClient && charID.IsPlayer() && Friends.CanPromote(charID) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "Promote"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotPromoteGuildMember, this);
        dataProvider.push(item);
        guildElementAdded = true;
    }

    if( !isClient && charID.IsPlayer() && Friends.CanDemote(charID) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "Demote"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotDemoteGuildMember, this);
        dataProvider.push(item);
        guildElementAdded = true;
    }
    
    if (guildElementAdded)
    {
        dataProvider.push(RightClickItem.MakeSeparator() );
    }
       
    //Add Friend
    if( !isClient && charID.IsPlayer()  && Friends.CanAddFriend(charID))
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "MakeFriend"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotAddFriend, this);
        dataProvider.push(item);
    }
    
    //Remove Friend
    if( !isClient && charID.IsPlayer() && Friends.CanRemoveFriend(charID) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "RemoveFriend"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotRemoveFriend, this);
        dataProvider.push(item);
    }
    
    //Add to IgnoreList
    if( !isClient && charID.IsPlayer() && Friends.CanIgnore(m_Name) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "Ignore"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotIgnore, this);
        dataProvider.push(item);
    }
    
    //Remove from IgnoreList
    if( !isClient && charID.IsPlayer() && Friends.CanUnignore(m_Name) )
    {
        var item = new RightClickItem(LDBFormat.LDBGetText("CharacterMenuGUI", "Unignore"), false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(SlotUnignore, this);
        dataProvider.push(item);
    }

    if (dataProvider.length > 0 && dataProvider[dataProvider.length - 1].m_IsSeparator)
    {
        dataProvider.splice(dataProvider.length - 1, 1);
    }
	
	if (dataProvider.length > 0)
	{
		m_RightClickMenu.dataProvider = dataProvider;
		m_RightClickMenu.Show();
		
		// Fade in.
		m_RightClickMenu._alpha = 0;
		m_RightClickMenu.tweenTo( 0.2, {_alpha:100}, Back.easeOut )
		m_RightClickMenu.onTweenComplete = undefined;
	}
}

function SlotAddTeamMember()
{
    TeamInterface.InviteToTeam( m_CharID ); 
}

function SlotRemoveTeamMember()
{
    TeamInterface.KickFromTeam( m_CharID );
}

function SlotSummonTeamMember()
{
    TeamInterface.SummonRequest( m_CharID );
}

function SlotMakeTeamLeader()
{
    TeamInterface.PromoteToLeader( m_CharID );
}

function SlotLeaveTeam()
{
    TeamInterface.LeaveTeam( m_CharID );
}

function SlotToggleLootOptions()
{
    TeamInterface.ToggleLootOptions();
}

function SlotCreateRaid()
{
    TeamInterface.CreateRaid( );
}

function SlotLeaveRaid()
{
    TeamInterface.LeaveRaid();
}

function SlotInviteToRaid()
{    
    TeamInterface.InviteToRaid(m_CharID);
}

function SlotMarkForTeamSwap()
{    
    TeamInterface.MarkForTeamMove(m_CharID);
}

function SlotCancelTeamSwap()
{    
    TeamInterface.CancelTeamMove();
}

function SlotTeamSwap()
{    
    TeamInterface.TeamSwap(m_CharID, TeamInterface.GetCharacterMarkedForTeamMove());
}

function SlotTeamMove()
{    
    var newTeam:ID32 = TeamInterface.GetTeamIDFromRaid(m_CharID);
    TeamInterface.TeamMove(TeamInterface.GetCharacterMarkedForTeamMove(), newTeam);
}

function SlotKickFromRaid()
{
    TeamInterface.KickFromRaid(m_CharID);
}

function SlotTrade()
{
    Utils.StartTrade(m_CharID);
}

function SlotMeetUp():Void
{
    Friends.MeetUp(m_CharID);
}

function SlotSendMessage()
{
    com.GameInterface.Chat.SetChatInput( "/"+LDBFormat.LDBGetText("ChatCommands", "TellCommand_Name") + " " + m_Name + " " );
}

function SlotInspect()
{
    _global.com.Utils.GlobalSignal.SignalShowInspectWindow.Emit(m_CharID);
}

function SlotInviteToGuild()
{
	//Invite
	Friends.InviteToGuildByName(m_Name);
}

function SlotPromoteGuildMember()
{
    //Promote
	Friends.PromoteGuildMember(m_CharID);
}

function SlotDemoteGuildMember()
{
    //Demote
	Friends.DemoteGuildMember(m_CharID);
}

function SlotAddFriend()
{
	Friends.AddFriend(m_Name);
}

function SlotRemoveFriend()
{
	Friends.RemoveFriend(m_Name);
}

function SlotIgnore()
{
	Friends.Ignore(m_Name);
}

function SlotUnignore()
{
	Friends.Unignore(m_Name);
}
