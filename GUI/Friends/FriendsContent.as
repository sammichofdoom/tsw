//Imports
import com.Components.WindowComponentContent;
import com.Utils.LDBFormat;
import gfx.controls.ButtonBar;
import GUI.Friends.FriendsViewsContainer;
import GUI.Friends.Views.PromptWindow;
import com.GameInterface.Friends;
import com.GameInterface.DistributedValue;

//Class
class GUI.Friends.FriendsContent extends WindowComponentContent
{
    //Constants
    public static var ADD_FRIEND:String = LDBFormat.LDBGetText("FriendsGUI", "addFriendPromptTitle");
    public static var CABAL_MANAGEMENT:String = LDBFormat.LDBGetText("FriendsGUI", "cabalManagementPromptButtonLabel");
    public static var INVITE_TO_CABAL:String = LDBFormat.LDBGetText("FriendsGUI", "addToCabalPromptTitle");
    public static var IGNORE_PLAYER:String = LDBFormat.LDBGetText("FriendsGUI", "ignorePlayerPromptTitle");
    
    private static var GENERAL_GAP:Number = 10;
    private static var RESULT_CONTROLS_Y:Number = 7;
    
    private static var FRIENDS:String = LDBFormat.LDBGetText("FriendsGUI", "friendsTitle");
    private static var GUILD:String = LDBFormat.LDBGetText("FriendsGUI", "guildTitle");
    private static var IGNORED:String = LDBFormat.LDBGetText("FriendsGUI", "ignoredTitle");
    
    //Properties
    private var m_ButtonBar:ButtonBar;
    private var m_TabButtonArray:Array;
    private var m_ViewsContainer:MovieClip;
    private var m_AddButton:MovieClip;
    private var m_CabalManagementButton:MovieClip;
    private var m_PromptWindow:MovieClip;
    
    //Constructor
    public function FriendsContent()
    {
        super();
    }
    
    //Config UI
	private function configUI():Void
    {
        m_TabButtonArray = new Array();
        m_TabButtonArray.push({label: FRIENDS, view: FriendsViewsContainer.FRIENDS_VIEW, responseLabel: ADD_FRIEND});
        m_TabButtonArray.push({label: GUILD, view: FriendsViewsContainer.GUILD_VIEW, responseLabel: CABAL_MANAGEMENT});
        m_TabButtonArray.push({label: IGNORED, view: FriendsViewsContainer.IGNORED_VIEW, responseLabel: IGNORE_PLAYER});

        m_ButtonBar.addEventListener("focusIn", this, "RemoveFocus");
        m_ButtonBar.tabChildren = false;
        m_ButtonBar.itemRenderer = "TabButtonLight";
        m_ButtonBar.direction = "horizontal";
        m_ButtonBar.spacing = -5;
        m_ButtonBar.autoSize = "left";
        m_ButtonBar.dataProvider = m_TabButtonArray;
        m_ButtonBar.selectedIndex = 0;
        m_ButtonBar.addEventListener("change", this, "SetSelectedContent");
        
        var buttonBarLine:MovieClip = createEmptyMovieClip("buttonBarLine", getNextHighestDepth());
        buttonBarLine.lineStyle(1, 0x656565, 100, true, "noScale");
        buttonBarLine.moveTo(0, 0);
        buttonBarLine.lineTo(_width, 0);
        buttonBarLine.endFill();
        buttonBarLine._y = Math.round(m_ButtonBar._y + 30);
        
        for (var i:Number = 0; i < m_ButtonBar.dataProvider.length; i++)
        {
            
        }        
        
        m_ViewsContainer.view = m_TabButtonArray[m_ButtonBar.selectedIndex].view;
        
        m_AddButton = attachMovie("ChromeButtonWhite", "m_AddButton", getNextHighestDepth());
        m_AddButton.label = ADD_FRIEND;
        m_AddButton._x = _width - m_AddButton._width;
        m_AddButton._y = _height - m_AddButton._height - 1;
        m_AddButton.addEventListener("click", this, "ViewResponseButtonClickEventHandler");
        
        m_PromptWindow = attachMovie("PromptWindow", "m_PromptWindow", getNextHighestDepth());
        m_PromptWindow.SignalPromptResponse.Connect(SlotPromptResponse, this);
    }
    
    //Remove Focus
    private function RemoveFocus(event:Object):Void
    {
        Selection.setFocus(null);
    }
    
    //Set Selected Content
    private function SetSelectedContent(event:Object):Void
    {
        if (m_PromptWindow)
        {
            m_PromptWindow.HidePrompt();
        }
        
        m_ViewsContainer.view = m_TabButtonArray[event.index].view;
        m_ViewsContainer.ToggleRightClickMenu(true);
        
        m_CabalManagementButton._visible = (m_TabButtonArray[event.index].view == FriendsViewsContainer.GUILD_VIEW) ? true : false;
        
        m_AddButton.label = m_TabButtonArray[event.index].responseLabel;
    }
    
    //View Response Button Click Event Handler
    private function ViewResponseButtonClickEventHandler():Void
    {
        m_ViewsContainer.ToggleRightClickMenu(false);
        RemoveFocus();

        if (m_ButtonBar.selectedIndex == 1)
        {
            DistributedValue.SetDValue("guild_window", true);
        }
        else
        {
            m_PromptWindow.ShowPrompt(m_TabButtonArray[m_ButtonBar.selectedIndex].view);            
        }
    }
    
    //Slot Prompt Response
    private function SlotPromptResponse():Void
    {
        m_ViewsContainer.ToggleRightClickMenu(true);
    }
}