import flash.filters.GlowFilter;
import GUI.HUD.AbilityBase;
import com.Utils.Colors;
import mx.utils.Delegate;
import GUI.HUD.AbilityCooldown;
import com.Utils.Signal;
import com.GameInterface.Log;
import mx.transitions.easing.*;
import gfx.motion.Tween;

class GUI.HUD.ActiveAbility extends AbilityBase 
{
    public static var FLAG_WRONG_HEAPON:Number = 0;

    public static var FLAG_CASTING:Number = 4;

    public static var FLAG_COOLDOWN:Number = 6;

    private var m_Cooldown:AbilityCooldown = undefined;
    
    private var SignalDone:Signal;
    private var m_GlowFilter:GlowFilter;

    public function ActiveAbility()
    {
        super();
        
        init();
        UpdateVisuals();
    }
    
    public function init()
    {
        SignalDone = new Signal();
        m_GlowFilter = new GlowFilter(Colors.e_ColorWhite, 20, 6 , 6, 1, 1, false, false);
		m_AuxilliaryFrame._visible = false;
    }
    
    ///
    /// COOLDOWNS
    ///
    public function AddCooldown( cooldownStart:Number, cooldownEnd:Number, cooldownFlags:Number ) : Void
    {
		// update visuals now, to avoid being forever stuck in the wrong state if other abilities are spammed
		ForceUpdateVisuals();
        if(m_Cooldown == undefined) //there is no cooldown, start one
        {
            if (m_Flags & FLAG_MAX_MOMENTUM) /// filters messes the drawing. Remove them before comencing on a cooldown
            {
                this.filters = [];
            }
            m_Cooldown = new AbilityCooldown( this, cooldownStart, cooldownEnd, cooldownFlags, m_SpellId );
            m_Cooldown.SignalDone.Connect( RemoveCooldown, this );
        }
        else
        {
            m_Cooldown.OverwriteCooldown( cooldownStart, cooldownEnd, cooldownFlags );
        }
    }

    public function HasCoolDown():Boolean
    {
        return m_Cooldown != undefined;
    }

    /// fires after the cooldown is complete, creating a bright overlay
    /// The cooldown is removed and an enterframe method is set to fade out the overlay
    public function RemoveCooldown(spellId:Number) : Void
	{
        m_OuterLine._visible = true;
        m_InnerLine._visible = true;
        m_BackgroundOverlay._visible = true;
        
        Colors.ApplyColor( m_OuterLine, Colors.e_ColorBlack );
        Colors.ApplyColor( m_BackgroundOverlay, Colors.e_ColorWhite );
     
        m_BackgroundOverlay._alpha = 60;
        m_InnerLine._alpha = 60;
        m_OuterLine._alpha = 70;
        m_Content._alpha = 100;

        if(m_Cooldown != undefined)
		{
            if (m_Cooldown.SignalDone.IsSlotConnected(RemoveCooldown, this))
            {
                m_Cooldown.SignalDone.Disconnect(RemoveCooldown, this);
            }
        
            m_Cooldown.RemoveCooldown();
            m_Cooldown = undefined;
		}

		
		this.onEnterFrame = Delegate.create( this, CooldownFading) ;
	}
    
    /// OEnterFrame method that fades out the bright overlay.
    private function CooldownFading()
    {
        if (m_OuterLine._alpha < 100)
		{
			m_OuterLine._alpha += 1;
		}
		if (m_InnerLine._alpha >= 2)
		{
			m_InnerLine._alpha -= 2;
		}
        if (m_BackgroundOverlay._alpha >= 2)
		{
			m_BackgroundOverlay._alpha -= 2;
		}
		else
        {
            delete this.onEnterFrame;
            UpdateVisuals()
        }
    }

    ///
    /// CHANNELING
    /// 

