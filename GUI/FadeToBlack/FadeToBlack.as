import com.GameInterface.Utils;
import com.Utils.SignalGroup;
import gfx.motion.Tween; 
import mx.transitions.easing.*;

var m_BlackScreen:MovieClip;

function onLoad()
{
  com.Utils.GlobalSignal.SignalFadeScreen.Connect( SlotFadeScreen, this );
  attachMovie( "_BlackScreen", "m_BlackScreen", getNextHighestDepth() );
  m_BlackScreen._alpha = 0;
  m_BlackScreen._visible = false;
}

function onUnload()
{
}


function SlotFadeScreen( fadeIn:Boolean, time:Number )
{
  var visibleRect = Stage["visibleRect"];
  _x = visibleRect.x;
  _y = visibleRect.y;
  m_BlackScreen._xscale = visibleRect.width;
  m_BlackScreen._yscale = visibleRect.height;
  m_BlackScreen._visible = true;

  m_BlackScreen.tweenEnd(true);
  if( fadeIn )
  {
    // Fade in game, and delete blackness when done.
      if ( time > 0 )
      {
          m_BlackScreen.tweenTo( time, { _alpha:0 }, Strong.easeOut);
		  m_BlackScreen.onTweenComplete = function()
		  {
			this._visible = false;
		  }
      }
      else
      {
          m_BlackScreen._alpha = 0;
		  m_BlackScreen._visible = false;
      }
  }
  else
  {
      if ( time > 0 )
      {
          m_BlackScreen.tweenTo( time, { _alpha:100 }, Strong.easeOut);
		  m_BlackScreen.onTweenComplete = null;
      }
      else
      {
          m_BlackScreen._alpha = 100;
      }
  }

}
