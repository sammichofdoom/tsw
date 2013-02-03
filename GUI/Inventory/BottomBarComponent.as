//Imports
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import gfx.controls.Button;
import gfx.core.UIComponent;

//Class
class GUI.Inventory.BottomBarComponent extends UIComponent
{
    //Constants
    private static var PADDING:Number = 10;
    
    //Properties
    private var m_Cash:MovieClip;
    private var m_TokenButton:Button;
    private var m_Background:MovieClip;
    private var m_WalletVisible:DistributedValue;
    
    //Constructor
    public function BottomBarComponent()
    {
        super();
        m_WalletVisible = DistributedValue.Create( "wallet_window" );
    }
    
    //Config UI
    private function configUI():Void
    {
        m_TokenButton.textField.text = LDBFormat.LDBGetText("Tokens", "Tokens");
        m_TokenButton.addEventListener("click", this, "TokenButtonHandler");
        m_TokenButton.disableFocus = true;
    }
    
    //Set Width
    public function SetWidth(value:Number):Void
    {
        m_Background._width = value;
        m_Cash._x = PADDING;
        m_TokenButton._x = m_Background._x + m_Background._width - m_TokenButton._width - PADDING;
    }
    
    //Set Height
    public function SetHeight(value:Number):Void
    {
        m_Background._height = value;
        m_Cash._y = m_Background._y + m_Background._height / 2 - m_Cash._height / 2 - 3;
        m_TokenButton._y = m_Background._y + m_Background._height / 2 - m_TokenButton._height / 2 + 1;
    }
    
    //Token Button Handler
    private function TokenButtonHandler(event:Object):Void
    {
        var isOpen:Boolean = m_WalletVisible.GetValue();
        m_WalletVisible.SetValue(!isOpen);
        
        Selection.setFocus(null);
    }
}