import com.Utils.Signal;

class  GUI.SkillHive.BreadcrumbLabel extends gfx.controls.Label
{
    private var m_LinkedMovieClip:MovieClip;
    private var m_IsInteractable:Boolean
    
    public var SignalLabelPressed:Signal;
    
    function BreadcrumbLabel()
    {
        super();
        SignalLabelPressed = new Signal();
    }
    
    public function SetLinkedMovieClip(mc:MovieClip)
    {
        m_LinkedMovieClip = mc;
        m_IsInteractable = true;
    }
    
    public function IsInteractable()
    {
        return m_IsInteractable;
    }
    
    function onRollOver()
    {
        if (m_IsInteractable)
        {
            this.textField.textColor = 0xFFFFFF;
        }
    }
    
    function onRollOut()
    {
        if (m_IsInteractable)
        {
            this.textField.textColor = 0xDDDDDD;
        }
    }
    function onDragOut()
    {
        onRollOut();
    }
    
    function onRelease()
    {
        if (m_IsInteractable)
        {
            SignalLabelPressed.Emit(m_LinkedMovieClip);
        }
    }
    
}