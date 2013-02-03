//Imports
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tradepost;
import com.Utils.Archive;

//Constants
var WINDOW_POS_X:String = "windowPosX";
var WINDOW_POS_Y:String = "windowPosY";

//On Load
function onLoad()
{
    m_Window.SetTitle(LDBFormat.LDBGetText("MiscGUI", "TradePost_ComposeLetter"), "left");
    m_Window.SetPadding(8);
	m_Window.SetContent("Content");
    m_Window.ShowCloseButton(true);
    m_Window.ShowStroke(false);
    m_Window.ShowResizeButton(false);  
    
    m_Window.SignalClose.Connect(CloseWindowHandler, this);    
    m_Window.GetContent().SignalCloseWindow.Connect(CloseWindowHandler, this);
    
   Tradepost.SignalComposeMail.Connect(SlotBringToFront,this);
}

function SlotBringToFront():Void
{
    GUIFramework.SFClipLoader.MoveToFront(GUIFramework.SFClipLoader.GetClipIndex(this));
}

//On Module Activated
function OnModuleActivated(archive:Archive):Void
{
    var visibleRect = Stage["visibleRect"];
    
    m_Window._x = archive.FindEntry(WINDOW_POS_X, visibleRect.width / 2 - m_Window._width / 2);
    m_Window._y = archive.FindEntry(WINDOW_POS_Y, visibleRect.height / 2 - m_Window._height / 2);
    
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

	return archive;
}

//Close Window Handler
function CloseWindowHandler():Void
{
    DistributedValue.SetDValue("compose_mail_window", false);
}