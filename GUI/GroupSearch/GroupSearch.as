//Imports
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.Utils.LDBFormat;
import GUIFramework.SFClipLoader;

//Constants
var WINDOW_POS_X:String = "windowPosX";
var WINDOW_POS_Y:String = "windowPosY";
var CONTENT_PERSISTENCE:String = "LFGcontentPersistence";
var m_ScaleMonitor:DistributedValue;

//On Load
function onLoad()
{
    m_Window.SetTitle(LDBFormat.LDBGetText("GroupSearchGUI", "GroupSearch_WindowTitle"), "left");
    m_Window.SetPadding(8);
	m_Window.SetContent("Content");
    
    m_Window.ShowCloseButton(true);
    m_Window.ShowStroke(false);
    m_Window.ShowResizeButton(false);  
    
    var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
    
    m_Window._x = visibleRect.width / 2 - m_Window._width / 2;
    m_Window._y = visibleRect.height / 2 - m_Window._height / 2;
    
    m_Window.SignalClose.Connect(CloseWindowHandler, this);

    SFClipLoader.SignalDisplayResolutionChanged.Connect( ClampWindowPosition, this );
}

//On Module Activated
function OnModuleActivated(archive:Archive):Void
{
    var visibleRect = Stage["visibleRect"];
    
    m_Window._x = archive.FindEntry(WINDOW_POS_X, visibleRect.width / 2 - m_Window._width / 2);
    m_Window._y = archive.FindEntry(WINDOW_POS_Y, visibleRect.height / 2 - m_Window._height / 2);
    
    ClampWindowPosition();
    
    var persistence:Archive = archive.FindEntry(CONTENT_PERSISTENCE);
    
    m_Window.GetContent().SetContentPersistence(persistence);
}

function ClampWindowPosition():Void
{
    var visibleRect = Stage["visibleRect"];
    
    if (m_Window._x > visibleRect.width)
    {
        m_Window._x = visibleRect.width - 100;
    }
    
    if (m_Window._y > visibleRect.height)
    {
        m_Window._y = visibleRect.height - 100;
    }

}

//On Module Deactivated
function OnModuleDeactivated():Archive
{
    var archive:Archive = new Archive();
    
    archive.AddEntry(WINDOW_POS_X, m_Window._x);
    archive.AddEntry(WINDOW_POS_Y, m_Window._y);
    archive.AddEntry(CONTENT_PERSISTENCE, m_Window.GetContent().GetContentPersistence());
    
	return archive;
}

//Close Window Handler
function CloseWindowHandler():Void
{
    DistributedValue.SetDValue("group_search_window", false);
}