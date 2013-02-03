//Imports
import com.Utils.LDBFormat;
import com.Utils.GlobalSignal;
import com.GameInterface.Utils;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.DistributedValue;

//On Load
function onLoad()
{
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF("GenericHideModule");
	moduleIF.SignalStatusChanged.Connect(SlotHideModuleStateUpdated, this);
    
    m_Window.SetTitle(LDBFormat.LDBGetText("MiscGUI", "LootOptionWindow_Title"), "left");
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
    m_Window.GetContent().SignalCloseLootOptionWindow.Connect(CloseWindowHandler, this );
}

//Slot Hide Module State Updated
function SlotHideModuleStateUpdated(module:GUIModuleIF, isActive:Boolean):Void
{
	if (!isActive)
	{
		CloseWindowHandler();
	}
}

//Close Window Handler
function CloseWindowHandler():Void
{
    DistributedValue.SetDValue("loot_options_window", false);
}