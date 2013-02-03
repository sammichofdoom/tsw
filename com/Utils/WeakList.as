import com.Utils.WeakPtr
import mx.utils.Delegate;

////////////////////////////////////////////////////////////////////////////////
/// WeakList is a container similar to Array, except that it does not keep a
/// 'strong' reference to it's objects. This means that you will need atleast
/// one other reference to each object stored in the list to keep it from being
/// garbage collected. When the last external reference to an object inside the
/// list goes away, the object will be garbage collected and the slot it occupies
/// in the list will be automatically removed. Before removing the slot,
/// the SignalObjectDied will be sent. The signal arguments are the index about
/// to be removed, and optionally the user-data associcated with the slot.
/// The slot will not be deleted until after all signal handlers have returned,
/// but the object contained by it will already be gone. This means that
/// GetObject() will return 'undefined', but GetUserData() will still return
/// the associated user-data if specified when adding the object.
/// @author Kurt Skauen
////////////////////////////////////////////////////////////////////////////////

class com.Utils.WeakList
{
    ////////////////////////////////////////////////////////////////////////////////
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////

    public function WeakList()
    {
        m_List = [];
        m_ObjDiedDelegate = Delegate.create( this, OnObjectDied );
        SignalObjectDied = new com.Utils.Signal();
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// @fn PushBack( obj [, userData] )
    /// Appends an object to the end of the array.
    /// @param obj      - The object to append.
    /// @param userData - Optional value associated with obj. The WeakList will keep
    ///                   a strong reference to this object, so it will be kept
    ///                   alive until the object is removed from the array even if
    ///                   no other references to it exists.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function PushBack( obj ) : Number
    {
        var index:Number = m_List.length;
        Insert( index, obj, arguments[1] );
        return index;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// @fn Insert( pos:Number, obj, [userData] )
    /// Same as PushBack, except you are able to specify where to insert the object.
    /// @param pos      - Zero based index for the insertion point. The object will
    ///                   be inserted in the slot infront of \p pos.
    /// @param obj      - The object to append.
    /// @param userData - Optional value associated with obj. The WeakList will keep
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function Insert( pos:Number, obj ) : Void
    {
        var ptr:com.Utils.WeakPtr = new com.Utils.WeakPtr( obj );
        ptr.OnObjectDied = m_ObjDiedDelegate;
        if ( arguments.length > 2 )
        {
            ptr.m_UserData = arguments[2];
        }
        m_List.splice( pos, 0, ptr );
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Remove object at position \p index. No signals will be sent when manually
    /// removing an object.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////

    public function Remove( index:Number )
    {
        m_List.splice( index, 1 );
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Remove all objects. No signals will be sent when manually removing objects.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////

    public function Clear() : Void
    {
        m_List = [];
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Returns the number of objects stored in the array.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////

    public function GetLength() : Number
    {
        return m_List.length;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Get object at position \p index. Note that there might be a slight delay
    /// between an object dying and the list being notified (and the
    /// SignalObjectDied signal being sent). If GetObject() is called between the object
    /// death and the notification this function will return 'undefined'.
    /// This function will also return 'undefined' for the object being deleted if
    /// called while serving the SignalObjectDied event (the object is already gone
    /// by then, but the userData is still available).
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function GetObject( index:Number )
    {
        return m_List[ index ].Get();
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Retrieve the optional user-data associated with an object inside the list.
    /// The user-data will be availabel until the object is manually removed, or
    /// until it is automatically removed after all SignalObjectDied slot's has
    /// returned. I.e. the user-data is available while serving SignalObjectDied.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function GetUserData( index:Number )
    {
        return m_List[ index ].m_UserData;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    public function toString() : String
    {
        var text:String = "[";

        for ( var i:Number = 0 ; i < m_List.length ; ++i )
        {
            var node:String = m_List[i].Get();
            if ( m_List[i].m_UserData != undefined )
            {
                node += "{" + m_List[i].m_UserData + "}";
            }
            if ( i > 0 ) text += ", ";
            text += node;
        }
        text += "]";
        return text;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// SignalObjectDied( index:Number, [userData] ).
    /// Signal being sent whenever an object inside the list is being garbage
    /// collected. When the signal is being invoked the slot at \p index is still
    /// valid, but the object stored there has been deleted. I.e.
    /// GetUserData( index ) will still work, but GetObject( index ) will return
    /// 'undefined'. When the last signal handler returns the slot itself will be
    /// removed.
    /// If the same object is added multiple times to the list, the signal will
    /// be sent multiple times when the object die. One for each slot holding the
    /// object.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////

    public var SignalObjectDied:com.Utils.Signal;


    ////////////////////////////////////////////////////////////////////////////////
    /// Callback from the weak pointers used internally. This will be called
    /// whenever and object die, and are responsible for sending SignalObjectDied
    /// and then delete the slot wrapping the dead object.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnObjectDied( ptr:com.Utils.WeakPtr )
    {
        for ( var i:Number = 0 ; i < m_List.length ; ++i )
        {
            if ( m_List[i] == ptr )
            {
                SignalObjectDied.Emit( i, ptr.m_UserData );
                m_List.splice( i, 1 );
                break;
            }
        }
    }

    
    private var m_List:Array;
    private var m_ObjDiedDelegate;
}


