import com.Components.MultiColumnList.MCLItemValueData;
import com.Components.MultiColumnList.MCLItemRenderer;
class com.Components.MultiColumnList.MCLMovieClipAndTextCellRenderer extends com.Components.MultiColumnList.MCLBaseCellRenderer
{
	var m_Padding:Number;
	var m_MovieClipWidth:Number;
	
	public function MCLMovieClipAndTextCellRenderer(parent:MCLItemRenderer, id:Number, valueData:MCLItemValueData)
	{
		super(parent, id);		
		
		m_Padding = 5;
		
		m_MovieClipWidth = valueData.m_MovieClipWidth;
		
		var style:TextFormat = new TextFormat;
		style.font = "_StandardFont";
		style.size = valueData.m_TextSize != undefined ? valueData.m_TextSize : 15;
		style.color = valueData.m_TextColor != undefined ? valueData.m_TextColor : 0xFFFFFF;
		style.align = valueData.m_TextAlignment != undefined ? valueData.m_TextAlignment : "left";
		style.leftMargin = valueData.m_TextPadding != undefined ? valueData.m_TextPadding : 4;
		style.rightMargin = valueData.m_TextPadding != undefined ? valueData.m_TextPadding : 4;
		
		m_MovieClip = m_Parent.createEmptyMovieClip("m_Column_" +id,  m_Parent.getNextHighestDepth());
		var movieClip = m_MovieClip.attachMovie(valueData.m_MovieClipName, "m_MovieClip", m_MovieClip.getNextHighestDepth());
		//Default disable hit test, that needs to be turned back on to be used as a button etc.
		movieClip.hitTestDisable = true;
		parent.MovieClipAdded(id, movieClip);
		m_MovieClip.createTextField("m_Text", m_MovieClip.getNextHighestDepth(), 0, 0, 0, 0);

		m_MovieClip.m_Text.hitTestDisable = true;
		m_MovieClip.m_Text._x = m_MovieClip.m_MovieClip._width + 5;
		m_MovieClip.m_Text.setNewTextFormat(style);
		m_MovieClip.m_Text.selectable = false;
		m_MovieClip.m_Text.text = valueData.m_Text != undefined ? valueData.m_Text : valueData.m_Number;
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
			
			var heightPercentage:Number = (height - 5) / m_MovieClip.m_MovieClip._height;
			var widthPercentage:Number = (width - 5) / m_MovieClip.m_MovieClip._width;
			
			var percentage:Number = heightPercentage; 
			
			if (m_MovieClipWidth != undefined)
			{
				 percentage = Math.min(heightPercentage, widthPercentage);
			}
			
			m_MovieClip.m_MovieClip._width *= percentage;
			m_MovieClip.m_MovieClip._height *= percentage;
			
			m_MovieClip.m_MovieClip._y = ((height - m_MovieClip.m_MovieClip._height) / 2);
			
			if (m_MovieClipWidth != undefined)
			{
				m_MovieClip.m_MovieClip._x = ((m_MovieClipWidth - m_MovieClip.m_MovieClip._width) / 2);
				m_MovieClip.m_Text._x = m_MovieClipWidth + m_Padding;
			}
			else
			{
				m_MovieClip.m_MovieClip._x = m_Padding
				m_MovieClip.m_Text._x = m_MovieClip.m_MovieClip._x + m_MovieClip.m_MovieClip._width + m_Padding;
			}
			
			m_MovieClip.m_Text._width = width - m_MovieClip.m_Text._x;
			m_MovieClip.m_Text._height = m_MovieClip.m_Text.textHeight + 3;
			m_MovieClip.m_Text._y = (height - m_MovieClip.m_Text.textHeight) / 2;
			
		}
	}
	
	public function GetDesiredWidth() : Number
	{
		return m_MovieClip.m_Text._x + m_MovieClip.m_Text._width; 
	}
}