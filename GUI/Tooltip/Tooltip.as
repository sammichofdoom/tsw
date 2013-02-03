import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import GUI.Tooltip.ProjectTooltipInterface;

var index:Number = 0;
    
function SetTooltipInterface( tooltipInterface:ProjectTooltipInterface ) : Void
{
    var tooltipContainer = createEmptyMovieClip( "tooltipContainer_" + index++, getNextHighestDepth(), tooltipDataArray );
    tooltipInterface.SetTooltipContainer( tooltipContainer );
}