import com.GameInterface.Inventory
import com.GameInterface.Game.Character;
import com.Utils.Signal;
import com.Utils.DragObject;
import com.Utils.LDBFormat;
import com.Components.ItemSlot;
import flash.geom.Point;
import gfx.core.UIComponent;

class GUI.Crafting.CraftingSkin extends UIComponent
{
	
	public static var STATE_EMPTY:Number = 0;
	public static var STATE_CRAFTING_NOT_READY:Number = 1;
	public static var STATE_CRAFTING_NEED_TOOL:Number = 2;
	public static var STATE_CRAFTING_READY:Number = 3;
	public static var STATE_DISASSEMBLE_NEED_TOOL:Number = 4;
	public static var STATE_DISASSEMBLE_READY:Number = 5;
	public static var STATE_CRAFTING_SCRIPT_FAILED:Number = 6;
	public static var STATE_DISASSEMBLE_SCRIPT_FAILED:Number = 7;
	
	private var m_ItemSlots:Array;
	private var m_NumRows:Number;
	private var m_NumColumns:Number;
	private var m_SlotPadding:Number;
	
	private var m_DisassemblySlotNumber:Number;
	private var m_ToolSlotNumber:Number;
	
	private var m_Inventory:Inventory;
	
	private var m_IsEmpty:Boolean;
	private var m_IsDisassembling:Boolean;
	private var m_IsCrafting:Boolean;
	
	public var SignalClose:Signal;
	public var SignalClear:Signal;
	public var SignalStartCraft:Signal;
	public var SignalStartDisassembly:Signal;
	public var SignalStartDrag:Signal;
	public var SignalStopDrag:Signal;
	
	private var m_SplitItemPopup:MovieClip;
	
