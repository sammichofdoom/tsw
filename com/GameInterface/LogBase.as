import com.Utils.Signal;

intrinsic class com.GameInterface.LogBase
{
    public static function SetMsgForward( value:Boolean ) : Void;
    public static function GetMsgForward() : Boolean;  
    
    public static function GetMsgCache() : Array;
    
    /// Log an error to the client log.
    /// @param category  [in] The category, for example the name of the class/file reporting the message.
    /// @param message   [in] The message object. Should start with the function name for context 
    ///                       and try to make the message unique so we easily can search for it in .as code.
    public static function Error( category:String, message:Object ) : Void
    
    /// Log a warning to the client log.
    /// @param category  [in] The category, for example the name of the class/file reporting the message.
    /// @param message   [in] The message object. Should start with the function name for context 
    ///                       and try to make the message unique so we easily can search for it in .as code.
    public static function Warning( category:String, message:Object ) : Void
    
    /// Log an info2 message to the client log.
    /// @param category  [in] The category, for example the name of the class/file reporting the message.
    /// @param message   [in] The message object. Should start with the function name for context 
    ///                       and try to make the message unique so we easily can search for it in .as code.
    public static function Info2( category:String, message:Object ) : Void
    
    /// Log an info1 message to the client log.
    /// @param category  [in] The category, for example the name of the class/file reporting the message.
    /// @param message   [in] The message object. Should start with the function name for context 
    ///                       and try to make the message unique so we easily can search for it in .as code.
    public static function Info1( category:String, message:Object ) : Void
    
    /// Log an info0 message to the client log.
    /// @param category  [in] The category, for example the name of the class/file reporting the message.
    /// @param message   [in] The message object. Should start with the function name for context 
    ///                       and try to make the message unique so we easily can search for it in .as code.
    public static function Info0( category:String, message:Object ) : Void
    
    /// Log an message to the client log.
    /// @param level     [in] The level (0-4)
    /// @param category  [in] The category, for example the name of the class/file reporting the message.
    /// @param message   [in] The message string. Should start with the function name for context 
    ///                       and try to make the message unique so we easily can search for it in .as code.
    public static function Print( level:Number, category:String, message:String ) : Void    
    
    public static var SignalMsg:Signal;     
}
