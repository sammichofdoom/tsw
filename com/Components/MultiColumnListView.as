import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.HeaderView;
import com.Components.MultiColumnList.MCLItem;
import gfx.core.UIComponent;
import com.Utils.Signal;
import mx.utils.Delegate;

class com.Components.MultiColumnListView extends UIComponent
{
	private var m_HeaderSpacing:Number;
	
	private var m_ItemRendererName:String;
	
	private var m_RowCount:Number;
	private var m_AutoRowCount:Number;
	private var m_RowHeight:Number;
	private var m_AutoRowHeight:Number;
	
	private var m_ScrollPosition:Number
	private var m_ShowBottomLine:Boolean;
	private var m_SortColumn:Number;
	private var m_SortDirection:Number;
	private static var s_SortColumn:Number;
    private var m_SecondarySortColumn:Number;
	private var m_UseMask:Boolean;
    private var m_DisableRightClickSelection:Boolean;
	
	private var m_LineColor:Number;
	private var m_LineThickness:Number;
	
	private var m_HeaderView:HeaderView;
	private var m_ListView:MovieClip;
	private var m_Lines:MovieClip;
	private var m_Background:MovieClip;
	private var m_ScrollBar:MovieClip;
	private var m_Mask:MovieClip;
	
	private var m_ItemRenderers:Array;
	private var m_ColumnTable:Array;
	private var m_Items:Array;
	private var m_SelectedItem:Number;
	
	
	public var SignalSizeChanged:Signal;
	public var SignalItemClicked:Signal;
    public var SignalSortClicked:Signal;
	public var SignalItemMouseDown:Signal;
	
	//Signal telling the owner that a movieclip was added. The owner is then responsible for connecting to any signals / events on that movieclip
	public var SignalMovieClipAdded:Signal;
	
	public function MultiColumnListView()
	{
		m_ColumnTable = new Array();
		m_ItemRenderers = new Array();
		m_Items = new Array();
		
		m_UseMask = true;
        m_DisableRightClickSelection = true;
		
		m_SelectedItem = -1;
        m_SecondarySortColumn = -1;
		
		m_HeaderView = HeaderView( attachMovie("HeaderView", "m_HeaderView", getNextHighestDepth()) );
		m_HeaderView.SignalSortColumn.Connect(SlotSortColumn, this);
		m_HeaderView.SignalResizeColumn.Connect(SlotResizeColumn, this);
		m_HeaderView.SignalAutoResizeColumn.Connect(SlotAutoResizeColumn, this);
		
		m_ListView = createEmptyMovieClip("m_ListView", getNextHighestDepth());
		m_Lines = createEmptyMovieClip("m_Lines", getNextHighestDepth());
		
		m_HeaderView.SetMultiColumnListView(this);
		m_HeaderSpacing = 0;
		m_ScrollPosition = 0;
		
		m_RowCount = -1;
		m_AutoRowCount = -1;
		m_SortColumn = -1;
		m_SortDirection = 0;
		m_RowHeight = -1;
		m_AutoRowHeight = -1;
		
		m_ShowBottomLine = true;
		
		m_LineColor = 0x666666;
		m_LineThickness = 1;
		
		m_ItemRendererName = "";
		
		SignalSizeChanged = new Signal();
		SignalItemClicked = new Signal();
        SignalSortClicked = new Signal();
		SignalItemMouseDown = new Signal();
		SignalMovieClipAdded = new Signal();
		
		Mouse.addListener(this);
	}
		
	public function configUI()
	{
		super.configUI();
		if (m_RowCount == -1)
		{
			AutoUpdateRowCount();
		}
		
		if (GetRowCount() != 0)
		{
			DrawItemRenderers();
			ResetRenderers();
		}
		SignalSizeChanged.Emit()
	}
	
