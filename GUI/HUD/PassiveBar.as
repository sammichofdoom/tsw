/// this is all the logic applying to the PassiveBar
import GUI.HUD.AbilitySlot;
import GUI.HUD.PassiveAbilitySlot;
import com.Utils.DragObject;
import com.GameInterface.Spell;
import com.GameInterface.SpellData;
import com.GameInterface.DistributedValue;
import com.GameInterface.Lore
import com.GameInterface.Log;
import com.GameInterface.Utils;
import com.Utils.Colors;
import com.Utils.Signal;
import mx.utils.Delegate;

var m_PassiveAbilitySlots:Array;
var m_NumAbilities:Number = 8;
var m_PassiveBarActive:Boolean;
var m_PassiveAbilitiesEquipped:DistributedValue;

var SizeChanged:Signal;

var m_AuxilliarySlotAchievement:Number = 5437;

function onLoad()
{
	/// connect the signals
	Spell.SignalPassiveUpdate.Connect( GetAllPassives, this );
	Spell.SignalPassiveAdded.Connect( SlotPassiveAdded, this  );
	Spell.SignalPassiveRemoved.Connect( SlotPassiveRemoved, this );
	
	/// check if the passives bar opens or closes
	m_PassiveBarActive = false;
    
	// the button that moves the bar up and down.
	m_Button.addEventListener("press", this, "SlotTogglePassiveBar");
    gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "SlotDragBegin" );
    gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "SlotDragEnd" );
    SizeChanged = new Signal();

    InitializeBar();
   
    GetAllPassives(); 
    
    m_Bar._alpha = 0;    
    m_Bar.onTweenComplete = function()
    { 
       SizeChanged.Emit();
    }

    m_PassiveAbilitiesEquipped = DistributedValue.Create( "PassiveAbilitiesEquipped" );
    m_PassiveAbilitiesEquipped.SignalChanged.Connect( SlotEquippedAbilitiesChanged, this);
	SlotEquippedAbilitiesChanged();
	
	Lore.SignalTagAdded.Connect(SlotTagAdded, this);
	
	if (Lore.IsLocked(m_AuxilliarySlotAchievement))
	{
		 m_Bar["slot_" + 7]._visible = false;
		 //m_Bar["m_Background"]._width -= m_Bar["slot_" + 7]._width + 12;
	}
}

function SlotTagAdded(tag:Number)
{
	if (tag == m_AuxilliarySlotAchievement)
	{
		m_Bar["slot_" + 7]._visible = true;
		//m_Bar["m_Background"]._width += m_Bar["slot_" + 7]._width + 12;
	}
}

function SlotEquippedAbilitiesChanged() 
{
	_alpha = Boolean(m_PassiveAbilitiesEquipped.GetValue()) ? 100 : 0;
}

/// sets up the empty PassiveAbilityslots, and if opened, opens the passive bar
function InitializeBar()
{
    m_PassiveAbilitySlots = [];
 
    // loop the hive and push each of the slots in the m_AbilitySlots array.
    for( var i:Number = 0; i < m_NumAbilities; i++)
    {
        var mc_slot:MovieClip = MovieClip( m_Bar["slot_"+i] );

        if( mc_slot != null )
        {
            m_PassiveAbilitySlots.push( new PassiveAbilitySlot( mc_slot, i ) );
        }
        else
        {
            Log.Error( "PassiveBar", " Failed to retrieve a valid slot at index "+i);
        }
    }
	
	m_Bar["slot_7"].m_AuxilliaryFrame._visible = true;
}


/// fires when the Parent is trying to unload it
function onUnload()
{
}


/// triggers when there is a change to the Passive Lists distributed value
function SlotPassiveListOpenValueChanged(value:DistributedValue)
{
    var isOpen:Boolean = Boolean( value.GetValue() );
    m_Button.disabled = isOpen;
    TogglePassiveBar(isOpen);
}

function SlotTogglePassiveBar(e:Object)
{
    m_PassiveBarActive = !m_PassiveBarActive;
    TogglePassiveBar(m_PassiveBarActive);
}

function TogglePassiveBar(show:Boolean)
{
    if (show)
    {
        OpenPassiveBar();
    }
    else
    {
        ClosePassiveBar();
    }
}

// opens the bar as a result of the button being pressed or the the passivelist being opened
function OpenPassiveBar()
{
    m_Bar.tweenTo(0.3, { _y: -50, _alpha:100 }, Regular.easeOut );
    m_Button._rotation = 180; 
}

