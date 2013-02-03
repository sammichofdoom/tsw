import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.PvPMinigame.PvPMinigame
{
    public function PvPMinigame();

    private static var s_Instance:PvPMinigame = null;
    public static function GetInstance()
    {
        if ( s_Instance == null )
        {
            s_Instance = new PvPMinigame();
        }
        return s_Instance;
    }
    
    public static var m_TimeToJoinGame:Number;
    public static var m_SelectedRole:Number;
    public static var m_GamePlayFieldName:String;
    
    public static function GetMatchType() : Number;
    public static function GetSideScore( side:Number, scoreID:Number ) : Number;
    public static function GetTotalCharacterScore( side:Number, scoreID:Number ) : Number;

    public static function InMatchPlayfield() : Boolean;
    public static function GetMinigameStatus() : Number;

    public static function GetWinningSide() : Number;
    public static function GetCaptureZoneName( id:Number ) : String;
    public static function GetTimeLeft() : Number;
    public static function GetToGameTimeLeft() : Number;
    public static function GetScoreLimit() : Number;
    public static function PlantCTFFlags() : Void;
	public static function GetLastUpdateTimestamp() : Number;

	// pvp signup
	public static function SignUpForMinigame(playfieldId:Number, selectedClasses:Number, bringTeam:Boolean, doTeamMatch:Boolean) : Void;
    public static function CanSignUpForMinigame(playfieldId:Number) : Boolean;
	public static function RemoveFromMatchMaking() : Void;
	public static function RequestIsInMatchMaking() : Void;
	public static function LeaveMatch() : Void;
    public static function JoinGame(selectedRole:Number) : Void;
    public static function DeclineJoinGame():Void;

	// playfield name map
	public static function GetPlayfieldName(playfieldId:Number) : String;
  	public static function GetCountryName(countryId:Number) : String;
  	public static function GetCountryId(regionId:Number) : Number;
  	public static function GetCountryArray() : Array; // <Number>
  	public static function GetCountryPlayfieldIdArray(countryId:Number) : Array; // <number>

	// world stats
    public static var SignalWorldStatChanged:com.Utils.Signal; // statName:String, value:Number, type1:Number, type2:Number, dimID:Number
	public static function RequestWorldStat(statName:String, type1:Number, type2:Number, dimId:Number) : Void;
	public static function IsStatInCache(statName:String, type1:Number, type2:Number, dimId:Number) : Boolean;
	public static function GetWorldStat(statName:String, type1:Number, type2:Number, dimId:Number) : Number;
	public static function IsStatNameValid(statName:String) : Boolean;
	public static function IsStatGlobal(statName:String) : Boolean;
	public static function GetCurrentDimensionId() : Number;
    public static function RequestTimeToStatusUpdate() : Void;
    
    public static var SignalPlayerChangedSide:com.Utils.Signal;
    public static var SignalPvPMinigameScoreChanged:com.Utils.Signal;

  //public static var SignalPvPMinigameCharacterScoreChanged:com.Utils.Signal;
  //public static var SignalPvPMatchMakingErrorCode:com.Utils.Signal;
  //public static var SignalPvPMatchMakingYouJoinedMatch:com.Utils.Signal;
  //public static var SignalPvPMatchMakingMatchInfo:com.Utils.Signal;
  public static var SignalPvPMatchMakingMatchRemoved:com.Utils.Signal;
  public static var SignalPvPMatchMakingMatchStarted:com.Utils.Signal;
  public static var SignalPvPMatchMakingMatchEnded:com.Utils.Signal;
  //public static var SignalEnteredPvPPlayfield:com.Utils.Signal;
  public static var SignalMinigameStartsInXSeconds:com.Utils.Signal;
  //public static var SignalPvPMatchMakingSearchResult:com.Utils.Signal;
  public static var SignalYouAreInMatchMaking:com.Utils.Signal; // -> SlotYouAreInMatchMaking();
  public static var SignalMatchWantsToStart:com.Utils.Signal;
  public static var SignalNoLongerInMatchMaking:com.Utils.Signal;// -> SlotNoLongerInMatchMaking();
  public static var SignalStatusUpdateTime:com.Utils.Signal; // <timeLeft:Number>
  //public static var SignalPvPMatchMakingTeamJoined:com.Utils.Signal;
  //public static var SignalPvPMatchMakingRaidJoined:com.Utils.Signal;
  //public static var SignalMatchMakingCollectingMorePlayers:com.Utils.Signal;
  //public static var SignalCantStartMatchNotAllPlayersHaveSide:com.Utils.Signal;
  //public static var SignalPlayerJoinedMatch:com.Utils.Signal;
  //public static var SignalPlayerLeftMatch:com.Utils.Signal;
  //public static var SignalPlayerLockedToSide:com.Utils.Signal;
  //public static var SignalPlayerNoLongerLockedToSide:com.Utils.Signal;
  //public static var SignalCaptureZoneList:com.Utils.Signal;
  //public static var SignalCaptureZoneUpdate:com.Utils.Signal;
  //public static var SignalCaptureZoneNewOwner:com.Utils.Signal;
  //public static var SignalCaptureZoneLeaveEnter:com.Utils.Signal;
  //public static var SignalMatchMakingInfoRequest:com.Utils.Signal;
    
}