	public function DrawItemRenderers()
	{
		if (m_ItemRendererName.length > 0)
		{
			var rowCount:Number = GetRowCount();
			if (rowCount == -1)
			{
				return;
			}
			while (m_ItemRenderers.length > rowCount) 
			{
				m_ItemRenderers.pop().removeMovieClip();
			}
			
			var y:Number = m_ItemRenderers.length * GetRowHeight();
			while (m_ItemRenderers.length < rowCount)
			{
				var itemRenderer:MovieClip = CreateItemRenderer(m_ItemRenderers.length);
				m_ItemRenderers.push(itemRenderer);
				itemRenderer._y = y;
				y += itemRenderer._height;
			}
			
			UpdateScrollBar();
			
			var totalHeight:Number = m_HeaderView._height + m_ListView._height;
			if (totalHeight != m_Background._height)
			{
				m_Background._height = totalHeight;
			}
			LayoutMask();
			DrawLines();
		}
	}
	
	private function DrawLines()
	{
		m_Lines.clear();
        m_Lines.lineStyle(m_LineThickness, m_LineColor);
		var x:Number = 0;
		for (var i:Number = 0; i < m_ColumnTable.length; i++)
		{
			if (i != m_ColumnTable.length - 1)
			{
				x += m_ColumnTable[i].m_Width + m_HeaderSpacing / 2;
				m_Lines.moveTo(x, 3);
				m_Lines.lineTo(x, m_Background._height - m_HeaderView._height);
				x += m_HeaderSpacing / 2
				
			}
		}
		
		var y:Number = 0;
		var lastItemHadData:Boolean = false;
		for (var i:Number = 0; i < GetRowCount(); i++)
		{
			if (m_Items[i] != undefined && m_ItemRenderers[i] != undefined)
			{
				var isBottomLine = (i == GetRowCount() - 1) || (lastItemHadData && !m_ItemRenderers[i].HasData());
				var shouldDrawLine:Boolean = m_ItemRenderers[i].HasData() && (m_ShowBottomLine || !isBottomLine);
				if ( shouldDrawLine )
				{
					y += GetRowHeight();
					m_Lines.moveTo(0, y);
					m_Lines.lineTo(m_Background._width, y);
				}
				
				lastItemHadData = m_ItemRenderers[i].HasData();
			}
		}
	}
	
	public function CreateItemRenderer(index:Number):MovieClip
	{
		var itemRenderer:MovieClip = m_ListView.attachMovie(m_ItemRendererName, "m_ItemRenderer_" + index, m_ListView.getNextHighestDepth());
		itemRenderer.SetWidth(m_Background._width);
		itemRenderer.SetIndex(index);
		itemRenderer.UpdateLayout(this);
		itemRenderer.SignalClicked.Connect(SlotItemClicked, this);
		itemRenderer.SignalMouseDown.Connect(SlotItemMouseDown, this);
		itemRenderer.SignalMovieClipAdded.Connect(SlotMovieClipAdded, this);
		return itemRenderer;
	}
	
	public function Resort()
	{
		if (m_SortColumn >= 0)
		{
			SlotSortColumn(m_SortColumn, m_SortDirection);
		}
	}
	
	public function SlotSortColumn(columnId:Number, direction:Number)
	{
        var selectedItemId:Number = m_SelectedItem;
        
		m_SortColumn = columnId;
		m_SortDirection = direction;
		s_SortColumn = columnId;
		
		m_Items.sort(Delegate.create(this, CompareItems));
		if ((direction & Array.DESCENDING) != 0)
		{
			m_Items.reverse();
		}		
		ResetRenderers();
        SignalSortClicked.Emit();
	}
	
	public function SlotItemClicked(itemIndex:Number, buttonIndex:Number)
	{
		if (buttonIndex == 1 || !m_DisableRightClickSelection)
		{
			for (var i:Number = 0; i < m_ItemRenderers.length; i++)
			{
				if (i != itemIndex && m_ItemRenderers[i] != undefined)
				{
					m_ItemRenderers[i].SetSelected(false);
				}
			}
            if (m_ItemRenderers[itemIndex] != undefined)
            {
                m_ItemRenderers[itemIndex].SetSelected(true)
            }
						
			m_SelectedItem = m_ScrollPosition + itemIndex;
		}
		SignalItemClicked.Emit(m_ScrollPosition + itemIndex, buttonIndex);
	}
    
