import gfx.controls.Slider;
import mx.utils.Delegate;

class com.Components.FCSlider extends Slider
{
	private var m_SliderDividerArray:Array;
	
    function FCSlider()
    {
        super();
		m_SliderDividerArray = new Array;
    }
	
	public function set maximum(value:Number):Void
	{
		super.maximum = value;
		
		DrawDividers();
	}

	public function get maximum():Number
	{
		return super.maximum;
	}
    
	public function set snapping(value:Boolean):Void 
	{
		super.snapping = value;
		
		DrawDividers();
	}
	
	private function DrawDividers() 
	{
		for ( var i = 0; i < m_SliderDividerArray.length; i++ )
		{
			m_SliderDividerArray[i].removeMovieClip();
		}
		
		m_SliderDividerArray = new Array;

		if ( snapping && !isNaN(maximum) && maximum < track._width )
		{
			for ( var i = 0; i < maximum - 1; i++ )
			{
				var divider = track.attachMovie("SliderDivider", "divider_" + i, track.getNextHighestDepth() );
				m_SliderDividerArray.push(divider);
				divider._x = ((track._width / maximum) * i) + (track._width / maximum);
				divider._y = 4;
			}
		}
	}
	
}