//Imports
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.LDBFormat;

//Class
class GUI.TradePost.Views.Cash extends MovieClip
{
    //Properties
    private var m_Label:TextField;
    private var m_Character:Character;
    
    //Constructor
    public function Cash()
    {
        super();
        
        m_Label.autoSize = "left";
        
        Init();
    }
    
    //Initialize
    private function Init():Void
    {
        m_Character = Character.GetClientCharacter();
    
        if (m_Character != undefined)
        {
            m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
            var cash:Number = m_Character.GetTokens(_global.Enums.Token.e_Cash);
            m_Label.text = cash.toString();
        }
    }
    
    //Slot Token Amount Changed
    function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number):Void
    {
        if (id == _global.Enums.Token.e_Cash)
        {
            m_Label.text = newValue.toString(); //com.Utils.Format.Printf("%.2f", newValue / 100);
        }
    }
}