class com.Components.InventoryItemList.MCLItemPriceCellRenderer extends com.Components.MultiColumnList.MCLBaseCellRenderer
{
	private var m_Type1:MovieClip;
	private var m_Price1:TextField;
	private var m_Type2:MovieClip;
	private var m_Price2:TextField;
	
	public function MCLItemPriceCellRenderer(parent:MovieClip, id:Number, type1:Number, price1:Number, type2:Number, price2:Number, priceColor1:Number, priceColor2:Number )
	{
		super(parent, id);
		
		var style1:TextFormat = new TextFormat;
		style1.font = "_StandardFont";
		style1.size = 15;
		style1.color = 0xFFFFFF;
		style1.leftMargin = 4;
		if (priceColor1 != undefined)
		{
			style1.color = priceColor1;
		}
		
		var style2:TextFormat = new TextFormat;
		style2.font = "_StandardFont";
		style2.size = 15;
		style2.color = 0xFFFFFF;
		style2.leftMargin = 4;
		if (priceColor2 != undefined)
		{
			style2.color = priceColor2;
		}
		
				
		m_MovieClip = m_Parent.createEmptyMovieClip("m_Column_" +id,  m_Parent.getNextHighestDepth());
		m_MovieClip.hitTestDisable = true;
		
		if (type1 != undefined && type1 > 0 && price1 != undefined && price1 > 0)
		{
			m_Type1 = m_MovieClip.attachMovie("T" + type1, "m_Type1", m_MovieClip.getNextHighestDepth());
			m_Price1 = m_MovieClip.createTextField("m_Price1", m_MovieClip.getNextHighestDepth(), 0, 0, 0, 0);
            m_Price1.autoSize = "left";
			m_Price1.setNewTextFormat(style1);
			m_Price1.selectable = false;
            m_Price1.text = price1.toString();
		}
		
		if (type2 != undefined && type2 > 0 && price2 != undefined && price2 > 0)
		{
			m_Type2 = m_MovieClip.attachMovie("T" + type2, "m_Type1", m_MovieClip.getNextHighestDepth());
			m_Price2 = m_MovieClip.createTextField("m_Price2", m_MovieClip.getNextHighestDepth(), 0, 0, 0, 0);
            m_Price2.autoSize = "left";
			m_Price2.setNewTextFormat(style2);
			m_Price2.selectable = false;
            m_Price2.text = price2.toString();
		}
	}
	
	public function SetPos(x:Number, y:Number)
	{
		m_MovieClip._x = x;
		m_MovieClip._y = y;
	}
	
	public function SetSize(width:Number, height:Number)
	{
		var percentage:Number = (height - 10) / m_Type1._height;
		
		m_Type1._width *= percentage;
		m_Type1._height *= percentage;
		
		percentage = (height - 10) / m_Type2._height;
		
		m_Type2._width *= percentage;
		m_Type2._height *= percentage;
		
		m_Type1._y = ((height - m_Type1._height) / 2);
		m_Type2._y = ((height - m_Type2._height) / 2);
		
		m_Price1._height = m_Price1.textHeight + 3;
		m_Price2._height = m_Price2.textHeight + 3;
		m_Price1._y = (height - m_Price1.textHeight) / 2;
		m_Price2._y = (height - m_Price2.textHeight) / 2;
		
		m_Type1._x = 5;
		m_Price1._x = m_Type1._x + m_Type1._width;
		m_Type2._x = m_Price1._x + m_Price1._width + 5;
		m_Price2._x = m_Type2._x + m_Type2._width;
	}
	
	public function GetDesiredWidth() : Number
	{
		return m_MovieClip._width; 
	}
}