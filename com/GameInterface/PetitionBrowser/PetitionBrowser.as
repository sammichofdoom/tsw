import flash.external.*
import com.Utils.*;
import com.GameInterface.Utils.*;
import com.GameInterface.Tooltip.*;

intrinsic class com.GameInterface.PetitionBrowser.PetitionBrowser
{
  public function OpenBrowser()
  public function CloseBrowser()
	public function IsBrowserActive():Boolean;

  // code -> character selection
  public var SignalBrowserShowPage:Signal;
  public var SignalAdjustXY:Signal;

  public function MouseMove( x:Number, y:Number )
  public function MouseUp( button:Number )
  public function MouseDown( button:Number )
  public function MouseWheel( delta:Number )

  public function SetFocus( focus:Boolean )
}
