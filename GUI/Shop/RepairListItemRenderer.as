import com.GameInterface.InventoryItem;
import com.GameInterface.Inventory;
import com.Components.ItemComponent;
import gfx.controls.ListItemRenderer;
import gfx.utils.Constraints;
import com.GameInterface.Tooltip.*;
import mx.utils.Delegate;
import GUI.Shop.ShopWindowContent;
import com.Utils.Colors;
import com.Utils.ID32;
import com.GameInterface.Game.Character;

class GUI.Shop.RepairListItemRenderer extends ListItemRenderer
{
	private var m_InventoryID:ID32;
	private var m_RepairItem:InventoryItem;
	
	private var m_Icon:MovieClip;
	private var m_Name:MovieClip;
	private var m_Price:MovieClip;
    private var m_PriceWidth:Number;
    private var m_Background:MovieClip;
	
	private var m_Tooltip:TooltipInterface
	
	private function RepairListItemRenderer()
	{
		super();
        m_PriceWidth = 0;
	}
	
	private function configUI()
	{
        constraints = new Constraints(this, true);
		if (!_disableConstraints) {
			constraints.addElement(textField, Constraints.ALL);
		}
		
		// Force dimension check if autoSize is set to true
		if (_autoSize != "none") {
			sizeIsInvalid = true;
		}
        
		m_Background.onRollOver = Delegate.create(this, handleMouseRollOver);
		m_Background.onRollOut = Delegate.create(this, handleMouseRollOut);
		m_Background.onPress = Delegate.create(this, handleMousePress);
		m_Background.onRelease = Delegate.create(this, handleMouseRelease);
		m_Background.onReleaseOutside = Delegate.create(this, handleReleaseOutside);
		m_Background.onDragOver = Delegate.create(this, handleDragOver);
		m_Background.onDragOut = Delegate.create(this, handleDragOut);
        
		m_Icon.onPress = function() { };
        m_Icon.onRollOver = Delegate.create(this, SlotIconRollOver);
        m_Icon.onRollOut = m_Icon.onDragOut = Delegate.create(this, SlotIconRollOut);

		
		if (focusIndicator != null && !_focused && focusIndicator._totalFrames == 1) { focusIndicator._visible = false; }
		
		updateAfterStateChange();
        
        focusTarget = owner; // The component sets the focusTarget to its owner instead of vice-versa.  This allows sub-classes to override this behaviour.

		addEventListener( "select", this, "SlotSelected");
	}
		
	public function setData(repairItem:Object)
	{
		if (repairItem == undefined)
		{
			CloseTooltip();
			_visible = false;
			return;
		}
		_visible = true;
		
		if (m_Icon.item != undefined)
		{
			m_Icon.item.removeMovieClip();
		}
		m_RepairItem = repairItem.m_Item;
        m_InventoryID = repairItem.m_InventoryID;
		CreateIcon();
        
        var textColor:Number = 0xFFFFFF;
        switch(m_RepairItem.m_Rarity)
        {
            case _global.Enums.ItemPowerLevel.e_Superior:
                textColor = Colors.e_ColorBorderItemSuperior;
				break;
            case _global.Enums.ItemPowerLevel.e_Enchanted:
                textColor = Colors.e_ColorBorderItemEnchanted;
				break;
            case _global.Enums.ItemPowerLevel.e_Rare:
                textColor = Colors.e_ColorBorderItemRare;
				break;
			case _global.Enums.ItemPowerLevel.e_Epic:
                textColor = Colors.e_ColorBorderItemEpic;
				break;
			case _global.Enums.ItemPowerLevel.e_Legendary:
                textColor = Colors.e_ColorBorderItemLegendary;
				break;
        }
		m_Name.text = m_RepairItem.m_Name;
        m_Name.textColor = textColor;
        m_Name._x = ShopWindowContent.ITEM_WIDTH + 5;
        m_Name._width = ShopWindowContent.NAME_WIDTH - 30;
        m_PriceWidth = ShopWindowContent.ITEM_WIDTH + ShopWindowContent.NAME_WIDTH;
		SetPrice();
	}
    
    	
    private function SetPrice()
    {
        ClearPrice();
        
        var isToken:Boolean = false;
        
        isToken = AddToken(_global.Enums.Token.e_Cash, m_RepairItem.m_RepairPrice);
        
        if (!isToken)
        {
            m_Price.autoSize = "left";
            m_Price.text = "";
            m_Price.text = "" + m_RepairItem.m_RepairPrice;
            m_Price._x = m_PriceWidth;
        }
    }
    
