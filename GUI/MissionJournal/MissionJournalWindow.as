import com.Components.WinComp;
import flash.geom.Point;
import GUI.MissionJournal.JournalWindow;
import com.Utils.Archive;
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.GameInterface.LoreBase;

var m_ExpandedTiersArray:Array = new Array();

var m_ExpandedMissionID:Number = -123456789;

var m_Window:WinComp
var m_HelpButton:MovieClip;
var m_WinDefaultWidth:Number = 450;
var m_WinDefaultHeight:Number = 400;

function onLoad()
{
    m_Window = attachMovie("WindowComponent", "m_Window", getNextHighestDepth());
    m_Window.SetContent( "JournalWindow" );
    m_Window.SignalClose.Connect( SlotCloseWindow, this );
    m_Window.GetContent().SignalSizeChanged.Connect( SlotSizeChanged, this );
    m_Window.SetTitle( LDBFormat.LDBGetText("GenericGUI", "MissionJournalWindowTitle") );
    m_Window.ShowFooter( false );
    m_Window.ShowResizeButton( true );
    m_Window.ShowStroke( false );
    m_Window.SetMinWidth( 300 );
    m_Window.SetMinHeight( 300 );
	
    m_HelpButton = m_Window.attachMovie("HelpButton", "m_HelpButton", m_Window.getNextHighestDepth());
    m_HelpButton._width = m_HelpButton._height = m_Window.m_CloseButton._width;
}

function SlotSizeChanged():Void
{    
    m_HelpButton._x = m_Window.m_CloseButton._x - m_HelpButton._width - 5;
    m_HelpButton._y = m_Window.m_CloseButton._y;
}

function HelpWindowClickedHandler():Void
{
    Selection.setFocus(null);
    
    LoreBase.OpenTag(5218);
}

function OnModuleDeactivated()
{
    var content:JournalWindow = JournalWindow( m_Window.GetContent() );
    var contentSize:Point = m_Window.GetSize();
    var archive:Archive = content.GetModuleData();
    
    archive.AddEntry("WindowX", m_Window._x);
    archive.AddEntry("WindowY", m_Window._y);
	if (contentSize != undefined)
	{
		archive.AddEntry("WindowSize", contentSize);
	}

    return archive;
}


function OnModuleActivated(archive:Archive)
{
    var content:JournalWindow = JournalWindow( m_Window.GetContent());
    var visibleRect = Stage["visibleRect"];
    
    content.SetModuleData(archive);
    
    var size:Point = archive.FindEntry("WindowSize", new Point(m_WinDefaultWidth, m_WinDefaultHeight));
	var nonContentSize:Point = m_Window.GetNonContentSize();
	
	if (size == undefined)
	{
		size = new Point(300, 300);
	}
	if (isNaN(size.x))
	{
		size.x = 300;
	}
	if (isNaN(size.y))
	{
		size.x = 300;
	}
	
	size.x += nonContentSize.x;
	size.y += nonContentSize.y;
        
    var x:Number = archive.FindEntry("WindowX", 100);
    var y:Number = archive.FindEntry("WindowY", 100);
    
    if (x > visibleRect.width || x < -size.x)
    {
        x = 100;
    }
    if (y > visibleRect.height || y < -size.y)
    {
        y = 100;
    }
    m_Window.SetSize(size.x, size.y);
    m_Window._x = x;
    m_Window._y = y;
    m_HelpButton.addEventListener("click", this, "HelpWindowClickedHandler");
}

function SlotCloseWindow()
{
    DistributedValue.SetDValue("mission_journal_window", false);
}