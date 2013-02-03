//import mx.core.UIComponent
import com.Utils.Colors;
import com.Utils.ID32;
import mx.utils.Delegate;
import com.GameInterface.Utils;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DialogIF;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import com.GameInterface.Spell;

class com.Components.BuffComponent extends MovieClip
{
    private var m_BuffData:BuffData;
    private var m_ShowCharges:Boolean;
    private var m_UseTimers:Boolean;
    private var m_IsPlayer:Boolean;
    
    private var m_TimeLeft:Number;
    
	private var m_CharacterID:ID32;
	private var m_Tooltip:TooltipInterface;
    private var m_TooltipOrientation:Number;
    
	private var m_IconLoader:MovieClipLoader;
        
    private var m_Background:MovieClip;
    private var m_Border:MovieClip;
    private var m_Icon:MovieClip;
    private var m_Timer:MovieClip;
    private var m_BuffCharge:MovieClip;
	
	private var m_CooldownIntervalID:Number;
    
    public function BuffComponent()
    {
        super();
        		
		var mclistener:Object = new Object();
		m_IconLoader  = new MovieClipLoader();
		m_IconLoader.addListener( mclistener );
        
        m_ShowCharges = true;
        m_UseTimers = true;
		m_IsPlayer = false;
        m_CooldownIntervalID = -1;
        m_TooltipOrientation = TooltipInterface.e_OrientationVertical;
        
        m_TimeLeft = Number.MAX_VALUE;
    }
    
    public function SetShowCharges(showCharges:Boolean)
    {
        m_ShowCharges = showCharges;
    }
    
    public function SetUseTimers(useTimers:Boolean)
    {
        m_UseTimers = useTimers;
    }
    
    public function SetIsPlayer(isPlayer:Boolean)
    {
        m_IsPlayer = isPlayer;
    }
    
    public function SetTooltipOrientation(value:Number):Void
    {
        m_TooltipOrientation = value;
    }
	
	public function SetCharacterID(characterID:ID32)
	{
		m_CharacterID = characterID;
	}
    
    public function GetHeight()
    {
        return _height;
    }
    
    public function GetWidth()
    {
		//Min width of 35
        var width:Number = Math.max(m_Border._width, m_Background._width);
		return Math.max(width, 35);
    }
    
    public function GetBuffData()
    {
        return m_BuffData;
    }
    
    public function SetBuffData(buffData:BuffData)
    {
        m_BuffData = buffData;
        switch(buffData.m_BuffType)
        {
            case _global.Enums.BuffType.e_BuffType_None:
                {
                    if (m_BuffData.m_Hostile)
                    {
                        gotoAndStop("debuff")
                    }
                    else
                    {
                        gotoAndStop("buff");
                    }
                }
                break;
            case _global.Enums.BuffType.e_BuffType_Buff:
                gotoAndStop("buff");
                break;
            case _global.Enums.BuffType.e_BuffType_Debuff:
                gotoAndStop("debuff")
                break;
            case _global.Enums.BuffType.e_BuffType_TrueBand:
                gotoAndStop("permanent");
                break;
            case _global.Enums.BuffType.e_BuffType_Trigger:
                gotoAndStop("permanent");
                break;
            case _global.Enums.BuffType.e_BuffType_Resistance:
                gotoAndStop("permanent");
                break;
        }
        
        SetIcon(m_BuffData.m_Icon);
        Colors.ApplyColor(m_Background.i_Background, Colors.GetColor( m_BuffData.m_ColorLine ) )
        
        UpdateCharges()
        
        m_Timer._visible = (m_BuffData.m_RemainingTime > 0 && m_UseTimers);
        if (m_Timer._visible && m_CooldownIntervalID == -1 )
        {
            m_CooldownIntervalID = setInterval( Delegate.create(this, TimerCallback), 1/60 /*200*/, this );
        }
    }
    
