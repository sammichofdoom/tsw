import flash.external.ExternalInterface;
import com.Utils.Signal;
import com.GameInterface.DynelSlot;

/// Signals regarding stats and buffs on any character, Wraps the ASDynels.cpp for actionscript
class com.GameInterface.Dynels extends com.GameInterface.DynelsBase
{
  /// The DynelSlot object is never removed as it represent directly to the slots defined by Enums.DynelSlot so you can always keep connections to the signals and never change them.
  /// Use Exists() if you need to check that the slot holds some dynel.
  public static var Slots:Array = new Array( new DynelSlot, new DynelSlot, new DynelSlot, new DynelSlot, new DynelSlot, new DynelSlot, new DynelSlot, new DynelSlot, new DynelSlot, new DynelSlot, new DynelSlot ); 

  /// Signal dispatched when a change to a slot is discovered (that is that a target is being replaced, added or removed)
  /// @param p_Slot:Number  -  The slot id
  /// @param p_Exists:Booelan - True if the slot has a dynel.
  public static var SlotChanged = new Signal; /// -> onSlotChanged( p_Slot:Number )

  /// Dispatched when a registered object is removed from the client.
  /// @param type:Number -  The type for the object
  /// @param instance:Number  -  The instance for the object
  public static var DynelGone = new Signal; /// -> onDynelGone( type:Number, instance:Number )
}
