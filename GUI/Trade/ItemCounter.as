//Imports
import com.Utils.Colors;
import gfx.core.UIComponent;
import gfx.controls.TextInput;
import gfx.controls.Button;

//Class
class GUI.Trade.ItemCounter extends UIComponent
{
    //Constants
    public static var MAX_VALUE:Number = 999999999;
    
    private static var ON_COLOR:Number = 0xFFFFFF;
    private static var OFF_COLOR:Number = 0x999999;
    private static var STARTING_INTERVAL:Number = 200;
    private static var MINIMUM_INTERVAL:Number = 40;
    private static var STEP_INTERVAL:Number = 100;
    
    //Properties
    public var SignalValueChanged:com.Utils.Signal;
    public var m_TextInput:TextInput;
    
    private var m_Icon:MovieClip;
    private var m_IconName:String;
    private var m_Amount:Number;
    private var m_UpArrow:Button;
    private var m_DownArrow:Button;
    private var m_Background:MovieClip;
    private var m_MaxAmount:Number;
    private var m_MinAmount:Number;
    private var m_Interval:Number;
    private var m_IntervalDelay:Number;
    private var m_IntervalTarget:MovieClip;
    private var m_IsDisabled:Boolean;
    
    //Constructor
    public function ItemCounter()
    {
        super();
        m_Amount = 0;
        SignalValueChanged = new com.Utils.Signal();
        
        m_IntervalDelay = STARTING_INTERVAL;
    }    
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_TextInput.textField.restrict = "0-9";
        m_TextInput.text = m_Amount.toString();
        m_TextInput.addEventListener("textChange", this, "TextChangedEventHandler");
        
        m_UpArrow.disableFocus = true;
        m_UpArrow.addEventListener("press", this, "ArrowMouseDownEventHandler");
        m_UpArrow.addEventListener("click", this, "ArrowClickEventHandler");
        m_UpArrow.addEventListener("dragOut", this, "ArrowClickEventHandler");
        
        m_DownArrow.disableFocus = true;
        m_DownArrow.addEventListener("press", this, "ArrowMouseDownEventHandler");
        m_DownArrow.addEventListener("click", this, "ArrowClickEventHandler");
        m_DownArrow.addEventListener("dragOut", this, "ArrowClickEventHandler");
    }
    
    //Text Changed Event Handler
    private function TextChangedEventHandler():Void
    {
        m_Amount = parseInt(m_TextInput.text, 10);
       
        if (m_Amount > m_MaxAmount)
        {
            amount = m_MaxAmount;
        }
        else if (m_Amount < m_MinAmount)
        {
            amount = m_MinAmount;
        }
        else if (isNaN(m_Amount) || m_Amount == 00)
        {
            amount = m_MinAmount;
            
            TakeFocus();            
        }
        else
        {
            SignalValueChanged.Emit(m_Amount);            
        }
    }
    
    //Arrows Mouse Down Event Handler
    private function ArrowMouseDownEventHandler(event:Object):Void
    {
        m_IntervalTarget = event.target;
        
        switch (m_IntervalTarget)
        {
            case m_UpArrow:     if (amount < m_MaxAmount)
                                {
                                    amount += STEP_INTERVAL;
                                }
                                
                                break;
                                
            case m_DownArrow:   if (amount > m_MinAmount)
                                {
                                    amount -= STEP_INTERVAL;
                                }
        }
        
        m_Interval = setInterval(DecreaseInterval, m_IntervalDelay, this);
        TakeFocus();
    }
    
    //Arrows Click Event Handler
    private function ArrowClickEventHandler(event:Object):Void
    {
        clearInterval(m_Interval);
        m_IntervalDelay = STARTING_INTERVAL;
    }

    //Decrease Interval
    private function DecreaseInterval(scope:Object):Void
    {
        scope.m_IntervalDelay = Math.max(MINIMUM_INTERVAL, scope.m_IntervalDelay -= 20);
        clearInterval(scope.m_Interval);
        scope.ArrowMouseDownEventHandler({target: scope.m_IntervalTarget});
    }
    
    //Show Background
    public function ShowBackground(show:Boolean):Void
    {
        m_Background._visible = show;
    }

    //Take Focus
    public function TakeFocus():Void
    {
        Selection.setFocus(m_TextInput.textField);
        Selection.setSelection(0, m_TextInput.text.length);
    }
    
    //Set Icon
    public function set icon(value:String):Void
    {
        m_IconName = value;
        
        m_Icon = attachMovie(m_IconName, "m_Icon", getNextHighestDepth());
        
        if (m_Icon._height > m_TextInput._height - 2)
        {
            m_Icon._width = m_Icon._height = m_TextInput._height - 2;
        }

        m_Icon._y = m_Background._height / 2 - m_Icon._height / 2 + 1;
        m_Icon._x = m_Icon._y - 1;
            
        m_Icon.disableFocus = true;
    }
    
    //Get Icon
    public function get icon():String
    {
        return m_IconName;
    }
    
    //Set Amount
    public function set amount(value:Number):Void
    {
        m_Amount = Math.max(m_MinAmount, Math.min(value, m_MaxAmount)); 
        m_TextInput.text = m_Amount.toString();
        SignalValueChanged.Emit(m_Amount);
    }
    
    //Get Amount
    public function get amount():Number
    {
        return m_Amount;
    }
    
    //Set Max Amount
    public function set maxAmount(value:Number):Void
    {
        m_MaxAmount = value;
    }
    
    //Get Max Amount
    public function get maxAmount():Number
    {
        return m_MaxAmount;
    }
    
    //Set Min Amount
    public function set minAmount(value:Number):Void
    {
        m_MinAmount = value;
    }
    
    //Get Min Amount
    public function get minAmount():Number
    {
        return m_MinAmount;
    }
    
    //Set Disabled
    public function set disabled(value:Boolean):Void
    {
        m_UpArrow.disabled = m_DownArrow.disabled = m_TextInput.disabled = m_IsDisabled = value;
        
        if (value)
        {
            Selection.setFocus(null);            
        }
        else
        {
            TakeFocus();
        }
    }
    
    //Get Disabled
    public function get disabled():Boolean
    {
        return m_IsDisabled;
    }
}