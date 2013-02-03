import flash.geom.Point;
import com.Utils.Rect;
import flash.geom.Rectangle;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.Utils.ID32;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import com.Components.ItemSlot;
import flash.filters.GlowFilter;

class GUI.Inventory.IconBox
{
    //Constants
    public static var EXPAND_ITEM_BUTTON_SPACE:Number = 20;
    
    private static var BOTTOM_BAR_HEIGHT:Number = 44;
    private static var VISIBILITY_OFF:Number = 0;
    private static var VISIBILITY_ON:Number = 1;
    private static var VISIBILITY_PARTIAL:Number = 2;
    private static var WINDOW_CORNER_RADIUS:Number = 10;
    
    private var m_Visible:Boolean;
    private var m_WindowMC:MovieClip;
    private var m_Grid:MovieClip;
    private var m_BottomBar:MovieClip;
    private var m_BoxID:Number;
    
    private var m_IconSize:Number;
    private var m_IconPaddingX:Number;
    private var m_IconPaddingY:Number;
    private var m_BoxPadding:Rect;
    private var m_BottomBarHeight:Number;
    private var m_TopBarHeight:Number;
    
    private var m_CanRename:Boolean;
    private var m_BoxHeight;
    private var m_BoxWidth;
    
    private var m_NumRows;
    private var m_NumColumns;
    private var m_NumItems;
    private var m_MinNumRows:Number;
    private var m_MinNumColumns:Number;
	
    private var m_Name:String;
    private var m_IsPinned:Boolean;
    private var m_IsGlowing:Boolean;
    private var m_HasGrid:Boolean;
    private var m_HasBottomBar:Boolean;
    private var m_WindowHasFullVisibility:Boolean;
    private var m_PinnedBackgroundOpacity:Number;
    private var m_LockPositionWhenPinned:Boolean;
    private var m_ItemSlots:Array;
    
    private var m_InventoryId:ID32;
    
    public var SignalStartDragging:Signal;
	public var SignalDeleteItem:Signal;
	public var SignalUseItem:Signal;
	public var SignalStartDragItem:Signal;
    public var SignalStartSplitItem:Signal;
	public var SignalMouseDownItem:Signal;
	public var SignalMouseUpItem:Signal;
    public var SignalMouseUpEmptySlot:Signal;
    public var SignalMouseDownEmptySlot:Signal;
    
    public function IconBox(boxID:Number, inventoryId:ID32, windowMC:MovieClip, numRows:Number, numColumns:Number)
    {
        m_BoxID = boxID;
        m_WindowMC = windowMC;
        m_InventoryId = inventoryId;
        m_Name = "";
                
        m_IconSize = 40;
        m_IconPaddingX = 10;
        m_IconPaddingY = 10;
        m_BoxPadding = new Rect(12, 12, 12, 12);
        m_TopBarHeight = 30;
        m_BottomBarHeight = 0;
		
		m_MinNumRows = 1;
		m_MinNumColumns = 1;
		
        m_NumColumns = numColumns;
        m_NumRows = numRows;
        
        m_NumItems = 0;
        
        m_PinnedBackgroundOpacity = 50;
        m_LockPositionWhenPinned = false;
        
        m_ItemSlots = new Array();
        
        for (var i:Number = 0; i < m_NumColumns; i++)
        {
            m_ItemSlots[i] = new Array();
        }
        
        m_IsPinned = false;
        m_CanRename = true;
        m_Visible = true;
        m_HasGrid = false;
        m_HasBottomBar = false;
        m_WindowHasFullVisibility = true;
        
        SignalStartDragging = new Signal();
        
        SignalUseItem = new Signal();
        SignalDeleteItem = new Signal();
		SignalMouseDownItem = new Signal();
		SignalMouseUpItem = new Signal();
		SignalStartDragItem = new Signal();
        SignalStartSplitItem = new Signal();
        SignalMouseDownEmptySlot = new Signal();
        SignalMouseUpEmptySlot = new Signal();

        m_WindowMC.attachMovie("UnpinButton", "i_PinButton", m_WindowMC.getNextHighestDepth());
        m_WindowMC.i_PinButton.onPress = Delegate.create(this, SlotPinPress);
        m_WindowMC.i_PinButton.onRollOver = SlotMouseOverButton;
        m_WindowMC.i_PinButton.onRollOut = SlotMouseOutButton;
        
        m_WindowMC.i_FrameName.onMousePress = Delegate.create(this, SlotRenameBox);
        m_WindowMC.i_FrameName.onPress = Delegate.create(this, SlotStartDrag);
		m_WindowMC.i_FrameName.m_Text.maxChars = 50;
		
        windowMC.i_Background.onPress = function() { };
        windowMC.i_Background.onMousePress = Delegate.create(this, SlotBackgroundPressed);
        windowMC.i_Background.onMouseRelease = Delegate.create(this, SlotBackgroundReleased);
        windowMC.i_TopBar.onPress = Delegate.create(this, SlotTopPressed);
    }
    
