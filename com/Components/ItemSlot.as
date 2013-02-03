import com.Utils.Colors;
import mx.utils.Delegate;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import flash.geom.Point;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.Utils.ID32;
import com.Utils.Signal;
import com.GameInterface.Tooltip.*;
import com.Utils.DragObject;
import com.Components.ItemComponent;
import com.Utils.LDBFormat;

class com.Components.ItemSlot 
{
    private var m_ItemData:InventoryItem;
    private var m_SlotID:Number;
    private var m_InventoryID:ID32;
    private var m_SlotMC:MovieClip;
	
	private var m_SupportsFiltering:Boolean;
	private var m_ShowCanUse:Boolean;
	private var m_CanDrag:Boolean;
    private var m_IsACGItem:Boolean;
    private var m_Icon:MovieClip;
    
    private var m_HitPos:Point;
	public var m_WasHit:Boolean;
    public var m_DragType:String;
    public var m_IsDragging;
    
    public var m_IconTemplateName:String;
    public var m_IconScale:Number;
    
    private var m_Tooltip:TooltipInterface;
    private var m_RightClickMenu:MovieClip;
	
	public var SignalMouseDown:Signal;
	public var SignalMouseUp:Signal;
	public var SignalMouseDownEmptySlot:Signal;
	public var SignalMouseUpEmptySlot:Signal;
	public var SignalUse:Signal;
	public var SignalDelete:Signal;
	public var SignalStartDrag:Signal;
    public var SignalStartSplit:Signal;
	
	private var m_HasReactedOnMouseDown:Boolean;
    
    public function ItemSlot( inventoryID:com.Utils.ID32,  slotID:Number, slotMC:MovieClip, iconTemplateName:String )
    {
		m_IsDragging = false;
		m_WasHit = false;
		m_DragType = "item";
        m_SlotID = slotID;
        m_InventoryID = inventoryID;
        m_SlotMC = slotMC;
        m_HitPos = new Point();
        m_Tooltip = undefined;
        m_SlotMC.onMousePress = Delegate.create(this, onMousePress);
        m_SlotMC.onMouseRelease = Delegate.create(this, onMouseRelease);
        m_RightClickMenu = undefined;
		SignalMouseDown = new Signal;
		SignalMouseUp = new Signal;
        SignalMouseDownEmptySlot = new Signal;
        SignalMouseUpEmptySlot = new Signal;
		SignalUse = new Signal;
		SignalDelete = new Signal;
		SignalStartDrag = new Signal;
        SignalStartSplit = new Signal;
        m_IconTemplateName = (iconTemplateName == undefined) ? "Item" : iconTemplateName;
        m_IconScale = 100;
        m_IsACGItem = false;
		m_CanDrag = true;
		m_SupportsFiltering = false;
		m_ShowCanUse = true;
		m_HasReactedOnMouseDown = false;
    }
    
    function onMousePress(buttonIdx:Number, clickCount:Number)
    {
        if (HasItem())
        {
            if (buttonIdx == 1)
			{
				if(clickCount == 1)
				{
                    m_WasHit = true;
                    m_HitPos.x = _root._xmouse;
                    m_HitPos.y = _root._ymouse;
				}
				else if (clickCount == 2)
				{
					m_HasReactedOnMouseDown = true;
				}
			}
		
			
			SignalMouseDown.Emit(this, buttonIdx, clickCount);
			
		}
        else
        {
            SignalMouseDownEmptySlot.Emit(this, buttonIdx);
        }
        
	}
    
    function onMouseRelease(buttonIdx:Number)
    {
        if (HasItem())
        {
            if (buttonIdx == 1 && !Key.isDown(Key.CONTROL))
            {
                if (Key.isDown(Key.SHIFT) && m_ItemData.m_StackSize > 1)
                {
                    StartSplittingItem();
                }
                else if(m_WasHit && !m_HasReactedOnMouseDown)
                {
                    StartDraggingItem(m_ItemData.m_StackSize);
                }
            }
			else if (buttonIdx == 2 && DragObject.GetCurrentDragObject() == undefined)
            {
                if (Key.isDown(Key.CONTROL))
                {
                    var inv:Inventory  = new Inventory(m_InventoryID);
                    inv.MakeItemLink(m_ItemData.m_InventoryPos);
                }
            }
			SignalMouseUp.Emit(this, buttonIdx);
			m_HasReactedOnMouseDown = false;
        }
        else
        {
            SignalMouseUpEmptySlot.Emit(this, buttonIdx);
        }
    }
    
    function CloseRightClickMenu():Void
    {
        m_RightClickMenu.removeMovieClip();
        m_RightClickMenu = undefined;
    }
    
	public function SetFilteringSupport(isSupportingFilters:Boolean)
	{
		m_SupportsFiltering = isSupportingFilters;
	}
	
    function EquipItemInBelt()
    {
        UseItem();
    }
    
    function EquipItem()
    {
        UseItem();
    }
    
