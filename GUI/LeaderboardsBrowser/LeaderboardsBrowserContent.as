//Imports
import com.Components.WindowComponentContent;
import com.GameInterface.BrowserImageMetadata;
import com.GameInterface.Browser.Browser;
import com.Utils.ImageLoader;
import gfx.controls.UILoader;
import mx.utils.Delegate;
import flash.geom.Point;

//Class
class GUI.LeaderboardsBrowser.LeaderboardsBrowserContent extends WindowComponentContent
{
    //Properties
    private var m_MouseListener:Object;
    private var m_Loader:UILoader;
    private var m_Browser:Browser;
    private static var SCROLL_AMOUNT:Number = 32;
    
    //Constructor
    public function LeaderboardsBrowserContent()
    {
        super();
    }
    
    //On Load
    private function configUI():Void
    {
        super.configUI();

        m_Browser = new Browser(_global.Enums.WebBrowserStates.e_BrowserMode_Leaderboards, m_Loader._width, m_Loader._height);
        m_Browser.OpenURL("http://profile.thesecretworld.com");

        m_Loader.loadMovie( "img://browsertexture/" + m_Browser.GetBrowserName() );
        
        onMouseMove = Delegate.create(this, MouseMoveEventHandler);
        onMouseDown = Delegate.create(this, MouseDownEventHandler);
        onMouseUp = Delegate.create(this, MouseUpEventHandler);
        
        m_MouseListener = new Object();
        m_MouseListener.onMouseWheel = Delegate.create(this, MouseWheelEventHandler);
        Mouse.addListener(m_MouseListener);

        m_Browser.SetFocus(true);
        Selection.setFocus(this);        
    }
    
    private function onUnload():Void
    {
        super.onUnload();
        onMouseMove = undefined;
        onMouseDown = undefined;
        onMouseUp = undefined;
        Mouse.removeListener(m_MouseListener);
        Selection.setFocus(null);
    }
    
    //Mouse Move Event Handler
    private function MouseMoveEventHandler():Void
    {
        if ( m_Loader!=undefined && m_Loader.hitTest(_root._xmouse, _root._ymouse, true) && Mouse["IsMouseOver"](m_Loader))
        {
            m_Browser.MouseMove(GetBrowserMouseLocation().x, GetBrowserMouseLocation().y);
        }
    }
    
    //Mouse Down Event Handler
    private function MouseDownEventHandler():Void
    {
        if (m_Loader!=undefined && m_Loader.hitTest(_root._xmouse, _root._ymouse, true) && Mouse["IsMouseOver"](m_Loader))
        {   
            m_Browser.MouseDown(GetBrowserMouseLocation().x, GetBrowserMouseLocation().y);
        }
    }
    
    //Mouse Wheel Event Handler
    private function MouseWheelEventHandler(delta:Number):Void
    {
        if ( m_Loader!=undefined && m_Loader.hitTest(_root._xmouse, _root._ymouse, true) && Mouse["IsMouseOver"](m_Loader))
        {
            m_Browser.MouseWheel(delta * SCROLL_AMOUNT);
        }
    }
        
    //Mouse Up Event Handler
    private function MouseUpEventHandler():Void
    {
        if (m_Loader!=undefined && m_Loader.hitTest(_root._xmouse, _root._ymouse, true) && Mouse["IsMouseOver"](m_Loader))
        {
            m_Browser.SetFocus(true);
            Selection.setFocus(this);
            
            m_Browser.MouseUp(GetBrowserMouseLocation().x, GetBrowserMouseLocation().y);
        }
        else
        {
            m_Browser.SetFocus(false);
            Selection.setFocus(null);
        }
    }
    
    //Get Browser Mouse Location
    private function GetBrowserMouseLocation():Point
    {
        var result:Point = new Point();
        result.x = _root._xmouse - this._parent._x - this._x;
        result.y = _root._ymouse - this._parent._y - this._y;
        
        return result;
    }
    
    //Deconstruct
    public function Deconstruct():Void
    {
        m_Browser.CloseBrowser();
        
        delete m_BrowserData;
        m_BrowserData = undefined;
        
        Selection.setFocus(null);
        m_Browser.CloseBrowser();
    }
}