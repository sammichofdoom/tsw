//Imports
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.GameInterface.LoreBase;

//Properties
var m_HelpButton:MovieClip;

//On Load
function onLoad()
{
    m_Window.SetPadding(10);
	m_Window.SetContent("Content");
    
    m_Window.ShowCloseButton(true);
    m_Window.ShowStroke(false);
    m_Window.ShowResizeButton(false);  
    
    m_HelpButton = m_Window.attachMovie("HelpButton", "m_HelpButton", m_Window.getNextHighestDepth());
    m_HelpButton._width = m_HelpButton._height = m_Window.m_CloseButton._width;
    m_HelpButton._x = m_Window.m_CloseButton._x - m_HelpButton._width - 5;
    m_HelpButton._y = m_Window.m_CloseButton._y;
    m_HelpButton.addEventListener("click", this, "HelpButtonClickedHandler");
    
    var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
    
    m_Window._x = visibleRect.width / 2 - m_Window._width / 2;
    m_Window._y = visibleRect.height / 2 - m_Window._height / 2;
    
    m_Window.SignalClose.Connect(CloseWindowHandler, this);
}

//Help Button Clicked Handler
function HelpButtonClickedHandler():Void
{
    Selection.setFocus(null);
    
    LoreBase.OpenTag(5222);
}

//Close Window Handler
function CloseWindowHandler():Void
{
    DistributedValue.SetDValue("friends_window", false);
}