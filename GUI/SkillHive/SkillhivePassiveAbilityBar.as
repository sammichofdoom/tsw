import GUI.HUD.PassiveAbilitySlot;
import GUI.HUD.AbilitySlot;
import com.GameInterface.Spell;
import com.GameInterface.SpellBase;
import com.GameInterface.SpellData;
import flash.filters.GlowFilter;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.Utils.Colors;
import com.GameInterface.Utils;
import com.GameInterface.Lore;

dynamic class GUI.SkillHive.SkillhivePassiveAbilityBar extends MovieClip
{
	var m_NumAbilities:Number = 8;
	var m_PassiveAbilitySlots:Array;
    
	var m_AuxilliarySlotAchievement:Number = 5437;
    var SignalToggleVisibility:Signal;
    
    function SkillhivePassiveAbilityBar()
    {
        SignalToggleVisibility = new Signal();
    }
	function onLoad()
	{
		m_PassiveAbilitySlots = [];
		Spell.SignalPassiveAdded.Connect( SlotPassiveAdded, this  );
		Spell.SignalPassiveRemoved.Connect( SlotPassiveRemoved, this );
        
		
		for( var i:Number = 0; i < m_NumAbilities; i++)
		{
			var mc_slot:MovieClip = MovieClip( this["slot_"+i] );

			if( mc_slot != null )
			{
				m_PassiveAbilitySlots.push( new PassiveAbilitySlot( mc_slot, i ) );
			}
		}
		
		for ( var i:Number = 0; i < m_NumAbilities; i++)
		{
            var passiveID:Number = Spell.GetPassiveAbility(i);
            var passiveData:SpellData = SpellBase.m_PassivesList[passiveID];
			var abilityslot:AbilitySlot = AbilitySlot( m_PassiveAbilitySlots[ i ] );
			if (passiveData != undefined)
			{
				abilityslot.SetAbilityData(  Utils.CreateResourceString(passiveData.m_Icon), passiveData.m_ColorLine, passiveData.m_Id, passiveData.m_SpellType, "Passive", false );
			}
		}
        
        this.i_Bar.i_TopFrame.onPress = Delegate.create(this, SlotToggleVisibility);
        
		gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "SlotDragEnd" );
	
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
    
        Spell.SignalPassiveAdded.Disconnect( SlotPassiveAdded, this  );
        Spell.SignalPassiveRemoved.Disconnect( SlotPassiveRemoved, this );
        
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
 
		
	function CanAddPassive(pos:Number, spellId:Number) : Boolean
	{
		var spellData:SpellData = Spell.GetSpellData(spellId);
		if (spellData != undefined)
		{
			if (pos != 7 && spellData.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
			{
				return false;
			}
			else if (pos == 7 && spellData.m_SpellType != _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
			{
				return false;
			}
		}
		return true;
	}
	
    
    function GetTopFrameHeight():Number
    {
        return (this.i_Bar.i_TopFrame._height * (this._yscale / 100)) + 5;
    }
    
    function SlotToggleVisibility()
    {
        SignalToggleVisibility.Emit();
    }
	
	public function EquipPassive(slotId:Number, spellId:Number)
	{
		if (CanAddPassive(slotId, spellId))
		{
			Spell.EquipPassiveAbility(slotId, spellId);
		}
	}
	
	public function UnEquipPassive(spellId:Number)
	{
		for (var i:Number = 0; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
		{
			if (Spell.GetPassiveAbility(i) == spellId)
			{
				Spell.UnequipPassiveAbility(i);
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
	function SlotPassiveAdded( itemPos:Number ) : Void
	{
		//Add the icon
		if ( itemPos >= 0 && itemPos < m_NumAbilities )
		{   
            var passiveID:Number = Spell.GetPassiveAbility(itemPos);
            var passiveData:SpellData = SpellBase.m_PassivesList[passiveID];
			// First make sure it's removed. Might be something here if messages from server are delayed.
			SlotPassiveRemoved(itemPos);
			var abilityslot:AbilitySlot = AbilitySlot( m_PassiveAbilitySlots[ itemPos ] );
            abilityslot.SetAbilityData(  Utils.CreateResourceString(passiveData.m_Icon), passiveData.m_ColorLine, passiveData.m_Id, passiveData.m_SpellType, "Passive",false );
		}
	}

	/// Signal sent when a shortcut has been removed.
	/// This will not be sent if the shortcut changes position, moved.
	/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
	function SlotPassiveRemoved( itemPos:Number ) : Void
	{
		if ( itemPos >= 0 && itemPos < m_NumAbilities )
		{
			var abilityslot:AbilitySlot = m_PassiveAbilitySlots[ itemPos ];
			if (abilityslot.IsActive)
			{
				abilityslot.Clear( );
			}
		}
	}
    
    		
	function SlotDragEnd( event:Object )
	{
        if ( event.data.type == "shortcutbar/passiveability" ) //Dragging from a passive ability bar
        {
            var dstID = GetMouseSlotID();

            if ( dstID >= 0)
            {
                if (dstID != event.data.slot_index && m_PassiveAbilitySlots[ event.data.slot_index ].IsActive)
                {
					var fromPassiveId:Number = Spell.GetPassiveAbility(event.data.slot_index);
					var toPassiveId:Number = Spell.GetPassiveAbility(dstID);
                    var canMove:Boolean = true;
					if (fromPassiveId != undefined && !CanAddPassive(dstID, fromPassiveId))
					{
						canMove = false;
					}
					if (toPassiveId != undefined && !CanAddPassive(event.data.slot_index, toPassiveId))
					{
						canMove = false;
					}
                    
                    if (canMove)
                    {
                        Spell.MovePassiveAbility(event.data.slot_index, dstID);
                    }
                    event.data.DragHandled();
                }
            }
        }
        else if ( event.data.type == "skillhive_passive" )
        {
            var dstID = GetMouseSlotID();
            if ( dstID >= 0 )
            {
				EquipPassive( dstID, event.data.ability);
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

	  for ( var i in m_PassiveAbilitySlots )
	  {
		var abilitySlot:AbilitySlot = m_PassiveAbilitySlots[i];
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
        for (var i:Number = 0; i < m_PassiveAbilitySlots.length; i++)
        {
            if (m_PassiveAbilitySlots[i].m_ColorLine != undefined)
            {
                colorArray.push(Colors.GetColor( m_PassiveAbilitySlots[i].m_ColorLine));
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
            Colors.ApplyColor(this.i_Bar.i_TopFrame, 0xDEDEDE)
        }
    }
	
}