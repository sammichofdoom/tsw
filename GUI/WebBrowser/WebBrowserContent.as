//Imports
import com.Components.WindowComponentContent;
import com.GameInterface.BrowserImageMetadata;
import com.GameInterface.Browser.Browser;
import com.GameInterface.DistributedValue;
import com.Utils.ImageLoader;
import com.Utils.Signal;
import com.Utils.Colors;
import gfx.controls.UILoader;
import mx.utils.Delegate;
import flash.geom.Point;

//Class
class GUI.WebBrowser.WebBrowserContent extends WindowComponentContent
{
    //Constants
    private static var REFRESH_MODE:String = "refreshMode";
    private static var STOP_MODE:String = "stopMode"
    private static var SCROLL_AMOUNT:Number = 32;
    private static var ADDRESS_STROKE_HIGHLIGHT:Number = 0x00AAFF;
    private static var ADDRESS_STROKE_DEFAULT:Number = 0x717171;
    
    //Properties
    private var m_BackButton:MovieClip;
    private var m_ForwardButton:MovieClip;
    private var m_AddressBar:MovieClip;
    private var m_Loader:UILoader;
    private var m_Browser:Browser;
    private var m_CurrentAddress:String;
    private var m_History:Array;
    private var m_HistoryIndex:Number;
    private var m_MouseListener:Object;
    
    //Constructor
    public function WebBrowser()
    {
        super();
    }
    
