/// this is all the logic applying to the AbilityBar
import GUI.HUD.AbilitySlot;
import GUI.HUD.ActiveAbilitySlot;
import GUI.HUD.AbilityBase;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Utils;
import com.GameInterface.DistributedValue;
import com.GameInterface.Log;
import com.GameInterface.Lore;
import com.GameInterface.ProjectUtils;
import com.Utils.DragObject;
import com.Utils.ID32;
import mx.utils.Delegate;


var m_AbilitySlots:Array = [];
var m_PassiveAbilitiesEquipped:DistributedValue;
var m_ShowHotkeys:DistributedValue;
var m_Character:Character;
var m_UsedShortcut:Number;

var STATE_WRONG_HEAPON:Number = 0;
var STATE_OUT_OF_RANGE:Number = 1;
var STATE_NO_RESOURCE:Number = 2;
var STATE_CASTING:Number = 3;
var STATE_CHANNELING:Number = 4;
var STATE_COOLDOWN:Number = 5;
var STATE_GLOBAL_COOLDOWN:Number = 6;
var STATE_ACTIVE:Number = 7;
var STATE_MAX_MOMENTUM:Number = 9;

var PLAYER_MAX_ACTIVE_SPELLS:String = "PlayerMaxActiveSpells";
var PLAYER_START_SLOT_SPELLS:String = "PlayerStartSlotSpells";

var m_AuxilliarySlotAchievement:Number = 5437;

var m_BaseWidth:Number;



function onLoad()
{
    /*
     *  m_BaseWidth is referenced from com.Utils.HUDController.as to serve
     *  as a constant.  Without this constant, unintentional repositioning of
     *  the AbilityBar will occur:
     * 
     *  http://jira.funcom.com/browse/TSW-101595
     *
     */
    m_BaseWidth = _width;
    
    gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "onDragBegin" );
    gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );

    m_PassiveAbilitiesEquipped = DistributedValue.Create( "PassiveAbilitiesEquipped" );
    m_PassiveAbilitiesEquipped.SignalChanged.Connect( SlotEquippedAbilitiesChanged, this);
    m_ShowHotkeys = DistributedValue.Create( "ShortcutbarHotkeysVisible" );
    m_ShowHotkeys.SignalChanged.Connect( SlotShortcutbarHotkeysVisibleChanged, this);

    // loop the hive and push each of the slots in the m_AbilitySlots array.
    for( var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
    {
        var mc_slot:MovieClip = MovieClip( this["slot_"+i] );

        if( mc_slot != null )
        {
            m_AbilitySlots.push( new ActiveAbilitySlot( mc_slot, ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS) + i ) );
            var hotkey:MovieClip = attachMovie("HotkeyLabel", "m_HotkeyLabel" + i, getNextHighestDepth());
            hotkey._x = mc_slot._x + 2;
            hotkey._y = mc_slot._y + 1;
        }
        else
        {
            Log.Error( "AbilityBar", "Failed to retrieve a valid slot at index "+i); 
        }
    }
    
    /// connect the signals
	Shortcut.SignalShortcutAdded.Connect( SlotShortcutAdded, this  );
	Shortcut.SignalShortcutRemoved.Connect( SlotShortcutRemoved, this );
	Shortcut.SignalShortcutMoved.Connect( SlotShortcutMoved, this );
	Shortcut.SignalShortcutStatChanged.Connect( SlotShortcutStatChanged, this );
//	Shortcut.SignalShortcutResourceEnabled.Connect( SlotShortcutResourceEnabled, this );
    Shortcut.SignalShortcutEnabled.Connect( SlotShortcutEnabled, this );
    Shortcut.SignalShortcutRangeEnabled.Connect( SlotShortcutRangeEnabled, this );
    Shortcut.SignalShortcutUsed.Connect( SlotShortcutUsed, this );
    Shortcut.SignalShortcutAddedToQueue.Connect( SlotShortcutAddedToQueue, this );
    Shortcut.SignalShortcutRemovedFromQueue.Connect( SlotShortcutRemovedFromQueue, this );
	Shortcut.SignalCooldownTime.Connect( SlotCooldownTime,this );
	Shortcut.SignalShortcutsRefresh.Connect( SlotShortcutsRefresh, this );
    Shortcut.SignalHotkeyChanged.Connect( SlotHotkeyChanged, this );
    Shortcut.SignalSwapShortcut.Connect( SlotSwapShortcut, this);
    
