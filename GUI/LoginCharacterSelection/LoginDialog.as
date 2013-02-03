//Imports
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.controls.Button;
import gfx.core.UIComponent;
import mx.transitions.easing.*;

//Class
class GUI.LoginCharacterSelection.LoginDialog extends UIComponent
{
    //Properties
    public var SignalCancelLogin:Signal;
    
    private var m_Button:Button;
    private var m_TimeoutBar:MovieClip;
    private var m_Text:TextField;
    
    private var m_IsConfigured:Boolean;
    private var m_TimerRunning:Boolean;
    private var m_SidePadding:Number
    private var m_DelayTimestamp:Number;
    private var m_TimeoutTimestamp:Number;
    private var m_TimeoutSeconds:Number;
    private var m_CurrentFrame:Number;

    private var m_CurrentText:String;
    private var m_CurrentButtonLabel:String;
    
    //Constructor
    public function LoginDialog()
    {
        super();
        
        m_IsConfigured = false;
        SignalCancelLogin = new Signal();
        m_TimerRunning = false;
        m_DelayTimestamp = 0;
        m_TimeoutTimestamp = 0;
        m_TimeoutSeconds = 0;
        m_SidePadding = 10;
        m_TimeoutBar._visible = false;
        m_CurrentButtonLabel = LDBFormat.LDBGetText("GenericGUI", "Cancel");
        m_CurrentText = "";
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_Button.label = m_CurrentButtonLabel;
        m_Button.addEventListener("click", this, "SlotCancel");

        m_Text.text = m_CurrentText;
        
        m_IsConfigured = true;
        
        Layout();
    }
    
    //Slot Cancel
    private function SlotCancel()
    {
        SignalCancelLogin.Emit();
    }
    
    //Set Text
    public function SetText(text:String):Void
    {
        m_CurrentText = text;

        if (m_IsConfigured)
        {
            m_Text.text = text;
            
            Layout();
        }
    }
    
    //Set Button Text
    public function SetButtonText(text:String):Void
    {
        m_CurrentButtonLabel = text;
        if (m_IsConfigured)
        {
            m_Button.label = text;
        }
    }
    
    //Set Timeout
    public function SetTimeout(timeoutSeconds:Number, delaySeconds:Number):Void
    {
        if (timeoutSeconds > 0)
        {
            var currentDate:Date = new Date();
            
            m_TimeoutSeconds = timeoutSeconds;
            m_TimeoutTimestamp = Math.round(currentDate.getTime() + timeoutSeconds * 1000);
            m_DelayTimestamp = Math.round(currentDate.getTime() + delaySeconds * 1000);
            
            if (delaySeconds > 0)
            {
                m_TimeoutBar._visible = false;
            }
            else
            {
                m_TimeoutBar._visible = true;
            }
            
            Layout();
        }
        else
        {
            StopTimer();
        }
    }
    
    //Stop Timer
    public function StopTimer():Void
    {
        m_TimerRunning = false;
        m_TimeoutBar._visible = false;
        
        Layout();
    }
    
    //Layout
    private function Layout():Void
    {
        if (!m_IsConfigured)
        {
            return;
        }
        
        var y:Number = m_SidePadding;
        var maxWidth:Number = 0;
        
        m_Text.y = y;
        maxWidth = Math.max(maxWidth, m_Text._width);
        y += m_Text._height;
        
        if (m_TimeoutBar._visible)
        {
            y += 10;
            m_TimeoutBar._y = y;
            y += m_TimeoutBar._height + 10;
            maxWidth = Math.max(maxWidth, m_TimeoutBar._width);
        }
        else
        {
            m_TimeoutBar._y = 0;
        }
        
        m_Button._y = y;
        y += m_Button._height;
        maxWidth = Math.max(maxWidth, m_Button._width);
        
        var maxWidth:Number = maxWidth + m_SidePadding * 2;
        var maxHeight:Number = y + m_SidePadding;
        
        m_Text._x = maxWidth / 2 - m_Text._width / 2;
        m_TimeoutBar._x = maxWidth / 2 - m_TimeoutBar._width / 2;
        m_Button._x = maxWidth / 2 - m_Button._width / 2;
        
        com.Utils.Draw.DrawRectangle(this, 0, 0, maxWidth, maxHeight, 0x333333, 90, [6, 6, 6, 6], 2, 0xFFFFFF, 100); 
        
        _x = Stage["visibleRect"].x + Stage.width / 2 - _width/2; 
        _y = Stage["visibleRect"].y + Stage.height / 2 - _height/2; 
    }
    
    //On Enter Frame
    private function onEnterFrame():Void
    {
        if (m_TimerRunning)
        {
            var currentDate:Date = new Date();
            var currentTimestamp = Math.round(currentDate.getTime());
			
            if (currentTimestamp < m_DelayTimestamp)
            {
                //Do nothing?
            }
            else if (currentTimestamp < m_TimeoutTimestamp)
            {
                if (!m_TimeoutBar._visible)
                {
                    m_TimeoutBar._visible = true;
                    
                    Layout();
                }
                
                var targetFrame:Number = Math.round((m_TimeoutTimestamp - currentTimestamp) / 300000 * 100);
                
                if (targetFrame != m_CurrentFrame)
                {
                    m_CurrentFrame = targetFrame;
                    m_TimeoutBar.gotoAndStop(targetFrame);
                }
            }
            else
            {
                SlotCancel();
            }
        }
    }
}