    function DeleteItem()
    {
        if (m_ItemData != undefined && m_ItemData.m_Deleteable)
        {
            SignalDelete.Emit(this);
        }
    }
    
    function ExamineItem()
    {
        var tooltipData:TooltipData = GetTooltipData();
        var tooltip:TooltipInterface = TooltipManager.GetInstance().ShowTooltip( null, TooltipInterface.e_OrientationHorizontal, 0, tooltipData );
        tooltip.MakeFloating();
    }
    
    function UseItem()
    {
        SignalUse.Emit(this);
    }
	
	public function SetCanDrag(canDrag:Boolean)
	{
		m_CanDrag = canDrag;
	}
	
	public function SetShowCanUse(show:Boolean)
	{
		m_ShowCanUse = show;
	}
    
    public function SetData(newData:InventoryItem)
    {
        Clear();
        m_ItemData = newData;
        
        if (m_ItemData.m_ACGItem != undefined)
        {
            m_IsACGItem = true;
        }
		else
		{
			m_IsACGItem = false;
		}
        if( m_ItemData.m_Icon != undefined && m_ItemData.m_Icon != "" )
		{
            m_Icon = CreateIcon( );
            m_Icon.onPress = function() { }; //This is needed as if you dont have it, no clicks are registered and you click through flash
			if (newData.m_CooldownEnd != undefined && newData.m_CooldownEnd > 0 && (newData.m_CooldownEnd - com.GameInterface.Utils.GetGameTime()) > 0)
			{
				SetCooldown(newData.m_CooldownEnd - com.GameInterface.Utils.GetGameTime());
			}
		}
		UpdateFilter();
    }
    
    public function GetData():InventoryItem
    {
        return m_ItemData;
    }
    
    public function UpdateStackSize(itemData:InventoryItem)
    {
        m_Icon.SetStackSize(itemData.m_StackSize);
        m_ItemData = itemData;
    }
	
    public function SetCooldown( seconds:Number )
    {
		m_Icon.SetCooldown(seconds, true )
    }
    
	public function RemoveCooldown()
    {
		m_Icon.RemoveCooldown();
    }
    
    private function OnMouseUp() :Void
	{
        m_WasHit = false;
		m_IsDragging = false;
	}

    private function OnMouseDown() : Void
    {
        if(m_RightClickMenu != undefined && !m_RightClickMenu.hitTest(_root._xmouse, _root._ymouse, false))
        {
            CloseRightClickMenu();
        }
    }
    
    public function HasItem():Boolean
    {
        return m_ItemData != undefined;
    }
	
	public function IsLocked():Boolean
	{
		return m_ItemData.m_Locked;
	}
    
    public function GetTooltipData():TooltipData
    {
        var tooltipData:TooltipData;
        if (m_IsACGItem)
        {
            tooltipData = TooltipDataProvider.GetACGItemTooltip(m_ItemData.m_ACGItem);
        }
        else
        {
            var inventorySlot:Number = (m_ItemData)?m_ItemData.m_InventoryPos : m_SlotID;
            tooltipData = TooltipDataProvider.GetInventoryItemTooltip( m_InventoryID, inventorySlot );
        }
        return tooltipData;
    }

