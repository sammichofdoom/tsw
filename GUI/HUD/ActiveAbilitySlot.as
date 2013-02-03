//import GUI.HUD.AbilityCooldown;
import com.GameInterface.Game.Shortcut;
import GUI.HUD.AbilitySlot;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.*;
import GUI.HUD.AbilityBase;
import GUI.HUD.ActiveAbility;
import com.GameInterface.Log;
import mx.utils.Delegate;
import gfx.motion.Tween;

class GUI.HUD.ActiveAbilitySlot extends GUI.HUD.AbilitySlot 
{
	public static var s_HighestSlotDepth:Number
    private var m_State:Number;
	private var m_SlotSize:Number;
    private var test:Number = 20;
	
    private var m_Ability:ActiveAbility;
    private var m_Reflection:ActiveAbility;
    
    private var m_QueueAnimation:MovieClip;
	
	private var m_IsChanneling:Boolean;
	
	private var m_CanUse:Boolean;
    
	public function ActiveAbilitySlot(p_mc:MovieClip, p_id:Number)
	{
		super(p_mc, p_id);
        m_DragType = "shortcutbar/activeability";
		m_IsChanneling = false;
		m_SlotSize = p_mc._height + 4;
		m_CanUse = true;
	}
	
	
	private function OnMouseUp() : Void
    {
        if ( m_WasHit )
        {
            m_WasHit = false;
            
            if( m_CanUse )
            {
                Shortcut.UseShortcut( m_SlotId );
            }
        }
    }
	
	function SetCanUse(canUse:Boolean)
	{
		m_CanUse = canUse;
	}
    
    ///Adds the reflection on the AbilityBar
    private function AddEffects(iconPath:String)
    {
        //RemoveEffects();
        
        if (!m_Reflection)
        {
            m_Reflection = ActiveAbility( m_SlotMC.attachMovie( "Ability", "Reflection", m_SlotMC.getNextHighestDepth()) );
        }
        else 
        {
            //m_Reflection._visible = true;
            m_Reflection.Clear();
        }
        m_Reflection.SetColor( m_ColorLine );
        m_Reflection.SetIcon( iconPath );
        if (m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility || m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility)
        {
            m_Reflection.m_EliteFrame._visible = true;
        }
        else
        {
            m_Reflection.m_EliteFrame._visible = false;
        }
        m_Reflection.SetSpellType(m_SpellType);
        m_Reflection._yscale = -100;
        m_Reflection._y = (m_Reflection._height * 2)- 5; // -5 to push the reflection closer to the actual ability
        m_Reflection.attachMovie("Mask", "mask", m_Reflection.getNextHighestDepth());
        m_Reflection.swapDepths( m_Ability );
    }
    
    private function RemoveEffects():Void
    {
        if (m_Reflection)
        {
            m_Reflection.removeMovieClip();
            m_Reflection = undefined;
        }
    }

    public function SwapEffect(duration:Number):Void
    {
        VerticalFlipEffect(duration, 0, m_SwappedAbility._height, 100, m_SwappedAbility.GetIcon());
        //VerticalFlipEffect(duration, 0, m_SwappedAbility._height, 100, m_SwappedAbility.m_Background);
        
        _global.setTimeout(Delegate.create(this, SwapBackEffect), duration * 1000, duration);
    }
    
    private function SwapBackEffect(duration:Number):Void
    {
        m_SwappedAbility._visible = false;
        m_Ability._visible = true
        
        VerticalFlipBackEffect( duration, 0, m_Ability._height, 100, m_Ability.GetIcon());
        //VerticalFlipBackEffect( duration, 0, m_Ability._height, 100, m_Ability.m_Background);
    }
    
    private function VerticalFlipBackEffect(duration:Number, position:Number, height:Number, scale:Number, clip:MovieClip):Void
    {
        var y:Number = position;
        var yMax:Number = height / 2;
        clip._yscale = 0;
        clip._y = yMax;
        clip.tweenTo( duration, { _yscale:scale, _y:y }, mx.transitions.easing.Regular.easeOut );
        clip.onTweenComplete = function() { };
    }
    
