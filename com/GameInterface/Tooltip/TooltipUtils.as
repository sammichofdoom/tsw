import com.GameInterface.Log;
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.GameInterface.ACGItem;

class com.GameInterface.Tooltip.TooltipUtils 
{
    public static function CreateWeaponRequirementsIcon(parentClip:MovieClip, weaponRequirementsFlag:Number, initObject:Object):Boolean
    {
        var weapons:Array = GetWeaponRequirementIcons(weaponRequirementsFlag);
        
        return CreateItemIcon(parentClip, weapons, initObject);
    }
    
    public static function CreateItemIconFromType(parentClip:MovieClip, weaponType:Number, initObject:Object):Boolean
    {
        var weapon:String = GetWeaponRequirementIconNameFromType(weaponType);
        var weapons:Array = [weapon];
        return CreateItemIcon(parentClip, weapons, initObject);
    }
    
    private static function CreateItemIcon(parentClip:MovieClip, itemArray:Array, initObject:Object):Boolean
    {
		if (itemArray[0] != undefined)
		{
			if (itemArray.length == 1)
			{
				parentClip.attachMovie(itemArray[0], "i_WeaponRequirement", parentClip.getNextHighestDepth(), initObject);
				return true;
			}
			else if (itemArray.length > 1)
			{
				//TODO: Create a new icon consisting of all of them (only first for now)
				Log.Info2("Tooltip", "Several weapons!!!");
				parentClip.attachMovie(itemArray[0], "i_WeaponRequirement", parentClip.getNextHighestDepth(),initObject);
				return true;
			}
			else
			{
				return false;
			}
		}
    }
    
