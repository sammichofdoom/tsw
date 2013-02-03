import CommonLib.StandardFlashWindowClass;
/**
 * ...
 * @author bertrandr@funcom.com
 */
class MainItemShopBrowser {
	
	static private var _flash:MovieClip;
	
	public function MainItemShopBrowser() {
		
	}
	
	public static function main(swfRoot:MovieClip):Void {
		// entry point
	
		_flash = swfRoot;
		var browser:ItemShopBrowserClass = new ItemShopBrowserClass(_flash.attachMovie("ItemShopFrame", "shopWindow", _flash.getNextHighestDepth()));
		
		//var _window:StandardFlashWindowClass = new StandardFlashWindowClass(_flash.window_mc);
	}
	
}
