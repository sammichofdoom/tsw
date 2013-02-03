import mx.utils.Delegate;
import com.GameInterface.Log;
import com.GameInterface.DistributedValue;
import com.Utils.Signal;
import gfx.controls.TextArea;
import gfx.motion.Tween; 
import mx.transitions.easing.*;

var m_LogWindow:MovieClip = this;
var m_IconSizes:Number = 500; // just a magic number used to control icon sizes, the higher the number, the bigger the icons (not pixel by pixel)
var m_HalfWidth:Number; ///Container for the width of the stage, used to calculate rotation of the MissionWindow
var m_ResolutionScaleMonitor:DistributedValue;
var m_ErrorFormat:TextFormat;
var m_WarningFormat:TextFormat;
var m_Padding:Number = 2;
var m_Log0:TextField;
var m_MaxLines = 8;

/// INSTANCIATION
function onLoad()
{
  //  trace('LogWindow.onLoad()')  
    
    m_HalfWidth = Stage["visibleRect"].width / 2;
    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_LogWindow = this
    
    m_ErrorFormat = new TextFormat;
    m_ErrorFormat.font = "_StandardFont";
    m_ErrorFormat.size = 11;
    m_ErrorFormat.color = 0xFF0000; // Red

    m_WarningFormat = new TextFormat;
    m_WarningFormat.font = "_StandardFont";
    m_WarningFormat.size = 11;
    m_WarningFormat.color = 0xFFa500; // Orange
    
    m_Background.onPress = function()
    {
        m_LogWindow.startDrag();
    }

    m_Background.onMouseUp = function()
    {
        m_LogWindow.stopDrag();
    }
    
    Redraw();
    
    com.GameInterface.Log.SetMsgForward(true)       
}

function ScrollLog() : Void
{

    for ( var i = m_MaxLines - 1; i >= 1; --i )
    {
        var toTF:TextField = this['m_Log'+i];
        var fromTF:TextField = this['m_Log' + (i - 1)];
        
        toTF.data = fromTF.data;
        
        UpdateText(toTF);
    }
}

function SlotMsg(message:String)
{
    // Any errors in this code will *not* appear in the log window, only in ClientLog.txt
    
    var errorIdx:Number = message.indexOf('ERROR: ');
    var warningIdx:Number = message.indexOf('WARNING: ');
    var isServer:Boolean = (message.indexOf('ServerLogCopy') > 0);       
    var isError:Boolean = false;
    var isWarning:Boolean = false;
    
    if (errorIdx > 0)
    {
        isError = true;
        
         // Keep text after first 'ERROR: '
        message = message.substring(errorIdx + 7, message.length);
    }
    else if (warningIdx > 0)
    {
        isWarning = true;
        
         // Keep text after first 'WARNING: '
        message = message.substring(warningIdx + 9, message.length);
    }
    else
    {
        // Not an error or warning message. Skip it.
        return;
    }
    

    
    // Remove leading spaces. Maybe a better way to do this... anyway, who cares.
    
    while (message.substr(0, 1) == ' ')
    {
        message = message.substring(1, message.length);
    }
    
    // Remove trailing return, if any.
    
    if (message.substr(message.length - 1, 1) == '\n')
    {
        message = message.substring(0, message.length - 1);        
    }
    
 
    // Check if this line is a repeat of a currently displayed line.
    for ( var i = 0; i < m_MaxLines; ++i )
    {
        var tf:TextField = this['m_Log' + i];
        
        if (tf.data.originalText == message)
        {           
            tf.data.textRepeats = tf.data.textRepeats + 1;
            
            UpdateText(tf);
          
            return;
        }
    }
    
    ScrollLog();
    
    var data:Object =
    {
        originalText: message,
        textRepeats: 1,
        isError: isError,
        isWarning: isWarning,
        isServer: isServer
    };
        
    m_Log0.data = data;
    
    UpdateText(m_Log0);
}

function UpdateText(tf:TextField)
{
    
    if (tf.data.isError)
    {
        tf.setNewTextFormat( m_ErrorFormat );  
    }
    else
    {
        tf.setNewTextFormat( m_WarningFormat );  
    }   
    
    tf.text = ""
    
    if (tf.data.originalText != "")
    {
        if (tf.data.isServer)
        {
            tf.text += 'S - ';       
        }
        else
        {
            tf.text += 'C - ';
        }
        
        tf.text += tf.data.originalText;
        
        if (tf.data.textRepeats > 1)
        {
            tf.text += ' (x' + tf.data.textRepeats + ')';       
        }
    }
}

/// Method being called by the GUIFramework when it is unloading
function onUnload() : Void
{
    Log.SetMsgForward(false)
}

function Redraw() : Void
{
//    trace('LogWindow.Redraw()')
    
    for ( var i = 0; i < m_MaxLines; ++i )
    {
        var log:TextField = m_LogWindow.createTextField("m_Log" + i, m_LogWindow.getNextHighestDepth(), 0, 0, 780, 18);
				log.selectable = false;
        log.multiline = false;
        log.wordWrap = false;
        log.setNewTextFormat( m_ErrorFormat );
        log.text = "-";
        //log._height = log.textHeight
        log._x = m_Padding;
        log._y = log._height * i;
        log.textRepeats = 0;
        log.data = 
        {
            originalText: ''
        }
    }
    
    ReadMsgCache();
}

function onEnterFrame() : Void
{
    ReadMsgCache();
}

function ReadMsgCache() : Void
{
    var msgCache:Array = Log.GetMsgCache();
    
    // Fill the window with the current cache, if any.
    for ( var i = 0; i < msgCache.length; ++i )
    {   
        SlotMsg(msgCache[i]);
    }
}

/// invoked by the parent (GUIFramework, handles resizing of all GUI elements
function ResizeHandler() : Void
{
	var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
	_y = visibleRect.y;
	_x = visibleRect.x;
    m_HalfWidth = visibleRect.width / 2;
}
