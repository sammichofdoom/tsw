import com.Components.WindowComponentContent;
import com.Utils.Signal;
import flash.geom.Point;

class GUI.Tutorial.TutorialWindow extends WindowComponentContent
{
    
    public static var s_Height:Number;
    public static var s_Width:Number;
    
    public var SignalRedraw:Signal;
    
    public function TutorialWindow()
    {
        super();
        CreateCanvas();
        SignalRedraw = new Signal();
    }
    
    public function SetSize(width:Number, height:Number)
    {
        s_Width = width;
        s_Height = height;
        
        clear()
        lineStyle(2, 0xFFFFFF, 50);
        moveTo(0, 0);
        lineTo(s_Width,0 );
        
        SignalRedraw.Emit();
        SignalSizeChanged.Emit();
    }
    
    public function GetSize() : Point
    {
        return new Point(s_Width, s_Height);
    }

    public function ClearCanvas()
    {
        if (this["m_Canvas"] != undefined)
        {
            this["m_Canvas"].removeMovieClip();
        }
    }
    
    public function GetCanvas()
    {
        if (this["m_Canvas"] != undefined)
        {
            return this["m_Canvas"];
        }
        else
        {
            return CreateCanvas();
        }
    }
    
    public function CreateCanvas() : MovieClip
    {
        var canvas = createEmptyMovieClip("m_Canvas", getNextHighestDepth());
        return canvas
    }
}