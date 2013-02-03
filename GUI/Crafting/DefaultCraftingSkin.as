import com.GameInterface.LoreBase;
import com.GameInterface.InventoryItem;
import com.GameInterface.Game.Character;

import GUI.Crafting.CraftingSkin;
import com.Components.ItemSlot;
import com.Components.FCButton;

import com.Utils.ID32;
import com.Utils.LDBFormat;

import mx.utils.Delegate;
import mx.transitions.easing.Strong;
import gfx.controls.Button;

class GUI.Crafting.DefaultCraftingSkin extends CraftingSkin
{
	private var m_SlotContent:MovieClip;
	private var m_DisassemblySlot:MovieClip;
	private var m_ToolSlot:MovieClip;
	private var m_Background:MovieClip;
	private var m_DissambleDoneFrame:MovieClip;
	private var m_AssembleDoneFrame:MovieClip;
	private var m_FeedbackFrame:MovieClip;
	private var m_ArrowDown:MovieClip;
	private var m_ArrowUp:MovieClip;
	
	private var m_CloseButton:Button;
	private var m_HelpButton:Button;
	private var m_AssembleButton:Button;
	private var m_ClearButton:FCButton;
	private var m_NoneButton:Button;
	
	private var m_PartsText:TextField;
	private var m_Title:TextField;
	private var m_ToolSlotTextInfo:TextField;
	private var m_DisassemblySlotTextInfo:TextField;
	private var m_ToolSlotTextHeadline:TextField;
	private var m_DisassemblySlotTextHeadline:TextField;
	
	private var m_AssembleText:String;
	private var m_DisassembleText:String;
	
	private var m_HasTool:Boolean;
	
	public function DefaultCraftingSkin()
	{
		super();
		
		_alpha = 0;
		
		m_AssembleText = LDBFormat.LDBGetText("GenericGUI", "CraftingAssemble");
		m_DisassembleText = LDBFormat.LDBGetText("GenericGUI", "CraftingDisassemble");
		m_HasTool = false;
	}
	
	public function configUI()
	{
		super.configUI();
		
		MovieClip(this).tweenTo( 0.2, {_alpha: 100}, Strong.easeOut );
		
		m_Background.onRelease = Delegate.create(this, SlotStopDrag);
		m_Background.onReleaseOutside = Delegate.create(this, SlotStopDrag);
		m_Background.onPress = Delegate.create(this, SlotStartDrag);
		m_DissambleDoneFrame._visible = false;
		m_AssembleDoneFrame._visible = false;
		
		m_PartsText.autoSize = "center";
		m_PartsText.text = LDBFormat.LDBGetText("GenericGUI", "CraftingLayoutParts");
		m_PartsText.hitTestDisable = true;
		
		m_Title.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingTitle");
		
		m_CloseButton.disableFocus = true;
		m_HelpButton.disableFocus = true;
		m_AssembleButton.disableFocus = true;
		m_ClearButton.disableFocus = true;
        m_ClearButton.SetTooltipText(LDBFormat.LDBGetText("GenericGUI", "ClearAssemblyItemsTooltip"));
			
		m_CloseButton.addEventListener("click", this, "SlotClose");
		m_HelpButton.addEventListener("click", this, "SlotHelp");
		m_ClearButton.addEventListener("click", this, "SlotClear");
		
		m_NoneButton.textField.text = LDBFormat.LDBGetText("GenericGUI", "CraftingCraft");
		
		m_AssembleButton.addEventListener( "click", this, "SlotStartCrafting" );
		
		m_AssembleButton.disabled = true;
		m_AssembleButton.label = m_AssembleText;
	
		ResetIfEmpty();
	}
	
	public function SlotClear()
	{
		SignalClear.Emit();
		m_ClearButton.disabled = true;
		m_IsEmpty = true;
	}

	function SlotClose()
	{
		SignalClose.Emit();
	}
	
	

