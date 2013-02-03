//Imports
import gfx.core.UIComponent;
import com.GameInterface.Inventory;
import com.Components.BankItemSlot;
import com.GameInterface.Tradepost;
import com.GameInterface.Friends;
import com.GameInterface.ItemPrice;
import com.GameInterface.DialogIF;
import com.GameInterface.ProjectUtils;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.Components.RightClickMenu;
import com.Components.RightClickItem;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.Utils.ID32;
import com.Utils.DragObject;
import flash.geom.Point;
import GUI.TradePost.Views.StoreAndSellView;

//Class
class GUI.TradePost.BankContainer extends UIComponent
{
    //Constants for RightClick Menu
    private static var RIGHT_CLICK_MOUSE_OFFSET:Number = 5;
    
    private static var TITLE_MENU:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ItemName");
    
    //Properties
    public var SignalRightClickBankContainer:Signal;
    public var SignalItemPressed:Signal;
    
    private var m_NumColums:Number;
    private var m_NumRows:Number;
    private var m_NumPages:Number;
    private var m_CurrentPage:Number;
    private var m_Inventory:Inventory;
    private var m_ItemSlotsArray:Array;
    private var m_ItemsContainer:MovieClip;
    private var m_ItemSlotTemplate:String;
    private var m_GridLines:MovieClip;
    private var m_RightClickMenu:MovieClip;
    private var m_SelectedBankSlotID:Number;
    private var m_CurrentDialog:DialogIF;
	private var m_SplitItemPopup:MovieClip;
	private var m_MovedCabalItem:Object;
    
    //Constructor
    public function BankContainer()
    {
        super();

        SignalRightClickBankContainer = new Signal();
        SignalItemPressed = new Signal();
    }
    
    public function onLoad():Void
    {
        gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );
        
        Tradepost.SignalMailItemAttached.Connect(SlotMailItemAttachUpdate, this);
        Tradepost.SignalMailItemDetached.Connect(SlotMailItemAttachUpdate, this);
        