    private function SlotBackgroundPressed(buttonIdx:Number)
    {
        if (buttonIdx == 1)
        {
            SlotStartDrag();
        }
        if (GetItemAt(_root._xmouse, _root._ymouse) == undefined)
        {
            SlotMouseDownEmptySlot(GetGridPositionAt(_root._xmouse, _root._ymouse), buttonIdx);
        }
    }
    
    private function SlotBackgroundReleased(buttonIdx:Number)
    {
        if (GetItemAt(_root._xmouse, _root._ymouse) == undefined)
        {
            SlotMouseUpEmptySlot(GetGridPositionAt(_root._xmouse, _root._ymouse),buttonIdx);
        }
    }
    
    private function SlotMouseDownEmptySlot(gridPos:Point, buttonIdx:Number)
    {
        SignalMouseDownEmptySlot.Emit(this, gridPos, buttonIdx);
    }
    
    private function SlotMouseUpEmptySlot(gridPos:Point, buttonIdx:Number)
    {
        SignalMouseUpEmptySlot.Emit(this, gridPos, buttonIdx);
    }
	
	private function SlotStartDrag()
	{
        if (!m_LockPositionWhenPinned || !m_IsPinned)
        {
            SignalStartDragging.Emit(this);            
        }
	}
    
    private function SlotTopPressed()
    {
        SlotStartDrag();
    }
    
    private function SlotMouseOverButton()
    {
        MovieClip(this).gotoAndPlay("over");
    }
    
    private function SlotMouseOutButton()
    {
        MovieClip(this).gotoAndPlay("out");
    }
    
    public function CloseAllTooltips()
    {
    }
       
    private function SlotPinPress()
    {
        SetPinned(!m_IsPinned);
    }
    
    public function GetWindowMC():MovieClip
    {
        return m_WindowMC;
    }
    
    public function GetNumItems():Number
    {
        return m_NumItems;
    }
    
    public function GetName():String
    {
        if (m_Name == "")
        {
            m_Name = (m_WindowMC.i_FrameName.m_Text.text) ? m_WindowMC.i_FrameName.m_Text.text : " ";
        }
        return m_Name;
    }
    
    public function SetName(name:String)
    {
        m_WindowMC.i_FrameName.m_Text.text = (name == "") ? " " : name;
        m_Name = name;
    }
    
    public function SetNumTotalItems(numItems:Number, numMaxItems:Number)
    {
    }
    
    public function IsPinned():Boolean
    {
        return m_IsPinned;
    }
    
    public function SetPinned(pin:Boolean)
    {
        m_IsPinned = pin;

        if (m_WindowMC.i_PinButton)
        {
            m_WindowMC.i_PinButton.removeMovieClip()
            var linkageId:String = (m_IsPinned) ? "PinButton" : "UnpinButton";
            m_WindowMC.attachMovie(linkageId, "i_PinButton", m_WindowMC.getNextHighestDepth());
            m_WindowMC.i_PinButton._x = m_BoxWidth -  m_WindowMC.i_PinButton._width;
            m_WindowMC.i_PinButton.onPress = Delegate.create(this, SlotPinPress);
            m_WindowMC.i_PinButton.onRollOver = SlotMouseOverButton;
            m_WindowMC.i_PinButton.onRollOut = SlotMouseOutButton;
        }
        else
        {
            com.GameInterface.Log.Error("IconBox:SetPinned Failed retrieve and remove the i_Pinbutton movieclip, m_WindowMC.i_PinButton = "+m_WindowMC.i_PinButton); 
        }
        
        UpdateVisibility();
    }
    
    public function IsGlowing():Boolean
    {
        return m_IsGlowing;
    }
    
