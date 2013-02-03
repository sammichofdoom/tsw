import flash.geom.Rectangle;
import GUI.Inventory.IconBox;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Components.ItemSlot;
import flash.geom.Point;
import com.Utils.Rect;
import com.GameInterface.InventoryItem;
import com.GameInterface.Log;
import com.Components.SearchBox;
import com.GameInterface.DialogIF;
import com.GameInterface.LoreBase;

class GUI.Inventory.ItemIconBox extends IconBox
{
    private var m_IsDefaultBox:Boolean;
    private var m_IsResizing:Boolean;
    private var m_IsResizable:Boolean;
    private var m_IsScrollbarEnabled:Boolean
	private var m_MaxItems:Number;

    private var m_SearchBox:SearchBox;
	
	var m_CurrentDialog:DialogIF;
    
    public var SignalNewButtonPressed:Signal;
	public var SignalCloseButtonPressed:Signal;
    public var SignalTrashButtonPressed:Signal;
    public var SignalSearch:Signal;
    public var SignalBuySlots:Signal;
    
    public function ItemIconBox(boxId:Number, inventoryId:ID32, windowMC:MovieClip, numRows:Number, numColumns:Number, isDefaultBox:Boolean, isNew:Boolean, isShortcutsBox:Boolean)
    {
        super(boxId, inventoryId, windowMC, numRows, numColumns);
        
		m_MaxItems = 0;
		
        m_IsDefaultBox = isDefaultBox;
        m_InventoryId = inventoryId;
        m_IsScrollbarEnabled = false;
        m_IsResizable = true;
        
        if (isDefaultBox)
        {
			m_MinNumColumns = 4;
			m_MinNumRows = 1;

            SetName(LDBFormat.LDBGetText("GenericGUI", "InventoryWindowTitle"));
            CanRename(false);
            
            m_WindowMC.attachMovie("NewButton", "i_NewButton", m_WindowMC.getNextHighestDepth());
            SignalNewButtonPressed = new Signal;
            
            m_WindowMC.i_NewButton.onPress = Delegate.create(this, SlotNewPress);
            m_WindowMC.i_NewButton.onRollOver = SlotMouseOverButton;
            m_WindowMC.i_NewButton.onRollOut = SlotMouseOutButton;
			
            m_WindowMC.attachMovie("HelpButton", "m_HelpButton", m_WindowMC.getNextHighestDepth());
            m_WindowMC.m_HelpButton.addEventListener("click", this, "SlotHelpButtonPressed");
            m_WindowMC.m_HelpButton.disableFocus = true;
            
			m_WindowMC.attachMovie("InventoryCloseButton", "m_CloseButton", m_WindowMC.getNextHighestDepth());
            SignalCloseButtonPressed = new Signal;
            m_WindowMC.m_CloseButton.addEventListener("click", this, "SlotCloseButtonPressed");
            m_WindowMC.m_CloseButton.disableFocus = true;
            
            m_WindowMC.createTextField("i_NumItemsTextField", m_WindowMC.getNextHighestDepth(), 0, 0, 100, 20);
            
            var textFormat:TextFormat = new TextFormat();
            textFormat.font = "_StandardFont";
            textFormat.size = 11;
            
            m_WindowMC.i_NumItemsTextField.setNewTextFormat(textFormat);
            m_WindowMC.i_NumItemsTextField.textColor = 0xFFFFFF;
            m_WindowMC.i_NumItemsTextField.text = "";
            m_WindowMC.i_NumItemsTextField.selectable = false;
            
            m_WindowMC.attachMovie("BuySlotButton", "m_BuySlotButton", m_WindowMC.getNextHighestDepth());
            
            m_WindowMC.m_BuySlotButton.disableFocus = true;4
            m_WindowMC.m_BuySlotButton.SetTooltipText(LDBFormat.LDBGetText("MiscGUI",  "ReachedInventoryLimit"));
            m_WindowMC.m_BuySlotButton.addEventListener("click", this, "SlotBuySlots");
			m_WindowMC.m_BuySlotButton.addEventListener("rollOver", this, "SlotExpandInventoryTooltip");
			
            m_WindowMC.m_BuySlotButton.textField.text = LDBFormat.LDBGetText("MiscGUI",  "BuyMoreSlots");
            m_WindowMC.m_BuySlotButton.textField._width = m_WindowMC.m_BuySlotButton.textField.textWidth + 5;
            m_WindowMC.m_BuySlotButton.m_Plus._x = m_WindowMC.m_BuySlotButton.textField._width + 5;
            
            m_SearchBox = SearchBox(m_WindowMC.attachMovie("SearchBox", "m_SearchBox", m_WindowMC.getNextHighestDepth()));
          
            m_SearchBox.SetSearchOnInput(true);
            m_SearchBox.SetDefaultText(LDBFormat.LDBGetText("GenericGUI", "SearchText"));
            m_SearchBox.addEventListener("search", this, "SlotSearchText");
            SignalSearch = new Signal();
            SignalBuySlots = new Signal();
            
            m_TopBarHeight += m_SearchBox._height + 10;
            m_WindowMC.i_Background._y += m_SearchBox._height + 8;
            m_WindowMC.i_Content._y = m_WindowMC.i_Background._y;
            
            SetHasBottomBar(true);
            
            m_BottomBar = m_WindowMC.attachMovie("BottomBarComponent", "m_BottomBar", m_WindowMC.getNextHighestDepth());
            m_BottomBar.SetHeight(GetBottomBarHeight());
        }
        else
        {
            if (isShortcutsBox)
            {
                m_WindowMC.attachMovie("ShortcutsClearButton", "i_TrashButton", m_WindowMC.getNextHighestDepth());
                
                SetName(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI",  "ShortcutsWindowTitle")));
                CanRename(false);
            }
            else
            {
                m_WindowMC.attachMovie("Backpack_TrashButton", "i_TrashButton", m_WindowMC.getNextHighestDepth());
                
                if (isNew)
                {
                   SetName(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "NewInventoryWindow")));
                }
            }
            
            SignalTrashButtonPressed = new Signal;
            
            m_WindowMC.i_TrashButton.onPress = Delegate.create(this, SlotTrashPress);
            m_WindowMC.i_TrashButton.onRollOver = SlotMouseOverButton;
            m_WindowMC.i_TrashButton.onRollOut = SlotMouseOutButton;
        }
        
