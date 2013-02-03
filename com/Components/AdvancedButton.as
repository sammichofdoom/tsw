//Improts
import com.Utils.Signal;

//Class
class com.Components.AdvancedButton extends MovieClip
{
    /*
     *  AdvancedButton MovieClip object must contain timeline
     *  labels consisting of the following in order:
     *
     *  1.  over (must be frame 1)
     *  2.  down
     *  3.  up
     *  4.  disabled
     * 
     *  
     * 
     * 
     *  If the AdvancedButton is a toggle button, the
     *  toggle property must be set to true and the 
     *  additional timeline labels must be included:
     *
     *  - myButton.toggle = true;
     * 
     *  5.  select
     *  6.  selected
     *  7.  deselect          
     *  8.  disabledSelected
     * 
     * 
     * 
     * 
     *  Both basic and toggle buttons must redirect back to the "over"
     *  label when the "up" (basic) or "deselect" (toggle) animations
     *  has finished by including the following on the appropriate frame:
     * 
     *  - gotoAndStop("over");
     * 
     * 
     * 
     * 
     *  Optionally assign a name to each instance:
     *  
     *  - myButton.name = "myButton")
     * 
     * 
     * 
     * 
     *  Connect to SignalButtonSelected(name:String):Void signal
     *  for handling when the button has been clicked:
     * 
     *  - myButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
     * 
     * 
     * 
     * 
     *  With optional name property:
     * 
     *  - public function SlotButtonSelected(name:String):Void
     * 
     * 
     * 
     * 
     *  Without optional name property:
     * 
     *  - public function SlotButtonSelected(target:Object):Void
     * 
     */
    
    //Properties
    public var SignalButtonSelected:Signal;

    private var m_Name:String;
    private var m_IsToggle:Boolean;
    private var m_IsSelected:Boolean;
    private var m_IsDisabled:Boolean;
    private var m_IsHammered:Boolean;
    
    //Constructor
    public function AdvancedButton()
    {
        super();
        
        SignalButtonSelected = new Signal();
        
        m_IsToggle = false;
        m_IsSelected = false;
        m_IsDisabled = false;
        
        onRelease = ReleaseEventHandler;
        onReleaseOutside = ReleaseOutsideEventHandler;
        onRollOver = RollOverEventHandler;
    }
    
    //Roll Over Event Handler
    private function RollOverEventHandler():Void
    {
        onRollOver = null;
        onRollOut = RollOutEventHandler;
        onPress = PressEventHandler;

        gotoAndPlay("over");
    }
    
    //Roll Out Event Handler
    private function RollOutEventHandler():Void
    {
        onRollOut = null;
        onPress = null;

        onRollOver = RollOverEventHandler;
        onEnterFrame = OnEnterFrameEventHandlder;
    }
    
    //Press Event Handler
    private function PressEventHandler():Void
    {
        onRollOut = null;
        onPress = null;

        gotoAndPlay("down");
    }
    
    //Release Event Handler
    private function ReleaseEventHandler():Void
    {
        onRollOver = RollOverEventHandler;

        if (m_IsToggle)
        {
            selected = true;
        }
        else
        {
            onPress = PressEventHandler;
            m_IsHammered = true;
            
            gotoAndPlay("up");
        }

        if (!m_Name)
        {
            SignalButtonSelected.Emit(this);
        }
        else
        {
            SignalButtonSelected.Emit(m_Name);                
        }
    }
    
    //Release Outside Event Handler
    private function ReleaseOutsideEventHandler():Void
    {
        onRollOver = RollOverEventHandler;
        
        if (m_IsHammered)
        {
            m_IsHammered = false;
        }
        else
        {
            gotoAndPlay("up");
        }
    }
    
    //On Enter Frame Event Handler
    private function OnEnterFrameEventHandlder():Void
    {   
        if (_currentframe > 1)
        {
            prevFrame();
        }
        else
        {
            onEnterFrame = null;
        }
    }

    //Set Select Handler
    public function set name(value:String):Void
    {
        m_Name = value;
    }
    
    //Get Select Handler
    public function get name():String
    {
        return m_Name;
    }
    
    //Set Toggle
    public function set toggle(value:Boolean):Void
    {
        m_IsToggle = value;
    }
    
    //Get Toggle
    public function get toggle():Boolean
    {
        return m_IsToggle;
    }
    
    //Set Selected
    public function set selected(value:Boolean):Void
    {
        if (!m_IsSelected && value)
        {
            gotoAndPlay("select");
            
            onRollOver = null;
            onRollOut = null;
            onPress = null;
        }
        
        if (m_IsSelected && !value)
        {
            gotoAndPlay("deselect");
            
            onRollOver = RollOverEventHandler;
        }

        m_IsSelected = value;
    }
    
    //Get Selected
    public function get selected():Boolean
    {
        return m_IsSelected;
    }
    
    //Set Disabled
    public function set disabled(value:Boolean):Void
    {
        m_IsDisabled = value;
        
        if (m_IsDisabled)
        {
            if (m_IsSelected)
            {
                gotoAndPlay("disabledSelected")
            }
            else
            {
                gotoAndPlay("disabled");
            }
            
            onRollOver = null;
            onRollOut = null;
            onRelease = null;
            onReleaseOutside = null;
            onPress = null;
        }
        else
        {
            if (m_IsSelected)
            {
                gotoAndPlay("selected");
            }
            else
            {
                gotoAndStop("over");
            }
            
            onRelease = ReleaseEventHandler;
            onReleaseOutside = ReleaseOutsideEventHandler;
            onRollOver = RollOverEventHandler;
        }
    }
    
    //Set Disabled
    public function get disabled():Boolean
    {
        return m_IsDisabled;
    }
}