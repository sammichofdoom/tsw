import com.Utils.Signal;

intrinsic class com.GameInterface.Puzzle
{
    /// Close the puzzle.
    public static function Close() : Void;
    
    /// Send a message to the server.
    public static function SendMessageToServer( msg:String ) : Void;

    public static var SignalMessage:Signal;
}
