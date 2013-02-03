intrinsic class com.Utils.LDBFormat
{
    public function LDBFormat( formatStr:String );

    public function AddData( data );
    public function GetString() : String;

    ////////////////////////////////////////////////////////////////////////////////
    /// @fn Printf( formatStr:String, ... );
    /// Vararg function taking a LDBformat compatible format string and a
    /// variable number of arguments to fill in the format string variables.
    ///
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public static function Printf( formatStr:String /*[...]*/ ) : String;

    ////////////////////////////////////////////////////////////////////////////////
    /// Retrieve an entry from the LDB. Both category and instance can either be a
    /// string containing a category name / instance token, or a numerical value.
    ///
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public static function LDBGetText( category, instance ) : String;


    ////////////////////////////////////////////////////////////////////////////////
    /// Perform the same translation on 'text' that is normally performed on all
    /// text added to a TextField in Flash. Except the "$Category:Token" string
    /// since that is depricated.
    ///
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public static function Translate( text:String ) : String;
	
	// Returns the current language code (de, en, fr, ...)
    public static function GetCurrentLanguageCode() : String;

    
}