    public static function GetWeaponRequirementString(spellRequirementsFlag:Number):String
    {
        var weapons:String = "";
        for (var i:Number = 0; i < _global.Enums.WeaponTypeFlag.e_WeaponType_Count; i++)
        {
            var flagValue = 1 << i;
            if (spellRequirementsFlag & flagValue)
            {
                if(weapons.length > 0)
                {
                    weapons += " or ";
                }
                var weapon:String = LDBFormat.LDBGetText("WeaponTypeGUI", flagValue);
				
				switch(flagValue)
				{
					case _global.Enums.WeaponTypeFlag.e_WeaponType_Handgun:
						weapons += LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "TooltipRequires"), weapon);
						break;
					case _global.Enums.WeaponTypeFlag.e_WeaponType_AssaultRifle:
					case _global.Enums.WeaponTypeFlag.e_WeaponType_Fire:
						weapons += LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "TooltipRequiresAn"), weapon);
						break;
					case _global.Enums.WeaponTypeFlag.e_WeaponType_Club:
					case _global.Enums.WeaponTypeFlag.e_WeaponType_Sword:
					case _global.Enums.WeaponTypeFlag.e_WeaponType_Fist:
					case _global.Enums.WeaponTypeFlag.e_WeaponType_Shotgun:
					case _global.Enums.WeaponTypeFlag.e_WeaponType_Death:
					case _global.Enums.WeaponTypeFlag.e_WeaponType_Jinx:
					default:
						weapons += LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "TooltipRequiresA"), weapon);
						break;						
				}
            }
        }
        return weapons;
    }
    
    private static function GetWeaponRequirementIcons(spellRequirementsFlag:Number):Array
    {
        var iconNames:Array = [];
        for (var i:Number = 0; i < _global.Enums.WeaponTypeFlag.e_WeaponType_Count; i++)
        {
            var flagValue = 1 << i;
            if (spellRequirementsFlag & flagValue)
            {
                iconNames.push(GetWeaponRequirementIconName(flagValue));
            }
        }
        return iconNames;
    }
    
    private static function GetWeaponRequirementIconNameFromType(weaponType:Number):String
    {
        switch(weaponType)
        {
            case 4394078:
                return "FistsIcon";
            case 41012030:
                return "ShotgunsIcon";
            case 71672516:
                return "ElementalsIcon";
            case 91624581:
                return "AssaultRiflesIcon";
            case 93626565:
                return "BladesIcon";
            case 157308306:
                return "HammersIcon";
            case 166678788:
                return "ChaosIcon";
            case 205690740:
                return "BloodIcon";
            case 244175283:
                return "PistolsIcon";
            case 243435431:
                return "AstralIcon";
            case 243435430:
			case 243435429:
			case 243435428:
                return "MajorIcon";
            case 243435427:
			case 243435426:
			case 243435425:
                return "MinorIcon";
        }
    }

    private static function GetWeaponRequirementIconName(spellRequirementFlag:Number):String
    {
        switch(spellRequirementFlag)
        {
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Melee:
            return "Weapon_Melee";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Club:
            return "HammersIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Axe:
            return "Weapon_Axes";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Dagger:
            return "Weapon_Daggers";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Fist:
            return "FistsIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Sword:
            return "BladesIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Ranged:
            return "Weapon_Ranged";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Handgun:
            return "PistolsIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_AssaultRifle:
            return "AssaultRiflesIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Rifle:
            return "Weapon_Rifles";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Shotgun:
            return "ShotgunsIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_SMG:
            return "Weapon_SMGs";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Magic:
            return "Weapon_Magic";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Jinx:
            return "ChaosIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Vile:
            return "Weapon_Vile";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Life:
            return "Weapon_Life";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Death:
            return "BloodIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Fire:
            return "ElementalsIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_1_Handed:
            return "Weapon_Pistol";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_2_Handed:
            return "Weapon_Pistols";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Heal:
            return "Weapon_Life";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_Launcher:
            return "RocketLauncherIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_ChainSaw:
            return "ChainSawIcon";
          case _global.Enums.WeaponTypeFlag.e_WeaponType_QuantumWeapon:
            return "QuantumIcon";
			
          default:
            return "Weapon_Melee";
        }
    }
    
	public static function ShowFloatingTooltip(acgItem:ACGItem)
	{
		var tooltipData:TooltipData = TooltipDataProvider.GetACGItemTooltip(acgItem);
		var equippedItems:Array = [];
		
		for ( var i:Number = 0 ; i < tooltipData.m_CurrentlyEquippedItems.length ; ++i )
		{
			var equippedData:TooltipData;

			equippedData =  TooltipDataProvider.GetInventoryItemTooltipCompareACGItem( new com.Utils.ID32( _global.Enums.InvType.e_Type_GC_WeaponContainer, 0 ), 
									tooltipData.m_CurrentlyEquippedItems[i], acgItem);
			
			equippedData.m_IsEquipped = true;
			equippedItems.push( equippedData);
		}
		
		TooltipManager.GetInstance().ShowTooltip( null, TooltipInterface.e_OrientationHorizontal, 0, tooltipData, equippedItems ).MakeFloating();
	}
    
    public static function GetSpellTypeName(spellType:Number, spellAttackType:Number ):String
    {
        if (spellType == _global.Enums.SpellItemType.ePassiveAbility)
        {
            return LDBFormat.LDBGetText("Gamecode", "PassiveAbility");
        }
        else if(spellType == _global.Enums.SpellItemType.eMagicSpell)
        {
            return LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ActiveAbility"), GetSpellAttackTypeName(spellAttackType));
        }
        else if(spellType == _global.Enums.SpellItemType.eEliteActiveAbility)
        {
            return LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "EliteActiveAbility"), GetSpellAttackTypeName(spellAttackType));
        }
        else if(spellType == _global.Enums.SpellItemType.eElitePassiveAbility)
        {
            return LDBFormat.LDBGetText("Gamecode", "ElitePassiveAbility");
        }
        else if(spellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
        {
            return LDBFormat.LDBGetText("Gamecode", "AuxilliaryActiveAbility");
        }
        else if(spellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
        {
            return LDBFormat.LDBGetText("Gamecode", "AuxilliaryPassiveAbility");
        }
    }

    public static function GetSpellAttackTypeName(spellAttackType:Number)
    {
        switch(spellAttackType)
        {
            case _global.Enums.AttackType.e_Melee:
            {
                return LDBFormat.LDBGetText("ItemInfoGUI", "AttackType_Melee");
                break;
            }
            case _global.Enums.AttackType.e_Ranged:
            {
                return LDBFormat.LDBGetText("ItemInfoGUI", "AttackType_Ranged");
                break;
            }
            case _global.Enums.AttackType.e_Magic:
            {
                return LDBFormat.LDBGetText("ItemInfoGUI", "AttackType_Magic");
                break;
            }
            case _global.Enums.AttackType.e_Heal:
            {
                return LDBFormat.LDBGetText("ItemInfoGUI", "AttackType_Heal");
                break;
            }
            default:
            {
                return "";
                break;
            }
        }
    }
	
	public static function AddTextTooltip(parentClip:MovieClip, text:String, maxWidth:Number, orientation:Number, showAtMouse:Boolean, showDelay:Boolean )
	{
		if (parentClip.onPress == null) parentClip.onPress = function() { };
		parentClip.onRollOver =  function()
		{
			if (this._visible && this._alpha > 0)
			{
				var tooltipData:TooltipData = new TooltipData();
				
				tooltipData.m_Descriptions.push(text);
				tooltipData.m_Padding = 4;
                
				if (maxWidth == undefined || maxWidth <= 140)
				{
					tooltipData.m_MaxWidth = 140;
				}
                else
                {
                    tooltipData.m_MaxWidth = maxWidth;
                }
                
				var connectedClip:MovieClip = parentClip;
				if (showAtMouse != undefined && showAtMouse)
				{
					connectedClip = undefined;
				}
                
                var delay:Number = (showDelay == undefined || showDelay == true)?DistributedValue.GetDValue("HoverInfoShowDelay"):0;
              
				this.m_Tooltip = TooltipManager.GetInstance().ShowTooltip( connectedClip, orientation, delay, tooltipData );
			}
		}
		
		parentClip.onRollOut = parentClip.onDragOut = parentClip.onMouseDown = function()
		{
			if (this.m_Tooltip != undefined)
			{
				this.m_Tooltip.Close();
				this.m_Tooltip = undefined;
			}
		}
	}
}