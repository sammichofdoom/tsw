import gfx.core.UIComponent
import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.GameInterface.Game.Character;
import com.Components.ListHeader;
import com.Components.WindowComponentContent;
import gfx.controls.Button;
import mx.utils.Delegate;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;

class GUI.Wallet.WalletWindow extends WindowComponentContent
{
    private var m_Tokens:Array;
    private var m_Character:Character;
    
    private var m_MultiColumnList:MultiColumnListView
    
    private var m_Width:Number
    private var m_Height:Number
    
    private var m_ItemWidth:Number = 275;
    private var m_AmountWidth:Number = 65;
    
    private var m_ItemColumn:Number = 0;
    private var m_AmountColumn:Number = 1;

    public var SignalClose:Signal;

    public function WalletWindow()
    {
        SignalClose = new Signal();
        m_Character = Character.GetClientCharacter();
                    
        var tokenId:Number;
        m_Tokens = [];
        
        tokenId = _global.Enums.Token.e_Major_Anima_Fragment;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId });
        tokenId = _global.Enums.Token.e_Minor_Anima_Fragment;
        m_Tokens.push({ name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId });
        tokenId = _global.Enums.Token.e_Solomon_Island_Token;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId });
        tokenId = _global.Enums.Token.e_Egypt_Token;
        m_Tokens.push({ name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId });
        tokenId = _global.Enums.Token.e_Transylvania_Token;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId });
        tokenId = _global.Enums.Token.e_Heroic_Token;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId } );
        tokenId = _global.Enums.Token.e_Apocalypse_Token;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId } );
        tokenId = _global.Enums.Token.e_Coupon_Barbershop;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId });
        tokenId = _global.Enums.Token.e_Coupon_PlasticSurgery;
        m_Tokens.push( { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId } );
        
        m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);        
    }    
    
    public function SetSize(width:Number, height:Number)
    {
        m_Width = width;
        m_Height = height;
    }
    
    private function SlotTokenAmountChanged(tokenID:Number, newAmount:Number, oldAmount:Number)
    {
        for (var i:Number = 0; i < m_Tokens.length; i++)
        {
            if (m_Tokens[i].id == tokenID)
            {
                m_Tokens[i].value = newAmount;
                UpdateToken(m_Tokens[i]);
                return;
            }
        }      
    }
    
    public function configUI()
    {        
        m_MultiColumnList.SignalSizeChanged.Connect(Layout, this)
        m_MultiColumnList.SetItemRenderer("TokenItemRenderer");
        m_MultiColumnList.SetHeaderSpacing(3);
        m_MultiColumnList.SetShowBottomLine(false);
        
        m_MultiColumnList.AddColumn(m_ItemColumn, LDBFormat.LDBGetText("GenericGUI", "Name"), m_ItemWidth, 0);
        m_MultiColumnList.AddColumn(m_AmountColumn,  LDBFormat.LDBGetText("GenericGUI", "Amount"), m_AmountWidth, 0);
        m_MultiColumnList.SetRowCount(m_Tokens.length);
        
        CreateTokens();
        
        Layout();
        
    }
    
    private function CreateTokens()
    {
        var ypos:Number = 0;
        for (var i:Number = 0; i < m_Tokens.length; i++ )
        {
            var tokenObj:Object = m_Tokens[i];
            if (tokenObj.id != _global.Enums.Token.e_Cash)
            {
                UpdateToken(tokenObj);
            }
        }
    }
    
    private function UpdateToken(tokenObj:Object)
    {
        var tokenItem:MCLItemDefault = new MCLItemDefault(tokenObj.id);
        var textAndIconValue:MCLItemValueData = new MCLItemValueData();
        textAndIconValue.m_Text = tokenObj.name;
        textAndIconValue.m_MovieClipName = "T" + tokenObj.id;
        textAndIconValue.m_MovieClipWidth = 35;
        tokenItem.SetValue(m_ItemColumn, textAndIconValue, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
        var amountValue:MCLItemValueData = new MCLItemValueData();
        amountValue.m_Number = tokenObj.value;
        amountValue.m_TextAlignment = "right";
        tokenItem.SetValue(m_AmountColumn,amountValue, MCLItemDefault.LIST_ITEMTYPE_NUMBER);

        m_MultiColumnList.SetItem(tokenItem);
    }

    private function Layout()
    {        
        SignalSizeChanged.Emit();
    }
}
