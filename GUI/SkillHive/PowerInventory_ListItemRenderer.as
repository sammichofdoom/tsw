import com.GameInterface.ProjectSpell;
import com.GameInterface.SpellData;
import com.GameInterface.Spell;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.Character;
import com.GameInterface.FeatData;
import com.GameInterface.Utils;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.Utils.DragObject;
import GUI.HUD.AbilityBase;
import GUI.SkillHive.SkillHiveSignals;
import GUI.SkillHive.BuyButton;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.Utils.Colors;

import gfx.utils.Constraints;
import gfx.controls.ListItemRenderer;
import gfx.controls.CheckBox;

import mx.utils.Delegate;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import flash.geom.Matrix;
import flash.geom.Point;

class GUI.SkillHive.PowerInventory_ListItemRenderer extends ListItemRenderer 
{
	
// UI Elements:
	public var m_Pos:MovieClip;	        // Position in the skillhive
	public var m_Icon:MovieClip;	    // Icon
	public var m_Name:TextField;	    // Name
	public var m_Category:TextField;	// Category (Active/Passive)
	public var m_Type:TextField;	    // Type
	public var m_SubTypes:TextField;	// Subtype
	public var m_Effects:TextField;	    // Effects
	public var m_WeaponIcon:MovieClip;	// Weapon Icon
	public var m_BuyButton:BuyButton;	    // Cost
	public var m_PassiveStripes:MovieClip;				// Stripes to indicate Passive type
	public var m_BgColor:MovieClip;
	
    public var m_Hit:MovieClip;         //Background hit test
    public var m_Symbol:MovieClip;
    
    public var m_SubTypesArray:Array;
    public var m_EffectsArray:Array;
    
    private var m_Tooltip:TooltipInterface;
    
    private var m_WasHit:Boolean;
    private var m_HitPos:Point;
	

// Initialization:
	private function PowerInventory_ListItemRenderer() 
    { 
        super();
        m_SubTypesArray = ["Blast", "Strike", "Focus", "Frenzy", "Chain"];
        m_EffectsArray = ["Critical", "Penetration", "Evade"];
        m_Tooltip = undefined;
		m_PassiveStripes._visible = false;
		m_BgColor._visible = false;
        m_WasHit = false;
    }
    
// Public Methods:	
	public function setData(data:Object):Void 
    {
		if (data == undefined) 
        {
        	this._visible = false;
        	return;
      	}
      	this.data = data;
      	this._visible = true;
        
		this.data = data;
        SetupIcon();
        m_Name.text = data.m_Name;
        m_Category.text = GetCategory();
        SetSubTypes();
        SetEffects();
        m_BuyButton.SetCost(data.m_Cost);
        m_BuyButton.SetCharacter(Character.GetClientCharacter());
        
        if (data.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility || data.m_SpellType == _global.Enums.SpellItemType.ePassiveAbility )
        {
            m_PassiveStripes._visible = true;
            m_BgColor._visible = true;
        }
        else
        {
            m_PassiveStripes._visible = false;
            m_BgColor._visible = false;
        }
				
        if (m_WeaponIcon.i_WeaponRequirement != undefined)
        {
            m_WeaponIcon.i_WeaponRequirement.removeMovieClip();
        }
        var spellData:SpellData = Spell.GetSpellData(data.m_Spell);
        var weaponRequirement:Number = spellData.m_WeaponFlags;
        m_Type.text = TooltipUtils.GetWeaponRequirementString(weaponRequirement);
        if (weaponRequirement > 0)
        {
            m_WeaponIcon._visible = true;
            TooltipUtils.CreateWeaponRequirementsIcon(m_WeaponIcon, weaponRequirement, {_xscale:23,_yscale:23,_x:1,_y:1})
        }
        else
        {
            m_WeaponIcon._visible = false;
        }
                
        m_Hit.onRelease = Delegate.create(this, SlotSelectAbility);
        m_Hit.onMouseUp = Delegate.create(this, SlotMouseUp);
        m_Hit.onMouseMove = Delegate.create(this, SlotMouseMove);
	}
    
