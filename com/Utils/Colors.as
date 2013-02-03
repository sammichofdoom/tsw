import flash.geom.ColorTransform;
import flash.geom.Transform;
///

class com.Utils.Colors
{
    /// color names
    public static var e_ColorWhite:Number = 0xFFFFFF;
    public static var e_ColorBlack:Number = 0x000000;
    public static var e_ColorYellow:Number = 0xFFF666;
    public static var e_ColorRed:Number = 0xa40001; 
    public static var e_ColorDarkRed:Number = 0x6B0102; 
    public static var e_ColorPureRed:Number = 0xff0000; 
    public static var e_ColorDarkBlue:Number = 0x023A8E;
   
    public static var e_ColorBlue:Number = 0x023A8E;
    public static var e_ColorLightBlue:Number = 0x0E93E7;
    public static var e_ColorGreen:Number = 0x1FBB00;
    public static var e_ColorDarkGreen:Number = 0x147800;
    public static var e_ColorPureGreen:Number = 0x00FF00;
    public static var e_ColorPureYellow:Number = 0xFFFF00;
    public static var e_ColorSignalGreen:Number = 0x00FF12;
    public static var e_ColorLightGreen:Number = 0xA9D48D;
    
    public static var e_ColorOrange :Number = 0xFF9900;
    public static var e_ColorDarkOrange :Number = 0x945F0F;
    public static var e_ColorLightOrange :Number = 0xFAD177;
    public static var e_ColorLightRed:Number = 0xFD0001;
    public static var e_ColorCyan:Number = 0x0E93E7;
    public static var e_ColorMagenta:Number = 0xF600FF;
    public static var e_ColorPurple:Number = 0x70469C;
    public static var e_ColorPalePurple:Number = 0x614D75;

    ///items, background and highlight
    public static var e_ColorDefaultBackground:Number = 0x000000;
    public static var e_ColorDefaultHighlight:Number = 0x414141;
    
    public static var e_ColorRangedSpellBackground:Number = 0x640000;
    public static var e_ColorRangedSpellHighlight:Number = 0xc90101;
    
    public static var e_ColorMeleeSpellBackground:Number = 0x732e00;
    public static var e_ColorMeleeSpellHighlight:Number = 0xd66001;
    
    public static var e_ColorSupportSpellBackground:Number = 0x00768b;
    public static var e_ColorSupportSpellHighlight:Number = 0x009cc9;
    
    public static var e_ColorHealSpellBackground:Number = 0x057400;
    public static var e_ColorHealSpellHighlight:Number = 0x31bd00;
    
    public static var e_ColorMagicSpellBackground:Number = 0x00297b;
    public static var e_ColorMagicSpellHighlight:Number = 0x016ce5;
    
    public static var e_ColorPassiveSpellBackground:Number = 0x551c42;
    public static var e_ColorPassiveSpellHighlight:Number = 0x85366b;

    public static var e_ColorTrueBandBuffBackground:Number = 0xd15002;
    public static var e_ColorTrueBandBuffHighlight:Number = 0xfd853d;
    
    public static var e_ColorOffensiveBuffBackground:Number = 0xad8000;
    public static var e_ColorOffensiveBuffHighlight:Number = 0xd6a500;
    
    public static var e_ColorDefensiveBuffBackground:Number = 0x017fa5;
    public static var e_ColorDefensiveBuffHighlight:Number = 0x00b0d7;
    
    public static var e_ColorHealBuffBackground:Number = 0x0d9a08;
    public static var e_ColorHealBuffHighlight:Number = 0x0cb700;
    
    public static var e_ColorGenericBuffBackground:Number = 0x875ea3;
    public static var e_ColorGenericBuffHighlight:Number = 0xb37bc9;
    
    public static var e_ColorAfflictedDebuffBackground:Number = 0x660000;
    public static var e_ColorAfflictedDebuffHighlight:Number = 0xa60000;
    
    public static var e_ColorWeakenedDebuffBackground:Number = 0x3c471c;
    public static var e_ColorWeakenedDebuffHighlight:Number = 0x607225;
    
    public static var e_ColorHinderedDebuffBackground:Number = 0x20414e;
    public static var e_ColorHinderedDebuffHighlight:Number = 0x016f7d;
    
