//Imports
import com.Components.ItemSlot;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Tradepost;
import com.GameInterface.TradepostSearchData;
import com.GameInterface.TradepostSearchResultData;
import com.GameInterface.InventoryItem;
import com.GameInterface.DialogIF;
import com.GameInterface.Game.Character;
import GUI.TradePost.Views.SortButton;
import GUI.TradePost.Views.PromptWindow;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import gfx.core.UIComponent;
import mx.utils.Delegate;
import com.Components.RightClickMenu;
import com.Components.RightClickItem;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.InventoryItemList.MCLItemInventoryItem;
import gfx.controls.TextInput;
import gfx.controls.Button;
import gfx.controls.ScrollBar;

//Class
class GUI.TradePost.Views.BuyView extends UIComponent
{
    //Constants
    private static var RIGHT_CLICK_MOUSE_OFFSET:Number = 5;
    private static var DEFAULT_CHECKBOX_WIDTH:Number = 110;
    private static var CHECKBOX_GAP:Number = 2;
    private static var GENERAL_GAP:Number = 10;
    private static var SEARCH_CONTROLS_Y:Number = 26;
    private static var RESULT_CONTROLS_Y:Number = 7;
    private static var SCROLL_WHEEL_SPEED:Number = 10;
    
    private static var SEARCH:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Search");
    private static var USABLE_ITEMS_ONLY:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_UsableItemsOnly");
    private static var USE_EXACT_NAME:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_UseExactName");
    
    private static var ITEM_TYPE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ItemType");
    private static var SUB_TYPE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_SubType");
    private static var RANK:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Rank");
    private static var KEYWORDS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_KeyWords");
    
    private static var RESULTS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Results");
    
    private static var TYPE_ALL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Class_All");
    private static var RANK_ALL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Rank_All");
    private static var BUY:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Buy");
    private static var BUYITEM:String = LDBFormat.LDBGetText("MiscGUI", "Tradepost_BuyItem");
    
    private static var EXPIRATION_DAYS:String = LDBFormat.LDBGetText("MiscGUI", "expirationDays");
    private static var PRESS_SEARCH_BUTTON:String = LDBFormat.LDBGetText("MiscGUI", "Tradepost_Buy_PressSearchHelp");
    
    //Properties
    private var m_UsableItemsOnlyCheckBox:MovieClip;
    private var m_UseExactNameCheckBox:MovieClip;

    private var m_MinRankField:TextInput;
    private var m_MaxRankField:TextInput;
    private var m_SearchField:TextInput;
    private var m_SearchHelptext:TextField;
    private var m_SearchContainer:MovieClip;
    private var m_ItemTypeDropdownMenu:MovieClip;
    private var m_SubTypeDropdownMenu:MovieClip;
    private var m_RightClickMenu:MovieClip;
    private var m_SearchButton:MovieClip;
    private var m_ResultsFooter:MovieClip;
    private var m_ScrollBar:ScrollBar;
    private var m_CurrentDialog:DialogIF;

    private var m_ResultsList:MultiColumnListView;
    private var m_ScrollBarPosition:Number;
    private var m_ResultsRowsArray:Array;
    
    private var m_BuyButton:Button;
    
    private var m_CheckBoxArray:Array;
    private var m_DropdownMenuArray:Array;

    private var m_CheckInterval:Number;
    private var m_UpdateSubtypeInterval:Number;
    
    private var m_SelectedItem:Number;
	private var m_CurrentSearchResult:Number;
    
    private var m_DisableSearchInterval:Number;
    private var m_Character:Character;
    
    //Constructor
    public function BuyView()
    {
        super();
		
        var keyListener:Object = new Object();
        keyListener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(keyListener);
        
        m_Character = Character.GetClientCharacter();
        if (m_Character != undefined)
        {
            m_Character.SignalTokenAmountChanged.Connect(UpdateList, this);
        }
    }
    