    public function SetGlowing(glow:Boolean)
    {
        m_IsGlowing = glow;
        
        if (m_IsGlowing)
        {
            m_WindowMC.filters = [new GlowFilter(0x6699FF, 0.1, 10, 10, 2, 3, false, false)];
        }
        else
        {
            m_WindowMC.filters = [];
        }
    }
    
    public function IsVisible():Boolean
    {
        return m_WindowMC._visible;
    }

    public function GetNumColumns():Number
    {
        return m_NumColumns;
    }
	
    public function GetNumRows():Number
    {
        return m_NumRows;
    }
    
    public function GetNumSlots()
    {
        return m_NumColumns * m_NumRows
    }
        
    private function CalculateSlotPosX(val:Number)
    {
        return val * (m_IconSize + m_IconPaddingX) + m_BoxPadding.left;
    }
    
    private function CalculateSlotPosY(val:Number)
    {
        return val * (m_IconSize + m_IconPaddingY) + m_BoxPadding.top;
    }
        
    public function RelayoutSlots()
    {
        for (var i:Number = 0; i < m_NumColumns; i++)
        {
            for (var j:Number = 0; j < m_NumRows; j++)
            {
                if (m_ItemSlots[i][j] != undefined)
                {
                    var mc:MovieClip = m_ItemSlots[i][j].GetSlotMC()
                    mc._x = CalculateSlotPosX(i);
                    mc._y = CalculateSlotPosY(j);
                    mc._visible = true;
                    mc.hitTestDisable = false;
                }
            }
        }
    }

    public function GetGridPositionAt(x:Number, y:Number):Point
    {
        var p:Point = new Point(x, y);
        
        m_WindowMC.i_Background.globalToLocal(p);
        
        var dstX:Number = p.x;
        var dstY:Number = p.y;
        
        dstX = Math.floor(dstX / (m_IconSize + m_IconPaddingX));
        dstY= Math.floor(dstY / (m_IconSize + m_IconPaddingY));

        dstX = Math.min(dstX, m_NumColumns - 1);
        dstY = Math.min(dstY, m_NumRows - 1);
        
        return new Point(dstX, dstY);
    }
    
    public function GetFirstFreeGridPosition()
    {
        for (var i:Number = 0; i < m_NumRows; i++)
        {
            for (var j:Number = 0; j < m_NumColumns; j++)
            {
                if (m_ItemSlots[j][i] == undefined)
                {
                    return new Point(j, i);
                }
            }
        }

        return new Point(0, m_NumRows);
    }
    
    public function GetItemAtGridPosition(gridPos:Point)
    {
        return m_ItemSlots[gridPos.x][gridPos.y];
    }
	
	public function IsValidGridPosition(gridPos:Point) : Boolean
	{
		return gridPos.x >= 0 && gridPos.x < m_NumColumns && gridPos.y >= 0 && gridPos.y < m_NumRows; 
	}
        
    public function GetItemAt(dstX:Number, dstY:Number):ItemSlot
    {
        var gridPosition:Point = GetGridPositionAt(dstX, dstY);
        var itemSlot:ItemSlot = m_ItemSlots[gridPosition.x][gridPosition.y];
        
        if (itemSlot != undefined && itemSlot.GetData() != undefined)
        {
            return itemSlot;
        }
        
        return undefined;
    }  

    public function HitTest(x:Number, y:Number)
    {        
         return (m_Visible || m_IsPinned) && (x >= m_WindowMC._x && y >= m_WindowMC._y && x <= m_WindowMC._x + m_BoxWidth * (m_WindowMC._xscale/100) && y <= m_WindowMC._y + m_BoxHeight * (m_WindowMC._yscale/100));
    }
    
    public function HitTestTopBar(x:Number, y:Number)
    {
        return m_Visible && (x >= m_WindowMC._x && y >= m_WindowMC._y && x <= m_WindowMC._x + m_BoxWidth * (m_WindowMC._xscale/100) && y <= m_WindowMC._y + m_TopBarHeight * (m_WindowMC._yscale/100));
    }
    
    public function GetBoxID() :Number
    {
        return m_BoxID;
    }
    
    public function GetWidth()
    {
        return m_BoxWidth;
    }
    
    public function GetHeight()
    {
        return m_BoxHeight;
    }
    