    private function UpdateCharges()
    {
		if( m_ShowCharges && m_BuffData.m_Count > 0)
		{
            swapDepths(_parent.getNextHighestDepth());
			if( m_BuffCharge == undefined)
			{
				m_BuffCharge = attachMovie( "_BuffCharge", "m_BuffCharge", getNextHighestDepth() );
			}

			m_BuffCharge.SetMax( m_BuffData.m_MaxCounters );
			m_BuffCharge.SetCharge( m_BuffData.m_Count );
			m_BuffCharge.SetColor( 0x0000ff ); // TODO: Change. Maybe add color if charge == max

			// Place it in the lower left corner of the buff.
			m_BuffCharge._x = m_Border._width;
			m_BuffCharge._y = m_Border._height;
		}
    }
    
    public function SetIcon(icon:ID32) : Void
    {
		//Default Icon
		var loadString:String = "rdb:1000624:7645315"
        if (icon.GetType() != 0 && icon.GetInstance() != 0)
        {
			loadString = Utils.CreateResourceString(icon) 
		}
		m_IconLoader.loadClip( loadString, m_Icon );
	
		m_Icon._xscale = 28;
		m_Icon._yscale = 28;
    }
    
	public function UnloadIcon()
	{
		clearInterval( m_CooldownIntervalID );
        m_CooldownIntervalID = -1;
		m_IconLoader.unloadClip(m_Icon);
	}
    
    public function GetIcon(): MovieClip
    {
        return m_Icon;
    }
    
    public function GetTimeLeft():Number
    {
        return m_TimeLeft;
    }
	
	function TimerCallback()
	{
		var time = com.GameInterface.Utils.GetNormalTime() * 1000;
        var m_TimeLeft = m_BuffData.m_TotalTime - time;

        // Add blinking when 4 sec left.
        if( m_TimeLeft <= 4000 && m_TimeLeft > 0 )
        {
            // Inverted bounce.
            var x = ((m_TimeLeft % 1000) - 500)/1000;
            var alpha = (30+(x*x*4)*70);
            _alpha = alpha;
        }

        if( m_Timer != undefined && m_TimeLeft > 0 )
        {
            // Normaly show "min:sec"
            if( m_TimeLeft > 60*60*1000 )
            {
                // Show "hour:min" if more than 1 hour left.
                m_TimeLeft = m_TimeLeft/60;
            }
			var totalSeconds:Number = Math.ceil(m_TimeLeft / 1000);
			var minutes:Number = Math.floor(totalSeconds / 60);
			var seconds:Number = totalSeconds % 60;
            m_Timer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", minutes, seconds );
		}
	}
    
    	
	function MakeTooltip(buffID:Number)
	{
		var tooltipData:TooltipData = TooltipDataProvider.GetBuffTooltip( m_BuffData.m_BuffId, m_CharacterID );
		var delay:Number = DistributedValue.GetDValue( "HoverInfoShowDelayShortcutBar" );
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip( this, m_TooltipOrientation, delay, tooltipData );
	}
	
	function MakeTooltipFloating()
	{
		m_Tooltip.MakeFloating();
	}
    
    function Remove()
    {
        CloseTooltip();
        UnloadIcon();
        this.removeMovieClip();
    }

	function CloseTooltip()
	{
		if (m_Tooltip != undefined)
		{
			if ( !m_Tooltip.IsFloating() )
			{
				m_Tooltip.Close();
			}
			m_Tooltip = undefined;
		}
	}
    
    function onMousePress(mouseBtnId:Number)
    {
        if (mouseBtnId == 2 && !GetBuffData().m_Hostile && GetBuffData().m_Cancelable)
        {
            if (m_IsPlayer)
            {
                CancelBuff();
            }
        }
        else if(mouseBtnId == 1 &&  Key.isDown( Key.SHIFT ))
        {
            MakeTooltipFloating();
        }
        
    }
    
    function onRollOver()
    {
        MakeTooltip(this.GetBuffData().m_BuffId);
    }
    
    function onRollOut()
    {
        CloseTooltip();
    }
	
	function CancelBuff()
	{
		var dialogIF = new com.GameInterface.DialogIF( LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "CancelBuffPrompt"),m_BuffData.m_Name), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
		dialogIF.SignalSelectedAS.Connect( SlotCancelBuff, this );
		dialogIF.Go( );
		CloseTooltip();
	}
    
    
	function SlotCancelBuff( buttonId:Number)
	{
		if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			Spell.CancelBuff(m_BuffData.m_BuffId, m_BuffData.m_CasterId);
		}
	}

    
    
}