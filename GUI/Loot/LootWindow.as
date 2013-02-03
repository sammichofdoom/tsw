import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Game.Team;
import com.GameInterface.Game.Raid;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.Character;
import com.GameInterface.DialogIF;
import com.Components.ItemSlot;
import com.Components.RightClickMenu;
import com.Components.RightClickItem;
import com.Utils.ID32;
import com.GameInterface.Loot;
import com.GameInterface.NeedGreed;
import com.GameInterface.GUIUtils.Draw;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.Utils.DragObject;
import com.Utils.LDBFormat;

class GUI.Loot.LootWindow
{
    static private var ASSIGN_LABEL:String = LDBFormat.LDBGetText("MiscGUI", "Assign_Item");
    static private var ASSIGN_ITEM_TO:String = LDBFormat.LDBGetText("MiscGUI", "Assign_Item_To");
    static private var RIGHT_CLICK_MOUSE_OFFSET:Number = 5;
    static private var m_Padding:Number = 2;
    
    public var SignalLootWindowClosed:Signal;

    private var m_Inventory:Inventory;
    private var m_ItemSlots:Array;
    private var m_LootBagMC:MovieClip;
    private var m_LootbagBackground:MovieClip;
    private var m_CloseButton:MovieClip;
    private var m_RightClickMenu:MovieClip;
    private var m_NumLootItemsPerLine:Number = 4;
    private var m_LootbagPadding:Number = 10;
    private var m_LootItemsPadding:Number = 5;
    private var m_RightClickSelectedItemSlot:ItemSlot;
    private var m_CharactersToLoot:Array;
    private var m_MasterLooterConfirmDialog:DialogIF;
    private var m_Client:Character;
    
    private var m_NumRows:Number;
    private var m_IconSize:Number;
    public  var m_ID:ID32;
    private var m_LootBag:com.GameInterface.Loot;
    private var STATE_DRAGGING;
    
    private var m_MaxDragX;
    private var m_MinDragX;
    private var m_MaxDragY;
    private var m_MinDragY;

    public function LootWindow( id:com.Utils.ID32, mc:MovieClip )
    {
        m_ID = id;
        m_LootBag = new Loot(id);
        m_LootBagMC = mc;
        m_NumRows = 0;
        m_ItemSlots = new Array();
        STATE_DRAGGING = false;
        
        m_Client = Character.GetClientCharacter();
        
        /// create the background of the lootbag now, cause the slots will be placed on top of it.
        m_LootbagBackground = mc.createEmptyMovieClip("i_Background", mc.getNextHighestDepth());
        m_LootbagBackground.onRelease = Delegate.create(this, StopDragLootBag)
        m_LootbagBackground.onPress = Delegate.create(this, StartDragLootBag)
        
        m_LootBag.SignalChanged.Connect(SlotChanged, this);
        m_LootBag.SignalClose.Connect(SlotClose, this);
        
        SignalLootWindowClosed = new Signal;
        
        /// attach the close button
        m_CloseButton= m_LootBagMC.attachMovie("LootController_CloseButton", "i_CloseButton", m_LootBagMC.getNextHighestDepth() );
        m_CloseButton.onRollOut = onMouseOutButton;
        m_CloseButton.onRollOver = onMouseOverButton;
        m_CloseButton.onRelease = Delegate.create(this, CloseLootbag);
        
        if (NeedGreed.IsMasterLooter(m_Client.GetID()))
        {
            CreateRightClickMenu();
            m_CharactersToLoot = GetCharactersToLoot();
        }
    }
    
    private function GetCharactersToLoot():Array
    {
        var lootCharacters:Array = new Array();
        
        if ( TeamInterface.IsInRaid(m_Client.GetID()) )
        {
            var raid:Raid = new Raid(TeamInterface.GetClientRaidID());
            for ( var key:String in raid.m_Teams )
            {
                AddTeamCharacters(lootCharacters, raid.m_Teams[key]);
            }
        }
        else if ( TeamInterface.IsInTeam(m_Client.GetID()) )
        {
            var team:Team = new Team(TeamInterface.GetClientTeamID());
            AddTeamCharacters(lootCharacters, team);
        }
        
        return lootCharacters;
    }
    
    private function AddTeamCharacters(characters:Array, team:Team):Void
    {
        for ( var key:String in team.m_TeamMembers )
        {
            var charElement:GroupElement = team.m_TeamMembers[key];
            characters[charElement.m_Name] = charElement.m_CharacterId;
        }
    }
    
