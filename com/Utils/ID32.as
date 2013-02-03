/// Class storing a type/instance pair used to identify various items in the game.

class com.Utils.ID32
{
  /// Constructor taking 0-2 arguments. If no arguments the type and instance will be 0, if one argument
  /// are passed the type will be set to that value and the instance to 0, if two values are passed the
  /// type will be set to the first value and the instance to the second.
  /// @author Kurt Skauen
  
  public function ID32() {
    m_Type = 0;
    m_Instance = 0;

    if ( arguments.length > 0 ) {
      m_Type = arguments[0];
      if ( arguments.length > 1 ) {
        m_Instance = arguments[1];
      }
    }
  }

  public function Equal( other:ID32 ) : Boolean
  {
    return (m_Type == other.m_Type && m_Instance == other.m_Instance )
  }

  /// Returns true if id is 0:0.
  public function IsNull() : Boolean
  {
    return m_Type == 0 && m_Instance==0;
  }

  // Returns true if it's a npc. Note: False does not mean it's a player!
  public function IsNpc() : Boolean
  {
    return m_Type == _global.Enums.TypeID.e_Type_GC_Character && m_Instance < (1<<24) && m_Instance != 0;
  }

  // Returns true if it's a player. Note: False does not mean it's a npc!
  public function IsPlayer() : Boolean
  {
    return m_Type == _global.Enums.TypeID.e_Type_GC_Character && m_Instance >= (1<<24);
  }

  // Returns true if it's a simpledynel.
  public function IsSimpleDynel() : Boolean
  {
    return m_Type == _global.Enums.TypeID.e_Type_GC_SimpleDynel;
  }

  // Returns true if it's a destructible.
  public function IsDestructible() : Boolean
  {
    return m_Type == _global.Enums.TypeID.e_Type_GC_Destructible;
  }

  // Returns the id in a string formated as "type:instance" 
  public function toString() : String
  {
    return "" + m_Type + ":" + m_Instance;
  }

  public function GetType() : Number { return m_Type; }
  public function GetInstance() : Number { return m_Instance; }

  public function SetType( type:Number ) : Void { m_Type = type; }
  public function SetInstance( instance:Number ) : Void { m_Instance = instance; }
  
  public var m_Type:Number;
  public var m_Instance:Number;
}
