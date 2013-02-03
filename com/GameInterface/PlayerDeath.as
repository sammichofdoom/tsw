import com.Utils.Signal;

intrinsic class com.GameInterface.PlayerDeath
{	
	public static var SignalPlayerCharacterDead:Signal; // -> SlotPlayerCharacterDead(wait:Boolean) // wait for SignalRespawnWave
	public static var SignalPlayerCharacterAlive:Signal;
	public static var SignalResurrectRequest:Signal;
	public static var SignalNewAnimaWell:Signal;
	public static var SignalNoAnimaWell:Signal;
	public static var SignalAnimaWellIsClose:Signal;
	public static var SignalAnimaWellIsGone:Signal;
	public static var SignalTombstoneIsClose:Signal;
	public static var SignalTombstoneIsGone:Signal;
    public static var SignalRespawnWaveTimeUpdate:Signal; // -> SlotRespawnWaveTimeUpdate(timeLeft:Number);
	
	public static function Resurrect(respawnPointId:Number);
	public static function ResurrectGm();
	public static function ResurrectRequestAccept();
	public static function ResurrectRequestReject();
	public static function ClearGhosting();
	public static function GetAnimaWellArray():Array; // com.GameInterface.RespawnPoint
	public static function PlayerIsDead():Boolean;
	public static function DoWaveRespawn():Boolean;
	public static function MouseButton(button:Number, down:Boolean);
	public static function SignupForRespawnPoint(respawnPointId:Number);
}