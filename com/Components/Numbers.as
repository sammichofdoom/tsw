import gfx.motion.Tween; 
import mx.transitions.easing.*;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import com.Utils.Colors;

// This is how the graphics is built up and why:
// Symbol:  s_BuffCharge          = The charge. Not touched by the class.
//           m_Offset             = This offsets the rest based on lower right corener.
//            m_PosLayer          = Top left pos, use to move the charge using tween.
//              m_ScaleLayer      = Centered. Used for scaling the charge using tween.
//                m_MainLayer     = Keeps the back and the text on top of each other.
//                  m_Background        = Scale9grid border with a tintlayer in it.
//                    m_TintLayer = For tinting the background.
//                  m_Text        = The text. Needs to be outside the scale9grid as the background is scaled based on the text.

class com.Components.Numbers extends MovieClip
{
	public var m_Charge:Number = -1; // -1 to indicate that no charges has been set.
	public var m_Max:Number = 0; // 0 for no max, if no max is set. do not show the charge
	public var m_Over:Boolean = false;
	public var m_Offset:MovieClip;
    public var UseSingleDigits:Boolean = false;

	public function Numbers()
	{
		m_Offset.m_PosLayer.m_ScaleLayer.m_MainLayer.m_Text.text = "";
		m_Offset.m_PosLayer.m_ScaleLayer.m_MainLayer.m_Text.autoSize = "right";
	}

	public function SetColor( color )
  	{
		Colors.ApplyColor( m_Offset.m_PosLayer.m_ScaleLayer.m_MainLayer.m_Background.m_TintLayer, color);
	}
	
	public function SetFormat(format:TextFormat)
	{
		m_Offset.m_PosLayer.m_ScaleLayer.m_MainLayer.m_Text.setNewTextFormat(format);
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
				m_Offset.m_PosLayer.m_ScaleLayer.tweenTo( 0.3, {_xscale:150,_yscale:150}, Back.easeOut )
				m_Offset.m_PosLayer.m_ScaleLayer.onTweenComplete = function ()
				{
					this.tweenTo( 0.3, {_xscale:100,_yscale:100}, Back.easeOut )
					this.onTweenComplete = undefined;
				}
			}
			else if( charge < m_Charge )
			{
				// Drop down to indicate loosing some charges.
				m_Offset.m_PosLayer.tweenTo( 0.3, {_y:10}, Back.easeOut )
				m_Offset.m_PosLayer.onTweenComplete = function ()
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
		m_Offset.m_PosLayer.m_ScaleLayer.m_MainLayer.m_Text.text = charge + (m_Over?("/" + max):"");
		// Some 'magic' numbers that makes the background fit with the current font.
		m_Offset.m_PosLayer.m_ScaleLayer.m_MainLayer.m_Background._xscale = 55 + (0.57 * (m_Offset.m_PosLayer.m_ScaleLayer.m_MainLayer.m_Text._width - 44))
	}


	// Show the max and scale it when moused over.
	function onRollOver()
	{
        if (!UseSingleDigits && m_Max > 0)
        {
            m_Over = true;
            SetText( m_Charge, m_Max );
            // Zoom the number.
            m_Offset.m_PosLayer.m_ScaleLayer.tweenTo( 0.3, {_xscale:150,_yscale:150}, Back.easeOut )
            m_Offset.m_PosLayer.m_ScaleLayer.onTweenComplete = undefined;
        }
	}

	function onRollOut()
	{
        if (!UseSingleDigits && m_Max > 0)
        {
            m_Over = false;
            SetText( m_Charge, m_Max );
            // Scale it back.
            m_Offset.m_PosLayer.m_ScaleLayer.tweenTo( 0.3, {_xscale:100,_yscale:100}, Back.easeOut )
            m_Offset.m_PosLayer.m_ScaleLayer.onTweenComplete = undefined;
        }
	}
}

