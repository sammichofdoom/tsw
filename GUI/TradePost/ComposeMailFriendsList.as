//Imports
import gfx.core.UIComponent;
import gfx.controls.Button;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.controls.ScrollingList;
import com.GameInterface.Friends;

//Class
class GUI.TradePost.ComposeMailFriendsList extends UIComponent
{
    //Constants
    public static var FRIENDS_LIST_TYPE:String = "friendsListType";
    public static var CABAL_LIST_TYPE:String = "cabalListType";
    
    private static var FRIENDS_TITLE:String = LDBFormat.LDBGetText("Tradepost", "composeMailFriendRecipient");
    private static var CABAL_TITLE:String = LDBFormat.LDBGetText("Tradepost", "composeMailGuildMemberRecipient");
    private static var CANCEL_BUTTON_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
    private static var ACCEPT_BUTTON_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Accept")
    
    //Properties
    public var SignalButtonResponse:Signal;
    
    private var m_Title:TextField;
    private var m_ScrollingList:ScrollingList;
    private var m_DataProvider:Array;
    private var m_CancelButton:Button;
    private var m_AcceptButton:Button;

    //Constructor
    public function ComposeMailFriendsList()
    {
        super();
        
        SignalButtonResponse = new Signal();
        
        _visible = false;
    }
    
    //Config UI
    private function configUI():Void 
    {
        super.configUI();

        m_ScrollingList.addEventListener("itemDoubleClick", this, "ItemDoubleClickEventHandler");
        
        m_CancelButton.label = CANCEL_BUTTON_LABEL;
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_AcceptButton.label = ACCEPT_BUTTON_LABEL;
        m_AcceptButton.addEventListener("click", this, "ResponseButtonEventHandler");
    }
    
    //Item Double Click Event Handler
    private function ItemDoubleClickEventHandler():Void
    {
        if (m_DataProvider[m_ScrollingList.selectedIndex] != undefined)
        {
            ResponseButtonEventHandler( { target: m_AcceptButton } );
        }
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_CancelButton:    SignalButtonResponse.Emit();
                                    _visible = false;
                                    
                                    break;
                
            case m_AcceptButton:    if (m_DataProvider[m_ScrollingList.selectedIndex] != undefined)
                                    {
                                        SignalButtonResponse.Emit(m_DataProvider[m_ScrollingList.selectedIndex]);
                                        _visible = false;
                                    }
                                    
                                    break;
        }
    }
    
    //Open List
    public function OpenList(type:String):Void
    {
        _visible = true;
        
        m_DataProvider = new Array();
        
        switch (type)
        {
            case FRIENDS_LIST_TYPE:     m_Title.text = FRIENDS_TITLE;
                                        m_ScrollingList.rowCount = Friends.GetTotalFriends();
                                        
                                        for (var key in Friends.m_Friends)
                                        {
                                            m_DataProvider.push(Friends.m_Friends[key].m_Name);
                                        }
                                        
                                        break;
                                        
            case CABAL_LIST_TYPE:       m_Title.text = CABAL_TITLE;
                                        m_ScrollingList.rowCount = Friends.GetTotalGuildMembers();
                                        
                                        for (var key in Friends.m_GuildFriends)
                                        {
                                            m_DataProvider.push(Friends.m_GuildFriends[key].m_Name);
                                        }
                                        
                                        break;
        }
        
        m_ScrollingList.dataProvider = m_DataProvider;
    }
}