    public static var e_ColorImpariedDebuffBackground:Number = 0x683000;
    public static var e_ColorImpariedDebuffHighlight:Number = 0xa34300;
    
    public static var e_ColorFilthDebuffBackground:Number = 0x000000;
    public static var e_ColorFilthDebuffHighlight:Number = 0x414141;

    public static var e_ColorGenericDebuffBackground:Number = 0x660140;
    public static var e_ColorGenericDebuffHighlight:Number = 0x861260;
    
    public static var e_ColorWeaponItemsBackground:Number = 0x242949;
    public static var e_ColorWeaponItemsHightlight:Number = 0x33456c;
    
    public static var e_ColorTalismanHeadBackground:Number = 0x531623;
    public static var e_ColorTalismanHeadHightlight:Number = 0x712b42;

    public static var e_ColorTalismanMajorBackground:Number = 0x3e1b37;
    public static var e_ColorTalismanMajorHightlight:Number = 0x652d56;

    public static var e_ColorTalismanMinorBackground:Number = 0x35234f;
    public static var e_ColorTalismanMinorHightlight:Number = 0x553d67;

    public static var e_ColorCraftingItemsBackground:Number = 0x152c3a;
    public static var e_ColorCraftingItemsHighlight:Number = 0x005866;

    public static var e_ColorUnusableMissionItemsBackground:Number = 0x510200;
    public static var e_ColorUnusableMissionItemsHighlight:Number = 0x860500;

    public static var e_ColorUsableMissionItemsBackground:Number = 0x701011;
    public static var e_ColorUsableMissionItemsHighlight:Number = 0xba1110
    
    public static var e_ColorTrinketsBackground:Number = 0x00376f;
    public static var e_ColorTrinketsHighlight:Number = 0x0084c9;
    
    public static var e_ColorConsumablesBackground:Number = 0x005215;
    public static var e_ColorConsumablesHighlight:Number = 0x169a00;
    
    public static var e_ColorSocialConsumablesBackground:Number = 0x5f2d00;
    public static var e_ColorSocialConsumablesHighlight:Number = 0xc86800;

    public static var e_ColorClothingItemsBackground:Number = 0x4d2f00;    
    public static var e_ColorClothingItemsHighlight:Number = 0x7e4400;
	
	public static var e_ColorSilverBackground:Number = 0x434343;
    public static var e_ColorSilverHighlight:Number = 0x7b7b7b;

    public static var e_ColorChristmasBackground:Number = 0xc50000;    
    public static var e_ColorChristmasHighlight:Number = 0x008c08;
    
    
    
    public static var e_ColorCharcoal:Number = 0x333333;
    public static var e_ColorDarkGray:Number = 0xAAAAAA;
    public static var e_ColorGray:Number = 0xCCCCCC;
    
            
    /// named resources
    public static var e_ColorCastbar:Number = e_ColorCyan;
    public static var e_ColorDisabledAbility:Number = e_ColorBlack;
    
    /// icons, abilities
   
    public static var e_ColorIconDefault:Number = e_ColorBlack;
    public static var e_ColorIconRangedSpell:Number = e_ColorRed;
    public static var e_ColorIconMeleeSpell:Number = e_ColorOrange;
    public static var e_ColorIconSupportSpell:Number = e_ColorCyan;
    public static var e_ColorIconHealSpell:Number = e_ColorGreen;
    public static var e_ColorIconMagicSpell:Number = e_ColorDarkBlue;
    public static var e_ColorIconPassiveSpell:Number = e_ColorPurple;
    
    public static var e_ColorIconTrueBandBuff:Number = e_ColorOrange;
    public static var e_ColorIconOffensiveBuff:Number = 0xD6A500;
    public static var e_ColorIconDefensiveBuff:Number = e_ColorBlue;
    public static var e_ColorIconHealBuff:Number = e_ColorGreen;
    public static var e_ColorIconGenericBuff:Number = e_ColorPurple;
    public static var e_ColorIconAfflictedDebuff:Number = e_ColorDarkRed;
    public static var e_ColorIconWeakenedDebuff:Number = e_ColorDarkGreen;
    public static var e_ColorIconHinderedDebuff:Number = e_ColorDarkBlue;
    public static var e_ColorIconImpariedDebuff:Number = e_ColorDarkOrange;
    public static var e_ColorIconFilthDebuff:Number = e_ColorDarkGray;
    public static var e_ColorIconGenericDebuff:Number = e_ColorPalePurple;

