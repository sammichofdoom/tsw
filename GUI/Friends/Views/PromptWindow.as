//Imports
import com.GameInterface.Friends;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.Friends.FriendsContent;
import GUI.Friends.FriendsViewsContainer;
import gfx.controls.Button;
import gfx.controls.TextInput;

//Class
class GUI.Friends.Views.PromptWindow extends MovieClip
{
    //Constants
    public static var RESPONSE_OK:String = "responseOK";
    public static var RESPONSE_CANCEL:String = "responseCancel";
    
    private static var PLAYERS_NAME:String = LDBFormat.LDBGetText("FriendsGUI", "playersNamePromptLabel");
    private static var NAME:String = LDBFormat.LDBGetText("FriendsGUI", "namePromptWindow");
    private static var OK:String = LDBFormat.LDBGetText("GenericGUI", "Ok");
    private static var CANCEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");

    //Properties
    public var SignalPromptResponse:Signal;
    
    private var m_TargetView:MovieClip;
    private var m_Title:TextField;
    private var m_InputTextLabel:TextField;
    private var m_InputText:TextInput;
    private var m_OKButton:Button;
    private var m_CancelButton:Button;
    
    //Constructor
    public function PromptWindow()
    {
        super();
        
        _visible = false;
        
        SignalPromptResponse = new Signal;
    }
    
    //On Load
    private function onLoad():Void
    {
        _x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;
        
        m_InputTextLabel.text = PLAYERS_NAME;
        
        m_OKButton.label = OK;
        m_CancelButton.label = CANCEL;
        
        Key.addListener(this);
        
        m_InputText.addEventListener("textChange", this, "InputTextChangedEventHandler");
        m_OKButton.addEventListener("click", this, "ResponseButtonEventHandler");
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
    }
    
    //Remove Focus
    private function RemoveFocus():Void
    {        
        Selection.setFocus(null);
    }
   
    //Show Prompt
    public function ShowPrompt(targetView:MovieClip):Void
    {
        switch (targetView)
        {
            case FriendsViewsContainer.FRIENDS_VIEW:    m_Title.text = FriendsContent.ADD_FRIEND;
                                                        break;
                                                        
            case FriendsViewsContainer.GUILD_VIEW:      m_Title.text = FriendsContent.INVITE_TO_CABAL;
                                                        break;
                                                        
            case FriendsViewsContainer.IGNORED_VIEW:    m_Title.text = FriendsContent.IGNORE_PLAYER;
        }

        m_InputText.text = "";
        
        m_OKButton.disabled = true;
                
        swapDepths(_parent.getNextHighestDepth());
        _visible = true;
        
        m_TargetView = targetView;
        
        Selection.setFocus(m_InputText);
    }
    
    //Hide Prompt
    public function HidePrompt():Void
    {
        _visible = false;
    }

    //On Key Up
	private function onKeyUp():Void
	{
		if (Key.getCode() == Key.ENTER)
		{
			if (!m_OKButton.disabled)
			{
				ResponseButtonEventHandler({target: m_OKButton});
			}
		}
		else if (Key.getCode() == Key.ESCAPE)
		{
			ResponseButtonEventHandler();
		}
	}
    
    //Input Text Changed Event handler
    private function InputTextChangedEventHandler(event:Object):Void
    {
        m_OKButton.disabled = (m_InputText.text == "") ? true : false;
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        if (event.target == m_OKButton)
        {
            switch (m_TargetView)
            {
            case FriendsViewsContainer.FRIENDS_VIEW:    Friends.AddFriend(m_InputText.text);
                                                        break;
                                                        
            case FriendsViewsContainer.GUILD_VIEW:      Friends.InviteToGuildByName(m_InputText.text);
                                                        break;
                                                        
            case FriendsViewsContainer.IGNORED_VIEW:    Friends.Ignore(m_InputText.text);
            }
        }
        
        SignalPromptResponse.Emit();
        RemoveFocus();
        HidePrompt();
    }
}