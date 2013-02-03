//Imports
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.LDBFormat;
import com.Utils.Signal;

//Class
class com.Components.Cash extends MovieClip
{
    //Properties
    public var SignalCashUpdated:Signal;
    
    private var m_Label:TextField;
    private var m_Character:Character;
    
    //Constructor
    public function Cash()
    {
        super();
        
        SignalCashUpdated = new Signal();
        
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
            m_Label.text = newValue.toString();

            SignalCashUpdated.Emit(newValue, oldValue);
        }
    }
}