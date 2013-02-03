//Imports
import com.Utils.Signal;
import com.Utils.ID32;

//Class
class GUI.Friends.Views.Row extends MovieClip
{
    //Constants
    public static var FRIENDS_TYPE:String = "friendsType";
    public static var GUILD_TYPE:String = "guildType";
    public static var IGNORED_TYPE:String = "ignoredType";
    
    //Properties
    public var SignalRowPressed:Signal;

    public var m_Type:String;
    public var m_ID:ID32;
    public var m_Name:MovieClip;
    public var m_SecretSociety:MovieClip;
    public var m_Rank:MovieClip;
    public var m_Role:MovieClip;
    public var m_Region:MovieClip;
    public var m_Online:Boolean;
    
    //Constructor
    public function Row()
    {
        super();
        
        SignalRowPressed = new Signal();
    }
    
    //On Mouse Press
    private function onMousePress(buttonIndex:Number, clickCount:Number):Void
    {
        SignalRowPressed.Emit(buttonIndex, this);
    }
}