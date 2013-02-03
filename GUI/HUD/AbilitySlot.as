import GUI.HUD.ActiveAbility;
import GUI.HUD.ActiveAbilitySlot;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.Utils.DragObject;
import mx.core.UIComponent;
//import com.Utils.Signal;
//import com.Utils.SignalGroup;
import com.Utils.Colors;
import GUI.HUD.AbilityBase;

import mx.utils.Delegate;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import flash.geom.Point;

/// Object that controls an ability,
class GUI.HUD.AbilitySlot
{
    var SWAP_ANIMATION_DURATION:Number = 0.2;
	
	private var m_IsActive:Boolean = false;
	
	private var m_IconPath:String = "none";
    private var m_HitPos:Point;
    private var m_IsBeingDragged:Boolean = false;
	public var m_ColorLine:Number = undefined;
    public var m_DisabledColor:Number = 0x666666;
	private var m_SlotMC:MovieClip;
	private var m_SlotId:Number;
    private var m_Icon:MovieClip;
	private var m_WasHit:Boolean = false;
    private var m_IsUnderMouse:Boolean = false;
    private var m_Tooltip:TooltipInterface = undefined;
	private var m_UseEffects:Boolean = false;
    public var m_Ability:AbilityBase;
    public var m_SwappedAbility:AbilityBase;
    public var m_Reflection:AbilityBase;
    public var m_Enabled:Boolean;
    public var m_RangedEnabled:Boolean;
    private var m_IsCooldown:Boolean = false;
    public var m_DragType:String = "";
    private var m_LinkageId:String = "";
    private var m_SpellType:Number = -1;
    private var m_Id:Number;
	
	public function AbilitySlot(p_mc:MovieClip, p_id:Number)
	{
		m_SlotMC = p_mc;
		m_SlotId = p_id;
        m_HitPos = new Point();
        m_Enabled = true;
        m_RangedEnabled = true;
	}
	
	private function OnMouseUp() :Void
	{

	}
    
    private function OnMouseDown() : Void
    {
        if ( m_Tooltip != undefined && Key.isDown( Key.SHIFT ) )
        {
            m_Tooltip.MakeFloating();
        }
        else
        {
            m_WasHit = true;
            m_HitPos.x = _root._xmouse;
            m_HitPos.y = _root._ymouse;
        }
    }    
    function GetTooltipData()
    {
        var tooltipData:TooltipData = TooltipDataProvider.GetShortcutbarTooltip( m_SlotId );
        return tooltipData;
    }
   