    public function SetSelection(index:Number):Void
    {
        if (index >= 0)
        {
            SlotItemClicked(index - m_ScrollPosition, 1);
        }
    }
    
    public function SetSelectionById(itemId:Object):Void
    {
        SetSelection( GetIndexById(itemId) );
    }
    
    public function GetSelectedIndex():Number
    {
        return m_SelectedItem;
    }
    
    public function ClearSelection()
    {
        for (var i:Number = 0; i < m_ItemRenderers.length; i++)
        {
            if (m_ItemRenderers[i] != undefined)
            {
                m_ItemRenderers[i].SetSelected(false);
            }
        }
		m_SelectedItem = -1;
    }
	
	public function SlotItemMouseDown(itemIndex:Number, buttonIndex:Number)
	{
		SignalItemMouseDown.Emit(m_ScrollPosition + itemIndex, buttonIndex);
	}
	
	public function SlotMovieClipAdded(itemIndex:Number, columnId:Number, movieClip:MovieClip)
	{
		SignalMovieClipAdded.Emit(m_ScrollPosition + itemIndex, columnId, movieClip);
	}
	
	public function SlotResizeColumn(columnId:Number, width:Number)
	{
		SetColumnWidth(columnId, width);
	}
	
	public function SlotAutoResizeColumn(columnId:Number)
	{
		var maxWidth:Number = 0;
		for (var i:Number = 0; i < m_ItemRenderers.length; i++)
		{
			maxWidth = Math.max(maxWidth, m_ItemRenderers[i].GetDesiredWidth(columnId));
		}
		if (maxWidth > 0)
		{
			SetColumnWidth(columnId, maxWidth);
		}
	}
	
    public function CompareItems(item1:Object, item2:Object)
    {
        var compareResult:Number = item1.Compare(s_SortColumn, item2);
        
        if (compareResult == 0 && m_SecondarySortColumn >= 0 && m_SecondarySortColumn != s_SortColumn)
        {
            if ( (m_SortDirection & Array.DESCENDING) != 0 ) //Invert result
            {
                compareResult = item2.Compare(m_SecondarySortColumn, item1);
            }
            else
            {
                compareResult = item1.Compare(m_SecondarySortColumn, item2);
            }
        }
        
        if ( compareResult == 0 )
        {
            var item1Str:String = item1.GetId().toString();
            var item2Str:String = item2.GetId().toString();
            if (item1Str > item2Str)
            {
                compareResult = 1;
            }
            else if (item1Str < item2Str)
            {
                compareResult = -1;
            }
        }
        
        return compareResult;
    }
		
	public function SetItemRenderer(name:String)
	{		
		m_ItemRendererName = name;
		if (initialized)
		{
			m_AutoRowHeight = -1;
			if (m_RowCount == -1)
			{
				var oldCount:Number = m_AutoRowCount;
				AutoUpdateRowCount();
			}
			DrawItemRenderers();
			ResetRenderers();
		}
	}
	
	public function SetShowBottomLine(showLine:Boolean)
	{
		m_ShowBottomLine = showLine;
	}
	
	public function SetHeaderSpacing(headerSpacing:Number)
	{
		m_HeaderSpacing = headerSpacing;
	}
	
	public function GetHeaderSpacing() : Number
	{
		return m_HeaderSpacing;
	}
	
	public function GetRowCount():Number
	{
		return m_RowCount != -1 ? m_RowCount : m_AutoRowCount;
	}
	
	public function GetRowHeight():Number
	{
		if (m_RowHeight != -1)
		{
			return m_RowHeight;
		}
		if (m_AutoRowHeight == -1 && m_ItemRendererName.length > 0)
		{
			var clip:MovieClip = attachMovie(m_ItemRendererName, "m_ItemRenderer_Test", getNextHighestDepth());
			if (clip != undefined	)
			{
				m_AutoRowHeight = clip._height;
				clip.removeMovieClip();
			}
		}
		return m_AutoRowHeight;
	}
	
