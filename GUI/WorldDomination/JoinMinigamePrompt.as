import com.Utils.LDBFormat;

function onLoad()
{
	var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
	
    var windowTitle:String = LDBFormat.LDBGetText("WorldDominationGUI", "JoinPvPMinigame");
    
    m_Window.SetTitle(windowTitle, "center");
    m_Window.SetPadding(10);
	m_Window.SetContent("JoinMinigamePromptContent");
    
    m_Window.ShowCloseButton(false);
    m_Window.ShowStroke(true);
    m_Window.ShowResizeButton(false);    
    
  	m_Window._x = (visibleRect.width / 2) - (m_Window.m_Background._width / 2);
	m_Window._y = (visibleRect.height / 2) - (m_Window.m_Background._height / 2);
}