//Imports
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;

//On Load
function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
    var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "Help_Browser");
    
    m_Window.SetTitle(windowTitle, "left");
    m_Window.SetPadding(10);
	m_Window.SetContent("PetitionBrowserContent");
    
    m_Window.ShowCloseButton(true);
    m_Window.ShowStroke(false);
    m_Window.ShowResizeButton(false);    
    m_Window.ShowFooter(false);
    
  	m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
	m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
    
    m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}

//Close Window Handler
function CloseWindowHandler():Void
{
    m_Window.GetContent().Deconstruct();
    DistributedValue.SetDValue("petition_browser", false);
}