    public function OpenTooltip() : Void
    {
        if (m_Tooltip == undefined)
        {
            var tooltipData:TooltipData = GetTooltipData();
            
			var equippedItems:Array = [];
			if (m_InventoryID.GetType() != _global.Enums.InvType.e_Type_GC_WeaponContainer)
			{
				for ( var i:Number = 0 ; i < tooltipData.m_CurrentlyEquippedItems.length ; ++i )
				{
					var equippedData:TooltipData;
					if (m_IsACGItem)
					{
						equippedData =  TooltipDataProvider.GetInventoryItemTooltipCompareACGItem( new com.Utils.ID32( _global.Enums.InvType.e_Type_GC_WeaponContainer, 0 ), 
											tooltipData.m_CurrentlyEquippedItems[i], m_ItemData.m_ACGItem);
					}
					else
					{
						equippedData =  TooltipDataProvider.GetInventoryItemTooltipCompareInventoryItem( new com.Utils.ID32( _global.Enums.InvType.e_Type_GC_WeaponContainer, 0 ), 
											tooltipData.m_CurrentlyEquippedItems[i], m_InventoryID, m_SlotID);
					}
					equippedData.m_IsEquipped = true;
					equippedItems.push( equippedData);
				}
			}
			
            m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_SlotMC, TooltipInterface.e_OrientationHorizontal, -1, tooltipData, equippedItems );
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
    
    private function OnMouseMove() : Void
    {
        if (Mouse["IsMouseOver"](m_SlotMC) && !m_IsDragging )
        {
            OpenTooltip();
        }
        else if (m_Tooltip != undefined)
        {
            CloseTooltip();
        }
		
        var mousePos:Point = new Point( _root._xmouse, _root._ymouse );
        if ( m_WasHit && HasItem() && Point.distance( m_HitPos, mousePos ) > 3 )
        {
			if (Key.isDown(Key.SHIFT) && m_ItemData.m_StackSize > 1)
			{
				StartSplittingItem();
			}
			else
			{
				StartDraggingItem(m_ItemData.m_StackSize)
			}
            m_IsDragging = true;
            m_WasHit = false;
        }
    }
    
    private function StartDraggingItem(stackSize:Number)
    {
        if (DragObject.GetCurrentDragObject() == undefined && !m_ItemData.m_Locked && m_CanDrag)
        {
            SignalStartDrag.Emit(this, stackSize);
        }
    }
    
    private function StartSplittingItem()
    {
		if (m_ItemData.m_Unique)
		{
			var fifoMessage:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "CantSplitLimitedItem"), m_ItemData.m_Name)
			com.GameInterface.Chat.SignalShowFIFOMessage.Emit(fifoMessage, 0)
			return;
		}
        SignalStartSplit.Emit(this);
    }
    
    private function SlotItemDroppedOnDesktop()
    {   
        DeleteItem();
    }
    
    public function CreateIcon( ) : MovieClip
    {
        var icon:ItemComponent = ItemComponent(m_SlotMC.attachMovie( m_IconTemplateName, "item", m_SlotMC.getNextHighestDepth(), { ref:this } ));
		icon.SetShowCanUse(m_ShowCanUse);
        icon.SetData( m_ItemData );
        icon.SetStackSize(m_ItemData.m_StackSize);        
        icon.SetLocked(m_ItemData.m_Locked);
        
        icon.onMouseDown = Delegate.create( this, OnMouseDown );
        icon.onMouseUp   = Delegate.create( this, OnMouseUp );
        icon.onMouseMove = Delegate.create( this, OnMouseMove );   
   
        return icon;
    }
	
	/// clears the class intance of all variables that needs to be nulled when the class is reset
	/// @return void
	public function Clear() : Void
	{
        if (m_Tooltip != undefined)
        {
            if ( !m_Tooltip.IsFloating() )
            {
                m_Tooltip.Close();
            }
            m_Tooltip = undefined;
        }
        if (m_RightClickMenu != undefined)
        {
            m_RightClickMenu.removeMovieClip();
        }
        
		m_ItemData = undefined;
		
		RemoveIcon();
	}
	
	/// when an ability is removed from the slot, the ability is cleared from the AbilitySlot
	private function RemoveIcon() : Void
	{
        if (m_Icon != undefined)
        {
			m_Icon.UnloadIcon();
            m_Icon.removeMovieClip();
			m_Icon = undefined;
        }
	}
    
    public function HitTest(mouseX:Number, mouseY:Number):Boolean
    {
        //Cannot use hitTest for some weird reason.. For some itemslots it always returns true...
        var boundsRect:Object = m_SlotMC.getBounds();
        var rectMin:Point = new Point( boundsRect.xMin, boundsRect.yMin);
        var rectMax:Point = new Point( boundsRect.xMax, boundsRect.yMax);
        
        m_SlotMC.localToGlobal( rectMin );
        m_SlotMC.localToGlobal( rectMax );
        return mouseX >= rectMin.x && mouseX <= rectMax.x && mouseY >= rectMin.y && mouseY <= rectMax.y;
    }
	
	public function UpdateFilter()
	{
		if (m_SupportsFiltering)
		{
			if (m_ItemData.m_InFilter)
			{
				m_Icon._alpha = m_Icon.GetAlpha();
			}
			else
			{
				m_Icon._alpha = 10;
			}
		}
	}
    
    public function GetSlotID():Number
    {
        return m_SlotID;
    }
    
    public function SetSlotID(newSlot:Number)
    {
        m_SlotID = newSlot;
    }
    
    public function GetSlotMC():MovieClip
    {
        return m_SlotMC;
    }
	
	public function SetGlow(glow:Boolean)
	{
		m_Icon.Glow( glow );
	}
	
	public function SetThrottle(throttle:Boolean)
	{
		m_Icon.SetThrottle( throttle );
	}
    
    public function SetAlpha(alpha:Number)
    {
        m_Icon.SetAlpha(alpha);
    }
       
    public function SetPos(x:Number, y:Number)
    {
        m_SlotMC._x = x;
        m_SlotMC._y = y;
    }
    
    public function SetDragItemType(dragType:String)
    {
        m_DragType = dragType;   
    }
	
	public function GetDragItemType() : String
	{
		return m_DragType;
	}    
	
    public function GetIcon() : MovieClip
    {
        return m_Icon;
    }
    

	public function GetIconTemplateName() : String
	{
		return m_IconTemplateName;
	}
	
	public function GetInventoryID() : ID32
	{
		return m_InventoryID;
	}
	
	public function GetHitPos() : Point
	{
		return m_HitPos;
	}
}
