import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.UtilsBase
{
	public static function PrintChatText(text:String) : Void;
    public static function ParseHTMLColor(name:String) : Number;
    public static function ParseHTMLFont(name:String) : Object;
    
    public static function PlaySound(soundName:String) : Void;
    
    public static function PlayFeedbackSound(feedbackSoundName:String) : Void;
    public static function PlayFeedbackSoundEnum(feedbackSoundEnum:Number) : Void;
    

    /// Get a tweakvalue. This should preferable only be done once at startup, per value you need. Instead of every time you need it.
    /// In the case of changing the tweak, the .swf file should be reloaded to get this value again.
    /// @param name     [in]  The name of the tweakvalue.
    /// @param          [out] The value. Returns 0 if not found.    
    public static function GetGameTweak( name:String ) : Number;

    /// Get the scalable (affected by the /time chat command) timer used by most
    /// systems in the game. Granularity is milliseconds or better.
    public static function GetGameTime() : Number;
	
    public static function GetNormalTime() : Number;
    
    public static function GetTimeOfDay() : Number;

    /// Get GMT time syncronized with the server. Granularity is seconds.
    public static function GetServerSyncedTime() : Number;
    
    public static function StartTrade(tradeCharacter:ID32);
    ///Accept the current trade
    public static function AcceptTrade();
	
    ///Modify the current trade
    public static function NoLongerAcceptTrade();
    
    ///Abort the current trade
    public static function AbortTrade();
    
    public static function AttenuateGameSounds(attenuate:Boolean) : Void;
    
    public static function SetTradeCash(cash:Number);
    
    /// Signal sent when the splashscreen is activated or deactivated.
    /// @param activated:Boolean    True if splash was shown, else false.
    public static var SignalSplashScreenActivated:Signal; // -> OnSplashScreenActivated( activated:Boolean )

    /// Signal sent when login prefs has been loaded. This happens right after you have logged in.
    /// @param reloaded:Boolean    True if it was a reload.
    public static var SignalLoginPrefsLoaded:Signal; // -> OnLoginPrefsLoaded( reloaded:Boolean )

    /// Signal sent when you've logged out.
    public static var SignalLoginPrefsPostUnload:Signal; // -> OnLoginPrefsPostUnload()

    /// Signal sent when you chosen a character and it's prefs has been loaded.
    /// @param reloaded:Boolean    True if it was a reload.
    public static var SignalCharacterPrefsLoaded:Signal; // -> OnCharacterPrefsLoaded( reloaded:Boolean )

    /// Signal sent when the characters prefs are about to be unloaded.
    public static var SignalCharacterPrefsPreUnload:Signal; // -> OnCharacterPrefsPreUnload()

    /// Signal sent when the characters prefs has been unloaded.
    public static var SignalCharacterPrefsPostUnload:Signal; // -> OnCharacterPrefsPostUnload()
    
	///Signal sent whenever the object under the mouse changes
	public static var SignalObjectUnderMouseChanged:Signal;
	
    public static var SignalTradeStarted:Signal;
    public static var SignalTradeEnded:Signal;
    public static var SignalPartnerAccepted:Signal;
    public static var SignalPartnerNoLongerAccepted:Signal;
    public static var SignalClientCharAccepted:Signal;
    public static var SignalClientCharNoLongerAccepted:Signal;
    public static var SignalPartnerCashUpdated:Signal;
}