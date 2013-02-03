import com.Components.MultiColumnList.MCLItemValueData;

class com.Components.MultiColumnList.MCLItemValue
{
	public var m_Value:MCLItemValueData;
	public var m_Type:Number;
	
	public function MCLItemValue(value:MCLItemValueData, type:Number)
	{
		m_Value = value;
		m_Type = type;
	}
}