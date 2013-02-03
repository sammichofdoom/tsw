import flash.external.*;
import gfx.motion.Tween;
import mx.transitions.easing.*
import gfx.managers.PopUpManager;
import gfx.managers.DragManager;
import com.GameInterface.Utils;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import GUI.Tooltip.ProjectTooltipInterface;
import GUIFramework.SFClipLoader;
import GUIFramework.ClipNode;

class com.GameInterface.Tooltip.TooltipManager
{
	private static var m_instance:TooltipManager;
	private static var m_WindowIndex:Number = 0;

	public static function GetInstance():TooltipManager 
	{
		if (m_instance == undefined) 
		{
			m_instance = new TooltipManager();
		}
		return m_instance;
	}
	

	public function TooltipManager()
	{
	}

    /// Display a tooltip. ShowTooltip() opens a tooltip window displaying the
    /// data from tooltipData and the optional 4th argument that can be an array
    /// of additional TooltipData objects that will be displayed next to the
    /// main tooltip (used for comparision mode).
    /// The first argument (targetClip) can be either null or a MovieClip.
    /// If it is null the tooltip arrow will point towards the current mouse
    /// position. If targetClip is a valid MovieClip the arrow will point at
    /// the edge of this clip. The clip can be moved later with
    /// TooltipInterface.SetPosition(). The orientation argument specify
    /// wether the different panels should be layed out vertically
    /// (TooltipInterface.e_OrientationVertical) or horizontally
    /// (TooltipInterface.e_OrientationHorizontal) when displaying multiple panels.
    ///
    /// The return value is a TooltipInterface that will be the interface for
    /// further interaction with the tooltip. Through this interface you can
    /// move the tooltip, convert it into a floating window with a close button
    /// or close it.
    
	public function ShowTooltip( targetClip:MovieClip, orientation:Number, delay:Number, tooltipData:TooltipData ) : TooltipInterface
	{
		var tooltipDataArray:Array = [ tooltipData ];

        if ( delay < 0 )
        {
            delay = DistributedValue.GetDValue( "HoverInfoShowDelay" );
        }
		if ( arguments.length > 4 )
		{
			var currentlyEquipped:Array = arguments[4];
			tooltipDataArray = tooltipDataArray.concat( currentlyEquipped );
		}

        var tooltipIF:ProjectTooltipInterface = new ProjectTooltipInterface( orientation, tooltipDataArray );
        
        var delegate:Object = new Object( { m_TooltipIF:tooltipIF, m_Delay:delay } );
        
        delegate.SlotLoaded = function( clipNode:ClipNode, succeded:Boolean )
        {
            if ( this.m_Delay != 0 )
            {
                clipNode.m_Movie._alpha = 0;
                //Need to check if the tweenTo function on the movie is undefined, as the movie never is set to undefined (Just a bad reference)
                _global['setTimeout'] (function() { if (clipNode.m_Movie.tweenTo != undefined) { clipNode.m_Movie.tweenTo( 0.7, { _alpha:100 }, Strong.easeOut ) } }, this.m_Delay * 1000 );
            }
            clipNode.m_Movie.SetTooltipInterface( this.m_TooltipIF );
            delete clipNode["tooltipDelegate"];
        }
        
        var clipNode:ClipNode = SFClipLoader.LoadClip( "Tooltip.swf", "TooltipWindow" + m_WindowIndex++, false, _global.Enums.ViewLayer.e_ViewLayerTooltip, 0 );
        clipNode["tooltipDelegate"] = delegate; // Make sure the garbage collector don't eat the delegate object.
        clipNode.SignalLoaded.Connect( null, delegate.SlotLoaded, delegate );
        
        if ( targetClip != null )
        {
            var bounds = targetClip.getBounds( _root );
            var targetSize:flash.geom.Point = new flash.geom.Point( bounds.xMax - bounds.xMin, bounds.yMax - bounds.yMin );
            var targetPos:flash.geom.Point = new flash.geom.Point( bounds.xMin + targetSize.x * 0.5, bounds.yMin + targetSize.y * 0.5 );
            tooltipIF.SetPosition( targetPos, targetSize );
        }
        else
        {
			//Adding a size to not have tooltip on top of mouse
            tooltipIF.SetPosition( new flash.geom.Point( _root._xmouse, _root._ymouse ), new flash.geom.Point( 40, 40 ) );
        }
        return tooltipIF;
	}
}