    private function VerticalFlipEffect(duration:Number, position:Number, height:Number, scale:Number, clip:MovieClip):Void
    {
        var y:Number = position;
        var yMax:Number = height / 2;
        clip.tweenTo( duration, { _yscale:0, _y:yMax }, mx.transitions.easing.Regular.easeOut );
        clip.onTweenComplete = 
            function()
            {  
                this._yscale = 0;
                this._y = yMax;
                this.tweenTo( duration, { _yscale:scale, _y:y }, mx.transitions.easing.Regular.easeOut ); 
                this.onTweenComplete = function() { };
            }
    }
    
	public function Fire() : Void
	{
		/// add animation here.
		var abilityFire:MovieClip = m_SlotMC.attachMovie("AbilityFire", "AbilityFire", m_SlotMC.getNextHighestDepth());
		abilityFire._height = m_SlotSize;
		abilityFire._width = m_SlotSize;
        
        abilityFire.onEnterFrame = function()
        {
            if (this._currentframe == this._totalframes)
            {
                this.onEnterFrame = function(){};
                this.removeMovieClip();
            }
        }
	}
    
    public function AddToQueue()
    {
        if (m_QueueAnimation == undefined)
        {
            m_QueueAnimation = m_SlotMC.attachMovie("QueueAnimation", "m_QueueAnimation", m_SlotMC.getNextHighestDepth());
            m_QueueAnimation._height = m_SlotSize;
            m_QueueAnimation._width = m_SlotSize;
        }
    }
    
    public function RemoveFromQueue()
    {
        if (m_QueueAnimation != undefined)
        {
            m_QueueAnimation.removeMovieClip();
            m_QueueAnimation = undefined;
        }
        
    }
    
    public function Use() : Void
    {
        if(!m_IsCooldown)
		{
            Shortcut.UseShortcut( Number( this.m_SlotId ) );
		} 
    }

    
    public function UpdateAbilityFlags( enabled:Boolean, flag:Number)
    {
        if (enabled)
        {
            m_Ability.MergeFlags( flag );
        }
        else
        {
            m_Ability.ClearFlags( flag );
        }
        
        if (m_UseEffects)
        {
            if (enabled)
            {
                m_Reflection.MergeFlags( flag );
            }
            else
            {
                m_Reflection.ClearFlags( flag );
            }
        }
    }

    public function StartChanneling() : Void
    {
        m_Ability.StartChanneling();
        if (m_UseEffects)
        {
            m_Reflection.StartChanneling(  );
        }
		m_IsChanneling = true;
    }
    
    public function StopChanneling() : Void
    {
        m_Ability.StopChanneling();
        if (m_UseEffects)
        {
            m_Reflection.StopChanneling(  );
        }
		m_IsChanneling = false;
    }
	
    /// adds a cooldown to the ability by attaching tha cooldown animation to the slot and passing it to the timer
	/// the ability cooldown uses the AbilityCooldown and the Timer to create a "refill" effect and a countdown timer
	public function AddCooldown( cooldownStart:Number, cooldownEnd:Number,  cooldownType:Number ) : Void
	{
        m_Ability.AddCooldown(cooldownStart, cooldownEnd, cooldownType );
        m_IsCooldown = true;
	}
    
	/// remnoves a cooldown unconditionally
	public function RemoveCooldown()
	{
        m_Ability.RemoveCooldown( );
        m_IsCooldown = false;
	}   

    public function SetVisible(val:Boolean):Void
    {
        m_SlotMC._visible = val;
    }
    
	/// when an ability is removed from the slot, the ability is cleared from the AbilitySlot
	private function RemoveIcon() : Void
	{
		super.RemoveIcon();
		m_IsCooldown = false;
	}
    
    function GetTooltipData():TooltipData
    {
        var tooltipData:TooltipData = TooltipDataProvider.GetShortcutbarTooltip( m_SlotId );
        return tooltipData;
    }
	   
	public function SlotItemDroppedOnDesktop()
    {   
        if (Boolean(DistributedValue.GetDValue( "skillhive_window" )))
        {
            Shortcut.RemoveFromShortcutBar( m_SlotId );
        }        
    }
	
	public function IsChanneling():Boolean
	{
		return m_IsChanneling;
	}
}