//Imports
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;

//Variables
var m_ResolutionScaleMonitor:DistributedValue;

//On Load
function onLoad()
{
    m_Window.SetTitle(LDBFormat.LDBGetText("GenericGUI", "LogoutGUI_Heading"), "center");
    m_Window.SetPadding(12);
	m_Window.SetContent("Content");
    
    m_Window.ShowCloseButton(false);
    m_Window.ShowStroke(true);
    m_Window.ShowResizeButton(false);  
    m_WIndow.SetDraggable(false);
    
    Layout();
    
    m_ResolutionScaleMonitor = DistributedValue.Create("GUIResolutionScale");
	m_ResolutionScaleMonitor.SignalChanged.Connect(Layout, this);
}

//Layout
function Layout():Void
{
    var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
    
    m_Window._x = visibleRect.width / 2 - m_Window._width / 2;
    m_Window._y = visibleRect.height / 2 - m_Window._height / 2;
}