// opens the bar as a result of the button being pressed or the the passivelist being opened
function ClosePassiveBar()
{
    m_Bar.tweenTo(0.3, { _y:0, _alpha:0}, Regular.easeOut );
    m_Button._rotation = 0;
}

/// Gets all the equipped passives and 
function GetAllPassives()  : Void
{
	for ( var i:Number = 0; i < m_NumAbilities; i++)
	{
		var passiveID:Number = Spell.GetPassiveAbility(i);
        var passiveData:SpellData = Spell.m_PassivesList[passiveID];
        var abilityslot:AbilitySlot = AbilitySlot( m_PassiveAbilitySlots[ i ] );
		if (passiveData != undefined)
		{
			abilityslot.SetAbilityData( Utils.CreateResourceString(passiveData.m_Icon), passiveData.m_ColorLine, passiveData.m_Id, passiveData.m_SpellType, "Passive" );
		}
        else if(abilityslot.IsActive)
        {
            abilitiyslot.Clear();
        }
	}
}

function debugObject(obj:Object)
{
    for (var prop in obj)
    {
        if ( obj[prop].toString() == "[object Object]" )
        {
            debugObject( obj[prop] )
        }
        
    }
}

function SlotDragBegin( event:Object )
{
    // TODO: HIGLIGHT SLOTS THAT CAN ACCEPT THE DRAGGED OBJECT IF ANY.
   // debugObject(event);
    //trace( "Begin drag passives: " + event.data.type + "(" + event.dropTarget + ") " );
}


function SlotDragEnd( event:Object )
{
    //Check if the mouse is really hovering this movieclip (and not something above it)
    if (Mouse["IsMouseOver"](this))
    {
        if (event.data.type == "passive")
        {
            var dstID = GetMouseSlotID();
            if ( dstID >= 0 ) 
            {
                event.data.DragHandled();
                Spell.EquipPassiveAbility( dstID, event.data.id );
            }
         }
        else if ( event.data.type == "shortcutbar/passiveability" ) //Dragging from a passive ability bar
        {
            var dstID = GetMouseSlotID();

            if ( dstID >= 0)
            {
                event.data.DragHandled();
                if (dstID != event.data.slot_index && m_PassiveAbilitySlots[ event.data.slot_index ].IsActive)
                {
                    Spell.MovePassiveAbility(event.data.slot_index, dstID);
                }
            }
        }
    }
}

function GetMouseSlotID() : Number
{
  var mousePos:flash.geom.Point = new flash.geom.Point;

  mousePos.x = _root._xmouse;
  mousePos.y = _root._ymouse;

  for ( var i in m_PassiveAbilitySlots )
  {
    var abilitySlot:AbilitySlot = m_PassiveAbilitySlots[i];
    var abilityIcon:MovieClip = abilitySlot.Slot.i_Background;
	
    if ( abilityIcon.hitTest( mousePos.x, mousePos.y, true ) )
    {
      return abilitySlot.GetSlotId();
    }
  }
  return -1;
}

/// Signal sent when a shortcut has been added.
/// This also happens when you teleport to a new pf.
/// Note that you might get an SignalShortcutEnabled right afterward if the shortcut is disabled. And SignalCooldownTime if it's in cooldown.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotPassiveAdded( itemPos:Number) : Void
{
    //Add the icon
	if ( itemPos >= 0 && itemPos < m_NumAbilities )
	{
        var passiveID:Number = Spell.GetPassiveAbility(itemPos);
        var passiveData:SpellData = Spell.m_PassivesList[passiveID];
        // First make sure it's removed. Might be something here if messages from server are delayed.
        SlotPassiveRemoved(itemPos);
		var abilityslot:AbilitySlot = AbilitySlot( m_PassiveAbilitySlots[ itemPos ] );

		abilityslot.SetAbilityData(  Utils.CreateResourceString(passiveData.m_Icon), passiveData.m_ColorLine, passiveData.m_Id, passiveData.m_SpellType, "Passive" );
	} 
	else 
	{
		Log.Error( "PassiveBar", "SlotPassiveAdded failed when adding passive to slot: "+itemPos);
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
        abilityslot.Clear( );
	}
	else 
	{
		Log.Error( "PassiveBar", "SlotPassiveRemoved failed when removing an ability from slot: "+itemPos);
	}
}