	//Manually sets the rowcount. The list will resize after the number of rows
	public function SetRowCount(rowCount:Number)
	{
		m_RowCount = rowCount;
		if (initialized)
		{
			DrawItemRenderers();
			ResetRenderers();
			DrawLines();
		}
	}
	
	public function SetSortColumn(columnId:Number)
	{
		m_SortColumn = columnId;
	}
	
	public function GetSortColumn():Number
	{
		return m_SortColumn;
	}
    
    public function SetSortDirection(direction:Number)
    {
        m_SortDirection = direction;
    }
    
    public function GetSortDirection():Number
    {
        return m_SortDirection;
    }
	
	public function GetColumn(id:Number)
	{
		for (var i:Number = 0; i < m_ColumnTable.length; i++)
		{
			if (m_ColumnTable[i].m_Id == id)
			{
				return m_ColumnTable[i];
			}
		}
		return undefined;
	}
	
	public function GetColumnIndex(id:Number) : Number
	{
		for (var i:Number = 0; i < m_ColumnTable.length; i++)
		{
			if (m_ColumnTable[i].m_Id == id)
			{
				return i;
			}
		}
		return -1;
	}
	
	public function GetColumnTable()
	{
		return m_ColumnTable;
	}
	
	public function GetItems():Array
	{
		return m_Items;
	}
	
	public function AddItems(itemArray:Array)
	{
		var firstIndex:Number = m_Items.length;
		m_Items = m_Items.concat(itemArray);
		var lastIndex:Number = m_Items.length;
		if (firstIndex <= m_ScrollPosition + GetRowCount()  && lastIndex >= m_ScrollPosition)
		{
			ResetRenderers();
		}
		DrawLines();
		LayoutMask();
        UpdateScrollBar();
	}
	
	public function AddItem(item:MCLItem)
	{
		m_Items.push(item);
		
		if (m_Items.length - 1 >= m_ScrollPosition && m_Items.length - 1 <= m_ScrollPosition + GetRowCount())
		{
			if (m_ItemRenderers[m_Items.length -1 - m_ScrollPosition] != undefined)
			{
				m_ItemRenderers[m_Items.length -1 - m_ScrollPosition].SetData(this, m_Items[m_Items.length - 1]);
			}
		}
		DrawLines();
        UpdateScrollBar();
	}
	
    public function GetIndexById(itemId:Object):Number
    {
		for (var i:Number = 0; i < m_Items.length; i++)
		{
			if (m_Items[i].GetId() == itemId)
			{
				return i;
			}
		}
        return -1;
    }
    
    public function HasItemById(itemId:Object):Boolean
    {
        return (GetIndexById(itemId) >= 0);
    }
    
	public function RemoveItemById(itemId:Object)
	{
        var index:Number = GetIndexById(itemId);
        if (index >= 0)
        {
            RemoveItem(index);
        }
	}
	
	public function RemoveItem(index:Number)
	{
		m_Items.splice(index, 1);
		if (index < m_ScrollPosition + GetRowCount())
		{
			ResetRenderers();
		}

        UpdateScrollBar();
	}
	
	public function RemoveAllItems()
	{
		m_Items = new Array();
		ResetRenderers();
	}
	
    public function SetItems(itemsList:Array):Void
    {
        for (var i:Number = 0; i < itemsList.length; ++i )
        {
            var item:MCLItem = itemsList[i];
            if (item != undefined)
            {
                SetItem(itemsList[i]);
            }
        }
    }
    
	public function SetItem(item:MCLItem)
	{
		for (var i:Number = 0; i < m_Items.length; i++)
		{
			if (m_Items[i].GetId() == item.GetId())
			{
				m_Items[i] = item;
				if (i >= m_ScrollPosition && i <= m_ScrollPosition + GetRowCount() && m_ItemRenderers[i - m_ScrollPosition] != undefined)
				{
					m_ItemRenderers[i - m_ScrollPosition].SetData(this, item);
				}
				DrawLines();
				return;
			}
		}
		
		//If it does not find it Add it
		AddItem(item);
	}
	
