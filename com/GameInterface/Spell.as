import com.GameInterface.SpellBase;
class com.GameInterface.Spell extends SpellBase
{
	public static function IsPassiveSpell(spellId:Number):Boolean
	{
		return m_PassivesList.hasOwnProperty(spellId.toString());
	}
	
	public static function IsActiveSpell(spellId:Number):Boolean
	{
		return m_SpellList.hasOwnProperty(spellId.toString());
	}
    
    public static function GetNextFreePassiveSlot()
    {
        for (var i:Number = 0; i < 8; i++)
        {
            if (SpellBase.GetPassiveAbility(i) == 0)
            {
                return i;
            }
        }
    }
}
