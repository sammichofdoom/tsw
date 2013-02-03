/* * * * * * * * * *
 *                 *
 *  USAGE EXAMPLE  *
 *                 *
 * * * * * * * * * *

    //Constants
    private static var RIGHT_CLICK_MOUSE_OFFSET:Number = 5;
    
    //On Load
    private function onLoad():Void
    {
        m_RightClickMenu = attachMovie("RightClickMenu", "m_RightClickMenu", getNextHighestDepth());
        m_RightClickMenu.SignalRightClickMenuSelect.Connect(SlotRightClickMenuSelect, this);
        m_RightClickMenu.width = 150;
        
        var dataProvider:Array = new Array();
        dataProvider.push(new RightClickItem("Funcom Locations", true, RightClickItem.CENTER_ALIGN));
        dataProvider.push(RightClickItem.separator());
        dataProvider.push(new RightClickItem("Montreal, Canada", false, RightClickItem.LEFT_ALIGN));
        dataProvider.push(new RightClickItem("Oslo, Norway", false, RightClickItem.LEFT_ALIGN));
        dataProvider.push(new RightClickItem("Zurich, Switzerland", false, RightClickItem.LEFT_ALIGN));
        dataProvider.push(new RightClickItem("Durham, USA", false, RightClickItem.LEFT_ALIGN));
        dataProvider.push(new RightClickItem("Beijing, China", false, RightClickItem.LEFT_ALIGN));
        dataProvider.push(new RightClickItem("Badhoevedorp, Netherlands", false, RightClickItem.LEFT_ALIGN));
        
        m_RightClickMenu.dataProvider = dataProvider;
        
        this.onMousePress = Delegate.create(this, onMousePress);
    }
    
    //On Mouse Press
    private function onMousePress(buttonIndex:Number, clickCount:Number) : Void
    {
        switch (buttonIndex)
        {
            case 1:     if (!m_RightClickMenu.hitTest(_root._xmouse, _root._ymouse))
                        {
                            m_RightClickMenu.Hide();
                        }
                        
                        break;
                        
            case 2:     if (!m_RightClickMenu._visible)
                        {
                            m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET;
                            m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET;

                            m_RightClickMenu.Show();
                        }
                        else 
                        {
                            if (m_RightClickMenu.hitTest(_root._xmouse, _root._ymouse))
                            {
                                m_RightClickMenu.Hide();
                            }
                            else
                            {
                                m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET;
                                m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET;
                            }
                        }
        }
    }

    //Slot Right Click Menu Select
    private function SlotRightClickMenuSelect(label:String, isHeadline:Boolean, alignment:String, isSeparator:Boolean):Void
    {        
        m_RightClickMenu.Hide();
    }
    
*/
    

//Imports
import com.Components.RightClickItemRenderer;
import com.Utils.Signal;

//Class
dynamic class com.Components.RightClickMenu extends MovieClip
{
    //Constants
    private static var ITEM_CONTAINER_OFFSET:Number = 8;
    private static var BACKGROUND_FILL_OFFSET:Number = 2;
    
    //Properties    
    private var m_Width:Number;
    private var m_DataProvider:Array;
    private var m_ItemsContainer:MovieClip;
    private var m_Stroke:MovieClip;
    private var m_Fill:MovieClip;
    
    private var m_HandleClose:Boolean;
    
    public var SignalWantToClose:Signal;
            
    //Constructor
    public function RightClickMenu()
    {
        super();
        
        _visible = false;
        
        m_HandleClose = true;
        
        SignalWantToClose = new Signal;
        
        m_Fill.onPress = function() {}; //to avoid clicking through the menu
    }
    
    //On Mouse Press
    private function onMousePress(buttonIndex:Number, clickCount:Number):Void
    {
        if (buttonIndex == 2)
        {
            Hide();
        }
    }
    
    private function onMouseDown()
    {
        if (!this.hitTest(_root._xmouse, _root._ymouse))
        {
            CloseSelf();
        }
    
    }
    
    //Set if this menu should close itself when it wants, or if it should be handled by someone else
    public function SetHandleClose(handleClose:Boolean)
    {
        m_HandleClose = handleClose;
    }
    
    private function CloseSelf()
    {
        if (m_HandleClose)
        {
            this.removeMovieClip();
        }
        else
        {
            SignalWantToClose.Emit();
        }
    }
    
    //Set Width
    public function set width(value:Number):Void
    {
        m_Width = value;
        
        m_Stroke._width = value;
        m_Fill._width = value - BACKGROUND_FILL_OFFSET;
        
        if (m_DataProvider)
        {
            dataProvider = m_DataProvider;
        }
    }
    
    //Get Width
    public function get width():Number
    {
        return m_Width;
    }
    
    private function SlotClickedItem()
    {
        CloseSelf();
    }
    
    //Set Data Provider
    public function set dataProvider(value:Array):Void
    {
        m_DataProvider = value;
        
        if (m_ItemsContainer)
        {
            m_ItemsContainer.removeMovieClip();
            m_ItemsContainer = null;
        }
        
        m_ItemsContainer = createEmptyMovieClip("m_ItemsContainer", getNextHighestDepth());
                
        for (var i:Number = 0; i < m_DataProvider.length; i++)
        {
            var itemRenderer:MovieClip = m_ItemsContainer.attachMovie("RightClickItemRenderer", "m_RightClickItemRenderer_" + i, m_ItemsContainer.getNextHighestDepth());
            itemRenderer.SetRightClickItem(m_DataProvider[i]);
            m_DataProvider[i].SignalItemClicked.Connect(SlotClickedItem, this);
            
            itemRenderer.m_Background._width = m_Width - ITEM_CONTAINER_OFFSET * 2;
            itemRenderer.m_Separator._width = m_Width - ITEM_CONTAINER_OFFSET * 2;
            itemRenderer.m_Label._width = m_Width - itemRenderer.m_Label._x * 2 - ITEM_CONTAINER_OFFSET * 2;
        }
        
        var previousItemRenderer:MovieClip
        
        for (var i:Number = 0; i < m_DataProvider.length; i++)
        {          
            var itemRenderer:MovieClip = m_ItemsContainer.getInstanceAtDepth(i);
            
            if (i == 0)
            {
                itemRenderer._y = 0;
            }
            else
            {
                if (previousItemRenderer.isSeparator)
                {
                    itemRenderer._y = previousItemRenderer._y + previousItemRenderer.m_Separator._height;
                }
                else
                {
                    itemRenderer._y = previousItemRenderer._y + previousItemRenderer.m_Background._height;
                }
            }
            
            previousItemRenderer = itemRenderer;
        }
        
        m_ItemsContainer._x = m_ItemsContainer._y = ITEM_CONTAINER_OFFSET;
        
        m_Stroke._height = m_ItemsContainer._height + ITEM_CONTAINER_OFFSET * 2;
        m_Fill._height = m_Stroke._height - BACKGROUND_FILL_OFFSET;
    }
    
    //Get Data Provider
    public function get dataProvider():Array
    {
        return m_DataProvider;
    }

    //Show
    public function Show():Void
    {
        /*if (m_DataProvider)
        {
            dataProvider = m_DataProvider;
        }*/
        
        _visible = true;
    }
    
    //Hide
    public function Hide():Void
    {
        _visible = false;
    }
}