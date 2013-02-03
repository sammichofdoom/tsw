//Imports
import com.Utils.LDBFormat;
import gfx.controls.Button;
import com.Utils.Signal;

//Class
class GUI.Claim.PromptWindow extends MovieClip
{
    //Constants
    public static var DELETE_ACTION:String = "deleteAction";
    public static var CLAIM_ACTION:String = "claimAction";
    public static var CLAIM_ALL_ACTION:String = "claimAllAction";
    
    public static var RESPONSE_OK:String = "responseOK";
    public static var RESPONSE_CANCEL:String = "responseCancel";
    
    private static var CLAIM_MESSAGE:String = LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_claimPrompt");
    private static var CLAIM_ALL_MESSAGE:String = LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_claimAllPrompt");
    private static var DELETE_MESSAGE:String = LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_deletePrompt");
    private static var OK:String = LDBFormat.LDBGetText("GenericGUI", "Ok");
    private static var CANCEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
    
    //Properties
    public var SignalPromptResponse:Signal;
    
    private var m_Text:TextField;
    private var m_OKButton:Button;
    private var m_CancelButton:Button;
    private var m_ItemID:Number; 
    
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
        
        m_OKButton.label = OK;
        m_CancelButton.label = CANCEL;
        
        m_OKButton.addEventListener("click", this, "ResponseButtonEventHandler");
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
    }
    
    //Show Prompt
    public function ShowPrompt(action:String, selectedID:Number):Void
    {
        m_ItemID = selectedID;
        swapDepths(_parent.getNextHighestDepth());
        _visible = true;
        
        switch (action)
        {
            case CLAIM_ACTION:      m_Text.text = CLAIM_MESSAGE;
                                    break;
                                    
            case CLAIM_ALL_ACTION:  m_Text.text = CLAIM_ALL_MESSAGE;
                                    break;
                                    
            case DELETE_ACTION:     m_Text.text = DELETE_MESSAGE;
        }
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_OKButton:        SignalPromptResponse.Emit(RESPONSE_OK, m_ItemID);
                                    break;
                                
            case m_CancelButton:    SignalPromptResponse.Emit(RESPONSE_CANCEL, m_ItemID);
        }
        
        Hide();
    }
    
    public function IsVisible():Boolean
    {
        return _visible;
    }
    
    public function Hide():Void
    {
        _visible = false;
    }
}
