////////////////////////////////////////////////////////////////////////////////
/// WeakPtr is a container class that can hold exactly one object, but that does
/// not keep a 'strong' reference to the object that it contains. This means
/// that atleast one external reference must be kept to the object to prevent it
/// from being garbage collected. When the last external reference to the object
/// pointet at by a weak pointer dies the pointer will automatically start
/// pointing at 'undefined' rather than the original object. It will also send
/// an event informing the user about the object death.
/// @author Kurt Skauen
////////////////////////////////////////////////////////////////////////////////

intrinsic dynamic class com.Utils.WeakPtr
{
    ////////////////////////////////////////////////////////////////////////////////
    /// Constructor.
    /// @param obj - Initial object to reference (see Set()), or null.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    public function WeakPtr( obj );
    
    ////////////////////////////////////////////////////////////////////////////////
    /// Assign an object to the pointer. The pointer will keep a week reference to
    /// this object that can be converted back to a strong reference by calling
    /// Get() as long as it has not been garbage collected.
    /// At least one external strong reference to the object must be kept to prevent
    /// the object from dying.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    public function Set( obj ) : Void;

    ////////////////////////////////////////////////////////////////////////////////
    /// Convert the internal weak reference to a normal strong reference. If the
    /// pointer is referencing a valid object this member will return the object
    /// and the caller will be the owner of a strong reference to it. If no object
    /// have yet been assigned to the pointer, or if the assigned object have since
    /// died due to no external references being kept to it, this member will return
    /// 'undefined'.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    public function Get();

    
    ////////////////////////////////////////////////////////////////////////////////
    /// Callback being called when the target object dies. If the last external
    /// reference to the contained object goes away, the object will die. When this
    /// happens OnObjectDied() will be called to inform about the event. To listen
    /// to the event just assign a callable to OnObjectDied(). When OnObjectDied()
    /// is called, the object pointed to is already dead and can not be investigated
    /// The callback will be sent a reference to the WeakPtr object that trigged
    /// the event. If the same callback is assigned to multiple WeakPtr objects
    /// this argument can be used to figure out which pointer fired the event.
    /// @author Kurt Skauen
    ////////////////////////////////////////////////////////////////////////////////
    public function OnObjectDied( ptr:com.Utils.WeakPtr ) : Void;
}
