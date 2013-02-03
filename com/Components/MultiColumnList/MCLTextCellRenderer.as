import com.Components.MultiColumnList.MCLItemValueData;

class com.Components.MultiColumnList.MCLTextCellRenderer extends com.Components.MultiColumnList.MCLBaseCellRenderer
{
	var m_Padding:Number;
	
	public function MCLTextCellRenderer(parent:MovieClip, id:Number, valueData:MCLItemValueData)
	{
		super(parent, id);
		m_Padding = 4;
		
		var style:TextFormat = new TextFormat;
		style.font = "_StandardFont";
		style.size = valueData.m_TextSize != undefined ? valueData.m_TextSize : 15;
		style.color = valueData.m_TextColor != undefined ? valueData.m_TextColor : 0xFFFFFF;
		style.align = valueData.m_TextAlignment != undefined ? valueData.m_TextAlignment : "left";
		style.leftMargin = valueData.m_TextPadding != undefined ? valueData.m_TextPadding : m_Padding;
		style.rightMargin = valueData.m_TextPadding != undefined ? valueData.m_TextPadding : m_Padding;
		
		m_MovieClip = m_Parent.createEmptyMovieClip("m_Column_" +id,  m_Parent.getNextHighestDepth());
		m_MovieClip.hitTestDisable = true;
		m_MovieClip.createTextField("m_Text", m_MovieClip.getNextHighestDepth(), 0, 0, 0, 0);
		m_MovieClip.m_Text.setNewTextFormat(style);
		m_MovieClip.m_Text.selectable = false;
		m_MovieClip.m_Text.text = valueData.m_Text != undefined ? valueData.m_Text : valueData.m_Number;
	}
	
	public function SetText(text:String)
	{
		m_MovieClip.m_Text.text = text;
	}
	
	public function SetPos(x:Number, y:Number)
	{
		m_MovieClip._x = x;
		m_MovieClip._y = y;
	}
	
	public function SetSize(width:Number, height:Number)
	{
		m_MovieClip.m_Text._width = width;
		m_MovieClip.m_Text._height = m_MovieClip.m_Text.textHeight + 3;
		
		m_MovieClip.m_Text._y = (height - m_MovieClip.m_Text.textHeight) / 2;
	}
	
	public function GetDesiredWidth() : Number
	{
		return m_MovieClip.m_Text.textWidth + 5; 
	}
}