import com.Utils.ID32;

intrinsic class com.GameInterface.ProjectUtilsBase
{
    static function SendBugreport(title:String, comment:String, bugCategory:String, includeScreenShot:Boolean, includeNPC:Boolean, includePlayer:Boolean, email:String );
    static function CloseBugreport();
	static function CloseLogoutWindow();
	static function CancelLogout();
    
    static function StartQuitGame();
	static function QuitGame();

	static function GetUint32TweakValue(tweakValueName:String) : Number;
	
	static function GetTokenName(tokenID:Number):String;
    static function GetTokenDescription(tokenID:Number):String;
    static function GetTokenIcon(tokenID:Number):String;
    static function GetTokenAmount(tokenID:Number):Number;
    static function GetTokenIdArray():Array; //<Number>
	
    public static function BuyInventorySlots(inventoryID:ID32);
    public static function CalculateNextExpansionPrice(inventoryID:ID32);
	
	public static function GetInteractionType(dynelId:ID32):Number;
	public static function SetInteractionDynel(dynelId:ID32):Number;

}