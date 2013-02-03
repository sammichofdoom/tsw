import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.TextInput;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import mx.transitions.easing.*;
import mx.utils.Delegate;


class GUI.LoginCharacterSelection.RenameCharacterDialog extends UIComponent
{
    private static var TEXT_INPUT_DEFAULT_STROKE_COLOR:Number = 0x666666;
    private static var TEXT_INPUT_HIGHLIGHT_STROKE_COLOR:Number = 0x0795C3;
    
	private var m_Background:MovieClip;
    private var m_ConfirmButton:Button;
    private var m_CancelButton:Button;
    private var m_NameInput:MovieClip;
    private var m_Text:TextField;
	private var m_KeyListener:Object;
    private var m_Description:String;
    private var m_CharInstance:Number = 0;
    public var SignalSelected:Signal;
    
    private var m_SidePadding:Number;
    
    public function RenameCharacterDialog()
    {
        super();
		
		m_KeyListener = new Object();

		m_KeyListener.onKeyUp = Delegate.create( this, function ()
        {
			switch( Key.getCode() )
			{
				case Key.ENTER:
                    SlotOkButton();
				    break;
				
			}
        } );
        
        SignalSelected = new Signal();
		
        m_SidePadding = 10;
    }

    private function onLoad()
    {
        super.onLoad();
        Key.addListener( m_KeyListener );
    }

    private function onUnload()
    {
        super.onUnload();
		Key.removeListener( m_KeyListener );
    }

    public function configUI()
    {
        super.configUI();

        var format:TextFormat = new TextFormat();
        format.align = "center";
        
        m_NameInput.maxChars = 14;

        m_NameInput.textField.setTextFormat( format );
        m_NameInput.m_HolderText.text = LDBFormat.LDBGetText("CharCreationGUI", "NameEditor_NickName").toUpperCase();
        m_NameInput.textField.onChanged = Delegate.create( this, OnNameChanged );
        m_NameInput.addEventListener("focusIn", this, "TextFieldFocusEventHandler");
        m_NameInput.addEventListener("focusOut", this, "TextFieldFocusEventHandler");

		m_Text.text = m_Description;
		
        m_ConfirmButton.label = LDBFormat.LDBGetText("GenericGUI", "Ok");
        m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
		
        m_ConfirmButton.addEventListener("click", this, "SlotOkButton");
        m_CancelButton.addEventListener("click", this, "SlotCancelButton");
        
        Layout();
    }

    private function OnNameChanged()
    {
        m_NameInput.textField.text = com.GameInterface.CharacterCreation.CharacterCreation.FilterCharacterName( m_NameInput.textField.text );
    }

    public function SetDescription( desc:String ) : Void
    {
        m_Description = desc;
        if ( initialized )
        {
            m_Text.text = m_Description;
        }
    }

    public function SetCharInstance( charInstance:Number )
    {
        m_CharInstance = charInstance;
    }
	
    private function SlotCancelButton()
    {
        SignalSelected.Emit( _global.Enums.StandardButtonID.e_ButtonIDCancel, "" );
    }
	
	private function SlotOkButton()
    {
        SignalSelected.Emit( m_CharInstance, m_NameInput.text );
    }
    
    function Layout()
    {
		var buttonSpace:Number = 5;
		
        this._x = Stage.width / 2 - this._width/2; 
        this._y = Stage.height / 2 - this._height / 2;
    }
    
    //Text Field Focus Event Handler
	private function TextFieldFocusEventHandler(event:Object):Void
	{
		Selection.setSelection(0, event.target.text.length);
        
        switch (event.type)
        {
            case "focusIn":     Colors.ApplyColor(event.target.m_Stroke, TEXT_INPUT_HIGHLIGHT_STROKE_COLOR);
                                event.target.m_HolderText._visible = false;
                                break;
                                    
            case "focusOut":    Colors.ApplyColor(event.target.m_Stroke, TEXT_INPUT_DEFAULT_STROKE_COLOR);
                                event.target.m_HolderText._visible = (event.target.textField.text == "") ? true : false;
        }
	}
}