import flash.external.ExternalInterface;
import com.Utils.Signal;


class com.GameInterface.Targeting
{
  private static var m_ClassName:String = "Targeting";

  public static function GetTarget() {
    return ExternalInterface.call( "GetTarget", m_ClassName );
    
  }
  public static function GetTargetsTarget() {
    return ExternalInterface.call( "GetTargetsTarget", m_ClassName );
  }

  public static var SignalTargetChanged:Signal = new Signal;
  public static var SignalTargetsTargetChanged:Signal = new Signal;

}