//    Shortcut.SignalShortcutMaxMomentumEnabled.Connect( SlotSignalShortcutMaxMomentumEnabled, this);
	
    m_Character = Character.GetClientCharacter();
    m_Character.SignalCommandStarted.Connect(SlotSignalCommandStarted, this);
    m_Character.SignalCommandEnded.Connect(SlotSignalCommandEnded, this);
    m_Character.SignalCommandAborted.Connect(SlotSignalCommandAborted, this);
        
    Shortcut.RefreshShortcuts( ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS), ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS) );
   
	SlotEquippedAbilitiesChanged();
    
    /// Update Hotkey Labels
    SlotHotkeyChanged();
    SlotShortcutbarHotkeysVisibleChanged();
	
	Lore.SignalTagAdded.Connect(SlotTagAdded, this);
	
	if (Lore.IsLocked(m_AuxilliarySlotAchievement))
	{
		this["slot_"+7]._visible = false;
		this["m_AuxilliaryFrame"]._visible = false;
		this["m_HotkeyLabel" + 7]._visible = false;
	}
}

function onUnload()
{
    gfx.managers.DragManager.instance.removeEventListener( "dragBegin", this, "onDragBegin" );
    gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "onDragEnd" );
    
    Shortcut.SignalShortcutAdded.Disconnect( SlotShortcutAdded, this  );
    Shortcut.SignalShortcutRemoved.Disconnect( SlotShortcutRemoved, this );
    Shortcut.SignalShortcutMoved.Disconnect( SlotShortcutMoved, this );
    Shortcut.SignalShortcutStatChanged.Disconnect( SlotShortcutStatChanged, this );
    Shortcut.SignalShortcutEnabled.Disconnect( SlotShortcutEnabled, this );
    Shortcut.SignalShortcutRangeEnabled.Disconnect( SlotShortcutRangeEnabled, this );
    Shortcut.SignalShortcutUsed.Disconnect( SlotShortcutUsed, this );
    Shortcut.SignalShortcutAddedToQueue.Disconnect( SlotShortcutAddedToQueue, this );
    Shortcut.SignalShortcutRemovedFromQueue.Disconnect( SlotShortcutRemovedFromQueue, this );
    Shortcut.SignalCooldownTime.Disconnect( SlotCooldownTime,this );
    Shortcut.SignalShortcutsRefresh.Disconnect( SlotShortcutsRefresh, this );
    Shortcut.SignalHotkeyChanged.Disconnect( SlotHotkeyChanged, this );
    Shortcut.SignalSwapShortcut.Disconnect( SlotSwapShortcut, this);
    
    m_Character.SignalCommandStarted.Disconnect(SlotSignalCommandStarted, this);
    m_Character.SignalCommandEnded.Disconnect(SlotSignalCommandEnded, this);
    m_Character.SignalCommandAborted.Disconnect(SlotSignalCommandAborted, this);
    
    Lore.SignalTagAdded.Disconnect(SlotTagAdded, this);
}

function SlotTagAdded(tag:Number)
{
	if (tag == m_AuxilliarySlotAchievement)
	{
		this["slot_" + 7]._visible = true;
		this["m_AuxilliaryFrame"]._visible = true;
		this["m_HotkeyLabel" + 7]._visible = true;
	}
}

function SlotHotkeyChanged(hotkeyId:Number) : Void
{
    for( var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
    {
        var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel" + i] );
        hotkey.m_HotkeyText.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
        hotkey.m_HotkeyText.text = "<variable name='hotkey:" + "Shortcutbar_" + (i + 1) + "'/ >";
    }
}

function SlotShortcutbarHotkeysVisibleChanged()
{
    for( var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
    {
        var hotkey:MovieClip = MovieClip( this["m_HotkeyLabel" + i] );
        hotkey._visible = Boolean(m_ShowHotkeys.GetValue());
    }
}


function SlotEquippedAbilitiesChanged() 
{
	var show:Boolean = false;
	if (Boolean(m_PassiveAbilitiesEquipped.GetValue()))
	{
		show = true;
	}
	else
	{
		for (var i:Number = 0; i < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS); i++)
		{
			if (m_AbilitySlots[i].IsActive)
			{
				show = true;
				break;
			}
		}
	}
	_alpha = (show ? 100 : 0);
}


/// Signal sent when a shortcut has been added.
/// This also happens when you teleport to a new pf.
/// Note that you might get an SignalShortcutEnabled right afterward if the shortcut is disabled. And SignalCooldownTime if it's in cooldown.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotShortcutAdded( itemPos:Number) : Void
{
//    Log.Info2( "AbilityBar", "SlotShortcutAdded(" + itemPos + ") ");
    
    if( IsAbilityShortcut(itemPos) )
    {
        var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
        var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
        var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
        var abilitySlot:AbilitySlot = AbilitySlot( m_AbilitySlots[ slotNo ] );
        abilitySlot.SetAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", true);
        abilitySlot.CloseTooltip();
        SlotEquippedAbilitiesChanged();
    }
    
}

//Signal set when a shortcut should be swapped with another one.
//@param itemPos:Number the position of the item to swap
//@param templateID:Number the id of the new shortcut
function SlotSwapShortcut(itemPos:Number, templateID:Number):Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        SwapAbilities(itemPos);
    }
}