    /// Item backgrounds
    
    public static var e_ColorBorderItemSuperior:Number = 0xffffff; 
    public static var e_ColorBorderItemEnchanted:Number = 0x00ff16; 
    public static var e_ColorBorderItemRare:Number = 0x02b6ff; 
    public static var e_ColorBorderItemEpic:Number = 0xd565f8; 
    public static var e_ColorBorderItemLegendary:Number = 0xffd001; 
    public static var e_ColorBorderItemMission:Number = 0x963232; 
    public static var e_ColorBorderItemMissionUsable:Number = 0xca5d32; 
    
    
    public static var e_ColorItemTypeWeapons:Number = 0x36486e;
    public static var e_ColorItemTypeCrafting:Number = 0x197d97; 
    public static var e_ColorItemTypeChakras:Number = 0x60446a;
    public static var e_ColorItemTypeCenterChakra:Number = 0x993300;
    public static var e_ColorItemTypeConsumable:Number = 0x419945; 
    public static var e_ColorItemTypeMissionUsable:Number = 0xa92425; 
    public static var e_ColorItemTypeMission:Number = 0x993233; 
	
	public static var e_ColorItemUnusuable:Number = e_ColorRed;
    
    
    /// buff debuffs and states conditions
    public static var e_ColorBuff:Number = e_ColorDarkBlue;
    public static var e_ColorDebuff:Number = e_ColorLightRed;
    public static var e_ColorStates:Number = e_ColorCyan;
    
    /// token colors
    public static var e_ColorDefaultToken:Number = e_ColorGray;
    
    /// Health bars
    public static var e_ColorHealthCritical:Number = e_ColorLightRed;
    public static var e_ColorHealthNormal:Number = e_ColorSignalGreen;
    public static var e_ColorAnimaCritical:Number = e_ColorLightRed;
    public static var e_ColorAnimaNormal:Number = e_ColorYellow;
    
    public static var  e_ColorMissionAction:Number = 0x500000;
    public static var  e_ColorMissionInvestigation:Number = 0x2F650A;
    public static var  e_ColorMissionSabotage:Number = 0xBD8606;
    public static var  e_ColorMissionStory:Number = 0x120A65;
    public static var  e_ColorMissionDungeon:Number = 0x0986BB;
    public static var  e_ColorMissionRaid:Number = 0x700D7B;
    
    ///Mission difficulty
    public static var e_Equal:Number = 0xffffff;
    public static var e_Moderate:Number = 0x07ccdf;
    public static var e_Easy:Number = 0x2cc22f;
    public static var e_Challenging:Number = 0xefe02d;
    public static var e_Demanding:Number = 0xdfaa07;
    public static var e_Difficult:Number = 0xc70304;
    
    /// default window colors
    public static var e_ColorPanelsBackground:Number = e_ColorBlack;
    public static var e_ColorPanelsLine:Number = e_ColorWhite;
    public static var e_ColorJournalMainTier:Number = 0x373737;
    public static var e_ColorJournalSubTier:Number = 0x474747;
    public static var e_ColorJournalRepetableFont:Number = e_ColorLightGreen;
    public static var e_ColorJournalUnrepeatableFont:Number = e_ColorDarkGray;
    
    
    // timeout animation for mission timer
    public static var e_ColorTimeoutSuccess:Number = e_ColorGreen;
    public static var e_ColorTimeoutFail:Number = e_ColorRed;
    
    /// abilities
    public static var e_ColorEnabledIcon:Number = e_ColorWhite;
    public static var e_ColorDisabledIcon:Number = e_ColorGray;

    /// PvP
    public static var e_ColorPvPIlluminati:Number = 0x00a9fa;
	public static var e_ColorPvPIlluminatiText:Number = 0x5FCEFE;
    public static var e_ColorPvPDragon:Number = 0x5ca716;
    public static var e_ColorPvPDragonText:Number = 0x73C91D;
	public static var e_ColorPvPTemplar:Number = 0xdd0007;
    public static var e_ColorPvPTemplarText:Number = 0xFE4558;
	
    
    /// Damage
    public static var e_ColorDamage:Number = e_ColorRed;
    
