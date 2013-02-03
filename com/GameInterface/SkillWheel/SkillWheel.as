import com.Utils.Signal;

/**
 * ...
 * @author Håvard Homb
 */

intrinsic class com.GameInterface.SkillWheel.SkillWheel
{
    /// Object containing arrays of templates indexed on faction
    public static var m_FactionSkillTemplates:Object;
    
    //Functions to get cached names for clusters/cells
    public static function GetClusterName();
    public static function GetCellName();
    public static function ClaimDeck(deckID:Number);
}