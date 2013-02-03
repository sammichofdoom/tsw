import com.Utils.ID32

intrinsic class com.GameInterface.Waypoint
{
  
  public var m_Id:ID32;
  public var m_WaypointType:Number;
  public var m_Label:String;
  public var m_IsScreenWaypoint:Boolean;
  public var m_IsStackingWaypoint:Boolean;
  public var m_Radius:Number;
  public var m_Color:Number;
  
  public var m_WaypointState:Number;
  
  public var m_ScreenPositionX:Number;
  public var m_ScreenPositionY:Number;
  public var m_CollisionOffsetX:Number;
  public var m_CollisionOffsetY:Number;
  
  public var m_WorldPosition:com.GameInterface.MathLib.Vector3;
  
  public var m_MinViewDistance:Number;
  public var m_MaxViewDistance:Number;
  
  public var m_DistanceToCam:Number;
    
}
