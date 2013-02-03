import com.GameInterface.Waypoint;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import com.Utils.Colors;

class GUI.Waypoints.CustomWaypoint extends GUI.Waypoints.ScreenWaypoint
{
    var m_Background:MovieClip;
    
    function CustomWaypoint()
    {
        super();
    }

    function WriteText() : Void
    {
        if(m_Direction != "")
        {
            var waypoint:MovieClip = this["i_"+m_Direction];

            var arrowwidth:Number = (waypoint.i_Arrow._width);
            var textx:Number = (m_Direction == DIRECTION_LEFT ) ? arrowwidth : 0;
            var arrowx:Number = (m_Direction == DIRECTION_LEFT ) ? 0 : arrowwidth ;

            this["i_DistanceText"].text = m_WaypointText;
            this["i_NameText"].text = m_WaypointName;
        }
        else
        {
            trace("attempted to write waypoint before defining direction");
        }
    }
    
    
    function UpdateColor()
    {
        SetColor(m_Waypoint.m_Color);
    }
    
    function SetColor(color:Number)
    {
        var iconColorTransform:ColorTransform = new ColorTransform();
        iconColorTransform.rgb = color;
        
        var iconTransform:Transform = new Transform(  this["i_TintLayerLeft"] );
        iconTransform.colorTransform = iconColorTransform;
        iconTransform = new Transform(  this["i_TintLayerCenter"] );
        iconTransform.colorTransform = iconColorTransform;
        iconTransform = new Transform(  this["i_TintLayerRight"] );
        iconTransform.colorTransform = iconColorTransform;
    }
    
    function GetHeight()
    {
      return m_Background._height+this["i_DistanceText"]._height;
    }
    
    function GetWidth()
    {
        return m_Background._width;
    }

    function Update(screenWidth:Number)
    {        
        if (!m_Enabled)
        {
            if (_visible)
            {
                _visible = false;
            }
            return;
        }
        else if (m_Enabled && !_visible)
        {
            _visible = true;
        }
            
        if (m_Waypoint.m_DistanceToCam < m_Waypoint.m_MinViewDistance || ( m_Waypoint.m_MaxViewDistance > 0 && m_Waypoint.m_DistanceToCam > m_Waypoint.m_MaxViewDistance ))
        {
            if (_visible) 
            {
                _visible = false;
            }
        }
        else if (!_visible)
        {
            _visible = true;
        }
		_z = 0;
        
        var dist:String = int(m_Waypoint.m_DistanceToCam).toString(); 
        if(dist != m_WaypointText)
        {
          SetText(dist);
        }
        if(m_Waypoint.m_ScreenPositionX < 0)
        {
          if(m_Direction != DIRECTION_LEFT)
          {
            SetDirection("left");
          }
          _x = 0 + 15;
        }
        else if(m_Waypoint.m_ScreenPositionX > screenWidth)
        {
          if(m_Direction != DIRECTION_RIGHT)
          {
            SetDirection("right");
          }
          _x = screenWidth - 15;
        }
        else if(m_Waypoint.m_ScreenPositionX >= 0 && m_Waypoint.m_ScreenPositionX <= screenWidth )
        {
          if(m_Direction != DIRECTION_CENTER)
          {
            SetDirection("center");
          }
          _x = m_Waypoint.m_ScreenPositionX + m_Waypoint.m_CollisionOffsetX;
          _y = m_Waypoint.m_ScreenPositionY + m_Waypoint.m_CollisionOffsetY;
		  _z = m_Waypoint.m_DistanceToCam;
        }
    }
    
    function SetDirection(direction:String)
    {
        super.SetDirection(direction);
        
        //Must update this manually as colortransforms does not carry well over frames
        if (direction == DIRECTION_LEFT)
        {
            this["i_TintLayerLeft"]._visible = true;
            this["i_TintLayerRight"]._visible = false;
            this["i_TintLayerCenter"]._visible = false;
        }
        
        else if (direction == DIRECTION_RIGHT)
        {
            this["i_TintLayerLeft"]._visible = false;
            this["i_TintLayerRight"]._visible = true;
            this["i_TintLayerCenter"]._visible = false;        
        }
        else if (direction == DIRECTION_CENTER)
        {
            this["i_TintLayerLeft"]._visible = false;
            this["i_TintLayerRight"]._visible = false;
            this["i_TintLayerCenter"]._visible = true;   
            if (m_Waypoint.m_Radius > 0)
            {
                this["i_TintLayerCenter"]["i_TintLayerArea"]._visible = true;
                this["i_TintLayerCenter"]["i_TintLayerSingle"]._visible = false;
            }
            else
            {
                this["i_TintLayerCenter"]["i_TintLayerArea"]._visible = false;
                this["i_TintLayerCenter"]["i_TintLayerSingle"]._visible = true;
            }
            
        }
    }
}