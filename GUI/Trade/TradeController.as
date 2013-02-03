import com.GameInterface.Utils;
import GUI.Trade.TradeWindow;
import com.Utils.ID32;
import com.GameInterface.DistributedValue;
import com.GameInterface.GUIModuleIF;

var m_TradeWindow:MovieClip;
var m_ScaleMonitor :DistributedValue;

function onLoad()
{
    Utils.SignalTradeStarted.Connect(SlotTradeStarted, this);
    Utils.SignalTradeEnded.Connect(SlotTradeCompleted, this);
    
    m_ScaleMonitor = DistributedValue.Create( "GUIScaleInventory" );
    m_ScaleMonitor.SignalChanged.Connect( SlotScaleChanged, this );
    Layout();
    
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
	moduleIF.SignalStatusChanged.Connect( SlotHideModuleStateUpdated, this );
}

function SlotHideModuleStateUpdated( module:GUIModuleIF, isActive:Boolean )
{
	if (m_TradeWindow != undefined && !isActive)
	{
		Utils.AbortTrade();
	}
}

function Layout()
{
    var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
    _x = visibleRect.x;
    _y = visibleRect.y;
}

function SlotScaleChanged()
{
	if (m_TradeWindow != undefined)
	{
		m_TradeWindow._xscale = m_ScaleMonitor.GetValue();
		m_TradeWindow._yscale = m_ScaleMonitor.GetValue();
	}
}

function SlotTradeStarted(tradePartner:ID32)
{
    m_TradeWindow = attachMovie("TradeWindow", "m_TradeWindow", getNextHighestDepth());
    m_TradeWindow.SetTradePartner(tradePartner);
    
    m_TradeWindow._x = 200;
    m_TradeWindow._y = 200;
	SlotScaleChanged();
}

function SlotTradeCompleted(acceptedTrade:Boolean)
{
    m_TradeWindow.ClearItems();
    m_TradeWindow.removeMovieClip();
	m_TradeWindow = undefined;
}
