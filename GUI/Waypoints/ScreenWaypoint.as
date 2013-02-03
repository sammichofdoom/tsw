import com.GameInterface.Waypoint

///Base class for a screenwaypoint, with basic definitions of functions
class GUI.Waypoints.ScreenWaypoint extends MovieClip
{
  var m_WaypointText:String;
  var m_WaypointName:String;
  var m_Direction:String;
  var m_Enabled:Boolean;
  var m_IsArea:Boolean;
  var m_Waypoint:Waypoint;

  
  public static var DIRECTION_NONE:String = "none"
  public static var DIRECTION_RIGHT:String = "right"
  public static var DIRECTION_LEFT:String = "left"
  public static var DIRECTION_CENTER:String = "center"
  var tf:TextFormat;
  

  function ScreenWaypoint()
  {
    tf = new TextFormat();
    tf.font =  "_StandardFont";
    tf.size = 12;
    tf.color = 0xFFFFFF;
    m_Enabled = true;
  }
  
  function SetDirection(p_direction:String)
  {
    if(p_direction == DIRECTION_LEFT || p_direction == DIRECTION_RIGHT || p_direction == DIRECTION_CENTER)
    {
      m_Direction = p_direction;
      this.gotoAndStop( p_direction );
      if(m_WaypointText != "")
      {
        WriteText();
      }
    }
  }
  
  function Enable(enabled:Boolean)
  {
      m_Enabled = enabled;
  }

  function SetText( p_text:String ) : Void
  {
    m_WaypointText = p_text;
    WriteText();
  }
  
  function GetHeight()
  {
      return _height;
  }
  
  function GetWidth()
  {
      return _width;
  }
  
  function SetName(name:String) : Void
  {
      m_WaypointName = name;
      WriteText();
  }
  function WriteText() : Void
  {
    return;
  }
  
  function Update(screenWidth:Number)
  {
    return;
  }
  
  function UpdateColor()
  {
  }
  
  function SetColor(color:Number)
  {
  }
  
  function SetWaypoint(waypoint:Waypoint)
  {
      m_Waypoint = waypoint;
      //In case it is not fully initialized, we wait until the next frame to set properties
      this.onEnterFrame = function()
      {
          SetText(m_Waypoint.m_Label);
          SetName(m_Waypoint.m_Label);
          UpdateColor();
          delete this.onEnterFrame;
      }
  }
  
}