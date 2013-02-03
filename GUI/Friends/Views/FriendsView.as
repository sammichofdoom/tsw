//Imports
import com.Utils.LDBFormat;
import GUI.Friends.Views.Row;
import GUI.Friends.Views.View;
import com.GameInterface.AccountManagement;
import com.GameInterface.DimensionData;
import com.GameInterface.Friends;
import com.Utils.ID32;
import com.Utils.Faction;
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;

//Class
class GUI.Friends.Views.FriendsView extends View
{
    //Constants
    private static var COLUMN_NAME:Number = 0;
    private static var COLUMN_SOCIETY:Number = 1;
    private static var COLUMN_DIMENSION:Number = 2;
    private static var COLUMN_STATUS:Number = 3;
    
    //Properties
    private var m_Header:MovieClip;
    private var m_FriendsArray:Array;
    
    //Constructor
    private function FriendsView()
    {
        super();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        SlotFriendsUpdate();
        Friends.SignalFriendsUpdated.Connect(SlotFriendsUpdate, this);
        
        m_List.SignalItemClicked.Connect(SlotItemClicked, this);
        m_List.SignalMovieClipAdded.Connect(SlotMovieClipAdded, this);
        m_List.AddColumn(COLUMN_NAME, LDBFormat.LDBGetText("FriendsGUI", "nameColumnTitle"), 168, 0);
        m_List.AddColumn(COLUMN_SOCIETY, LDBFormat.LDBGetText("FriendsGUI", "secretSocietyColumnTitle"), 226, 0);
        m_List.AddColumn(COLUMN_DIMENSION, LDBFormat.LDBGetText("FriendsGUI", "dimensionColumnTitle"), 226, 0);
        m_List.AddColumn(COLUMN_STATUS, LDBFormat.LDBGetText("FriendsGUI", "statusColumnTitle"), 100, 0);
        
        m_ScrollBar._height = m_List._height - 38;
    }

    //Slot Item Clicked
    public function SlotItemClicked(index:Number, buttonIndex:Number):Void
    {
        var friendID:ID32 = m_List.GetItems()[index].GetId();
        var friendInstance:Number = friendID.GetInstance();
        
        RowSelected (
                    buttonIndex,
                    friendID,
                    Friends.m_Friends[friendInstance].m_Name,
                    Friends.m_Friends[friendInstance].m_Online,
                    View.FRIENDS_ITEM_TYPE
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
    
    //Slot Friends Update
    private function SlotFriendsUpdate():Void
    {
        m_Header.m_Title.text = LDBFormat.LDBGetText("FriendsGUI", "friendsTitle") + " (" + Friends.GetOnlineFriends() + "/" + Friends.GetTotalFriends() + ")";

        m_FriendsArray = new Array();
        
        m_List.RemoveAllItems();
        
        for (var key in Friends.m_Friends) 
        {
            var textColor:Number = (Friends.m_Friends[key].m_Online) ? 0x00FF00 : 0xFF0000;
            
            var friendsItem:MCLItemDefault = new MCLItemDefault(Friends.m_Friends[key].m_FriendID);

            var nameAndRightClickButtonValue:MCLItemValueData = new MCLItemValueData();
            nameAndRightClickButtonValue.m_Text = Friends.m_Friends[key].m_Name;
            nameAndRightClickButtonValue.m_TextColor = textColor;
            nameAndRightClickButtonValue.m_TextSize = 12;
            nameAndRightClickButtonValue.m_MovieClipName = "RightClickButton";
            nameAndRightClickButtonValue.m_MovieClipWidth = 20;
            friendsItem.SetValue(COLUMN_NAME, nameAndRightClickButtonValue, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
            
            var secretSocietyValueData:MCLItemValueData = new MCLItemValueData();
            secretSocietyValueData.m_Text = GetFactionName(Friends.m_Friends[key].m_Faction);
            secretSocietyValueData.m_TextColor = textColor;
            secretSocietyValueData.m_TextSize = 12;
            friendsItem.SetValue(COLUMN_SOCIETY, secretSocietyValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
            
            var dimensionValueData:MCLItemValueData = new MCLItemValueData();
            dimensionValueData.m_Text = GetDimensionData(Friends.GetFriendDimension(Friends.m_Friends[key].m_FriendID));
            dimensionValueData.m_TextColor = textColor;
            dimensionValueData.m_TextSize = 12;
            friendsItem.SetValue(COLUMN_DIMENSION, dimensionValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
            
            var statusValueData:MCLItemValueData = new MCLItemValueData();
            statusValueData.m_Text = (Friends.m_Friends[key].m_Online) ? LDBFormat.LDBGetText("FriendsGUI", "statusOnline") : LDBFormat.LDBGetText("FriendsGUI", "statusOffline");
            statusValueData.m_TextColor = textColor;
            statusValueData.m_TextSize = 12;
            friendsItem.SetValue(COLUMN_STATUS, statusValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);
            
            m_FriendsArray.push(friendsItem);
        }
        
        m_List.AddItems(m_FriendsArray);
    }
    
    //Get Dimension Data
    private function GetDimensionData(dimensionId:Number):String
    {
        var dimensions:Array = AccountManagement.GetInstance().m_Dimensions;

        for (var i:Number = 0; i < dimensions.length; i++)
        {
            if (dimensions[i].m_Id == dimensionId)
            {
                return dimensions[i].m_Name;
            }
        }
        
        return undefined;
    }
}