    public function SetPos(x:Number, y:Number)
    {
        m_WindowMC._x = x;
        m_WindowMC._y = y ;
    }

    public function GetPos():Point
    {
        return new Point(m_WindowMC._x, m_WindowMC._y);
    }

    function GetHorizontalSizeOfSlots(numSlots:Number)
    {
        return (m_BoxPadding.left + m_BoxPadding.right) + ((numSlots - 1) * m_IconPaddingX) + (numSlots * m_IconSize);
    }
    
    function GetVerticalSizeOfSlots(numSlots:Number)
    {
        return (m_BoxPadding.top + m_BoxPadding.bottom) + ((numSlots - 1) * m_IconPaddingY) + (numSlots * m_IconSize);
    }
    
    function GetNumHorizontalSlotsFromSize(width:Number)
    {
        return Math.max(m_MinNumColumns,Math.floor(width / (m_IconSize + m_IconPaddingX)));
    }
    
    function GetNumVerticalSlotsFromSize(width:Number)
    {
        return Math.max(m_MinNumRows,Math.floor(width / (m_IconSize + m_IconPaddingY)));
    }

    private function UpdateBoxContents(width:Number, height:Number)
    {
        com.GameInterface.GUIUtils.Draw.DrawRectangle(m_WindowMC.i_TopBar, 0, 0, width, m_TopBarHeight, 0x000000, 90, [WINDOW_CORNER_RADIUS, WINDOW_CORNER_RADIUS, 0, 0]);        
        com.GameInterface.GUIUtils.Draw.DrawRectangle(m_WindowMC.i_Background, 0, 0, width, height + 2, 0x000000, 70, [0, 0, WINDOW_CORNER_RADIUS, WINDOW_CORNER_RADIUS]);

        m_BoxWidth = width;
        m_BoxHeight = height + m_WindowMC.i_TopBar._height;

        m_WindowMC.i_PinButton._x = 0;
        m_WindowMC.i_PinButton._y = -1;
    }
    
    /// writes the box only if the state is pinned and the inventory is hidden. The box is only the frame around the icons
    /// @param width:Number - witdh of the box to draw
    /// @param height:Number - height of the box to draw
    /// @return Void
    private function UpdatePinnedBoxContents(width:Number, height:Number) : Void
    {
        com.GameInterface.GUIUtils.Draw.DrawRectangle(m_WindowMC.i_Background, 0, 0, width , height, 0x000000, m_PinnedBackgroundOpacity, [WINDOW_CORNER_RADIUS, WINDOW_CORNER_RADIUS, WINDOW_CORNER_RADIUS, WINDOW_CORNER_RADIUS]);
        m_BoxWidth = width;
        m_BoxHeight = height;
        
        UpdateDropShadow(true);
    }
    
    //Update Drop Shadow
    private function UpdateDropShadow(displayingAsPinned:Boolean):Void
    {
        m_WindowMC.i_DropShadow._visible = !displayingAsPinned;
        m_WindowMC.i_DropShadow._x = m_WindowMC.i_DropShadow._y = -15.5
        m_WindowMC.i_DropShadow._width = m_BoxWidth + 31;
        m_WindowMC.i_DropShadow._height = m_BoxHeight + 31;
    }
    
    public function SetOnScreenVisibility(stateVisible:Boolean)
    {
        m_Visible = stateVisible;
        
        UpdateVisibility()
    }
    
    private function UpdateVisibility()
    {
        var visibility:Number;
        
        if (!m_Visible)
        {
            visibility = m_IsPinned ? VISIBILITY_PARTIAL : VISIBILITY_OFF;
        }
        else
        {
            visibility = VISIBILITY_ON;
        }

        if (visibility == VISIBILITY_PARTIAL)
        {
            m_WindowMC._visible = true;
            SetWindowHasFullVisibility(false);
            var realWidth = GetHorizontalSizeOfSlots(m_NumColumns);
            var realHeight = GetVerticalSizeOfSlots(m_NumRows);
            UpdatePinnedBoxContents(realWidth, realHeight);
        }
        else if (visibility == VISIBILITY_ON)
        {
            m_WindowMC._visible = true;
            SetWindowHasFullVisibility(true);
            var realWidth = GetHorizontalSizeOfSlots(m_NumColumns);
            var realHeight = GetVerticalSizeOfSlots(m_NumRows);
            
            UpdateBoxContents(realWidth, realHeight + GetBottomBarHeight());
        }
        else
        {
            m_WindowMC._visible = false;
        }
        
        if (visibility != VISIBILITY_ON)
        {
            CloseAllTooltips()
        }
    }

