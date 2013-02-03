import com.Utils.Colors;
import com.Utils.LDBFormat;

class GUI.Mission.MissionUtils
{
    /// constructor to load in GamecodeInterface
    public function MissionUtils()
    {
        
    }
    /// returns the mission type as a string, gets it from the missiontypeenum
	/// 
	public static function MissionTypeToString( p_missiontype:Number ) :String
	{
		var iconname:String = "Unknown";
		switch( p_missiontype )
		{
			case _global.Enums.MainQuestType.e_Action:
				iconname = "Action";
			break;
			case _global.Enums.MainQuestType.e_Sabotage:
				iconname = "Sabotage";
			break;
			case _global.Enums.MainQuestType.e_Story:
				iconname = "Story";
			break;
			case _global.Enums.MainQuestType.e_Challenge:
				iconname = "Unknown";
			break;
            case _global.Enums.MainQuestType.e_Investigation:
                iconname = "Investigation";
            break;
            case _global.Enums.MainQuestType.e_Group:
                iconname = "Group";
            break;
            case _global.Enums.MainQuestType.e_Raid:
                iconname = "Raid";
            break;
            case _global.Enums.MainQuestType.e_Lair:
                iconname = "Dungeon";
            break;
            case _global.Enums.MainQuestType.e_PvP:
                iconname = "PvP";
            break;
            case _global.Enums.MainQuestType.e_Massacre:
                iconname = "Massacre";
            break;
            case _global.Enums.MainQuestType.e_Item:
                iconname = "Item";
            break;
		}
		return iconname;
	}
    
    
    /// returns the name and color of the MonsterBand thing
    public static function GetMissionDifficultyText(difficulty:Number, format:Object) : String
    {
        format = (format == undefined) ? { face: "_Headline", size:10 } : format;
        var color:String = "#FFFFFF";
        var text:String = "";
        
        if (difficulty <= -3) // easy
        {
            color = Colors.ColorToHtml( Colors.e_Easy );
            text = LDBFormat.LDBGetText( "GenericGUI", "Easy");
        }
        else if (difficulty <= -2) // moderate
        {
            color = Colors.ColorToHtml( Colors.e_Moderate );
            text = LDBFormat.LDBGetText( "GenericGUI", "Moderate");
        }
        else if (difficulty <= 0) // equal
        {
            color = Colors.ColorToHtml( Colors.e_Equal );
            text = LDBFormat.LDBGetText( "GenericGUI", "Equal");
        }
        else if (difficulty <= 1) // Challenging
        {
            color = Colors.ColorToHtml( Colors.e_Challenging );
            text = LDBFormat.LDBGetText( "GenericGUI", "Challenging");
        }
        
        else if (difficulty <= 2) // Hard
        {
            color = Colors.ColorToHtml( Colors.e_Demanding );
            text = LDBFormat.LDBGetText( "GenericGUI", "Demanding");
        }
        else if (difficulty >= 3) // Difficult
        {
            color = Colors.ColorToHtml( Colors.e_Difficult );
            text = LDBFormat.LDBGetText( "GenericGUI", "Difficult");
        }
        format.color = color;
        return com.GameInterface.Utils.CreateHTMLString("("+text+")",format);
    }
	
	//returns the name of the slot that a missiontype will be added to
	public static function GetMissionSlotTypeName(missionType:Number) : String
	{
		switch( missionType )
		{
			case    _global.Enums.MainQuestType.e_Action:
			case    _global.Enums.MainQuestType.e_Sabotage:
			case    _global.Enums.MainQuestType.e_Challenge:
			case    _global.Enums.MainQuestType.e_Investigation:
				return LDBFormat.LDBGetText( "Quests", "MainMissionMixedCase" );
			case    _global.Enums.MainQuestType.e_Lair:
			case    _global.Enums.MainQuestType.e_Group:
            case    _global.Enums.MainQuestType.e_Raid:
				return LDBFormat.LDBGetText( "Quests", "DungeonMissionMixedCase" );
			case    _global.Enums.MainQuestType.e_Story:
				return LDBFormat.LDBGetText( "Quests", "StoryMissionMixedCase" );
			case    _global.Enums.MainQuestType.e_Item:
			case    _global.Enums.MainQuestType.e_PvP:
			case    _global.Enums.MainQuestType.e_Massacre:
				return LDBFormat.LDBGetText( "Quests", "SideMissionMixedCase" );
				
		}
		return "";
	}
	
	//returns the name of the slot that a missiontype will be added to
	public static function GetMissionSlotTypeColor(missionType:Number) : String
	{
		switch( missionType )
		{
			case    _global.Enums.MainQuestType.e_Action:
			case    _global.Enums.MainQuestType.e_Sabotage:
			case    _global.Enums.MainQuestType.e_Challenge:
			case    _global.Enums.MainQuestType.e_Investigation:
				return "#824430";
			case    _global.Enums.MainQuestType.e_Lair:
			case    _global.Enums.MainQuestType.e_Group:
            case    _global.Enums.MainQuestType.e_Raid:
				return "#715F8E";
			case    _global.Enums.MainQuestType.e_Story:
				return "#5099AA";
			case    _global.Enums.MainQuestType.e_Item:
			case    _global.Enums.MainQuestType.e_PvP:
			case    _global.Enums.MainQuestType.e_Massacre:
				return "#515956";
				
		}
		return "#000000";
	}
}