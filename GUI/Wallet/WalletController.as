import flash.geom.Point;
import flash.geom.Rectangle;
import GUI.Wallet.WalletWindow
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.Utils.LDBFormat;


var m_VisibleValue:DistributedValue;
var m_WalletWindow:WalletWindow;

var m_IsWalletVisible:Boolean;
var m_WalletPos:Point;
var m_Config:Archive;

function onLoad()
{
    m_WalletPos = new Point(100, 100);
    
    m_WalletWindow = attachMovie("WalletWindowComponent", "m_WalletWindow", getNextHighestDepth());
    m_WalletWindow.SetContent( "WalletWindow" );
    m_WalletWindow.SignalClose.Connect( SlotCloseWallet, this );
    m_WalletWindow.SetTitle(LDBFormat.LDBGetText("Tokens", "Tokens"));
    m_WalletWindow.ShowFooter( false );
    m_WalletWindow.ShowResizeButton( false );
    m_WalletWindow.ShowStroke( false );
    m_WalletWindow.SetSize( 350, 250 );
    
    m_WalletWindow._x = m_WalletPos.x;
    m_WalletWindow._y = m_WalletPos.y;
}

function OnModuleDeactivated()
{
    
    if (m_IsWalletVisible)
    {
        var archive:Archive = new Archive();
        archive.AddEntry("WindowX", m_WalletWindow._x);
        archive.AddEntry("WindowY", m_WalletWindow._y);
        return archive; 
    }
    else
    {
        return m_Config;
    }
      
}


function OnModuleActivated(config:Archive)
{
    m_WalletPos.x = config.FindEntry("WindowX", 100);
    m_WalletPos.y = config.FindEntry("WindowY", 100);
    
    m_Config = config;    
    if (m_IsWalletVisible)
    {
        m_WalletWindow._x = m_WalletPos.x;
        m_WalletWindow._y = m_WalletPos.y;
    }
}


function SlotCloseWallet()
{
    DistributedValue.SetDValue("wallet_window", false);
}
