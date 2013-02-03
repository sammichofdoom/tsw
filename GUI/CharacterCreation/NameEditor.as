import mx.utils.Delegate;

import gfx.core.UIComponent;
import mx.transitions.easing.*;

import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.CharacterCreation.CameraController;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.*;

dynamic class GUI.CharacterCreation.NameEditor extends UIComponent
{
    public var SignalBack:com.Utils.Signal;
    public var SignalForward:com.Utils.Signal;
    
    private var m_CameraController:CameraController;
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;

	private var m_Title:MovieClip;
	private var m_NamingBox:MovieClip;
	private var m_NamingGuideline:MovieClip;
	private var m_NamePreviewer:MovieClip;
	private var m_NamePreviewBar:MovieClip;
	private var m_BackButton:MovieClip;
	private var m_ForwardButton:MovieClip;
	private var m_NavigationBar:MovieClip;
	
	private var m_KeyListener:Object;
	
	private static var TEXT_INPUT_DEFAULT_STROKE_COLOR:Number = 0x666666;
    private static var TEXT_INPUT_HIGHLIGHT_STROKE_COLOR:Number = 0x4188A9;
	
	private static var MIN_CHAR_COUNT:Number = 3;
	private static var MAX_CHAR_COUNT:Number = 14;
	
    
    public function NameEditor()
    {
        SignalBack = new com.Utils.Signal;
        SignalForward = new com.Utils.Signal;
		
		m_NamePreviewBar._alpha = 0;
		
		m_NamingGuideline.m_Background.onPress = function() { };
    }

	private function configUI()
    {
        m_NamingBox.m_FirstNameInput.maxChars = MAX_CHAR_COUNT;
        m_NamingBox.m_FirstNameInput.textField.onChanged = Delegate.create( this, OnFirstNameChanged );
		
        m_NamingBox.m_LastNameInput.maxChars = MAX_CHAR_COUNT;
        m_NamingBox.m_LastNameInput.textField.onChanged = Delegate.create( this, OnLastNameChanged );

        m_NamingBox.m_NickNameInput.maxChars = MAX_CHAR_COUNT;
        m_NamingBox.m_NickNameInput.textField.onChanged = Delegate.create( this, OnNickNameChanged );
		
		m_NamingBox.m_FirstNameInput.addEventListener("focusIn", this, "TextFieldFocusEventHandler");
        m_NamingBox.m_FirstNameInput.addEventListener("focusOut", this, "TextFieldFocusEventHandler");
		m_NamingBox.m_LastNameInput.addEventListener("focusIn", this, "TextFieldFocusEventHandler");
        m_NamingBox.m_LastNameInput.addEventListener("focusOut", this, "TextFieldFocusEventHandler");
		m_NamingBox.m_NickNameInput.addEventListener("focusIn", this, "TextFieldFocusEventHandler");
        m_NamingBox.m_NickNameInput.addEventListener("focusOut", this, "TextFieldFocusEventHandler");
        
		m_BackButton.m_BackwardArrow._alpha = 100;
		m_ForwardButton.m_ForwardArrow._alpha = 100;
		m_BackButton.SignalButtonSelected.Connect(BackToCharacterEditor, this);
		m_ForwardButton.SignalButtonSelected.Connect(GoPlay, this);
		
		SetLabels();
		LayoutHandler();
		
		m_KeyListener = new Object();
    
		m_KeyListener.onKeyUp = Delegate.create( this, function ()
		{
			if ( Key.getCode() == Key.ENTER )
			{
				Selection.setFocus( null );
				GoPlay();
			}
			
			if ( Key.getCode() == Key.TAB )
			{
				if ( Selection.getFocus() == m_NamingBox.m_FirstNameInput.textField )
				{
					m_NamingBox.m_NickNameInput.focused = true;
					
					if (Key.isDown(Key.SHIFT))
					{
						m_NamingBox.m_LastNameInput.focused = true;
					}
					
				}
				else if ( Selection.getFocus() == m_NamingBox.m_NickNameInput.textField )
				{
					m_NamingBox.m_LastNameInput.focused = true;
					
					if (Key.isDown(Key.SHIFT))
					{
						m_NamingBox.m_FirstNameInput.focused = true;
					}
				}
				else if ( Selection.getFocus() == m_NamingBox.m_LastNameInput.textField )
				{
					m_NamingBox.m_FirstNameInput.focused = true;
					if (Key.isDown(Key.SHIFT))
					{
						m_NamingBox.m_NickNameInput.focused = true;
					}
				}
				
				
			}
		} );
		Key.addListener( m_KeyListener );
		
		Selection.setFocus( m_NamingBox.m_FirstNameInput );
		CheckInputFields();
    }
	
	private function CheckInputFields():Void
    {		
        if (m_NamingBox.m_FirstNameInput.textField.length < MIN_CHAR_COUNT || m_NamingBox.m_NickNameInput.textField.length < MIN_CHAR_COUNT || m_NamingBox.m_LastNameInput.textField.length < MIN_CHAR_COUNT)
        {
            m_ForwardButton.disabled = true;
            m_ForwardButton.m_ForwardArrow._alpha = 50;
        }
        else
        {
            m_ForwardButton.disabled = false;
            m_ForwardButton.m_ForwardArrow._alpha = 100;
        }
    }
	
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
	
    public function GetFirstName() : String
    {
        return m_NamingBox.m_FirstNameInput.textField.text;
    }

    public function GetLastName() : String
    {
        return m_NamingBox.m_LastNameInput.textField.text;
    }

    public function GetNickName() : String
    {
        return m_NamingBox.m_NickNameInput.textField.text;
    }
    
	private function SetLabels()
	{
		m_Title.text = LDBFormat.LDBGetText( "CharCreationGUI", "NameEditor_ScreenTitle" );
		m_BackButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "EditCharacter" );
		m_ForwardButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "StartGame" );
		
		m_NamingBox.m_Header.text = LDBFormat.LDBGetText( "CharCreationGUI", "NameEditor_NamingBoxTitle" );
		m_NamingBox.m_FirstNameInput.m_NameTypeLabel.text = LDBFormat.LDBGetText( "CharCreationGUI", "NameEditor_FirstName" );
		m_NamingBox.m_NickNameInput.m_NameTypeLabel.text = LDBFormat.LDBGetText( "CharCreationGUI", "NameEditor_NickName" );
		m_NamingBox.m_LastNameInput.m_NameTypeLabel.text = LDBFormat.LDBGetText( "CharCreationGUI", "NameEditor_LastName" );
		
		m_NamingGuideline.m_Header.text = LDBFormat.LDBGetText("CharCreationGUI", "NameCreationGuidelinesHeader");
		m_NamingGuideline.m_GuideText.text = LDBFormat.LDBGetText("CharCreationGUI", "NameCreationGuidelines");
		
		m_NamingBox.m_FirstNameInput.m_HolderText.text = LDBFormat.LDBGetText( "CharCreationGUI", "InputFieldDefaultText" );	
		m_NamingBox.m_NickNameInput.m_HolderText.text = LDBFormat.LDBGetText( "CharCreationGUI", "InputFieldDefaultText" );	
		m_NamingBox.m_LastNameInput.m_HolderText.text = LDBFormat.LDBGetText( "CharCreationGUI", "InputFieldDefaultText" );	
		
		TooltipUtils.AddTextTooltip( m_NamingBox.m_FirstNameInput.m_TutorialIcon, LDBFormat.LDBGetText( "CharCreationGUI", "NamingConvention_FirstLast" ), 250, TooltipInterface.e_OrientationHorizontal,  true); 
		TooltipUtils.AddTextTooltip( m_NamingBox.m_LastNameInput.m_TutorialIcon, LDBFormat.LDBGetText( "CharCreationGUI", "NamingConvention_FirstLast" ), 250, TooltipInterface.e_OrientationHorizontal,  true); 
		TooltipUtils.AddTextTooltip( m_NamingBox.m_NickNameInput.m_TutorialIcon, LDBFormat.LDBGetText( "CharCreationGUI", "NamingConvention_Nick" ), 250, TooltipInterface.e_OrientationHorizontal,  true); 
	}
	
	public function LayoutHandler()
	{
		w = Stage.width;
		h = Stage.height;
		
		m_Title._x = (w / 2) - (m_Title._width / 2);
		m_Title._y = 20;
		
		m_NavigationBar._x  = 0;
		m_NavigationBar._y = h - m_NavigationBar._height;
		m_NavigationBar._width = w;
		m_BackButton._x = 10;
		m_BackButton._y = h - (m_NavigationBar._height / 2) - (m_BackButton._height/2) + 5;
		m_ForwardButton._y = m_BackButton._y;
		m_ForwardButton._x = w - m_ForwardButton._width - 10;
		
		m_NamingBox._x = Stage.width/2 + Stage.width/4  - m_NamingBox._width/2 + 20;
		m_NamingBox._y = (h / 2) - (m_NamingBox._height / 2);
		
		m_NamePreviewer._x = m_Title._x;
		m_NamePreviewer._y = m_Title._y + m_Title._height + 5;
		
		m_NamePreviewBar._x = (w / 2) - (m_NamePreviewBar._width / 2);
		m_NamePreviewBar._y = m_NamePreviewer._y;
		
		m_NamingGuideline.m_GuideText.height = m_NamingGuideline.m_GuideText.textField.textHeight + 10;
		m_NamingGuideline.m_Background._height = m_NamingGuideline.m_GuideText.height + 50;
		m_NamingGuideline._x = Stage.width / 2 - m_NamingGuideline._width/2 - Stage.width / 4 - 20;
		m_NamingGuideline._y = (h / 2) - (m_NamingGuideline._height / 2);
		
	}
	
	private function BackToCharacterEditor()
	{
		this.SignalBack.Emit();
	}
	
	private function GoPlay()
	{
		if (m_NamingBox.m_FirstNameInput.textField.length >= MIN_CHAR_COUNT && m_NamingBox.m_NickNameInput.textField.length >= MIN_CHAR_COUNT && m_NamingBox.m_LastNameInput.textField.length && MIN_CHAR_COUNT)
		{
			this.SignalForward.Emit();
		}
		else
		{
			Selection.setFocus( m_NamingBox.m_FirstNameInput )
		}
	}
	
	private function onUnload()
	{
		Key.removeListener( m_KeyListener );
	}
	
    private function OnFirstNameChanged()
    {
        m_NamingBox.m_FirstNameInput.textField.text = com.GameInterface.CharacterCreation.CharacterCreation.FilterCharacterName( m_NamingBox.m_FirstNameInput.textField.text );
		UpdateNamePreview();
		CheckInputFields();
    }

    private function OnLastNameChanged()
    {
        m_NamingBox.m_LastNameInput.textField.text = com.GameInterface.CharacterCreation.CharacterCreation.FilterCharacterName( m_NamingBox.m_LastNameInput.textField.text );
		UpdateNamePreview();
		CheckInputFields();
    }

    private function OnNickNameChanged()
    {
        m_NamingBox.m_NickNameInput.textField.text = com.GameInterface.CharacterCreation.CharacterCreation.FilterCharacterName( m_NamingBox.m_NickNameInput.textField.text );
		UpdateNamePreview();
		CheckInputFields();
    }
    
	private function UpdateNamePreview()
	{
		if ( m_NamingBox.m_FirstNameInput.textField.text != "" || m_NamingBox.m_NickNameInput.textField.text != "" ||  m_NamingBox.m_LastNameInput.textField.text != "" )
		{
			m_NamePreviewBar.tweenTo(1, { _alpha:100 }, Strong.easeOut);
		}
		else m_NamePreviewBar.tweenTo(1, { _alpha:0 }, Strong.easeOut);
		
		
		if (m_NamingBox.m_NickNameInput.textField.text == "")
		{
			m_NamePreviewer.text = m_NamingBox.m_FirstNameInput.textField.text + ' ' + m_NamingBox.m_LastNameInput.textField.text;
		}
		else m_NamePreviewer.text = m_NamingBox.m_FirstNameInput.textField.text + ' ' + '"' + m_NamingBox.m_NickNameInput.textField.text + '"' + ' ' + m_NamingBox.m_LastNameInput.textField.text;
	}
}
