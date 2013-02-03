import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;

var m_WindowVisibility:DistributedValue;
var m_WindowFocus:DistributedValue;
var m_ScaleMonitor:DistributedValue;

function onLoad()
{
    m_WindowVisibility = DistributedValue.Create( "achievement_lore_window" );
    m_Window.SignalClose.Connect(SlotCloseWindow, this);
	
	m_ScaleMonitor = DistributedValue.Create( "GUIScaleAchievements" );
	m_ScaleMonitor.SignalChanged.Connect(SlotScaleChanged, this);
	SlotScaleChanged();
}

function SlotScaleChanged()
{
	m_Window._xscale = m_ScaleMonitor.GetValue();
	m_Window._yscale = m_ScaleMonitor.GetValue();
}


function OnModuleActivated(config:Archive)
{
    var x:Number = config.FindEntry("PosX", 100);
    var y:Number = config.FindEntry("PosY", 180);
    var h:Number = config.FindEntry("Height", 500);
    var w:Number = config.FindEntry("Width", 570);
    
    var visibleRect:Rectangle = Stage["visibleRect"];
    x = Math.max(x, visibleRect.x);
    y = Math.max(y, visibleRect.y);
    x = Math.min(x, visibleRect.x + visibleRect.width - w);
    y = Math.min(y, visibleRect.y + visibleRect.height - h);

    var rectangle:Rectangle = new Rectangle(x, y, w, h);
    m_Window.SetSize(rectangle);
}

function OnModuleDeactivated():Archive
{
    var archive:Archive = new Archive();
    var rectangle:Rectangle = m_Window.GetSize();
    
    archive.AddEntry("PosX", rectangle.x);
    archive.AddEntry("PosY", rectangle.y);
    archive.AddEntry("Height", rectangle.height);
    archive.AddEntry("Width", rectangle.width);
	return archive;
}

function SlotCloseWindow()
{
    m_WindowVisibility.SetValue(false);
}