    function SlotMouseUp()
    {
        m_WasHit = false;        
    }
    
    function onMousePress(buttonIdx:Number, clickCount:Number)
    {
        if (buttonIdx == 1)
        {
            m_HitPos = new Point(_root._xmouse, _root._ymouse);
            m_WasHit = true; 
            //For doubleclicking to equip on first free slot (but feels weird so not in yet)
            /*if (clickCount == 2)
            {
                Shortcut.AddSpell(-1, data.m_Spell);
            }*/
        }
        else if (buttonIdx == 2)
        {
            if (Spell.IsPassiveSpell(data.m_Spell))
            {
                var nextFreeSlot:Number = Spell.GetNextFreePassiveSlot();
                if (nextFreeSlot >= 0)
                {
                    Spell.EquipPassiveAbility( nextFreeSlot, data.m_Spell);
                }
            }
            else if(Spell.IsActiveSpell(data.m_Spell))
            {
                Shortcut.AddSpell(-1 , data.m_Spell);
                
            }
        }
    }
    
    function SlotMouseMove()
    {
        if (m_WasHit && data.m_Trained)
        {
            var mousePos:Point = new Point( _root._xmouse, _root._ymouse );
            if (Point.distance( m_HitPos, mousePos ) > 10)
            {
                var dragData:DragObject = new DragObject();
                //dragData.SignalDragHandled.Connect(SlotDragHandled, this);
                if (data.m_SpellType == _global.Enums.SpellItemType.eMagicSpell || data.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility  )
                {
                    dragData.type = "skillhive_active";
                    
                }
                else
                {
                    dragData.type = "skillhive_passive";                 
                }
                dragData.ability = data.m_Spell;
                var grandParent:MovieClip = _parent._parent._parent._parent;
                var dragClip  = AbilityBase(grandParent.attachMovie( "Ability", "drag_clip", grandParent.getNextHighestDepth(), { _x: grandParent._xmouse, _y: grandParent._ymouse} ));
                dragClip.SetColor( data.m_ColorLine );
                dragClip.SetIcon( Utils.CreateResourceString(data.m_IconID) );
                dragClip.SetSpellType( data.m_SpellType );
				
                gfx.managers.DragManager.instance.startDrag( grandParent, dragClip, dragData, dragData, null, false );
                gfx.managers.DragManager.instance.removeTarget = true;
				
				gfx.managers.DragManager.instance.dragOffsetY = -dragClip._width / 2;
				gfx.managers.DragManager.instance.dragOffsetX = -dragClip._width / 2;
                
                dragClip.topmostLevel = true;
                m_WasHit = false;
            }
        }
    }
    
    function SlotBuyClicked()
    {
        if (!data.m_Trained && data.m_CanTrain)
        {
            SkillHiveSignals.SignalBuyAbility.Emit(data.m_Id);
        }
    }
    
    private function configUI():Void 
    {
        constraints = new Constraints(this, true);
		if (!_disableConstraints) {
			constraints.addElement(textField, Constraints.ALL);
		}
        
        // Force dimension check if autoSize is set to true
		if (_autoSize != "none") {
			sizeIsInvalid = true;
		}

         m_Icon.onRollOver = Delegate.create(this, SlotRollOverIcon);
         m_Icon.onRollOut = Delegate.create(this, SlotRollOutIcon);
         m_Icon.onDragOver = Delegate.create(this, SlotRollOverIcon);
         m_Icon.onDragOut = Delegate.create(this, SlotRollOutIcon);
         m_Icon.onRelease = Delegate.create(this, SlotSelectAbility);
         
        if (m_BuyButton.SignalPressed != undefined)
        {
            m_BuyButton.SignalPressed.Connect(SlotBuyClicked, this);
        }

		
		if (focusIndicator != null && !_focused && focusIndicator._totalFrames == 1) { focusIndicator._visible = false; }
		
		updateAfterStateChange();

    }
    
