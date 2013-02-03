//Imports
import gfx.core.UIComponent;

//Class
class GUI.LoginCharacterSelection.ServerListFacebookInfo extends UIComponent
{
    //Properties
    private var m_TotalFriends:TextField;
    private var m_FriendsNumber:Number;
    
    //Constructor
    public function ServerListFacebookInfo()
    {
        super();
        m_FriendsNumber = -1;
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_TotalFriends.autoSize = "right";
    }
    
    //Set Total Friends
    public function SetTotalFriends(value:Number):Void
    {
        m_FriendsNumber = value;
        m_TotalFriends.text = value.toString();
    }
    
    //Display some text while there're no number of friends info
    public function SetWaitingText(value:String):Void
    {
        m_TotalFriends.text = value.toString();
    }
    
    public function GetTotalFriends():Number
    {
        return m_FriendsNumber;
    }
    
    //On Roll Over
    private function onRollOver():Void
    {
        //trace("*** roll over");
    }
    
    //On Roll Out
    private function onRollOut():Void
    {
        //trace("****** roll out");
    }
}