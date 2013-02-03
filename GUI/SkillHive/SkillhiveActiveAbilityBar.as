import GUI.HUD.ActiveAbilitySlot;
import com.GameInterface.GUIUtils.FlashEnums;
import GUI.HUD.AbilitySlot;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import flash.filters.GlowFilter;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.GameInterface.Utils;
import com.Utils.ShortcutLocation;
import com.Utils.Colors;
import com.GameInterface.Lore;
import com.GameInterface.Spell;
import com.GameInterface.SpellData;

dynamic class GUI.SkillHive.SkillhiveActiveAbilityBar extends MovieClip
{
	var m_AbilitySlots:Array;
    
    var SignalToggleVisibility:Signal;
	
	var m_AuxilliarySlotAchievement:Number = 5437;
    
    function SkillhiveActiveAbilityBar()
    {
        SignalToggleVisibility = new Signal();
    }

	function onLoad()
	{
		m_AbilitySlots = [];
		// loop the hive and push each of the slots in the m_AbilitySlots array.
		for( var i:Number = 0; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
		{
			var mc_slot:MovieClip = MovieClip( this["slot_"+i] );

			if( mc_slot != null )
			{
             /*   if (mc_slot.i_AbilityBase.i_AbilityMouseOverGlow != undefined)
                {
                    mc_slot.i_AbilityBase.i_AbilityMouseOverGlow.stop();
                }*/
				m_AbilitySlots.push(new ActiveAbilitySlot(mc_slot, _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + i) );
				m_AbilitySlots[i].SetCanUse(false);
			}
		}
	    /// connect the signals
		Shortcut.SignalShortcutAdded.Connect( SlotShortcutAdded, this  );
		Shortcut.SignalShortcutRemoved.Connect( SlotShortcutRemoved, this );
		Shortcut.SignalShortcutMoved.Connect( SlotShortcutMoved, this );
		
		Shortcut.RefreshShortcuts( _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount );
		
		gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "SlotDragEnd" );
        
        this.i_Bar.i_TopFrame.onPress = Delegate.create(this, SlotToggleVisibility);
		
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
		
		if (Lore.IsLocked(m_AuxilliarySlotAchievement))
		{
			this["slot_"+7]._visible = false;
			this["m_AuxilliaryFrame"]._visible = false;
		}
	}

    function onUnload()
    {
        gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "SlotDragEnd" );
        
		Shortcut.SignalShortcutAdded.Disconnect( SlotShortcutAdded, this  );
		Shortcut.SignalShortcutRemoved.Disconnect( SlotShortcutRemoved, this );
		Shortcut.SignalShortcutMoved.Disconnect( SlotShortcutMoved, this );
        
        Lore.SignalTagAdded.Disconnect(SlotTagAdded, this);
    }
    
	function SlotTagAdded(tag:Number)
	{
		if (tag == m_AuxilliarySlotAchievement)
		{
			this["slot_" + 7]._visible = true;
			this["m_AuxilliaryFrame"]._visible = true;
		}
	}
 
        
    function GetTopFrameHeight():Number
    {
        return (this.i_Bar.i_TopFrame._height * (this._yscale / 100)) + 5;
    }
    
    function SlotToggleVisibility()
    {
        SignalToggleVisibility.Emit();
    }

	public function EquipActive(slotId:Number, spellId:Number)
	{
		if (CanAddShortcut(slotId, spellId))
		{
			Shortcut.AddSpell(slotId + _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, spellId);
		}
	}
	
	public function UnEquipActive(spellId:Number)
	{
		for (var i:Number = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot +_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
		{
			if (Shortcut.m_ShortcutList[i].m_SpellId == spellId)
			{
				Shortcut.RemoveFromShortcutBar(i);
			}
		}
	}
	
	public function HighlightSlot(slotId:Number)
	{
		var filter:GlowFilter = new GlowFilter(0xFFFFFF,90,15,15,2,2,false,false);
		this["slot_" + slotId].filters = [filter];
	}
	
	public function StopHighlightSlot(slotId:Number)
	{
		this["slot_" + slotId].filters = [];
	}

	/// Signal sent when a shortcut has been added.
	/// This also happens when you teleport to a new pf.
	/// Note that you might get an SignalShortcutEnabled right afterward if the shortcut is disabled. And SignalCooldownTime if it's in cooldown.
	/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
	/// @param name:String      The name of the item in LDB format.
	/// @param icon:String      The icon resource information.
	/// @param itemClass:Number The type of shortcut. See Enums.StatItemClass
	function SlotShortcutAdded( itemPos:Number) : Void
	{
		var slotNo:Number = itemPos - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
        var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
        if ( slotNo >= 0 && slotNo < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount  && shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_SpellShortcut)
        {
            var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
            SlotShortcutRemoved(itemPos);
			var abilityslot:AbilitySlot = AbilitySlot( m_AbilitySlots[ slotNo ] );
            abilityslot.SetAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", false );
        }
	}

	/// Signal sent when a shortcut has been removed.
	/// This will not be sent if the shortcut changes position, moved.
	/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
	function SlotShortcutRemoved( itemPos:Number ) : Void
	{
		var slotNo:Number = itemPos - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
		if ( slotNo >= 0 && slotNo < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount )
		{
			var abilityslot:AbilitySlot = m_AbilitySlots[ slotNo ];
			if (abilityslot.IsActive)
			{
				abilityslot.Clear( );
			}
		}
	}

	/// Signal sent when a shortcut has been move to some other spot.
	/// No add/remove signal will be triggered.
	/// @param fromPos:Number   The position the item was move from.
	/// @param toPos:Number     The position the item was move to.
	function SlotShortcutMoved( p_from:Number, p_to:Number ) : Void
	{
		var fromSlot:Number = p_from - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
		var toSlot:Number   = p_to - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;

		if ( fromSlot >= 0 && fromSlot < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount  && toSlot >= 0 && toSlot < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount)  
		{
			/// get a reference to the slots
			var abilityTo:AbilitySlot = m_AbilitySlots[ toSlot ];
			var abilityFrom:AbilitySlot = m_AbilitySlots[ fromSlot ];
			
			//var fromName = abilityFrom.Name;
			//var fromIcon = abilityFrom.IconName;
			//var fromColor = abilityFrom.m_ColorLine;
			SlotShortcutRemoved( p_from );
			
			if( abilityTo.IsActive)
			{
				SlotShortcutAdded( p_from);
				abilityTo.Clear();
			} 
			SlotShortcutAdded( p_to);			
		}
	}
	
	function CanAddShortcut(pos:Number, spellId:Number) : Boolean
	{
		var spellData:SpellData = Spell.GetSpellData(spellId);
		if (spellData != undefined)
		{
			if (pos != 7 && spellData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
			{
				return false;
			}
			else if (pos == 7 && spellData.m_SpellType != _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
			{
				return false;
			}
		}
		return true;
	}
	
		
	function SlotDragEnd( event:Object )
	{
		if ( event.data.type == "shortcutbar/activeability" )
		{
			var dstID = GetMouseSlotID();

			if ( dstID >= 0 )
			{
				
				var fromData:ShortcutData = Shortcut.m_ShortcutList[event.data.slot_index];
				var toData:ShortcutData = Shortcut.m_ShortcutList[dstID];
                
                var canMove:Boolean = true;
                
				if (fromData != undefined && !CanAddShortcut(dstID - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, fromData.m_SpellId))
				{
					canMove = false;
				}
				if (toData != undefined && !CanAddShortcut(event.data.slot_index - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, toData.m_SpellId))
				{
					canMove = false;
				}
                if (canMove)
                {
                    Shortcut.MoveShortcut( event.data.slot_index, dstID );
                }
                event.data.DragHandled();
			}
		}
        else if ( event.data.type == "skillhive_active" )
        {
            var dstID = GetMouseSlotID();
            if ( dstID >= 0 )
            {
                EquipActive( dstID - _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot, event.data.ability );
                event.data.DragHandled();
            }
        }
        ToggleHighlightTopFrame(false);
	}
	
		
	function GetMouseSlotID() : Number
	{
	  var mousePos:flash.geom.Point = new flash.geom.Point;

	  mousePos.x = _root._xmouse;
	  mousePos.y = _root._ymouse;

	  for ( var i in m_AbilitySlots )
	  {
		var abilitySlot:AbilitySlot = m_AbilitySlots[i];
		var abilityIcon:MovieClip = abilitySlot.Slot;
       
		if ( abilityIcon.hitTest( mousePos.x, mousePos.y, true ) )
		{
		  return abilitySlot.GetSlotId();
		}
	  }
	  return -1;
	}
    
    function GetAbilityColors():Array
    {
        var colorArray:Array = [];
        //Push colorline / undefined if no ability
        for (var i:Number = 0; i < m_AbilitySlots.length; i++)
        {
            if (m_AbilitySlots[i].m_ColorLine != undefined)
            {
                colorArray.push(Colors.GetColor( m_AbilitySlots[i].m_ColorLine));
            }
            else
            {
                colorArray.push(undefined);
            }
        }
        return colorArray;
    }
    
    function ToggleHighlightTopFrame(highlight:Boolean)
    {
        if (!highlight)
        {
            Colors.ApplyColor(this.i_Bar.i_TopFrame, 0x737373)
        }
        else
        {
            Colors.ApplyColor(this.i_Bar.i_TopFrame, 0xAAAAB6)
        }
    }
}