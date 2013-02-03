//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.ShopInterface;
import com.Utils.Archive;
import com.Utils.ID32;
import flash.geom.Rectangle;
import GUI.Shop.ShopWindow;

//Constants
var WINDOW_X:String = "windowX";
var WINDOW_Y:String = "windowY";
var WINDOW_WIDTH:String = "windowWidth";
var WINDOW_HEIGHT:String = "windowHeight";
var SELECTED_TAB_INDEX:String = "selectedTabIndex";

//Properties
var m_Window:MovieClip;
var m_VisibleRect:Rectangle
var m_ArchiveX:Number;
var m_ArchiveY:Number;
var m_ArchiveWidth:Number;
var m_ArchiveHeight:Number;
var m_ArchiveTabIndex:Number;
var m_Archive:Archive;
var m_ShopInterface:ShopInterface;

//On Load
function onLoad():Void
{
    var m_ResolutionScaleMonitor:DistributedValue = DistributedValue.Create("GUIResolutionScale");
    m_ResolutionScaleMonitor.SignalChanged.Connect(CheckWindowBounds, this);
    
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF("GenericHideModule");
	moduleIF.SignalDeactivated.Connect(SlotCloseShop, this);
}

//On Module Activated
function OnModuleActivated(archive:Archive):Void
{
    m_Archive = archive;
    
    ShopInterface.SignalOpenShop.Connect(SlotOpenShop, this);
}

//On Module Deactivated
function OnModuleDeactivated():Archive
{
    return m_Archive;
}

//Read Archive
function ReadArchive():Void
{
    m_ArchiveX = m_Archive.FindEntry(WINDOW_X, 100);
    m_ArchiveY = m_Archive.FindEntry(WINDOW_Y, 100);
    m_ArchiveWidth = m_Archive.FindEntry(WINDOW_WIDTH, ShopWindow.MIN_WIDTH);
    m_ArchiveHeight = m_Archive.FindEntry(WINDOW_HEIGHT, ShopWindow.MIN_HEIGHT);
    m_ArchiveTabIndex = m_Archive.FindEntry(SELECTED_TAB_INDEX, 0);
}

//Write Archive
function WriteArchive():Void
{
    m_Archive = new Archive();
    
    m_Archive.AddEntry(WINDOW_X, m_Window._x);
    m_Archive.AddEntry(WINDOW_Y, m_Window._y);
    m_Archive.AddEntry(WINDOW_WIDTH, m_Window.GetContent().GetSize().x);
    m_Archive.AddEntry(WINDOW_HEIGHT, m_Window.GetContent().GetSize().y);
    m_Archive.AddEntry(SELECTED_TAB_INDEX, m_Window.GetContent().GetTabIndex());
}

//Slot Open Shop
function SlotOpenShop(shopInterface:ShopInterface):Void
{
    m_ShopInterface = shopInterface;
    
    ReadArchive();
    
	m_Window = attachMovie("ShopWindow", "shopwindow", getNextHighestDepth());
    m_Window.GetContent().SignalContentInitialized.Connect(SlotContentInitialized, this);
}

//Slot Content Initialized
function SlotContentInitialized():Void
{    
	m_Window._x = m_ArchiveX;
	m_Window._y = m_ArchiveY;
    
    
	m_Window.SetShopInterface(m_ShopInterface);
    m_Window.GetContent().SetSize(m_ArchiveWidth, m_ArchiveHeight);
    m_Window.GetContent().SetTabIndex(m_ArchiveTabIndex);
	m_Window.SignalCloseShop.Connect(SlotCloseWindow);

    var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
    escapeNode.SignalEscapePressed.Connect(SlotCloseShop);
    
    com.GameInterface.EscapeStack.Push(escapeNode);
    
    CheckWindowBounds();
}

//Slot Close Shop
function SlotCloseShop():Void
{
	m_Window.SlotClose();
}

//Slot Close Window
function SlotCloseWindow(window:MovieClip):Void
{
    if (m_Window)
    {
        WriteArchive();
        
        m_Window.removeMovieClip();
        m_Window = undefined;
    }
}

//Check Window Bounds
function CheckWindowBounds():Void
{
    var m_VisibleRect:Rectangle = Stage["m_VisibleRect"];
    
    if (m_Window._x > m_VisibleRect.width)
    {
        m_Window._x = m_VisibleRect.width - 100;
    }
    
    if (m_Window._y > m_VisibleRect.height)
    {
        m_Window._y = m_VisibleRect.height - 100;
    }
}