    private function SetWindowHasFullVisibility(fullVisibility:Boolean)
    {
        m_WindowHasFullVisibility = fullVisibility;
        
        if (m_WindowMC.i_PinButton)
        {
            m_WindowMC.i_PinButton._visible = fullVisibility;
        }
        
        if (m_WindowMC.i_TopBar)
        {
            m_WindowMC.i_TopBar._visible = fullVisibility;  
        }
        
        if (m_WindowMC.i_FrameName)
        {
            m_WindowMC.i_FrameName._visible = fullVisibility;
        }
        
        if (m_BottomBar)
        {
            m_BottomBar._visible = fullVisibility;
        }
    }
    
    public function RemoveItem(itemID:Number):Boolean
    {
        return false;
    }
        
    ///Resetting the itemdata of the item in the itemID slot
    public function ChangeItem(itemID:Number, itemData:Object)
    {
        var gridPosition:Point = GetGridPositionFromSlotID(itemID);
        if (gridPosition != undefined)
        {
            m_ItemSlots[gridPosition.x][gridPosition.y].SetData(itemData);
            return true;
        }
    }

    //Add Shortcut Label And Animation
    public function AddShortcutLabelAndAnimation(inventoryPosition:Number, label:String):Void
    {
        var targetClip:MovieClip = GetMovieClipFromInventoryPosition(inventoryPosition);

        if (targetClip.m_HotkeyLabel)
        {
            targetClip.m_HotkeyLabel.removeMovieClip();
        }
        
        targetClip.attachMovie("HotkeyLabel", "m_HotkeyLabel", targetClip.getNextHighestDepth());
        targetClip.m_HotkeyLabel.m_HotkeyText.text = label;
        
        if (!targetClip.m_UseAnimation)
        {
            targetClip.attachMovie("UseAnimation", "m_UseAnimation", targetClip.getNextHighestDepth());
            targetClip.m_UseAnimation._width = targetClip.i_Background._width;
            targetClip.m_UseAnimation._height = targetClip.i_Background._height;            
        }
    }
    
    //Remove Shortcut Label And Animation
    public function RemoveShortcutLabelAndAnimation(inventoryPosition:Number):Void
    {
        var targetClip:MovieClip = GetMovieClipFromInventoryPosition(inventoryPosition);

        if (targetClip.m_HotkeyLabel)
        {
            targetClip.m_HotkeyLabel.removeMovieClip();            
        }
        
        if (targetClip.m_UseAnimation)
        {
            targetClip.m_UseAnimation.removeMovieClip();            
        }
    }
    
    //Get MovieClip From Inventory Position
    public function GetMovieClipFromInventoryPosition(inventoryPosition:Number):MovieClip
    {
        for (var i:Number = 0; i < m_NumColumns; i++)
        {
            for (var j:Number = 0; j < m_NumRows; j++)
            {
                if (m_ItemSlots[i][j] != undefined && m_ItemSlots[i][j].GetData().m_InventoryPos == inventoryPosition)
                {
                    return m_ItemSlots[i][j].GetSlotMC();
                }
            }
        }
        
        return undefined;
    }
    
    //Get Grid Position From Slot ID
    public function GetGridPositionFromSlotID(itemID:Number):Point
    {
        for (var i:Number = 0; i < m_NumColumns; i++)
        {
            for (var j:Number = 0; j < m_NumRows; j++)
            {
                if (m_ItemSlots[i][j] != undefined && m_ItemSlots[i][j].GetSlotID() == itemID)
                {
                    return new Point(i, j);
                }
            }
        }
        
        return undefined;
    }
    
    //Animate Shortcut
    public function AnimateShortcut(inventoryPosition:Number):Void
    {
        var targetClip:MovieClip = GetMovieClipFromInventoryPosition(inventoryPosition);
        
        if (targetClip && targetClip.m_UseAnimation)
        {
            targetClip.m_UseAnimation.gotoAndPlay("Start");            
        }
    }
      