function IsAbilityShortcut(itemPos:Number):Boolean
{
    var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
    var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
    var checkSpell:Boolean = (shortcutData)?(shortcutData.m_ShortcutType == _global.Enums.ShortcutType.e_SpellShortcut) : true;
    if ( slotNo >= 0 && slotNo < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS) && checkSpell)
    {
        return true;
    }
    return false;
}

function SwapAbilities(itemPos:Number):Void
{
    if (itemPos != undefined)
    {
        if( IsAbilityShortcut(itemPos) )
        {
            var slotNo:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
            var shortcutData:ShortcutData = Shortcut.m_ShortcutList[itemPos];
            var spellData:com.GameInterface.SpellData = com.GameInterface.Spell.GetSpellData( shortcutData.m_SpellId );
            var abilitySlot:AbilitySlot = AbilitySlot( m_AbilitySlots[ slotNo ] );
            abilitySlot.SwapAbilityData( Utils.CreateResourceString(shortcutData.m_Icon), shortcutData.m_ColorLine, spellData.m_Id, spellData.m_SpellType, "Ability", true);
            abilitySlot.CloseTooltip();
            SlotEquippedAbilitiesChanged();
        }
    }
}

/// Signal sent when a shortcut has been removed.
/// This will not be sent if the shortcut changes position, moved.
/// @param itemPos:Number   The position the item was added to. This is used for refering to this item.
function SlotShortcutRemoved( itemPos:Number ) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);

        if ( abilitySlot != undefined )
        {
            abilitySlot.Clear( );
        }
        
        SlotEquippedAbilitiesChanged();
    }
}


/// Signal sent when a shortcut has been move to some other spot.
/// No add/remove signal will be triggered.
/// @param fromPos:Number   The position the item was move from.
/// @param toPos:Number     The position the item was move to.
function SlotShortcutMoved( p_from:Number, p_to:Number ) : Void
{ 
    SlotShortcutRemoved(p_to);
    SlotShortcutRemoved(p_from);
    
    SlotShortcutAdded(p_to);
    if (Shortcut.m_ShortcutList.hasOwnProperty(p_from+""))
    {
        SlotShortcutAdded(p_from);
    }
}


/// Signal sent when a shortcut is enabled/disabled.
/// Will also be send when you enter a new playfield.
/// @param itemPos:Number   The position of the item.
/// @param enabled:Number   0=disable, 1=enabled
function SlotShortcutEnabled( itemPos:Number, enabled:Boolean ) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        if (abilitySlot.IsActive)
        {
            abilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_DISABLED );
        }
    }
}


/// Signal sent when a shortcut is enabled/disabled via range.
/// @param itemPos:Number   The position of the item.
/// @param enabled:Boolean   Enabled/Disabled
function SlotShortcutRangeEnabled(itemPos:Number, enabled:Boolean) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        
        if (abilitySlot.IsActive)
        {
            abilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_OUT_OF_RANGE );
        }
    }
}


/// Signal sent when a shortcut is enabled/disabled via resource.
/// @param itemPos:Number   The position of the item.
/// @param enabled:Boolean   Enabled/Disabled
function SlotShortcutResourceEnabled(itemPos:Number, enabled:Boolean) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        if (abilitySlot.IsActive)
        {
            abilitySlot.UpdateAbilityFlags(!enabled, AbilityBase.FLAG_NO_RESOURCE );
        }
    }
}


///Slot function called when an ability is used
/// @param itemPos:Number   The position of the item.
function SlotShortcutUsed(itemPos:Number)
{
    if( IsAbilityShortcut(itemPos) )
    {
        m_UsedShortcut = itemPos;
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        abilitySlot.Fire();
    }
}

function SlotShortcutAddedToQueue(itemPos:Number)
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        abilitySlot.AddToQueue();
    }
}

function SlotShortcutRemovedFromQueue(itemPos:Number)
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        abilitySlot.RemoveFromQueue();
    }
}

/// Signal that triggers every time the player load the game or teleports or whatever, will call the 
/// SlotShortcutAdded for every shortcut item.
function SlotShortcutsRefresh() : Void
{ 
    Shortcut.RefreshShortcuts( ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS), ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS) );
}


