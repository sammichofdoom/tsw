import com.Components.MultiColumnList.MCLBaseCellRenderer;
import com.Components.MultiColumnList.MCLItemRenderer;
class com.Components.FeatList.MCLFeatCostCellRenderer extends MCLBaseCellRenderer
{	
	public function MCLFeatCostCellRenderer(parent:MCLItemRenderer, id:Number, cost:Number)
	{
		super(parent, id);
		
		m_MovieClip = m_Parent.createEmptyMovieClip("m_Column_" +id,  m_Parent.getNextHighestDepth());
		
		var movie = m_MovieClip.attachMovie("BuyButton", "m_Content", m_MovieClip.getNextHighestDepth());
		movie.SetCost(cost)
		movie.hitTestDisable = true;
		parent.MovieClipAdded(id, movie);	
	}
	
	public function SetPos(x:Number, y:Number)
	{
		m_MovieClip._x = x;
		m_MovieClip._y = y;
	}
	
	public function SetSize(width:Number, height:Number)
	{
		if (m_MovieClip != undefined && m_MovieClip._width > 0 && m_MovieClip._height > 0)
		{
			var heightPercentage:Number = (height - 25) / m_MovieClip._height;
			var widthPercentage:Number = (width - 25) / m_MovieClip._width;
			
			var percentage:Number = Math.min(heightPercentage, widthPercentage);
			
			m_MovieClip._width *= percentage;
			m_MovieClip._height *= percentage;
			
			m_MovieClip.m_Content._x = ((width - m_MovieClip._width) / 2) * (100 / m_MovieClip._yscale);
			m_MovieClip.m_Content._y = ((height - m_MovieClip._height) / 2) * (100 / m_MovieClip._xscale);
			
		}
	}
	
	public function GetDesiredWidth() : Number
	{
		return m_MovieClip._width; 
	}
}