//Imports
import com.Components.RightClickItem;
import com.Utils.Signal;

//Class
class com.Components.RightClickItemRenderer extends MovieClip
{
    //Properties
    public var SignalRightClickItemSelect:Signal;
    public var m_Background:MovieClip;
    public var m_Separator:MovieClip;
    private var m_Label:TextField;
        
    private var m_RightClickItem:RightClickItem;
    
    //Constructor
    public function RightClickItemRenderer()
    {
        super();
        
        SignalRightClickItemSelect = new Signal();
        
        m_Background._visible = false;
        onRollOver = RollOverEventHandler;
        onPress = function() {};
    }
    
    //Roll Over Event Handler
    private function RollOverEventHandler():Void
    {
        if (m_RightClickItem.m_Label != "" && !m_RightClickItem.m_IsHeadline && m_RightClickItem.IsEnabled())
        {
            onRollOver = null;
            onRollOut = RollOutEventHandler;
            onMouseDown = MouseDownEventHandler;

            m_Background._visible = true;
        }
    }
    
    //Roll Out Event Handler
    private function RollOutEventHandler():Void
    {
        onRollOut = null;
        onMouseDown = null;
        onRollOver = RollOverEventHandler;
        
        m_Background._visible = false;
    }
    
    //Mouse Down Event Handler
    private function MouseDownEventHandler():Void
    {
        if (m_RightClickItem.IsEnabled())
        {
            onRollOut = null;
            onMouseDown = null;
            onMouseUp = MouseUpEventHandler;
            onReleaseOutside = MouseUpEventHandler;
            
            m_Background._visible = true;
        }
    }
    
    //Mouse Up Event Handler
    private function MouseUpEventHandler():Void
    {
        if (m_RightClickItem.IsEnabled())
        {
            onMouseUp = null;
            onReleaseOutside = null;
            onRollOver = RollOverEventHandler;
            
            if (hitTest(_root._xmouse, _root._ymouse, false))
            {
                m_RightClickItem.SignalItemClicked.Emit(m_RightClickItem.m_Label);
            }
            
            m_Background._visible = false;
        }
    }
    
    public function GetRightClickItem():RightClickItem
    {
        return m_RightClickItem;
    }
    
    public function SetRightClickItem(rightClickItem:RightClickItem)
    {
        m_RightClickItem = rightClickItem;
        
        if (m_RightClickItem.m_IsSeparator)
        {
            m_Label._visible = false;
            m_Separator._visible = true;
        }
        else
        {
            m_Label._visible = true;
            m_Separator._visible = false;
            
            m_Label.text = m_RightClickItem.m_Label;
            
            var textFormat:TextFormat = m_Label.getTextFormat();
            textFormat.font = "_StandardFont";
            textFormat.bold = (m_RightClickItem.m_IsHeadline) ? true : false;
            
            if (!m_RightClickItem.IsEnabled())
            {
                textFormat.color = 0xC0C0C0;
            }
            if ( m_RightClickItem.IsNotification() )
            {
                textFormat.color = 0xFFFFCC;
            }
            
            if (m_RightClickItem.m_Alignment == RightClickItem.LEFT_ALIGN || m_RightClickItem.m_Alignment == RightClickItem.CENTER_ALIGN || m_RightClickItem.m_Alignment == RightClickItem.RIGHT_ALIGN)
            {
                textFormat.align = m_RightClickItem.m_Alignment;
            }
            
            m_Label.setTextFormat(textFormat);
        }
    }
}