    //Compass
    public static var e_ColorCompassLines:Number = e_ColorWhite;
    
	public static function GetColorlineColors( colorline:Number) : Object
    {
      switch( colorline )
      {
        case 0:
          return { highlight: e_ColorDefaultHighlight, background:  e_ColorDefaultBackground };
          
        case 1:
          return { highlight: e_ColorRangedSpellHighlight, background:  e_ColorRangedSpellBackground };

        case 2:
          return { highlight: e_ColorMeleeSpellHighlight, background:  e_ColorMeleeSpellBackground };

        case 3:
          return { highlight: e_ColorSupportSpellHighlight, background:  e_ColorSupportSpellBackground };

        case 4:
          return { highlight: e_ColorHealSpellHighlight, background:  e_ColorHealSpellBackground };

        case 5:
          return { highlight: e_ColorMagicSpellHighlight, background:  e_ColorMagicSpellBackground };
        
        case 6:
          return { highlight: e_ColorPassiveSpellHighlight, background:  e_ColorPassiveSpellBackground };
        
        case 7:
          return { highlight: e_ColorTrueBandBuffHighlight, background:  e_ColorTrueBandBuffBackground };
        
        case 8:
          return { highlight: e_ColorOffensiveBuffHighlight, background:  e_ColorOffensiveBuffBackground };
        
        case 9:
          return { highlight: e_ColorDefensiveBuffHighlight, background:  e_ColorDefensiveBuffBackground };
        
        case 10:
          return { highlight: e_ColorHealBuffHighlight, background:  e_ColorHealBuffBackground };
          
        case 11:
          return { highlight: e_ColorGenericBuffHighlight, background:  e_ColorGenericBuffBackground };
        
        case 12:
          return { highlight: e_ColorAfflictedDebuffHighlight, background:  e_ColorAfflictedDebuffBackground };
        
        case 13:
          return { highlight: e_ColorWeakenedDebuffHighlight, background:  e_ColorWeakenedDebuffBackground };
        
        case 14:
          return { highlight: e_ColorHinderedDebuffHighlight, background:  e_ColorHinderedDebuffBackground };
        
        case 15:
          return { highlight: e_ColorImpariedDebuffHighlight, background: e_ColorImpariedDebuffBackground };
        
        case 16:
          return { highlight: e_ColorFilthDebuffHighlight, background: e_ColorFilthDebuffBackground };
        
        case 17:
          return { highlight: e_ColorGenericDebuffHighlight, background: e_ColorGenericDebuffBackground };

        case 18:
            return { highlight: e_ColorWeaponItemsHightlight, background: e_ColorWeaponItemsBackground };
            
        case 19:
            return { highlight: e_ColorTalismanHeadHightlight, background: e_ColorTalismanHeadBackground };
            
        case 20:
            return { highlight: e_ColorTalismanMajorHightlight, background: e_ColorTalismanMajorBackground };
            
        case 21:
            return { highlight: e_ColorTalismanMinorHightlight, background: e_ColorTalismanMinorBackground };
            
        case 22:
            return { highlight: e_ColorCraftingItemsHighlight, background: e_ColorCraftingItemsBackground };
            
        case 23:
            return { highlight: e_ColorUnusableMissionItemsHighlight, background: e_ColorUnusableMissionItemsBackground };
            
        case 24:
            return { highlight: e_ColorUsableMissionItemsHighlight, background: e_ColorUsableMissionItemsBackground };
            
        case 25:
            return { highlight: e_ColorTrinketsHighlight, background: e_ColorTrinketsBackground };
            
        case 26:
            return { highlight: e_ColorConsumablesHighlight, background: e_ColorConsumablesBackground };
            
        case 27:
            return { highlight: e_ColorSocialConsumablesHighlight, background: e_ColorSocialConsumablesBackground };
            
        case 28:
            return { highlight: e_ColorClothingItemsHighlight, background: e_ColorClothingItemsBackground };
			
		case 29:
            return { highlight: e_ColorSilverHighlight, background: e_ColorSilverBackground };
			
		case 30:
            return { highlight: e_ColorChristmasHighlight, background: e_ColorChristmasBackground };
            
        default:
          return { highlight: e_ColorDefaultHighlight, background:  e_ColorDefaultBackground };
      }
    }
    
