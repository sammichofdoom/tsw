import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.HeaderButton;
import com.Utils.Signal;
import gfx.core.UIComponent;

class com.Components.MultiColumnList.HeaderView extends UIComponent
{
	private var m_HeaderButtons:Array;
	private var m_HeaderButtonDividers:Array;
	
	private var m_ListView:MultiColumnListView;
	
	private var m_RendererName:String;
	
	public var SignalSortColumn:Signal;
	public var SignalAutoResizeColumn:Signal;
	public var SignalResizeColumn:Signal;
	
	public var m_HeaderDividerClip:MovieClip;
	public var m_HeaderClip:MovieClip;
	
	public function HeaderView()
	{
		super();
		m_HeaderButtons = new Array();
		m_HeaderButtonDividers = new Array();
		m_RendererName = "HeaderRenderer";
		
		SignalSortColumn = new Signal();
		SignalAutoResizeColumn = new Signal();
		SignalResizeColumn = new Signal();
		
		m_HeaderClip = createEmptyMovieClip("m_Headers", getNextHighestDepth());
		m_HeaderDividerClip = createEmptyMovieClip("m_HeaderDividers", getNextHighestDepth());
	}
	
	public function SetMultiColumnListView(multiColumnListView:MultiColumnListView)
	{
		m_ListView = multiColumnListView;
	}
	
	public function SetItemRenderer(name:String)
	{
		m_RendererName = name;
	}
	
	public function GetHeaderButton(id:Number)
	{
		for (var i:Number = 0; i < m_HeaderButtons.length;  i++)
		{
			if (m_HeaderButtons[i].GetId() == id)
			{
				return m_HeaderButtons[i];
			}
		}
		return undefined;
	}
	
	public function LayoutColumns(columnSpacing:Number, columnRemoved:Boolean)
	{
		if (columnRemoved)
		{
			for (var i:Number = 0; i < m_HeaderButtons.length; i++)
			{
				if (m_ListView.IsColumnActive(m_HeaderButtons[i].GetId()))
				{
					m_HeaderButtons[i].removeMovieClip();
					m_HeaderButtons.splice(i, 1);
					for (var j:Number = 0; j < m_HeaderButtonDividers.length; j++)
					{
						if (m_HeaderButtonDividers[j].m_Id == m_HeaderButtons[i].GetId())
						{
							m_HeaderButtonDividers[j].removeMovieClip();
							m_HeaderButtonDividers.splice(j, 1);
							break;
						}
					}
					i--;
				}
			}
		}
		var headerX:Number = 0;
		var columnTable:Array = m_ListView.GetColumnTable();
		for (var i:Number = 0; i < columnTable.length; i++)
		{
			if (columnTable[i].IsDisabled())
			{
				continue;
			}
			var label:String = "";
			if (columnTable[i].ShouldShowLabel())
			{
				label = columnTable[i].m_Label
			}
			
			var header:MovieClip = GetHeaderButton(columnTable[i].m_Id);
			if (header == undefined)
			{
				header = m_HeaderClip.attachMovie(m_RendererName, "m_Header_" + columnTable[i].m_Id, m_HeaderClip.getNextHighestDepth());
				header.disableFocus = true;
				header.addEventListener("sort", this, "SlotSort");
				
				header.SetCanSort(columnTable[i].CanSort());
				
				if (columnTable[i].CanResize())
				{
					m_HeaderButtonDividers.push(CreateHeaderDivider(columnTable[i].m_Id));
				}
				
				m_HeaderButtons.push(header);
			}
			
			header.SetId(columnTable[i].m_Id);
			header.SetLabel(label);
			header.SetWidth(columnTable[i].m_Width);
			if (i == 0)
			{
				header.SetType(HeaderButton.HEADER_FIRST);
			}
			else if (i == columnTable.length - 1)
			{
				header.SetType(HeaderButton.HEADER_LAST);
			}
			else
			{
				header.SetType(HeaderButton.HEADER_NORMAL);
			}
			
			header._x = headerX;
			headerX += columnTable[i].m_Width + columnSpacing;
			
			var headerDivider:MovieClip = GetButtonDivider(columnTable[i].m_Id);
			if (headerDivider != undefined)
			{
				headerDivider._x = headerX;
			}
		}
	}
	
	public function CreateHeaderDivider(id:Number) : MovieClip
	{
		//var clip = m_HeaderDividerClip.createEmptyMovieClip("m_Divider_" + id, m_HeaderDividerClip.getNextHighestDepth());
		var clip = m_HeaderDividerClip.attachMovie("HeaderDivider", "m_Divider_" + id, m_HeaderDividerClip.getNextHighestDepth());
		/*trace("Creating headerdivider: " + _height);
		clip.lineStyle(0, 0x000000, 0);
		clip.beginFill(0xFF0000, 100);
		clip.moveTo(-5, 0);
		clip.lineTo(5, 0);
		clip.lineTo(5, _height);
		clip.lineTo(-5, _height);
		clip.endFill();*/
		clip.m_Id = id;

		var ref = this;
		clip.onPress = function(){}
		clip.onMousePress = function(buttonIndex:Number, clickCount:Number)
		{
			if (buttonIndex == 1)
			{
				if (clickCount == 1)
				{
					this.onMouseMove = function()
					{
						ref.UpdateResize(id);
					}
				}
				else if (clickCount == 2)
				{
					ref.AutoResize(id);
				}
			}
		}
		
		clip.onRelease = clip.onReleaseOutside = function()
		{
			this.onMouseMove = null;
		}
		return clip;
	}
	
	public function UpdateResize(id:Number)
	{
		var button:MovieClip = GetButton(id);
		if (button != undefined)
		{
			SignalResizeColumn.Emit(id, (button._parent._xmouse - button._x));
		}
	}
	
	public function AutoResize(id:Number)
	{
		var button:MovieClip = GetButton(id);
		if (button != undefined)
		{
			SignalAutoResizeColumn.Emit(id);
		}
	}
	
	public function SlotSort(event:Object)
	{
		for (var i:Number = 0; i < m_HeaderButtons.length; i++)
		{
			if (m_HeaderButtons[i].GetId() != event.id)
			{
				m_HeaderButtons[i].SetShowArrow(false);
                m_HeaderButtons[i].SetSortDirection(0); //Reset sort direction when a different column is sorted
			}
		}
		//dispatchEvent( { type:"sort", direction:event.direction, id:event.id} );
		SignalSortColumn.Emit(event.id, event.direction);
	}
	
	public function GetButtonDivider(id:Number)
	{
		for (var i:Number = 0; i < m_HeaderButtonDividers.length; i++)
		{
			if (m_HeaderButtonDividers[i].m_Id == id)
			{
				return m_HeaderButtonDividers[i];
			}
		}
		return undefined;
	}
	
	public function GetButton(id:Number)
	{
		for (var i:Number = 0; i < m_HeaderButtons.length; i++)
		{
			if (m_HeaderButtons[i].GetId() == id)
			{
				return m_HeaderButtons[i];
			}
		}
		return undefined;
	}
}