	public function AddColumn(columnId:Number, name:String, defaultWidth:Number, flags:Number, minWidth:Number)
	{
		var columnData:ColumnData = new ColumnData();
		columnData.m_Id = columnId;
		columnData.m_Flags = flags;
		columnData.m_Width = defaultWidth;
		columnData.m_DefaultWidth = defaultWidth;
		columnData.m_Label = name;
		if (minWidth != undefined)
		{
			columnData.m_MinWidth = minWidth;
		}
		m_ColumnTable.push(columnData);
		
		LayoutHeaders(false);
	}
	
	public function LayoutHeaders(columnsRemoved:Boolean)
	{
		m_HeaderView.LayoutColumns(m_HeaderSpacing, columnsRemoved);
		m_ListView._y = m_HeaderView._height;
		m_Lines._y = m_HeaderView._height;
	}
	
	public function LayoutMask()
	{
		if (m_UseMask)
		{
			if (m_Mask == undefined)
			{
				m_Mask = this.createEmptyMovieClip("m_Mask", this.getNextHighestDepth());
				m_ListView.setMask(m_Mask);
			}
			m_Mask.clear();
			m_Mask.beginFill(0xFF0000);
			m_Mask.moveTo(0, 0);
			m_Mask.lineTo(m_Background._width, 0);
			m_Mask.lineTo(m_Background._width, m_Background._height - m_HeaderView._height);
			m_Mask.lineTo(0, m_Background._height - m_HeaderView._height);
			m_Mask.lineTo(0, 0);
			m_Mask.endFill();
					
			m_Mask._x = m_ListView._x;
			m_Mask._y = m_ListView._y;
		}
	}
	
	public function ResetRenderers()
	{
		if (initialized)
		{
			for (var i:Number = 0; i < m_ItemRenderers.length; i++)
			{
				m_ItemRenderers[i].Clear();
			}
			for (var i:Number = 0; i < GetRowCount(); i++)
			{
				if (m_ItemRenderers[i] != undefined && m_Items[m_ScrollPosition + i] != undefined)
				{
					m_ItemRenderers[i].SetData(this, m_Items[m_ScrollPosition + i]);
				}
			}
			DrawLines();
		}
	}
	
	public function LayoutRenderers()
	{
		if (initialized)
		{
			for (var i:Number = 0; i < m_ItemRenderers.length; i++)
			{
				m_ItemRenderers[i].SetWidth(m_Background._width);
				m_ItemRenderers[i].UpdateLayout(this);
			}
			
			DrawLines();
		}
	}
	
	public function IsColumnActive(id:Number)
	{
		var column:ColumnData = GetColumn(id);
		if (column != undefined)
		{
			return !column.IsDisabled();
		}
		return false;
	}
	
	public function SetSize(newWidth:Number, newHeight:Number)
	{
		m_Background._width = newWidth;
		m_Background._height = newHeight;
		LayoutMask();
		
		AutoSizeColumns();
		if (m_RowCount == -1)
		{
			var oldCount:Number = m_AutoRowCount;
			AutoUpdateRowCount();
			if (oldCount != m_AutoRowCount)
			{
				DrawItemRenderers();
				ResetRenderers();
			}
		}
		
	}
	
	public function AutoSizeColumns()
	{
		var currentWidth:Number = GetWidthOfColumns();
		var realWidth:Number = m_Background._width;
		var numResizeable:Number = GetNumResizeableColumns();
		if (numResizeable > 0)
		{
			var additionPrColumn:Number = (realWidth - currentWidth) / numResizeable;
			for (var i:Number = 0; i < m_ColumnTable.length; i++)
			{
				if (m_ColumnTable[i].CanResize() && !m_ColumnTable[i].IsDisabled())
				{
					m_ColumnTable[i].m_Width += additionPrColumn;
				}
			}
			LayoutHeaders(false);
			LayoutRenderers();
		}
	}
	
