import com.Components.MultiColumnList.MCLItem;

import com.GameInterface.SpellData;
import com.GameInterface.Spell;
import com.GameInterface.FeatData

import com.Utils.LDBFormat;

class com.Components.FeatList.MCLItemFeat extends MCLItem
{
	public static var FEAT_COLUMN_ICON				= 0;
	public static var FEAT_COLUMN_ICON_WITH_SYMBOL	= 1;
	public static var FEAT_COLUMN_NAME				= 2;
	public static var FEAT_COLUMN_CATEGORY			= 3;
	public static var FEAT_COLUMN_TYPE				= 4;
	public static var FEAT_COLUMN_SUBTYPE			= 5;
    public static var FEAT_COLUMN_EFFECT    		= 6;
    public static var FEAT_COLUMN_COST      		= 7;
	
	public static var s_SubTypesArray = [	LDBFormat.LDBGetText("SkillhiveGUI", "SubType_Blast"), LDBFormat.LDBGetText("SkillhiveGUI", "SubType_Strike"), 
											LDBFormat.LDBGetText("SkillhiveGUI", "SubType_Focus"), LDBFormat.LDBGetText("SkillhiveGUI", "SubType_Frenzy"), 
											LDBFormat.LDBGetText("SkillhiveGUI", "SubType_Chain"), LDBFormat.LDBGetText("SkillhiveGUI", "SubType_Burst")];
	public static var s_EffectsArray =	[	LDBFormat.LDBGetText("SkillhiveGUI", "Effect_Critical"), LDBFormat.LDBGetText("SkillhiveGUI", "Effect_Penetration"), 
											LDBFormat.LDBGetText("SkillhiveGUI", "Effect_Evade")];
	
	public var m_FeatData:FeatData
	
	public var m_SubType:String;
	public var m_Effect:String;
	public var m_Category:String;
	public var m_WeaponRequirement:Number
	public var m_WeaponType:String
	
	public function MCLItemFeat(featData:FeatData)
	{
		super(featData.m_Id);

		m_FeatData = featData;
		
		var spellData:SpellData = Spell.GetSpellData(m_FeatData.m_Spell);
        m_WeaponRequirement = spellData.m_WeaponFlags;
		m_WeaponType = LDBFormat.LDBGetText("WeaponTypeGUI", m_WeaponRequirement)
		//Update subtype and effect until we get real data from systems
		UpdateSubTypes();
		UpdateEffects();
		
		UpdateCategory();
		
	}
	
	public function Compare(sortColumn:Number, item:MCLItem)
	{
		var otherItem:MCLItemFeat = MCLItemFeat(item);
		
		switch(sortColumn)
		{
		case FEAT_COLUMN_NAME:
			{
				return CompareString(m_FeatData.m_Name, otherItem.m_FeatData.m_Name);
			}
		case FEAT_COLUMN_CATEGORY:
			{
				return CompareString(m_Category, otherItem.m_Category);
			}
		case FEAT_COLUMN_TYPE:
			{
				return CompareString(m_WeaponType, otherItem.m_WeaponType);
			}
		case FEAT_COLUMN_SUBTYPE:
			{
				return CompareString(m_SubType, otherItem.m_SubType);
			}
        case FEAT_COLUMN_EFFECT:
            {
                return CompareString(m_Effect, otherItem.m_Effect);
            }
        case FEAT_COLUMN_COST:
            {
                return CompareNumber(m_FeatData.m_Cost, otherItem.m_FeatData.m_Cost);
            }
		}
		
		return super.Compare(sortColumn, item);
	}
	
	private function UpdateSubTypes()
    {
        var subTypes:String = "";
        for (var i:Number = 0; i < s_SubTypesArray.length; i++)
        {
            if (m_FeatData.m_Desc.toLowerCase().indexOf(s_SubTypesArray[i].toLowerCase()) != -1)
            {
                if (subTypes.length > 0)
                {
                    subTypes += ", ";
                }
                subTypes += s_SubTypesArray[i];
            }
        }
        m_SubType = subTypes;
    }
	
	private function UpdateEffects()
    {
        var effects:String = "";
        for (var i:Number = 0; i < s_EffectsArray.length; i++)
        {
            if (m_FeatData.m_Desc.toLowerCase().indexOf(s_EffectsArray[i].toLowerCase()) != -1)
            {
                if (effects.length > 0)
                {
                    effects += ", ";
                }
                effects += s_EffectsArray[i];
            }
        }
        m_Effect = effects;
    }
	
	private function UpdateCategory()
    {
        switch(m_FeatData.m_SpellType)
        {
            case _global.Enums.SpellItemType.ePassiveAbility:
				m_Category =  LDBFormat.LDBGetText("Gamecode", "Passive");
				break;
            case _global.Enums.SpellItemType.eElitePassiveAbility:
				m_Category = LDBFormat.LDBGetText("Gamecode", "PassiveElite");
				break;
            case _global.Enums.SpellItemType.eMagicSpell:
				m_Category = LDBFormat.LDBGetText("Gamecode", "Active");
				break;
            case _global.Enums.SpellItemType.eEliteActiveAbility:
				m_Category = LDBFormat.LDBGetText("Gamecode", "ActiveElite");
				break;
            case _global.Enums.SpellItemType.eAuxilliaryActiveAbility:
				m_Category = LDBFormat.LDBGetText("Gamecode", "ActiveAuxilliary");
				break;
            case _global.Enums.SpellItemType.eAuxilliaryPassiveAbility:
				m_Category = LDBFormat.LDBGetText("Gamecode", "PassiveAuxilliary");
				break;
            default:
				m_Category = "";
        }
    }
    
}