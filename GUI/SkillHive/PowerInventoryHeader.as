import gfx.controls.Label;
import com.Utils.Signal;
import mx.utils.Delegate;
import mx.controls.streamingmedia.StreamingMediaConstants;
class GUI.SkillHive.PowerInventoryHeader
{
    private var m_HeaderID:Number;
    private var m_Direction:Number;
    
    private var m_Label:Label;
    private var m_SortArrow:MovieClip;
    
    public var SignalSort:Signal;
    public function PowerInventoryHeader(headerID:Number, name:String, label:Label, sortArrow:MovieClip)
    {
        m_HeaderID = headerID
        m_Direction = 0;
        
        SignalSort = new Signal();
        
        m_SortArrow = sortArrow;
        m_Label = label;
        
        m_Label.text = name;
        if (sortArrow != undefined)
        {
            m_SortArrow.gotoAndStop("default");
            m_Label.onRelease = Delegate.create(this, SlotSort);
        }
    }
    
    private function SlotSort()
    {
        var dir:Number = -m_Direction
        if (dir == 0)
        {
            dir = 1;
        }
        SetDirection(dir)
        SignalSort.Emit(this);
    
    }
    public function SetDirection(direction:Number)
    {
        m_Direction = direction;
        
        if (m_Direction == 1)
        {
            m_SortArrow.gotoAndStop("ascending");
        }
        else if(m_Direction == -1)
        {
            m_SortArrow.gotoAndStop("descending");
        }
        else
        {
            m_SortArrow.gotoAndStop("default");
        }
    }
    
    public function GetDirection()
    {
        return m_Direction;
    }
    
    public function GetHeaderID()
    {
        return m_HeaderID;
    }
}