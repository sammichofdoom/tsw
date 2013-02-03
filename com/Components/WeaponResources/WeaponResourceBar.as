import com.Components.ResourceBase;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;


class com.Components.WeaponResources.WeaponResourceBar extends ResourceBase
{
    private var m_EffectBar:MovieClip;
    private var m_ResourceNumbers:MovieClip;
    private var m_ProgressAnimation:MovieClip
    private var m_Bar:MovieClip;
    
    public function WeaponResourceBar()
    {
        super();
        m_ResourceDisplayType = DISPLAY_BAR;
    }
    
    
    public function configUI()
    {
        m_ProgressAnimation._visible = false;
        m_Bar._xscale = 1;
        m_Bar.onTweenComplete = undefined;
        m_EffectBar._xscale = 1;
        m_EffectBar._alpha = 0;
        m_EffectBar.onTweenComplete = undefined;
        m_ResourceNumbers.onTweenComplete = undefined;
        
        SetThrottle(m_Throttle && m_IsInCombat)
    }
    
    private function Layout(snap:Boolean)
    {
        m_ResourceNumbers.textField.htmlText = "<b>"+m_Amount + "/" + m_MaxAmount+"</b>";
        m_EffectBar._alpha = 100;
        
        if (snap)
        {
            m_Bar._xscale = m_Amount * 20;
        }
        else
        {
            
            if (m_Amount > m_PreviousAmount)
            {
                if (m_Amount == m_PreviousAmount + 1) // if its a large increase, skip the white flash
                {
                    m_ProgressAnimation._visible = true;
                    m_ProgressAnimation._x = m_Bar._x + m_Bar._width;
                    m_ProgressAnimation.gotoAndPlay("increase");
                }
                m_Bar.tweenTo(0.3, { _xscale:m_Amount * 20 }, None.easeNone );
                m_Bar.onTweenComplete = Delegate.create( this, CleanupAfterAnimation);
                
                m_EffectBar.tweenTo(0.3, { _xscale:m_Amount * 20, _alpha:0 }, None.easeNone );
            }
            else
            {
                m_Bar.tweenTo(0.3, { _xscale:m_Amount * 20 }, None.easeNone );
                m_EffectBar.tweenTo(0.3, { _xscale:m_Amount * 20, _alpha:0 }, None.easeNone );
            }
            
            m_ResourceNumbers._alpha = 0;
            m_ResourceNumbers.tweenTo( 0.3, { _alpha:100 }, None.easeNone);
        }
        SetThrottle(m_Amount == m_MaxAmount)
        m_PreviousAmount = m_Amount;
    }
    
    public function SetThrottle(throttle:Boolean)
    {
        if ((m_Throttle && !throttle) || (!m_IsInCombat && m_Throttle) )
        {
            m_Background.gotoAndPlay("throttle_off");
            
        }
        else if (throttle && m_IsInCombat)
        {
            m_Background.gotoAndPlay("throttle");
        }
        m_Throttle = throttle;
    }
    
    private function CleanupAfterAnimation()
    {
        m_ProgressAnimation._visible = false;
    }
}