        m_SelectedBankSlotID = -1;
        m_CurrentPage = 0;
    }
    
    public function onUnload()
    {
        gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "onDragEnd" );
       
        Tradepost.SignalMailItemAttached.Disconnect(SlotMailItemAttachUpdate, this);
        Tradepost.SignalMailItemDetached.Disconnect(SlotMailItemAttachUpdate, this);

        if (m_CurrentDialog != undefined)
        {
            m_CurrentDialog.Close();
        }
    }

    
    //Set Size
    public function SetSize(colums:Number, rows:Number, pages:Number, currentPage:Number):Void
    {
        m_NumColums = colums;
        m_NumRows = rows;
        m_NumPages = pages;
        m_CurrentPage = (currentPage == undefined || currentPage < 0) ? 0 : Math.min(currentPage, m_NumPages-1);
        
        DrawGrid();
    }
    
    //Set Item Slot Template
    public function SetItemSlotTemplate(value:String):Void
    {
        m_ItemSlotTemplate = value;
    }
    
    //Draw Grid
    private function DrawGrid():Void
    {
        if (m_ItemSlotsArray == undefined)
        {
            m_ItemSlotsArray = new Array();
            
            m_ItemsContainer = createEmptyMovieClip("m_ItemsContainer", getNextHighestDepth());
            
            m_ItemsContainer.createTextField("i_NumItemsTextField", getNextHighestDepth(), 0, 0, 100, 20);
            var textFormat:TextFormat = new TextFormat();
            textFormat.font = "_StandardFont";
            textFormat.size = 10;
            m_ItemsContainer.i_NumItemsTextField.setNewTextFormat(textFormat);
            m_ItemsContainer.i_NumItemsTextField.textColor = 0xFFFFFF;
            m_ItemsContainer.i_NumItemsTextField.text = "";
            m_ItemsContainer.i_NumItemsTextField.selectable = false;
            
            
            for (var i:Number = 0; i < m_NumRows; i++)
            {
                for (var j:Number = 0; j < m_NumColums; j++)
                {
                    var index:Number = i * m_NumColums + j;
                    
                    var itemSlotMovieClip:MovieClip = m_ItemsContainer.attachMovie(m_ItemSlotTemplate, "m_ItemSlotMovieClip_" + index, m_ItemsContainer.getNextHighestDepth());
                    itemSlotMovieClip._x = j * itemSlotMovieClip._width;
                    itemSlotMovieClip._y = i * itemSlotMovieClip._height;
                    
                    var itemSlot:BankItemSlot = new BankItemSlot(m_Inventory.m_InventoryID, index, itemSlotMovieClip);
                    itemSlot.SignalMouseDown.Connect(SlotMousePressItemSlot, this);
                    itemSlot.SignalStartDrag.Connect(onDragBegin, this);
					itemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
                    itemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
                    m_ItemSlotsArray.push(itemSlot);
                }
            }
            
            var gridLineOffset:Number = 5;
            
            m_GridLines = createEmptyMovieClip("m_GridLines", getNextHighestDepth());
            m_GridLines.lineStyle(1.0, 0x555555, 100, true, "noscale");
            
            for (var horizontalLine:Number = 1; horizontalLine < m_NumRows; horizontalLine++)
            {
                m_GridLines.moveTo(gridLineOffset, itemSlotMovieClip._height * horizontalLine);
                m_GridLines.lineTo(_width - gridLineOffset, itemSlotMovieClip._height * horizontalLine)
            }

            for (var verticalLine:Number = 1; verticalLine < m_NumColums; verticalLine++)
            {
                m_GridLines.moveTo(itemSlotMovieClip._width * verticalLine, gridLineOffset);
                m_GridLines.lineTo(itemSlotMovieClip._width * verticalLine, _height - gridLineOffset);
            }
            
            m_ItemsContainer.i_NumItemsTextField._y = m_ItemsContainer._height + 2;
            m_ItemsContainer.i_NumItemsTextField._x = m_ItemsContainer._x;
            m_ItemsContainer.i_NumItemsTextField._width = m_ItemsContainer.i_NumItemsTextField.textWidth + 5;
        }
        
        UpdateItems();
        UpdateTotalItemsTextField();
    }

    public function UpdateTotalItemsTextField()
    {
        var numItems:Number = 0;
        
        for (var prop:String in m_Inventory.m_Items)
        {
            if (m_Inventory.GetItemAt(prop) != undefined )
            {
                numItems++;
            }
        }
        
        var numMaxItems:Number = m_Inventory.GetMaxItems();
        
        if (numItems >= numMaxItems)
        {
            m_ItemsContainer.i_NumItemsTextField.textColor = 0xff3030;
        }
        else
        {
            m_ItemsContainer.i_NumItemsTextField.textColor = 0xffffff;
        }
        m_ItemsContainer.i_NumItemsTextField.text = numItems + "/" + numMaxItems +" " + LDBFormat.LDBGetText("GenericGUI", "Items" );
        
        m_ItemsContainer.i_NumItemsTextField._width = m_ItemsContainer.i_NumItemsTextField.textWidth + 5;
    }

    public function GotoPage(page:Number)
    {
        m_CurrentPage = page;
        UpdateItems();
    }
    
    //Set Inventory
    public function SetInventory(inventory:Inventory):Void
    {
        m_Inventory = inventory;
        
        m_Inventory.SignalItemAdded.Connect(SlotItemAdded, this);
        m_Inventory.SignalItemMoved.Connect(SlotItemMoved, this);
        m_Inventory.SignalItemRemoved.Connect(SlotItemRemoved, this);
        m_Inventory.SignalItemChanged.Connect(SlotItemChanged, this);
        m_Inventory.SignalItemStatChanged.Connect(SlotItemStatChanged, this);
        m_Inventory.SignalItemCooldown.Connect( SlotItemCooldown, this );
        m_Inventory.SignalItemCooldownRemoved.Connect( SlotItemCooldownRemoved, this );
        m_Inventory.SignalItemLoaded.Connect( SlotItemAdded, this );

          
        UpdateItems();
    }
    
    private function SlotMailItemAttachUpdate(bankSlot:Number):Void
    {
        if ( m_Inventory.GetInventoryID().GetType() == _global.Enums.InvType.e_Type_GC_BankContainer)
        {
            
            var firstPagePosition:Number = m_CurrentPage * m_NumColums * m_NumRows;
            var lastPagePosition:Number = (m_CurrentPage+1) * m_NumColums * m_NumRows;
            
            //Updated item is in the actual page
            if (bankSlot >= firstPagePosition && bankSlot < lastPagePosition )
            {
                var gridSize:Number = m_NumColums * m_NumRows;
                var clampSlotPosition:Number = bankSlot % gridSize;
                m_ItemSlotsArray[clampSlotPosition].SetData(m_Inventory.GetItemAt(bankSlot));
            }
        }
    }
    
    //Create Right Click Menu
    public function CreateRightClickMenu():Void
    {
        var ref:MovieClip = m_ItemsContainer._parent;
        m_RightClickMenu = ref.attachMovie("RightClickMenu", "m_RightClickMenu", ref.getNextHighestDepth());
        m_RightClickMenu.width = 250;
        m_RightClickMenu._visible = false;
        m_RightClickMenu.SetHandleClose(false);
        m_RightClickMenu.SignalWantToClose.Connect(SlotHideRightClickMenu, this);
    }
    
    //Slot Hide Right Click Menu
    function SlotHideRightClickMenu():Void
    {
        if (m_RightClickMenu != undefined)
        {
            m_RightClickMenu.Hide();
        }
    }
    
    //Update Menu Title
    function UpdateMenuTitle(bankItem:BankItemSlot):Void
    {
        var menuDataProvider:Array = new Array();
        menuDataProvider.push(new RightClickItem(bankItem.GetData().m_Name, true, RightClickItem.CENTER_ALIGN));
        menuDataProvider.push(RightClickItem.MakeSeparator());
        
        var item:RightClickItem;

        if ( Tradepost.IsItemForSale(bankItem.GetData().m_InventoryPos) )
        {
            item = new RightClickItem(LDBFormat.LDBGetText("MiscGUI", "TradePost_CancelSale"), false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotCancelSale, this);
            menuDataProvider.push(item);
        }
        else //Is not for sale
        {
            if ( Tradepost.IsItemAttachedToMail(bankItem.GetData().m_InventoryPos) )
            {
                item = new RightClickItem(LDBFormat.LDBGetText("MiscGUI", "TradePost_CancelMail"), false, RightClickItem.LEFT_ALIGN);
                item.SignalItemClicked.Connect(SlotShowCancelMailDialog, this);
                menuDataProvider.push(item);
            }
            else if(Tradepost.IsItemInComposeMail(bankItem.GetData().m_InventoryPos)) //Mail is being composed
            {
                item = new RightClickItem(LDBFormat.LDBGetText("MiscGUI", "TradePost_DetachFromMail"), false, RightClickItem.LEFT_ALIGN);
                item.SignalItemClicked.Connect(SlotDetachFromMail, this);
                menuDataProvider.push(item);
            }
            else //Not attached to mail
            {
                if ( com.GameInterface.Utils.GetGameTweak("TradePost_SellingEnabled") )
                {
                    item = new RightClickItem(LDBFormat.LDBGetText("MiscGUI", "TradePost_SellItem"), false, RightClickItem.LEFT_ALIGN);
                    if(!bankItem.GetData().m_IsBoundToPlayer)
                    {
                        item.SignalItemClicked.Connect(SlotSell, this);
                    }
                    else
                    {
                        item.SetEnabled(false);
                    }
                    menuDataProvider.push(item);
                }
                
                if ( Tradepost.CanAttachToMail(m_Inventory.m_InventoryID, bankItem.GetData().m_InventoryPos, false) )
                {
                    item = new RightClickItem(LDBFormat.LDBGetText("MiscGUI", "TradePost_AttachToMail"), false, RightClickItem.LEFT_ALIGN);
                    if(!bankItem.GetData().m_IsBoundToPlayer)
                    {
                        item.SignalItemClicked.Connect(SlotAttachToMail, this);
                    }
                    else 
                    {
                        item.SetEnabled(false);
                    }
                    menuDataProvider.push(item);
                }
                
                if (bankItem.GetData().m_IsBoundToPlayer)
                {
                    item = new RightClickItem(LDBFormat.LDBGetText("MiscGUI", "TradepostGUI_BoundedItemCanNotBeTraded"), false, RightClickItem.LEFT_ALIGN);
                    item.SetEnabled(false);
                    item.SetIsNotification(true);
                    menuDataProvider.push(item);
                }
                
                if (CanDeleteItem(bankItem.GetData().m_InventoryPos))
                {
                    item = new RightClickItem(LDBFormat.LDBGetText("GenericGUI", "DeleteItem"), false, RightClickItem.LEFT_ALIGN);
                    item.SignalItemClicked.Connect(DeleteItem, this);
                    menuDataProvider.push(item);
                }            
            }
        }

        m_RightClickMenu.dataProvider = menuDataProvider;
    }
    
    private function SlotMouseUpEmptySlot(bankItemSlot:BankItemSlot, buttonIndex:Number) : Void
    {
        SlotHideRightClickMenu();
        m_SelectedBankSlotID = -1;

		//If you release right button with a drag item, deposit one
		if (buttonIndex == 2)
		{
			var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
			if (currentDragObject != undefined && currentDragObject.type == "item")
			{
				if (currentDragObject.stack_size > 1)
				{
					if (m_Inventory.SplitItem( currentDragObject.inventory_id, currentDragObject.inventory_slot, bankItemSlot.GetSlotID(), 1 ))
					{
						currentDragObject.stack_size = currentDragObject.stack_size - 1;
						currentDragObject.GetDragClip().SetStackSize(currentDragObject.stack_size);            
					}
				}
				else
				{
					gfx.managers.DragManager.instance.stopDrag();
				}
			}
		}
    }
	

	private function SlotStartSplitItem(itemSlot:BankItemSlot, stackSize:Number)
	{
        //Is on Trade in the user bank or is in the guild bank
        var isOnTrade:Boolean = itemSlot.GetInventoryID().GetType() == _global.Enums.InvType.e_Type_GC_GuildContainer ||
                                Tradepost.IsItemForSale(itemSlot.GetSlotID()) || 
                                Tradepost.IsItemAttachedToMail(itemSlot.GetSlotID()) ||
                                Tradepost.IsItemInComposeMail(itemSlot.GetSlotID() );
        
		if (m_SplitItemPopup == undefined && !isOnTrade && m_Inventory.GetInventoryID().GetType() != _global.Enums.InvType.e_Type_GC_GuildContainer)
		{
			m_SplitItemPopup = attachMovie("SplitItemPopup", "m_SplitItemPopup", getNextHighestDepth());
			var iconPos:Point = new Point(itemSlot.GetIcon()._width, 0);
			itemSlot.GetSlotMC().localToGlobal(iconPos);
			this.globalToLocal(iconPos);
			m_SplitItemPopup._x = iconPos.x;
			m_SplitItemPopup._y = iconPos.y;
			m_SplitItemPopup.SignalAcceptSplitItem.Connect(SlotAcceptSplitItem, this);
			m_SplitItemPopup.SignalCancelSplitItem.Connect(SlotCancelSplitItem, this);
			m_SplitItemPopup.SetItemSlot(itemSlot);
		}
	}
	
	private function SlotAcceptSplitItem(itemSlot:BankItemSlot, stackSplit:Number)
	{
		if (itemSlot != undefined)
		{
			onDragBegin(itemSlot, stackSplit);
			gfx.managers.DragManager.instance.dragOffsetX = -DragObject.GetCurrentDragObject().GetDragClip()._width / 2;
			gfx.managers.DragManager.instance.dragOffsetY = -DragObject.GetCurrentDragObject().GetDragClip()._height / 2;
		}
		m_SplitItemPopup = undefined;
	}

	private function SlotCancelSplitItem(slotID:Number)
	{
		m_SplitItemPopup = undefined;
	}
    
    private function SlotMousePressItemSlot(bankItemSlot:BankItemSlot, buttonIndex:Number) : Void
    {
    
        if (m_RightClickMenu)
        {
            switch (buttonIndex)
            {
                case 1:     if (!m_RightClickMenu.hitTest(_root._xmouse, _root._ymouse))
                            {
                                if (m_RightClickMenu._visible)
                                {
                                    bankItemSlot.CanReactOnNextMouseRelease(false);//Do not drag the clicked item
                                    m_RightClickMenu.Hide();
                                }
                                m_SelectedBankSlotID = -1;
                            }

                            break;
                            
                case 2:     if (!m_RightClickMenu._visible && bankItemSlot.HasItem())
                            {
                                PositionRightClickMenu();
                                
                                UpdateMenuTitle(bankItemSlot);                                
                                bankItemSlot.CloseTooltip();
                                m_RightClickMenu.Show();
                                m_SelectedBankSlotID = bankItemSlot.GetSlotID();
                            }
                            else 
                            {
                                if (m_RightClickMenu.hitTest(_root._xmouse, _root._ymouse) || !bankItemSlot.HasItem())
                                {
                                    m_RightClickMenu.Hide();                                    
                                                                        
                                    m_SelectedBankSlotID = -1;
                                }
                                else
                                {
                                    UpdateMenuTitle(bankItemSlot);
                                    
                                    bankItemSlot.CloseTooltip();
                                    m_SelectedBankSlotID = bankItemSlot.GetSlotID();
                                    
                                    PositionRightClickMenu();                                      
                                }
                            }
                            
                            break;
            }
        }
        else
        {
            m_SelectedBankSlotID = -1;
        }
        
        SignalItemPressed.Emit();
    }
    
    //Position Right Click Menu
    private function PositionRightClickMenu():Void
    {
        var visibleRect = Stage["visibleRect"];
        
        m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._xmouse + m_RightClickMenu._width - visibleRect.width);
        m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._ymouse + m_RightClickMenu._height - visibleRect.height);
    }
    
    private function SlotSell()
    {
        SellItem();
    }
    
    private function SlotCancelSale()
    {
        CancelSellItem();
    }
    
    private function SlotAttachToMail()
    {
        AttachToMail();
    }
    
    private function SlotDetachFromMail()
    {
        DetachFromMail();
    }
    
    private function SlotShowCancelMailDialog()
    {
        m_CurrentDialog = new DialogIF( LDBFormat.LDBGetText("MiscGUI", "TradePost_AreYouSureYouWantToCancelTheMail"), _global.Enums.StandardButtons.e_ButtonsYesNo, "CancelMail" );
        m_CurrentDialog.SignalSelectedAS.Connect( SlotCancelMail, this );
        m_CurrentDialog.Go();
    }
    
    public function BuySlots():Void
    {
        var nextExpansionSize:Number = com.GameInterface.Utils.GetGameTweak("Inventory_BankExpansionIncrement");
        var nextExpansionPrice:Number = ProjectUtils.CalculateNextExpansionPrice(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BankContainer, Character.GetClientCharID().GetInstance()));
        var tokenName:String = LDBFormat.LDBGetText("Tokens",  "CashToken");
        var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "ConfirmBuyBankSlots"), nextExpansionSize, nextExpansionPrice, tokenName);
        
        m_CurrentDialog = new DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "BuySlots" );
        m_CurrentDialog.SignalSelectedAS.Connect( SlotAcceptBuySlots, this );
        m_CurrentDialog.Go( );
    }

    private function SlotAcceptBuySlots(buttonID:Number):Void
    {
        if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
        {
            ProjectUtils.BuyInventorySlots(m_Inventory.GetInventoryID());
        }    
    }
    
    function SellItem():Void
    {
        if ( m_SelectedBankSlotID >= 0 )
        {
            if ( m_Inventory[m_SelectedBankSlotID].m_Durability >0 )
            {
                CanNotSellItem();
            }
            else 
            {
                SignalRightClickBankContainer.Emit(StoreAndSellView.SELL_ITEM, m_SelectedBankSlotID);
            }
        }
    }
        
    private function CanNotSellItem():Void
    {
        var dialogText:String = LDBFormat.LDBGetText("MiscGUI", "CanNotSellDamagedItems");
        m_CurrentDialog = new DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsOk, "SellDamagedItems" );
        m_CurrentDialog.Go( );
    }

    public function GetItemPriceFromCash(cash:Number):ItemPrice
    {
        var price:ItemPrice = new ItemPrice();
        price.m_TokenType1 = _global.Enums.Token.e_Cash;
        price.m_TokenType1_Amount = cash;
        price.m_TokenType2 = _global.Enums.Token.e_InvalidToken;
        price.m_TokenType2_Amount = 0;  
        return price;
    }
    
    function CancelSellItem():Void
    {
        if ( m_SelectedBankSlotID >= 0 )
        {
            Tradepost.CancelSellItem(m_SelectedBankSlotID);
        }
    }
    
    function AttachToMail():Void
    {
        if ( m_SelectedBankSlotID >= 0 )
        {
            Tradepost.OpenComposeMail();
            Tradepost.AttachItemToMail(m_Inventory.m_InventoryID, m_SelectedBankSlotID, -1);
        }
    }

    function DetachFromMail():Void
    {
        if ( m_SelectedBankSlotID >= 0 )
        {
            Tradepost.DetachItemFromMail(m_SelectedBankSlotID);
        }
    }
    
    function SlotCancelMail(buttonID:Number):Void
    {
        if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes && m_SelectedBankSlotID >= 0)
        {
            var mailID:Number = Tradepost.GetMailIDByItem(m_SelectedBankSlotID);
            Tradepost.CancelMail(mailID);
        }
    }
    
    //Slot Item Added
    function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number):Void
    {
        var firstPagePosition:Number = m_CurrentPage * m_NumColums * m_NumRows;
        var lastPagePosition:Number = (m_CurrentPage+1) * m_NumColums * m_NumRows;
        
        //Updated item is in the actual page
        if (itemPos >= firstPagePosition && itemPos < lastPagePosition )
        {
            var gridSize:Number = m_NumColums * m_NumRows;
            var clampSlotPosition:Number = itemPos % gridSize;
            m_ItemSlotsArray[clampSlotPosition].SetData(m_Inventory.GetItemAt(itemPos));
        }
        
        UpdateTotalItemsTextField();
    }
    
    //Slot Item Moved
    function SlotItemMoved(inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number):Void
    {
    }
    
    //Slot Item Removed
    function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean):Void
    {
        var firstPagePosition:Number = m_CurrentPage * m_NumColums * m_NumRows;
        var lastPagePosition:Number = (m_CurrentPage+1) * m_NumColums * m_NumRows;
        
        //Updated item is in the actual page
        if (itemPos >= firstPagePosition && itemPos < lastPagePosition )
        {
            var gridSize:Number = m_NumColums * m_NumRows;
            var clampSlotPosition:Number = itemPos % gridSize;
        
            m_ItemSlotsArray[clampSlotPosition].Clear();
        }
        
        UpdateTotalItemsTextField();
    }
    
    //Slot Item Stat Changed
    function SlotItemStatChanged(inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number):Void
    {  
        SlotItemChanged(inventoryID, itemPos);
    }
      
    function SlotItemCooldown( inventoryID:com.Utils.ID32, itemPos:Number, seconds:Number )
    {
        var firstPagePosition:Number = m_CurrentPage * m_NumColums * m_NumRows;
        var lastPagePosition:Number = (m_CurrentPage+1) * m_NumColums * m_NumRows;
        
        //Updated item is in the actual page
        if (itemPos >= firstPagePosition && itemPos < lastPagePosition )
        {
            var gridSize:Number = m_NumColums * m_NumRows;
            var clampSlotPosition:Number = itemPos % gridSize;
        
            m_ItemSlotsArray[clampSlotPosition].SetCooldown(itemPos, seconds);
        }
    }

    function SlotItemCooldownRemoved( inventoryID:com.Utils.ID32, itemPos:Number  )
    {
        var firstPagePosition:Number = m_CurrentPage * m_NumColums * m_NumRows;
        var lastPagePosition:Number = (m_CurrentPage+1) * m_NumColums * m_NumRows;
        
        //Updated item is in the actual page
        if (itemPos >= firstPagePosition && itemPos < lastPagePosition )
        {
            var gridSize:Number = m_NumColums * m_NumRows;
            var clampSlotPosition:Number = itemPos % gridSize;
        
            m_ItemSlotsArray[clampSlotPosition].RemoveCooldown(itemPos);
        }
    }
    
    //Slot Item Changed
    function SlotItemChanged(inventoryID:com.Utils.ID32, itemPos:Number):Void
    {
        var firstPagePosition:Number = m_CurrentPage * m_NumColums * m_NumRows;
        var lastPagePosition:Number = (m_CurrentPage+1) * m_NumColums * m_NumRows;
        
        //Updated item is in the actual page
        if (itemPos >= firstPagePosition && itemPos < lastPagePosition )
        {
            var gridSize:Number = m_NumColums * m_NumRows;
            var clampSlotPosition:Number = itemPos % gridSize;
            m_ItemSlotsArray[clampSlotPosition].SetData(m_Inventory.GetItemAt(itemPos));
        }
    }
    
    //Update Items
    private function UpdateItems():Void
    {
        if ( m_CurrentPage >= 0 && m_CurrentPage < m_NumPages ) //currentPage is valid
        {
            var firstPosition:Number = m_CurrentPage * m_NumColums * m_NumRows;
                    
            for (var i:Number = 0; i < m_ItemSlotsArray.length; i++)
            {
                m_ItemSlotsArray[i].SetSlotID(i + firstPosition);
                
                if (m_Inventory.GetItemAt(i + firstPosition) != undefined)
                {
                    m_ItemSlotsArray[i].SetData(m_Inventory.GetItemAt(i + firstPosition));
                }
                else
                {
                    m_ItemSlotsArray[i].Clear();
                }
            }
        }
        DisableSlots();
    }
    
    //Disable slots which are not available because of the bank size
    private function DisableSlots():Void
    {
        var firstPosition:Number = m_CurrentPage * m_NumColums * m_NumRows;
        var bankSize:Number = m_Inventory.GetMaxItems();
        for (var i:Number = 0; i < m_ItemSlotsArray.length; i++)
        {
            var slotMC:MovieClip = m_ItemSlotsArray[i].GetSlotMC();
            
            var clipName:String = "m_DisabledSlot_" + i;
            
            var clip:MovieClip = slotMC[clipName];
            if ( clip != undefined )
            {
                clip.removeMovieClip();
            }
            
            if ( firstPosition + i >= bankSize )
            {
                var disabledClip:MovieClip = slotMC.attachMovie("DisabledBankSlot", clipName, slotMC.getNextHighestDepth());
                disabledClip._alpha = 50;
            }
        }
    }
    
    //On Drag Begin
    private function onDragBegin(item:BankItemSlot, stackSize:Number):Void
    {
        var isOnTrade:Boolean = item.GetInventoryID().GetType() == _global.Enums.InvType.e_Type_GC_BankContainer &&
                                                                        ( Tradepost.IsItemForSale(item.GetSlotID()) || 
                                                                          Tradepost.IsItemAttachedToMail(item.GetSlotID()) || 
                                                                          Tradepost.IsItemInComposeMail(item.GetSlotID()) );

        if (!isOnTrade)
        {
            var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, item, stackSize);
            dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
            dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
        }
    }
    
    //On Drag End
    private function onDragEnd(event:Object):Void
    {
        if (event.cancelled)
        {
            event.data.DragHandled();
            return;
        }
        
        if ( event.data.type == "mailAttachment" && Mouse["IsMouseOver"](this) )
        {
            Tradepost.DetachItemFromMail(event.data.inventory_slot,true);
        }
        
        var isTheRightType:Boolean = ( event.data.type == "item" || event.data.type == "mailAttachment" );
        
        if ( isTheRightType && _parent._visible && Mouse["IsMouseOver"](this))
        {
            var targetSlot:Number = GetTargetSlot();
            var playSound:Boolean = true;
            if (targetSlot >= 0)
            {
				if (m_Inventory.GetInventoryID().GetType() == _global.Enums.InvType.e_Type_GC_GuildContainer && !Friends.CanWithdrawFromBank(Character.GetClientCharID()))
				{
					event.data.target_slot = targetSlot;
					m_MovedCabalItem = event.data;
					var dialogText:String = LDBFormat.LDBGetText("MiscGUI", "MoveItemToCabalBankWithoutPermission");
					m_CurrentDialog = new DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "AddToCabal" );
					m_CurrentDialog.SignalSelectedAS.Connect( SlotMoveItemToGuildBank, this );
					m_CurrentDialog.Go();
				}
				else
				{
					TryMoveItem(event.data.inventory_id, event.data.inventory_slot, targetSlot, event.data.split, event.data.stack_size);
				}
                
            }
            event.data.DragHandled();
        }
    }
	
	function SlotMoveItemToGuildBank(buttonID:Number)
	{
		if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			TryMoveItem(m_MovedCabalItem.inventory_id, m_MovedCabalItem.inventory_slot, m_MovedCabalItem.target_slot, m_MovedCabalItem.split, m_MovedCabalItem.stack_size);
		}
	}
	
	function TryMoveItem(srcInvId:ID32, srcInvSlot:Number, targetSlot:Number, isSplit:Boolean, splitSize:Number)
	{
		var succeed:Boolean = true;
		if(isSplit)
		{
			m_Inventory.SplitItem(srcInvId, srcInvSlot, targetSlot, splitSize);
		}
		else if(!(m_Inventory.GetInventoryID().GetType() == _global.Enums.InvType.e_Type_GC_BankContainer && Tradepost.IsItemInComposeMail(targetSlot)))
		{
			var addItemResult:Number = m_Inventory.AddItem(srcInvId, srcInvSlot, targetSlot);
			succeed = (addItemResult == _global.Enums.InventoryAddItemResponse.e_AddItem_Success);
		}
		Character.GetClientCharacter().AddEffectPackage((succeed) ? "sound_fxpackage_GUI_item_slot.xml" : "sound_fxpackage_GUI_item_slot_fail.xml");
	}
    
    private function SlotItemDroppedOnDesktop():Void
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        if ( currentDragObject.inventory_id.Equal(m_Inventory.GetInventoryID()) && currentDragObject.type == "item")
        {
            DeleteItem(currentDragObject.inventory_slot);
            currentDragObject.DragHandled();
        }
    }
    
    private function DeleteItem(itemSlot:Number):Void
    {
        if (itemSlot == undefined)
        {
            itemSlot = m_SelectedBankSlotID;
        }
 
        if (itemSlot >= 0 && CanDeleteItem(itemSlot))
        {
            var dialogText:String
            if (m_Inventory.GetInventoryID().GetType() != _global.Enums.InvType.e_Type_GC_GuildContainer)
            {
                dialogText = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ConfirmDeleteItem"), m_Inventory.GetItemAt(itemSlot).m_Name);                    
            }
            else
            {
                dialogText = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ConfirmDeleteCabalBankItem"), m_Inventory.GetItemAt(itemSlot).m_Name)
            }

            m_CurrentDialog = new DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "DeleteItem" );
            m_CurrentDialog.SignalSelectedAS.Connect( SlotDeleteItemDialog, this );
            m_CurrentDialog.Go(itemSlot); // <-  the slotid is userdata.
        }
        else
        {
            var errorDeleteMessage:String = LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "CanNotDeleteItem"), m_Inventory.GetItemAt(itemSlot).m_Name);
            com.GameInterface.Chat.SignalShowFIFOMessage.Emit(errorDeleteMessage, 0)  
        }
    }
    
    private function CanDeleteItem(itemSlot:Number):Boolean
    {
        if ( m_Inventory.GetItemAt(itemSlot).m_Deleteable )
        {
            if ( m_Inventory.GetInventoryID().GetType() == _global.Enums.InvType.e_Type_GC_GuildContainer &&
                Tradepost.CanItemBeRemovedFromGuildBank(itemSlot) )
                {
                    return true;
                }
            else if ( m_Inventory.GetInventoryID().GetType() == _global.Enums.InvType.e_Type_GC_BankContainer &&
                !Tradepost.IsItemForSale(itemSlot) && 
                !Tradepost.IsItemAttachedToMail(itemSlot) &&
                !Tradepost.IsItemInComposeMail(itemSlot)  )
                {
                    return true;
                }
        }
        return false;
    }
    
    private function SlotDeleteItemDialog(buttonID:Number, itemSlotID:Number)
    {
        if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
        {
            m_Inventory.DeleteItem(itemSlotID);
        }
        else
        {
            var slot:BankItemSlot = m_ItemSlotsArray[itemSlotID];
            slot.UpdateFilter();
        }
    }
    
    private function SlotDragHandled()
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        var slot:BankItemSlot = m_ItemSlotsArray[currentDragObject.inventory_slot];
        
        if ( slot != undefined && slot.HasItem() )
        {
            slot.SetAlpha(100);
            slot.UpdateFilter();
        }
    }
    
    //Get Target Slot
    private function GetTargetSlot():Number
    {
        for (var i:Number = 0; i < m_ItemSlotsArray.length; i++)
        {
            if (m_ItemSlotsArray[i].HitTest(_root._xmouse, _root._ymouse))
            {
                return m_ItemSlotsArray[i].GetSlotID();
            }
        }
        
        return -1;
    }
}
