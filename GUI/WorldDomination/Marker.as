//Improts
import com.Utils.Signal;
import com.GameInterface.Game.Character;

//Class
class GUI.WorldDomination.Marker extends MovieClip
{
    //Constants
    private static var SELECT_LOCATION_SOUND_EFFECT:String = "sound_fxpackage_GUI_PvP_select_location.xml";
    
    //Properties
    public static var m_SelectSound:Boolean;
    
    public var SignalMarkerSelected:Signal;
    public var m_Name:String;
    public var m_InZoneNotification:MovieClip;
    public var m_InQueueNotification:MovieClip;
    
    private var m_SelectHandler:Function;
    private var m_IsSelected:Boolean;
    private var m_IsDisabled:Boolean;
    private var m_Character:Character;
    
    //Constructor
    public function Marker()
    {
        super();
        
        SignalMarkerSelected = new Signal();
        
        m_SelectHandler = null;
        m_IsSelected = false;
        m_IsDisabled = false;
        
        m_InZoneNotification._visible = false;
        m_InQueueNotification._visible = false;
        
        m_Character = Character.GetClientCharacter();
        
        this.onRollOver = RollOverEventHandler;
    }
    
    //Roll Over Event Handler
    private function RollOverEventHandler():Void
    {
        this.onRollOver = null;
        this.onRollOut = RollOutEventHandler;
        this.onMouseDown = MouseDownEventHandler;
            
        this.gotoAndPlay("over");
    }
    
    //Roll Out Event Handler
    private function RollOutEventHandler():Void
    {
        this.onRollOut = null;
        this.onMouseDown = null;
        
        this.onRollOver = RollOverEventHandler;
        this.onEnterFrame = OnEnterFrameEventHandlder;
    }
    
    //Mouse Down Event Handler
    private function MouseDownEventHandler():Void
    {
        this.onRollOut = null;
        this.onMouseDown = null;
        this.onMouseUp = MouseUpEventHandler;
        this.onReleaseOutside = MouseUpEventHandler;
        
        this.gotoAndPlay("down");
    }
    
    //Mouse Up Event Handler
    private function MouseUpEventHandler():Void
    {
        this.onMouseUp = null;
        this.onReleaseOutside = null;
        this.onRollOver = RollOverEventHandler;
        
        if (this.hitTest(_root._xmouse, _root._ymouse, false))
        {
            this.selected = true;
            SignalMarkerSelected.Emit(m_Name);
        }
        else
        {
            this.gotoAndPlay("up");
        }
    }    
    
    //On Enter Frame Event Handler
    private function OnEnterFrameEventHandlder():Void
    {   
        if (this._currentframe > 1)
        {
            this.prevFrame();
        }
        else
        {
            this.onEnterFrame = null;
        }
    }

    //Set Select Handler
    public function set selectHandler(value:Function):Void
    {
        m_SelectHandler = value;
    }
    
    //Get Select Handler
    public function get selectHandler():Function
    {
        return m_SelectHandler;
    }
    
    //Set Selected
    public function set selected(value:Boolean):Void
    {
        if (!m_IsSelected && value)
        {
            gotoAndPlay("select");
            
            this.onRollOver = null;
            this.onRollOut = null;
            this.onMouseDown = null;
            this.onMouseUp = null;
            this.onReleaseOutside = null;
            
            if (m_SelectSound && m_Character != undefined)
            {
                m_Character.AddEffectPackage(SELECT_LOCATION_SOUND_EFFECT);
            }
        }
        
        if (m_IsSelected && !value)
        {
            gotoAndPlay("deselect");
            
            this.onRollOver = RollOverEventHandler;
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
            gotoAndPlay("disabled");
            
            this.onRollOver = null;
            this.onRollOut = null;
            this.onMouseDown = null;
            this.onMouseUp = null;
            this.onReleaseOutside = null;
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
            
            this.onRollOver = RollOverEventHandler;
        }
    }
    
    //Set Disabled
    public function get disabled():Boolean
    {
        return m_IsDisabled;
    }
}