import gfx.controls.Button;

class com.Components.MultiColumnList.HeaderButton extends Button
{
	private var m_Id;
	private var m_LabelText:String;
	
	private var m_CanSort:Boolean;
	
	private var m_SortArrow:MovieClip;
	
	private var m_SortDirection:Number;
	private var m_Type:Number;
	
	public static var HEADER_NORMAL = 0;
	public static var HEADER_FIRST = 1;
	public static var HEADER_LAST = 2;
	
	public function HeaderButton()
	{
		super();
		m_CanSort = true;
		m_SortDirection = 0;
		if (m_SortArrow != undefined)
		{
			m_SortArrow._visible = false;
		}
	}
	
	public function SetId(id:Number)
	{
		m_Id = id;
	}
	
	public function GetId()
	{
		return m_Id;
	}
	
	public function SetCanSort(canSort:Boolean )
	{
		m_CanSort = canSort;
		if (!m_CanSort)
		{
			m_SortArrow._visible = false;
		}
	}
	
	public function SetShowArrow(show:Boolean)
	{
		m_SortArrow._visible = show;
	}
	
	public function SetLabel(label:String)
	{
		m_LabelText = label;
		textField.text = m_LabelText;
	}
	
	public function SetWidth(newWidth:Number)
	{
		if (!initialized)
		{
			_width = newWidth;
		}
		else
		{
			_width = newWidth;
			width = newWidth;
		}
	}
	
	public function SetType(type:Number)
	{
		switch(type)
		{
			case HEADER_NORMAL:
				break;
			case HEADER_FIRST:
				break;
			case HEADER_LAST:
				break;
		}
	}
    
    public function SetSortDirection(direction:Number):Void
    {
        m_SortDirection = direction;
    }

	private function handleClick(controllerIdx:Number, button:Number):Void 
	{
		super.handleClick(controllerIdx, button);
		if (m_CanSort)
		{
			m_SortArrow._visible = true;
			if (m_SortDirection == 0)
			{
				m_SortArrow.tweenTo(0.6, { _rotation:0 }, mx.transitions.easing.Back.easeOut);
			}
			else
			{
				m_SortArrow.tweenTo(0.6, { _rotation:-179 }, mx.transitions.easing.Back.easeOut);
			}
			dispatchEvent( { type:"sort", direction:m_SortDirection, id:m_Id } );
			m_SortDirection = m_SortDirection == 0 ? Array.DESCENDING : 0;
		}		
	}
}