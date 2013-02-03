import mx.utils.Delegate;

////////////////////////////////////////////////////////////////////////////////
/// Container class that can hold a reference to an object and send a signal
/// passing that object to a callback when the container itself is garbage
/// collected. The Contained object is guaranteed to be kept alive until
/// after the signal is sent. Can be usefull for classes that need to do
/// some cleanup inside one of it's members when a instance of the class
/// dies.
////////////////////////////////////////////////////////////////////////////////

class com.Utils.Destructor
{  
    ////////////////////////////////////////////////////////////////////////////////
    /// @fn Destructor( [obj] )
    /// Initializes the instance and optionally wraps an object.
    /// If \p obj is present it will be passed to Set() when initialization is done.
    ////////////////////////////////////////////////////////////////////////////////
    public function Destructor()
    {
        m_Object = null;
        var obj = null;
        if ( arguments.length > 0 )
        {
            obj = arguments[0];
        }
        this.SignalDying = new com.Utils.Signal;
        if ( obj != null )
        {
            this.Set( obj );
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Clear the reference to the wrapped object without sending SignalDying.
    ////////////////////////////////////////////////////////////////////////////////
    public function Clear() : Void
    {
        for ( var i:Number = 0 ; i < s_GuardList.length ; ++i )
        {
            if ( SignalDying === s_GuardList[i].SignalDying )
            {
                s_GuardList[i].m_WeakPtr.Set( null );
                Destructor.s_GuardList.splice( i, 1 );
                break;
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    /// Wrap an object and prepare to send SignalDying if the Destructor object
    /// itself is being garbage collected.
    ////////////////////////////////////////////////////////////////////////////////
    public function Set( obj )
    {
        Clear();
        m_Object = obj;
        if ( m_Object != null )
        {
            var guard:Object = { m_Object:obj };
            guard.SignalDying = SignalDying;
            guard.m_WeakPtr = new com.Utils.WeakPtr( this );
            guard.OnObjectDied = function() {
                this.SignalDying.Emit( m_Object );
                for ( var i:Number = 0 ; i < Destructor.s_GuardList.length ; ++i )
                {
                    if ( this == Destructor.s_GuardList[i] )
                    {
                        Destructor.s_GuardList.splice( i, 1 );
                        break;
                    }
                }
            }
            guard.m_WeakPtr.OnObjectDied = Delegate.create( guard, guard.OnObjectDied );
        
            s_GuardList.push( guard );
        }
    }
    ////////////////////////////////////////////////////////////////////////////////
    /// Returns the object previously specified with Set(), or null if no object
    /// have been set yet.
    ////////////////////////////////////////////////////////////////////////////////
    public function Get() { return m_Object; }

    ////////////////////////////////////////////////////////////////////////////////
    /// Signal being sent when this instance of com.Utils.Destructor is being
    /// garbage collected. When this signal is being sent the Destructor object
    /// is already gone, but SignalDying and the wrapped object is kept in a safe
    /// place until after the signal has been emitted. The wrapped object will be
    /// passed as an argument to the signal.
    ////////////////////////////////////////////////////////////////////////////////
    public var SignalDying:com.Utils.Signal; // SlotDying( obj )
    
    private static var s_GuardList:Array = [];
    private var m_Object;
}
