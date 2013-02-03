//Imports
import gfx.core.UIComponent;
import gfx.controls.Button;
import com.Utils.LDBFormat;
import com.Utils.Signal;

//Class
class GUI.LoginCharacterSelection.FacebookDialog extends UIComponent
{
    //Constants  
    private static var FACEBOOK_DIALOG_TITLE:String = LDBFormat.LDBGetText("CharCreationGUI", "FacebookDialog_Title");
    private static var FACEBOOK_DIALOG_MESSAGE:String = LDBFormat.LDBGetText("CharCreationGUI", "FacebookDialog_Message");
    private static var LOGIN_WITH_FACEBOOK_BUTTON_LABEL:String = LDBFormat.LDBGetText("CharCreationGUI", "FacebookDialog_LoginWithFacebookButtonLabel");
    private static var CANCEL_BUTTON_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
    
    //Properties
    public var SignalLoginSelected:Signal;
    
    private var m_TitleTextField:TextField;
    private var m_MessageTextField:TextField;
    private var m_LoginWithFacebookButton:Button;
    private var m_CancelButton:Button;
    
    //Constructor
    public function FacebookDialog()
    {
        super();
        
        SignalLoginSelected = new Signal();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_TitleTextField.text = FACEBOOK_DIALOG_TITLE;
        m_MessageTextField.text = FACEBOOK_DIALOG_MESSAGE;
        
        m_LoginWithFacebookButton.label = LOGIN_WITH_FACEBOOK_BUTTON_LABEL;
        m_CancelButton.label = CANCEL_BUTTON_LABEL;
        
        m_LoginWithFacebookButton.addEventListener("click", this, "ClickEventHandler");
        m_CancelButton.addEventListener("click", this, "ClickEventHandler");
    }
    
    //Click Event Handler
    private function ClickEventHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_LoginWithFacebookButton:     SignalLoginSelected.Emit(true);
                                                break;
                                                
            case m_CancelButton:                SignalLoginSelected.Emit(false);
        }
    }
}