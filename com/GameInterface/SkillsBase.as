import com.Utils.Signal;

intrinsic class com.GameInterface.SkillsBase
{    
    public static var SignalSkillUpdated:Signal// -> SlotSkillUpdated( updatedSkill:Enums.SkillType)
    public static var SignalUpdateAllSkills:Signal; // (Void)
    
    public static function GetSkill(skill:Number, weapon:Number):String;
    public static function UpdateAllSkills():Void;
}