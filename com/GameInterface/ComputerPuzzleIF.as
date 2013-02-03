import com.Utils.Signal;

intrinsic class com.GameInterface.ComputerPuzzleIF
{
    public static function GetText() : String;
    public static function GetQuestions() : Array;
    public static function AcceptPlayerInput(inputString:String) : Boolean;
    public static function Close() : Void;
    
    public static var SignalQuestionsUpdated : Signal; 
    public static var SignalTextUpdated : Signal ; 
    public static var SignalClose : Signal; 
}
