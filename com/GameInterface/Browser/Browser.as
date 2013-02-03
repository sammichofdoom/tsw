import flash.external.*
import com.Utils.Signal;
import com.GameInterface.Utils.*;
import com.GameInterface.Tooltip.*;

intrinsic class com.GameInterface.Browser.Browser
{
    public static function IsBrowserActive():Boolean;
    
    /// Constructor.
    public function Browser(browserState:Number, width:Number, height:Number);
    
    public var SignalStartLoadingURL:Signal; //<String url>
    public var SignalBrowserShowPage:Signal;
    public var SignalAdjustXY:Signal;

    public function CloseBrowser():Void;
    public function GetBrowserState():Number;
    public function GetBrowserName():String;
    public function OpenURL(url:String):Void;
    public function OpenFacebookURL():Void;
    public function Stop():Void;
    
    public function MouseMove( x:Number, y:Number )
    public function MouseUp( button:Number )
    public function MouseDown( button:Number )
    public function MouseWheel( delta:Number )

    public function SetFocus( focus:Boolean )
}
