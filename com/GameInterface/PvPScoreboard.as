import com.Utils.Signal;

intrinsic class com.GameInterface.PvPScoreboard
{
    public static var m_Players:Array; //Array of PvPScoreboardPlayerData objects
    public static var m_PlayfieldID:Number;
    public static var m_MatchResult : Number; //MinigameMatchResult_e
    public static var m_WinnerSide : Number; //PvPMatchMakingSide_e
    
    public static function Close() : Void; //Call to reset PvPScoreboard values
}