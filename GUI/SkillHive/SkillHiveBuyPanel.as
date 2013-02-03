import com.Utils.Signal;
import gfx.core.UIComponent;
import gfx.controls.Button;
import mx.utils.Delegate;
import com.GameInterface.Game.Character;
import com.Utils.LDBFormat;
import com.GameInterface.Spell;
import com.GameInterface.Game.Shortcut;
dynamic class GUI.SkillHive.SkillHiveBuyPanel extends UIComponent
{
    public var SignalBuyPressed;
	public var SignalEquipPressed;
	public var SignalUnEquipPressed;
	public var SignalRefundPressed;
    
	
	var m_Character:Character;
	var m_Cost:Number;
	var m_SP:MovieClip;
	var m_FirstButton:Button;
	var m_SecondButton:Button;
    
    var m_Initialized:Boolean;
    var m_IsTrained:Boolean;
    var m_IsEquipped:Boolean;
    var m_IsRefundable:Boolean;
	var m_ShouldUnequip:Boolean;
    
    function SkillHiveBuyPanel()
    {
        super();
        
		SignalBuyPressed = new Signal();
		SignalEquipPressed = new Signal();
		SignalUnEquipPressed = new Signal();
		SignalRefundPressed = new Signal();
        	
        m_Initialized = false;
        m_IsTrained = false;
        m_IsRefundable = false;
		m_IsEquipped = false;
		m_ShouldUnequip = false;
		
		m_SP.m_SkillPointsLabel.text = LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsAbbreviation");
    }
    
    function configUI()
    {
		super.configUI();
		
        m_FirstButton.autoSize = "left";
        m_SecondButton.autoSize = "left";
        
        m_FirstButton.addEventListener("click", this, "SlotFirstButtonClicked");
        m_SecondButton.addEventListener("click", this, "SlotSecondButtonClicked");
		
		m_FirstButton.disableFocus = true;
		m_SecondButton.disableFocus = true;
        
        m_Initialized = true;
        UpdateLayout();
		
		_global.setTimeout(Delegate.create(this, UpdateButtons), 1);
    }
    
    
    function SlotFirstButtonClicked(event:Object)
    {
        if (!m_IsTrained)
        {
            if (m_Character.GetTokens(1) >= m_Cost)
            {
                BuyAbility();
            }
        }
        else
        {
            EquipAbility();
        }
    }
    
    function SlotSecondButtonClicked(event:Object)
    {
        if (m_IsRefundable)
        {
            RefundAbility();
        }
    }
	
	function SetData(character:Character, cost:Number)
	{
		m_Character = character;
		m_Cost = cost;
	}
	
	function SetShouldUnequip(unequip:Boolean)
	{
		m_ShouldUnequip = unequip;
	}
    
    function Update(isTrained:Boolean, isRefundable:Boolean, spellId:Number)
    {
        m_IsTrained = isTrained;
        m_IsRefundable = isRefundable;
		
		if (Spell.IsPassiveSpell(spellId))
        {
			m_IsEquipped = Spell.IsPassiveEquipped(spellId);
        }
        else if (Spell.IsActiveSpell(spellId))
        {
			m_IsEquipped = Shortcut.IsSpellEquipped(spellId);
        }
		
        if (m_Initialized)
        {
            UpdateLayout();
        }
    }
    
    function UpdateLayout()
    {
		if (!m_IsTrained)
        {
            m_SP._visible = true;
			if (m_Character.GetTokens(1) >= m_Cost)
			{
				m_FirstButton._visible = true;
				m_FirstButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "BuyAbility");;
			}
			else
			{
				m_FirstButton._visible = false;
			}
        }
        else
        {
            m_SP._visible = false;
			m_FirstButton._visible = true;
			if (m_IsEquipped)
			{
				if (m_ShouldUnequip)
				{
					m_FirstButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "UnEquipAbility");
				}
				else
				{
					m_FirstButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "ReEquipAbility");
				}
			}
			else
			{
				m_FirstButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "EquipAbility");
			}
        }
        
        if (m_IsTrained && m_IsRefundable)
        {
            m_SecondButton.label = LDBFormat.LDBGetText( "SkillhiveGUI", "RefundAbility");
            m_SecondButton._visible = true;
        }
        else
        {
            m_SecondButton._visible = false;
        }
		m_SecondButton._x = m_FirstButton._x + m_FirstButton.width + 5;
    }
	
	function UpdateButtons()
	{
		m_SecondButton._x = m_FirstButton._x + m_FirstButton.width + 5;
	}
    
    function BuyAbility()
    {
        SignalBuyPressed.Emit();
    }
    
    function RefundAbility()
    {
        SignalRefundPressed.Emit();    
    }
    
    function EquipAbility()
    {
		if (m_IsEquipped && m_ShouldUnequip)
		{
			SignalUnEquipPressed.Emit();
		}
		else
		{
			SignalEquipPressed.Emit();  
		}
    }
}