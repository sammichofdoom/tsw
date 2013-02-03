//Imports
import com.Utils.LDBFormat;
import com.Utils.Signal;

//Class
class GUI.WorldDomination.JoinType extends MovieClip
{
    //Constants
    public static var JOIN_SOLO_SELECTION:Number = 1;
    public static var JOIN_AS_PARTY_SELECTION:Number = 2;
    
    private static var JOIN_SOLO:String = LDBFormat.LDBGetText("WorldDominationGUI", "joinSolo");
    private static var JOIN_AS_PARTY:String = LDBFormat.LDBGetText("WorldDominationGUI", "joinAsParty");
    private static var JOIN_RADIO_GROUP:String = "joinRadioGroup";
   
    private static var DEFAULT_RADIO_BUTTON_WIDTH:Number = 37;
    
    //Properties
    public var SignalJoinTypeSelectionChanged:Signal;
    
    private var m_JoinTypeContainer:MovieClip;
    private var m_JoinSoloRadioButton:MovieClip;
    private var m_JoinAsPartyRadioButton:MovieClip;
    private var m_ControlsArray:Array;
    private var m_CheckInterval:Number;
    private var m_IsDisabled:Boolean;
    private var m_Selection:Number;
    private var m_IsJoinTypeHidden:Boolean;
    
    //Constructor
    public function JoinType()
    {
        super();
        
        SignalJoinTypeSelectionChanged = new Signal();
  
        Init();
    }
    
    //Initialize
    private function Init():Void
    {
        //Radio Buttons
        m_JoinSoloRadioButton = m_JoinTypeContainer.attachMovie("PvPRadioButton", "m_JoinSoloRadioButton", m_JoinTypeContainer.getNextHighestDepth());
        m_JoinSoloRadioButton.group = JOIN_RADIO_GROUP;
        m_JoinSoloRadioButton.textField.autoSize = "left";
        m_JoinSoloRadioButton.label = JOIN_SOLO;
        
        m_JoinAsPartyRadioButton = m_JoinTypeContainer.attachMovie("PvPRadioButton", "m_JoinAsPartyRadioButton", m_JoinTypeContainer.getNextHighestDepth());
        m_JoinAsPartyRadioButton.group = JOIN_RADIO_GROUP;
        m_JoinAsPartyRadioButton.textField.autoSize = "left";
        m_JoinAsPartyRadioButton.label = JOIN_AS_PARTY;
        
        selection = m_Selection;
        
        //Remove Focus Array
        m_ControlsArray = new Array(m_JoinSoloRadioButton, m_JoinAsPartyRadioButton);
                                                
        for (var i:Number = 0; i < m_ControlsArray.length; i++)
        {
            m_ControlsArray[i].addEventListener("click", this, "SelectionEventHandler");
        }
        
        /*
         *  Tragedy strikes!
         * 
         *  Overriding UIComponent() doesn't work, so here I will employ a super ghetto interval check before calling the Layout
         *  function so the precious component can have its beauty sleep before updating its width after the auto-sizing
         *  label has been assigned.
         * 
         */
        
        m_CheckInterval = setInterval(CheckButtonResize, 20, this);
    }
    
    //Selection Event Handler
    private function SelectionEventHandler():Void
    {
        if (m_JoinSoloRadioButton.selected)
        {
            selection = JOIN_SOLO_SELECTION;
        }
        
        if (m_JoinAsPartyRadioButton.selected)
        {
            selection = JOIN_AS_PARTY_SELECTION;
        }
        
        Selection.setFocus(null);
    }
    
    //Check Button Resize
    private function CheckButtonResize(scope:Object):Void
    {
        if (scope.m_JoinAsPartyRadioButton._width != DEFAULT_RADIO_BUTTON_WIDTH)
        {
            clearInterval(scope.m_CheckInterval);
            scope.Layout();
        }
    }
    
    //Layout
    private function Layout(scope:Object):Void
    {
        m_JoinSoloRadioButton._x = 0;
        m_JoinSoloRadioButton._y = 0;

        m_JoinAsPartyRadioButton._x = m_JoinTypeContainer._x + m_JoinTypeContainer._width - m_JoinAsPartyRadioButton._width;
        m_JoinAsPartyRadioButton._y = 0;
    }
    
    //Set Selection
    public function set selection(value:Number):Void
    {
        if (value == JOIN_SOLO_SELECTION)
        {
            m_JoinSoloRadioButton.selected = true;
        }
        
        if (value == JOIN_AS_PARTY_SELECTION)
        {
            m_JoinAsPartyRadioButton.selected = true;
        }
        
        SignalJoinTypeSelectionChanged.Emit(value);
        
        m_Selection = value;
    }
    
    //Get Selection
    public function get selection():Number
    {
        return m_Selection;
    }
    
    //Set Disabled
    public function set disabled(value:Boolean):Void
    {
        m_JoinTypeContainer._alpha = (value) ? 50 : 100;
        
        for (var i:Number = 0; i < m_ControlsArray.length; i++)
        {
            m_ControlsArray[i].disabled = value;
        }
        
        if (value)
        {
            selection = JOIN_SOLO_SELECTION;
        }
        
        m_IsDisabled = value;
    }
    
    //Get Disabled
    public function get disabled():Boolean
    {
        return m_IsDisabled;
    }
    
    //Set Hide Join As Party
    public function set hideJoinAsParty(value:Boolean):Void
    {
        if (value)
        {
            selection = JOIN_SOLO_SELECTION;
        }
        
        m_JoinAsPartyRadioButton._visible = !value;
        m_IsJoinTypeHidden = value;
    }
    
    //Get Hide Join As Party
    public function get hideJoinAsParty():Boolean
    {
        return m_IsJoinTypeHidden;
    }
}