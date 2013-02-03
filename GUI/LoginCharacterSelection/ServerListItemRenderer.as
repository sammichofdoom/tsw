//Imports
import com.GameInterface.AccountManagement;
import com.GameInterface.Browser.Facebook;
import com.GameInterface.CharacterData;
import com.GameInterface.DimensionData;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.*;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.controls.Button;
import gfx.controls.ListItemRenderer;

//Class
class GUI.LoginCharacterSelection.ServerListItemRenderer extends ListItemRenderer
{
    private static var MAX_DOTS:Number = 3;
    
    //Properties
    private var m_ServerName:TextField;
    private var m_ServerInfo:TextField;
    private var m_IsConfigured:Boolean;
    private var m_FacebookInfo:MovieClip;
    private var m_FacebookList:MovieClip;
    private var m_IntervalID:Number;
    private var m_WaitingTextDotCounter:Number;
    private var m_Tooltip:TooltipInterface;
    
    //Constructor
	public function ServerListItemRenderer()
    {
        super();
        
        m_IsConfigured = false;
        m_IntervalID = undefined;
        m_WaitingTextDotCounter = 0;
    }
    
    //Config UI
	private function configUI():Void
	{
		super.configUI();
        
        m_IsConfigured = true;
        
        UpdateVisuals();
	}
		
    //Set Data
	public function setData(serverData:Object):Void
	{
        super.setData(serverData);
        
        if (m_IsConfigured)
        {
            UpdateVisuals();
        }
    }
    
    //Update Visuals
    private function UpdateVisuals():Void
    {
        if (m_IntervalID != undefined)
        {
            clearInterval(m_IntervalID);
            m_IntervalID = undefined;
        }
            
        if (data == undefined)
		{
			_visible = false;
			return;
		}
        
		_visible = true;
        
        m_ServerName.htmlText = "";
        m_ServerInfo.htmlText = "";
        
        m_ServerName.htmlText = data.m_Name;
        m_ServerInfo.htmlText = data.m_Name + " - " + data.m_Load;
        
        if ( Facebook.IsConnectedToFacebook() )
        {
            if ( m_FacebookInfo == undefined )
            {
                m_FacebookInfo = attachMovie("ServerListFacebookInfo", "m_FacebookInfo", getNextHighestDepth());
                m_FacebookInfo._x = 195;
                m_FacebookInfo._y = 6;
            }
            
            if ( Facebook.IsInterfaceUpdateReceived() )
            {
            
                var friendsArray:Array = Facebook.GetFriendsByDimensionId(data.m_Id);
                
                m_FacebookInfo.SetTotalFriends(friendsArray.length);
                
                _parent._parent._parent._parent.CreateFacebookList(m_ServerName.text);
                
                m_FacebookList = _parent._parent._parent._parent[m_ServerName.text];
                
                m_FacebookList.SetFriendsList(friendsArray);
            }
            else //Still there's no data about friends in dimensions
            {
                Facebook.SignalInterfaceUpdated.Connect(SlotFacebookUpdated, this);
                m_IntervalID = setInterval(this, "SlotWaitingForFacebookUpdate", 500);
                
                
            }
        }
        else
        {
            Facebook.SignalReceivedFriendsList.Connect(SlotFacebookUpdated, this);
            if ( m_FacebookInfo != undefined )
            {
                m_FacebookInfo.removeMovieClip();
                m_FacebookInfo = undefined;
            }
        }
    }
    
    private function SlotWaitingForFacebookUpdate():Void
    {
        var waitingText:String = "";
        
        m_WaitingTextDotCounter = (++m_WaitingTextDotCounter) % (MAX_DOTS+1);
        
        for (var i:Number = 0; i < m_WaitingTextDotCounter; ++i )
        {
            waitingText += ".";
        }
        
        m_FacebookInfo.SetWaitingText(waitingText);
    }
    
    private function SlotFacebookUpdated():Void
    {
        UpdateVisuals();
    }
    
    //On Mouse Move
    private function onMouseMove():Void
    {
        if (m_FacebookInfo && m_FacebookInfo.GetTotalFriends() > 0)
        {            
            if (m_FacebookInfo.hitTest(_root._xmouse, _root._ymouse))
            {                       
                m_FacebookList._visible = true;
                
                m_FacebookList._x = _root._xmouse - m_FacebookList._width + 43;
                m_FacebookList._y = _root._ymouse - 18;
            }
            else
            {
                m_FacebookList._visible = false;
            }
        }
        else if (m_FacebookInfo && m_FacebookInfo.GetTotalFriends() < 0)
        {
            if (m_FacebookInfo.hitTest(_root._xmouse, _root._ymouse))
            {                       
                var tooltipData:TooltipData = new TooltipData();
                var tooltipText:String = LDBFormat.LDBGetText("CharCreationGUI", "FacebookDialog_LoginWithFacebookButtonLabel");
                tooltipData.AddAttribute("", tooltipText );
                tooltipData.m_Padding = 4;
                tooltipData.m_MaxWidth = 100;
                m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
            }
            else
            {
                if (m_Tooltip != undefined)
                {
                    m_Tooltip.Close();
                    m_Tooltip = undefined;
                }
            }
        }
    }
}