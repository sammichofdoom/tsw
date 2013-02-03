intrinsic class com.GameInterface.ProjectFeatInterface extends com.GameInterface.FeatInterface
{
	public static function CanRefund():Boolean;
    public static function GetHighestLearnedSkillLevel(skillEnum:Number) : Number;
    public static function GetSpentSkillPoints() : Number;
	public static function GetSkillRows() : Array;  // ASCharacterPointRowData
	public static function GetSkillLevelForRow() : Number;
}