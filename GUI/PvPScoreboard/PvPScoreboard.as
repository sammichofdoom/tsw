//Imports
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.GameInterface.PvPScoreboard;

//On Load
function onLoad()
{
    m_Window.SetTitle(LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_pvpScoreboard"), "left");
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
}

//Close Window Handler
function CloseWindowHandler():Void
{
    PvPScoreboard.Close();
    DistributedValue.SetDValue("pvp_scoreboard", false);
}