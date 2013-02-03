import mx.transitions.easing.*;
import gfx.controls.Button;
import com.GameInterface.Log;
import com.GameInterface.Puzzle;
import com.GameInterface.Game.Character;
import com.GameInterface.GUIModuleIF;

var m_Skin:MovieClip;
var m_NumDisplay:TextField;
var m_KeyListener:Object;
var m_KeySounds:Object;

function onLoad()
{
    Log.Info2("Keypad", "onLoad()")    
}

function LoadArgumentsReceived(args:Array):Void
{
    // Logs
    Log.Info1("Keypad", "skin='" + args[0] + "'");      
    Log.Info1("Keypad", "maxInputLength='" + args[1] + "'"); 
    Log.Info1("Keypad", "LoadArgumentsReceived()");  
    
    // Skin
    var skinsArray:Array = new Array()
    skinsArray.push(this.metal, this.staffofmoses, this.egyptian);
    
    for (var i:Number = 0; i < skinsArray.length; i++)
    {
        if (skinsArray[i] != this[args[0]])
        {
            skinsArray[i]._visible = false;
        }
    }
    
    m_Skin = this[args[0]];
    m_Skin._x = 400;
    m_Skin._y = 100;
    m_Skin.tabEnabled = true;
    
    // Drag
    m_Skin.m_Background.onPress = function()
    {
        m_Skin.startDrag();
    }

    m_Skin.m_Background.onMouseUp = function()
    {
        m_Skin.stopDrag();
    } 
	
	
    // Buttons
	{
		for (var i:Number = 0; i <= 9; ++i)
		{
			var keypadButton:MovieClip = KeypadNumberToKeypadButton(i);
		
			keypadButton.m_KeypadNumber = i;
			keypadButton.onPress = onKeypadButtonPress;        
			keypadButton.onRelease = onKeypadButtonRelease;
		}
	}
	
	// Enter
    var keypadButton:MovieClip = m_Skin["m_numpad13"];  
    keypadButton.onPress = onEnterButtonPress;    
    keypadButton.onRelease = onEnterButtonRelease;
    
	// Backspace
    var keypadButton:MovieClip = m_Skin["m_numpad8"];  
    keypadButton.onPress = onBackspaceButtonPress;    
    keypadButton.onRelease = onBackspaceButtonRelease;
    
    // Sounds
    m_KeySounds = new Object;
    
	if ( m_Skin == egyptian )
	{
		for (var i:Number = 0; i <= 6; ++i)
		{
			m_KeySounds[1] = "sound_fxpackage_GUI_keyboard_interface_note_1.xml";
			m_KeySounds[2] = "sound_fxpackage_GUI_keyboard_interface_note_2.xml";
			m_KeySounds[4] = "sound_fxpackage_GUI_keyboard_interface_note_4.xml";
			m_KeySounds[3] = "sound_fxpackage_GUI_keyboard_interface_note_3.xml";
			m_KeySounds[5] = "sound_fxpackage_GUI_keyboard_interface_note_5.xml";
			m_KeySounds[6] = "sound_fxpackage_GUI_keyboard_interface_note_6.xml";
			m_KeySounds[7] = "sound_fxpackage_GUI_keyboard_interface_note_7.xml";
		}
	}
	else
	{
		m_KeySounds[0] = "sound_fxpackage_GUI_keyboard_interface_note_0.xml";
		m_KeySounds[1] = "sound_fxpackage_GUI_keyboard_interface_note_1.xml";
		m_KeySounds[2] = "sound_fxpackage_GUI_keyboard_interface_note_2.xml";
		m_KeySounds[4] = "sound_fxpackage_GUI_keyboard_interface_note_4.xml";
		m_KeySounds[3] = "sound_fxpackage_GUI_keyboard_interface_note_3.xml";
		m_KeySounds[5] = "sound_fxpackage_GUI_keyboard_interface_note_5.xml";
		m_KeySounds[6] = "sound_fxpackage_GUI_keyboard_interface_note_6.xml";
		m_KeySounds[7] = "sound_fxpackage_GUI_keyboard_interface_note_7.xml";
		m_KeySounds[8] = "sound_fxpackage_GUI_keyboard_interface_note_8.xml";
		m_KeySounds[9] = "sound_fxpackage_GUI_keyboard_interface_note_9.xml";
	}
    // Signals
    Puzzle.SignalMessage.Connect(onPuzzleMessageFromServer, this);
    
    var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF("GenericHideModule");
    moduleIF.SignalStatusChanged.Connect(SlotModuleStatusChanged, this);
    SlotModuleStatusChanged(moduleIF, moduleIF.IsActive());
    
    // Window
    m_Skin.i_CloseButton.addEventListener("click", this, "CloseButtonHandler");
    
    m_NumDisplay = m_Skin.m_display.m_displayInput;
    m_NumDisplay.maxChars = args[1];
    m_NumDisplay.text = "";

    Selection.setFocus(m_NumDisplay);
    
    // Keyboard
    m_KeyListener = new Object();
	m_KeyListener.onKeyDown = onKeyboardKeyPressed;
    
	Key.addListener(m_KeyListener);
}

function onMouseDown():Void
{
    if (m_Skin.hitTest(_root._xmouse, _root._ymouse))
    {
        Selection.setFocus(m_NumDisplay);
    }
    else
    {
        Selection.setFocus(null);
    }
}

function SlotModuleStatusChanged(module:GUIModuleIF, isActive:Boolean)
{
    _visible = isActive;
}

function onUnload()
{
    Log.Info2("Keypad", "onUnload()");    
	Key.removeListener(m_KeyListener);    
}