    public function GetColumnWidth(columnId:Number):Number
    {
        for (var i:Number = 0; i < m_ColumnTable.length; i++)
        {
            if ( m_ColumnTable[i].m_Id == columnId )
            {
                return m_ColumnTable[i].m_Width;
            }
        }
        return 0;
    }
    
	public function SetColumnWidth(columnId:Number, width:Number)
	{
		var resizeWidth:Number = Math.max(width, 0);
		var columnIndex:Number = GetColumnIndex(columnId);
		var widthFromSelectedColumn:Number = m_Background._width - GetColumnX(columnId);
		
		if (columnIndex != -1)
		{
			resizeWidth = Math.min(resizeWidth, widthFromSelectedColumn);
			resizeWidth = Math.max(resizeWidth, m_ColumnTable[columnIndex].m_MinWidth);
						
			var change:Number = resizeWidth - m_ColumnTable[columnIndex].m_Width;
			var startIndex:Number = columnIndex+1;
			var endIndex:Number = m_ColumnTable.length;
						
			var resizeableColumns:Number = GetNumResizeableColumns(startIndex, endIndex);
			
			if (resizeableColumns > 0 && change != 0)
			{
				var needResize:Boolean = true;
				var counter:Number = 0;
				while((needResize || Math.abs(change) > 0.01) && counter < 10 )
				{
					counter++;
					var additionPrColumn:Number = -change / resizeableColumns;
					
					needResize = false;
					for (var i:Number = startIndex; i < endIndex; i++)
					{
						if (m_ColumnTable[i].CanResize() && !m_ColumnTable[i].IsDisabled() && m_ColumnTable[i].m_Id != columnId)
						{
							var resizedColumnSize:Number = m_ColumnTable[i].m_Width + additionPrColumn;
							var actualColumnResized:Number = additionPrColumn;
							if (resizedColumnSize < m_ColumnTable[i].m_MinWidth)
							{
								actualColumnResized = m_ColumnTable[i].m_Width - m_ColumnTable[i].m_MinWidth;
								if (actualColumnResized != 0)
								{
									needResize = true;
								}
								m_ColumnTable[i].m_Width = m_ColumnTable[i].m_MinWidth;
							}
							else
							{
								m_ColumnTable[i].m_Width = resizedColumnSize;
							}
							change += actualColumnResized;
						}
					}
				}
				var sizeOfOtherColumns:Number = 0;
				for (var i:Number = startIndex; i < endIndex; i++)
				{
					sizeOfOtherColumns += m_ColumnTable[i].m_Width;
					if (i != endIndex)
					{
						sizeOfOtherColumns += m_HeaderSpacing;
					}
				}
				m_ColumnTable[columnIndex].m_Width = widthFromSelectedColumn - sizeOfOtherColumns;
				LayoutHeaders(false);
				LayoutRenderers();
			}
		}
	}
	
	public function AutoUpdateRowCount()
	{
		if (GetRowHeight() != -1)
		{
			m_AutoRowCount = Math.floor((m_Background._height - m_HeaderView._height) / GetRowHeight());
		}
	}
	
	private function GetWidthOfColumns():Number
	{
		var columnWidth:Number = 0;
		for (var i:Number = 0; i < m_ColumnTable.length; i++)
		{
			if (!m_ColumnTable[i].IsDisabled())
			{
				columnWidth += m_ColumnTable[i].m_Width;
				if (i != m_ColumnTable.length -1)
				{
					columnWidth += m_HeaderSpacing;
				}
			}
		}
		return columnWidth;
	}
	
	private function GetColumnX(columnId:Number):Number
	{
		var columnX:Number = 0;
		for (var i:Number = 0; i < m_ColumnTable.length; i++)
		{
			if (m_ColumnTable[i].m_Id == columnId)
			{
				break;
			}
			
			if (!m_ColumnTable[i].IsDisabled())
			{
				columnX += m_ColumnTable[i].m_Width;
				if (i != m_ColumnTable.length -1)
				{
					columnX += m_HeaderSpacing;
				}
			}
		}
		return columnX;
	}
	
