import com.Utils.LDBFormat;
import gfx.controls.Button;
import com.Utils.Signal;
import gfx.core.UIComponent;

class GUI.CharacterSheet.GearManagerErrorConsoleComponent extends UIComponent 
{
    private var m_Headline:TextField;
    private var m_Body:TextField;
    private var m_OKButton:Button;
    
    public var SignalClicked:Signal;
    
    public function GearManagerErrorConsoleComponent()
    {
        SignalClicked = new Signal();
    }
    
    public function configUI()
	{
        super.configUI();
        
        m_Headline.text = LDBFormat.LDBGetText("CharStatSkillGUI", "ErrorHeadline");
        m_OKButton.label = LDBFormat.LDBGetText("GenericGUI", "Ok");
        m_OKButton.addEventListener("click", this, "CloseComponentHandler");
    }
    
    public function SetError(errorCode:Number)
    {
        m_Body.text = LDBFormat.LDBGetText("CharStatSkillGUI", "Error_"+errorCode);
    }
    
    private function CloseComponentHandler(event:Object)
    {
        SignalClicked.Emit();
    }
}