function onPuzzleMessageFromServer(msg:String)
{
    Log.Info2("Keypad", "onPuzzleMessageFromServer('" + msg + "')");       
    
    if (msg == 'fail')
    {
        // TODO: Do puzzle fail animation
    }
}

function onNumericButtonRelease(keypadNumber:Number)
{
    if (keypadNumber >= 0 && keypadNumber <= 9)
    {
        Log.Info1("Keypad", "Clicked '" + keypadNumber + "'.");   
        
        if (m_NumDisplay.text.length < m_NumDisplay.maxChars)
        {
            m_NumDisplay.text += ("" + keypadNumber);
        }
    }
    
    KeypadNumberToKeypadButton(keypadNumber).gotoAndPlay("up");    
}

function CloseButtonHandler(event:Object)
{
    CloseKeypad();
}

function onBackspaceButtonPress():Void
{
    m_Skin["m_numpad8"].gotoAndPlay("down");
}

function onBackspaceButtonRelease():Void
{
	if (m_NumDisplay.text.length > 0)
	{
		m_NumDisplay.text = m_NumDisplay.text.substr(0, m_NumDisplay.text.length-1);
	}
    m_Skin["m_numpad8"].gotoAndPlay("up");
}

function onEnterButtonPress():Void
{
    m_Skin["m_numpad13"].gotoAndPlay("down");
}

function onEnterButtonRelease():Void
{
    Log.Info1("Keypad", "Clicked 'enter'.");      
    
    if (m_NumDisplay.text != "")
    {
        Log.Info2("Keypad", "Sending keypad puzzle message '" + m_NumDisplay.text + "' from client to server.");  
        Puzzle.SendMessageToServer(m_NumDisplay.text);
        m_NumDisplay.text = "";
    }
    
    m_Skin["m_numpad13"].gotoAndPlay("up");    
}

function onKeypadButtonRelease():Void
{
    var keypadNumber:Number = this.m_KeypadNumber;

    Log.Info1("Keypad", "onKeypadButtonRelease(" + keypadNumber + ")");      
    onNumericButtonRelease(keypadNumber);
}

function onKeypadButtonPress():Void
{
    var keypadNumber:Number = this.m_KeypadNumber;

    PlayKeySound(keypadNumber);
    
    KeypadNumberToKeypadButton(keypadNumber).gotoAndPlay("down");
}

/// invoked by the parent (GUIFramework, handles resizing of all GUI elements
function ResizeHandler():Void
{
	var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
	_y = visibleRect.y;
	_x = visibleRect.x;
    m_HalfWidth = visibleRect.width / 2;
}

function PlayKeySound(keypadNumber:Number)
{
    if (m_KeySounds.hasOwnProperty(String(keypadNumber)))
    {
        var character:Character = Character.GetClientCharacter();
        character.AddEffectPackage(m_KeySounds[keypadNumber]);
    }
}

function ScanCodeToKeypadNumber(scanCode:Number):Number
{
    if (scanCode >= 96 && scanCode <= 105)
    {
        // Convert numpad code to keypad number.
        return scanCode - 96;
    }
    
    if (scanCode >= 48 && scanCode <= 57)
    {
        // Convert number key code to keypad number.
        return scanCode - 48;
    }
    
    // The key is not a keypad number, return an invalid number.
    return -1;
}

function KeypadNumberToKeypadButton(keypadNumber:Number):MovieClip
{
    var keypadButton:MovieClip = m_Skin["m_numpad" + (keypadNumber + 48)];

    return keypadButton;
}

function ScanCodeToKeypadButton(scanCode:Number):MovieClip
{
    if (scanCode == 8)
    {
        return m_Skin["m_numpad8"];
    }
    if (scanCode == 13)
    {
        return m_Skin["m_numpad13"];
    }
    else
    {
        return KeypadNumberToKeypadButton(ScanCodeToKeypadNumber(scanCode)); 
    }
}

function onKeyboardKeyPressed():Void
{
    m_KeyListener.onKeyDown = null;
    m_KeyListener.onKeyUp = onKeyboardKeyReleased;
    
    var scanCode:Number = Key.getCode();

    Log.Info1("Keypad", "onKeyboardKeyPressed(scanCode=" + scanCode + ")")      ;

    PlayKeySound(ScanCodeToKeypadNumber(scanCode));
    
    if (scanCode == 13 || scanCode == 8 || (scanCode >= 96 && scanCode <= 105))
    {
        ScanCodeToKeypadButton(scanCode).gotoAndPlay("down");
    }
}

function onKeyboardKeyReleased():Void
{
    m_KeyListener.onKeyUp = null;
    m_KeyListener.onKeyDown = onKeyboardKeyPressed;
    
	var scanCode:Number = Key.getCode();
 
    if (scanCode == 13)
    {
        onEnterButtonRelease();
    }
    else if (scanCode == 8)
    {
        onBackspaceButtonRelease();
    }
    else if (scanCode >= 96 && scanCode <= 105)
    {        
        var keypadNumber:Number = ScanCodeToKeypadNumber(scanCode);
        onNumericButtonRelease(keypadNumber)  
    }
    
    Log.Info1("Keypad", "onKeyboardKeyReleased(scanCode=" + scanCode + ")")   
    
    if (scanCode == 13 || scanCode == 8 || (scanCode >= 96 && scanCode <= 105))
    {
        ScanCodeToKeypadButton(scanCode).gotoAndPlay("up");     
    }
}

function CloseKeypad():Void
{
	Puzzle.Close()
}