    private function AddRow()
    {
        for (var i:Number = 0; i < m_NumLootItemsPerLine; i++)
        {
            var lootIcon:MovieClip = m_LootBagMC.attachMovie("IconSlot", "slot_" + ((m_NumRows * m_NumLootItemsPerLine) + i), m_LootBagMC.getNextHighestDepth()); 
            m_IconSize = lootIcon._width;
            lootIcon._x += (m_IconSize + 2) * i + m_LootbagPadding;
            lootIcon._y += ((m_IconSize + 2) * m_NumRows + m_LootbagPadding) + 20;
        }
        m_NumRows++;
        DrawBackground();
    }
    
    public function SetInventory(inventory:Inventory)
    {
        m_Inventory = inventory;
        
        for (var i:Number = 0; i < m_Inventory.GetMaxItems(); i++ )
        {
            // The number of items is the inventory max size, so we have to check if there is an item in the slot.
            if (m_Inventory.GetItemAt(i) != undefined)
            {
                AddItem(i, m_Inventory.GetItemAt(i));
            }
        }
        
        m_Inventory.SignalItemRemoved.Connect( SlotItemRemoved, this );
        
        m_LootBag.TryLootCash();
        
    }
    
    //Create Right Click Menu
    private function CreateRightClickMenu():Void
    {
        if (m_RightClickMenu)
        {
            m_RightClickMenu.removeMovieClip();
        }
        var ref:MovieClip = m_LootBagMC._parent;
        m_RightClickMenu = ref.attachMovie("RightClickMenu", "rightClickMenu", ref.getNextHighestDepth());
        m_RightClickMenu.width = 250;
        m_RightClickMenu._visible = false;
        m_RightClickMenu.SetHandleClose(false);
        m_RightClickMenu.SignalWantToClose.Connect(SlotHideRightClickMenu, this);
    }
    
    //Slot Hide Right Click Menu
    function SlotHideRightClickMenu():Void
    {
        HideRighClickMenu();
    }
    
    function UpdateRightClickMenuItems():Void
    {
        var menuDataProvider:Array = new Array();
        menuDataProvider.push(new RightClickItem(ASSIGN_LABEL+m_RightClickSelectedItemSlot.GetData().m_Name, true, RightClickItem.CENTER_ALIGN));
        menuDataProvider.push(RightClickItem.MakeSeparator());
        
        
        var item:RightClickItem;
        for ( var key:String in m_CharactersToLoot )
        {
            item = new RightClickItem(key, false, RightClickItem.LEFT_ALIGN);
            item.SignalItemClicked.Connect(SlotShareLoot, this);
            menuDataProvider.push(item);
        }
        
        m_RightClickMenu.dataProvider = menuDataProvider;
    }
    
    
    private function SlotShareLoot(selectedLabel:String):Void
    {
        var confirmText:String =  LDBFormat.Printf(ASSIGN_ITEM_TO, m_RightClickSelectedItemSlot.GetData().m_Name, selectedLabel);
        m_MasterLooterConfirmDialog = new DialogIF( confirmText, _global.Enums.StandardButtons.e_ButtonsYesNo, "ConfirmShareLoot" );
        m_MasterLooterConfirmDialog.SignalSelectedAS.Connect( Delegate.create(this, SlotConfirmShareLoot), this );
        m_MasterLooterConfirmDialog.Go( m_CharactersToLoot[selectedLabel] );
    }
    
    private function SlotConfirmShareLoot(buttonID:Number, charId:ID32):Void
    {
        if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
        {
           LootItem(m_RightClickSelectedItemSlot, charId);
           
           m_RightClickSelectedItemSlot = undefined;
        }
    }

    
    private function GetNumItems() : Number
    {
        var count:Number = 0;
        for (var i:Number = 0; i < m_Inventory.GetMaxItems(); i++ )
        {
            if (m_Inventory.GetItemAt(i) != undefined)
            {
                count++;
            }
        }
        return count;
    }
    
    private function DrawBackground()
    {       
        /// get the dimensions, the magic numbers here are just to position the temporary closebutton, will be removed with the fancy close/accept button
        var height:Number = (m_NumRows * (m_LootItemsPadding + m_IconSize)) + (m_LootbagPadding ) + 20;
        var width:Number = ( m_NumLootItemsPerLine  * (m_LootItemsPadding + m_IconSize)) + (m_LootItemsPadding );
        
        /// draw the background of the items now that all slots are done
        com.GameInterface.GUIUtils.Draw.DrawRectangle(m_LootbagBackground, 0, 0, width, height, 0x333333, 70, [8, 8, 8, 8], 1, 0xFFFFFF);
        
        m_CloseButton._x = width - m_CloseButton._width;
        m_CloseButton._y = -3;
        
    }
    
