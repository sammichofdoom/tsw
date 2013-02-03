//Imports
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;
import com.GameInterface.Friends;
import com.Utils.Faction;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import GUI.Friends.Views.Row;
import GUI.Friends.Views.View;

//Class
class GUI.Friends.Views.IgnoredView extends View
{
    //Constants
    private static var COLUMN_NAME:Number = 0;

    //Properties
    private var m_Header:MovieClip;
    private var m_IgnoredArray:Array;
    
    //Constructor
    private function IgnoredView()
    {
        super();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        SlotIgnoredUpdate();
        Friends.SignalIgnoreListUpdated.Connect(SlotIgnoredUpdate, this);

        m_List.SignalItemClicked.Connect(SlotItemClicked, this);
        m_List.SignalMovieClipAdded.Connect(SlotMovieClipAdded, this);
        
        m_List.AddColumn(COLUMN_NAME, LDBFormat.LDBGetText("FriendsGUI", "nameColumnTitle"), 729, 0);
    }
    
    //Slot Item Clicked
    public function SlotItemClicked(index:Number, buttonIndex:Number):Void
    {
        var friendName:String = m_List.GetItems()[index].GetId();
        
        RowSelected (
                    buttonIndex,
                    new ID32(),
                    friendName,
                    false,
                    View.IGNORED_ITEM_TYPE
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
    private function SlotIgnoredUpdate():Void
    {
        m_IgnoredArray = new Array();
        
        m_List.RemoveAllItems();

        for (var key in Friends.m_IgnoredFriends)
        {
            var textColor:Number = (Friends.m_IgnoredFriends[key].m_Online) ? 0x00FF00 : 0xFF0000;
            
            var ignoredItem:MCLItemDefault = new MCLItemDefault(Friends.m_IgnoredFriends[key].m_Name);

            var nameAndRightClickButtonValue:MCLItemValueData = new MCLItemValueData();
            var name:String = Friends.m_IgnoredFriends[key].m_Name;
            name = name.substr(0, 1).toUpperCase() + name.substr(1);
            nameAndRightClickButtonValue.m_Text = name;
            nameAndRightClickButtonValue.m_TextColor = textColor;
            nameAndRightClickButtonValue.m_TextSize = 12;
            nameAndRightClickButtonValue.m_MovieClipName = "RightClickButton";
            nameAndRightClickButtonValue.m_MovieClipWidth = 20;
            ignoredItem.SetValue(COLUMN_NAME, nameAndRightClickButtonValue, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);

            m_IgnoredArray.push(ignoredItem);                     
        }
        
        m_List.AddItems(m_IgnoredArray);

        m_Header.m_Title.text = LDBFormat.LDBGetText("FriendsGUI", "ignoredTitle") + " (" + Friends.m_IgnoredFriends.length + ")";
    }
}