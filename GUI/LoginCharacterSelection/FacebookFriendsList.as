//Imports
import com.GameInterface.ProjectUtils;
import com.Utils.LDBFormat;
import gfx.core.UIComponent;

//Class
class GUI.LoginCharacterSelection.FacebookFriendsList extends UIComponent
{
    //Constants
    private static var DEFAULT_LIST_HEIGHT:Number = 148;
    private static var DEFAULT_LIST_WIDTH:Number = 177;
    private static var SCROLL_WHEEL_SPEED:Number = 10;
    
    //Properties
    private var m_TitleTextField:TextField;
    private var m_Background:MovieClip;
    private var m_ListContainer:MovieClip;
    private var m_ScrollBar:MovieClip;
    private var m_ScrollBarPosition:Number;
    
    //Constructor
    public function FacebookFriendsList()
    {
        super();
        
        _visible = false;
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_TitleTextField.text = LDBFormat.LDBGetText("CharCreationGUI", "FacebookFrieldsListTitle");
        
        ProjectUtils.SetMovieClipMask(m_ListContainer, null, DEFAULT_LIST_HEIGHT, DEFAULT_LIST_WIDTH, false);
        
        m_ScrollBar = attachMovie("ScrollBarVisibleTrack", "m_ScrollBar", getNextHighestDepth());
        m_ScrollBar._x = m_Background._x + m_Background._width - m_ScrollBar._width - 13; 
        m_ScrollBar._y = m_ListContainer._y - 1;
        m_ScrollBar._height = DEFAULT_LIST_HEIGHT + 9;
        m_ScrollBar.setScrollProperties(m_ListContainer.m_ListTextField._height, 0, m_ListContainer.m_ListTextField._height - DEFAULT_LIST_HEIGHT);
        m_ScrollBar.trackMode = "scrollPage";
    }
    
    //Set Friends List
    public function SetFriendsList(list:Array):Void
    {
        m_ListContainer.m_ListTextField.text = "";
        m_ListContainer.m_ListTextField._width = DEFAULT_LIST_WIDTH;
        m_ListContainer.m_ListTextField.autoSize = "left";
        
        for (var i:Number = 0; i < list.length; i++)
        {
            m_ListContainer.m_ListTextField.text += list[i] + "\n";
        }
        
        if (m_ListContainer.m_ListTextField._height > DEFAULT_LIST_HEIGHT)
        {
            m_ScrollBar.position = m_ScrollBarPosition = 0;
            m_ScrollBar._visible = true;
            
            m_ListContainer.m_ListTextField._width -= 10;            
        }
        else
        {
            m_ScrollBar.position = m_ScrollBarPosition = 0;
            m_ScrollBar._visible = false;
            
            m_ListContainer.m_ListTextField._width = DEFAULT_LIST_WIDTH;
        }
    }
    
    //On Mouse Wheel
    private function onMouseWheel(delta:Number):Void
    {
        var newPos:Number = m_ScrollBar.position + -(delta * SCROLL_WHEEL_SPEED);
        
        m_ScrollBar.position = Math.min(Math.max(0.0, newPos), m_ScrollBar.maxPosition);
        m_ListContainer.m_ListTextField._y = 0 - m_ScrollBar.position;
        
        Selection.setFocus(null);
    }
}