    public function CloseTooltip() : Void
    {
        if ( m_Tooltip != undefined )
        {
            if ( !m_Tooltip.IsFloating() )
            {
                m_Tooltip.Close();
            }
            m_Tooltip = undefined;
        }
    }        
    private function OnMouseMove() : Void
    {
        var mousePos:Point = new Point( _root._xmouse, _root._ymouse );

        if ( m_WasHit && m_IsActive && !m_IsCooldown && Point.distance( m_HitPos, mousePos ) > 3  )
        {
            if( CanDragAbility() && !DragObject.GetCurrentDragObject() && !DistributedValue.GetDValue( "LockShortcutBars" ) )
            {
                var dragData:DragObject = new DragObject();
                dragData.type = m_DragType;
                dragData.slot_index = m_SlotId;
                
				dragData.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
				dragData.SignalDragHandled.Connect(SlotDragHandled, this);
                var dragClip  = AbilityBase(m_SlotMC.attachMovie( m_LinkageId, "drag_clip" + m_SlotMC.UID(), m_SlotMC.getNextHighestDepth()));
                dragClip.SetColor( m_ColorLine ); 
                dragClip.SetIcon( m_IconPath );
                dragClip.SetSpellType( m_SpellType );

                gfx.managers.DragManager.instance.startDrag( m_Ability, dragClip, dragData, dragData, m_Ability, false );
                gfx.managers.DragManager.instance.removeTarget = true;
                
                dragClip.topmostLevel = true;
                dragClip.hitTestDisable = true;
                
                m_IsBeingDragged = true;
                UpdateAlpha();
               // m_Ability.UnGlow();
            }
            m_WasHit = false;
        }
        if ( DistributedValue.GetDValue( "BottomBarShowTooltips" ) &&  (Mouse["IsMouseOver"](m_Ability, false)) && !DragObject.GetCurrentDragObject() )
        {
            if ( m_Tooltip == undefined )
            {
                var tooltipData:TooltipData = GetTooltipData();
                var delay:Number = DistributedValue.GetDValue( "HoverInfoShowDelayShortcutBar" );
                m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_Ability, TooltipInterface.e_OrientationVertical, delay, tooltipData );
            }
        }
        else if ( m_Tooltip != undefined )
        {
            CloseTooltip();
        }
    }
	    
    public function SlotItemDroppedOnDesktop() { }
    
    public function SlotDragHandled()
    {
        m_IsBeingDragged = false;
        UpdateAlpha();
    }
    
    private function CanDragAbility():Boolean
    {
        return DistributedValue.GetDValue( "skillhive_window" );
    }

    /// sets up the visuals for the ability
    /// @param p_icon:String  - the rdb id of the icon
    /// @param p_ColorLine:Number - id of the colour, no real value
    /// @param spellType:Number - the spelltype, used to identify elite abilities
    /// @param linkageId:String - Linkage name in the library for the ability icon
    /// @param useEffects:Boolean - wether or not to display effects (reflections...)
    public function SetAbilityData(p_icon:String, p_ColorLine:Number, spellId:Number, spellType:Number, linkageId:String, useEffects:Boolean) : Void
	{
        if( p_icon == "" )
		{
            return;
        }
        
		m_IsActive = true;
		m_IconPath = p_icon;
        m_ColorLine = p_ColorLine;
        m_Id = spellId;
        m_SpellType = spellType;
		m_UseEffects = (useEffects ? useEffects : false); // is that wrong? Force the boolean if useEffects == undefined
        m_LinkageId = linkageId;

        if (!m_Ability)
        {
            m_Ability = AbilityBase( m_SlotMC.attachMovie( linkageId, "m_AbilityBase_" + _root.UID(), m_SlotMC.getNextHighestDepth() ) );
            m_Ability.onPress       = Delegate.create( this, OnMouseDown );
            m_Ability.onRelease     = Delegate.create( this, OnMouseUp );
            m_Ability.onMouseMove   = Delegate.create( this, OnMouseMove );
            //  m_Ability.onRollOver    = m_Ability.Glow;
            //  m_Ability.onRollOut     = m_Ability.UnGlow;
        }
        else
        {
            m_Ability.Clear();
            RemoveEffects();
        }

        m_Ability.SetColor( m_ColorLine );
        m_Ability.SetIcon( p_icon );
        m_Ability.SetSpellType(m_SpellType);
        m_Ability.SetSpellId(m_Id);
        
        if (this.m_UseEffects)
        { 
            AddEffects( p_icon );
        }

    }
    
    public function SwapAbilityData(p_icon:String, p_ColorLine:Number, spellId:Number, spellType:Number, linkageId:String, useEffects:Boolean) : Void
    {
        m_IsActive = true;
        m_IconPath = p_icon;
        m_ColorLine = p_ColorLine;
        m_Id = spellId;
        m_SpellType = spellType;
        m_UseEffects = (useEffects ? useEffects : false);
        m_LinkageId = linkageId;

        if (m_SwappedAbility != undefined)
        {
            var tempAbility:AbilityBase = m_SwappedAbility;
            m_SwappedAbility = m_Ability;
            m_Ability = tempAbility;
        }
        else
        {
            m_SwappedAbility = m_Ability;
            m_Ability = AbilityBase( m_SlotMC.attachMovie( linkageId, "m_AbilityBase_Swap_" + _root.UID(), m_SlotMC.getNextHighestDepth() ) );
            m_Ability.onPress       = Delegate.create( this, OnMouseDown );
            m_Ability.onRelease     = Delegate.create( this, OnMouseUp );
            m_Ability.onMouseMove   = Delegate.create( this, OnMouseMove );
        }
        RemoveEffects();

        m_Ability._visible = false; //New swapped ability will be set to visible after the tween
        
        m_Ability.SetColor( m_ColorLine );
        m_Ability.SetIcon( p_icon );
        m_Ability.SetSpellType(m_SpellType);
        m_Ability.SetSpellId(m_Id);
        
        if (this.m_UseEffects)
        { 
            AddEffects( p_icon );
        }

        SwapEffect(SWAP_ANIMATION_DURATION);
    }
    
	
	/// clears the class intance of all variables that needs to be nulled when the class is reset
	/// @return void
	public function Clear() : Void
	{
        CloseTooltip();
		m_IsActive = false;
		m_IconPath = "";
		RemoveIcon();
        m_ColorLine = undefined;
	}
	
    ///Empty method for effects, used by any child classes to add specific effects
    private function AddEffects(iconPath:String)
    {
        // nothin here
    }

    ///Empty method for effects, used by any child classes to remove effects
    private function RemoveEffects():Void
    {
        // nothin here
    }
    
    private function UpdateAlpha() : Void
    {
        var alpha:Number = (m_IsBeingDragged) ? 0 : 100;
        if ( !m_RangedEnabled )
        {
            alpha *= 0.1;
        }
        m_Ability._alpha = alpha;
        if (m_UseEffects)
        {
            m_Reflection._alpha = alpha;
        }
    }
  
	/// when an ability is removed from the slot, the ability is cleared from the AbilitySlot
	private function RemoveIcon() : Void
	{
        if (m_Ability != undefined )
        {
            m_Ability.removeMovieClip();
            m_Ability = undefined;
        }
        if ( m_SwappedAbility != undefined )
        {
            m_SwappedAbility.removeMovieClip();
            m_SwappedAbility = undefined;
        }
        RemoveEffects();
	}

    public function SetVisible(val:Boolean):Void
    {
        m_SlotMC._visible = val;
    }
    
    public function GetSlotId() : Number
	{
		return m_SlotId;
	}
    
    
	public function get Slot() : MovieClip
	{
		return this.m_SlotMC;
	}
	
    
    public function SwapEffect(duration:Number):Void
    {
    }

	public function get Ability() : MovieClip
	{
		return m_Ability;
	}
	
    
	public function get IsActive() :Boolean
	{
		return m_IsActive;
    }
	
}
