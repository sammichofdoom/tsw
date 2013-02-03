import com.GameInterface.MathLib.Vector3;
import com.Utils.ID32;
import com.Utils.Signal;
import flash.geom.Point;

intrinsic class com.GameInterface.Game.DynelBase
{    
    public function DynelBase( dynelID:com.Utils.ID32 );
	public function ReInitialize();
    public function GetStat( statID:Number, mode:Number );
    public function GetRotation() : Number;
    public function SetRotation( angle : Number ) : Void;
    public function GetPosition( attractor:Number ) : Vector3;
    public function SetPosition( pos:Vector3 ) : Void;
	public function GetScreenPosition():Point
	public function GetCameraDistance(attractor:Number):Number;
    public function GetDistanceToPlayer():Number;
    public function GetPlayfieldID():Number;
    public function GetName():String;
    public function IsRendered():Boolean;
    public function IsDead():Boolean;
    public function IsMissionGiver():Boolean;
    public function IsEnemy():Boolean;
    public function IsFriend():Boolean;
    public function HasDialogue():Boolean;
	public function GetNametagPosition():Point;
	public function GetNametagCategory():Number;
	public function GetLockedTo():ID32;

    public function AddLooksPackage( looksPackageRDBID:Number, looksConfiguration:Number ) : Void;
    public function RemoveLooksPackage( looksPackageRDBID:Number ) : Void;
    public function RemoveAllLooksPackages() : Void;

    public function AddEffectPackage( packageName:String ) : Number;
    public function RemoveEffectPackage( effectHandle:Number ) : Boolean;
    
    public var SignalStatChanged:Signal;
    public var SignalLockedToTarget:Signal;
    
    public function GetID():ID32;
}
