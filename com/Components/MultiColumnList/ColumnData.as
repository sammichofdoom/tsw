class com.Components.MultiColumnList.ColumnData
{
	public var m_Id:Number;
	public var m_Flags:Number;
	public var m_Label:String;
	public var m_Width:Number;
	public var m_DefaultWidth:Number;
	public var m_MinWidth:Number;
	
	public function ColumnData()
	{
		m_MinWidth = 25;
	}
	
	
	public static var COLUMN_DISABLED:Number 		= 1 << 0;
	public static var COLUMN_NON_RESIZEABLE:Number 	= 1 << 1;
	public static var COLUMN_HIDE_LABEL:Number 		= 1 << 2;
	public static var COLUMN_NOT_SORTABLE:Number 	= 1 << 3;
	
	public function IsDisabled()
	{
		return (m_Flags & COLUMN_DISABLED) != 0;
	}
	
	public function ShouldShowLabel()
	{
		return (m_Flags & COLUMN_HIDE_LABEL) == 0;
	}
	
	public function CanResize()
	{
		return (m_Flags & COLUMN_NON_RESIZEABLE) == 0;
	}
	
	public function CanSort()
	{
		return (m_Flags & COLUMN_NOT_SORTABLE) == 0;
	}
}