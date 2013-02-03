import com.GameInterface.MathLib.Vector3;
import com.Utils.ID32;
import com.Utils.Signal;
import flash.geom.Point;
import com.GameInterface.Game.Dynel;

intrinsic class com.GameInterface.Game.CharacterBase extends Dynel
{
    public static function GetClientCharID():ID32;
    
    public function CharacterBase( charId:com.Utils.ID32 );
    public function GetTitle():String;
    public function GetFirstName():String;
    public function GetLastName():String;
    public function GetGuildName():String;
    public function GetDimensionName():String;
	public function GetDifficulty():Number;
    public function GetTokens(tokenID:Number);
    public function SetBaseAnim( name:String );
    
    public function GetDefensiveTarget():ID32;
    public function GetOffensiveTarget():ID32;
    
    public function ConnectToCommandQueue();
    public function GetCommandProgress():Number;
    
    public function IsInCharacterCreation():Boolean;
    public function IsInCombat():Boolean;
    public function IsNPC():Boolean;
    public function IsBoss():Boolean;
    public function IsMerchant():Boolean;
    public function IsBanker():Boolean;
    public function IsRare():Boolean;
    public function IsQuestTarget():Boolean;
    public function IsGhosting():Boolean;
    
    public function IsClientChar():Boolean;

	public function CanReceiveItems():Boolean;

    public var SignalTokenAmountChanged:Signal;
    public var SignalToggleCombat:Signal;
    
    public var SignalBuffAdded:Signal;
    public var SignalBuffUpdated:Signal;
    public var SignalBuffRemoved:Signal;
    public var SignalInvisibleBuffAdded:Signal;
    public var SignalInvisibleBuffUpdated:Signal;
    
    public var SignalDefensiveTargetChanged:Signal;
    public var SignalOffensiveTargetChanged:Signal;
    
    public var SignalStateAdded:Signal;
    public var SignalStateUpdated:Signal;
    public var SignalStateRemoved:Signal;
    
    ///*** Signals sent only if you are connected to the CommandQueue through ConnectToCommandQueue function  ***///
    
    /// Signal sent when a command is started.
    public var SignalCommandStarted:Signal; // -> OnSignalCommandStarted( name:String, progressBarType:Number)

    /// Signal sent when a command is ended.
    public var SignalCommandEnded:Signal; // -> OnSignalCommandEnded()

    /// Signal sent when a command is aborted.
    public var SignalCommandAborted:Signal; // -> OnSignalCommandAborted()
    
    ///Signal sent when the character dies
    public var SignalCharacterDied:Signal;
	
    ///Signal sent when the character is resurrected
    public var SignalCharacterAlive:Signal;
    
    ///Signal sent when the character teleports
    public var SignalCharacterTeleported:Signal;
    
    ///Signal sent when the character is being removed from the client for whatever reason (logged out, teleported away, etc)
    public var SignalCharacterDestructed:Signal;
    
    ///*** -------------------------------------------------------------------------------------------------  ***///
    
    public static var SignalClientCharacterAlive:Signal;
    
    public var m_StateList:Object;
    
    public var m_BuffList:Object;
    public var m_InvisibleBuffList:Object;
}
