//Imports
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.WorldDomination.MiniMap;
import mx.transitions.easing.*;

//Class
class GUI.WorldDomination.Instructions extends MovieClip
{
    //Constants
    private static var FADE_DURATION:Number = 1;
    private static var CLOSE_BUTTON_SIZE:Number = 29;
    private static var CLOSE_BUTTON_GAP:Number = 12;
    private static var INSTRUCTION_CLOSE_BUTTON:String = "instructionsCloseButton";
    
    //Properties
    public var SignalInstructionsAreVisible:Signal;
    
    private var m_Background:MovieClip;
    private var m_CloseButton:MovieClip;
    private var m_Content:MovieClip;
    
    private var m_InstructionsAreVisible:Boolean;
    
    //Constructor
    public function Instructions()
    {
        super();
        
        m_Content.m_Title.autoSize = "left";
        m_Content.m_Subtitle.autoSize = "left";
        m_Content.m_Body.autoSize = "left";
        
        m_InstructionsAreVisible = false;
        
        SignalInstructionsAreVisible = new Signal();
    }
    
    //Set Size
    private function SetSize(x:Number, y:Number, width:Number, height:Number):Void
    {
        m_Background._x = x;
        m_Background._y = y;
        m_Background._width = width;
        m_Background._height = height;
        
        m_CloseButton = attachMovie("InstructionsCloseButton", "m_CloseButton", getNextHighestDepth());
        m_CloseButton._alpha = 0;
        m_CloseButton._width = m_CloseButton._height = CLOSE_BUTTON_SIZE;
        m_CloseButton._x = m_Background._x + m_Background._width - m_CloseButton._width / 2 - CLOSE_BUTTON_GAP;
        m_CloseButton._y = m_Background._y + m_CloseButton._height / 2 + CLOSE_BUTTON_GAP;
        
        m_CloseButton.name = INSTRUCTION_CLOSE_BUTTON;
        m_CloseButton.SignalButtonSelected.Connect(SlotCloseButtonSelected, this);
        m_CloseButton.enabled = false;
    }
    
    //Set Content
    public function SetContent(title:String, subtitle:String, bodyText:String):Void
    {
        m_Content.m_Underline._width = 2;
        
        m_Content.m_Title.text = title;
        m_Content.m_Subtitle.text = subtitle;
        m_Content.m_Body.text = bodyText;
        
        m_Content._x = m_Background._width / 2 - m_Content._width / 2;
        m_Content._y = m_Background._height / 2 - m_Content._height / 2;
        
        m_Content.m_Underline._width = m_Background._width - m_Content._x;
    }
    
    //Slot Close Button Selected
    private function SlotCloseButtonSelected(name:String):Void
    {
        if (name == INSTRUCTION_CLOSE_BUTTON)
        {
            Hide();
        }
    }
    
    //Show
    public function Show():Void
    {
        if (!m_InstructionsAreVisible)
        {
            m_Content.tweenTo(FADE_DURATION, {_alpha: 100}, Strong.easeOut);
            m_Background.tweenTo(FADE_DURATION, {_alpha: 100}, Strong.easeOut);
            m_CloseButton.tweenTo(FADE_DURATION, {_alpha: 100}, Strong.easeOut);
            
            m_CloseButton.enabled = true;
            
            SignalInstructionsAreVisible.Emit(true);
            
            m_InstructionsAreVisible = true;
        }
    }
    
    //Hide
    public function Hide():Void
    {
        if (m_InstructionsAreVisible)
        {
            m_Content.tweenTo(FADE_DURATION, {_alpha: 0}, Strong.easeOut);
            m_Background.tweenTo(FADE_DURATION, {_alpha: 0}, Strong.easeOut);
            m_CloseButton.tweenTo(FADE_DURATION, { _alpha: 0 }, Strong.easeOut);
            
            m_CloseButton.enabled = false;
            
            SignalInstructionsAreVisible.Emit(false);
            
            m_InstructionsAreVisible = false;
        }
    }
}