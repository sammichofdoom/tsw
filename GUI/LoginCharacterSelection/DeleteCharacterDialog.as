//Imports
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.TextInput;
import mx.transitions.easing.*;
import mx.utils.Delegate;

//Class
class GUI.LoginCharacterSelection.DeleteCharacterDialog extends UIComponent
{
    //Properties
    public var SignalCancelDeleteCharacter:Signal;
    public var SignalConfirmDeleteCharacter:Signal;
    
	private var m_Background:MovieClip;
    private var m_CancelButton:Button;
    private var m_ConfirmButton:Button;
    private var m_PasswordInput:MovieClip;
    private var m_Text:TextField;
	private var m_KeyListener:Object;
    private var m_SidePadding:Number;
    
    //Constructor
    public function DeleteCharacterDialog()
    {
        super();
        
        SignalCancelDeleteCharacter = new Signal();
        SignalConfirmDeleteCharacter = new Signal();
		
        m_SidePadding = 10;
    }
    
    //On Load
    private function onLoad():Void
    {
        m_KeyListener = new Object();
		m_KeyListener.onKeyUp = Delegate.create( this, KeyUpEventHandler);
        Key.addListener(m_KeyListener);
        
        super.onLoad();
    }

    //On Unload
    private function onUnload()
    {
        Key.removeListener( m_KeyListener );
        super.onUnload();
    }
    
    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        if (Key.getCode() == Key.ENTER)
        {
            SlotConfirmDelete();
        }
    }
    
    //Config UI
    public function configUI():Void
    {
        super.configUI();
		
		m_Text.text = LDBFormat.LDBGetText("Launcher", "Launcher_CharacterSelectView_EnterYourPassword");
		
        m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
        m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "Delete");
		
        var textFormat:TextFormat = m_PasswordInput.textField.getTextFormat();
        textFormat.align = "center";
        m_PasswordInput.textField.setTextFormat(textFormat);
        
        m_CancelButton.addEventListener("click", this, "SlotCancelDelete");
        m_ConfirmButton.addEventListener("click", this, "SlotConfirmDelete");
		Selection.setFocus( m_PasswordInput );
		
        LayoutHandler();
    }
    
    //Slot Cancel Delete
    private function SlotCancelDelete():Void
    {
        SignalCancelDeleteCharacter.Emit();
    }
	
    //Slot Confirm Delete
	private function SlotConfirmDelete():Void
    {
        SignalConfirmDeleteCharacter.Emit( m_PasswordInput.text );
    }
    
    //Layout Handler
    public function LayoutHandler():Void
    {
        this._x = Stage["visibleRect"].x + Stage.width / 2 - this._width/2; 
        this._y = Stage["visibleRect"].y + Stage.height / 2 - this._height/2; 
    }
}
