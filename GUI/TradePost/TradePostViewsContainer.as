//Imports
import com.GameInterface.Tradepost;
import com.Utils.Signal;

//Class
class GUI.TradePost.TradePostViewsContainer extends MovieClip
{
    //Constants
    public static var STORE_AND_SELL_VIEW:String = "StoreAndSellView";
    public static var BUY_VIEW:String = "BuyView";
    public static var POSTAL_SERVICE_VIEW:String = "PostalServiceView";
    public static var GUILD_BANK_VIEW:String = "GuildBankView";
    
    //Properties
    public var SignalViewChanged:Signal;
    
    private var m_StoreAndSellView:MovieClip;
    private var m_BuyViewView:MovieClip;
    private var m_PostalServiceView:MovieClip;
    private var m_GuildBankView:MovieClip;
    private var m_ViewsArray:Array;
    private var m_View:String;
    
    //Constructor
    public function TradePostViewsContainer()
    {
        super();
        
        Init();
        
        SignalViewChanged = new Signal();
    }
    
    //Initialize
    private function Init():Void
    {
        Tradepost.UpdateMail(); 

        m_StoreAndSellView = attachMovie(STORE_AND_SELL_VIEW, "m_" + STORE_AND_SELL_VIEW, getNextHighestDepth());
        m_BuyViewView = attachMovie(BUY_VIEW, "m_" + BUY_VIEW, getNextHighestDepth());
        m_PostalServiceView = attachMovie(POSTAL_SERVICE_VIEW, "m_" + POSTAL_SERVICE_VIEW, getNextHighestDepth());
        m_GuildBankView = attachMovie(GUILD_BANK_VIEW, "m_" + GUILD_BANK_VIEW, getNextHighestDepth())
        
        m_ViewsArray = new Array();
        m_ViewsArray.push({name: STORE_AND_SELL_VIEW, view: m_StoreAndSellView});
        m_ViewsArray.push({name: BUY_VIEW, view: m_BuyViewView});
        m_ViewsArray.push({name: POSTAL_SERVICE_VIEW, view: m_PostalServiceView});
        m_ViewsArray.push( { name: GUILD_BANK_VIEW, view: m_GuildBankView } );
        
        for (var i:Number = 0; i < m_ViewsArray.length; i++)
        {
            m_ViewsArray[i].view._visible = false;
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
                
                SignalViewChanged.Emit();
            }
            else
            {
                m_ViewsArray[i].view._visible = false;
            }
        }
    }
    
    public function RemoveView(view:String):Void
    {
        m_GuildBankView._visible = false;
        m_GuildBankView.removeMovieClip();
        m_GuildBankView = undefined;
    }
    
    //Get View
    public function get view():String
    {
        return m_View;
    }
}