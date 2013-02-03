import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.Nametags
{	
	public static function RefreshNametags();
	public static function GetAggroStanding(identity:ID32):Number;
	
	public static var SignalNametagAdded:Signal;
	public static var SignalNametagRemoved:Signal;
	public static var SignalNametagUpdated:Signal;
	public static var SignalNametagAggroUpdated:Signal;
	public static var SignalAllNametagsRemoved:Signal;
}