    private function ResizeBox(isDefaultWindow:Boolean)
    {
        var width:Number = m_WindowMC._xmouse;
        var height:Number = m_WindowMC._ymouse - m_TopBarHeight;
        
        var numColumns = GetNumHorizontalSlotsFromSize(width);
        var numRows = GetNumVerticalSlotsFromSize(height);
        
        
        //If there is a change in the rows/columns and we dont leave any items outside the new box
        var highestSlot:Point = GetHighestSlotUsed();
        numRows = Math.max(highestSlot.y + 1, numRows);
        numColumns = Math.max(highestSlot.x + 1, numColumns);
        if (numRows != m_NumRows || numColumns != m_NumColumns)
        {
            ResizeBoxTo(numRows, numColumns, isDefaultWindow);
        }
        
    }
    
    public function ResizeBoxTo(numRows:Number, numColumns:Number, isDefaultWindow:Boolean)
    {
        UpdateItemSlotsArray(numRows,numColumns);
        m_NumRows = numRows;
        m_NumColumns = numColumns;
        
        var realWidth = GetHorizontalSizeOfSlots(m_NumColumns);
        var realHeight = GetVerticalSizeOfSlots(m_NumRows);
        UpdateBoxContents(realWidth, realHeight + GetBottomBarHeight());
        RelayoutSlots();
        
        RedrawGrid(isDefaultWindow);
    }
    
    public function UpdateItemSlotsArray(numRows:Number, numColumns:Number)
    {
        var newItemSlots:Array = new Array();
        for (var i:Number = 0; i < numColumns; i++)
        {
            newItemSlots[i] = new Array();
        }
        
        for (var i:Number = 0; i < numColumns; i++)
        {
            for (var j:Number = 0; j < numRows; j++)
            {
                newItemSlots[i][j] = m_ItemSlots[i][j];
            }
        }
        m_ItemSlots = newItemSlots;
    }
    
        
    
    public function GetHighestSlotUsed():Point
    {
        var highestColumn:Number = 0;
        var highestRow:Number = 0;
        for (var i:Number = 0;  i < m_NumColumns; i++)
        {
            for (var j:Number = 0;  j < m_NumRows; j++)
            {
                if (m_ItemSlots[i][j] != undefined)
                {
                    if (i > highestColumn)
                    {
                        highestColumn = i;
                    }
                    if (j > highestRow)
                    {
                        highestRow = j;
                    }
                }
            }
        }
        return new Point(highestColumn, highestRow);
    }
    
    public function CreateEmptySlot(gridPosition:Point, slotID:Number)
    {
    }

    ///*** GRID ***///
    
    public function DrawGrid(isDefaultWindow:Boolean):Void
    {
        if (m_Grid == undefined)
        {
            m_Grid = m_WindowMC.createEmptyMovieClip("grid", m_WindowMC.getNextHighestDepth());
        }
        
        m_HasGrid = true;
        m_Grid.clear();
        
        var h:Number = m_TopBarHeight + 7;
        var w:Number = 7;
        var i:Number = 0;
 
        for (i = 0; i < m_NumRows - 1; i++)
        {
            h += (m_IconSize + m_IconPaddingY)
            m_Grid.lineStyle(1, 0x999999);
            m_Grid.moveTo(m_IconPaddingX, h);
            m_Grid.lineTo(m_BoxWidth - m_IconPaddingX, h);
        }
        
        var bottomBarHeight:Number = GetBottomBarHeight();
        var expandItemsButtonSpace:Number = (isDefaultWindow && m_WindowHasFullVisibility) ? EXPAND_ITEM_BUTTON_SPACE + BOTTOM_BAR_HEIGHT: 0;
        
        for (i = 0; i < m_NumColumns - 1; i++)
        {
            w += (m_IconSize + m_IconPaddingX)
            m_Grid.lineStyle(1, 0x999999);
            m_Grid.moveTo(w, m_TopBarHeight + (m_BoxPadding.top));
            
            m_Grid.lineTo(w, m_WindowMC.i_Background._height + m_TopBarHeight - bottomBarHeight - m_BoxPadding.bottom - expandItemsButtonSpace + bottomBarHeight);
        }
        
        m_Grid._alpha = 0;
        m_Grid.tweenTo(0.2, { _alpha:50 }, None.easeNone);
        m_Grid.onTweenComplete = undefined;
    }

    public function RemoveGrid()
    {
        m_HasGrid = false;
        if (m_Grid)
        {
            m_Grid.tweenTo(0.4, { _alpha:0 }, None.easeNone);
            m_Grid.onTweenComplete = function()
            {
                this.clear();
            }
        }
    }
    
