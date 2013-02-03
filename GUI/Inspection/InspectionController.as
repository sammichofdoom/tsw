import com.GameInterface.Utils;
import com.GameInterface.Game.Character;
import com.GameInterface.DistributedValue;
import com.GameInterface.GUIModuleIF;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.GlobalSignal;
import com.Utils.Signal;
import flash.geom.Point;

var m_InspectionPos:Point;
var m_InspectionWindows:Object;
var m_ResolutionScaleMonitor:DistributedValue;

function onLoad()
{
    m_InspectionWindows = new Object();
    
    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( Layout, this );
    Layout();
    
    GlobalSignal.SignalShowInspectWindow.Connect(SlotShowInspectionWindow, this);
    
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
	moduleIF.SignalStatusChanged.Connect( SlotHideModuleStateUpdated, this );
}

function SlotHideModuleStateUpdated( module:GUIModuleIF, isActive:Boolean )
{

}

function Layout()
{
    var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
    _x = visibleRect.x;
    _y = visibleRect.y;
    
     var scale:Number = m_ResolutionScaleMonitor.GetValue();
    _xscale = scale * 100;
    _yscale = scale * 100;
}

function SlotShowInspectionWindow(characterID:ID32)
{
    if (m_InspectionWindows[characterID.toString()] == undefined)
    {
		m_InspectionPos = new Point(100, 100);
    
		m_InspectionWindow = attachMovie("InspectionWindowComponent", "i_InspectionWindow_" + characterID.GetInstance(), getNextHighestDepth());
		m_InspectionWindow.SetContent( "InspectionWindow" );
		m_InspectionWindow.GetContent().SetCharacter(characterID);
		m_InspectionWindow.SetTitle(LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Title"));
		m_InspectionWindow.ShowFooter( true );
		m_InspectionWindow.ShowResizeButton( false );
		m_InspectionWindow.ShowStroke( false );
		m_InspectionWindow.SetSize( m_InspectionWindow.GetContent()._width, m_InspectionWindow.GetContent()._height );
		
		m_InspectionWindow.GetContent().SignalClose.Connect( SlotCloseInspectionWindow, this );
		
		m_InspectionWindow._x = m_InspectionPos.x;
		m_InspectionWindow._y = m_InspectionPos.y;
        
        m_InspectionWindows[characterID.toString()] = m_InspectionWindow;
    }
}

function SlotCloseInspectionWindow(windowID:MovieClip)
{
    if (m_InspectionWindows.hasOwnProperty(windowID.toString()))
    {
        m_InspectionWindows[windowID.toString()].removeMovieClip();
        m_InspectionWindows[windowID.toString()] = undefined;
    }
}
