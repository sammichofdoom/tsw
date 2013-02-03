import flash.external.ExternalInterface;
import com.Utils.Signal;
import com.Utils.ID32;

/// NOTE: This object is never removed. So you can keep ref to it and keep the connections.
/// Only the data within it changes.
class com.GameInterface.DynelSlot
{
  public var Name:String = "";
  public var m_Id:ID32;
  public var OnClient:Boolean = false;
  public var Stats:Object = new Object;
  public var Buffs:Object = new Object;

  /// Signal sent any stat has been updated.
  /// Note that there exist 1 signal per Enums.DynelSlot .
  /// Use it like this:  Dynels.Slots[Enums.DynelSlot.e_Slot_Player].StatUpdated.Connect( this.m_SignalGroup, this.onStatUpdated, this );
  /// @param p_StatEnum:Number  -  The type of stat, defined in the Stat  Enum
  /// @param p_StatValue:Number -  The value of the stat
  public var StatUpdated:Signal; /// -> onStatUpdated( p_stat:Number )

  /// This signal is sent for team members to tell if they are visible/available on your client, or too far away.
  /// Use it for teammembers to show less info when not in range.
  /// @param p_OnClient:Boolean  -  True if the dynel is now on the client. 
  public var DynelOnClient:Signal; /// -> onDynelOnClient( p_OnClient:Boolean )

  /// Dispatched when a buff is activated
  /// @param p_BuffID:Number  - The template id of the buff.
  /// @param p_BuffTotalTime:Number - The total time the buff lasts in milliseconds.
  /// @param p_BuffRemainingTime:Number  -  The remaining time of the buff at the time in milliseconds.
  /// @param p_Icon:String  -  The icon string ready to be loaded.
  /// @param p_BuffName:String  -  The friendly name of the buff
  /// @param p_Hostile:Boolean -  The type of spell. Enums.
  /// @param p_Count:Number  - The number of counters if any.
  /// @param p_MaxCounters:Number - The max number of counters.
  /// @param p_ColorLine:Number - The color category.
  public var BuffActivated; /// -> SlotBuffActivated( p_BuffID:Number, p_BuffTotalTime:Number, p_BuffRemainingTime:Number, p_Icon:String, p_BuffName:String, p_Hostile:Boolean, p_Count:Number, p_MaxCounters:Number, p_ColorLine:Number, p_CasterID:Number )
   
  /// Dispatched when a buff is deactivated
  /// @param p_TemplateId:Number  -  The id of the buff
  public var BuffDeactivated; /// -> onBuffDeactivated(p_TemplateId:Number)

  public function DynelSlot()
  {
    StatUpdated = new Signal;
    DynelOnClient = new Signal;
    BuffActivated = new Signal;
    BuffDeactivated = new Signal;
    m_Id = new ID32(0,0)
  }

  /// Returns true if the slot is filled.
  public function Exists() : Boolean
  {
    return !m_Id.IsNull();
  }
  
  // Returns true if it's a npc. Note: False does not mean it's a player!
  public function IsNpc() : Boolean
  {
    return m_Id.IsNpc();
  }

  // Returns true if it's a player. Note: False does not mean it's a npc!
  public function IsPlayer() : Boolean
  {
    return m_Id.IsPlayer();
  }

  // Returns true if it's a simpledynel.
  public function IsSimpleDynel() : Boolean
  {
    return m_Id.IsSimpleDynel();
  }

  // Returns true if it's a destructible.
  public function IsDestructible() : Boolean
  {
    return m_Id.IsDestructible();
  }
  
  public function GetID()
  {
	  return m_Id;
  }
  
}
