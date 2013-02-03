class GUI.Tooltip.TooltipEntry
{
    public static var TOOLTIPENTRY_TYPE_MOVIECLIP = 0;
    public static var TOOLTIPENTRY_TYPE_TEXTFIELD = 1;
    public static var TOOLTIPENTRY_TYPE_DIVIDER = 2;
    public static var TOOLTIPENTRY_TYPE_PADDING = 3;
    
    public var m_TypeLeft:Number;
    public var m_TypeRight:Number;
    public var m_ContentLeft:Object;
    public var m_ContentRight:Object;
    
    public var m_Padding:Number;
    
    public function TooltipEntry(type:Number, content:Object, padding:Number)
    {
        m_TypeLeft = type;
        m_ContentLeft = content;
        m_Padding = 0;
        if (padding != undefined)
        {
            m_Padding = padding;
        }
    }
    
    public function SetRightContent(type:Number, content:Object)
    {
        m_TypeRight = type;
        m_ContentRight = content;        
    }
}