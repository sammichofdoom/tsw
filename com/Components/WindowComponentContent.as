import flash.geom.Point;
import gfx.core.UIComponent;
import com.Utils.Signal;
dynamic class com.Components.WindowComponentContent extends UIComponent
{
    public var SignalSizeChanged:Signal;
	public var SignalLoaded:Signal;
    
    function WindowComponentContent()
    {
        SignalSizeChanged = new Signal();
		SignalLoaded = new Signal();
    }
    
    public function SetSize(width:Number, height:Number)
    {
        trace("Setting size base");
    }
    public function GetSize():Point
    {
        return new Point(_width, _height);
    }
	
	public function configUI()
	{
		super.configUI();
		SignalLoaded.Emit();
	}
    
    public function SetData()
    {
        trace("SetData base with " + arguments.length + " arguments");
    }
    
    public function Close()
    {
        trace("Close base")
    }
}