    private function StartDragLootBag()
    {
        STATE_DRAGGING = true;
        m_LootBagMC.startDrag();
        CheckPositionLimits();
        m_LootBagMC.onMouseMove = Delegate.create(this, DragPositionCheck);
        
        HideRighClickMenu();
    }
    
    private function HideRighClickMenu():Void
    {
        if (m_RightClickMenu)
        {
            m_RightClickMenu.Hide();
        }
    }
    
    //Position Right Click Menu
    private function PositionRightClickMenu():Void
    {
        if (m_RightClickMenu)
        {
            var visibleRect = Stage["visibleRect"];
            m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._xmouse + m_RightClickMenu._width - visibleRect.width);
            m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._ymouse + m_RightClickMenu._height - visibleRect.height);
        }
    }
    
    private function CheckPositionLimits() : Void
    {
        m_MaxDragX = Stage["visibleRect"].x + Stage["visibleRect"].width - m_LootBagMC._width;
        m_MinDragX = Stage["visibleRect"].x;
        m_MaxDragY = Stage["visibleRect"].y + Stage["visibleRect"].height - m_LootBagMC._height;
        m_MinDragY = Stage["visibleRect"].y;
    }
    
    private function CorrectPostion() : Void
    {
        CheckPositionLimits();
        if (m_LootBagMC._x < m_MinDragX)
        {
            m_LootBagMC._x = m_MinDragX;
        }
        else if (m_LootBagMC._x > m_MaxDragX)
        {
            m_LootBagMC._x = m_MaxDragX
        }
        
        if (m_LootBagMC._y < m_MinDragY)
        {
            m_LootBagMC._y = m_MinDragY;
        }
        else if (m_LootBagMC._y > m_MaxDragY)
        {
            m_LootBagMC._y = m_MaxDragY
        }        
    }
    
    public function GetID()
    {
        return m_ID;
    }
    
    public function SetCenterPosition(x:Number, y:Number):Void
    {
        m_LootBagMC._x = x - m_LootBagMC._width / 2;
        m_LootBagMC._y = y - m_LootBagMC._height / 2;
        CorrectPostion();
    }
    
    public function AddItem(itemPos:Number, item:InventoryItem)
    {
        var nextFree:Number = m_ItemSlots.length;
        
        var numRowsNeeded:Number = Math.ceil((nextFree + 1) / m_NumLootItemsPerLine);
        if (numRowsNeeded > m_NumRows)
        {
            AddRow();
        }
        
        
        var itemSlot:ItemSlot = new ItemSlot(m_ID, itemPos, m_LootBagMC["slot_" + nextFree]);
  
        if(itemSlot != undefined)
        {
            itemSlot.SetDragItemType("lootitem");
            itemSlot.SignalMouseDown.Connect(SlotMouseDownItem, this);
            //itemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
            itemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
            itemSlot.SetData( item );
        }
        m_ItemSlots.push(itemSlot);
    }
    
    private function StopDragLootBag()
    {      
        if (STATE_DRAGGING)
        {
            STATE_DRAGGING = false
            m_LootBagMC.stopDrag();
            delete m_LootBagMC.onMouseMove
        }
    }
    
    private function DragPositionCheck()
    {
        if (m_LootBagMC._x < m_MinDragX)
        {
            m_LootBagMC._x = m_MinDragX;
            StopDragLootBag();
        }
        else if (m_LootBagMC._x > m_MaxDragX)
        {
            m_LootBagMC._x = m_MaxDragX
            StopDragLootBag();
        }
        
        if (m_LootBagMC._y < m_MinDragY)
        {
            m_LootBagMC._y = m_MinDragY;
            StopDragLootBag();
        }
        else if (m_LootBagMC._y > m_MaxDragY)
        {
            m_LootBagMC._y = m_MaxDragY
            StopDragLootBag();
        }
    }
    
    private function onMouseOverButton()
    {
        MovieClip(this).gotoAndPlay("over"); /// bloody compiler, if u gonna flip around the scopes like crazy please have the dignity to pay attention...
    }

    private function onMouseOutButton()
    {
        MovieClip(this).gotoAndPlay("out");
    }
    
    private function IsSlotPersonalLoot(itemSlot:ItemSlot)
    {
        if (itemSlot.GetData() != undefined)
        {
            return itemSlot.GetData().m_ACGItem != undefined
        }
        return false;
    }
    
    function SlotMouseDownItem(itemSlot:ItemSlot, buttonIndex:Number, clickCount:Number)
    {
        HideRighClickMenu();
        
        if (clickCount == 2 && buttonIndex == 1)
        {
            LootItem(itemSlot, m_Client.GetID());
        }
        else if (buttonIndex == 2 && m_RightClickMenu && m_LootBag.GetPersonalItemDropStat(itemSlot.GetSlotID()) == 0)
        {
            m_RightClickSelectedItemSlot = itemSlot;
            itemSlot.CloseTooltip();
            
            UpdateRightClickMenuItems();
            m_RightClickMenu.Show();
            PositionRightClickMenu();
        }
    }
    
    private function LootItem(itemSlot:ItemSlot, characterID:ID32)
    {
        if (characterID)
        {
            m_LootBag.TryLootItem(itemSlot.GetSlotID(), characterID, 0);
            if (IsSlotPersonalLoot(itemSlot))
            {
                SlotItemRemoved(m_Inventory.m_InventoryID, itemSlot.GetSlotID(), false);
            }
        }
    }
    
    private function SlotStartDragItem(itemSlot:ItemSlot, stackSize:Number)
    {
        var dragObject:DragObject = com.Utils.DragManager.StartDragItem(m_LootBagMC, itemSlot, stackSize);
        dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
    }
    
    function SlotDragHandled()
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        var itemSlot:ItemSlot = GetItemSlot(currentDragObject.inventory_slot);
        if ( itemSlot != undefined )
        {
            itemSlot.SetAlpha(100);
            itemSlot.UpdateFilter();
            if ( IsSlotPersonalLoot(itemSlot))
            {
                SlotItemRemoved(m_Inventory.m_InventoryID, currentDragObject.inventory_slot, false);
            }
        }
    }
    
    function GetItemSlot(slotId:Number): ItemSlot
    {
        for (var i:Number = 0; i < m_ItemSlots.length; i++)
        {
            if (slotId == m_ItemSlots[i].GetSlotID())
            {
                return m_ItemSlots[i];
            }
        }
    }
    
    private function SlotItemRemoved( inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean)
    {
        var check:Boolean = false;
        for(var i:Number = 0;i<m_ItemSlots.length;i++)
        {
            if(m_ItemSlots[i] != undefined && m_ItemSlots[i].GetSlotID() == itemPos)
            {
                m_ItemSlots[i].Clear();
                m_ItemSlots[i] = undefined
            }
            else if (m_ItemSlots[i] != undefined)
            {
                check = true;
            }
        }
        if (!check)
        {
            CloseLootbag();
        }
    }
    
    private function ClearSlots()
    {
        for(var i:Number = 0;i<m_ItemSlots.length;i++)
        {
            m_ItemSlots[i].Clear();
        }
        m_ItemSlots = [];
        m_NumRows = 1;
        DrawBackground();
    }

    private function SlotChanged(lootBagID:ID32)
    {
        ClearSlots();
        SetInventory(new Inventory(lootBagID));
    }
    
    private function SlotClose()
    {
        if (m_RightClickMenu)
        {
            m_RightClickMenu.removeMovieClip();
            m_RightClickMenu = undefined;
        }
        if (m_LootBag != undefined)
        {
            m_LootBag.SignalChanged.Disconnect(SlotChanged, this);
            m_LootBag.SignalClose.Disconnect(SlotClose, this);
            DisconnectTooltip();
        }
                
        var lastPosition:flash.geom.Point = new flash.geom.Point(0,0);
        if (m_LootBagMC != undefined)
        {
            lastPosition = new flash.geom.Point( m_LootBagMC._x, m_LootBagMC._y );
            m_LootBagMC.removeMovieClip(); 
            m_LootBagMC = undefined;
        }
        SignalLootWindowClosed.Emit( this, lastPosition );
    }
    
    public function CloseLootbag()
    {
        m_LootBag.Close();
        SlotClose();
    }

    /// disconnects all the tooltips if box is removed or enter a state where ist is invisible
    public function DisconnectTooltip()
    {
        for ( var i:Number = 0; i < m_ItemSlots.length ; ++i )
        {
            if (m_ItemSlots[i] != undefined)
            {
                m_ItemSlots[i].CloseTooltip();
            }
        }
    }
}
