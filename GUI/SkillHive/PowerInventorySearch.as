import com.GameInterface.FeatData;
import com.GameInterface.ProjectSpell;
import com.GameInterface.SpellData;
import com.GameInterface.Spell;

class GUI.SkillHive.PowerInventorySearch
{
    private var m_IsPurchased:Boolean;
    private var m_IsAvailable:Boolean;
    private var m_IsLocked:Boolean;
    
    private var m_SearchText:String;
    
    private var m_Category:Number;
    private var m_WeaponFlag:Number;
    
    public static var ALL = 0;
    public static var ACTIVE = 1;
    public static var PASSIVE = 2;
    public static var ACTIVE_ELITE = 3;
    public static var PASSIVE_ELITE = 4;
    public static var ACTIVE_AUXILLIARY = 5;
    public static var PASSIVE_AUXILLIARY = 6;
    
    function PowerInventorySearch()
    {
        m_IsPurchased = false;
        m_IsAvailable = false;
        m_IsLocked = false;
        m_SearchText = "";
        m_WeaponFlag = -1;
        m_Category = ALL;
    }
    
    public function CompareText(featData:FeatData):Boolean
    {
        return (m_SearchText == "" || featData.m_Name.toLowerCase().indexOf(m_SearchText.toLowerCase()) != -1 || featData.m_Desc.toLowerCase().indexOf(m_SearchText.toLowerCase()) != -1)
    }
    
    public function CompareControls(featData:FeatData)
    {
        return (((m_IsPurchased && featData.m_Trained)  || 
                (m_IsAvailable && featData.m_CanTrain) ||
                (m_IsLocked && (!featData.m_CanTrain && !featData.m_Trained))) 
                && featData.m_Cost > 0
                && featData.m_Spell != 0
                && CheckCategory(featData)
                && CheckWeaponType(featData));
    }
    
    
    
    public function SetSearchText(text:String)
    {
        m_SearchText = text;
    }
    
    public function SetPurchased(purchased:Boolean)
    {
        m_IsPurchased = purchased;
    }
    
    public function SetAvailable(available:Boolean)
    {
        m_IsAvailable = available;
    }
    
    public function SetLocked(locked:Boolean)
    {
        m_IsLocked = locked;
    }
    
    public function SetCategory(category:Number)
    {
        m_Category = category;
    }
    
    public function SetWeaponFlag(weaponFlag:Number)
    {
        m_WeaponFlag = weaponFlag;
    }
    
    public function SetAllControls(isSet:Boolean)
    {
        m_IsPurchased = isSet;
        m_IsAvailable = isSet;
        m_IsLocked = isSet;
    }
    
    private function CheckCategory(featData:FeatData)
    {
        if (m_Category == ALL)
        {
            return true;
        }
        switch(featData.m_SpellType)
        {
            case _global.Enums.SpellItemType.ePassiveAbility:
                return (m_Category == PASSIVE);
            case _global.Enums.SpellItemType.eElitePassiveAbility:
                return (m_Category == PASSIVE_ELITE);
            case _global.Enums.SpellItemType.eMagicSpell:
                return (m_Category == ACTIVE);
            case _global.Enums.SpellItemType.eEliteActiveAbility:
                return (m_Category == ACTIVE_ELITE);
            case _global.Enums.SpellItemType.eAuxilliaryActiveAbility:
                return (m_Category == ACTIVE_AUXILLIARY);
            case _global.Enums.SpellItemType.eAuxilliaryPassiveAbility:
                return (m_Category == PASSIVE_AUXILLIARY);
            default:
                return false;
        }
        return false;
    }
    
    private function CheckWeaponType(featData:FeatData)
    {
		if (m_WeaponFlag == -1)
		{
			return true;
		}
		var spellData:SpellData = Spell.GetSpellData(featData.m_Spell);
        var req:Number = spellData.m_WeaponFlags;
        return ((req & m_WeaponFlag) != 0);
    }
}