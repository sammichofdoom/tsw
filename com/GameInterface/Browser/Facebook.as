import com.Utils.Signal;

intrinsic class com.GameInterface.Browser.Facebook
{
    public static var SignalReceivedFriendsList:Signal;
    public static var SignalAskToSignUp:Signal;
    public static var SignalInterfaceUpdated:Signal;
    
    public static function IsConnectedToFacebook():Boolean;
    public static function IsInterfaceUpdateReceived():Boolean;
    public static function GetFriendsByDimensionId(dimensionId:Number):Array; //return Array of String (friendNames)
}
