
import GUI.HUD.AbilityBase

class GUI.HUD.PassiveAbility extends AbilityBase
{
    private var m_EliteFrame:MovieClip;

    public function PassiveAbility()
    {
        super();
        init();
    }
    
    public function init()
    {
        SetBackgroundColor(true);
        m_EliteFrame._visible = false;
		m_AuxilliaryFrame._visible = false;
    }
}