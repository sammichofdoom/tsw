import com.GameInterface.Game.Character;
import com.Utils.Signal;
import mx.utils.Delegate;
import com.Utils.LDBFormat;

class GUI.SkillHive.BuyButton extends MovieClip
{
    private var m_Character:Character;
    private var m_Cost:Number;
    
    private var m_SkillPointsLabel:TextField;
    private var m_SkillPointsText:TextField;
    private var m_Background:MovieClip;
    
    public var SignalPressed:Signal;
    
    function BuyButton()
    {
        super();
        SignalPressed = new Signal();
        m_Cost = 0;
		m_SkillPointsLabel.text = LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsAbbreviation");
    }
    
    public function SetCharacter(character:Character)
    {
        m_Character = character;
        if (m_Cost > 0)
        {
            UpdateColors();
        }
    }
    
    function onRollOver()
    {
        
    }
    
    function onRollOut()
    {
        
    }

    function onRelease()
    {
        SignalPressed.Emit();
    }
    
    public function SetCost(cost:Number)
    {
        m_Cost = cost;
        m_SkillPointsText.text = ""+cost;
        if (m_Character != undefined)
        {
            UpdateColors();
        }
    }
    
    private function UpdateColors()
    {
        if (m_Cost <= m_Character.GetTokens(1))
        {
            m_SkillPointsText.textColor = 0x00FF33;
            m_SkillPointsLabel.textColor = 0x00FF33;
        }
        else
        {
            m_SkillPointsText.textColor = 0xFF6040;
            m_SkillPointsLabel.textColor = 0xFF6040;
        }
    }
    
    public function toString():String
    {
        return "BuyButton";
    }
}