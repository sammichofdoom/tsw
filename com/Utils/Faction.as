class com.Utils.Faction
{
	public static function GetName( enum:Number, allCaps:Boolean ) : String
	{
		if (enum == _global.Enums.Factions.e_FactionDragon)
		{
            if (allCaps == false)
            {
                return com.Utils.LDBFormat.LDBGetText("FactionNames", "DragonCapitalizationCase");
            }
            
            if (allCaps == undefined || allCaps == true)
            {
                return com.Utils.LDBFormat.LDBGetText("FactionNames", "Dragon");
            }
		}
		else if (enum == _global.Enums.Factions.e_FactionTemplar)
		{
            if (allCaps == false)
            {
                return com.Utils.LDBFormat.LDBGetText("FactionNames", "TemplarsCapitalizationCase");
            }
            
            if (allCaps == undefined || allCaps == true)
            {
                return com.Utils.LDBFormat.LDBGetText("FactionNames", "Templars");
            }
		}
		else if (enum == _global.Enums.Factions.e_FactionIlluminati)
		{
            if (allCaps == false)
            {
                return com.Utils.LDBFormat.LDBGetText("FactionNames", "IlluminatiCapitalizationCase");
            }
            
            if (allCaps == undefined || allCaps == true)
            {
                return com.Utils.LDBFormat.LDBGetText("FactionNames", "Illuminati");
            }
		}
		else
		{
			return "";
		}
	}
    
    /// returns a non localised string representation of the faction in english
    /// used to refernce linked icons or resources with a descriptive faction name
    public static function GetFactionNameNonLocalized( faction:Number ) : String
    {
        if (faction == _global.Enums.Factions.e_FactionDragon)
        {
            return "dragon";
        }
        else if (faction == _global.Enums.Factions.e_FactionTemplar)
        {
            return "templar";
        }
        else if (faction == _global.Enums.Factions.e_FactionIlluminati)
        {
            return "illuminati";
        }
        else
        {
            return "none";
        }
    }
	
	public static function GetHQ( enum:Number ) : String
	{
		if (enum == _global.Enums.Factions.e_FactionDragon)
		{
			return com.Utils.LDBFormat.LDBGetText("FactionNames", "DragonHQ");
		}
		else if (enum == _global.Enums.Factions.e_FactionTemplar)
		{
			return com.Utils.LDBFormat.LDBGetText("FactionNames", "TemplarHQ");
		}
		else if (enum == _global.Enums.Factions.e_FactionIlluminati)
		{
			return com.Utils.LDBFormat.LDBGetText("FactionNames", "IlluminatiHQ");
		}
		else
		{
			return "";
		}
	}
}