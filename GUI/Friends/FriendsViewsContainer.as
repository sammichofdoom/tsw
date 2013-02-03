//Class
class GUI.Friends.FriendsViewsContainer extends MovieClip
{
    //Constants
    public static var FRIENDS_VIEW:String = "FriendsView";
    public static var GUILD_VIEW:String = "GuildView";
    public static var IGNORED_VIEW:String = "IgnoredView";
    
    //Properties
    private var m_FriendsView:MovieClip;
    private var m_GuildView:MovieClip;
    private var m_IgnoredView:MovieClip;

    private var m_ViewsArray:Array;
    private var m_View:String;
    
    //Constructor
    public function FriendsViewsContainer()
    {
        super();
        
        Init();
    }
    
    //Initialize
    private function Init():Void
    {
        m_FriendsView = attachMovie(FRIENDS_VIEW, "m_" + FRIENDS_VIEW, getNextHighestDepth());
        m_GuildView = attachMovie(GUILD_VIEW, "m_" + GUILD_VIEW, getNextHighestDepth());
        m_IgnoredView = attachMovie(IGNORED_VIEW, "m_" + IGNORED_VIEW, getNextHighestDepth());
        
        m_ViewsArray = new Array();
        m_ViewsArray.push({name: FRIENDS_VIEW, view: m_FriendsView});
        m_ViewsArray.push({name: GUILD_VIEW, view: m_GuildView});
        m_ViewsArray.push({name: IGNORED_VIEW, view: m_IgnoredView});
        
        for (var i:Number = 0; i < m_ViewsArray.length; i++)
        {
            m_ViewsArray[i].view._visible = false;
        } 
    }
    
    //Toggle Right Click Menu
    public function ToggleRightClickMenu(value:Boolean):Void
    {
        for (var i:Number = 0; i < m_ViewsArray.length; i++)
        {
            if (value)
            {
                m_ViewsArray[i].view.allowRightClick = true;
            }
            else
            {
                m_ViewsArray[i].view.allowRightClick = false;
                m_ViewsArray[i].view.HideRightClickMenuAndMessagePrompt();
            }
        }
    }
    
    //Set View
    public function set view(value:String):Void
    {
        m_View = value;
        
        for (var i:Number = 0; i < m_ViewsArray.length; i++)
        {
            if (m_ViewsArray[i].name == value)
            {
                m_ViewsArray[i].view._visible = true;
            }
            else
            {
                m_ViewsArray[i].view.HideRightClickMenuAndMessagePrompt();
                m_ViewsArray[i].view._visible = false;
            }
        }
    }
    
    //Get View
    public function get view():String
    {
        return m_View;
    }
}