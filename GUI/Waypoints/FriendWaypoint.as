import com.GameInterface.Waypoint;

class GUI.Waypoints.FriendWaypoint extends GUI.Waypoints.ScreenWaypoint
{

  function FriendWaypoint()
  {
    super();
  }
  
  function WriteText() : Void
  {
    this["autotext"].removeTextField();
    if(m_Direction != "")
    {
      var waypoint:MovieClip = this["i_"+m_Direction];
      
      var arrowwidth:Number = (waypoint.i_Arrow._width);
      var textx:Number = (m_Direction == DIRECTION_LEFT ) ? arrowwidth : 0;
      var arrowx:Number = (m_Direction == DIRECTION_LEFT ) ? 0 : arrowwidth ;
      
      /// create the textfield and write to it
      var autotext:TextField = this.createTextField("autotext", this.getNextHighestDepth(), 0, -4, 0, 0);
      autotext.setNewTextFormat( tf );	
      //autotext.embedFonts = true;
      autotext.selectable = false;
      autotext.autoSize = m_Direction;
      autotext.text = "";
      autotext.text = m_WaypointText;
      
      var autotextwidth:Number = autotext._width;
      
      var endx:Number = (m_Direction == DIRECTION_LEFT ) ? (autotextwidth) : -(autotextwidth);
      waypoint.i_Background._width = autotextwidth;
      waypoint.i_Background._x = 0;
      waypoint.i_End._x = endx;
      waypoint.i_Arrow._x = arrowx;
      
      ///position textfield and bits
    }
    else
    {
      trace("attempted to write waypoint before defining direction");
    }
  }
  
  function Update(screenWidth:Number)
  {
    if(m_Waypoint.m_ScreenPositionX < 0 && m_Direction != DIRECTION_LEFT)
    {
      _visible = true;
      _x = 0 + 15;
      SetDirection("left");
    }
    else if(m_Waypoint.m_ScreenPositionX > screenWidth && m_Direction != DIRECTION_RIGHT)
    {
      _visible = true;
      _x = screenWidth - 15;
      SetDirection("right");
    }
    else if(m_Waypoint.m_ScreenPositionX >= 0 && m_Waypoint.m_ScreenPositionX <= screenWidth && m_Direction != DIRECTION_NONE)
    {
      m_Direction = DIRECTION_NONE;
      _visible = false;
    }
  }
}