	function SlotHelp():Void
	{
		Selection.setFocus(null);
		
		LoreBase.OpenTag(5221)
	}

	
		
	function SlotStartCrafting()
	{
		if (m_IsCrafting)
		{
			SignalStartCraft.Emit();
		}
		else
		{
			SignalStartDisassembly.Emit();
		}
	}
	
	
	public function InitializeItemSlots()
	{
		super.InitializeItemSlots();
		for (var i:Number = 0; i < m_NumColumns; i++)
		{
			for (var j:Number = 0; j < m_NumRows; j++)
			{
				var index:Number = i * m_NumRows + j;
				var mc:MovieClip = m_SlotContent.attachMovie("IconSlot", "m_IconSlot_" + i + "_" + j, m_SlotContent.getNextHighestDepth());
				mc._x = j * (mc._width + m_SlotPadding);
				mc._y = -(i * (mc._height + m_SlotPadding));
				m_ItemSlots[index] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, index, mc), m_IsPreview:false};
				m_ItemSlots[index].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
				m_ItemSlots[index].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
				m_ItemSlots[index].m_ItemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
				m_ItemSlots[index].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
				m_ItemSlots[index].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
				if (m_Inventory.GetItemAt(index) != undefined)
				{
					m_ItemSlots[index].m_ItemSlot.SetData(m_Inventory.GetItemAt(index));
				}
			}
		}
		m_DisassemblySlotNumber = m_ItemSlots.length
		
		m_ItemSlots[m_DisassemblySlotNumber] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, m_DisassemblySlotNumber, m_DisassemblySlot), m_IsPreview:false};
		m_ItemSlots[m_DisassemblySlotNumber].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[m_DisassemblySlotNumber].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[m_DisassemblySlotNumber].m_ItemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
		m_ItemSlots[m_DisassemblySlotNumber].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[m_DisassemblySlotNumber].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[m_DisassemblySlotNumber].m_ItemSlot.SetData(m_Inventory.GetItemAt(m_DisassemblySlotNumber));
		if (m_Inventory.GetItemAt(m_DisassemblySlotNumber) != undefined)
		{
			UpdateDisassemblySlotItemInfo(m_Inventory.GetItemAt(m_DisassemblySlotNumber));
		}
		
		m_ToolSlotNumber = m_DisassemblySlotNumber + 1;
		m_ItemSlots[m_ToolSlotNumber] = {m_ItemSlot: new ItemSlot(m_Inventory.m_InventoryID, m_ToolSlotNumber, m_ToolSlot), m_IsPreview:false};
		m_ItemSlots[m_ToolSlotNumber].m_ItemSlot.SignalDelete.Connect(SlotDeleteItem, this);
		m_ItemSlots[m_ToolSlotNumber].m_ItemSlot.SignalStartDrag.Connect(SlotStartDragItem, this);
		m_ItemSlots[m_ToolSlotNumber].m_ItemSlot.SignalStartSplit.Connect(SlotStartSplitItem, this);
		m_ItemSlots[m_ToolSlotNumber].m_ItemSlot.SignalMouseUpEmptySlot.Connect(SlotMouseUpEmptySlot, this);
		m_ItemSlots[m_ToolSlotNumber].m_ItemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
		m_ItemSlots[m_ToolSlotNumber].m_ItemSlot.SetData(m_Inventory.GetItemAt(m_ToolSlotNumber));
		if (m_Inventory.GetItemAt(m_ToolSlotNumber) != undefined)
		{
			UpdateToolSlotItemInfo(m_Inventory.GetItemAt(m_ToolSlotNumber));
		}
	}
	
	public function GetDisassemblySlot():Number
	{
		return m_DisassemblySlotNumber;
	}
	
	function SlotItemAdded( inventoryId:ID32, itemPos:Number )
	{
		m_ItemSlots[itemPos].m_ItemSlot.SetData(m_Inventory.GetItemAt(itemPos));
		m_ItemSlots[itemPos].m_IsPreview = false;
		m_ItemSlots[itemPos].m_ItemSlot.SetCanDrag(true);
		m_IsDisassembling = false;
		if (itemPos == m_DisassemblySlotNumber)
		{
			m_IsDisassembling = true;
			var item:InventoryItem = m_Inventory.GetItemAt(itemPos);
			UpdateDisassemblySlotItemInfo(item);
		}
		else if (itemPos == m_ToolSlotNumber)
		{
			m_HasTool = true;
			var item:InventoryItem = m_Inventory.GetItemAt(itemPos);
			UpdateToolSlotItemInfo(item);
		}
		m_IsEmpty = false;
	}
	
	function SlotItemMoved( inventoryID:ID32, fromPos:Number, toPos:Number )
	{
	}

	function SlotItemRemoved( inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
	{
		if (itemPos == m_ToolSlotNumber)
		{
			m_ToolSlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingToolSlotInfo");
			m_HasTool = false;
		}
		else if (itemPos == m_DisassemblySlotNumber)
		{
			m_DisassemblySlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingDisassemblySlotInfo");
			m_IsDisassembling = false;
		}
		m_ItemSlots[itemPos].m_ItemSlot.Clear(); 
        
        ResetIfEmpty();
	}

	function SlotItemChanged( inventoryID:com.Utils.ID32, itemPos:Number )
	{
		SlotItemAdded(inventoryID, itemPos);
	}


	function SlotItemStatChanged( inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number  )
	{  
		if (stat == _global.Enums.Stat.e_StackSize)
		{
			var itemSlot:ItemSlot = m_ItemSlots[itemPos].m_ItemSlot;
			if (itemSlot != undefined)
			{
				itemSlot.UpdateStackSize(m_Inventory.GetItemAt(itemPos));
				return;
			}
			
		}
		SlotItemChanged(inventoryID, itemPos);
	}
	
	function UpdateToolSlotItemInfo(item:InventoryItem)
	{
		if ( item != undefined)
		{
			var toolText:String = item.m_Name + "\n" + LDBFormat.LDBGetText("ItemTypeGUI", item.m_ItemTypeGUI);
			m_ToolSlotTextInfo.htmlText = toolText;
		}
	}

	function UpdateDisassemblySlotItemInfo(item:InventoryItem)
	{
		if ( item != undefined)
		{
			var disassemblyText:String = item.m_Name + "\n" + LDBFormat.LDBGetText("ItemTypeGUI", item.m_ItemTypeGUI);
			m_DisassemblySlotTextInfo.htmlText = disassemblyText;
		}
	}
	
	function CraftingResultFeedback(result:Number, numItems:Number, feedback:String, items:Array)
	{
		ResetPreview();
		ResetIfEmpty();
		switch(result)
		{
			case _global.Enums.CraftingPhase.e_NoRecipes:
			case _global.Enums.CraftingPhase.e_Phase1CheckRelevantRecipes:
			case _global.Enums.CraftingPhase.e_Phase2CheckGridNumbers:
			case _global.Enums.CraftingPhase.e_Phase3CheckPositioning:
				SetState(STATE_CRAFTING_NOT_READY);
				break;
			case _global.Enums.CraftingPhase.e_Phase4CheckStackSizes:
				if (m_IsDisassembling)
				{
					SetState(STATE_DISASSEMBLE_NEED_TOOL);
				}
				else
				{
					SetState(STATE_CRAFTING_NEED_TOOL);
				}
				break;
			case _global.Enums.CraftingPhase.e_NoUpdate:
				break;
			case _global.Enums.CraftingPhase.e_Phase5CheckTools:
				if (feedback != undefined && feedback != "" )
				{
					m_DisassemblySlotTextInfo.htmlText = feedback
				}
				SetState(STATE_CRAFTING_SCRIPT_FAILED);
				break;
			case _global.Enums.CraftingPhase.e_LuaSuccess:
				SetState(STATE_CRAFTING_READY);
				if (items[0] != undefined)
				{
					m_ItemSlots[m_DisassemblySlotNumber].m_ItemSlot.SetData(items[0]);
					m_ItemSlots[m_DisassemblySlotNumber].m_ItemSlot.SetCanDrag(false);
					m_ItemSlots[m_DisassemblySlotNumber].m_IsPreview = true;
					UpdateDisassemblySlotItemInfo(items[0]);
				}
				break;
			case _global.Enums.CraftingPhase.e_DisassemblyPass:
				SetState(STATE_DISASSEMBLE_READY);
				for (var i:Number = 0; i < items.length; i++)
				{
					if (items[i] != undefined)
					{
						m_ItemSlots[i].m_ItemSlot.SetData(items[i]);
						m_ItemSlots[i].m_ItemSlot.SetCanDrag(false);
						m_ItemSlots[i].m_IsPreview = true;
					}
				}
				break;
			case _global.Enums.CraftingPhase.e_Disassembled:
				var character:Character = Character.GetClientCharacter();
				if (character != undefined) { character.AddEffectPackage( "sound_fxpackage_GUI_group_member_leaves.xml" ); }
				break;
			case _global.Enums.CraftingPhase.e_LuaFailed:
			case _global.Enums.CraftingPhase.e_Crafted:
			case _global.Enums.CraftingPhase.e_ClearGrid:
			case _global.Enums.CraftingPhase.e_SetData:
			default:
				break;
		}
		ResetIfEmpty()
	}
	
	function SetState(newState:Number)
	{
		switch(newState)
		{
			case CraftingSkin.STATE_EMPTY:
				m_DisassemblySlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingDisassemblySlotInfo");
				m_ToolSlotTextHeadline.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingTool");
				m_DisassemblySlotTextHeadline.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingItem");
				if (!m_HasTool)
				{
					m_ToolSlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingToolSlotInfo");
				}
				m_ArrowDown._visible = false;
				m_ArrowUp._visible = false;
				m_IsCrafting = false;
				m_AssembleButton.disabled = true;
				m_AssembleButton.label = m_AssembleText;
				m_NoneButton._visible = true;
				m_FeedbackFrame.gotoAndPlay("empty");
				m_PartsText._visible = true;
				m_AssembleDoneFrame._visible = false;
				m_DissambleDoneFrame._visible = false;
				m_ToolSlotTextInfo.textColor = 0xFFFFFF;
				m_ClearButton.disabled = true;
				
				break;
			case CraftingSkin.STATE_CRAFTING_NOT_READY:
				m_DisassemblySlotTextHeadline.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingResult");
				m_DisassemblySlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingResultSlotInfo");
				if (!m_HasTool)
				{
					m_ToolSlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingToolSlotInfoAssembly");
				}
				m_ArrowDown._visible = true;
				m_ArrowDown.gotoAndPlay("craftingNotReady");
				m_ArrowUp._visible = false;
				m_AssembleButton.disabled = true;
				m_AssembleButton.label = m_AssembleText;
				m_FeedbackFrame.gotoAndPlay("craftingNotReady");
				m_PartsText._visible = false;
				m_AssembleDoneFrame._visible = false;
				m_DissambleDoneFrame._visible = false;
				m_ToolSlotTextInfo.textColor = 0xFFFFFF;
				m_ClearButton.disabled = m_IsEmpty;
				m_IsCrafting = true;
				break;
			case CraftingSkin.STATE_CRAFTING_NEED_TOOL:
				m_ArrowDown._visible = true;
				m_ArrowDown.gotoAndPlay("craftingNeedTool");
				m_FeedbackFrame.gotoAndPlay("craftingNeedtool");
				m_ArrowUp._visible = false;
				m_AssembleButton.disabled = true;
				m_AssembleButton.label = m_AssembleText;
				m_PartsText._visible = false;
				m_IsCrafting = true;
				m_AssembleDoneFrame._visible = false;
				m_DissambleDoneFrame._visible = false;
				if (!m_HasTool)
				{
					m_ToolSlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingToolMandatory");
				}
				m_ToolSlotTextInfo.textColor = 0xFF9932;
				m_ClearButton.disabled = false;
				
				break;
			case CraftingSkin.STATE_CRAFTING_SCRIPT_FAILED:
				m_ArrowDown._visible = true;
				m_ArrowUp._visible = false;
				m_AssembleButton.disabled = true;
				m_AssembleButton.label = m_AssembleText;
				m_ToolSlotTextInfo.textColor = 0xFFFFFF;
				if (m_HasTool)
				{
					m_FeedbackFrame.gotoAndPlay("craftingReadyWithTool");
				}
				else
				{
					m_ToolSlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingToolSlotInfo");
					m_FeedbackFrame.gotoAndPlay("craftingReadyNoTool");
				}
				m_ArrowDown.gotoAndPlay("craftingReady");
				m_AssembleDoneFrame._visible = false;
				m_DissambleDoneFrame._visible = false;
				m_PartsText._visible = false;
				m_IsCrafting = true;
				m_ClearButton.disabled = false;
				break;
			case CraftingSkin.STATE_CRAFTING_READY:
				m_ArrowDown._visible = true;
				m_ArrowUp._visible = false;
				m_AssembleButton.disabled = false;
				m_AssembleButton.label = m_AssembleText;
				m_ToolSlotTextInfo.textColor = 0xFFFFFF;
				if (m_HasTool)
				{
					m_FeedbackFrame.gotoAndPlay("craftingReadyWithTool");
				}
				else
				{
					m_ToolSlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "CraftingToolSlotInfo");
					m_FeedbackFrame.gotoAndPlay("craftingReadyNoTool");
				}
				m_ArrowDown.gotoAndPlay("craftingReady");
				m_AssembleDoneFrame._visible = true;
				m_DissambleDoneFrame._visible = false;
				m_PartsText._visible = false;
				m_IsCrafting = true;
				m_ClearButton.disabled = false;
				break;
			case CraftingSkin.STATE_DISASSEMBLE_NEED_TOOL:
				m_ArrowDown._visible = false;
				m_ArrowUp._visible = true;
				m_ArrowUp.gotoAndPlay("disassembleNeedTool");
				m_IsCrafting = false;
				m_AssembleButton.label = m_DisassembleText;
				m_AssembleButton.disabled = true;
				m_FeedbackFrame.gotoAndPlay("disassembleNeedTool");
				m_PartsText._visible = false;
				m_AssembleDoneFrame._visible = false;
				m_DissambleDoneFrame._visible = false;
				m_ClearButton.disabled = false;
				break;
			case CraftingSkin.STATE_DISASSEMBLE_READY:
				m_ArrowDown._visible = false;
				m_ArrowUp._visible = true;
				m_ArrowUp.gotoAndPlay("disassembleReady");
				m_IsCrafting = false;
				m_AssembleButton.label = m_DisassembleText;
				m_AssembleButton.disabled = false;
				m_PartsText._visible = false;
				m_AssembleDoneFrame._visible = false;
				m_DissambleDoneFrame._visible = true;
				m_ToolSlotTextInfo.textColor = 0xFFFFFF;
				m_ClearButton.disabled = false;
				
				if (m_HasTool)
				{
					m_FeedbackFrame.gotoAndPlay("disassembleReadyWithTool");
				}
				else
				{
					m_ToolSlotTextInfo.htmlText = LDBFormat.LDBGetText("GenericGUI", "DisassemblyToolOptional");
					m_FeedbackFrame.gotoAndPlay("disassembleReadyNoTool");
				}
				
				break;
			default:
				m_FeedbackFrame.gotoAndPlay("empty");
				break;
		}
	}
}