        m_WindowMC.attachMovie("ResizeButton", "i_ResizeButton", m_WindowMC.getNextHighestDepth());
        
        m_WindowMC.i_ResizeButton.onMousePress = Delegate.create(this, SlotResizePress);
        m_WindowMC.i_ResizeButton.onPress = function() {}
        m_WindowMC.i_ResizeButton.onMouseUp = Delegate.create(this, SlotResizeRelease);
        m_WindowMC.i_ResizeButton.onMouseMove = Delegate.create(this, SlotResizeMove);
        m_WindowMC.i_ResizeButton.disableFocus = true;
        m_WindowMC.i_ResizeButton._alpha = 40;
        
        UpdateVisibility();
    }
	
	private function SlotExpandInventoryTooltip():Void
    {
		if (!m_WindowMC.m_BuySlotButton.disabled)
		{
			var nextExpansionSize:Number = com.GameInterface.Utils.GetGameTweak("Inventory_BankExpansionIncrement");
			var nextExpansionPrice:Number = com.GameInterface.ProjectUtils.CalculateNextExpansionPrice(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, com.GameInterface.Game.CharacterBase.GetClientCharID().GetInstance()));
			var tokenName:String = LDBFormat.LDBGetText("Tokens",  "CashToken");
            var maxSize:Number = com.GameInterface.Utils.GetGameTweak("Inventory_BackpackMaxSize");
            
			m_WindowMC.m_BuySlotButton.SetTooltipText(LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI",  "BuyMoreSlotsTooltip"), nextExpansionSize, nextExpansionPrice, tokenName, maxSize));
		}
		else
		{
			m_WindowMC.m_BuySlotButton.SetTooltipText(LDBFormat.LDBGetText("MiscGUI",  "ReachedInventoryLimit") );
		}
    }
	
	public function UpdateBuySlotsButton()
	{
        var inventoryMaxInGamePurchasedItems:Number = com.GameInterface.Utils.GetGameTweak("Inventory_BackpackSize") + 
                                                      com.GameInterface.Game.Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_ExtraItemInventorySlots);
        if (inventoryMaxInGamePurchasedItems >= com.GameInterface.Utils.GetGameTweak("Inventory_BackpackMaxSize"))
        {
            m_WindowMC.m_BuySlotButton.disabled = true;
            m_WindowMC.m_BuySlotButton.textField.text = LDBFormat.LDBGetText("MiscGUI",  "BuyMoreSlots");
            m_WindowMC.m_BuySlotButton.SetTooltipText(LDBFormat.LDBGetText("MiscGUI",  "ReachedInventoryLimit"));
        }
    }
    
    public function SetNumTotalItems(numItems:Number, numMaxItems:Number)
    {
		m_MaxItems = numMaxItems;
        
		if (numItems >= numMaxItems)
		{
			m_WindowMC.i_NumItemsTextField.textColor = 0xff3030;
		}
		else
		{
			m_WindowMC.i_NumItemsTextField.textColor = 0xffffff;
		}
        
        m_WindowMC.i_NumItemsTextField.text = numItems + "\\" + numMaxItems +" " + LDBFormat.LDBGetText("GenericGUI", "Items");
        m_WindowMC.i_NumItemsTextField._width = m_WindowMC.i_NumItemsTextField.textWidth + 5;
		
		UpdateBuySlotsButton();
    }
    
    private function SlotSearchText(event:Object)
    {
        SignalSearch.Emit(event.searchText);
    }
	
	private function SlotCloseButtonPressed()
	{
		SignalCloseButtonPressed.Emit();
	}
    
    private function SlotBuySlots()
    {
		var nextExpansionSize:Number = com.GameInterface.Utils.GetGameTweak("Inventory_BankExpansionIncrement");
        var nextExpansionPrice:Number = com.GameInterface.ProjectUtils.CalculateNextExpansionPrice(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, com.GameInterface.Game.CharacterBase.GetClientCharID().GetInstance()));
        var tokenName:String = LDBFormat.LDBGetText("Tokens",  "CashToken");
		var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "BuyMoreSlotsPopup"), nextExpansionSize, nextExpansionPrice, tokenName);
		
        m_CurrentDialog = new DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "DeleteBox" );
        m_CurrentDialog.SignalSelectedAS.Connect( SlotBuySlotsAnswer, this );
		m_CurrentDialog.Go();
    }
	
	private function SlotBuySlotsAnswer(buttonID:Number)
	{
		if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			SignalBuySlots.Emit();
		}
	}
    
    private function UpdateBoxContents(width:Number, height:Number)
    {
        height += (m_IsDefaultBox) ? IconBox.EXPAND_ITEM_BUTTON_SPACE : 0;
        
        super.UpdateBoxContents(width, height);
        
        m_WindowMC.i_ResizeButton._x = m_BoxWidth - m_WindowMC.i_ResizeButton._width;
        m_WindowMC.i_ResizeButton._y = m_BoxHeight - m_WindowMC.i_ResizeButton._height;
        
        var titleTextWidth:Number = m_BoxWidth - m_WindowMC.i_FrameName._x - m_WindowMC.i_PinButton._width
        
        if (m_IsDefaultBox)
        {  
            var boxPadding:Rect = GetBoxPadding();
            var bottomBarHeight:Number = GetBottomBarHeight();
            
            m_WindowMC.m_CloseButton._x = m_BoxWidth - m_WindowMC.m_CloseButton._width - 8;
            m_WindowMC.m_CloseButton._y = 7;
            
            m_WindowMC.m_HelpButton.width = m_WindowMC.m_HelpButton.height = m_WindowMC.m_CloseButton.width;
            m_WindowMC.m_HelpButton._x = m_WindowMC.m_CloseButton._x - m_WindowMC.m_HelpButton.width - 5;
            m_WindowMC.m_HelpButton._y = 7;
			
            m_WindowMC.i_NewButton.width = m_WindowMC.i_NewButton.height = m_WindowMC.m_CloseButton.width;
            m_WindowMC.i_NewButton._x = m_WindowMC.m_HelpButton._x - m_WindowMC.i_NewButton._width - 5;
            m_WindowMC.i_NewButton._y = 7;
            
            titleTextWidth -= m_WindowMC.i_NewButton._width - m_WindowMC.m_CloseButton._width;
            
            m_WindowMC.i_NumItemsTextField._y = m_BoxHeight - GetBottomBarHeight() - m_WindowMC.i_NumItemsTextField._height - 4;
            m_WindowMC.i_NumItemsTextField._x = Number(boxPadding.left);
            m_WindowMC.i_NumItemsTextField._width = m_WindowMC.i_NumItemsTextField.textWidth + 5;
            
            m_WindowMC.m_BuySlotButton._y = m_BoxHeight - GetBottomBarHeight() - m_WindowMC.m_BuySlotButton._height - 5;
            m_WindowMC.m_BuySlotButton._x = m_BoxWidth - m_WindowMC.m_BuySlotButton._width - boxPadding.right;
            
            m_SearchBox._y = m_TopBarHeight - m_SearchBox._height - 10;
            m_SearchBox.SetWidth(m_BoxWidth - boxPadding.left - boxPadding.right);
            m_SearchBox._x =  Number(boxPadding.left);
            
            m_BottomBar._y = m_BoxHeight - bottomBarHeight;
            m_BottomBar.SetWidth(m_BoxWidth);
        }
        else
        {
            m_WindowMC.i_TrashButton._x = m_BoxWidth - m_WindowMC.i_TrashButton._width - 8;
            m_WindowMC.i_TrashButton._y = 6;
            
            titleTextWidth -= m_WindowMC.i_TrashButton._width;
        }
        
        m_WindowMC.i_FrameName._x = m_WindowMC.i_PinButton._x + m_WindowMC.i_PinButton._width;
        m_WindowMC.i_FrameName.m_TextBackground._width = titleTextWidth;
        m_WindowMC.i_FrameName.m_Text._width = titleTextWidth;
        
        UpdateDropShadow(false);
    }
    
    private function SetWindowHasFullVisibility(fullVisibility:Boolean)
    {
        m_IsResizing = false;

        super.SetWindowHasFullVisibility(fullVisibility);
        
        if (m_WindowMC.i_ResizeButton && m_IsResizable)
        {
            m_WindowMC.i_ResizeButton._visible = fullVisibility;
        }
        if (m_WindowMC.i_NewButton)
        {
           m_WindowMC.i_NewButton._visible = fullVisibility; 
        }
        if (m_WindowMC.i_TrashButton)
        {
            m_WindowMC.i_TrashButton._visible = fullVisibility;
        }        
        if (m_WindowMC.i_NumItemsTextField)
        {
            m_WindowMC.i_NumItemsTextField._visible = fullVisibility;
        }
        if (m_SearchBox != undefined)
        {
            m_SearchBox._visible = fullVisibility;
        }
		if (m_WindowMC.m_CloseButton != undefined)
		{
			m_WindowMC.m_CloseButton._visible = fullVisibility;
		}
        if (m_WindowMC.m_HelpButton != undefined)
		{
			m_WindowMC.m_HelpButton._visible = fullVisibility;
		}
		if (m_WindowMC.m_BuySlotButton != undefined)
		{
			m_WindowMC.m_BuySlotButton._visible = fullVisibility;
		}
    }
    
    public function ResizeBoxTo(numRows:Number, numColumns:Number, isDefaultBox:Boolean)
    {
        super.ResizeBoxTo(numRows, numColumns, isDefaultBox);
        
        if ( m_WindowMC.i_ResizeButton )
        {
            m_WindowMC.i_ResizeButton.disableFocus = true;
        }
    }
    
    private function SlotResizePress()
    {
        if (Mouse["IsMouseOver"](m_WindowMC.i_ResizeButton))
        {
            m_IsResizing = true;
        }
    }
    
    private function SlotResizeRelease()
    {
        if (m_IsResizing)
        {
            m_IsResizing = false;
        }
    }
    
    private function SlotResizeMove()
    {
        if (m_IsResizing)
        {
            ResizeBox(m_IsDefaultBox);
        }
    }
    
    private function SlotHelpButtonPressed():Void
    {
        LoreBase.OpenTag(5217);
    }
    
    private function SlotNewPress()
    {
        SignalNewButtonPressed.Emit(this);
    }
    
    private function SlotTrashPress()
    {
        SignalTrashButtonPressed.Emit(this);
    }
    
    public function AddItemAtGridPosition(slotID:Number, itemData:InventoryItem, gridPosition:Point)
    {
        if (m_ItemSlots[gridPosition.x][gridPosition.y] == undefined)
        {
            CreateSlot(gridPosition, slotID, itemData, CalculateSlotPosX(gridPosition.x), CalculateSlotPosY(gridPosition.y));
        }
    }
    
    public function RemoveItem(itemID:Number):Boolean
    {
        var gridPosition:Point = GetGridPositionFromSlotID(itemID);

        if (gridPosition != undefined)
        {
            var itemSlot:ItemSlot = m_ItemSlots[gridPosition.x][gridPosition.y];
            var mc = itemSlot.GetSlotMC();
            itemSlot.Clear();
            if (mc != undefined)
            {
                mc.removeMovieClip();
            }
            m_ItemSlots[gridPosition.x][gridPosition.y] = undefined;
            m_NumItems--;
            return true;
        }
        else
        {
            return false;
        }
    }

    public function ClearItem(itemID:Number):Boolean
    {
        var gridPosition:Point = GetGridPositionFromSlotID(itemID);

        if (gridPosition != undefined)
        {
            var itemSlot:ItemSlot = m_ItemSlots[gridPosition.x][gridPosition.y];
            var mc = itemSlot.GetSlotMC();
            itemSlot.Clear();

            m_NumItems--;
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public function CreateSlot(gridPosition:Point, slotID:Number, itemData:InventoryItem, x:Number, y:Number)
    {
        var mc:MovieClip = m_WindowMC.i_Content.attachMovie("IconSlotTransparent", "slot_" +m_WindowMC.UID(), m_WindowMC.i_Content.getNextHighestDepth());
        mc._x += x;
        mc._y += y;
        var itemSlot:ItemSlot = new ItemSlot(m_InventoryId, slotID, mc);
        itemSlot.SetFilteringSupport( true );
        itemSlot.SetData(itemData);
        itemSlot.SignalDelete.Connect(SlotDeleteItem, this);
        itemSlot.SignalMouseDown.Connect(SlotMouseDownItem, this);
        itemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
        itemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
        itemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
        m_ItemSlots[gridPosition.x][gridPosition.y] = itemSlot;
        
        m_NumItems++;
        /// if no space, add the item invisible;
        if (gridPosition.y >= m_NumRows)
        {
			m_NumRows++;
			ResizeBoxTo(m_NumRows, m_NumColumns, m_IsDefaultBox);
            /*mc._visible  = false;
            mc.hitTestDisable = true;
            if (!m_IsScrollbarEnabled)
            {
                CreateScrollbar();
            }*/
        }
    }
    
    public function CreateEmptySlot(gridPosition:Point, slotID:Number)
    {
        var x:Number = CalculateSlotPosX(gridPosition.x);
        var y:Number = CalculateSlotPosY(gridPosition.y);
        
        var mc:MovieClip = m_WindowMC.i_Content.attachMovie("IconSlotTransparent", "slot_" +m_WindowMC.UID(), m_WindowMC.i_Content.getNextHighestDepth());
        mc._x += x;
        mc._y += y;
        
        var itemSlot:ItemSlot = new ItemSlot(m_InventoryId, slotID, mc);
        itemSlot.SetFilteringSupport( true );
        itemSlot.SignalDelete.Connect(SlotDeleteItem, this);
        itemSlot.SignalMouseDown.Connect(SlotMouseDownItem, this);
        itemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
        itemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
        itemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
        m_ItemSlots[gridPosition.x][gridPosition.y] = itemSlot;
        
        m_NumItems++; 
    }
    

    
    /// @TODO implement a scrollbar when content overflows the space. 
    /// Today content is truncated to be invisible, but it is there when you resize the inventory
    public function CreateScrollbar()
    {
    }
        
    ///Slot function to be called whenever an item is Deleted from the inventory
    private function SlotDeleteItem(itemSlot:ItemSlot)
    {
        if ( itemSlot.HasItem() )
        {
            //Send it further as we do not have an inventory here
            SignalDeleteItem.Emit(itemSlot);
        }
    }
    
    private function SlotMouseDownItem(itemSlot:ItemSlot, buttonIndex:Number, clickCount:Number)
    {
        //Send it further as we do not have an inventory here
        SignalMouseDownItem.Emit(this, itemSlot, buttonIndex, clickCount);
    }
    
    private function SlotMouseUpItem(itemSlot:ItemSlot, buttonIndex:Number)
    {
        //Send it further as we do not have an inventory here
        SignalMouseUpItem.Emit(this, itemSlot, buttonIndex);
    }
    
    private function SlotStartDragItem(itemSlot:ItemSlot, stackSize:Number)
    {
        if ( itemSlot.HasItem() )
        {        
            SignalStartDragItem.Emit(this, itemSlot, stackSize);
        }
    }
    
    private function SlotStartSplitItem(itemSlot:ItemSlot)
    {
        if ( itemSlot.HasItem() )
        {        
            SignalStartSplitItem.Emit(this, itemSlot);
        }
    }
    
    ///Adds an item to a given x,y position in the window
    public function AddItemAt(slotID:Number, itemData:InventoryItem, dstX:Number, dstY:Number)
    {
        var gridPosition:Point = GetGridPositionAt(dstX, dstY);
        CreateSlot(gridPosition, slotID, itemData, CalculateSlotPosX(gridPosition.x), CalculateSlotPosY(gridPosition.y) );
    }
    
    ///Adds an item to the first free slot
    public function AddItem(slotID:Number, itemData:InventoryItem)
    {
		var gridPos:Point = GetFirstFreeGridPosition();
		if (gridPos != undefined)
		{
			CreateSlot(gridPos, slotID, itemData, CalculateSlotPosX(gridPos.x), CalculateSlotPosY(gridPos.y));
        }
    }
    
    public function AddItemToExistingSlot(slotID:Number, itemData:Object)
    {
        ChangeItem(slotID, itemData);
    }
    
    ///Merges this box into another box (By putting all elements into the other one)
    public function MergeInto(otherBox:ItemIconBox)
    {
        for (var i:Number = 0; i < m_NumColumns; i++ )
        {
            for (var j:Number = 0; j < m_NumRows; j++ )
            {
                if (m_ItemSlots[i][j] != undefined)
                {
                    var itemSlot:ItemSlot = m_ItemSlots[i][j];
                    otherBox.AddItem(itemSlot.GetSlotID(), itemSlot.GetData() );
                    RemoveItem(itemSlot.GetSlotID());
                }
            }
        }    
    }
   
    public function GetItemSlot(itemID:Number):ItemSlot
    {
        var gridPosition:Point = GetGridPositionFromSlotID(itemID);
        if (gridPosition != undefined)
        {
            return m_ItemSlots[gridPosition.x][gridPosition.y];
        }
        else
        {
            Log.Error("ItemIconBox", "Could not get gridposition for item id " + itemID);
            return null    
        }
        
    }
    
    public function GetItemData(itemID:Number)
    {
        var itemSlot:ItemSlot = GetItemSlot(itemID);
        return (itemSlot)?itemSlot.GetData():undefined;
    }
    
        
    public function GetSlotBindings():Array
    {
        var bindings:Array = [];
        for (var i:Number = 0; i < m_NumColumns; i++ )
        {
            for (var j:Number = 0; j < m_NumRows; j++ )
            {
                if (m_ItemSlots[i][j] != undefined)
                {
                    var binding:Object = { m_Index:new Point(i, j), m_Item:m_ItemSlots[i][j].GetSlotID() };
                    bindings.push(binding);
                }
            }
        }
        return bindings;
    }
    
    /// Closes all the tooltips if box is removed or enter a state where ist is invisible
    public function CloseAllTooltips()
    {
        for (var i:Number = 0; i < m_NumColumns; i++ )
        {
            for (var j:Number = 0; j < m_NumRows; j++ )
            {
                if (m_ItemSlots[i][j] != undefined)
                {
                    m_ItemSlots[i][j].CloseTooltip();
                }
            }
        }
    }
    
    public function UpdateFilteredItems()
    {
        for (var i:Number = 0; i < m_ItemSlots.length; i++)
        {
            for (var j:Number = 0; j < m_ItemSlots[i].length; j++)
            {
                if (m_ItemSlots[i][j] != undefined)
                {
                    m_ItemSlots[i][j].UpdateFilter();
                }
            }
        }
    }
    
    public function SetCooldown(slotID:Number, seconds:Number)
    {
        var gridPosition:Point = GetGridPositionFromSlotID(slotID);
        if (gridPosition != undefined)
        {
            m_ItemSlots[gridPosition.x][gridPosition.y].SetCooldown(seconds);
        }
    }
    
    public function RemoveCooldown(slotID:Number)
    {
        var gridPosition:Point = GetGridPositionFromSlotID(slotID);
        if (gridPosition != undefined)
        {
            m_ItemSlots[gridPosition.x][gridPosition.y].RemoveCooldown();
        }        
    }
    
    public function SetResizable(resizable:Boolean)
    {
        m_IsResizable = resizable;
        m_WindowMC.i_ResizeButton._visible = m_IsResizable;
    }
}
