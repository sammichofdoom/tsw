//Imports
import com.GameInterface.Friends;
import com.Utils.LDBFormat;
import gfx.controls.Button;
import gfx.controls.TextArea;
import mx.utils.Delegate;

//Class
class GUI.Friends.Views.MessageWindow extends MovieClip
{
    //Constants
    public static var RESPONSE_OK:String = "responseOK";
    public static var RESPONSE_CANCEL:String = "responseCancel";
    
    private static var MESSAGE_TO:String = LDBFormat.LDBGetText("FriendsGUI", "messageToTitleMessageWindow");
    private static var SEND:String = LDBFormat.LDBGetText("FriendsGUI", "sendButtonMessageWindow");
    private static var CANCEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
     
    //Properties
    private var m_Recipient:String;
    private var m_Title:TextField;
    private var m_InputText:TextArea;
    private var m_OKButton:Button;
    private var m_CancelButton:Button;
    
    //Constructor
    public function MessageWindow()
    {
        super();
        
        _visible = false;
    }
    
    //On Load
    private function onLoad():Void
    {
        _x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;
        
        m_OKButton.label = SEND;
        m_CancelButton.label = CANCEL;
        
        m_OKButton.disabled = true;
        
        m_OKButton.addEventListener("click", this, "ResponseButtonEventHandler");
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        m_InputText.addEventListener("textChange", this, "TextChangeEventHandler");
    }
    
    
    //Show Message Window
    public function ShowMessageWindow(recipient:String):Void
    {
        m_Recipient = recipient;
        
        m_Title.text = MESSAGE_TO + "  " + recipient;
        m_InputText.text = "";
        
        swapDepths(_parent.getNextHighestDepth());
        _visible = true;
    }
    
    //Hide Message Window
    public function HideMessageWindow():Void
    {
        _visible = false;
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        if (event.target == m_OKButton)
        {
            Friends.Tell(m_Recipient, m_InputText.text);
        }
        m_OKButton.disabled = true;
        HideMessageWindow();
    }

    //Text Change Event Handler
    private function TextChangeEventHandler()
    {
        m_OKButton.disabled = (m_InputText.text == "");
    }
}