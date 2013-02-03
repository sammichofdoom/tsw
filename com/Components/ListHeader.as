import flash.geom.Point;
import com.Utils.Signal;
import com.Utils.Colors;

class com.Components.ListHeader extends MovieClip
{
    private var m_ListItems:Array;
    private var m_ListSize:Point;
    private var m_CurrentSize:Point
    private var m_ListItemRenderer:String;
    
    public var m_Background:MovieClip;
    
    public static var SORTORDER_NONE:Number = 0;
    public static var SORTORDER_ASC:Number = 1;
    public static var SORTORDER_DESC:Number = 2;
    
    private var m_SelectedColor:Number = 0x555555;
    private var m_OverColor:Number = 0x454545;
    private var m_LineColor:Number = 0x555555;
    private var m_LineThickness:Number = 2;
    
    public var SignalClicked:Signal;
    
    public function ListHeader()
    {
        m_ListItems = []; 
        m_CurrentSize = new Point(0, 0);
        m_ListItemRenderer = "ListItemItem"
        SignalClicked = new Signal();
        
        SetListSize(this._height, this._width, false);
    }
    
    /// set a new itemrenderere
    /// @param newRenderer:String - tghe name of the list item to use
    public function SetListItemRenderer(newRenderer:String)
    {
        m_ListItemRenderer = newRenderer;
    }
    
    /// Sets a new linestyle for the dividers in the header
    /// @param thickness:Number - thickness of line in pixels
    /// @param color:Number - the new linecolor
    public function SetLineStyle(thickness:Number, color:Number)
    {
        m_LineThickness = thickness;
        m_LineColor = color;
    }
    
    /// creates a point object with the new height and width, runs layout if needed
    /// @param height:Number - the new height
    /// @param width:Number - the new width
    /// @param forceLayout:Boolean - wether to forvce redraw with the new dimensions
    public function SetListSize(height:Number, width:Number, forceLayout:Boolean)
    {
        width = (!isNaN( width) ? width : 100);
        height = (!isNaN( height) ? height : 20);
        m_ListSize = new Point(width, height);
        m_Background._width = width;
        m_Background._height = height;
        if (forceLayout)
        {
            Layout();
        }
    }
    /// adds a list item to the list and draws if forced
    /// @param	text - name of item
    /// @param	id - id, easier to find, being dispatched when clicking the item
    /// @param	width - the width of the item
    /// @param	forceLayout - draw immediately
    public function SetListItem(text:String, id:Number, width, forceLayout:Boolean)
    {
        m_ListItems.push( { name:text, id:id, width:width, sortorder:SORTORDER_NONE } );
        if (forceLayout)
        {
            Layout();
        }
    }
    
    /// Draws the ListHeader
    public function Layout()
    {
        m_CurrentSize = new Point(0, 0);
        for (var i:Number = 0; i < m_ListItems.length; i++ )
        {
            if (this["renderer_" + i] != undefined)
            {
                this["renderer_" + i].removeMovieClip();
            }
            if (i > 0)
            {
               // return;
            }
            var listItem:Object = m_ListItems[i];
            /// draw
            var item:MovieClip = attachMovie(m_ListItemRenderer, "renderer_" + i, getNextHighestDepth());
            item._x = m_CurrentSize.x;
            
            item.m_Text._width = listItem.width - 30;
            item.m_Text.text = listItem.name;
            item.m_Background._width = listItem.width;
            
            if (m_ListSize.y > 0)
            {
                item.m_Background._height = m_ListSize.y;
            }
            
            item.m_Arrows._x = listItem.width - 20;
            
            item.ref = this;
            item.id = i
            item.onRelease = function()
            {
                this["ref"].SortItems(this["id"]);
            }
            item.onRollOver = function()
            {
                this["ref"].RendererRollOver(this["id"]);
            }
            item.onRollOut = function()
            {
                this["ref"].RendererRollOut(this["id"]);
            }
            
            m_CurrentSize.x += listItem.width;

        }
        if (this["m_Lines"] != undefined)
        {
            this["m_Lines"].removeMovieClip();
        }
        var lines:MovieClip = createEmptyMovieClip("m_Lines", getNextHighestDepth());
        lines.lineStyle(m_LineThickness, m_LineColor, 100, true,"normal","none");
        
        var width:Number = 0;
        for (var i:Number = 0; i < m_ListItems.length; i++ )
        {
            if (i != m_ListItems.length - 1)
            {
                width += m_ListItems[i].width;
                
                lines.moveTo(width, 0)
                lines.lineTo(width, m_ListSize.y);
            }
        }
    }
    
    /// rollovers
    private function RendererRollOver(index:Number)
    {
        if (m_ListItems[index].sortorder == SORTORDER_NONE)
        {
           Colors.Tint( this["renderer_" + index].m_Background, m_OverColor, 100);
        }
    }
    
    /// rollouts
    private function RendererRollOut(index:Number)
    {
        if (m_ListItems[index].sortorder == SORTORDER_NONE)
        {
           Colors.Tint( this["renderer_" + index].m_Background, m_OverColor, 0);
        }
    }
    
    /// updates the visuals, toggles the sortordering and dispatches a signal
    private function SortItems(index)
    {
        /// disable the others
        for (var i:Number = 0; i < m_ListItems.length; i++)
        {
            if (i != index)
            {
                var renderer:MovieClip = this["renderer_" + i];
                
                if (m_ListItems[i].sortorder != SORTORDER_NONE)
                {
                    m_ListItems[i].sortorder = SORTORDER_NONE;
                    renderer.m_Arrows.m_Ascending._alpha = 40;
                    renderer.m_Arrows.m_Descending._alpha = 40;
                    Colors.Tint( renderer.m_Background, m_OverColor, 0);
                }
            }
        }
        
        //enable the selected
        var listItem:Object = m_ListItems[index];
        var renderer:MovieClip = this["renderer_" + index];
        
        if (listItem.sortorder == SORTORDER_NONE)
        {
            listItem.sortorder = SORTORDER_ASC;
            renderer.m_Arrows.m_Ascending._alpha = 100;
        }
        else if (listItem.sortorder == SORTORDER_ASC)
        {
            listItem.sortorder = SORTORDER_DESC;
            renderer.m_Arrows.m_Ascending._alpha = 40;
            renderer.m_Arrows.m_Descending._alpha = 100;
        }
        else if (listItem.sortorder == SORTORDER_DESC)
        {
            listItem.sortorder = SORTORDER_ASC;
            renderer.m_Arrows.m_Ascending._alpha = 100;
            renderer.m_Arrows.m_Descending._alpha = 40;
        }
        
        Colors.Tint( renderer.m_Background, m_SelectedColor, 100);
        
        SignalClicked.Emit(listItem.id, listItem.sortorder);
    }
}