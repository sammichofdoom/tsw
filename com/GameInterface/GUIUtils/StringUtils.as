	//// string and number formatting utils
	
	class com.GameInterface.GUIUtils.StringUtils
	{

		/// formats a number to string, adding capital K for thousands and Capital M for millions
		/// @param p_number:Number - the number to convert
		public static function NumberToString(p_number:Number) : String
		{
			var str:String;
			
			if(p_number > 9999999)
			{
				str = String( Math.round(p_number/100000) );
				var len:Number = str.length;
				var decimal:String = str.substring(len-1, len);
				var whole:String = str.substring(0, len-1);
			//	trace("Utils:NumberToString - "+String(whole + "."+decimal+"m") );
				return String(whole + "."+decimal+"m");
				
			}
			else if(p_number > 99999)
			{
				str = String( Math.round(p_number/1000) );
				return String(str +  "k");
			}
			else
			{
				return String(p_number)
			}
		}
	}	