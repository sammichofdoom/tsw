//import flash.utils.Dictionary;
import com.Utils.Slot;
import com.Utils.SignalGroup;

class com.Utils.Signal
{
    private var m_EventList:Array;

    public function Signal()
    {
        this.m_EventList = new Array;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// @fn Connect( [group:com.Utils.SignalGroup], callback:Function, [context:Object] )
    ///
    /// Connects a function to the signal. Multiple connections can be tracked by
    /// a com.utils.SignalGroup object if you need to disconnect them manually as a
    /// group later. Note that you should rarely need to manually disconnect signals.
    /// Neither using a SignalGroup, nor using Signal.Disconnect(). The Signal class
    /// only hold weak references to it's targets and will automatically break the
    /// connection if the target dies. Since most Signal connections are supposed to
    /// have the same lifespan as the target you will normally rely the automatic
    /// disconnect.
    ///
    /// To add the connection to a group, pass a com.Utils.SignalGroup instance as
    /// the first argument. If no goup is needed (the normal case) you can pass null,
    /// or simply omit the group, and pass a callback function as the first argument.
    ///
    /// The \a callback argument is the function that will be called when the signal
    /// is emitted. All arguments passed to Signal.Emit(...) will be forwarded to
    /// this function. If the \a context argument is specified this will be used as
    /// the 'this' pointer when the callback is called. If no context is specified
    /// the callback will be called as a global or static function.
    ///
    /// Any number of 'slots' or callback can be connected to a signal. You should
    /// not make any assumptions regarding the order in which the callbacks are
    /// called though.
    ///
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function Connect() : com.Utils.Slot
    {
        var group:SignalGroup;
        var callback:Function;
        var context:Object;
        
        var slot:Slot;

        var usedArgs:Number = 0;
        if ( arguments.length > 1 && typeof(arguments[1]) == "function" )
        {
            group = arguments[usedArgs++];
            callback = arguments[usedArgs++];
        }
        else
        {
            group = null;
            callback = arguments[usedArgs++];
        }
        
        if ( arguments.length > usedArgs )
        {
            context = arguments[usedArgs++];
            if ( IsSlotConnected( callback, context ) )
            {
                return;
            }
        }
        else
        {
            context = null;
            if ( IsSlotConnected( callback ) )
            {
                return;
            }
        }

        slot = new Slot( this, group, callback, context );
        m_EventList.push( slot );
        if ( group != null )
        {
            group.AddSlot( slot );
        }
        return slot;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// @fn Disconnect( callback:Function, [context:Object] )
    ///
    /// Manually break a signal/slot connection. This will cancel a previous
    /// connection made with Signal.Connect(). Note that you should rarely need to
    /// manually break a connection as it will automatically go away when the target
    /// object or function is garbage collected.
    ///
    /// @param callback - The callback function specified in the Connect() call.
    /// @param context  - The 'this' pointer specified in the Connect() call, if any.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function Disconnect( callback:Function ) : Boolean
    {
        if ( arguments.length == 1 )
        {
            for ( var i:Number = 0 ; i < m_EventList.length ; ++i )
            {
                if ( m_EventList[i].GetCallback() == callback )
                {
                    if ( m_EventList[i].m_SignalGroup != null )
                    {
                        m_EventList[i].m_SignalGroup.RemoveSlot( m_EventList[i] );
                    }
                    m_EventList.splice( i, 1 );
                    return true;
                }
            }
            trace( "Signal.Disconnect() failed to remove function slot." );
            return false;
        }
        else
        {
            var object:Object = arguments[1];
            for ( var i:Number = 0 ; i < m_EventList.length ; ++i )
            {
                if ( m_EventList[i].GetCallback() == callback && m_EventList[i].GetObject() == object )
                {
                    if ( m_EventList[i].m_SignalGroup != null )
                    {
                        m_EventList[i].m_SignalGroup.RemoveSlot( m_EventList[i] );
                    }
                    m_EventList.splice( i, 1 );
                    return true;
                }
            }
            trace( "Signal.Disconnect() failed to remove method slot." );
            return false;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// @fn IsSlotConnected( callback:Function, [context:Object] )
    ///
    /// Check if a slot is already connected to the signal.
    ///
    /// @param callback - The callback function specified in the Connect() call.
    /// @param context  - The 'this' pointer specified in the Connect() call, if any.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function IsSlotConnected( callback:Function ) : Boolean
    {
        if ( arguments.length == 1 )
        {
            for ( var i:Number = 0 ; i < m_EventList.length ; ++i )
            {
                if ( m_EventList[i].GetCallback() == callback )
                {
                    return true;
                }
            }
            return false;
        }
        else
        {
            var object:Object = arguments[1];
            for ( var i:Number = 0 ; i < m_EventList.length ; ++i )
            {
                if ( m_EventList[i].GetCallback() == callback && m_EventList[i].GetObject() == object )
                {
                    return true;
                }
            }
            return false;
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    /// Same as Disconnect() except that it accepts a com.Utils.Slot instance rather
    /// than a callback/context. The Slot object is returned from Connect() when
    /// making a connection.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function DisconnectSlot( slot:Slot ) : Boolean
    {
        for ( var i:Number = 0 ; i < m_EventList.length ; ++i )
        {
            if ( m_EventList[i] == slot )
            {
                slot.m_Signal = null;
                m_EventList.splice( i, 1 );
                return true;
            }
        }
        trace( "Signal.DisconnectSlot() failed to remove slot." );
        return false;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// @fn Emit(...)
    ///
    /// This is the method that trigger the signal. Emit() will call all the
    /// connected 'slots'. All arguments passed to the Emit() method will be
    /// forwarded to the slot callbacks.
    ///
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function Emit() : Void
    {
        if ( m_EventList.length > 500 )
        {
            trace( "Emit signal to " + m_EventList.length + " slots" );
        }
        var callback;
        for ( var i:Number = 0 ; i < m_EventList.length ; ++i )
        {
            m_EventList[i].GetCallback().apply( m_EventList[i].GetObject(), arguments );
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Returns 'true' if no slots are connected, false otherwice.
    ////////////////////////////////////////////////////////////////////////////////
    
    public function Empty() : Boolean
    {
        return m_EventList.length == 0;
    }
}
