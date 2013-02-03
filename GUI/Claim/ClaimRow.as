//Imports
import mx.utils.Delegate;
import com.Utils.Colors;
import com.Utils.GlobalSignal;
import com.Utils.Signal;

//Class
class GUI.Claim.ClaimRow extends MovieClip
{
    //Constants
    private static var SELECTED_COLOR:Number = 0xB27C26;
    private static var DESELECTED_COLOR:Number = 0x313131;
    
    //Properties
    private var m_Item:MovieClip;
    private var m_Name:MovieClip;
    private var m_Recurrent:MovieClip;
    private var m_Expires:MovieClip;
    private var m_Origin:MovieClip;
    
    private var m_CategoriesArray:Array;
    
    private var m_IsSelected:Boolean;
    private var m_ID:Number;
    
    public var SignalSelectedClaimRow:Signal;
    
    //Constructor
    public function ClaimRow()
    {
        super();

        m_CategoriesArray = new Array(m_Item, m_Name, m_Recurrent, m_Expires, m_Origin);
        
        onRelease = Delegate.create(this, ReleaseEventHandler);
        
        GlobalSignal.SignalClaimRowSelected.Connect(SlotClaimRowSelected, this);
        SignalSelectedClaimRow = new Signal();
        
        m_IsSelected = false;
    }
    
    //Release Event Handler
    private function ReleaseEventHandler():Void
    {
        if (!m_IsSelected)
        {
            GlobalSignal.SignalClaimRowSelected.Emit();
            SignalSelectedClaimRow.Emit(m_ID);
            
            m_IsSelected = true;
            
            for (var i:Number = 0; i < m_CategoriesArray.length; i++)
            {
                Colors.ApplyColor(m_CategoriesArray[i].m_Background, 0xB27C26)
            }          
        }
    }
    
    //Slot Claim Row Selected
    public function SlotClaimRowSelected():Void
    {
        if (m_IsSelected)
        {
            m_IsSelected = false;
            
            for (var i:Number = 0; i < m_CategoriesArray.length; i++)
            {
                Colors.ApplyColor(m_CategoriesArray[i].m_Background, 0x313131)
            }
        }      
    }
    
    //Get Selected
    public function get selected():Boolean
    {
        return m_IsSelected;
    }
    
    //Set ID
    public function set ID(value:Number):Void
    {
        m_ID = value;
    }
    
    //Get ID
    public function get ID():Number
    {
        return m_ID;
    }
}