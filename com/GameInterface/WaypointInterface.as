import com.Utils.Signal;

/// This class contains information about all the waypoints
///
/// There are two different types of waypoints, screenwaypoints and mapwaypoints
/// screenwaypoints are shown on the screen, while mapwaypoints are shown on the map

intrinsic class com.GameInterface.WaypointInterface
{
  public static var SignalPlayfieldChanged:Signal;
   
  public var SignalWaypointAdded:Signal;
  public var SignalWaypointRemoved:Signal;
  public var SignalWaypointMoved:Signal;
  public var SignalWaypointStateChanged:Signal;
  public var SignalWaypointColorChanged:Signal;
  public var SignalWaypointRenamed:Signal;
  
  public var m_Waypoints:Object;
  
  public function GetExistingWaypoints(pfID:Number);
}
  