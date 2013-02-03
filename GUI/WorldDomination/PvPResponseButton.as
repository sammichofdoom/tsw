//Class
class GUI.WorldDomination.PvPResponseButton extends MovieClip
{
    //Constants
    private static var UNSELECTED_FRAME:Number = 1;
    private static var SELECTED_FRAME:Number = 41;
    
    //Properties
    private var m_IsSelected:Boolean;
    private var m_Label:TextField;
    private var m_IsDisabled:Boolean;
    
    //Constructor
    public function PvPResponseButton()
    {
        super();
        
        m_IsSelected = false;
        
        onRollOver = RollOverEventHandler;
    }
    
    //Roll Over Event Handler
    private function RollOverEventHandler():Void
    {
        onRollOver = null;
        onRollOut = RollOutEventHandler;
        onMouseDown = MouseDownEventHandler;

        gotoAndPlay((!m_IsSelected) ? "over" : "selected_over");
    }
    
    //Roll Out Event Handler
    private function RollOutEventHandler():Void
    {
        onRollOut = null;
        onMouseDown = null;
        onRollOver = RollOverEventHandler;
        onEnterFrame = OnEnterFrameEventHandlder;
    }
    
    //Mouse Down Event Handler
    private function MouseDownEventHandler():Void
    {
        onRollOut = null;
        onMouseDown = null;
        onMouseUp = MouseUpEventHandler;
        onReleaseOutside = MouseUpEventHandler;
        
        gotoAndPlay((!m_IsSelected) ? "down" : "selected_down");
    }
    
    //Mouse Up Event Handler
    private function MouseUpEventHandler():Void
    {
        if (hitTest(_root._xmouse, _root._ymouse, false))
        {
            selected = !m_IsSelected;
        }
        else
        {
            onMouseUp = null;
            onReleaseOutside = null;
            onRollOver = RollOverEventHandler;
        
            gotoAndPlay((!m_IsSelected) ? "up" : "selected_up");
        }
    }    
    
    //On Enter Frame Event Handler
    private function OnEnterFrameEventHandlder():Void
    {   
        if (!m_IsSelected)
        {
            (_currentframe > UNSELECTED_FRAME) ? prevFrame() : delete onEnterFrame;
        }
        else
        {
            (_currentframe > SELECTED_FRAME) ? prevFrame() : delete onEnterFrame;
        }
    }
    
    //Set Selected
    public function set selected(value:Boolean):Void
    {
        if (!m_IsSelected && value)
        {
            gotoAndPlay("select");
        }
        
        if (m_IsSelected && !value)
        {
            gotoAndPlay("deselect");
        }

        m_IsSelected = value;
        
        onMouseUp = null;
        onReleaseOutside = null;
        onRollOver = RollOverEventHandler;
    }
    
    //Get Selected
    public function get selected():Boolean
    {
        return m_IsSelected;
    }
    
    //Set Label
    public function SetLabel(value:String, selected:Boolean, textColor:Number):Void
    {
        gotoAndStop((selected) ? SELECTED_FRAME : UNSELECTED_FRAME);
        m_IsSelected = selected;
        m_Label.text = value;
        m_Label.textColor = textColor;
    }
    
    //Set Disabled
    public function set disabled(value:Boolean):Void
    {
        onRollOver = (value) ? null : RollOverEventHandler;
        
        m_IsDisabled = value;
    }
    
    //Get Disabled
    public function get disabled():Boolean
    {
        return m_IsDisabled;
    }
}