/// Signal sent when a shortcut changed one of it's stats. Probably most usefull for stacksize changes.
/// @param itemPos:Number   The position of the item.
/// @param stat:Number      The stat that changed. See Enums/Stats.as
/// @param value:Number     The new value for the stat.
function SlotShortcutStatChanged( itemPos:Number, stat:Number, value:Number ) : Void
{

}


// Signal sent when a shortcut enters cooldown.
/// Will also be send when you enter a new playfield.
/// @param itemPos:Number       The position of the item.
/// @param cooldownStart:Number The start of the cooldown.
/// @param cooldownEnd:Number The end of the cooldown.
/// @param cooldownFlags:Number  The cooldown type from Enums.TemplateLock...
function SlotCooldownTime( itemPos:Number, cooldownStart:Number, cooldownEnd:Number,  cooldownFlags:Number ) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);

        var seconds:Number = cooldownEnd - cooldownStart;
        if (cooldownFlags > 0 && seconds > 0)
        {
            abilitySlot.AddCooldown( cooldownStart, cooldownEnd, cooldownFlags );
        }
        else if (cooldownFlags == 0 && seconds <= 0)
        {
            abilitySlot.RemoveCooldown();
        }
    }
}


/// Method invoked when a shortcut is enters its max momentum.
/// @param itemPos:Number   The position of the item.
function SlotSignalShortcutMaxMomentumEnabled( itemPos:Number, enabled:Boolean ) : Void
{
    if( IsAbilityShortcut(itemPos) )
    {
        var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(itemPos);
        if (abilitySlot.IsActive)
        {
            abilitySlot.UpdateAbilityFlags(enabled, AbilityBase.FLAG_MAX_MOMENTUM );
        }
    }
}


function SlotSignalCommandStarted( name:String, progressBarType:Number) : Void
{
    var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(m_UsedShortcut);
	//Check if it is really channeling
    if (abilitySlot.IsActive && progressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty)
    {
        abilitySlot.StartChanneling();
    }
}

function SlotSignalCommandEnded()
{
    var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(m_UsedShortcut);
    if (abilitySlot.IsActive && abilitySlot.IsChanneling())
    {
        abilitySlot.StopChanneling();
    }
}

function SlotSignalCommandAborted()
{
    var abilitySlot:ActiveAbilitySlot = GetAbilitySlot(m_UsedShortcut);
    if (abilitySlot.IsActive)
    {
        abilitySlot.StopChanneling();
    }
}


function GetAbilitySlot(itemPos:Number) : GUI.HUD.ActiveAbilitySlot
{
    var slotID:Number = itemPos - ProjectUtils.GetUint32TweakValue(PLAYER_START_SLOT_SPELLS);
    
    if ( slotID >= 0 && slotID < ProjectUtils.GetUint32TweakValue(PLAYER_MAX_ACTIVE_SPELLS))
    {
        return m_AbilitySlots[ slotID ];
    }
    return null;
    /*
    else
    {
        Log.Warning("AbilityBar", "GetAbilitySlot(), No slot found at " + itemPos);
        return null;
    }*/
}

function onDragBegin( event:Object )
{
    // TODO: HIGLIGHT SLOTS THAT CAN ACCEPT THE DRAGGED OBJECT IF ANY.
    //trace( "Begin drag: " + event.data.type + "(" + event.dropTarget + ")" );
}

function GetMouseSlotID() : Number
{
    var mousePos:flash.geom.Point = new flash.geom.Point;

    mousePos.x = _root._xmouse;
    mousePos.y = _root._ymouse;

    for ( var i in m_AbilitySlots )
    {
        var abilitySlot:AbilitySlot = m_AbilitySlots[i];
        var abilityIcon:MovieClip = abilitySlot.Slot().i_SlotBackground;

        if ( abilityIcon.hitTest( mousePos.x, mousePos.y, true ) )
        {
            return abilitySlot.GetSlotId();
        }
    }
    return -1;
}

function onDragEnd( event:Object )
{
    //Check if the mouse is really hovering this movieclip (and not something above it)
    if (Mouse["IsMouseOver"](this))
    {
        if ( event.data.type == "spell" )
        {
            var dstID = GetMouseSlotID();
            if ( dstID >= 0 )
            {
                event.data.DragHandled();
                Shortcut.AddSpell( dstID, event.data.id );
            }
        }
        else if ( event.data.type == "shortcutbar/activeability" )
        {
            var dstID = GetMouseSlotID();

            if ( dstID >= 0 )
            {
                Shortcut.MoveShortcut( event.data.slot_index, dstID );
                event.data.DragHandled();
            }
        }
    }
}


