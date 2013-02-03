intrinsic class com.Utils.Format
{
    public function Format( formatStr:String );

    public function AddData( data );
    public function GetString() : String;

    ////////////////////////////////////////////////////////////////////////////////
    /// @fn Printf( formatStr:String, ... );
    /// Vararg function taking a boost::format() compatible format string and a
    /// variable number of arguments to fill in the format string variables.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public static function Printf( formatStr:String /*[...]*/) : String;
	
	///Formats a number into a formatted string (in the current locale)
    public static function FormatNumeric(number:Number) : String;
}