    public function HasGrid():Boolean
    {
        return m_HasGrid;
    }
    
    public function RedrawGrid(isDefaultWindow:Boolean)
    {
        RemoveGrid();
        DrawGrid(isDefaultWindow);
    }
    
    ///*** NAMING ***///
    
    public function CanRename(value:Boolean):Void
    {
        m_CanRename = value;
    }
    
    /// when clicking the title of the inventory, the rename variable is set to true for a second
    /// if a user clicks again while the rename variable is true, it will enable them to edit the text
    private function SlotRenameBox(buttonIndex:Number, clickCount:Number)
    {
        if (m_CanRename)
        {
            if (clickCount == 2 && buttonIndex == 1)
            {
                StartWritingName();
            }
        }
    }
    
    ///Naming functionality
    public function StartWritingName()
    {
        m_WindowMC.i_FrameName._visible = true;
        m_WindowMC.i_FrameName.m_Text.type = "input";
		
        m_WindowMC.i_FrameName.onEnterFrame = Delegate.create(this, SlotNameEnterFrame);
        
        Key.addListener(this);
        
        if (m_WindowMC.i_FrameName.m_Text.text == "")
        {
            m_WindowMC.i_FrameName.m_Text.text = " ";
        }
    }
	
	public function SlotNameEnterFrame()
	{
        //Set the caret at the end of the line
        Selection.setFocus(m_WindowMC.i_FrameName.m_Text);
        Selection.setSelection(0, m_WindowMC.i_FrameName.m_Text.text.length);
		m_WindowMC.i_FrameName.m_Text.selectable = true;
		m_WindowMC.i_FrameName.onMouseDown = Delegate.create(this, SlotMouseDownEndWritingName);
		m_WindowMC.i_FrameName.onEnterFrame = null
	}

    public function SlotMouseDownEndWritingName()
    {
        EndWritingName();
        m_WindowMC.i_FrameName.onMouseDown = null;
    }
    
    public function EndWritingName()
    {
        //Remove the selection
        Selection.setSelection(0,0);
        m_WindowMC.i_FrameName.m_Text.type = "dynamic"
        m_WindowMC.i_FrameName.m_Text.selectable = false;
        SetName(m_WindowMC.i_FrameName.m_Text.text);

        Selection.setFocus(null);
        Key.removeListener(this);
    }

    public function onKeyDown()
    {
        if (Key.getCode() == Key.ENTER)
        {
            EndWritingName();
        }
        else if (Key.getCode() == Key.ESCAPE)
        {
            EndWritingName();
        }
    }
    
    public function GetInventoryID():ID32
    {
        return m_InventoryId;
    }
    
    //Get Icon Size
    public function GetIconSize():Number
    {
        return m_IconSize;
    }
    
    //Get Icon Padding X
    public function GetIconPaddingX():Number
    {
        return m_IconPaddingX;
    }
    
    //Get Icon Padding Y
    public function GetIconPadingY():Number
    {
        return m_IconPaddingY;
    }
    
    //Get Box Padding
    public function GetBoxPadding():Rect
    {
        return m_BoxPadding;
    }
    
    //Get Top Bar Height
    public function GetTopBarHeight():Number
    {
        return m_TopBarHeight;
    }
    
    //Get Bottom Bar Height
    public function GetBottomBarHeight():Number
    {
        return (m_HasBottomBar) ? BOTTOM_BAR_HEIGHT : 2;
    }
    
    //Set Has Bottom Bar
    public function SetHasBottomBar(value:Boolean):Void
    {
        m_HasBottomBar = value;
        
        m_BottomBarHeight = (m_HasBottomBar) ? BOTTOM_BAR_HEIGHT : 0;
    }
    
    //Get Has Bottom Bar
    public function GetHasBottomBar():Boolean
    {
        return m_HasBottomBar;
    }
    
    //Set Pinned Background Opacity
    public function SetPinnedBackgroundOpacity(value:Number):Void
    {
        m_PinnedBackgroundOpacity = value;
        
        UpdateVisibility();
    }
    
    //Set Lock Position When Pinned
    public function SetLockPositionWhenPinned(value:Boolean):Void
    {
        m_LockPositionWhenPinned = value;
    }
}