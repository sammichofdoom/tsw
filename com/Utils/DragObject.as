import com.Utils.Signal;

dynamic class com.Utils.DragObject 
{
    public var SignalDroppedOnDesktop:Signal;
    public var SignalDragHandled:Signal;
    
    private var m_DragClip:MovieClip;
    
	private static var s_CurrentDragObject;
	
    public function DragObject()
    {
        SignalDroppedOnDesktop = new Signal;
        SignalDragHandled = new Signal();
		if (s_CurrentDragObject != undefined)
		{
			trace("DragObject is constructed while there is a dragoperation ongoing. Should not be");
		}
		s_CurrentDragObject = this;
    }
    
    public function SetDragClip(dragClip:MovieClip)
    {
        m_DragClip = dragClip;
    }
    
    public function GetDragClip() : MovieClip
    {
        return m_DragClip;
    }
	
	public function DragHandled()
	{
        SignalDragHandled.Emit();
		s_CurrentDragObject = undefined;
	}
	
	public static function onDragEnd()
	{
		setTimeout(SlotDroppedToDesktop, 10 ); 
	}
	
	private static function SlotDroppedToDesktop()
	{
		if (s_CurrentDragObject != undefined)
		{
			s_CurrentDragObject.SignalDroppedOnDesktop.Emit();
            s_CurrentDragObject.DragHandled()
		}
	}
	
	public static function GetCurrentDragObject():DragObject
	{
		return s_CurrentDragObject;
	}
	
    
    
}