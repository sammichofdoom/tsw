class com.Components.MultiColumnList.MCLItem
{
	private var m_Id:Object;
	
	public function MCLItem(id:Object)
	{
		m_Id = id;
	}
	
	public function GetId():Object
	{
		return m_Id;
	}
	
	public function SetId(id:Object)
	{
		m_Id = id;
	}
	
	public function Compare(sortColumn:Number, item:MCLItem)
	{
		return this > item;
	}
		
	private function CompareString(string1:String, string2:String)
	{
        if (string1 == undefined)
        {
            string1 = "";
        }
        if (string2 == undefined)
        {
            string2 = "";
        }
        string1 = string1.toLowerCase();
        string2 = string2.toLowerCase();

		if (string1 > string2)
		{
			return 1;
		}
		else if (string1 < string2)
		{
			return -1;
		}
		else return 0;
	}
	
	private function CompareNumber(number1:Number, number2:Number)
	{
		if (number1 > number2)
		{
			return 1;
		}
		else if (number1 < number2)
		{
			return -1;
		}
		else return 0;
	}
}