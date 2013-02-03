import com.Utils.*;

intrinsic class com.GameInterface.GearManager
{
	public static function IsLoaded() : Boolean;
    public static function CreateBuild(name:String, selectionFlags:Number) : Void;
    public static function UseBuild(name:String) : Void;
    public static function DeleteBuild(name:String) : Void;
    public static function RenameBuild(oldName:String, newName:String) : Void;
	public static function ForceReload();
	public static function ShareBuild(name:String);
    public static function DecodeGearLink(link:String) : Boolean;
    public static function GetCurrentCharacterBuild() : com.GameInterface.GearData;
	public static function GetBuild(name:String) : com.GameInterface.GearData;  // com.GameInterface.GearData
	public static function GetBuildList() : Array;  // String (stored build names)
	
	public static var SignalGearManagerDataUpdated:Signal;  // no parameters
	public static var SignalGearManagerError:Signal;  // GearManagerErrorType_e errorType, const String& message
}