//Imports
import com.Utils.LDBFormat;
import GUI.Friends.Views.Row;
import mx.utils.Delegate;
import com.Components.RightClickItem;
import com.GameInterface.Game.Character;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Friends;
import com.Utils.ID32;
import com.Utils.Faction;
import gfx.core.UIComponent;
import com.Components.MultiColumnListView;

//Class
class GUI.Friends.Views.View extends UIComponent
{
    //Constants
    public static var FRIENDS_ITEM_TYPE:String = "friendsItemType";
    public static var CABAL_ITEM_TYPE:String = "cabalItemType";
    public static var IGNORED_ITEM_TYPE:String = "ignoredItemType";
    
    private static var LEFT_CLICK_INDEX:Number = 1;
    private static var RIGHT_CLICK_INDEX:Number = 2;
    private static var RIGHT_CLICK_MOUSE_OFFSET:Number = 5;
    private static var SCROLL_WHEEL_SPEED:Number = 10;
    private static var ONLINE_COLOR:Number = 0x00FF00;
    private static var OFFLINE_COLOR:Number = 0xFF0000;
    private static var DRAGON:String = LDBFormat.LDBGetText("FactionNames", "DragonCapitalizationCase");
    private static var TEMPLARS:String = LDBFormat.LDBGetText("FactionNames", "TemplarsCapitalizationCase");
    private static var ILLUMINATI:String = LDBFormat.LDBGetText("FactionNames", "IlluminatiCapitalizationCase");
    
    //Properties
    private var m_Character:Character;

    private var m_List:MultiColumnListView;
    private var m_ScrollBar:MovieClip;
    
    private var m_RightClickMenu:MovieClip;
    private var m_AllowRightClick:Boolean;
    
    private var m_RowID:ID32;
    private var m_RowName:String;
    private var m_RowOnline:Boolean;
    
    private var m_MessageWindow:MovieClip;
    
    //Constructor
    private function View()
    {
        super();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_Character = Character.GetClientCharacter();
        
        CreateRightClickMenu();

        m_MessageWindow = attachMovie("MessageWindow", "m_MessageWindow", getNextHighestDepth());
        
        m_List.SetItemRenderer("FriendsItemRenderer");
        m_List.SetHeaderSpacing(3);
        m_List.SetShowBottomLine(true);
        m_List.SetScrollBar(m_ScrollBar);
		m_List.SetUseMask(false);
        m_List.SetSize(723, 326);
    }

    //Create Right Click Menu
    private function CreateRightClickMenu():Void
    {
        m_RightClickMenu = attachMovie("RightClickMenu", "m_RightClickMenu", getNextHighestDepth());
        m_RightClickMenu.width = 200;
        m_RightClickMenu.SetHandleClose(false);
        m_RightClickMenu.SignalWantToClose.Connect(HideRightClickMenu, this);
        m_AllowRightClick = true;
    }
    
    //Hide Right Click Menu and Message Prompt
    public function HideRightClickMenuAndMessagePrompt():Void
    {
        HideRightClickMenu();
        
        if (m_MessageWindow)
        {
            m_MessageWindow.HideMessageWindow();
        }
    }
    
    //Hide Right Click Menu
    private function HideRightClickMenu():Void
    {
        if (m_RightClickMenu)
        {
            m_RightClickMenu.Hide();
        }
    }
    
    //On Mouse Press
    private function onMousePress(buttonIndex:Number, clickCount:Number):Void
    {
        HideRightClickMenu();
    }
    
    //Row Selected
    private function RowSelected(buttonIndex:Number, itemID:ID32, playerName:String, playerIsOnline:Boolean, itemType:String):Void
    {     
        m_RowID = itemID;
        m_RowName = playerName;
        m_RowOnline = playerIsOnline;

        var dataProvider:Array = new Array();
        
        dataProvider.push(new RightClickItem(m_RowName, true, RightClickItem.LEFT_ALIGN));
        dataProvider.push(RightClickItem.MakeSeparator());
       
        if (Friends.CanInviteToGroup(m_RowID))
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "inviteToGroupMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotInviteToGroup, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanKickFromGroup(m_RowID))
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "removeFromGroupMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotRemoveFromGroup, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanAddFriend(m_RowID) && itemType != IGNORED_ITEM_TYPE)
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "addFriendMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotAddFriend, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanRemoveFriend(m_RowID) && itemType != IGNORED_ITEM_TYPE)
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "removeFriendMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotRemoveFriend, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanInviteToGuild(m_RowID) && itemType != CABAL_ITEM_TYPE)
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "inviteToGuildMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotInviteToGuild, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanRemoveFromGuild(m_RowID) && itemType == CABAL_ITEM_TYPE)
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "removeFromGuildMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotRemoveFromGuild, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanPromote(m_RowID) && itemType == CABAL_ITEM_TYPE)
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "promoteMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotPromote, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanDemote(m_RowID) && itemType == CABAL_ITEM_TYPE)
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "demoteMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotDemote, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanIgnore(m_RowName))
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "ignoreMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotIgnore, this);
            dataProvider.push(item);
        }
        