    //On Load
    private function configUI():Void
    {
        super.configUI();
        m_BackButton.disabled = true;
        m_ForwardButton.disabled = true;
        
        m_BackButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        m_ForwardButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        m_AddressBar.m_RefreshButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        m_AddressBar.m_StopButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
        PositionAddressBar();
        
        m_Browser = new Browser(_global.Enums.WebBrowserStates.e_BrowserMode_Browser, m_Loader._width, m_Loader._height);

        var url:String = DistributedValue.GetDValue( "WebBrowserStartURL" );
        if ( url != undefined && url != "" )
        {
            DistributedValue.SetDValue( "WebBrowserStartURL", "" );
            m_Browser.OpenURL(url);
        }
        else
        {
            m_Browser.OpenURL("http://www.google.com");
        }
        m_Browser.SignalStartLoadingURL.Connect(SlotLoadingPageStart, this);
        m_Browser.SignalBrowserShowPage.Connect(SlotLoadingPageComplete, this);

        m_Loader.loadMovie( "img://browsertexture/" + m_Browser.GetBrowserName() );
        
        m_History = new Array();
        m_HistoryIndex = -1;
        
        var keyboardListener:Object = new Object();
        keyboardListener.onKeyUp = Delegate.create(this, AddressBarEnterKeyEventHandler);
        Key.addListener(keyboardListener);
        
        m_MouseListener = new Object();
        m_MouseListener.onMouseWheel = Delegate.create(this, MouseWheelEventHandler);
        Mouse.addListener(m_MouseListener);
        
        onMouseMove = Delegate.create(this, MouseMoveEventHandler);
        onMouseDown = Delegate.create(this, MouseDownEventHandler);
        onMouseUp = Delegate.create(this, MouseUpEventHandler);

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
    
    //Slot Loading Page Start
    private function SlotLoadingPageStart(url:String):Void
    {

            
        ToggleAddressBarButton(STOP_MODE);
        
        m_CurrentAddress = m_AddressBar.m_InputText.text = url;

        if (m_History[m_HistoryIndex] != url)
        {
            if (m_HistoryIndex < m_History.length - 1)
            {
                m_History.splice(m_HistoryIndex + 1);
            }
        
            m_History.push(url);
            m_HistoryIndex++;
        }
        
        ToggleNavigationButtons();
    }
    
    //Slot Loading Page Complete
    private function SlotLoadingPageComplete():Void
    {
        ToggleAddressBarButton(REFRESH_MODE);
    }
    
    //Change History Index
    private function ChangeHistoryIndex(index:Number):Void
    {
        if (index < 0 || index > m_History.length)
        {
            return;
        }

        m_HistoryIndex = index;

        m_Browser.OpenURL(m_History[m_HistoryIndex]);

        ToggleNavigationButtons();
    }
    
    //Toggle Navigation Buttons
    private function ToggleNavigationButtons():Void
    {
        m_BackButton.disabled = (m_HistoryIndex > 0) ? false : true;
        m_ForwardButton.disabled = (m_HistoryIndex < m_History.length - 1) ? false : true;
    }

    //Position Address Bar
    private function PositionAddressBar():Void
    {
        m_BackButton._x = 0 + m_BackButton._width;
        
        m_ForwardButton._x = m_BackButton._x + 2;
        
        m_AddressBar._x = m_ForwardButton._x + m_ForwardButton._width + 10;
        m_AddressBar.m_Background._width = m_Loader._width - m_AddressBar._x;
        m_AddressBar.m_RefreshButton._x = m_AddressBar.m_Background._width - m_AddressBar.m_RefreshButton._width - 5;
        m_AddressBar.m_RefreshButton._visible = false;
        m_AddressBar.m_StopButton._x = m_AddressBar.m_RefreshButton._x;
        m_AddressBar.m_InputText._width = m_AddressBar.m_RefreshButton._x - m_AddressBar.m_InputText._x;
    }
    
    //Slot Button Selected
    private function SlotButtonSelected(target:Object):Void
    {
        switch (target)
        {
            case m_BackButton:                  ChangeHistoryIndex(m_HistoryIndex - 1);    
                                                break;
                                    
            case m_ForwardButton:               ChangeHistoryIndex(m_HistoryIndex + 1); 
                                                break;
                                    
            case m_AddressBar.m_RefreshButton:  m_Browser.OpenURL(m_CurrentAddress);
                                                ToggleAddressBarButton(STOP_MODE);
                                                
                                                break;
                                    
            case m_AddressBar.m_StopButton:     m_Browser.Stop();
                                                ToggleAddressBarButton(REFRESH_MODE);
        }
    }
    
    //Toggle Address Bar Button
    private function ToggleAddressBarButton(mode:String):Void
    {
        switch (mode)
        {
            case REFRESH_MODE:  m_AddressBar.m_RefreshButton._visible = true;
                                m_AddressBar.m_StopButton._visible = false;
                            
                                break;
                            
            case STOP_MODE:     m_AddressBar.m_RefreshButton._visible = false;
                                m_AddressBar.m_StopButton._visible = true;
        }
    }

    //Address Bar Enter Key Event Handler
    private function AddressBarEnterKeyEventHandler():Void
    {
        if (Key.getCode() == Key.ENTER && Selection.getFocus() == String(eval(m_AddressBar.m_InputText)))
        {
            var url:String = m_AddressBar.m_InputText.text;
            var path:String = "://";
            var prefix:String = "http" + path;
            
            if (url.indexOf(path) == -1)
            {
                url = prefix + url;
            }
        
            m_Browser.OpenURL(url);
        }
    }
    
    //Mouse Wheel Event Handler
    private function MouseWheelEventHandler(delta:Number):Void
    {
        if (m_Loader!=undefined && m_Loader.hitTest(_root._xmouse, _root._ymouse, true) && Mouse["IsMouseOver"](m_Loader))
        {
            m_Browser.MouseWheel(delta * SCROLL_AMOUNT);
        }
    }
   
    //Mouse Move Event Handler
    private function MouseMoveEventHandler():Void
    {
        if (m_Loader!=undefined && m_Loader.hitTest(_root._xmouse, _root._ymouse, true) && Mouse["IsMouseOver"](m_Loader))
        {
             m_Browser.MouseMove(GetBrowserMouseLocation().x, GetBrowserMouseLocation().y);
        }
    }
    
    //Mouse Down Event Handler
    private function MouseDownEventHandler():Void
    {
        if (m_Loader!=undefined && m_Loader.hitTest(_root._xmouse, _root._ymouse, true) && Mouse["IsMouseOver"](m_Loader))
        {   
            m_Browser.SetFocus(true);
            Selection.setFocus(this);
            
            m_Browser.MouseDown(GetBrowserMouseLocation().x, GetBrowserMouseLocation().y);
        }
        else if (m_AddressBar.hitTest(_root._xmouse, _root._ymouse, true) && Mouse["IsMouseOver"](m_AddressBar))
        {
            Colors.ApplyColor(m_AddressBar.m_Background.m_Stroke, ADDRESS_STROKE_HIGHLIGHT);
            m_AddressBar.m_Background.m_Stroke._alpha = 100;
            m_Browser.SetFocus(false);
            //Selection.setFocus(this);
        }
        else
        {
            Colors.ApplyColor(m_AddressBar.m_Background.m_Stroke, ADDRESS_STROKE_DEFAULT);
            m_AddressBar.m_Background.m_Stroke._alpha = 60;
            m_Browser.SetFocus(false);
            Selection.setFocus(null);
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
    }
    
    //Get Browser Mouse Location
    private function GetBrowserMouseLocation():Point
    {
        var result:Point = new Point();
        result.x = _root._xmouse - this._parent._x - this._x - m_Loader._x;
        result.y = _root._ymouse - this._parent._y - this._y - m_Loader._y;
        
        return result;
    }
    
}
