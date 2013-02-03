import com.Utils.Signal;

intrinsic class com.GameInterface.AccountManagement 
{ 
    public static function GetInstance():AccountManagement;

    public function GetLoginState() : Number;
    public function LoginAccount(loginName:String, loginPassword:String):Void;
    public function CancelLogin():Void;
    public function LogoutAccount():Void;
    public function SelectCharacter(charId:Number):Void;
    public function RotateCharacter(delta:Number):Void;
    public function DeleteCharacter(charId:Number):Boolean;
    public function EnterGame(charId:Number, dimensionId:Number):Void;
    public function ShowAccountPage():Void;
    public function CreateCharacter(dimensionId:Number):Void;
    public function GetMaxCharSlots():Number;
    public function RenameCharacter( charInstance:Number, newName:String ) : Void;
    public function QuitGame():Number;
    
    public var m_Dimensions:Array;
    public var m_Characters:Array;
    
    public var SignalLoginStateChanged:Signal;     // SlotLoginStateChanged( state:Number )
    public var SignalCharacterNeedsNewName:Signal; // SlotCharacterNeedsNewName( charInstance:Number, reason:Number, requestedName:String )
    public var SignalCharacterDataUpdate:Signal;
    public var SignalDimensionDataUpdate:Signal;
}