        if (Friends.CanUnignore(m_RowName))
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "unignoreMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotUnignore, this);
            dataProvider.push(item);
        }
        
        if (!m_Character.IsInCombat() && m_RowOnline && itemType == FRIENDS_ITEM_TYPE)
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "meetUpMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotMeetUp, this);
            dataProvider.push(item);
        }
        
        if (m_RowOnline && !m_Character.GetID().Equal(m_RowID))
        {
            var item = new RightClickItem(LDBFormat.LDBGetText("FriendsGUI", "sendAMessageMenuItem"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotSendMessage, this);
            dataProvider.push(item);            
        }

        m_RightClickMenu.dataProvider = dataProvider;

        if (buttonIndex == RIGHT_CLICK_INDEX && m_AllowRightClick)
        {
            if (!m_RightClickMenu._visible && dataProvider.length > 2)
            {
                PositionRightClickMenu();
                m_RightClickMenu.Show();
            }
            else 
            {
                if (m_RightClickMenu.hitTest(_root._xmouse, _root._ymouse) || dataProvider.length <= 2)
                {
                    m_RightClickMenu.Hide();
                }
                else
                {
                    PositionRightClickMenu();
                }
            }
        }
    }
    
    //Position Right Click Menu
    private function PositionRightClickMenu():Void
    {
        var visibleRect = Stage["visibleRect"];
        
        m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._xmouse + m_RightClickMenu._width - visibleRect.width);
        m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._ymouse + m_RightClickMenu._height - visibleRect.height);
    }
    
    //Slot Invite To Group
    private function SlotInviteToGroup():Void
    {
        Friends.InviteToGroup(m_RowID);
    }
    
    //Slot Remove From Group
    private function SlotRemoveFromGroup():Void
    {
        Friends.KickFromGroup(m_RowID);
    }
    
    //Slot Add Friend
    private function SlotAddFriend():Void
    {
        Friends.AddFriend(m_RowName);
    }
    
    //Slot Remove Friend
    private function SlotRemoveFriend():Void
    {
        Friends.RemoveFriend(m_RowName);
    }
    
    //Slot Invite To Guild
    private function SlotInviteToGuild():Void
    {
        Friends.InviteToGuildByName(m_RowName);
    }
    
    //Slot Remove From Guild
    private function SlotRemoveFromGuild():Void
    {
        Friends.RemoveFromGuild(m_RowID);
    }
    
    //Slot Promote
    private function SlotPromote():Void
    {
        Friends.PromoteGuildMember(m_RowID);
    }
    
    //Slot Demote
    private function SlotDemote():Void
    {
        Friends.DemoteGuildMember(m_RowID);
    }
    
    //Slot Ignore
    private function SlotIgnore():Void
    {
        Friends.Ignore(m_RowName);
    }
    
    //Slot Unignore
    private function SlotUnignore():Void
    {
        Friends.Unignore(m_RowName);
    }
    
    //Slot Meet Up
    private function SlotMeetUp():Void
    {
        Friends.MeetUp(m_RowID);
    }
    
    //Slot Send Message
    private function SlotSendMessage():Void
    {
        m_MessageWindow.ShowMessageWindow(m_RowName);
    }
    
    //Set Allow Right Click
    public function set allowRightClick(value:Boolean):Void
    {
        m_AllowRightClick = value;
    }
    
    //Get Allow Right Click
    public function get allowRightClick():Boolean
    {
        return m_AllowRightClick;
    }
    
    //Get Faction Name
    private function GetFactionName(factionID:Number):String
    {
        switch (factionID)
        {
            case _global.Enums.Factions.e_FactionDragon:        return DRAGON;
            case _global.Enums.Factions.e_FactionTemplar:       return TEMPLARS;
            case _global.Enums.Factions.e_FactionIlluminati:    return ILLUMINATI;
        }
    }
}