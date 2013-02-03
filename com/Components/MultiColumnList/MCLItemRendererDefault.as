import com.Components.MultiColumnList.MCLBaseCellRenderer;
import com.Components.MultiColumnList.MCLItemValueData;
import com.Components.MultiColumnList.MCLTextCellRenderer;
import com.Components.MultiColumnList.MCLMovieClipCellRenderer;
import com.Components.MultiColumnList.MCLMovieClipAndTextCellRenderer;
import gfx.core.UIComponent;
import com.Components.MultiColumnList.MCLItemRenderer
import com.Components.MultiColumnListView
import com.Components.MultiColumnList.MCLItemValue
import com.Components.MultiColumnList.MCLItemDefault
import com.Components.MultiColumnList.MCLItem;
import com.Utils.ID32;


class com.Components.MultiColumnList.MCLItemRendererDefault extends MCLItemRenderer
{
	public function MCLItemRendererDefault()
	{
		super();
        m_Background._alpha = 0;
	}
	
    public function SetSelected(selected:Boolean)
    {
        if (selected)
        {
            m_Background._alpha = 100;
        }
        else
        {
            m_Background._alpha = 0;
        }
    }
    
	public function SetData(listView:MultiColumnListView, data:MCLItem)
	{
		super.SetData(listView, data);
				
		var defaultData:MCLItemDefault = MCLItemDefault(data);
		
		var columns:Array = listView.GetColumnTable();
		var values:Object = defaultData.GetValues();
		
		var columnX:Number = 0;
		for (var i:Number = 0; i < columns.length; i++)
		{
			if (columns[i].IsDisabled())
			{
				continue;
			}
			
			var value:MCLItemValue = values[columns[i].m_Id];
			var columnRenderer:MCLBaseCellRenderer;
			switch(value.m_Type)
			{
				case MCLItemDefault.LIST_ITEMTYPE_STRING:
				case MCLItemDefault.LIST_ITEMTYPE_NUMBER:
                case MCLItemDefault.LIST_ITEMTYPE_STRING_SORT_BY_NUMBER:
					columnRenderer = CreateTextRenderer(columns[i].m_Id, value.m_Value, columns[i].m_Width);
					break;
				case MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_SYMBOL:
                    if (value.m_Value.m_MovieClips != undefined && value.m_Value.m_MovieClips.length > 0)
                    {
                        columnRenderer = CreateMovieClipRenderer(columns[i].m_Id, value.m_Value.m_MovieClips, columns[i].m_Width);
                    }
                    else
                    {
                        columnRenderer = CreateMovieClipRenderer(columns[i].m_Id, value.m_Value.m_MovieClipName, columns[i].m_Width);
                    }
					break;;
				case MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_RDB:
					columnRenderer = CreateMovieClipRenderer(columns[i].m_Id, value.m_Value.m_MovieClipRDBID, columns[i].m_Width);
					break;
				case MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT:
					columnRenderer = CreateMovieClipAndTextRenderer(columns[i].m_Id, value.m_Value, columns[i].m_Width);
					break;
			}
			
			columnRenderer.SetPos(columnX, 0);
			m_ColumnViews.push(columnRenderer);
			columnX += columns[i].m_Width + listView.GetHeaderSpacing();
		}
	}
}