	private function GetNumResizeableColumns(startIndex:Number, endIndex:Number):Number
	{
		var numResizeable:Number = 0;
		var start:Number = startIndex;
		if (startIndex == undefined)
		{
			start = 0;
		}
		
		var end:Number = endIndex;
		if (endIndex == undefined)
		{
			end = m_ColumnTable.length;
		}
		
		for (var i:Number = start; i < end; i++)
		{
			if (m_ColumnTable[i].CanResize() && !m_ColumnTable[i].IsDisabled())
			{
				numResizeable++;
			}
		}
		return numResizeable;
	}
	
	public function SetScrollBar(scrollBar:MovieClip)
	{
		m_ScrollBar = scrollBar;
		m_ScrollBar.tabEnabled = false;
		if (m_ScrollBar.setScrollProperties != null) {
			m_ScrollBar.addEventListener("scroll", this, "SlotScroll");
		} else {
			m_ScrollBar.addEventListener("change", this, "SlotScroll");
		}
		
		UpdateScrollBar();
	}
	
	public function UpdateScrollBar()
	{
		var max:Number = Math.max(0, m_Items.length - GetRowCount());
		if (m_ScrollBar.setScrollProperties != null) 
		{
			m_ScrollBar.setScrollProperties(GetRowCount() * 1.0, 0, max);
		} 
        
        m_ScrollBar.height = (GetRowCount() + 1) * GetRowHeight();
        
        var newPos:Number = m_ScrollPosition;
        
        if (newPos > m_ScrollBar["maxPosition"])
        {
            newPos = m_ScrollBar["maxPosition"];
        }
        
		m_ScrollBar.position = newPos;

		m_ScrollBar.trackScrollPageSize = Math.max(1, GetRowCount());
	}
	
	private function SlotScroll(event:Object)
	{
		var newPosition:Number = event.target.position;
		if (isNaN(newPosition)) { return; }
		SetScrollPosition(newPosition);
	}

	private function scrollWheel(delta:Number) : Void
	{
		if (_disabled) { return; }
		var pageScrollSize = (m_ScrollBar != undefined && m_ScrollBar.pageScrollSize != undefined) ? m_ScrollBar.pageScrollSize : 1;
		var pos = m_ScrollPosition - (delta * pageScrollSize);
		m_ScrollBar.position = pos;
	}
	
	public function SetScrollPosition(position:Number)
	{
		if (position != m_ScrollPosition)
		{
			var oldScrollPos:Number = m_ScrollPosition;
			m_ScrollPosition = position;
			ResetRenderers();
            if (m_ItemRenderers[m_SelectedItem - oldScrollPos] != undefined)
            {
                m_ItemRenderers[m_SelectedItem - oldScrollPos].SetSelected(false);
            }
			if (m_SelectedItem >= 0 || m_SelectedItem < m_ItemRenderers.length)
			{
                if (m_ItemRenderers[m_SelectedItem - m_ScrollPosition] != undefined)
                {
                    m_ItemRenderers[m_SelectedItem - m_ScrollPosition].SetSelected(true);
                }
			}
		}		
	}
	
    public function DisableRightClickSelection(disable:Boolean):Void
    {
        m_DisableRightClickSelection = disable;
    }
    
	public function GetScrollPosition() : Number
	{
		return m_ScrollPosition;
	}
	
	public function SetLineStyle(thickness:Number, color:Number)
	{
		m_LineThickness = thickness;
		m_LineColor = color;
		DrawLines();
	}
	
	public function SetUseMask(useMask:Boolean)
	{
		m_UseMask = useMask;
		if (m_Mask != undefined && !useMask)
		{
			m_Mask.removeMovieClip();
			m_ListView.setMask(null);
		}
	}
	
	public function SetSecondarySortColumn(column:Number):Void
    {
        m_SecondarySortColumn = column;
    }
	
}