    public static function GetColor( p_colorline:Number) : Number
    {
      switch( p_colorline )
      {
        case 0:
          return e_ColorIconDefault;
          
        case 1:
          return e_ColorIconRangedSpell;

        case 2:
          return e_ColorIconMeleeSpell;

        case 3:
          return e_ColorIconSupportSpell;

        case 4:
          return e_ColorIconHealSpell;

        case 5:
          return e_ColorIconMagicSpell;
        
        case 6:
          return e_ColorIconPassiveSpell;
        
        case 7:
          return e_ColorIconTrueBandBuff;
        
        case 8:
          return e_ColorIconOffensiveBuff;
        
        case 9:
          return e_ColorIconDefensiveBuff;
        
        case 10:
          return e_ColorIconHealBuff;
          
        case 11:
          return e_ColorIconGenericBuff;
        
        case 12:
          return e_ColorIconAfflictedDebuff;
        
        case 13:
          return e_ColorIconWeakenedDebuff;
        
        case 14:
          return e_ColorIconHinderedDebuff;
        
        case 15:
          return e_ColorIconImpariedDebuff;
        
        case 16:
          return e_ColorIconFilthDebuff;
        
        case 17:
          return e_ColorIconGenericDebuff;
        
        case 18:
            return e_ColorWeaponItemsBackground;
            
        case 19:
            return e_ColorTalismanHeadBackground;
            
        case 20:
            return e_ColorTalismanMajorBackground;
            
        case 21:
            return e_ColorTalismanMinorBackground;
            
        case 22:
            return e_ColorCraftingItemsBackground;
            
        case 23:
            return e_ColorUnusableMissionItemsBackground;
            
        case 24:
            return e_ColorUsableMissionItemsBackground;
            
        case 25:
            return e_ColorTrinketsBackground;
            
        case 26:
            return e_ColorConsumablesBackground;
            
        case 27:
            return e_ColorSocialConsumablesBackground;
            
        case 28:
            return e_ColorClothingItemsBackground;
			
		case 29:
            return e_ColorSilverBackground;
			
		case 30:
            return e_ColorChristmasBackground;
            
        default:
          return e_ColorIconDefault;
      }
    }
    
    public static function GetMissionColor(missionType)
    {
        switch(missionType)
        {
            case _global.Enums.WaypointType.e_RMWPQuest_Sabotage:
                return e_ColorMissionSabotage;
            case _global.Enums.WaypointType.e_RMWPQuest_Investigation:
                return e_ColorMissionInvestigation;
            case _global.Enums.WaypointType.e_RMWPQuest_Action:
                return e_ColorMissionAction;
            case _global.Enums.WaypointType.e_RMWPQuest_Story:
                return e_ColorMissionStory;
            case _global.Enums.WaypointType.e_RMWPQuest_Dungeon:
                return e_ColorMissionDungeon;
            case _global.Enums.WaypointType.e_RMWPQuest_Raid:
                return e_ColorMissionRaid;
            default:
                return e_ColorIconDefault;
        }
    }
	
	public static function GetNametagColor(nametagCategory:Number, aggroStanding:Number)
	{
		switch(nametagCategory)
		{
			case _global.Enums.NametagCategory.e_NameTagCategory_NoTarget:
			case _global.Enums.NametagCategory.e_NameTagCategory_Self:
				return e_ColorWhite;
			case _global.Enums.NametagCategory.e_NameTagCategory_Team:
				return e_ColorWhite;
			case _global.Enums.NametagCategory.e_NameTagCategory_Raid:
				return e_ColorWhite;
			case _global.Enums.NametagCategory.e_NameTagCategory_Guild:
				return e_ColorSignalGreen;
			case _global.Enums.NametagCategory.e_NameTagCategory_FriendlyNPC:
			case _global.Enums.NametagCategory.e_NameTagCategory_FriendlyPlayer:
				return e_ColorPureGreen;
			case _global.Enums.NametagCategory.e_NameTagCategory_HostilePlayer:
			case _global.Enums.NametagCategory.e_NameTagCategory_HostileLowLvlPlayer:
				return e_ColorPureRed;
			case _global.Enums.NametagCategory.e_NameTagCategory_HostileNPC:
			case _global.Enums.NametagCategory.e_NameTagCategory_HostileMinionNPC:
			case _global.Enums.NametagCategory.e_NameTagCategory_HostileBossNPC:
			case _global.Enums.NametagCategory.e_NameTagCategory_HostileMiniBossNPC:
			case _global.Enums.NametagCategory.e_NameTagCategory_LowLvlNPC:
				{
					switch(aggroStanding)
					{
						case _global.Enums.Standing.e_StandingFriend:
							return e_ColorPureGreen;
						case _global.Enums.Standing.e_StandingNeutral:
							return e_ColorPureYellow;
						case _global.Enums.Standing.e_StandingEnemy:
							return e_ColorPureRed;
						default:
							return e_ColorPureRed;	
					}
				}
			case _global.Enums.NametagCategory.e_NameTagCategory_QuestTarget:
			case _global.Enums.NametagCategory.e_NameTagCategory_GameMaster:
				return e_ColorOrange;
			default:
				return e_ColorWhite;
		}
	}
    
