import gfx.controls.Button;
import mx.utils.Delegate;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.DistributedValue;

class com.Components.FCButton extends Button
{
    private var m_TooltipText:String;
    private var m_Tooltip:TooltipInterface;
	private var m_TooltipTimeout:Number;
    
    function FCButton()
    {
        super();
        m_TooltipText = "";
        m_Tooltip = undefined;
		m_TooltipTimeout = undefined;
    }
    private function handleMouseRollOver(controllerIdx:Number):Void
    {
        super.handleMouseRollOver(controllerIdx);
        StartTooltipTimout();
    }
    
    // #state RollOut is only called by mouse interaction. Focus change happens in changeFocus.
    private function handleMouseRollOut(controllerIdx:Number):Void
    {
        super.handleMouseRollOut(controllerIdx);
        CloseTooltip();
    }
    
    private function handleDragOver(controllerIdx:Number, button:Number):Void
    {
        super.handleDragOver(controllerIdx, button);
        // StartTooltipTimout();   // do we want this?
    }
    
    private function handleDragOut(controllerIdx:Number, button:Number):Void
    {
        super.handleDragOut(controllerIdx, button);
        CloseTooltip();
    }
	
	private function StartTooltipTimout()
	{
		if (m_TooltipTimeout != undefined)
		{
			return;
		}
		var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelay");
		if (delay == 0)
		{
			OpenTooltip();
			return;
		}
		m_TooltipTimeout = _global.setTimeout( Delegate.create( this, OpenTooltip ), delay*1000 );
	}

	private function StopTooltipTimout()
	{
		if (m_TooltipTimeout != undefined)
		{
			_global.clearTimeout(m_TooltipTimeout);
			m_TooltipTimeout = undefined;
		}
	}
    
    private function OpenTooltip()
    {
		StopTooltipTimout();
        if (this._visible && this._alpha > 0 && m_Tooltip == undefined)
        {
            var tooltipData:TooltipData = new TooltipData();
            
            tooltipData.m_Descriptions.push(m_TooltipText);
            tooltipData.m_Padding = 4;
            tooltipData.m_MaxWidth = 140;
			m_Tooltip = TooltipManager.GetInstance().ShowTooltip( this, TooltipInterface.e_OrientationVertical, 0, tooltipData );
        }
    }
    
    private function CloseTooltip()
    {
		StopTooltipTimout();
        if (m_Tooltip != undefined)
        {
            m_Tooltip.Close();
            m_Tooltip = undefined;
        }
    }
    
    public function SetTooltipText(tooltip:String)
    {
        m_TooltipText=tooltip;
		if (m_Tooltip != undefined)
		{
			CloseTooltip();
			OpenTooltip();
		}
    }
}