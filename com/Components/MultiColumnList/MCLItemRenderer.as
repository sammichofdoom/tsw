import gfx.core.UIComponent;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.MCLItem;
import com.Components.MultiColumnList.MCLBaseCellRenderer;
import com.Components.MultiColumnList.MCLTextCellRenderer;
import com.Components.MultiColumnList.MCLMovieClipCellRenderer;
import com.Components.MultiColumnList.MCLMovieClipAndTextCellRenderer;
import com.Components.MultiColumnList.MCLItemValueData;

import com.Utils.Signal;
import mx.utils.Delegate;

class com.Components.MultiColumnList.MCLItemRenderer extends UIComponent
{
	private var m_Index:Number;
	private var m_ItemData:MCLItem;
	private var m_ColumnViews:Array;
	
	private var m_Background:MovieClip;
	
	public var SignalClicked:Signal;
	public var SignalMouseDown:Signal;
	
	//Signal telling the owner that a movieclip was added. The owner is then responsible for connecting to any signals / events on that movieclip
	public var SignalMovieClipAdded:Signal;
	
	public function MCLItemRenderer()
	{
		super();
		m_Index = -1;
		m_ColumnViews  = new Array();
		SignalClicked = new Signal();
		SignalMouseDown = new Signal;
		SignalMovieClipAdded = new Signal();
		
		m_Background.onPress = function(){};
		m_Background.onMousePress = Delegate.create(this, SlotMousePress);
		m_Background.onMouseRelease = Delegate.create(this, SlotMouseRelease);
		
		m_Background.onMouseDown = function(){}
	}
	
	public function MovieClipAdded(columnId:Number, movieClip:MovieClip)
	{
		SignalMovieClipAdded.Emit(m_Index, columnId, movieClip);
	}
	
	public function SetIndex(index:Number)
	{
		m_Index = index;
	}
	
	public function SetData(listView:MultiColumnListView, data:MCLItem)
	{
		Clear();
		m_ItemData = data;
		m_Background._visible = true;
	}
	
	public function HasData() : Boolean
	{
		return m_ItemData != undefined;
	}
	
	private function SlotMousePress(buttonindex:Number)
	{
		if (HasData())
		{
			SignalMouseDown.Emit(m_Index, buttonindex);
		}
	}
	
	private function SlotMouseRelease(buttonindex:Number)
	{
		if (HasData())
		{			
			SignalClicked.Emit(m_Index, buttonindex);
		}
	}
	
	public function SetSelected(selected:Boolean)
	{
		if (selected)
		{
			gotoAndPlay("selected");
		}
		else
		{
			gotoAndStop("default");
		}
	}
	
	public function GetDesiredWidth(id:Number)
	{
		var columnIndex:Number = GetColumnIndexFromId(id);
		if (columnIndex >= 0)
		{
			return m_ColumnViews[columnIndex].GetDesiredWidth();
		}
		return -1;
	}
	
	private function GetColumnIndexFromId(id:Number)
	{
		for (var i:Number = 0; i < m_ColumnViews.length; i++)
		{
			if (m_ColumnViews[i].GetId() == id)
			{
				return i;
			}
		}
		return -1;
	}
	
	public function Clear()
	{
		m_ItemData = undefined;
		for (var i:Number = 0; i < m_ColumnViews.length; i++)
		{
			m_ColumnViews[i].Remove();
		}
		m_ColumnViews  = new Array();
		m_Background._visible = false;
	}
	
	public function UpdateLayout(listView:MultiColumnListView)
	{
		var columns:Array = listView.GetColumnTable();		
		var columnX:Number = 0;
		for (var i:Number = 0; i < columns.length; i++)
		{
			var columnIndex:Number = GetColumnIndexFromId(columns[i].m_Id);
			if (columnIndex != -1)
			{
				m_ColumnViews[columnIndex].SetSize(columns[i].m_Width, m_Background._height);
				m_ColumnViews[columnIndex].SetPos(columnX, 0);
			}
			columnX += columns[i].m_Width + listView.GetHeaderSpacing()
		}
	}
		
	public function SetWidth(newWidth:Number)
	{
		m_Background._width = newWidth;
	}
	
	public function SetHeight(newheight:Number)
	{
		m_Background._height = newheight;
	}
	
	
	private function CreateTextRenderer(id:Number, valueData:MCLItemValueData, width:Number) : MCLBaseCellRenderer
	{
		var textClip:MCLTextCellRenderer = new MCLTextCellRenderer(this, id, valueData);
		textClip.SetSize(width, m_Background._height);
		return textClip;
	}
	
	private function CreateMovieClipRenderer(id:Number, movieClip:Object, width:Number) : MCLBaseCellRenderer
	{
		var clipRenderer:MCLMovieClipCellRenderer = new MCLMovieClipCellRenderer(this, id, movieClip);
		clipRenderer.SetSize(width, m_Background._height);
		return clipRenderer;
	}
	
	private function CreateMovieClipAndTextRenderer(id:Number, valueData:MCLItemValueData, width:Number) : MCLBaseCellRenderer
	{
		var clipRenderer:MCLMovieClipAndTextCellRenderer = new MCLMovieClipAndTextCellRenderer(this, id, valueData);
		clipRenderer.SetSize(width, m_Background._height);
		return clipRenderer;
	}
}