    public static function GetNametagIconColor(rankDifference:Number)
    {
        if (rankDifference <= -3)
        {
            return Colors.e_Easy;
        }
        else if (rankDifference <= -2)
        {
            return Colors.e_Moderate;
        }
        else if (rankDifference <= 0)
        {
            return Colors.e_Equal;
        }
        else if (rankDifference <= 1)
        {
            return Colors.e_Challenging;
        }
        else if (rankDifference <= 2)
        {
            return Colors.e_Demanding;
        }
        if (rankDifference >= 3)
        {
            return Colors.e_Difficult;
        }
    }
	public static function GetItemRarityColor(rarity:Number)
	{
		var color:Number = e_ColorWhite;
        switch(rarity)
        {
            case _global.Enums.ItemPowerLevel.e_Superior:
                color = Colors.e_ColorBorderItemSuperior;
				break;
            case _global.Enums.ItemPowerLevel.e_Enchanted:
                color = Colors.e_ColorBorderItemEnchanted;
				break;
            case _global.Enums.ItemPowerLevel.e_Rare:
                color = Colors.e_ColorBorderItemRare;
				break;
			case _global.Enums.ItemPowerLevel.e_Epic:
                color = Colors.e_ColorBorderItemEpic;
				break;
			case _global.Enums.ItemPowerLevel.e_Legendary:
                color = Colors.e_ColorBorderItemLegendary;
				break;
        }
        return color;
	}
    
    /// converts a color (0-255 0-255 0-255) to a string aka #FF00FF
    public static function ColorToHtml(color:Number) : String
    {
        var r:Number = (color & 0xff0000) >> 16;
		var g:Number = (color & 0x00ff00) >> 8;
		var b:Number = color & 0x0000ff;
        var rs:String = r.toString(16);
        var gs:String = g.toString(16);
        var bs:String = b.toString(16);
        
        rs = (rs.length < 2) ? "0" + rs : rs;
        gs = (gs.length < 2) ? "0" + gs : gs;
        bs = (bs.length < 2) ? "0" + bs : bs;
      
        return "#" + rs+gs+bs;
    }
    
    /// tints a movieclip
    public static function ApplyColor(mc:MovieClip, color:Number)
    {
        //trace("com.Utils.Colors.ApplyColor(" + mc + "," + color +" )");
        var iconTransform:Transform = new Transform(  mc );
        var iconColorTransform:ColorTransform = new ColorTransform();
        iconColorTransform.rgb = color; 
        iconTransform.colorTransform = iconColorTransform;
    }
	
	/**
	 * 
	 * @param	mc:MovieClip - the clip to ting
	 * @param	color - the color (hex)
	 * @param	amount - amount in percent (0 - 100)
	 */
	public static function Tint(mc:MovieClip, color:Number, amount:Number)
	{
		var colorObject = new Color(mc);
		var r:Number = (color & 0xff0000) >> 16;
		var g:Number = (color & 0x00ff00) >> 8;
		var b:Number = color & 0x0000ff;
        
		var ratio = amount / 100;
		var trans = new Object();

		trans.ra = trans.ga = trans.ba = 100 - amount;
		trans.rb = r * ratio;
		trans.gb = g * ratio;
		trans.bb = b * ratio;
		
		colorObject.setTransform(trans);

	}
}