    public function onUnload()
    {
        if (m_CurrentDialog != undefined)
        {
            m_CurrentDialog.Close();
        }
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();

        m_SearchContainer.m_ItemTypeTextField.text = ITEM_TYPE;
        m_SearchContainer.m_SubTypeTextField.text = SUB_TYPE;
        m_SearchContainer.m_RankTextField.text = RANK;
        m_SearchContainer.m_KeywordsTextField.text = KEYWORDS;
        
        m_UseExactNameCheckBox = m_SearchContainer.attachMovie("CheckboxDark", "m_UseExactNameCheckBox", m_SearchContainer.getNextHighestDepth());
        m_UseExactNameCheckBox.autoSize = "left";
        m_UseExactNameCheckBox.label = USE_EXACT_NAME;
        m_UseExactNameCheckBox.selected = false;
        
        m_UsableItemsOnlyCheckBox = m_ResultsFooter.attachMovie("CheckboxDark", "m_UsableItemsOnlyCheckBox", m_ResultsFooter.getNextHighestDepth());
        m_UsableItemsOnlyCheckBox.autoSize = "left";
        m_UsableItemsOnlyCheckBox.label = USABLE_ITEMS_ONLY;
        m_UsableItemsOnlyCheckBox.selected = false;
        m_UsableItemsOnlyCheckBox.addEventListener("select", this, "SlotFilterUsableItems");
        
        var types:Array = new Array();
        types.push({label: TYPE_ALL, idx: TYPE_ALL});
        
        types = types.concat(GetTypes());
        m_ItemTypeDropdownMenu = m_SearchContainer.attachMovie("DropdownGray", "m_ItemTypeDropdownMenu", m_SearchContainer.getNextHighestDepth());
        m_ItemTypeDropdownMenu.dataProvider = types;
        m_ItemTypeDropdownMenu.width = 151;
        m_ItemTypeDropdownMenu.addEventListener("select", this, "SlotDropdownTypeSelected");  
        
        m_SubTypeDropdownMenu = m_SearchContainer.attachMovie("DropdownGray", "m_SubTypeDropdownMenu", m_SearchContainer.getNextHighestDepth());
        m_SubTypeDropdownMenu.dataProvider = [ { label: TYPE_ALL, idx: TYPE_ALL } ];
        m_SubTypeDropdownMenu.width = 191;
        m_SubTypeDropdownMenu.addEventListener("select", this, "RemoveFocusEventHandler"); 

        m_DropdownMenuArray = new Array (
                                        m_ItemTypeDropdownMenu,
                                        m_SubTypeDropdownMenu
                                        )
        
        for (var i:Number = 0; i < m_DropdownMenuArray.length; i++)
        {
            m_DropdownMenuArray[i].direction = "down";
            m_DropdownMenuArray[i].rowCount = m_DropdownMenuArray[i].dataProvider.length;
            m_DropdownMenuArray[i].selectedIndex = 0;
            m_DropdownMenuArray[i].dropdown = "DarkScrollingList";
            m_DropdownMenuArray[i].itemRenderer = "DarkListItemRenderer";
        }
        
        m_MinRankField.textField.restrict = m_MaxRankField.textField.restrict = "0-9";
        m_MinRankField.maxChars = m_MaxRankField.maxChars = 2;
        
        m_MinRankField.text = "0";
        m_MinRankField.addEventListener("textChange", this, "SlotMinRankChanged");
        
        m_MaxRankField.text = "10";
        m_MaxRankField.addEventListener("textChange", this, "SlotMaxRankChanged");  
        
        m_SelectedItem = 0;
        
        m_SearchButton = m_SearchContainer.attachMovie("ChromeButtonWhite", "m_SearchButton", m_SearchContainer.getNextHighestDepth());
        m_SearchButton.label = SEARCH;
        m_SearchButton.disableFocus = true;
        m_SearchButton.addEventListener("click", this, "SearchButtonClickEventHandler");

        m_ResultsList.SetItemRenderer("ResultItemRenderer");
        m_ResultsList.SetHeaderSpacing(3);
        m_ResultsList.SetShowBottomLine(true);
        m_ResultsList.SetScrollBar(m_ScrollBar);
        m_ResultsList.SignalItemClicked.Connect(SlotItemClicked, this);
        m_ResultsList.SignalSortClicked.Connect(SlotSortClicked, this);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ICON, LDBFormat.LDBGetText("MiscGUI", "TradePost_Item"), 58, ColumnData.COLUMN_NON_RESIZEABLE);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_NAME, LDBFormat.LDBGetText("MiscGUI", "TradePost_Name"), 216, 0);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_RANK, LDBFormat.LDBGetText("MiscGUI", "TradePost_QL"), 117, 0);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_EXPIRES, LDBFormat.LDBGetText("MiscGUI", "TradePost_Expires"), 117, 0);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_BUY_PRICE, LDBFormat.LDBGetText("MiscGUI", "TradePost_Price"), 117, ColumnData.COLUMN_NON_RESIZEABLE);
        m_ResultsList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_SELLER, LDBFormat.LDBGetText("MiscGUI", "TradePost_Seller"), 123, 0);
        m_ResultsList.SetSize(758, 418);
        m_ResultsList.SetSecondarySortColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_BUY_PRICE);
        m_ResultsList.DisableRightClickSelection(false);
        
        m_ScrollBar._height = m_ResultsList._height - 10;
        
        m_BuyButton.label = BUY;
        m_BuyButton.disabled = true;
        m_BuyButton.disableFocus = true;
        m_BuyButton.addEventListener("click", this, "BuyButtonClickEventHandler");
        
        m_CheckBoxArray = new Array(m_UsableItemsOnlyCheckBox, m_UseExactNameCheckBox);

        for (var i:Number = 0; i < m_CheckBoxArray.length; i++)
        {
            m_CheckBoxArray[i].addEventListener("click", this, "RemoveFocusEventHandler");
        }
        
        m_SearchField.maxChars = 100;
        m_ScrollBarPosition = 0;
        
        m_SearchHelptext.text = PRESS_SEARCH_BUTTON;
        
        CreateRightClickMenu();
        
        /*
         *  Tragedy strikes!
         * 
         *  Overriding UIComponent() doesn't work, so here I will employ a super ghetto interval check before calling the Layout
         *  function so the precious component can have its beauty sleep before updating its width after the auto-sizing
         *  label has been assigned.
         * 
         */
        
        Tradepost.SignalSearchResult.Connect(SlotResultsReceived, this);
         
        m_CheckInterval = setInterval(CheckButtonResize, 20, this);
    }
    
    //Slot Min Rand Changed
    private function SlotMinRankChanged(event:Object):Void
    {
        var min:Number = parseInt(m_MinRankField.text, 10);
        var max:Number = parseInt(m_MaxRankField.text, 10);
        
        if ( min > max )
        {
            m_MinRankField.text = max.toString();
        }
    }
    
    //Slot Max Rand Changed
    private function SlotMaxRankChanged(event:Object):Void
    {
        var max:Number = parseInt(m_MaxRankField.text, 10);
        var min:Number = parseInt(m_MinRankField.text, 10);

        if (max > 10)
        {
            m_MaxRankField.text = "10";
        }
        
        if ( max < min )
        {
            m_MaxRankField.text = min.toString();
        }
    }
    
    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        switch (Key.getCode())
        {
            case Key.TAB:       if (Selection.getFocus() == m_MinRankField.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? Selection.setFocus(m_SearchField.textField) : HighlightTextField(m_MaxRankField.textField);
                                }
                                else if (Selection.getFocus() == m_MaxRankField.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? HighlightTextField(m_MinRankField.textField) : Selection.setFocus(m_SearchField.textField);
                                }
                                else if (Selection.getFocus() == m_SearchField.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? HighlightTextField(m_MaxRankField.textField) : HighlightTextField(m_MinRankField.textField);
                                }
                                
                                break;

            case Key.ENTER:     if (Selection.getFocus() == m_MinRankField.textField || Selection.getFocus() == m_MaxRankField.textField || Selection.getFocus() == m_SearchField.textField)
                                {
                                    if (!m_SearchButton.disabled)
                                    {
                                        Search();
                                    }
                                }	
                                
                                break;
        }
    }
    
        //Create Right Click Menu
    public function CreateRightClickMenu():Void
    {
        var ref:MovieClip = m_ResultsList._parent;
        m_RightClickMenu = ref.attachMovie("RightClickMenu", "m_RightClickMenu", ref.getNextHighestDepth());
        m_RightClickMenu.width = 250;
        m_RightClickMenu._visible = false;
        m_RightClickMenu.SetHandleClose(false);
        m_RightClickMenu.SignalWantToClose.Connect(SlotHideRightClickMenu, this);
    }
    
    //Slot Hide Right Click Menu
    function SlotHideRightClickMenu():Void
    {
        m_RightClickMenu.Hide();
    }
    
    //Update Menu Title
    function UpdateRightClickMenu(item:MCLItemInventoryItem):Void
    {
        var isItemFromUser:Boolean = IsItemFromUser(item);
        var menuDataProvider:Array = new Array();
        
        menuDataProvider.push(new RightClickItem(item.m_InventoryItem.m_Name, true, RightClickItem.CENTER_ALIGN));
        
        menuDataProvider.push(RightClickItem.MakeSeparator());
        
        var option:RightClickItem;
        option = new RightClickItem(BUYITEM, false, RightClickItem.LEFT_ALIGN);
        option.SignalItemClicked.Connect(BuyButtonClickEventHandler, this);
        if (isItemFromUser)
        {
            option.SetEnabled(false);
        }
        menuDataProvider.push(option);

        if ( isItemFromUser )
        {
            option = new RightClickItem(LDBFormat.LDBGetText("Tradepost", "CantBuyItemFromSelf"), false, RightClickItem.LEFT_ALIGN);
            option.SetEnabled(false);
            option.SetIsNotification(true);
            menuDataProvider.push(option);
        }

        m_RightClickMenu.dataProvider = menuDataProvider;
    }
    
    //Position Right Click Menu
    private function PositionRightClickMenu():Void
    {
        var visibleRect = Stage["visibleRect"];
        
        m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._xmouse + m_RightClickMenu._width - visibleRect.width);
        m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._ymouse + m_RightClickMenu._height - visibleRect.height);
    }
    
    //Highlight Text Field
    private function HighlightTextField(textField:TextField):Void
    {
        Selection.setFocus(textField);
        Selection.setSelection(0, textField.text.length);
    }
    
    //Get Types
    private function GetTypes():Array
    {
        var types:Array = new Array();
        for ( var key:String in Tradepost.m_TradepostItemTypes )
        {
            key = parseInt(key, 10); //The String has something wrong
            types.push({label: LDBFormat.LDBGetText(10010, key), idx: key});
        }
        return types;
    }
    
    //Get Sub Types
    private function GetSubtypes(type:String):Array 
    {
        var subtypes:Array = new Array();
        for (var i:Number = 0; i < Tradepost.m_TradepostItemTypes[type].length; ++i )
        {
            var key:String = Tradepost.m_TradepostItemTypes[type][i];
            subtypes.push({label: LDBFormat.LDBGetText(10010, key), idx: key});
        }
        
        return subtypes;
    }
    
    //Slot Dropdown Type Selected
    private function SlotDropdownTypeSelected(event:Object):Void
    {
        if (!event.target.isOpen)
        {
            m_UpdateSubtypeInterval = setInterval(UpdateSubtypesDropdown, 20, this);
            Selection.setFocus(null);
        }
    }
    
    //Slot Filter Usable Items
    private function SlotFilterUsableItems(event:Object):Void
    {
        SlotResultsReceived();
    }
    
    //Update Subtypes Dropdown
    private function UpdateSubtypesDropdown(scope:Object):Void
    {
        clearInterval(scope.m_UpdateSubtypeInterval);
        
        var subtypes:Array = new Array();
        subtypes.push({label: TYPE_ALL, idx: TYPE_ALL});
        subtypes = subtypes.concat( scope.GetSubtypes(scope.m_ItemTypeDropdownMenu.selectedItem.idx));
        
        scope.m_SubTypeDropdownMenu.dataProvider = subtypes;
        scope.m_SubTypeDropdownMenu.rowCount = subtypes.length;
    }
    
    //Remove Focus Event Handler
    private function RemoveFocusEventHandler(event:Object):Void
    {
        if (!event.target.isOpen)
        {
            Selection.setFocus(null);
        }
    }
    
    //Search Button Click Event Handler
    private function SearchButtonClickEventHandler(event:Object):Void
    {
        Search();
        
        RemoveFocusEventHandler(event);
    }
    
    //Search
    private function Search():Void
    {
        m_SearchButton.disabled = true;
        
        Tradepost.m_SearchCriteria.m_ItemTypeVec = new Array();
        
        if ( m_ItemTypeDropdownMenu.selectedItem.idx != TYPE_ALL )
        {
            Tradepost.m_SearchCriteria.m_ItemTypeVec.push(parseInt(m_ItemTypeDropdownMenu.selectedItem.idx, 10));
        }

        Tradepost.m_SearchCriteria.m_ItemClassVec = new Array();
        Tradepost.m_SearchCriteria.m_ItemSubtypeVec = new Array();
        
        if ( m_SubTypeDropdownMenu.selectedItem.idx != TYPE_ALL )
        {
            Tradepost.m_SearchCriteria.m_ItemSubtypeVec.push(m_SubTypeDropdownMenu.selectedItem.idx);
        }        

        Tradepost.m_SearchCriteria.m_ItemPlacement = -1;
        
        var minRank:Number = parseInt(m_MinRankField.text, 10);
        var maxRank:Number = parseInt(m_MaxRankField.text, 10);
        
        if ( minRank == 0 && maxRank == 10 )
        {
            Tradepost.m_SearchCriteria.m_MinLevel = -1;
            Tradepost.m_SearchCriteria.m_MaxLevel = -1;
        }
        else
        {
            Tradepost.m_SearchCriteria.m_MinLevel = minRank;
            Tradepost.m_SearchCriteria.m_MaxLevel = maxRank;
        }
        
        Tradepost.m_SearchCriteria.m_MinPowerLevel = -1;
        Tradepost.m_SearchCriteria.m_MaxPowerLevel = -1;
        Tradepost.m_SearchCriteria.m_MinPrice = 0;
        Tradepost.m_SearchCriteria.m_MaxPrice = 99999999;
        Tradepost.m_SearchCriteria.m_MinStackSize = 0;
        Tradepost.m_SearchCriteria.m_MaxStackSize = 99999999;
        Tradepost.m_SearchCriteria.m_SellerName = "";
        Tradepost.m_SearchCriteria.m_SearchString = m_SearchField.text;
        Tradepost.m_SearchCriteria.m_SellerInstance = 0;
        Tradepost.m_SearchCriteria.m_UseExactName = m_UseExactNameCheckBox.selected;
        Tradepost.MakeSearch();
        
        m_ScrollBar.position = m_ScrollBarPosition = 0;
        
        m_DisableSearchInterval = setInterval(Delegate.create(this, SlotEnableSearch),2000,this);
    }
    
    private function SlotEnableSearch():Void
    {
        m_SearchButton.disabled = false;
        if (m_DisableSearchInterval != undefined)
        {
            clearInterval(m_DisableSearchInterval);
            m_DisableSearchInterval = undefined;
        }
    }

    //Slot Results Received
    private function SlotResultsReceived() : Void
    {
        m_SearchHelptext._visible = false;
        
        var itemsArray:Array = new Array();
        UnSelectRows();
        m_ResultsList.RemoveAllItems();
        
        var resultsCount:Number = Tradepost.m_SearchResults.length;
        var showUsableOnly:Boolean = m_UsableItemsOnlyCheckBox.selected;
            
        for (var i:Number = 0; i < resultsCount; ++i )
        {
            var result:TradepostSearchResultData = Tradepost.m_SearchResults[i];
			m_CurrentSearchResult = result.m_SearchResultId;
            
            if (!showUsableOnly || result.m_Item.m_CanUse)
            {
                result.m_Item.m_TokenCurrencyType1 = result.m_TokenType1;
                result.m_Item.m_TokenCurrencyPrice1 = result.m_TokenType1_Amount;
                result.m_Item.m_TokenCurrencyType2 = result.m_TokenType2;
                result.m_Item.m_TokenCurrencyPrice2 = result.m_TokenType2_Amount;
				

                
                var item:MCLItemInventoryItem = new MCLItemInventoryItem(result.m_Item, undefined);
				item.SetId( result.m_ItemId );
		
                item.m_Seller = result.m_SellerName;
                item.m_Expires = Math.round(result.m_ExpireDate / 86400) + " " + EXPIRATION_DAYS;
                
                itemsArray.push(item);
            }
        }        

        m_ResultsList.AddItems(itemsArray);
        m_ResultsList.SetSortColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_NAME);
        m_ResultsList.Resort();
        m_ResultsList.SetScrollBar(m_ScrollBar);
        Layout();
    }
    
    private function UpdateList():Void
    {
        m_ResultsList.ResetRenderers();
    }
    
    //Buy Button Click Event Handler
    private function BuyButtonClickEventHandler(event:Object):Void
    {
        var dialogText:String;
        if ( m_SelectedItem > 0)
        {
            dialogText = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI",  "TradePost_BuyConfirm"), m_ResultsList.GetItems()[m_ResultsList.GetIndexById(m_SelectedItem)].m_InventoryItem.m_Name);
        }
        else
        { //No name available? Use generic message
            dialogText = LDBFormat.LDBGetText("MiscGUI", "ConfirmBuyTradepostItem");
        }
        
        m_CurrentDialog = new DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "ConfirmBuyItem" );
        m_CurrentDialog.SignalSelectedAS.Connect( SlotBuyItemDialog, this );
        m_CurrentDialog.Go(undefined);
    }
    
    //Slot Buy Item Dialog
    private function SlotBuyItemDialog(buttonID:Number, boxIdx:Number)
    {
        if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
        {
            if (m_SelectedItem > 0)
            {
                var itemID:Number = m_ResultsList.GetItems()[m_ResultsList.GetIndexById(m_SelectedItem)].GetId();;
                
                var buy:Boolean = Tradepost.BuyItem(m_SelectedItem, m_CurrentSearchResult);
                
                if ( buy )
                {
                    var arraySize:Number = Tradepost.m_SearchResults.length;
                    for (var i:Number = 0; i < arraySize; ++i )
                    {
                        if (Tradepost.m_SearchResults[i].m_SearchResultId == m_CurrentSearchResult && Tradepost.m_SearchResults[i].m_ItemId == m_SelectedItem )
                        {
                            Tradepost.m_SearchResults.splice(i,1);
                            break;
                        }
                    }
                    
                    m_ResultsList.RemoveItemById(m_SelectedItem);
                    m_ResultsList.ClearSelection();
                    m_BuyButton.disabled = true;
                }
            }
        }
    }
    
    //Check Button Resize
    private function CheckButtonResize(scope:Object):Void
    {
        if (
           (scope.m_UsableItemsOnlyCheckBox._width   != DEFAULT_CHECKBOX_WIDTH)     &&
           (scope.m_UseExactNameCheckBox._width      != DEFAULT_CHECKBOX_WIDTH)     
           )
        {
            clearInterval(scope.m_CheckInterval);
            scope.Layout();
        }
    }
    
    //Layout
    private function Layout():Void
    {
        m_UseExactNameCheckBox._x = (m_SearchContainer.m_Background._x + m_SearchContainer.m_Background._width) - (m_UseExactNameCheckBox._width + CHECKBOX_GAP + 3);
        m_UseExactNameCheckBox._y = 4;
       
        m_UsableItemsOnlyCheckBox._x = m_ResultsFooter._width - m_UsableItemsOnlyCheckBox._width - GENERAL_GAP;
        m_UsableItemsOnlyCheckBox._y = m_ResultsFooter._height / 2 - m_UsableItemsOnlyCheckBox._height / 2;
        
        m_ItemTypeDropdownMenu._x = m_SearchContainer.m_ItemTypeTextField._x;
        m_SubTypeDropdownMenu._x = m_SearchContainer.m_SubTypeTextField._x;
        
        for (var i:Number = 0; i < m_DropdownMenuArray.length; i++)
        {
            m_DropdownMenuArray[i]._y = SEARCH_CONTROLS_Y;
        }
        
        m_SearchButton._x = m_SearchContainer._width - m_SearchButton._width - GENERAL_GAP;
        m_SearchButton._y = SEARCH_CONTROLS_Y;
        
        var textFormat:TextFormat = m_SearchField.textField.getTextFormat();
        textFormat.align = "left";
        m_SearchField.textField.setTextFormat(textFormat);
    }

    //Slot Item Clicked
    private function SlotItemClicked(index:Number,buttonIndex:Number):Void
    {
        m_SelectedItem = m_ResultsList.GetItems()[index].GetId();
        
        m_BuyButton.disabled = IsItemFromUser(m_ResultsList.GetItems()[index]);
        
        if ( buttonIndex == 2 )
        {
            UpdateRightClickMenu(m_ResultsList.GetItems()[index]);
            PositionRightClickMenu();
            m_RightClickMenu.Show();
        }
        else 
        {
            m_RightClickMenu.Hide();
        }
    }
    
    private function IsItemFromUser(item:MCLItemInventoryItem):Boolean
    {
        return item.m_Seller == m_Character.GetName();
    }
    
    //Slot Sort Clicked
    private function SlotSortClicked():Void
    {
        UnSelectRows();
    }
    
    //Unselect Rows
    private function UnSelectRows():Void
    {
        m_BuyButton.disabled = true;
        m_SelectedItem = 0;
        m_ResultsList.ClearSelection(); 
        m_RightClickMenu.Hide();
    }
}