    public function StartChanneling() : Void
    {
        if (m_Cooldown != undefined)
        {
            RemoveCooldown();
        }
        MergeFlags( FLAG_CHANNELING );
        
        m_BackgroundOverlay._visible = true;
        
        Colors.ApplyColor( m_BackgroundOverlay, Colors.e_ColorBlack );
        
        m_BackgroundOverlay._alpha  = 0;
    
        ChannelingHandler();
       
    	m_BackgroundOverlay.onTweenComplete = Delegate.create(this, ChannelingHandler); 
    }
    
    
    public function StopChanneling() : Void
    {
        m_BackgroundOverlay.tweenEnd();
        ClearFlags( FLAG_CHANNELING );
    }
    

    private function ChannelingHandler()
    {
        if (m_BackgroundOverlay._alpha <= 1) // give some slack on the _alpha == 0
        {
            m_BackgroundOverlay.tweenTo( 1, { _alpha:35}, None.easeNone);
        }
        else
        {
            m_BackgroundOverlay.tweenTo(1, { _alpha:0}, None.easeNone);
        }
    }

    ///
    /// DISPLAY METHODS
    ///
    
    public function SetDisabled()
    {
        SetEnabled(false);
        m_Background._visible = false;
        
        Colors.ApplyColor( m_OuterLine, Colors.e_ColorBlack );
   
        m_Content._alpha = 50;
    }
    
    private function SetEnabled(enabled:Boolean):Void
    {
        //m_EliteFrame._visible = enabled;
        m_InnerLine._visible = enabled;
        m_CooldownLine._visible = enabled;
        m_BackgroundOverlay._visible = enabled
        
        m_Gloss._visible = !enabled;
        m_OuterLine._visible = !enabled;
    }
    
    
        /// this is the baseline for all
    public function SetAvailable()
    {
        SetEnabled(false);

        SetBackgroundColor(true);

        Colors.ApplyColor( m_OuterLine, Colors.e_ColorBlack );
        
        m_Content._alpha = 100;
        m_Background._alpha = 100; 
    }
    
    private function SetRangeDisabled() : Void
    {
        SetEnabled(false);
        m_Content._visible = true;
        
        SetBackgroundColor(true);
        Colors.ApplyColor( m_OuterLine, Colors.e_ColorBlack );
        
        m_Content._alpha = 50;
        m_Background._alpha = 40;
    }

    private function SetMaxMomentum()
    {
        m_InnerLine._visible = false;
        //m_EliteFrame._visible = false;
        m_CooldownLine._visible = false;
        
        m_OuterLine._visible = true;
        m_BackgroundOverlay._visible = true;
        m_Gloss._visible = true;
        
        SetBackgroundColor(true);
        Colors.ApplyColor( m_BackgroundOverlay, Colors.e_ColorWhite );
        Colors.ApplyColor( m_OuterLine, Colors.e_ColorWhite );
        
        m_OuterLine._alpha = 50;
        m_Content._alpha = 85;
        m_Background._alpha = 100;
        m_BackgroundOverlay._alpha = 20;
        
        this.filters = [ m_GlowFilter ];
    }
    

    private function SetResourceDisabled()
    {
        //m_EliteFrame._visible = false;
        m_CooldownLine._visible = false;
        m_BackgroundOverlay._visible = false
        m_Background._visible = false;

        m_Gloss._visible = true;
        m_OuterLine._visible = true
        m_InnerLine._visible = true;
        m_BackgroundOverlay._visible = true;
        SetBackgroundColor(true);
        
        Colors.ApplyColor( m_InnerLine, m_ColorObject.background );
        
        m_Background._alpha = 100;
        m_BackgroundOverlay._alpha = 35;
        m_Content._alpha = 35;
    }

    
    private function UpdateVisuals()
    {
        if (m_Cooldown != undefined)
        {
            return;
        }

        ForceUpdateVisuals();
    }

    
    private function ForceUpdateVisuals()
    {
        if (m_Flags & FLAG_DISABLED)
        {
            SetDisabled();
        }
        else if (m_Flags & FLAG_MAX_MOMENTUM)
        {
            SetMaxMomentum();
        }
        else if (m_Flags & FLAG_OUT_OF_RANGE)
        {
            SetRangeDisabled();
        }
        else if (m_Flags & FLAG_NO_RESOURCE)
        {
            SetResourceDisabled();
        }
        else
        {
            SetAvailable();
        }
    }

}