class  com.Utils.StringUtils
{
	public static function LStrip(string:String):String
	{
		var i:Number = 0;
		while (IsWhiteSpace(string.charCodeAt(i)))
		{
			i++;
		}
		return string.substr(i, string.length);
	}
	
	public static function RStrip(string:String):String
	{
		var i:Number = string.length-1;
		while (IsWhiteSpace(string.charCodeAt(i)))
		{
			i--;
		}
		return string.substr(0, i+1);
	}
	
	public static function Strip(string:String):String
	{
		return LStrip(RStrip(string))
	}
	
	private static function IsWhiteSpace(charCode:Number)
	{
		return (charCode == 9 || charCode == 10 || charCode == 13 || charCode == 32)
	}
}