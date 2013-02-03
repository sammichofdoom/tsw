import com.Components.MultiColumnList.MCLBaseCellRenderer;
import com.GameInterface.FeatData;
import com.GameInterface.Utils;
import com.Utils.ID32;
import com.Utils.Colors;
import com.Utils.Signal;
import com.GameInterface.Tooltip.*;
import mx.utils.Delegate;
import com.GameInterface.DistributedValue;	

class com.Components.FeatList.MCLFeatIconCellRenderer extends MCLBaseCellRenderer
{
	private var m_Icon:MovieClip;
	private var m_FeatData:FeatData;
    private var m_Tooltip:TooltipInterface;
	
	public var SignalMouseDown:Signal
	public var SignalMouseUp:Signal
	
	public function MCLFeatIconCellRenderer(parent:MovieClip, id:Number, featData:FeatData, showSymbol:Boolean)
	{
		super(parent, id);
		SignalMouseDown = new Signal;
		SignalMouseUp = new Signal;
		
		m_FeatData = featData;
		
		m_MovieClip = m_Parent.createEmptyMovieClip("m_Column_" +id,  m_Parent.getNextHighestDepth());
		m_Icon = m_MovieClip.attachMovie("SimpleAbility", "m_Icon", m_MovieClip.getNextHighestDepth());
		
		var moviecliploader:MovieClipLoader = new MovieClipLoader();
        //var iconColor = 0x999999;
        var iconColor:Object = {background:0x999999, highlight:0x666666}
        
        if (!featData.m_IconID.IsNull())
        {
            var iconString:String = Utils.CreateResourceString(featData.m_IconID);
            moviecliploader.loadClip( iconString, m_Icon.m_Content);

            var w = m_Icon.m_Background._width - 4; // 2 pix borders
            var h = m_Icon.m_Background._height - 4; // 2 pix borders
            m_Icon.m_Content._x = 2;
            m_Icon.m_Content._y = 2;
            m_Icon.m_Content._xscale = w;
            m_Icon.m_Content._yscale = h;
            
            iconColor = Colors.GetColorlineColors( featData.m_ColorLine );
        }
        Colors.ApplyColor( m_Icon.m_Background.background, iconColor.background);
        Colors.ApplyColor( m_Icon.m_Background.highlight, iconColor.highlight);
        
        if(featData.m_SpellType ==  _global.Enums.SpellItemType.eEliteActiveAbility || featData.m_SpellType ==  _global.Enums.SpellItemType.eElitePassiveAbility )
        {
            m_Icon.m_EliteFrame._visible = true;
        }
        else
        {
            m_Icon.m_EliteFrame._visible = false;
        }
        
		if (showSymbol)
		{
			var symbolName = "";
			
			if (featData.m_CanTrain || featData.m_Trained)
			{
				if ( featData.m_Trained )
				{
					symbolName = "TickIcon";
				}
			}
			else
			{
				symbolName = "LockIcon";
			}
			
			if (symbolName != "")
			{
				var symbol:MovieClip = m_MovieClip.createEmptyMovieClip("m_Symbol", m_MovieClip.getNextHighestDepth());
				symbol.attachMovie(symbolName, symbolName, symbol.getNextHighestDepth() );
				symbol._x = m_Icon._x + m_Icon._width - 2;
				symbol._y = m_Icon._y + m_Icon._height - 2;
				symbol._xscale = 40;
				symbol._yscale = 40;
			}
		}
		
		
		m_MovieClip.onMouseRelease = Delegate.create(this, SlotMouseUp);
		m_MovieClip.onMousePress = Delegate.create(this, SlotMouseDown);
       	m_MovieClip.onUnload = Delegate.create(this, SlotUnload);
		
		
		m_Icon.onPress = function() { };
        m_Icon.onMouseMove = Delegate.create(this, SlotMouseMove);
	}
	
	function SlotUnload()
	{
		if (m_Tooltip != undefined)
		{
			CloseTooltip();
		}
	}
	
	public function SlotMouseUp(buttonIndex:Number)
	{
		SignalMouseUp.Emit(buttonIndex);
	}
	
	public function SlotMouseDown(buttonIndex:Number)
	{
		SignalMouseDown.Emit(buttonIndex);
	}
	
	public function SetSize(width:Number, height:Number)
	{
		var heightPercentage:Number = (height - 10) / m_MovieClip._height;
		var widthPercentage:Number = (width - 10) / m_MovieClip._width;
		
		var percentage:Number = Math.min(heightPercentage, widthPercentage);
		
		m_MovieClip._width *= percentage;
		m_MovieClip._height *= percentage;
		
		m_Icon._x = ((width - m_MovieClip._width) / 2) * (100 / m_MovieClip._yscale);
		m_Icon._y = ((height - m_MovieClip._height) / 2) * (100 / m_MovieClip._xscale);
	}
	
	public function GetDesiredWidth() : Number
	{
		return m_MovieClip._width; 
	}
	
	public function Remove()
	{
		if (m_Tooltip != undefined)
		{
			CloseTooltip();
		}

		super.Remove();
	}

	private function SlotMouseMove()
	{
		if (m_Icon.hitTest(_root._xmouse, _root._ymouse))
		{
			if (m_Tooltip == undefined)
			{
				OpenTooltip();
			}
		}
		else
		{
			if (m_Tooltip != undefined)
			{
				CloseTooltip();
			}
		}
	}
	
	public function OpenTooltip() : Void
    {

		var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( m_FeatData.m_Spell );
		var delay:Number = DistributedValue.GetDValue( "HoverInfoShowDelayShortcutBar" );
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_Icon, TooltipInterface.e_OrientationVertical, delay, tooltipData );
        
    }
    
    public function CloseTooltip() : Void
    {
        if ( !m_Tooltip.IsFloating() )
        {
            m_Tooltip.Close();
        }
        m_Tooltip = undefined;
    }
	
	
	public function SetPos(x:Number, y:Number)
	{
		m_MovieClip._x = x;
		m_MovieClip._y = y;
	}
}