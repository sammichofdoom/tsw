//Imports
import mx.utils.Delegate;
import com.Utils.Colors;
import com.Utils.Signal;

//Class
class GUI.PvPScoreboard.SortButton extends MovieClip
{
    //Constants
    public static var ASSENDING:String = "assending";
    public static var DESCENDING:String = "descending";
    
    private static var HIGHLIGHT_COLOR:Number = 0x484848;
    private static var PRE_HIGHLIGHT_COLOR:Number = 0x404040;
    private static var DEFAULT_COLOR:Number = 0x313131;
    
    //Properties
    public var SignalSortItems:Signal;
    
    private var m_TopButton:MovieClip;
    private var m_BottomButton:MovieClip;
    private var m_Background:MovieClip;
    
    private var m_Name:String;
    private var m_Direction:String;
    private var m_IsSelected:Boolean;
    
    //Constructor
    public function SortButton()
    {
        super();
        
        SignalSortItems = new Signal;
        
        Deselect();
    }
    
    //On Load
    private function onLoad():Void
    {
        onPress = PressEventHandler;
        onRelease = ReleaseEventHandler;
        onReleaseOutside = ReleaseOutsideEventHandler;
    }
    
    //Press Event Handler
    private function PressEventHandler():Void
    {
        Colors.ApplyColor(m_Background, PRE_HIGHLIGHT_COLOR);
    }
    
    //Release Event Handler
    private function ReleaseEventHandler():Void
    {
        m_IsSelected = true;
        
        Colors.ApplyColor(m_Background, HIGHLIGHT_COLOR);
        
        direction = (m_Direction == DESCENDING) ? ASSENDING : DESCENDING;
        
        SignalSortItems.Emit(this);
    }
    
    //Release Outside Event Handler
    private function ReleaseOutsideEventHandler():Void
    {
        if (m_IsSelected)
        {
            Colors.ApplyColor(m_Background, HIGHLIGHT_COLOR);
        }
        else
        {
            Colors.ApplyColor(m_Background, DEFAULT_COLOR);
        }
    }
    
    //Activate Display
    public function ActivateDisplay(direction:String):Void
    {
        m_IsSelected = true;
        
        Colors.ApplyColor(m_Background, HIGHLIGHT_COLOR);
        
        this.direction = direction;
    }
    
    //Deselect
    public function Deselect():Void
    {
        m_TopButton._visible = false;
        m_BottomButton._visible = false;
        
        m_IsSelected = false;
        
        Colors.ApplyColor(m_Background, DEFAULT_COLOR);
    }
    
    //Set Name 
    public function set name(value:String):Void
    {
        m_Name = value;
    }
    
    //Get Name
    public function get name():String
    {
        return m_Name;
    }
    
    //Set Direction
    public function set direction(value:String):Void
    {
        if (value == DESCENDING)
        {
            m_TopButton._visible = false;
            m_BottomButton._visible = true;
            
            m_Direction = DESCENDING;
        }
        
        if (value == ASSENDING)
        {
            m_TopButton._visible = true;
            m_BottomButton._visible = false;
            
            m_Direction = ASSENDING;
        }
    }
    
    //Get Direction
    public function get direction():String
    {
        return m_Direction;
    }
}