    private function AddToken(tokenId:Number, price:Number) :Boolean
    {
        if (price > 0 && (  tokenId == _global.Enums.Token.e_Major_Anima_Fragment || 
                            tokenId == _global.Enums.Token.e_Minor_Anima_Fragment ||
                            tokenId == _global.Enums.Token.e_Solomon_Island_Token ||
                            tokenId == _global.Enums.Token.e_Egypt_Token ||
                            tokenId == _global.Enums.Token.e_Transylvania_Token ||
                            tokenId == _global.Enums.Token.e_Heroic_Token ||
                            tokenId == _global.Enums.Token.e_Cash ))
        {
            if (this["m_TokenPrice"] == undefined)
            {
                var tokenPrice:MovieClip = createEmptyMovieClip("m_TokenPrice", getNextHighestDepth());
                tokenPrice._y = 5;
            }
            
            var formattedPrice:String = price.toString();
            if (tokenId == _global.Enums.Token.e_Cash)
            {
               formattedPrice = price.toString(); 
            }
            
            var priceClip:MovieClip = this["m_TokenPrice"].attachMovie("T"+tokenId, "T"+tokenId, this["m_TokenPrice"].getNextHighestDepth());
            priceClip.textField.autoSize = "left";
            priceClip.textField.text = formattedPrice;
            priceClip._x = m_PriceWidth;
            m_PriceWidth += priceClip._width + 5;

            var character:Character = Character.GetClientCharacter();
            var canAfford:Boolean = character.GetTokens(_global.Enums.Token.e_Cash) >= price;
            if (!canAfford)
            {
                priceClip.textField.textColor = 0xFF0000;
            }
            
            return true;
        }
        return false;
    }
    
    private function ClearPrice()
    {
        m_Price.text = "";
        if (this["m_TokenPrice"] != undefined)
        {
            this["m_TokenPrice"].removeMovieClip();
            //this["m_TokenPrice"] = undefined;
        }
    }
	
	public function CreateIcon()
    {
        var icon:ItemComponent = ItemComponent(m_Icon.attachMovie( "Item", "item", m_Icon.getNextHighestDepth() ));
        
        icon.SetData( m_RepairItem );
        icon.SetStackSize(m_RepairItem.m_StackSize);
        icon.SetStackSizeScale(150);
        
        icon._xscale = 60;
		icon._yscale = 60;
    }
	
	
    public function OpenTooltip() : Void
    {
        if (m_Tooltip == undefined)
        {
            var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip(m_InventoryID, m_RepairItem.m_InventoryPos);
            
            var equippedItems:Array = [];
            for ( var i:Number = 0 ; i < tooltipData.m_CurrentlyEquippedItems.length ; ++i )
            {
				var equippedData:TooltipData =  TooltipDataProvider.GetInventoryItemTooltip( new com.Utils.ID32( _global.Enums.InvType.e_Type_GC_WeaponContainer, 0 ), 
												tooltipData.m_CurrentlyEquippedItems[i] );
				equippedData.m_IsEquipped = true;
                equippedItems.push( equippedData);
            }
            m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_Icon, TooltipInterface.e_OrientationHorizontal, -1, tooltipData, equippedItems );
        }
    }
    
    public function CloseTooltip() : Void
    {
        if ( m_Tooltip != undefined && !m_Tooltip.IsFloating() )
        {
            m_Tooltip.Close();
        }
        m_Tooltip = undefined;
    }

    
    private function SlotIconRollOver()
    {
        if (m_Tooltip == undefined)
        {
            OpenTooltip();
        }
    }
    
    private function SlotIconRollOut()
    {
        if (m_Tooltip != undefined)
        {
            CloseTooltip();
        }
    }
	
	function SlotSelected()
	{
		if ( this.selected == true )
		{
			gotoAndStop("selected");
		}
		else
		{
			gotoAndStop("default");			
		}
		
		Selection.setFocus(null);
	}
}