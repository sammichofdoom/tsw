//Imports
import com.Components.InventoryItemList.MCLItemInventoryItem;
import com.Components.ListHeader;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.WindowComponentContent;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.ShopInterface;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import flash.geom.Point;
import gfx.controls.Button;
import gfx.controls.ButtonBar;
import gfx.controls.ScrollBar;
import gfx.controls.ScrollingList;
import gfx.core.UIComponent
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;

//Class
class GUI.Shop.ShopWindowContent extends WindowComponentContent
{
    //Constants
    public static var ITEM_WIDTH:Number = 55;
    public static var NAME_WIDTH:Number = 220;
    public static var RANK_WIDTH:Number = 50;
    public static var PRICE_WIDTH:Number = 143;
    
    public static var BUY:Number = 0;
    public static var SELL:Number = 1;
    public static var REPAIR:Number = 2;
    
    private static var TOKEN_MAX_SIZE:Number = 100;
    
    //Properties
    public var SignalContentInitialized:Signal;
    
    private var m_BuyList:MultiColumnListView;
    private var m_RepairList:MultiColumnListView;
    private var m_SellList:MultiColumnListView;
    private var m_ButtonTabDivider:MovieClip;
    private var m_SellRepairInfo:TextField;
    private var m_ScrollBarBuy:ScrollBar;
    private var m_ScrollBarSell:ScrollBar;
    private var m_ScrollBarRepair:ScrollBar;
    
    private var m_CurrentFocus:Number;
    
    private var m_FilterPanel:MovieClip;
    private var m_InfoPanel:MovieClip;
    private var m_TokenPanel:MovieClip;
    private var m_ButtonBar:MovieClip;
    private var m_TabButtonArray:Array;
    private var m_Tokens:Object;
    
    private var m_ShopInterface:ShopInterface;
    private var m_Inventory:Inventory;
    private var m_StaticInventory:Inventory;
    private var m_EquipInventory:Inventory;
    private var m_BuyBackInventory:Inventory;
    
    private var m_IsTokensOpen:Boolean;
    private var m_SelectedIndex:Number;
    private var m_SelectedRepairIndex:Number;
    private var m_SelectedSellIndex:Number;
    private var m_SelectedBuyBackIndex:Number;
    private var m_CanUndo:Boolean;
    
    private var m_SearchOnlyUseable:Boolean;
    private var m_SearchOnlyPurchaseable:Boolean;
    
    private var m_TDB_Buy:String;
    private var m_TDB_Sell:String;
    private var m_TDB_BuyBack:String;
    private var m_TDB_Repair:String;
    
    private var m_Width:Number;
    private var m_Height:Number;
    
    private var m_TokenTextFormat:TextFormat;
    private var m_Character:Character;
    private var m_IsInitialized:Boolean;
        
