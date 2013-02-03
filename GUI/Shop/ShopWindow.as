//Imports
import com.Components.WinComp;
import com.GameInterface.ShopInterface;
import com.Utils.LDBFormat;
import com.Utils.Signal;

//Class
class GUI.Shop.ShopWindow extends WinComp
{
    //Constants
    public static var MIN_WIDTH:Number = 478;
    public static var MIN_HEIGHT:Number = 570;
    
    //Properties
    public var SignalCloseShop:Signal;
	
    //Constructor
    public function ShopWindow()
	{
        super();
        
	    SetContent("ShopWindowContent");
        SetPadding(8);
        
        SignalCloseShop = new Signal();
    
        ShowCloseButton(true);
        ShowStroke(false);
        ShowFooter(false);
        ShowResizeButton(true);
        SetMinWidth(MIN_WIDTH);
        SetMinHeight(MIN_HEIGHT);
        SetSize(MIN_WIDTH, MIN_HEIGHT);
	}

    //Set Shop Interface
	public function SetShopInterface(shopInterface:ShopInterface):Void
	{
        shopInterface.SignalCloseShop.Connect(SlotClose, this);
        m_Content.SetShopInterface(shopInterface);
                
        SetTitle(LDBFormat.LDBGetText("MiscGUI", "VendorTitle"), "left");
	}
    
    //Slot Close
    public function SlotClose():Void
    {
        m_Content.Close();
        SignalCloseShop.Emit(this);
    }
}