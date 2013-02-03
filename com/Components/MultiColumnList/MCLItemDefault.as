import com.Components.MultiColumnList.MCLItem;
import com.Components.MultiColumnList.MCLItemValue;
import com.Components.MultiColumnList.MCLItemValueData;

class com.Components.MultiColumnList.MCLItemDefault extends MCLItem
{
	public static var LIST_ITEMTYPE_STRING 				    = 0;
	public static var LIST_ITEMTYPE_NUMBER				    = 1;
	public static var LIST_ITEMTYPE_MOVIECLIP_SYMBOL	    = 2;
	public static var LIST_ITEMTYPE_MOVIECLIP_RDB		    = 3;
	public static var LIST_ITEMTYPE_MOVIECLIP_AND_TEXT	    = 4;
    public static var LIST_ITEMTYPE_STRING_SORT_BY_NUMBER	= 5;
	
	private var m_Values:Object;
	
	public function MCLItemDefault(id:Object)
	{
		super(id);
		m_Values = new Object();
	}
	
	public function SetValue(id:Number, value:MCLItemValueData, valueType:Number)
	{
		m_Values[id] = new MCLItemValue(value, valueType);
	}
	
	public function GetValues():Object
	{
		return m_Values;
	}
	
	public function Compare(sortColumn:Number, item:MCLItem)
	{
		var defaultItem:MCLItemDefault = MCLItemDefault(item);
		var value:MCLItemValue = m_Values[sortColumn];
		var compareValue:MCLItemValue  = defaultItem.GetValues()[sortColumn];
		
		if (value != undefined && compareValue != undefined)
		{
			switch(value.m_Type)
			{
			case LIST_ITEMTYPE_STRING:
				{
					return CompareString(value.m_Value.m_Text, compareValue.m_Value.m_Text);
				}
			case LIST_ITEMTYPE_NUMBER:
				{
					return CompareNumber(value.m_Value.m_Number, compareValue.m_Value.m_Number);
				}
            case LIST_ITEMTYPE_MOVIECLIP_SYMBOL:
            case LIST_ITEMTYPE_MOVIECLIP_RDB:
			case LIST_ITEMTYPE_MOVIECLIP_AND_TEXT:
				{
					if (value.m_Value.m_Text != undefined)
					{
						return CompareString(value.m_Value.m_Text, compareValue.m_Value.m_Text);
					}
					else
					{
						return CompareNumber(value.m_Value.m_Number, compareValue.m_Value.m_Number);
					}
				}
            case LIST_ITEMTYPE_STRING_SORT_BY_NUMBER:
				{
					return CompareNumber(value.m_Value.m_Number, compareValue.m_Value.m_Number);
				}
			}
		}
		return super.Compare(sortColumn, item);
	}
}