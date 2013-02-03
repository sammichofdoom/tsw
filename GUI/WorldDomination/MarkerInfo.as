//Improts
import com.Utils.Signal;

//Class
class GUI.WorldDomination.MarkerInfo extends MovieClip
{
    //Constants
    public static var LEFT:String = "left";
    public static var RIGHT:String = "right";
    
    private static var X_POSITION:Number = 30;
    private static var CLOSE_BUTTON_SIZE:Number = 137;
    
    //Properties
    public var m_Button:MovieClip;
    
    private var m_Container:MovieClip;
    private var m_IsSelected:Boolean;
    
    //Constructor
    public function MarkerInfo()
    {
        super();
    }
    
    //Set Title
    public function SetupInfo(alignment:String, title:String, subtitle:String, buttonName:String):Void
    {
        m_Container.m_Title.autoSize = alignment;
        m_Container.m_Subtitle.autoSize = alignment;
        
        m_Container.m_Title.text = title;
        m_Container.m_Subtitle.text = subtitle;
        
        m_Button = m_Container.attachMovie(buttonName, "m_Button", m_Container.getNextHighestDepth());
        m_Button.name = title;
        m_Button._width = CLOSE_BUTTON_SIZE;
        m_Button._height = CLOSE_BUTTON_SIZE;
        
        if (alignment == LEFT)
        {
            m_Container.m_Title._x = -(m_Container.m_Title._width + X_POSITION);
            m_Container.m_Subtitle._x = -(m_Container.m_Subtitle._width + X_POSITION);
            m_Button._x = X_POSITION + m_Button._width / 2;
            m_Button._y = m_Button._width / 2;
        }
        else
        {
            m_Container.m_Title._x = X_POSITION;
            m_Container.m_Subtitle._x = X_POSITION;
            m_Button._x = -(m_Button._width + X_POSITION - m_Button._width / 2);
            m_Button._y = m_Button._width / 2;
        }
    }
    
    //Set Selected
    public function set selected(value:Boolean):Void
    {
        if (!m_IsSelected && value)
        {
            gotoAndPlay("select");
        }
        
        if (m_IsSelected == undefined && value)
        {
            gotoAndPlay("selected");
        }
        
        if (m_IsSelected && !value)
        {
            gotoAndPlay("deselect");
        }

        m_IsSelected = value;
    }
    
    //Get Selected
    public function get selected():Boolean
    {
        return m_IsSelected;
    }
}