    //Constructor
    public function ShopWindowContent()
    {
        super();
        
        SignalContentInitialized = new Signal();
        
        m_IsInitialized = false;
        
        m_TokenTextFormat = new TextFormat();
        m_TokenTextFormat.font = "_StandardFont";
        m_TokenTextFormat.size = 15;
        m_TokenTextFormat.color = 0xFFFFFF;
        
        m_IsTokensOpen = false;
        
        m_SelectedIndex = -1;
        m_SelectedRepairIndex = -1;
        m_SelectedSellIndex = -1;
        m_SelectedBuyBackIndex = -1;
        
        m_SearchOnlyUseable = false;
        m_SearchOnlyPurchaseable = false;
        
        var clientCharacterInstanceID:Number = CharacterBase.GetClientCharID().GetInstance();
        
        m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, clientCharacterInstanceID));
        m_StaticInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, clientCharacterInstanceID));
        m_EquipInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, clientCharacterInstanceID));
        m_BuyBackInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BuybackInventory, clientCharacterInstanceID));
        
        m_TDB_Buy = LDBFormat.LDBGetText("TradeGUI", "ShopGUI_Buy");
        m_TDB_Sell = LDBFormat.LDBGetText("TradeGUI", "ShopGUI_Sell");
        m_TDB_BuyBack = LDBFormat.LDBGetText("TradeGUI", "ShopGUI_Undo");
        m_TDB_Repair = LDBFormat.LDBGetText("TradeGUI", "ShopGUI_Repair");
        
        m_TabButtonArray = [];
        m_TabButtonArray[BUY] = {label: m_TDB_Buy, view: m_BuyList, scrollbar: m_ScrollBarBuy};
        m_TabButtonArray[SELL] = {label: m_TDB_Sell, view: m_SellList, scrollbar: m_ScrollBarSell};
        m_TabButtonArray[REPAIR] = {label: m_TDB_Repair, view: m_RepairList, scrollbar: m_ScrollBarRepair};
        
        m_Character = Character.GetClientCharacter();
        
        var tokenId:Number;
        
        m_Tokens = {};
        
        tokenId = _global.Enums.Token.e_Cash;
        m_Tokens["" + tokenId] = {name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId};
        
        tokenId = _global.Enums.Token.e_Major_Anima_Fragment;
        m_Tokens["" + tokenId] = {name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId};
        
        tokenId = _global.Enums.Token.e_Minor_Anima_Fragment;
        m_Tokens["" + tokenId] = {name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId};
        
        tokenId = _global.Enums.Token.e_Solomon_Island_Token;
        m_Tokens["" + tokenId] = {name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId};
        
        tokenId = _global.Enums.Token.e_Egypt_Token;
        m_Tokens["" + tokenId] = {name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId};
        
        tokenId = _global.Enums.Token.e_Transylvania_Token;
        m_Tokens["" + tokenId] = { name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId };
        
        tokenId = _global.Enums.Token.e_Apocalypse_Token;
        m_Tokens["" + tokenId] = {name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId};
        
        tokenId = _global.Enums.Token.e_Heroic_Token;
        m_Tokens["" + tokenId] = {name: LDBFormat.LDBGetText("Tokens", "Token" + tokenId), value:m_Character.GetTokens(tokenId), id:tokenId};
        
        m_StaticInventory.SignalItemAdded.Connect(SlotUpdateShopItems, this);
        m_StaticInventory.SignalItemRemoved.Connect(SlotUpdateShopItems, this);
        
        m_Inventory.SignalItemAdded.Connect(UpdateLists, this);
        m_Inventory.SignalItemRemoved.Connect(UpdateLists, this);
        m_Inventory.SignalItemMoved.Connect(UpdateLists, this);
        m_Inventory.SignalItemChanged.Connect(UpdateLists, this);
        m_Inventory.SignalItemStatChanged.Connect(SlotItemStatChanged, this);
        
        m_EquipInventory.SignalItemAdded.Connect(UpdateLists, this);
        m_EquipInventory.SignalItemRemoved.Connect(UpdateLists, this);
        m_EquipInventory.SignalItemMoved.Connect(UpdateLists, this);
        m_EquipInventory.SignalItemChanged.Connect(UpdateLists, this);
        m_EquipInventory.SignalItemStatChanged.Connect(SlotItemStatChanged, this);
        
        m_BuyBackInventory.SignalItemAdded.Connect(UpdateLists, this);
        m_BuyBackInventory.SignalItemRemoved.Connect(UpdateLists, this);
        
        gfx.managers.DragManager.instance.addEventListener("dragEnd", this, "SlotDragEnd");
    }
    
    //Slot Update Shop Items
    public function SlotUpdateShopItems():Void
    {
        m_ShopInterface.UpdateShopItems();
        UpdateBuyItems();
    }
    
    //SLot Item Stat Changed
    private function SlotItemStatChanged(inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number):Void
    {
        if (stat == _global.Enums.Stat.e_StackSize || stat == _global.Enums.Stat.e_Durability)
        {
            UpdateLists();
        }
    }
    
    //Layout Token Panel
    private function LayoutTokenPanel():Void
    {
        var tokenPadding:Number = 3;
        
        if (m_TokenPanel != undefined)
        {
            m_TokenPanel.removeMovieClip();
        }
        
        m_TokenPanel = createEmptyMovieClip("m_TokenBackground", getNextHighestDepth());
        
        var tokensPerLine:Number = Math.floor(m_Width/(TOKEN_MAX_SIZE + tokenPadding));
        var tokenWidth:Number = (m_Width - (tokensPerLine * tokenPadding)) / tokensPerLine;
        var tokenHeight:Number = 28;
        
        var tokenCount:Number = 0;
        
        for (var prop in m_Tokens)
        {
            var value:Number = m_Character.GetTokens(prop);
            
            if (prop != _global.Enums.Token.e_Cash && value > 0)
            {
                var token:MovieClip = m_TokenPanel.attachMovie("Token", "t" + prop, m_TokenPanel.getNextHighestDepth());
                token._x = (tokenWidth + tokenPadding) * (tokenCount % tokensPerLine);
                token._y = (tokenHeight + tokenPadding) * (Math.floor(tokenCount / tokensPerLine))
               
                token.m_Background._width = tokenWidth;
                
                var tokenIcon:MovieClip = token.attachMovie("T" + prop, "icon", token.getNextHighestDepth(), { _x:5, _y:3, _xscale:85, _yscale:85 } );
                
                var tokenTextField:TextField = token.createTextField("textField", token.getNextHighestDepth(), tokenIcon._x + tokenIcon._width + 8, 3, 0, 0);
                tokenTextField.setNewTextFormat(m_TokenTextFormat);
                tokenTextField.autoSize = "left";
                tokenTextField.text = value.toString();
                tokenCount++;
            }
        }
        
        m_TokenPanel._y = m_Height - m_TokenPanel._height;
    }
    
    //Config UI
    private function configUI():Void
    {
        CreateList(m_BuyList, m_ScrollBarBuy, SlotBuyItemSelected);
        CreateList(m_SellList, m_ScrollBarSell, SlotSellItemSelected);
        CreateList(m_RepairList, m_ScrollBarRepair, SlotRepairItemSelected);
                
        m_FilterPanel.m_CheckPurchaseable.addEventListener("select", this, "SlotPurchasableSelected");
        m_FilterPanel.m_CheckUsable.addEventListener("select", this, "SlotUseableSelected");

        m_FilterPanel.m_CheckPurchaseable.label = LDBFormat.LDBGetText("TradeGUI", "ShopGUI_PurcheseableItem");
        m_FilterPanel.m_CheckUsable.label = LDBFormat.LDBGetText("TradeGUI", "ShopGUI_UsableItem");
        
        m_FilterPanel.m_CheckPurchaseable.disableFocus = true;
        m_FilterPanel.m_CheckUsable.disableFocus = true;
        
        m_FilterPanel.m_CheckPurchaseable.autoSize = "left";
        m_FilterPanel.m_CheckUsable.autoSize = "left";
        
        m_SellRepairInfo.autoSize = "left";
        
        InitTabs();
               
        UpdateLists();
        
        Selection.addListener(this);
        
        m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
        
        SignalContentInitialized.Emit();

        Layout();
        
        m_InfoPanel.m_ActionButton_1.disableFocus = true;
        m_InfoPanel.m_ActionButton_2.disableFocus = true;
        
        _global.setTimeout(Delegate.create(this, InitializedLayoutComplete), 100);
    }
    
    //Initialized Layout Complete
    private function InitializedLayoutComplete():Void
    {
        m_IsInitialized = true;
        
        Layout();
    }
    
    //Create List
    private function CreateList(list:MultiColumnListView, scrollBar:ScrollBar, selectionCallback:Function):Void
    {
        list.SetItemRenderer("InventoryItemRenderer");
        list.SetHeaderSpacing(3);
        list.SetShowBottomLine(true);
        list.SetScrollBar(scrollBar);
        list.SignalItemClicked.Connect(selectionCallback, this);
        
        var priceColumnConstant:Number;
        
        switch (list)
        {
            case m_BuyList:         priceColumnConstant = MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_BUY_PRICE;
                                    break;
                                
            case m_SellList:        priceColumnConstant = MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_SELL_PRICE;
                                    break;
                                
            case m_RepairList:      priceColumnConstant = MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_REPAIR_PRICE;
        }
        
        list.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ICON, LDBFormat.LDBGetText("TradeGUI", "ShopGUI_Item"), ITEM_WIDTH, ColumnData.COLUMN_NOT_SORTABLE);
        list.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_NAME, LDBFormat.LDBGetText("TradeGUI", "ShopGUI_Name"), NAME_WIDTH, 0);
        list.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_RANK, LDBFormat.LDBGetText("TradeGUI", "ShopGUI_Rank"), RANK_WIDTH, 0);
        list.AddColumn(priceColumnConstant,                             LDBFormat.LDBGetText("TradeGUI", "ShopGUI_Price"), PRICE_WIDTH, 0);
    }
    
    //Reset List
    private function ResetList(type:Number):Void
    {
        var itemArray:Array = new Array();
        
        if (type == BUY)
        {
            m_BuyList.RemoveAllItems();
            
            for (var i:Number = 0; i < m_ShopInterface.m_Items.length; i++)
            {
                if (m_ShopInterface.m_Items[i] != undefined)
                {
                    var purchaseable = !m_SearchOnlyPurchaseable || CanPurchaseItem(m_ShopInterface.m_Items[i]);
                    var useable =  !m_SearchOnlyUseable || m_ShopInterface.m_Items[i].m_CanUse;
                    
                    if (purchaseable && useable)
                    {
                        itemArray.push(new MCLItemInventoryItem(m_ShopInterface.m_Items[i], undefined));
                    }
                }
            }
            
            m_BuyList.AddItems(itemArray);
            m_BuyList.Resort();
        }      
        else if (type == SELL)
        {
            m_SellList.RemoveAllItems();
            
            for (var i:Number = 0; i < m_Inventory.GetMaxItems(); i++)
            {
                if (m_Inventory.GetItemAt(i) != undefined)
                {
                    if (CanSellItem(m_Inventory.GetItemAt(i)))
                    {
                        var inventoryID:ID32 = m_Inventory.m_InventoryID;
                        itemArray.push(new MCLItemInventoryItem(m_Inventory.GetItemAt(i), inventoryID));
                    }
                }
            }
            
            m_SellList.AddItems(itemArray);
            m_SellList.Resort();
        }
        else if (type == REPAIR)
        {
            m_RepairList.RemoveAllItems();
            
            for (var i:Number = 0; i < m_Inventory.GetMaxItems(); i++)
            {
                if (m_Inventory.GetItemAt(i) != undefined && m_Inventory.GetItemAt(i).m_Durability != undefined && m_Inventory.GetItemAt(i).m_Durability > 0)
                {
                    var inventoryID:ID32 = m_Inventory.m_InventoryID;
                    itemArray.push(new MCLItemInventoryItem(m_Inventory.GetItemAt(i), inventoryID));
                }
            }
            
            for (var i:Number = 0; i < m_EquipInventory.GetMaxItems(); i++)
            {
                if (m_EquipInventory.GetItemAt(i) != undefined && m_EquipInventory.GetItemAt(i).m_Durability != undefined && m_EquipInventory.GetItemAt(i).m_Durability > 0)
                {
                    var inventoryID:ID32 = m_EquipInventory.m_InventoryID;
                    itemArray.push(new MCLItemInventoryItem(m_EquipInventory.GetItemAt(i), inventoryID));
                }
            }
            
            m_RepairList.AddItems(itemArray);
            m_RepairList.Resort();
        }
    }
    
    //Can Purchase Item
    private function CanPurchaseItem(inventoryItem:InventoryItem):Boolean
    {
        return  ((inventoryItem.m_CanBuy == undefined || inventoryItem.m_CanBuy) && 
                (inventoryItem.m_TokenCurrencyType1 == undefined || inventoryItem.m_TokenCurrencyType1 == 0 || m_Character.GetTokens(inventoryItem.m_TokenCurrencyType1) >= inventoryItem.m_TokenCurrencyPrice1) && 
                (inventoryItem.m_TokenCurrencyType2 == undefined || inventoryItem.m_TokenCurrencyType2 == 0 || m_Character.GetTokens(inventoryItem.m_TokenCurrencyType2) >= inventoryItem.m_TokenCurrencyPrice2));
    }
    
    //Can Sell Item
    private function CanSellItem(inventoryItem:InventoryItem):Boolean
    {
        return  ((inventoryItem.m_TokenCurrencySellType1 != undefined && inventoryItem.m_TokenCurrencySellType1 > 0 && inventoryItem.m_TokenCurrencySellPrice1 != undefined && inventoryItem.m_TokenCurrencySellPrice1 > 0) ||
                (inventoryItem.m_TokenCurrencySellType2 != undefined && inventoryItem.m_TokenCurrencySellType2 > 0 && inventoryItem.m_TokenCurrencySellPrice2 != undefined && inventoryItem.m_TokenCurrencySellPrice2 > 0));
    }

    //Init Tabs
    private function InitTabs():Void
    {
        m_ButtonBar._xscale = m_ButtonBar._yscale = 110;
        m_ButtonBar.tabChildren = false;
        m_ButtonBar.itemRenderer = "TabButton";
        m_ButtonBar.direction = "horizontal";
        m_ButtonBar.spacing = -5;
        m_ButtonBar.autoSize = true;
        m_ButtonBar.dataProvider = m_TabButtonArray;
        m_ButtonBar.addEventListener("change", this, "SlotChangeTabIndex");
        m_ButtonBar.addEventListener("focusIn", this, "SlotButtonBarFocus");
        m_ButtonBar.disableFocus = true;
    }
    
    //Slot Button Bar FOcus
    private function SlotButtonBarFocus():Void
    {
        Selection.setFocus(null);
    }
    
    //Slot Change Tab Index
    public function SlotChangeTabIndex(event:Object):Void
    {
        m_CurrentFocus  = event.index;
        m_ButtonBar.selectedIndex = m_CurrentFocus;
        
        for (var i:Number = 0; i < m_TabButtonArray.length; i++)
        {
            var view:MovieClip = m_TabButtonArray[i].view;
            
            if (i == m_CurrentFocus)
            {
                view._visible = true;
                view.disableFocus = true;
                m_TabButtonArray[i].scrollbar._visible = true;
            }
            else
            {
                view._visible = false;
                m_TabButtonArray[i].scrollbar._visible = false;
            }
        }
        
        switch (m_CurrentFocus)
        {
            case BUY:
            case SELL:      m_SellRepairInfo.text = LDBFormat.LDBGetText("TradeGUI", "SellItemInstructions");
                            break;
            
            case REPAIR:    m_SellRepairInfo.text = LDBFormat.LDBGetText("TradeGUI", "RepairItemInstructions");
        }
        
        UpdateInfoPanel();
    }
    
    //Update Lists
    private function UpdateLists():Void
    {
        if (m_ShopInterface != undefined)
        {
            UpdateBuyItems();
        }
        
        UpdateSellItems();
        UpdateRepairItems();
    }
    
    //Slot Token Amount Changed
    private function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number):Void
    {
        UpdateLists();
        LayoutTokenPanel();
    }
    
    //Update Buy Items
    public function UpdateBuyItems():Void
    {
        ResetList(BUY);
    }
    
    //Update Sell Items
    private function UpdateSellItems():Void
    {
        ResetList(SELL);
        UpdateInfoPanel();
    }
    
    //Update Repair Items
    private function UpdateRepairItems():Void
    {
        ResetList(REPAIR);
    }
    
    //Close
    public function Close():Void
    {
        m_ShopInterface.CloseShop();
    }
    
    //Slot Repair Item Selected
    public function SlotRepairItemSelected(index:Number, buttonIndex:Number):Void
    {
        if (buttonIndex == 1)
        {    
            m_SelectedRepairIndex = index;
            
            if (m_InfoPanel.m_ActionButton_1.disabled)
            {
                m_InfoPanel.m_ActionButton_1.disabled = false;
            }
        }
    }
    
    //Slot Buy Item Selected
    public function SlotBuyItemSelected(index:Number, buttonIndex:Number):Void
    {
        if (buttonIndex == 1)
        {
            m_SelectedIndex = index;
            
            var inventoryItem:InventoryItem = m_BuyList.GetItems()[m_SelectedIndex].m_InventoryItem
            var canBuy:Boolean = (inventoryItem.m_CanBuy == undefined || inventoryItem.m_CanBuy)
                
            m_InfoPanel.m_ActionButton_2.disabled = !canBuy || !m_ShopInterface.CanPreview(inventoryItem.m_InventoryPos);
            m_InfoPanel.m_ActionButton_1.disabled = !canBuy;
        }
    }
    
    //Slot Sell Item Selected
    public function SlotSellItemSelected(index:Number, buttonIndex:Number):Void
    {
        if (buttonIndex == 1)
        {
            m_SelectedSellIndex = index;
            
            if (m_InfoPanel.m_ActionButton_1.disabled)
            {
                m_InfoPanel.m_ActionButton_1.disabled = false;
            }
        }
    }
    
    //Slot Buy
    public function SlotBuy():Void
    {
        if (m_SelectedIndex >= 0)
        {
            m_ShopInterface.BuyItem(m_BuyList.GetItems()[m_SelectedIndex].m_InventoryItem.m_InventoryPos);
        }
    }
    
    //Slot Preview
    public function SlotPreview():Void
    {
        if (m_SelectedIndex >= 0)
        {
            m_ShopInterface.PreviewItem(m_BuyList.GetItems()[m_SelectedIndex].m_InventoryItem.m_InventoryPos);
        }
    }
    
    //Slot Repair
    public function SlotRepair():Void
    {
        m_ShopInterface.RepairItem(m_RepairList.GetItems()[m_SelectedRepairIndex].m_InventoryId, m_RepairList.GetItems()[m_SelectedRepairIndex].m_InventoryItem.m_InventoryPos);
        UpdateRepairItems();
    }
    
    //Slot Sell
    private function SlotSell():Void
    {
        m_ShopInterface.SellItem(m_Inventory.m_InventoryID, m_SellList.GetItems()[m_SelectedSellIndex].m_InventoryItem.m_InventoryPos);
    }
    
    //Slot Buy Back
    private function SlotBuyBack():Void
    {
        m_ShopInterface.UndoSell();
    }
    
    //Slot Repair All
    public function SlotRepairAll():Void
    {
        m_ShopInterface.RepairAllItems();
    }    
    
    //Slot Purchasable Selected
    private function SlotPurchasableSelected(event:Object):Void
    {
        m_SearchOnlyPurchaseable = event.selected;
        UpdateBuyItems();
    }
    
    //Slot Useable Selected
    private function SlotUseableSelected(event:Object):Void
    {
        m_SearchOnlyUseable = event.selected;
        UpdateBuyItems();
        UpdateSellItems();
    }
    
    //Layout
    private function Layout():Void
    {
        LayoutTokenPanel();
        LayoutInfoPanel();
        LayoutFilterPanel();
        
        m_SellRepairInfo._y = m_FilterPanel._y - m_SellRepairInfo._height - 5;
        
        SignalSizeChanged.Emit();
        
        m_InfoPanel.m_Background._width = m_Width + _parent.m_Padding * 2 + 2;
        m_InfoPanel._x = -_parent.m_Padding;

        if (m_IsInitialized)
        {
            m_BuyList.SetSize(m_Width - _parent.m_Padding * 2, (m_SellRepairInfo._y - 5 - m_BuyList._y));
            m_SellList.SetSize(m_Width - _parent.m_Padding * 2, (m_SellRepairInfo._y - 5 - m_BuyList._y));
            m_RepairList.SetSize(m_Width - _parent.m_Padding * 2, (m_SellRepairInfo._y - 5 - m_BuyList._y));

            m_ScrollBarBuy._x = m_BuyList._x + m_BuyList._width - 10;
            m_ScrollBarSell._x = m_SellList._x + m_SellList._width - 10;
            m_ScrollBarRepair._x = m_RepairList._x + m_RepairList._width - 10;
            
            m_ScrollBarBuy._y = m_BuyList._y - 5;
            m_ScrollBarSell._y = m_SellList._y - 5;
            m_ScrollBarRepair._y = m_RepairList._y - 5;
            
            m_ButtonTabDivider._width = m_BuyList._width;
        }
    }
    
    //Layout Info Panel
    private function LayoutInfoPanel():Void
    {
        m_InfoPanel.m_Background._width = m_Width + _parent.m_Padding * 2;
        m_InfoPanel._x = 0;
        m_InfoPanel._y = m_TokenPanel._y - m_InfoPanel._height - 5;
        m_InfoPanel.m_ActionButton_1._x = m_InfoPanel.m_Background._width - m_InfoPanel.m_ActionButton_1._width - 10;
        m_InfoPanel.m_ActionButton_2._x = m_InfoPanel.m_ActionButton_1._x - m_InfoPanel.m_ActionButton_2._width - 8;
    }
    
    //Layout Filter Panel
    private function LayoutFilterPanel():Void
    {
        m_FilterPanel._y = m_InfoPanel._y - m_FilterPanel._height - 12;
        m_FilterPanel._x = 0;
        m_FilterPanel.m_Background._width = m_Width;
        m_FilterPanel.m_CheckUsable._x = m_FilterPanel.m_Background._width - m_FilterPanel.m_CheckUsable._width;
        m_FilterPanel.m_CheckPurchaseable._x = m_FilterPanel.m_CheckUsable._x - m_FilterPanel.m_CheckPurchaseable._width;
    }
    
    //Update Info Panel
    private function UpdateInfoPanel():Void
    {
        m_InfoPanel.m_ActionButton_1.removeAllEventListeners("click");
        m_InfoPanel.m_ActionButton_2.removeAllEventListeners("click");
        
        m_InfoPanel.m_ActionButton_2._visible = true;
        
        if (m_CurrentFocus == BUY)
        {
            m_FilterPanel.m_CheckPurchaseable._visible = true;
            m_FilterPanel.m_CheckUsable._visible = true;
            
            m_InfoPanel.m_ActionButton_1.label = m_TDB_Buy;
            m_InfoPanel.m_ActionButton_1.disabled = (m_SelectedIndex == -1);
            m_InfoPanel.m_ActionButton_1.addEventListener("click", this, "SlotBuy");
            
            m_InfoPanel.m_ActionButton_2.label = LDBFormat.LDBGetText("GenericGUI", "Preview");
            m_InfoPanel.m_ActionButton_2.disabled = (m_SelectedIndex == -1)
            m_InfoPanel.m_ActionButton_2.addEventListener("click", this, "SlotPreview");
            
            if (m_SelectedIndex != -1)
            {
                SlotBuyItemSelected(m_SelectedIndex, 1);
            }
        }
        else if (m_CurrentFocus == REPAIR)
        {
            m_FilterPanel.m_CheckPurchaseable._visible = false;
            m_FilterPanel.m_CheckUsable._visible = true;
            
            m_InfoPanel.m_ActionButton_1.label = m_TDB_Repair;
            m_InfoPanel.m_ActionButton_1.disabled = (m_SelectedRepairIndex == -1);
            m_InfoPanel.m_ActionButton_1.addEventListener("click", this, "SlotRepair");
            
            m_InfoPanel.m_ActionButton_2.label = LDBFormat.LDBGetText("TradeGUI", "ShopGUI_RepairAll");
            m_InfoPanel.m_ActionButton_2.disabled = false;
            m_InfoPanel.m_ActionButton_2.addEventListener("click", this, "SlotRepairAll");
        }
        else if (m_CurrentFocus == SELL)
        {
            m_FilterPanel.m_CheckPurchaseable._visible = false;
            m_FilterPanel.m_CheckUsable._visible = true;
            
            m_InfoPanel.m_ActionButton_1.label = m_TDB_Sell;
            m_InfoPanel.m_ActionButton_1.disabled = (m_SelectedSellIndex == -1)
            m_InfoPanel.m_ActionButton_1.addEventListener("click", this, "SlotSell");
            
            m_InfoPanel.m_ActionButton_2.label = m_TDB_BuyBack;
            m_InfoPanel.m_ActionButton_2.disabled = (m_ShopInterface.GetNumUndoItems() == 0);
            m_InfoPanel.m_ActionButton_2.addEventListener("click", this, "SlotBuyBack");
        }
    }
    
    //Slot Drag End
    function SlotDragEnd(event:Object):Void
    {
        if (Mouse["IsMouseOver"](this, false))
        {
            if (event.data.type == "item")
            {
                if (m_CurrentFocus == SELL || m_CurrentFocus == BUY)
                {
                    m_ShopInterface.SellItem(event.data.inventory_id, event.data.inventory_slot);
                }
                else if (m_CurrentFocus == REPAIR)
                {
                    m_ShopInterface.RepairItem(event.data.inventory_id, event.data.inventory_slot);
                }
                
                event.data.DragHandled();
            }
        }
    }
    
    //Set Shop Interface
    public function SetShopInterface(shopInterface:ShopInterface):Void
    {
        m_ShopInterface = shopInterface;
        m_ShopInterface.SignalShopItemsUpdated.Connect(UpdateBuyItems, this);

        m_TabButtonArray[BUY] = {label: m_TDB_Buy, view: m_BuyList, scrollbar: m_ScrollBarBuy};
        
        m_SellList._visible = m_ScrollBarSell._visible = false;
        m_BuyBackList._visible = m_ScrollBarBuyBack._visible = false;
        m_RepairList._visible = m_ScrollBarRepair._visible = false;
        
        if (!m_ShopInterface.IsVendorSellOnly())
        {
            m_TabButtonArray[SELL] = {label: m_TDB_Sell, view: m_SellList, scrollbar: m_ScrollBarSell};
            m_TabButtonArray[REPAIR] = {label: m_TDB_Repair, view: m_RepairList, scrollbar: m_ScrollBarRepair};
            
            m_SellList._visible = m_ScrollBarSell._visible = true;
            m_BuyBackList._visible = m_ScrollBarBuyBack._visible = true;
            m_RepairList._visible = m_ScrollBarRepair._visible = true;
        }

        m_ButtonBar.dataProvider = m_TabButtonArray;

        UpdateBuyItems();
    }
    
    //Set Size
    public function SetSize(width:Number, height:Number):Void
    {
        m_Width = width;
        m_Height = height;
        
        Layout();
    }
    
    //Get Size
    public function GetSize():Point
    {
        return new Point(m_Width, m_Height);
    }
    
    //Set Tab Index
    public function SetTabIndex(value:Number):Void
    {
        SlotChangeTabIndex({index: (m_TabButtonArray[value]) ? value : 0});
    }
    
    //Get Tab Index
    public function GetTabIndex():Number
    {
        return m_ButtonBar.selectedIndex;
    }
}