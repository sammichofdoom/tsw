import gfx.core.UIComponent;
import gfx.controls.Button;
import flash.geom.Rectangle;
import mx.utils.Delegate;
import com.Utils.Signal;


class com.Components.WindowComponent extends UIComponent
{
    private var m_Size:Rectangle
    private var m_ContentSize:Rectangle;
    private var m_ResizeButton:MovieClip;
    private var m_Background:MovieClip;
    public var m_Content:MovieClip;
    private var m_CloseButton:MovieClip;
    
    private var m_MinHeight:Number;
    private var m_MinWidth:Number;
    private var m_TmpHeigth:Number;
    private var m_TmpWidth:Number;
    private var m_ResizeListener:Object;
    private var m_MoveListener:Object;
    
    private var TOP:Number = 0;
    private var RIGHT:Number = 1;
    private var BOTTOM:Number = 2;
    private var LEFT:Number = 3;
    
    private var m_Padding:Array;
    private var m_ResizeSensitivity:Number; /// how many pixels change in  height or width before we call sizechanged, might be set with SetResizeSensitivity()
    
    private var m_Title:TextField;
    
    public var SignalClose:Signal;
    public var SignalSizeChanged:Signal;
    
    public function WindowComponent()
    {

        m_Size = new Rectangle( this._x, this._y, this._width, this._height); 
        m_ContentSize = m_Size.clone();

        m_Padding = [];
        SetPadding(20, 10, 20, 10);
       
        m_ResizeSensitivity = 10;
        
        SignalClose = new Signal();
        SignalSizeChanged = new Signal();
    }
    
    private function configUI() : Void
    {
        m_ResizeButton.onPress = Delegate.create(this, ResizeDrag);
        m_ResizeButton.onRelease = m_ResizeButton.onReleaseOutside = Delegate.create(this, ResizeDragRelease);
        
        m_Background.onPress =  Delegate.create(this, MoveDrag);
        m_Background.onRelease = m_Background.onReleaseOutside  = Delegate.create(this, MoveDragRelease);
        
        m_CloseButton.addEventListener("click", this, "CloseButtonHandler");
        m_CloseButton.disableFocus = true;
    }
    
    public function GetSize() : Rectangle
    {
        return m_Size;
    }
    
    public function SetSize(newSize:Rectangle) : Void
    {
        m_Size = newSize;
        UpdateContentSize();
        Layout();
    }
    
    public function GetContentSize() : Rectangle
    {
        return m_ContentSize;
    }
    
    public function SetResizeSensitivity(sensitivity:Number) : Void
    {
        m_ResizeSensitivity = sensitivity;
    }
    
    private function UpdateContentSize()
    {
        m_ContentSize.x = m_Size.x + m_Padding[LEFT];
        m_ContentSize.y = m_Size.y + m_Padding[TOP];
        m_ContentSize.width = m_Size.width - m_Padding[RIGHT] - m_Padding[LEFT];
        m_ContentSize.height = m_Size.height - m_Padding[BOTTOM] - m_Padding[TOP];        
    }
    
    public function SetPadding(top:Number, right:Number, bottom:Number, left:Number)
    {
        m_Padding[TOP] = top;
        m_Padding[RIGHT] = right;
        m_Padding[BOTTOM] = bottom;
        m_Padding[LEFT] = left;
        
        UpdateContentSize();
        
        m_Content._x = left;
        m_Content._y = top;
    }
    
    public function SetTitle(title:String) : Void
    {
        m_Title.text = title;
    }
    
    public function SetMinWidth(width:Number) : Void
    {
        m_MinWidth = width;
    }
    
    public function SetMinHeight(height:Number) : Void
    {
        m_MinHeight = height;
    }
    
    private function ResizeDrag()
    {
        m_TmpHeigth = m_Size.height;
        m_TmpWidth = m_Size.width;
        
        m_ResizeListener = { };
        m_ResizeListener.onMouseMove = Delegate.create(this, MouseResizeMoving);
        
        Mouse.addListener( m_ResizeListener ); 
    }
    
    private function ResizeDragRelease()
    {
        SignalSizeChanged.Emit();
        Mouse.removeListener( m_ResizeListener );
        m_ResizeListener = undefined;
    }
    
    private function MoveDrag()
    {
        this.startDrag();
        
        m_MoveListener = { };
        m_MoveListener.onMouseMove = Delegate.create(this, MouseDragMoving);
        
        Mouse.addListener( m_MoveListener ); 
    }
    
    private function MoveDragRelease()
    {
        this.stopDrag();
        Mouse.removeListener( m_MoveListener );
        m_MoveListener = undefined;
    }
    
    private function MouseDragMoving()
    {
        m_Size.x = this._x;
        m_Size.y = this._y
    }
    
    private function MouseResizeMoving()
    {
        var xin:Number = Math.max( this._xmouse, m_MinWidth);
        var yin:Number = Math.max(this._ymouse, m_MinHeight);
        var xdiff:Number = Math.abs(m_Size.width - xin );
        var ydiff:Number = Math.abs(m_Size.height - yin);
        
        
        m_Size.width = xin;
        m_Size.height = yin;
        
        UpdateContentSize();
        
        if (xdiff > m_ResizeSensitivity || ydiff > m_ResizeSensitivity) 
        {
            SignalSizeChanged.Emit();
        }
        
        Layout();
    }
    
    public function Layout()
    {
        this._x = m_Size.x;
        this._y = m_Size.y;
        
        m_Background._width = m_Size.width;
        m_Background._height = m_Size.height;
        
        m_ResizeButton._x = m_Size.width - m_ResizeButton._width;
        m_ResizeButton._y = m_Size.height - m_ResizeButton._height;
        
        m_CloseButton._x = m_Size.width - m_CloseButton._width - m_Padding[RIGHT];
    }
    
    private function CloseButtonHandler()
    {
        SignalClose.Emit();
    }
}