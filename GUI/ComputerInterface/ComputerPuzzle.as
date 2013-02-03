//Imports
import com.Utils.LDBFormat;
import mx.transitions.easing.*;
import gfx.motion.Tween;
import gfx.controls.Button;
import com.GameInterface.Log;
import com.GameInterface.ComputerPuzzleIF;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.Game.Character;
import com.GameInterface.ProjectUtils;
import mx.utils.Delegate;

//Constants
var TEXT_AREA_LINE_HEIGHT:Number = 14.8;
var TEXT_AREA_WIDTH:Number = 436;
var LIGHT_GREEN:Number = 0x00FF00;
var DARK_GREEN:Number = 0x336600;
var TOP_ARROW:String = "topArrow";
var BOTTOM_ARROW:String = "bottomArrow";
var INPUT_FIELD_HOLDER_TEXT:String = "> " + LDBFormat.LDBGetText("GenericGUI", "ComputerPuzzle_InputFieldHolderText");
var WINDOW_TITLE:String = LDBFormat.LDBGetText("GenericGUI", "ComputerPuzzle_AccessingData");

//Properties
var g_FocusListener:Object = new Object();
var m_UserInputField:TextField;
var layout:String;
var m_Character:Character;
var m_TextArea:MovieClip;

//On Load
function onLoad()
{
	m_CloseButton.disableFocus = true;
	
	Log.Info2("ComputerPuzzle", "onLoad()");
    
	m_Title.htmlText = WINDOW_TITLE;
    
    m_TextArea.textField.textColor = 0x22dd22;
	m_TextArea.textField.htmlText = "";    
    m_TextArea.textField.autoSize = "left";  
    
    m_Character = Character.GetClientCharacter();
    if (m_Character != undefined) { m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_activated.xml" ); }
	
	ComputerPuzzleIF.SignalTextUpdated.Connect(SlotTextUpdated, this);
	ComputerPuzzleIF.SignalQuestionsUpdated.Connect(SlotQuestionsUpdated, this);   
	ComputerPuzzleIF.SignalClose.Connect(CloseComputerPuzzle, this);
    
    ProjectUtils.SetMovieClipMask(m_TextArea, null, m_TextArea.m_Background._height, m_TextArea.m_Background._width, false);
    
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
	
	moduleIF.SignalStatusChanged.Connect( SlotModuleStatusChanged, this );
	SlotModuleStatusChanged( moduleIF, moduleIF.IsActive() );
	
	SlotTextUpdated();
	SlotQuestionsUpdated();
    
	Key.addListener(this);
	
	m_CloseButton.addEventListener("click", this, "CloseComputerPuzzle");
    m_TextArea.m_TopArrow.addEventListener( "click", this, "SlotButtonSelected" );
    m_TextArea.m_BottomArrow.addEventListener( "click", this, "SlotButtonSelected" );
	
	m_Dragpoint.onPress = function()
	{
		_parent.startDrag();
	}
	m_Dragpoint.onRelease = function()
	{
		_parent.stopDrag();
	}
	m_Dragpoint.onReleaseOutside = function()
	{
		_parent.stopDrag();
	}
	
	_parent._x = Stage["visibleRect"].x+ ((Stage["visibleRect"].width - _parent._width)/2);
	_parent._y = Stage["visibleRect"].y +((Stage["visibleRect"].height - _parent._height) / 2);
	
	Selection.setFocus(m_UserInputField.textField);
	
	g_FocusListener.onSetFocus = function(oldFocus, newFocus)
	{
		if ( newFocus == m_UserInputField.textField )
		{
            ProjectUtils.SetMovieClipMask(missionWindow, m_Window.m_Content, m_ContentSize.height);
			InputFieldFocusIn();
		}
		
        if ( newFocus == m_TextArea.textField )
        {
            InputFieldFocusOut();
        }
	}
	
	//SetLayout can be set to "Illuminati", "Templars" or "Dragon". I.e SetLayout("Illuminati");
	SetLayout();
    
	Selection.addListener( g_FocusListener );
}

//Slot Button Selected
function SlotButtonSelected(object:MovieClip):Void
{
    switch (object.target)
    {
        case m_TextArea.m_TopArrow:     m_TextArea.textField._y += m_TextArea.m_Background._height;
                            break;
                            
        case m_TextArea.m_BottomArrow:  m_TextArea.textField._y -= m_TextArea.m_Background._height;
    }
    
    CheckTextArea();
}

//Check Text Area
function CheckTextArea():Void
{
    if (m_TextArea.textField._height > m_TextArea.m_Background._height)
    {
        m_TextArea.textField._width = TEXT_AREA_WIDTH - m_TextArea.m_TopArrow._width;   
        m_TextArea.m_TopArrow._visible = m_TextArea.m_BottomArrow._visible = true;
        
        if (m_TextArea.textField._y == m_TextArea.m_Background._y)
        {
            m_TextArea.m_TopArrow.disabled = true;
            m_TextArea.m_BottomArrow.disabled = false;
        }
        else if (m_TextArea.textField._y + m_TextArea.textField._height <= m_TextArea.m_Background._y + m_TextArea.m_Background._height)
        {
            m_TextArea.m_TopArrow.disabled = false;
            m_TextArea.m_BottomArrow.disabled = true;
        }
        else
        {
            m_TextArea.m_TopArrow.disabled = false;
            m_TextArea.m_BottomArrow.disabled = false;
        }
    }
    else
    {
        m_TextArea.textField._y = 0;
        m_TextArea.textField._width = TEXT_AREA_WIDTH;
        m_TextArea.m_TopArrow._visible = m_TextArea.m_BottomArrow._visible = false;
    }
    
    m_TextArea.textField.selectable = true;
}

//Input Field Focus In
function InputFieldFocusIn()
{
	if (m_UserInputField.text == INPUT_FIELD_HOLDER_TEXT )
	{
		m_UserInputField.text = "";
	}
}

//Input Field Focus Out
function InputFieldFocusOut()
{
	if (m_UserInputField.text == "" )
	{
		m_UserInputField.text = INPUT_FIELD_HOLDER_TEXT;
	}
}

//Set Layout
function SetLayout( layout:String ) : Void
{
	switch ( layout )
	{
		case "Illuminati":
			m_UserInputField.textField.textColor = 0x9FE2FF;
			var m_layoutBackground = m_LayoutLoader.attachMovie("BackgroundIlluminati", "m_illuminatiBg", this.getNextHighestDepth() );
			m_layoutBackground.m_Logo._alpha = 30;
			break;
				
		case "Templars":
			m_UserInputField.textField.textColor = 0xFAE5E4;
			var m_layoutBackground = m_LayoutLoader.attachMovie("BackgroundTemplars", "m_templarsBg", this.getNextHighestDepth() );
			m_layoutBackground.m_Logo._alpha = 50;
			break;
			
		case "Dragon":
			m_UserInputField.textField.textColor = 0x9DC785;
			var m_layoutBackground = m_LayoutLoader.attachMovie("BackgroundDragon", "m_dragonBg", this.getNextHighestDepth() );
			m_layoutBackground.m_Logo._alpha = 30;
			break;
            
		default:
			m_UserInputField.textField.textColor = 0x22dd22;
			break;
	}
}

//On Key Down
function onKeyDown()
{        
    var scanCode:Number = Key.getCode();   

    if (scanCode == 13) // 13 = ENTER 
    {
        Log.Info2("ComputerPuzzle", "Player input '" + m_UserInputField.text + "' accepted and sent to server.");   
        
        var success:Boolean = ComputerPuzzleIF.AcceptPlayerInput(m_UserInputField.text);
        
        if (m_Character != undefined)
        {
            if (success)
            {
                m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_entry_success.xml" );
            }
            else
            {
                m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_entry_fail.xml" );
            }
        }
        
        Selection.setFocus(m_UserInputField.textField);
        m_UserInputField.text = "";
    }
}

//On Key Up
function onKeyUp():Void
{    
    if (Selection.getFocus() == m_TextArea.textField)
    {
        SlotTextUpdated();
        SlotQuestionsUpdated();
    }
}

//Slot Module Status Changed
function SlotModuleStatusChanged( module:GUIModuleIF, isActive:Boolean )
{
    _visible = isActive;
}

//Slot Text Updated
function SlotTextUpdated() : Void
{
    m_TextArea.textField.htmlText = ComputerPuzzleIF.GetText();
    m_TextArea.textField.textColor = 0x22dd22;
    
    CheckTextArea();
}

//Slot Questions Updated
function SlotQuestionsUpdated() : Void
{    
	var questions:Array = ComputerPuzzleIF.GetQuestions();
    
    for (i:Number = 0; i < questions.length; ++i)
    {
        Log.Info1("ComputerPuzzle", "Command " + i + ": '" + questions[i] + "'");
    }
    
    CheckTextArea();
}

//On Unload
function onUnload()
{
    Log.Info2("ComputerPuzzle", "onUnload()");    
    Key.removeListener(this);    
}

//Resize Handler
function ResizeHandler() : Void
{
    var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];

    _y = visibleRect.y;
    _x = visibleRect.x;
    m_HalfWidth = visibleRect.width / 2;
}

//Close Computer Puzzle
function CloseComputerPuzzle() : Void
{
	_parent.UnloadClip();
	ComputerPuzzleIF.Close();
}