import com.Utils.Signal;
//Class
class com.Components.RightClickItem
{
    //Constants
    public static var LEFT_ALIGN:String = "left";
    public static var CENTER_ALIGN:String = "center";
    public static var RIGHT_ALIGN:String = "right";
    
    //Properties
    private var m_Enabled:Boolean;
    private var m_IsNotification:Boolean;
    
    public var m_Label:String;
    public var m_IsHeadline:Boolean;
    public var m_Alignment:String;
    public var m_IsSeparator:Boolean;

    
    public var SignalItemClicked:Signal;
    
    
    //Constructor
    public function RightClickItem(label:String, isHeadline:Boolean, alignment:String)
    {
        m_Label = label;
        m_IsHeadline = isHeadline;
        m_Alignment = alignment;
        m_IsSeparator = false;
        m_IsNotification = false;
        m_Enabled = true;
        
        SignalItemClicked = new Signal();
    }
    
    //Separator
    public static function MakeSeparator():RightClickItem
    {
        var result:RightClickItem = new RightClickItem("", false, "");
        result.m_IsSeparator = true;
        
        return result;
    }
    
    public function SetIsNotification(notification:Boolean):Void
    {
        m_IsNotification = notification;
    }
    
    public function IsNotification():Boolean
    {
        return m_IsNotification;
    }
    
    public function SetEnabled(enabled:Boolean):Void
    {
        m_Enabled = enabled;
    }
    
    public function IsEnabled():Boolean
    {
        return m_Enabled;
    }
}