//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.LoreBase;
import com.Utils.LDBFormat;
import gfx.core.UIComponent;
import gfx.controls.Button;
import flash.geom.Rectangle;

//Class
class GUI.WorldDomination.Header extends UIComponent
{
    //Constants
    private static var TITLE:String = LDBFormat.LDBGetText("WorldDominationGUI", "secretWar");
    private static var TEXT_SIZE_PERCENTAGE:Number = 0.55;
    private static var MAX_CLOSE_BUTTON_SIZE:Number = 22;
    private static var CLOSE_BUTTON_SCALE:Number = 0.6;
    private static var UNDERLINE_ALPHA:Number = 50;
    
    //Properties
    private var m_Background:MovieClip;
    private var m_TitleTextField:TextField;
    private var m_HelpButton:Button;
    private var m_CloseButton:Button;
    private var m_Underline:MovieClip;
    
    //Constructor
    public function Header()
    {
        super();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_CloseButton.addEventListener("click", this, "CloseWorldDomination");
        m_HelpButton.addEventListener("click", this, "HelpButtonCLickedEventHandler");
        
        Layout();
    }
    
    //Layout
    public function Layout():Void
    {
        //Background
        m_Background._width = _parent.STAGE.width;
        m_Background._height = _parent.STAGE.height * _parent.HEADER_HEIGHT_PERCENTAGE;

        //Title Text Field
        var m_TitleTextFormat:TextFormat = new TextFormat(); 
        m_TitleTextFormat.size = Math.round(m_Background._height * TEXT_SIZE_PERCENTAGE); 

        m_TitleTextField.autoSize = "left";
        m_TitleTextField._x = m_Background._x + 8;
        m_TitleTextField._y = m_Background._y + 3;
        m_TitleTextField.text = TITLE;
        m_TitleTextField.setTextFormat(m_TitleTextFormat); 
        
        //Close Button
        m_CloseButton._width = m_CloseButton._height = Math.min(MAX_CLOSE_BUTTON_SIZE, m_Background._height * CLOSE_BUTTON_SCALE);
        m_CloseButton._x = m_Background._width - m_CloseButton._width - (m_Background._height - m_CloseButton._height) / 2;
        m_CloseButton._y = m_Background._y + (m_Background._height - m_CloseButton._height) / 2 - 1;
        
        //Help Button
        m_HelpButton._width = m_HelpButton._height = m_CloseButton._width;
        m_HelpButton._x = m_CloseButton._x - m_HelpButton._width - (m_Background._height - m_CloseButton._height) / 2;
        m_HelpButton._y = m_CloseButton._y;
        
        //Underline
        m_Underline.lineStyle(2, 0xFFFFFF, UNDERLINE_ALPHA, true, "none")
        m_Underline.moveTo(0, 0);
        m_Underline.lineTo(m_Background._width, 0);
        m_Underline._x = 0;
        m_Underline._y = m_Background._height - 1;
    }
    
    //Help Button Clicked Event Handler
    private function HelpButtonCLickedEventHandler():Void
    {
        Selection.setFocus(null);
        
        LoreBase.OpenTag(5219)
    }
    
    //Close World Domination
    public function CloseWorldDomination():Void
    {
        DistributedValue.SetDValue("pvp_minigame_window", false);
    }
}