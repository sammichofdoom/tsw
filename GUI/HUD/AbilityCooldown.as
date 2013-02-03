/// adds the animation timer to the cooldown 
import mx.utils.Delegate;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import com.GameInterface.Log;
import com.Utils.Signal;
import com.Utils.Colors;

class GUI.HUD.AbilityCooldown
{
    private var m_IntervalID:Number = -1;
    private var m_Increments:Number = 20;
    private var m_MaskHeight:Number = -1;
    private var m_MaskY:Number;
    private var m_Mask:MovieClip;
    private var m_CooldownFlags:Number;
    private var m_CooldownTimer:MovieClip;
    private var m_IsPrepared:Boolean;
    private var m_UseTimer:Boolean;
    
    private var m_TotalDuration:Number;
    private var m_StartTime:Number;
    private var m_EndTime:Number;
    private var m_SpellId:Number;
    
    public var SignalDone:Signal;
    private var m_Icon:MovieClip;
    
    /// Sets up a new Abilitycooldown, subsequent calls to this instance should be done trough the AddCooldown method
    public function AbilityCooldown( icon:MovieClip, cooldownStart:Number, cooldownEnd:Number, cooldownFlags:Number, spellId:Number)
    {   
        m_Icon = icon;
        m_IsPrepared = false;
        m_UseTimer = false;
        m_CooldownFlags = cooldownFlags;
        m_SpellId = spellId;
        SignalDone = new Signal();
        
        PrepareStage(cooldownStart, cooldownEnd);
            
        m_IntervalID = setInterval( Delegate.create( this, UpdateTimer ), m_Increments, this );
    }
    
    /// prepares all values and sets all variables needed in the class-wide scope 
    /// note this is only to be done ONCE in the lifetime of an instance of this class
    private function PrepareStage(cooldownStart:Number, cooldownEnd:Number)
    {
        m_Icon.m_UseFrame._visible = true;
        m_Icon.m_Gloss._visible = false;
        m_Icon.m_CooldownLine._visible = true;
        
        m_StartTime = cooldownStart;
        m_EndTime = cooldownEnd;
        m_TotalDuration = cooldownEnd - cooldownStart;
              
        if (m_CooldownFlags & _global.Enums.TemplateLock.e_GlobalCooldown)
        {
            m_Icon.m_BackgroundOverlay._visible = true;
            
            Colors.ApplyColor(m_Icon.m_BackgroundOverlay, Colors.e_ColorWhite);
            m_Icon.m_BackgroundOverlay._alpha = 50;
            
            m_Icon.m_Background._alpha = 80;
            if (m_UseTimer)
            {
                if (m_CooldownTimer)
                {
                    m_CooldownTimer.removeMovieClip();
                    m_CooldownTimer = null;
                }
                m_UseTimer = false;
            }
        }
        else
        {
            m_Icon.m_BackgroundOverlay._alpha = 100;
            m_Icon.m_BackgroundOverlay._visible = false;
            m_Icon.m_Background._alpha = 100;
            
            m_CooldownTimer = m_Icon.attachMovie( "cooldown_template", "cooldown", m_Icon.getNextHighestDepth() );
            m_UseTimer = true;
        }

        ApplyMask();
        
        m_MaskHeight = m_Mask._height;
        m_MaskY = 1;
        
        m_IsPrepared = true;
    }
    
    /// Method that updates
    private function UpdateTimer() : Void
    {
        var currentTime = com.GameInterface.Utils.GetGameTime()
        var currentDuration =  currentTime - m_StartTime;
        var timeLeft = m_EndTime - currentTime;

        if ( timeLeft > 0 )
        {
            if (m_Mask && m_TotalDuration > 0)
            {
                m_Mask._height = m_MaskHeight * ( currentDuration / m_TotalDuration );
                m_Mask._y = m_MaskY + ( m_MaskHeight -  m_Mask._height);
                m_Icon.m_CooldownLine._y = m_Mask._y;
            }
            if (m_UseTimer)
            {
                m_CooldownTimer.ms_txt.text = com.Utils.Format.Printf( "%02.0f:%02.0f:%02.0f", Math.floor(timeLeft / 60), Math.floor(timeLeft) % 60, Math.floor(timeLeft * 100) % 100 );
            }
            else
            {
                m_CooldownTimer.ms_txt.text = com.Utils.Format.Printf( "%02.0f:%02.0f", Math.floor(timeLeft / 60), Math.floor(timeLeft) % 60 );
            }
        }
        else
        {
            RemoveCooldown();
            EmitSignal();
        }
    }
    
    private function ClearMask()
    {
        if (m_Mask)
        {
            var target:MovieClip = (m_CooldownFlags & _global.Enums.TemplateLock.e_GlobalCooldown) ? m_Icon.m_BackgroundOverlay : m_Icon.m_Background;
            target.setMask( null );
            m_Mask.removeMovieClip();
            m_Mask = null;
        }
       
    }

    private function ApplyMask()
    {
        if (m_CooldownFlags & _global.Enums.TemplateLock.e_GlobalCooldown)
        {
            m_Mask = com.GameInterface.ProjectUtils.SetMovieClipMask( m_Icon.m_BackgroundOverlay, m_Icon, m_Icon.m_BackgroundOverlay._height - 4 );
        }
        else
        {
            m_Mask = com.GameInterface.ProjectUtils.SetMovieClipMask( m_Icon.m_Background, m_Icon, m_Icon.m_Background._height - 4 );
        }
    }
    
    public function OverwriteCooldown( cooldownStart:Number, cooldownEnd:Number, cooldownFlags:Number)
    {
        if ((cooldownFlags & _global.Enums.TemplateLock.e_GlobalCooldown) && cooldownEnd < m_EndTime)
        {
            // if this is a global cooldown which is shorter than whats left of the cooldown already, ditch it
            return;
        }
        
        RemoveCooldown();
        m_CooldownFlags = cooldownFlags;
        PrepareStage( cooldownStart, cooldownEnd);
          
        if (m_IntervalID < 0)
        {
            m_IntervalID = setInterval( Delegate.create( this, UpdateTimer ), m_Increments, this );
        }
    }

    // emit SignalDone needs to be in a separate function for scope issues
    private function EmitSignal()
    {
        SignalDone.Emit(m_SpellId);
    }

    public function RemoveCooldown()
    {
        clearInterval( m_IntervalID );
        m_IntervalID = -1;
        ClearMask();
        m_CooldownFlags = 0;
        if (m_CooldownTimer != undefined)
        {
            m_CooldownTimer.removeMovieClip();
            m_CooldownTimer = undefined;
        }
    }
    public function GetCooldownFlags() : Number
    {
        return m_CooldownFlags;
    }
}
