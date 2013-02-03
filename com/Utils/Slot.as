import com.Utils.Signal;
import com.Utils.SignalGroup;

import mx.utils.Delegate;

class com.Utils.Slot
{
    public function Slot( signal:Signal, group:SignalGroup, callback:Function, object:Object )
    {
        m_Signal      = signal;
        m_SignalGroup = group;

        if ( object != null )
        {
            m_Object = new com.Utils.WeakPtr( object );
            m_Object.OnObjectDied = Delegate.create( this, DisconnectSelf );
        }
        else
        {
            m_Object = null;
        }
        m_Callback = callback;
    }
    public function GetCallback() : Function
    {
        return m_Callback;
    }
    public function GetObject() : Object
    {
        if ( m_Object != null )
        {
            return m_Object.Get();
        }
        else
        {
            return null;
        }
    }
    private function DisconnectSelf() : Void
    {
        m_Signal.DisconnectSlot( this );
    }

    private var m_Callback:Function;
    private var m_Object:com.Utils.WeakPtr;
    public var  m_SignalGroup:SignalGroup;
    public var  m_Signal:Signal;
}
