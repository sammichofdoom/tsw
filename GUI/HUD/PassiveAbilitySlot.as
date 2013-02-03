import GUI.HUD.AbilitySlot;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.*;
import com.GameInterface.Spell;

class GUI.HUD.PassiveAbilitySlot extends GUI.HUD.AbilitySlot 
{
    
	public function PassiveAbilitySlot(p_mc:MovieClip, p_id:Number)
	{
		super(p_mc, p_id);
        m_DragType = "shortcutbar/passiveability";
	}
        
    private function OnMouseUp() : Void
    {
        m_WasHit = false;
    }
    
    function GetTooltipData():TooltipData
    {
        var tooltipData:TooltipData = TooltipDataProvider.GetPassiveTooltip( m_SlotId );
        return tooltipData;
    }
	
	public function SlotItemDroppedOnDesktop()
    {   
		Spell.UnequipPassiveAbility(m_SlotId);
    }
}