    function SlotRollOverIcon()
    {
        var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( data.m_Spell );
        var delay:Number = DistributedValue.GetDValue( "HoverInfoShowDelayShortcutBar" );
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_Icon, TooltipInterface.e_OrientationVertical, delay, tooltipData );
    }
    
    function SlotRollOutIcon()
    {
        CloseTooltip();
    }
    
    private function CloseTooltip() : Void
    {
        if ( m_Tooltip != undefined )
        {
            m_Tooltip.Close();   
            m_Tooltip = undefined;
        }
    }
    
    function SlotSelectAbility() : Void
    {
        SkillHiveSignals.SignalSelectAbility.Emit(data.m_ClusterIndex, data.m_CellIndex, data.m_AbilityIndex);
        Selection.setFocus(null);
    }
    
    
    private function SetupIcon()
    {
        var moviecliploader:MovieClipLoader = new MovieClipLoader();
        var iconColor = 0x999999;
        if (!this.data.m_IconID.IsNull())
        {
            var iconString:String = Utils.CreateResourceString(this.data.m_IconID);
            moviecliploader.loadClip( iconString, m_Icon.m_Content);

            var w = m_Icon.m_Background._width - 4; // 2 pix borders
            var h = m_Icon.m_Background._height - 4; // 2 pix borders
            m_Icon.m_Content._x = 2;
            m_Icon.m_Content._y = 2;
            m_Icon.m_Content._xscale = w;
            m_Icon.m_Content._yscale = h;
            
            iconColor = Colors.GetColor( this.data.m_ColorLine );
        }
        else
        {
            moviecliploader.unloadClip(m_Icon.m_Content);
        }
        Colors.ApplyColor( m_Icon.m_Background, iconColor);
        
        //Add the symbol to the icon (ticked or locked)
        if (m_Symbol != undefined)
        {
            m_Symbol.removeMovieClip();
        }
		var symbolName = "";
		
		if (data.m_CanTrain || data.m_Trained)
		{
			if ( data.m_Trained )
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
			m_Symbol = createEmptyMovieClip("i_Symbol", getNextHighestDepth());
			m_Symbol.attachMovie(symbolName, symbolName, m_Symbol.getNextHighestDepth() );
			m_Symbol._x = m_Icon._x + m_Icon._width - 7;
			m_Symbol._y = m_Icon._y + m_Icon._height - 7;
			m_Symbol._xscale = 40;
			m_Symbol._yscale = 40;
		}
    }
    
    private function SetSubTypes()
    {
        var subTypes:String = "";
        for (var i:Number = 0; i < m_SubTypesArray.length; i++)
        {
            if (data.m_Desc.indexOf(m_SubTypesArray[i]) != -1)
            {
                if (subTypes.length > 0)
                {
                    subTypes += ", ";
                }
                subTypes += m_SubTypesArray[i];
            }
        }
        m_SubTypes.text = subTypes;
    }
    
    private function SetEffects()
    {
        var effects:String = "";
        for (var i:Number = 0; i < m_EffectsArray.length; i++)
        {
            if (data.m_Desc.indexOf(m_EffectsArray[i]) != -1)
            {
                if (effects.length > 0)
                {
                    effects += ", ";
                }
                effects += m_EffectsArray[i];
            }
        }
        m_Effects.text = effects;
    }
    
    private function GetCategory():String
    {
        switch(this.data.m_SpellType)
        {
            case _global.Enums.SpellItemType.ePassiveAbility:
            return LDBFormat.LDBGetText("Gamecode", "Passive");
            case _global.Enums.SpellItemType.eElitePassiveAbility:
            return LDBFormat.LDBGetText("Gamecode", "PassiveElite");
            case _global.Enums.SpellItemType.eMagicSpell:
            return LDBFormat.LDBGetText("Gamecode", "Active");
            case _global.Enums.SpellItemType.eEliteActiveAbility:
            return LDBFormat.LDBGetText("Gamecode", "ActiveElite");
            default:
            return "";
        }
    }
}
