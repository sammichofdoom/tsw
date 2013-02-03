//Imports
import com.Utils.LDBFormat;
import gfx.controls.Button;
import gfx.core.UIComponent;
import com.Utils.Signal;
import mx.utils.Delegate;

//Class
class GUI.TradePost.Views.ConfirmDeleteMailPromptWindow extends UIComponent
{
    //Constants
    private static var DELETE_MAIL_PROMPT_TITLE:String = LDBFormat.LDBGetText("MiscGUI", "deleteMailPromptTitle");
    private static var DELETE_MAIL_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("MiscGUI", "deleteMailPromptMessage");
    private static var DELETE_MAIL_NOATTACHMENTS_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("MiscGUI", "deleteMailNoAttachmentsPromptMessage");
    private static var OK_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Ok");
    private static var CANCEL_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
    
    //Properties
    public var SignalPromptResponse:Signal;
    
    private var m_Background:MovieClip;
    private var m_Title:TextField;
    private var m_Message:TextField;
    private var m_OKButton:Button;
    private var m_CancelButton:Button;
    private var m_KeyListener:TextField;
    
    //Constructor
    public function ConfirmDeleteMailPromptWindow()
    {
        super();
        
        SignalPromptResponse = new Signal;
        
        var keylistener:Object = new Object();
        keylistener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(keylistener);
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        _visible = false;
        m_KeyListener._visible = false;
        
        m_Title.text = DELETE_MAIL_PROMPT_TITLE;
        m_Message.htmlText = DELETE_MAIL_PROMPT_MESSAGE;
        m_Message.autoSize = "center";
        
        m_OKButton.label = OK_LABEL;
        m_OKButton.disableFocus = true;
        m_OKButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_CancelButton.label = CANCEL_LABEL;
        m_CancelButton.disableFocus = true;
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        _x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;        
    }
    
    //Show Prompt
    public function ShowPrompt(hasAttachments:Boolean):Void
    {
        if (hasAttachments)
        {
            m_Message.htmlText = DELETE_MAIL_PROMPT_MESSAGE;
        }
        else
        {
            m_Message.htmlText = DELETE_MAIL_NOATTACHMENTS_PROMPT_MESSAGE;
        }
        
        if (_visible)
        {
            return;
        }
        
        swapDepths(_parent.getNextHighestDepth());        
        
        _visible = true;
        Selection.setFocus(m_KeyListener);
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        if (event.target == m_OKButton)
        {
            SignalPromptResponse.Emit();
        }
        
        _visible = false;
        Selection.setFocus(null);
    }
    
    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        if (Selection.getFocus() == m_KeyListener)
        {
            switch(Key.getCode())
            {
                case Key.ESCAPE:    ResponseButtonEventHandler({target: m_CancelButton});
                                    break;

                case Key.ENTER:     ResponseButtonEventHandler({target: m_OKButton});  
                                    break;
            }
        }
    }
}