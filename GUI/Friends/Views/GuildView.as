//Imports
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;
import com.GameInterface.Friends;
import com.GameInterface.Game.Character;
import com.Utils.Faction;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import GUI.Friends.Views.View;

//Class
class GUI.Friends.Views.GuildView extends View
{
    //Constants
    private static var COLUMN_NAME:Number = 0;
    private static var COLUMN_ROLE:Number = 1;
    private static var COLUMN_SOCIETY:Number = 2;
    private static var COLUMN_RANK:Number = 3;
    private static var COLUMN_REGION:Number = 4;
    private static var COLUMN_STATUS:Number = 5;
    
    //Properties
    private var m_Character:Character;
    private var m_Header:MovieClip;
    private var m_CabalArray:Array;
    
    //Constructor
    private function GuildView()
    {
        super();
        
        m_Character = Character.GetClientCharacter();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        SlotGuildUpdate();
        Friends.SignalGuildUpdated.Connect(SlotGuildUpdate, this);
        
        m_List.SignalItemClicked.Connect(SlotItemClicked, this);
        m_List.SignalMovieClipAdded.Connect(SlotMovieClipAdded, this);
        m_List.AddColumn(COLUMN_NAME, LDBFormat.LDBGetText("FriendsGUI", "nameColumnTitle"), 168, 0);
        m_List.AddColumn(COLUMN_ROLE, LDBFormat.LDBGetText("FriendsGUI", "roleColumnTitle"), 115, 0);
        m_List.AddColumn(COLUMN_SOCIETY, LDBFormat.LDBGetText("FriendsGUI", "secretSocietyColumnTitle"), 110, 0);
        m_List.AddColumn(COLUMN_RANK, LDBFormat.LDBGetText("FriendsGUI", "rankColumnTitle"), 70, 0);
        m_List.AddColumn(COLUMN_REGION, LDBFormat.LDBGetText("FriendsGUI", "regionColumnTitle"), 151, 0);
        m_List.AddColumn(COLUMN_STATUS, LDBFormat.LDBGetText("FriendsGUI", "statusColumnTitle"), 100, 0);
        
        m_ScrollBar._height = m_List._height - 38;
    }

    //Slot Item Clicked
    public function SlotItemClicked(index:Number, buttonIndex:Number):Void
    {
        var friendID:ID32 = m_List.GetItems()[index].GetId();

        RowSelected (
                    buttonIndex,
                    friendID,
                    Friends.m_GuildFriends[friendID.GetInstance()].m_Name,
                    Friends.m_GuildFriends[friendID.GetInstance()].m_Online,
                    View.CABAL_ITEM_TYPE
                    );
    }
    
    //Slot Movie Clip Added
    private function SlotMovieClipAdded(itemIndex:Number, columnId:Number, movieClip:MovieClip):Void
    {
        if (columnId == COLUMN_NAME)
        {
            movieClip.hitTestDisable = false;
            movieClip.m_Index = itemIndex;
            movieClip.m_Ref = this;
            movieClip.onPress = function() {this.m_Ref.SlotItemClicked(this.m_Index, 2);}
        }
    }
    
    //Slot Guild Update
    private function SlotGuildUpdate():Void
    {
        m_Header.m_Title.text = LDBFormat.LDBGetText("FriendsGUI", "guildTitle") + " (" + Friends.GetOnlineGuildMembers() + "/" + Friends.GetTotalGuildMembers() + ")";

        m_CabalArray = new Array();
        
        m_List.RemoveAllItems();

        for (var key in Friends.m_GuildFriends) 
        {
            var textColor:Number = (Friends.m_GuildFriends[key].m_Online) ? 0x00FF00 : 0xFF0000;
            
            var guildItem:MCLItemDefault = new MCLItemDefault(Friends.m_GuildFriends[key].m_FriendID);
            
            var nameAndRightClickButtonValue:MCLItemValueData = new MCLItemValueData();
            nameAndRightClickButtonValue.m_Text = Friends.m_GuildFriends[key].m_Name;
            nameAndRightClickButtonValue.m_TextColor = textColor;
            nameAndRightClickButtonValue.m_TextSize = 12;
            nameAndRightClickButtonValue.m_MovieClipName = (m_Character.GetName() != Friends.m_GuildFriends[key].m_Name) ? "RightClickButton" : "RightClickButtonDisabled";
            nameAndRightClickButtonValue.m_MovieClipWidth = 20;
            guildItem.SetValue(COLUMN_NAME, nameAndRightClickButtonValue, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);         
            
            var roleValueData:MCLItemValueData = new MCLItemValueData();
            roleValueData.m_Text = Friends.m_GuildFriends[key].m_Role;
            roleValueData.m_TextColor = textColor;
            roleValueData.m_TextSize = 12;
            guildItem.SetValue(COLUMN_ROLE, roleValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
            
            var societyValueData:MCLItemValueData = new MCLItemValueData();
            societyValueData.m_Text = GetFactionName(Friends.m_GuildFriends[key].m_Faction);
            societyValueData.m_TextColor = textColor;
            societyValueData.m_TextSize = 12;
            guildItem.SetValue(COLUMN_SOCIETY, societyValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
            
            var rankValueData:MCLItemValueData = new MCLItemValueData();
            rankValueData.m_Text = (Friends.m_GuildFriends[key].m_GuildRank + 1).toString();
            rankValueData.m_TextColor = textColor;
            rankValueData.m_TextSize = 12;
            guildItem.SetValue(COLUMN_RANK, rankValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
            
            var regionValueData:MCLItemValueData = new MCLItemValueData();
            regionValueData.m_Text = Friends.m_GuildFriends[key].m_Region;
            regionValueData.m_TextColor = textColor;
            regionValueData.m_TextSize = 12;
            guildItem.SetValue(COLUMN_REGION, regionValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
            
            var statusValueData:MCLItemValueData = new MCLItemValueData();
            statusValueData.m_Text = (Friends.m_GuildFriends[key].m_Online) ? LDBFormat.LDBGetText("FriendsGUI", "statusOnline") : LDBFormat.LDBGetText("FriendsGUI", "statusOffline");
            statusValueData.m_TextColor = textColor;
            statusValueData.m_TextSize = 12;
            guildItem.SetValue(COLUMN_STATUS, statusValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
            
            m_CabalArray.push(guildItem);
        }
        
        m_List.AddItems(m_CabalArray);
    }
}