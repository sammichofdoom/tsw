//Imports
import com.Utils.Archive;
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;

//Constants
var ARCHIVED_LOCATION_X:String = "archivedLocationX";
var ARCHIVED_LOCATION_Y:String = "archivedLocationY";

//Properties
var m_ArchiveLocationX:Number = 0;
var m_ArchiveLocationY:Number = 0;

//On Module Activated
function OnModuleActivated(config:Archive):Void
{
    if (config != undefined)
    {
        m_ArchiveLocationX = Number(config.FindEntry(ARCHIVED_LOCATION_X, 0));
        m_ArchiveLocationY = Number(config.FindEntry(ARCHIVED_LOCATION_Y, 0));
    }
    
    PositionWindow();
}

//On Module Deactivated
function OnModuleDeactivated():Archive
{
    var archive:Archive = new Archive();
    archive.ReplaceEntry(ARCHIVED_LOCATION_X, m_Window._x);
    archive.ReplaceEntry(ARCHIVED_LOCATION_Y, m_Window._y);

    return archive;
}

//Initialize
function onLoad():Void
{
    var windowTitle:String = LDBFormat.LDBGetText("GenericGUI", "Web_Browser");
    
    m_Window.SetTitle(windowTitle, "left");
    m_Window.SetPadding(10);
    m_Window.SetContent("WebBrowserContent");
    
    m_Window.ShowCloseButton(true);
    m_Window.ShowStroke(false);
    m_Window.ShowResizeButton(false);    
    m_Window.ShowFooter(false);	
    
    m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
}

//Position Window
function PositionWindow():Void
{
    if (m_ArchiveLocationX == 0 && m_ArchiveLocationY == 0)
    {
        var visibleRect = Stage["visibleRect"];
        _x = visibleRect.x;
        _y = visibleRect.y;
        
        m_Window._x = Math.round((visibleRect.width / 2) - (m_Window.m_Background._width / 2));
        m_Window._y = Math.round((visibleRect.height / 2) - (m_Window.m_Background._height / 2));
    }
    else
    {
        m_Window._x = m_ArchiveLocationX;
        m_Window._y = m_ArchiveLocationY;
    }  
}

//Close Window Handler
function CloseWindowHandler():Void
{
    DistributedValue.SetDValue("web_browser", false);
}