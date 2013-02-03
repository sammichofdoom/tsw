//Imports
import mx.utils.Delegate;
import com.Utils.Colors;
import com.Utils.Signal;

//Class
class GUI.Claim.SortButton extends MovieClip
{
    //Constants
    public static var ASSENDING:String = "assending";
    public static var DESCENDING:String = "descending";
    
    private static var ON_COLOR:Number = 0xFFFFFF;
    private static var OFF_COLOR:Number = 0x999999;
    
    //Properties
    public var SignalSortClaimItems:Signal
    
    private var m_Name:String;
    private var m_TopButton:MovieClip;
    private var m_BottomButton:MovieClip;
    private var m_Direction:String;
    private var m_IsDisabled:Boolean;
    
    //Constructor
    public function SortButton()
    {
        super();
        
        SignalSortClaimItems = new Signal;
    }
    
    //On Load
    private function onLoad():Void
    {
        onRelease = ReleaseEventHandler;
    }
    
    //On Release Event Handler
    private function ReleaseEventHandler():Void
    {
        if (!m_IsDisabled)
        {
            if (m_Direction == ASSENDING)
            {
                Colors.ApplyColor(m_TopButton, OFF_COLOR);
                Colors.ApplyColor(m_BottomButton, ON_COLOR);
                
                SignalSortClaimItems.Emit(m_Name, DESCENDING);
                
                m_Direction = DESCENDING;
            }
            else
            {
                Colors.ApplyColor(m_TopButton, ON_COLOR);
                Colors.ApplyColor(m_BottomButton, OFF_COLOR);
                
                SignalSortClaimItems.Emit(m_Name, ASSENDING);
                
                m_Direction = ASSENDING;
            }
        }
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
            Colors.ApplyColor(m_TopButton, OFF_COLOR);
            Colors.ApplyColor(m_BottomButton, ON_COLOR);
            
            m_Direction = DESCENDING;
        }
        
        if (value == ASSENDING)
        {
            Colors.ApplyColor(m_TopButton, ON_COLOR);
            Colors.ApplyColor(m_BottomButton, OFF_COLOR);
            
            m_Direction = ASSENDING;
        }
    }
    
    //Get Direction
    public function get direction():String
    {
        return m_Direction;
    }
    
    //Set Disabled
    public function set disabled(value:Boolean):Void
    {
        if (value)
        {
            _alpha = 50;
            
            Colors.ApplyColor(m_TopButton, OFF_COLOR);
            Colors.ApplyColor(m_BottomButton, OFF_COLOR);
        }
        else
        {
            _alpha = 100;
            
            direction = ASSENDING;
        }
        
        m_IsDisabled = value;
    }
    
    //Get Disabled
    public function get disabled():Boolean
    {
        return m_IsDisabled;
    }
}