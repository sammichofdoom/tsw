import com.Utils.Slot;


class com.Utils.SignalGroup
{

  public function SignalGroup() {
    m_Connections = new Array;
  }

  public function DisconnectAll() {
    for ( var i:Number = 0 ; i < m_Connections.length ; ++i ) {
      var slot:Slot = m_Connections[i];
      
      slot.m_Signal.DisconnectSlot( slot );
    }
    m_Connections.splice( 0 );
  }

  public function AddSlot( slot:Slot ) {
    m_Connections.push( slot );
  }

  public function RemoveSlot( slot:Slot ) {
    for ( var i:Number = 0 ; i < m_Connections.length ; ++i ) {
      if ( m_Connections[i] == slot ) {
        m_Connections.splice( i, 1 );
        break;
      }
    }
  }


  private var m_Connections:Array;
}
