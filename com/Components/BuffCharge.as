import gfx.motion.Tween; 
import mx.transitions.easing.*;
import flash.geom.ColorTransform;
import flash.geom.Transform;


// This is how the graphics is built up and why:
// Symbol:  s_BuffCharge          = The charge. Not touched by the class.
//           i_Offset             = This offsets the rest based on lower right corener.
//            i_PosLayer          = Top left pos, use to move the charge using tween.
//              i_ScaleLayer      = Centered. Used for scaling the charge using tween.
//                i_MainLayer     = Keeps the back and the text on top of each other.
//                  i_Back        = Scale9grid border with a tintlayer in it.
//                    i_TintLayer = For tinting the background.
//                  i_Text        = The text. Needs to be outside the scale9grid as the background is scaled based on the text.

class com.Components.BuffCharge extends MovieClip
{
  public var m_Charge:Number = -1; // -1 to indicate that no charges has been set.
  public var m_Max:Number = 0;
  public var m_Over:Boolean = false;
  public var i_Offset:MovieClip;

  public function BuffCharge()
  {
	  i_Offset.i_PosLayer.i_ScaleLayer.i_MainLayer.i_Text.autoSize = "right";
  }

  public function SetColor( color )
  {
    var iconTransform:Transform = new Transform( i_Offset.i_PosLayer.i_ScaleLayer.i_MainLayer.i_Back.i_TintLayer );
    var iconColorTransform:ColorTransform = new ColorTransform();
    iconColorTransform.rgb = color;
    iconTransform.colorTransform = iconColorTransform;
  }

  // Set the max number. This will only be shown if moused over.
  public function SetMax( max )
  {
    m_Max = max;
    SetText( m_Charge, m_Max );
  }

  // Set the charge number. Effects will be played according to increase or decrease.
  public function SetCharge( charge )
  {
    SetText( charge, m_Max );

    // Only run effects if not over and if we had some legal value before.
    if( !m_Over && m_Charge > 0 )
    {
      if( charge > m_Charge )
      {
        // Charge went up. Scale the charge up and then back.
        i_Offset.i_PosLayer.i_ScaleLayer.tweenTo( 0.3, {_xscale:150,_yscale:150}, Back.easeOut )
        i_Offset.i_PosLayer.i_ScaleLayer.onTweenComplete = function ()
		    {
          // Only scale back if not over.
// 			    if( !_parent._parent._parent.m_Over ) // Must use the parents for unknown reasons.
// 			    {
            this.tweenTo( 0.3, {_xscale:100,_yscale:100}, Back.easeOut )
            this.onTweenComplete = undefined;
//			    }
		    }
      }
      else if( charge < m_Charge )
      {
        // Drop down to indicate loosing some charges.
        i_Offset.i_PosLayer.tweenTo( 0.3, {_y:10}, Back.easeOut )
        i_Offset.i_PosLayer.onTweenComplete = function ()
        {
		      this.tweenTo( 0.3, {_y:0}, Back.easeOut )
          this.onTweenComplete = undefined;
        }
      }
    }
    m_Charge = charge;
  }

  // Set text and calculated new backgroundsize based on it.
  function SetText( charge, max )
  {
    i_Offset.i_PosLayer.i_ScaleLayer.i_MainLayer.i_Text.text = charge + (m_Over?("/"+max):"");
    // Some 'magic' numbers that makes the background fit with the current font.
	  i_Offset.i_PosLayer.i_ScaleLayer.i_MainLayer.i_Back._xscale = 55 + (0.57 * (i_Offset.i_PosLayer.i_ScaleLayer.i_MainLayer.i_Text._width-44))
  }


  // Show the max and scale it when moused over.
  function onRollOver()
  {
    m_Over = true;
    SetText( m_Charge, m_Max );
    // Zoom the number.
	  i_Offset.i_PosLayer.i_ScaleLayer.tweenTo( 0.3, {_xscale:150,_yscale:150}, Back.easeOut )
    i_Offset.i_PosLayer.i_ScaleLayer.onTweenComplete = undefined;
  }

  function onRollOut()
  {
    m_Over = false;
    SetText( m_Charge, m_Max );
    // Scale it back.
	  i_Offset.i_PosLayer.i_ScaleLayer.tweenTo( 0.3, {_xscale:100,_yscale:100}, Back.easeOut )
    i_Offset.i_PosLayer.i_ScaleLayer.onTweenComplete = undefined;
  }


}