	public function CraftingSkin()
	{
		super();
		m_ItemSlots = new Array();
		
		m_NumRows = 5;
		m_NumColumns = 4;
		m_SlotPadding = 12;
		
		m_DisassemblySlotNumber = -1;
		m_ToolSlotNumber = -1;
		
		SignalClose = new Signal();
		SignalClear = new Signal();
		SignalStartCraft = new Signal();
		SignalStartDisassembly = new Signal();
		SignalStartDrag = new Signal();
		SignalStopDrag = new Signal();
		
		m_IsEmpty = true;
		m_IsDisassembling = false;
		m_IsCrafting = false;
		
		gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );
	}
	
	public function configUI()
	{
		super.configUI();
	}
	
	public function Unload()
	{
		CloseSplitItemPopup();
		gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "onDragEnd" );
	}
	
	public function InitializeItemSlots()
	{
	}
	
	private function SlotStartDrag()
	{
		SignalStartDrag.Emit();
	}
	
	private function SlotStopDrag()
	{
		SignalStopDrag.Emit();		
	}
	
	function SlotClose()
	{
		SignalClose.Emit();
	}
	
	function SlotClear()
	{
		SignalClear.Emit();
	}
	
	public function SetNumRows(numRows:Number)
	{
		m_NumRows = numRows;
	}
	
	public function SetNumColumns(numColumns:Number)
	{
		m_NumRows = numColumns;
	}
	
	public function SetSlotPadding(slotPadding:Number)
	{
		m_SlotPadding = slotPadding;
	}
	
	public function SetInventory(inventory:Inventory)
	{
		m_Inventory = inventory;
		
		m_Inventory.SignalItemAdded.Connect( SlotItemAdded, this);
		m_Inventory.SignalItemLoaded.Connect( SlotItemAdded, this);
		m_Inventory.SignalItemMoved.Connect( SlotItemMoved, this);
		m_Inventory.SignalItemRemoved.Connect( SlotItemRemoved, this);
		m_Inventory.SignalItemChanged.Connect( SlotItemChanged, this);
		m_Inventory.SignalItemStatChanged.Connect( SlotItemStatChanged, this );
	}
	
	function SlotItemAdded( inventoryID:com.Utils.ID32, itemPos:Number )
	{
	}
	
	function SlotItemMoved( inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number )
	{
	}

	function SlotItemRemoved( inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
	{
	}

	function SlotItemChanged( inventoryID:com.Utils.ID32, itemPos:Number )
	{
	}
	
	function SlotItemStatChanged( inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number  )
	{  
	}
	
	/**** DRAG AND DROP ****/
	function onDragEnd( event:Object ) : Void
	{
		if ( Mouse["IsMouseOver"](this) )
		{
			var succeded:Boolean = false;
			if ( event.data.type == "item" )
			{
				var dstID = GetMouseSlotID();
				if ( dstID >= 0 )
				{
					if (event.data.split)
					{
						m_Inventory.SplitItem(event.data.inventory_id, event.data.inventory_slot, dstID, event.data.stack_size);
					}
					else
					{
						//For the toolslot, we just add one item as it never needs more than one
						if (dstID == m_ToolSlotNumber && event.data.stack_size > 1)
						{
							m_Inventory.SplitItem(event.data.inventory_id, event.data.inventory_slot, dstID, 1);
						}
						else
						{
							m_Inventory.AddItem(event.data.inventory_id, event.data.inventory_slot, dstID);
						}
					}
			   
					succeded = true;
				}
			}
			event.data.DragHandled();
			Character.GetClientCharacter().AddEffectPackage((succeded) ? "sound_fxpackage_GUI_item_slot.xml" : "sound_fxpackage_GUI_item_slot_fail.xml");
		}
	}
	
	function GetMouseSlotID() : Number
	{
		for ( var i in m_ItemSlots )
		{
			var mc:MovieClip = m_ItemSlots[i].m_ItemSlot.GetSlotMC().i_Background;
			if (mc._xmouse >= -m_SlotPadding && mc._xmouse <= mc._width + m_SlotPadding && mc._ymouse >= -m_SlotPadding && mc._ymouse <= mc._height + m_SlotPadding)
			{
				return m_ItemSlots[i].m_ItemSlot.GetSlotID();
			}
		}
		return -1;
	}
	
	function SlotMouseUpEmptySlot(itemSlot:ItemSlot, buttonIdx:Number)
	{
		//If you release right button with a drag item, deposit one
		if (buttonIdx == 2)
		{
			var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
			if (currentDragObject != undefined && currentDragObject.type == "item")
			{
				if (currentDragObject.stack_size > 1)
				{
					if (m_Inventory.SplitItem( currentDragObject.inventory_id, currentDragObject.inventory_slot, itemSlot.GetSlotID(), 1 ))
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
	
	function SlotMouseUpItem(itemSlot:ItemSlot, buttonIndex:Number)
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        if (buttonIndex == 2 && currentDragObject != undefined && currentDragObject.type == "item")
        {
            if (currentDragObject.stack_size > 1)
            {
                if (m_Inventory.SplitItem( currentDragObject.inventory_id, currentDragObject.inventory_slot, itemSlot.GetSlotID(), 1))
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
	
	function SlotStartDragItem(itemSlot:ItemSlot, stackSize:Number)
	{
		SlotCancelSplitItem(itemSlot.GetSlotID());
		var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSize);
		dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
		dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
	}

	function SlotDragHandled()
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
		
		var slot:ItemSlot = m_ItemSlots[currentDragObject.inventory_slot].m_ItemSlot;
		
		if (slot != undefined && slot.HasItem() )
		{
			slot.SetAlpha(100);
		}
	}

	function SlotItemDroppedOnDesktop()
	{
		var currentDragObject:DragObject = DragObject.GetCurrentDragObject();

		if (currentDragObject.type == "item")
		{
			SlotDeleteItem(m_ItemSlots[currentDragObject.inventory_slot].m_ItemSlot);
		}
	}

	function SlotStartSplitItem(itemSlot:ItemSlot, stackSize:Number)
	{
		if (m_SplitItemPopup == undefined)
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

	function SlotAcceptSplitItem(itemSlot:ItemSlot, stackSplit:Number)
	{
		if (itemSlot != undefined)
		{
			var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSplit);
			dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
			dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
			gfx.managers.DragManager.instance.dragOffsetX = -dragObject.GetDragClip()._width / 2;
			gfx.managers.DragManager.instance.dragOffsetY = -dragObject.GetDragClip()._height / 2;
		}
		CloseSplitItemPopup();
	}

	public function CloseSplitItemPopup()
	{
		if (m_SplitItemPopup != undefined)
		{
			m_SplitItemPopup.removeMovieClip();
			m_SplitItemPopup = undefined;
		}
	}

	function SlotCancelSplitItem(slotID:Number)
	{
		CloseSplitItemPopup();
	}


	//Slot Delete Item
	function SlotDeleteItem(itemSlot:ItemSlot):Void
	{
		var isGM:Boolean = Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_GmLevel) != 0;
		var isInCombat:Boolean = Character.GetClientCharacter().IsInCombat();
		
		if ((itemSlot.GetData().m_Deleteable || isGM) && !isInCombat)
		{
			var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ConfirmDeleteItem"), itemSlot.GetData().m_Name);
			var dialogIF = new com.GameInterface.DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsYesNo, "DeleteItem" );
			dialogIF.SignalSelectedAS.Connect( SlotDeleteItemDialog, this );
			dialogIF.Go( itemSlot.GetSlotID() );
		}
		else if (!itemSlot.GetData().m_Deleteable)
		{
			var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ItemNotDeleteable"));
			var dialogIF =new com.GameInterface.DialogIF( dialogText, _global.Enums.StandardButtons.e_ButtonsOk, "DeleteItem" );
			dialogIF.Go( ); // <-  the slotid is userdata.
		}
	}

	//Slot Delete Item Dialog
	function SlotDeleteItemDialog(buttonID:Number, itemSlotID:Number):Void
	{
		if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
			m_Inventory.DeleteItem(itemSlotID);
		}
	}

	/**** Skin functionality ****/
	
	function CraftingResultFeedback(result:Number, numItems:Number, feedback:String, items:Array)
	{
	}
	
	
	function SetState(newState:Number)
	{
		
	}
	
	
	function ResetIfEmpty()
	{
		for (var i:Number = 0; i < m_ItemSlots.length; i++ )
		{
			if (m_ItemSlots[i].m_ItemSlot.HasItem())
			{
				return
			}
		}
		m_IsEmpty = true;
		SetState(STATE_EMPTY);
	}

	function ResetPreview()
	{
		for (var i:Number = 0; i < m_ItemSlots.length; i++)
		{
			if (m_ItemSlots[i].m_IsPreview)
			{
				m_ItemSlots[i].m_ItemSlot.Clear();
			}
		}
		
	}


}