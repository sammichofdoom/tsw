import com.Utils.ID32;
import com.GameInterface.Utils;
import com.Components.MultiColumnList.MCLItemRenderer;

class com.Components.MultiColumnList.MCLMovieClipCellRenderer extends com.Components.MultiColumnList.MCLBaseCellRenderer
{
	var m_Width:Number;
	var m_Height:Number;
    var m_MovieClipArray:Array;
	
	public function MCLMovieClipCellRenderer(parent:MCLItemRenderer, id:Number, movieClip:Object)
	{
		super(parent, id);
		
        m_MovieClipArray = new Array();
		m_Width = 0;
		m_Height = 0;
				
		m_MovieClip = m_Parent.createEmptyMovieClip("m_Column_" +id,  m_Parent.getNextHighestDepth());
		
        if (movieClip instanceof Array)
        {
            for (var i:Number = 0; i < movieClip.length; i++)
            {
                LoadMovieClip(parent, movieClip[i]);
            }
        }
        else
        {
            LoadMovieClip(parent, movieClip);
        }
	}
	
    private function LoadMovieClip(parent:MCLItemRenderer, movieClip:Object):Void
    {
        var rdbId:ID32 = ID32(movieClip);
		if (rdbId != undefined)
		{
			var loadClip:MovieClip = m_MovieClip.createEmptyMovieClip("m_Content_" + m_MovieClip.UID(), m_MovieClip.getNextHighestDepth());
			var loader:MovieClipLoader = new MovieClipLoader();
			loader.addListener(this);
			loader.loadClip(Utils.CreateResourceString(rdbId), loadClip);
            
            m_MovieClipArray.push(loadClip);
		}
		else
		{
			var movie = m_MovieClip.attachMovie(movieClip.toString(), "m_Content_" + m_MovieClip.UID(), m_MovieClip.getNextHighestDepth());
			movie.hitTestDisable = true;
			parent.MovieClipAdded(GetId(), movie);
            
            m_MovieClipArray.push(movie);
		}
    }
    
	public function SetPos(x:Number, y:Number)
	{
		m_MovieClip._x = x;
		m_MovieClip._y = y;
	}
	
	public function onLoadComplete(target:MovieClip)
	{
        m_Parent.MovieClipAdded(GetId(), target);
		//Update scale of movieclip
		if (m_Width > 0 && m_Height > 0)
		{
			SetSize(m_Width, m_Height);
		}
	}
	
	public function SetSize(width:Number, height:Number)
	{
		m_Width = width;
		m_Height = height;
        
        if (m_MovieClip != undefined && m_MovieClip._width > 0 && m_MovieClip._height > 0)
		{
            var x:Number = 0;
            
            for (var i:Number = 0; i < m_MovieClipArray.length; i++)
            {
                m_MovieClipArray[i]._x = x;
                x += m_MovieClipArray[i]._width + 5;
            }
            
			var heightPercentage:Number = (height - 2) / m_MovieClip._height;
			var widthPercentage:Number = (width - 2) / m_MovieClip._width;
			
			var percentage:Number = Math.min(heightPercentage, widthPercentage);
			
			m_MovieClip._width *= percentage;
			m_MovieClip._height *= percentage;
			
			//m_MovieClip.m_Content._x = ((width - m_MovieClip._width) / 2) * (100 / m_MovieClip._yscale);
            
            var xAddition:Number = ((width - m_MovieClip._width) / 2) * (100 / m_MovieClip._yscale);
            var y:Number = ((height - m_MovieClip._height) / 2) * (100 / m_MovieClip._xscale);
            
            for (var i:Number = 0; i < m_MovieClipArray.length; i++)
            {
                m_MovieClipArray[i]._x += xAddition;
                m_MovieClipArray[i]._y = y;
            }
            
			//m_MovieClip.m_Content._y = ((height - m_MovieClip._height) / 2) * (100 / m_MovieClip._xscale);
			
		}
	}
	
	public function GetDesiredWidth() : Number
	{
		return m_Width; 
	}
}