import flash.geom.Rectangle;
import gfx.core.UIComponent;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.GameInterface.LoreNode;
import com.Utils.ID32;
import mx.transitions.easing.*;
import gfx.motion.Tween;
import GUI.Achievement.LorePanelView;
import com.GameInterface.Lore;
import mx.utils.Delegate;
import com.GameInterface.Game.Character;
import com.GameInterface.DistributedValue;
import com.GameInterface.LoreBase;
import com.Utils.Colors;

class GUI.Achievement.AchievementWindow extends UIComponent
{
    private var m_ResizeButton:MovieClip
    private var m_Background:MovieClip;
    private var m_ButtonBar:MovieClip;
    private var m_CloseButton:MovieClip;
    private var m_HelpButton:MovieClip;
    private var m_Divider:MovieClip;
    private var m_MainProgress:MovieClip;
    private var m_SearchBox:MovieClip;
    private var m_TotalPoints:MovieClip;
    
    public static var ACHIEVEMENT:Number = 0;
    public static var LORE:Number = 1;
    public static var TITLE:Number = 2;
    public static var TUTORIAL:Number = 3;

    private var m_IsResizing:Boolean = false;

    private var m_ViewY:Number;
    private var m_MenuY:Number;
    private var m_ProgressY:Number;
    private var m_MenuAllowedHeight:Number;
    private var m_ViewAllowedHeight:Number;

    private var m_CurrentSizePos:Rectangle;
    private var m_MenuWidth:Number;
    private var m_ViewWidth:Number;
    private var m_MinWindowWidth:Number = 670;
    private var m_MinWindowHeight:Number = 400;
    private var m_MenuScrollbarEnabled:Boolean;
    private var m_ViewScrollbarEnabled:Boolean;
    
    private var m_Padding:Number = 10;

    private var m_ViewScrollbar:MovieClip;
    private var m_ViewMask:MovieClip;
    private var m_MenuScrollbar:MovieClip;
    private var m_MenuMask:MovieClip;
    private var m_AchievementProgress:MovieClip;

    private var m_CurrentTreeRootNode:LoreNode;
    private var m_CurrentSelectedNode:LoreNode;
    
    private var m_LoreDataNode:LoreNode;
    private var m_AchievementDataNode:LoreNode;

    private var m_TDB_Achievements:String;
    private var m_TDB_Lore:String;

    private var m_CurrentTab:Number;
    private var m_CurrentView:MovieClip;
    private var m_CurrentViewPanel:MovieClip;

    private var m_PanelLinkage:String;
    private var m_CurrentMenu:MovieClip;

    public var SignalClose:Signal;
    private var m_NodeFocus:DistributedValue;
    
    public static var SignalTagRead:Signal;
    var m_TabButtonArray:Array;
	
	public function onUnload()
	{
		super.onUnload();
		LoreBase.StopTagSound();
	}
        
    public function AchievementWindow()
    {
     //   super();
        m_TDB_Achievements = LDBFormat.LDBGetText( "AchievementGUI", "Achievements" ).toUpperCase();
        m_TDB_Lore = LDBFormat.LDBGetText( "AchievementGUI", "Lore" ).toUpperCase();

        m_NodeFocus = DistributedValue.Create( "achievement_window_focus" );
        m_NodeFocus.SignalChanged.Connect(SlotSetNodeFocus, this);
        
        m_TabButtonArray = [];
        m_TabButtonArray[ACHIEVEMENT] = { label:m_TDB_Achievements, view:"AchievementViewPanel"};
        m_TabButtonArray[LORE] = { label:m_TDB_Lore, view:"LoreViewPanel" };
        
        m_CurrentTab = -1;
    }
    
    public function configUI()
    {
		super.configUI();
     //   m_TreeViewY = 35;
        m_ViewY = 70
        m_MenuY = 70;
        m_ProgressY = 47;
        m_MenuWidth = 200;
        m_CurrentSizePos = new Rectangle(100, 100, 600, 600);
        
        SignalClose = new Signal();
        SignalTagRead = new Signal();        
        Lore.SignalTagAdded.Connect(SlotTagAdded, this);
        
        m_ResizeButton.onMousePress = Delegate.create(this, SlotResizePress);
        m_ResizeButton.onPress = function() {}
        m_ResizeButton.onMouseUp = Delegate.create(this, SlotResizeRelease);
        m_ResizeButton.onMouseMove = Delegate.create(this, SlotResizeMove);
        m_ResizeButton.disableFocus = true;
        m_ResizeButton._alpha = 40;

        InitTabs();
        
        m_Background.onPress = Delegate.create(this, StartDragAchievementWindow);
        m_Background.onReleaseOutside = Delegate.create(this, StopDragAchievementWindow);
        m_Background.onRelease = Delegate.create(this, StopDragAchievementWindow);

        m_CloseButton.addEventListener("click", this, "SlotCloseWindow");
        m_HelpButton.addEventListener("click", this, "HelpButtonClickedEventHandler");
        
        var visibleRect = Stage["visibleRect"];
        
        //m_NodeFocus.SetValue( this["tabIdFocus" + tabIndex] );
        SetTabFocus( GetTabId( m_NodeFocus.GetValue() ) );
        
        SlotSetNodeFocus();
        CreateView();
        SlotNodeSelected();
        Layout();
    }

    private function ResizeWindow()
    {
        m_CurrentSizePos.height = Math.max(this._ymouse, m_MinWindowHeight);
        m_CurrentSizePos.width = Math.max(this._xmouse, m_MinWindowWidth);
        
        Layout();
    }
    
    public function SetSize(rect:Rectangle)
    {
        m_CurrentSizePos = rect;
        Layout();
    }
    
    public function GetSize():Rectangle
    {
        return m_CurrentSizePos;
    }
    
    private function SlotSetNodeFocus()
    {
        var focus:Number = m_NodeFocus.GetValue();

        if (Lore.IsValidId(focus))
        {
            var tabId:Number = GetTabId(focus);
            this["tabIdFocus" + tabId] = focus;
            SetTabFocus( tabId );
            
            SlotNodeSelected();
            ScrollToSelected();
        }      
    }
    
    private function GetTabId(tagId:Number)
    {
        if (Lore.IsValidId(tagId))
        {
            var loreNodeType:Number = Lore.GetTagCategory(tagId)
            switch(loreNodeType)
            {
                case _global.Enums.LoreNodeType.e_Achievement:
                    return ACHIEVEMENT;
                case _global.Enums.LoreNodeType.e_Lore:
                    return LORE;
//                case _global.Enums.LoreNodeType.e_Title:
//                    return TITLE;
            }
        }
        return -1;
    }
    
    private function GetHeaderId(tabIndex:Number)
    {
        var newId:Number = -1; 
        if (tabIndex == LORE)
        {
            newId = Lore.GetHeaderNodeId( _global.Enums.LoreNodeType.e_HeaderLore );
        }
        else if (tabIndex == ACHIEVEMENT)
        {
            newId = Lore.GetHeaderNodeId( _global.Enums.LoreNodeType.e_HeaderAchievement );
        }
        else if (tabIndex == TITLE)
        {
            newId = Lore.GetHeaderNodeId( _global.Enums.LoreNodeType.e_HeaderTitle );
        }
        else if (tabIndex == TUTORIAL)
        {
            newId = Lore.GetHeaderNodeId( _global.Enums.LoreNodeType.e_HeaderTutorial );
        }
        return newId;
    }
    
    public function SetTabFocus(focus:Number)
    {
        var newFocus:Number;
        if (focus != -1)
        {
            newFocus = focus;
        }
        else
        {
            newFocus = (m_CurrentTab == undefined || m_CurrentTab == -1) ? ACHIEVEMENT : m_CurrentTab;    
        }

        if (newFocus != m_CurrentTab)
        {
            m_CurrentTab = newFocus;
            m_ButtonBar.selectedIndex = m_CurrentTab;
            CreateView();
            Layout();
        }
    }

    public function GetTabFocus()
    {
        return m_CurrentTab;
    }

    private function Layout()
    {
        _x = m_CurrentSizePos.x;
        _y = m_CurrentSizePos.y;
        
        m_ViewWidth = m_CurrentSizePos.width - (m_MenuWidth + (3 * m_Padding));
        
        m_MenuAllowedHeight = m_CurrentSizePos.height - m_ViewY - m_Padding;
        
        m_Background._width = m_CurrentSizePos.width;
        m_Background._height = m_CurrentSizePos.height;
        
        m_ResizeButton._y = m_CurrentSizePos.height - m_ResizeButton._height; 
        m_ResizeButton._x = m_CurrentSizePos.width - m_ResizeButton._width
        
        m_CloseButton._x = m_CurrentSizePos.width - m_CloseButton._width - m_Padding;
        
        m_HelpButton._x = m_CloseButton._x - m_HelpButton._width - 5;
        m_HelpButton._y = m_CloseButton._y;
        
        m_Divider._x = m_Padding;
        m_Divider._width = m_CurrentSizePos.width - (2 * m_Padding);

        m_ViewAllowedHeight = m_CurrentSizePos.height - (2 * m_Padding);
        
        if (m_CurrentTab == LORE)
        {
            m_MainProgress._x = m_MenuWidth + (2 * m_Padding)
            m_MainProgress._y = m_ProgressY;
            m_MainProgress.m_Background._width = m_ViewWidth;
            m_MainProgress.m_CounterText._x = m_ViewWidth - m_MainProgress.m_CounterText._width - 5
            
            if (m_CurrentSelectedNode != undefined)
            {
                UpdateProgressView(m_CurrentSelectedNode, m_MainProgress);
            }
            m_ViewAllowedHeight -= (m_ProgressY + m_MainProgress._height);
        
            
        }
        else if (m_CurrentTab == ACHIEVEMENT)
        {
            m_AchievementProgress._x = m_MenuWidth + (2 * m_Padding)
            m_AchievementProgress._y = m_ProgressY;
            m_AchievementProgress.m_Background._width = m_ViewWidth;
            m_AchievementProgress.m_BarBackground._width = m_ViewWidth - 15;
            m_AchievementProgress.m_CompletionText._x = (m_ViewWidth - m_AchievementProgress.m_CompletionText._width) * 0.5;
            

            UpdateAchievementProgressView()

            m_ViewAllowedHeight -= (m_ProgressY + m_AchievementProgress._height);
            m_MainProgress._visible = false;
        }

        if (m_CurrentViewPanel != undefined)
        {
            m_CurrentViewPanel.SetSize(m_ViewWidth, m_ViewAllowedHeight);
            m_CurrentView.m_ViewPanelBackground._width = m_ViewWidth;
            m_CurrentView.m_ViewPanelBackground._height = m_ViewAllowedHeight;
            UpdateViewScrollBar();
            ScrollToSelected();
        }
        
        if (m_CurrentMenu.m_TreeView != undefined)
        {
            m_CurrentMenu.m_TreeView.SetSize( m_MenuWidth, m_MenuAllowedHeight, true);
            UpdateMenuScrollBar()
        }
    }
    
    private function SetAchievementProgress(node:LoreNode)
    {
            m_AchievementProgress
    }
    
    private function ScrollToSelected()
    {        
        if (m_ViewScrollbar != undefined)
        {
            var scrollPos:Number = 0;
            var yPos = m_CurrentViewPanel.GetYPos(m_NodeFocus.GetValue());
            if (yPos > 0)
            {
                var windowScrollRange = m_CurrentViewPanel._height - m_ViewMask._height;
                var barScrollRange = m_ViewScrollbar.maxPosition;
                scrollPos = yPos - (m_ViewMask._height / 2);
                scrollPos = scrollPos * barScrollRange / windowScrollRange;
                scrollPos = Math.max(0, Math.min(scrollPos, barScrollRange));
            }
            m_ViewScrollbar.position = scrollPos;
        }
    }

    private function InitTabs()
    {
        m_ButtonBar.addEventListener("focusIn", this, "RemoveFocus");
        
        m_ButtonBar.tabChildren = false;
        m_ButtonBar.itemRenderer = "TabButtonLight";
        m_ButtonBar.direction = "horizontal";
        m_ButtonBar.spacing = -10;
        m_ButtonBar.autoSize = true;
        m_ButtonBar.dataProvider = m_TabButtonArray;
        m_ButtonBar.selectedIndex = m_CurrentTab;
        m_ButtonBar.addEventListener("change", this, "TabSelected");
        
        TabSelected();
    }

    private function SlotTagAdded(tagId:Number, character:ID32)
    {
        if ( character.Equal( Character.GetClientCharID()))
        {
            var dataNode:LoreNode = Lore.GetDataNodeById(tagId);
            if(dataNode == null) /// still not valid, print message and return
            {
                return;
            }
            
            dataNode.m_HasCount     = Lore.GetCounterCurrentValue(tagId);
            dataNode.m_Locked       = Lore.IsLocked(tagId);
            
            var parentNode:LoreNode = dataNode.m_Parent;
            while (parentNode != null)
            {
                parentNode.m_HasCount     = Lore.GetCounterCurrentValue(parentNode.m_Id);
                parentNode.m_Locked       = Lore.IsLocked(parentNode.m_Id);
                
                parentNode = parentNode.m_Parent;
            }
            var dataNode:LoreNode = CreateDataNode( m_CurrentTab, true );
            m_CurrentMenu.m_TreeView.SetData(dataNode, true);
            
            UpdateProgressView(m_CurrentSelectedNode, m_MainProgress);
        }
    }
   
    private function TabSelected(event:Object)
    {
        var tabIndex = (event != undefined && event.index != undefined) ? event.index : ACHIEVEMENT;
        if (tabIndex == m_CurrentTab)
        {
            return;
        }
        
        var focus:Number = m_NodeFocus.GetValue();
        if (this["tabIdFocus" + tabIndex] != undefined)
        {
            m_NodeFocus.SetValue( this["tabIdFocus" + tabIndex] );
        }
        else
        {
            var headerId:Number = GetHeaderId(tabIndex);
            m_NodeFocus.SetValue( headerId );
        }
        
        ScrollToSelected();
    }

    private function CreateView()
    {
        var currentNode:LoreNode = CreateDataNode( m_CurrentTab, true );
        var nodeId:Number = currentNode.m_Id

        if (nodeId == m_CurrentTreeRootNode.m_Id)
        {
            return;
        }
        m_CurrentTreeRootNode = currentNode; // CreateDataNode( m_CurrentTab, false );

        /// Add view specific extras
        if (m_CurrentTab == LORE)
        {
            m_SearchBox._visible = false; // search disbled
            //m_SearchBox._x = m_Padding;
            //m_SearchBox._y = m_ProgressY;
            
            m_AchievementProgress._visible = false;
            m_MainProgress._visible = true;
            
            m_TotalPoints._visible = false;
            m_AchievementProgress._visible = false;
            m_MainProgress._visible = true;
            
            m_ViewY = 70;
        }
        else if(m_CurrentTab == ACHIEVEMENT)
        {
            m_SearchBox._visible = false;
            
            m_TotalPoints._visible = true;
            m_TotalPoints._x = m_Padding;
            m_TotalPoints._y = m_ProgressY;
            
            m_TotalPoints.m_NameTextField.htmlText = LDBFormat.LDBGetText( "GenericGUI", "Total" );
            m_TotalPoints.m_NumberTextfield.htmlText = m_CurrentTreeRootNode.m_HasCount + "/" + m_CurrentTreeRootNode.m_TargetCount;
            
            m_AchievementProgress._visible = true;
            m_MainProgress._visible = false;
            
            m_ViewY = 120;

            /// setting the color of the top progressbar
            var backgroundGradientFrom:String = Lore.GetBackgroundGradientFrom(nodeId);
            var backgroundGradientTo:String = Lore.GetBackgroundGradientTo(nodeId);
            var foregroundGradientFrom:String = Lore.GetForegroundGradientFrom(nodeId);
            var foregroundGradientTo:String = Lore.GetForegroundGradientTo(nodeId);
            
            var backgroundFromColor:Number = ( backgroundGradientFrom != "" ) ? com.GameInterface.UtilsBase.ParseHTMLColor( backgroundGradientFrom ) : 0x36acea;
            var backgroundToColor:Number = ( backgroundGradientTo != "" ) ? com.GameInterface.UtilsBase.ParseHTMLColor( backgroundGradientTo ) : 0x0375be;
            var foregroundFromColor:Number = ( foregroundGradientFrom != "" ) ? com.GameInterface.UtilsBase.ParseHTMLColor( foregroundGradientFrom ) : 0x1c4f64;
            var foregroundToColor:Number = ( foregroundGradientTo != "" ) ? com.GameInterface.UtilsBase.ParseHTMLColor( foregroundGradientTo ) : 0x132b43;
            
            Colors.ApplyColor(m_AchievementProgress.m_Bar.background, backgroundFromColor );
            Colors.ApplyColor(m_AchievementProgress.m_Bar.highlight, backgroundToColor);
            
            Colors.ApplyColor(m_AchievementProgress.m_Background.highlight, foregroundFromColor);
            Colors.ApplyColor(m_AchievementProgress.m_Background.background, foregroundToColor);
            
            UpdateAchievementProgressView();
        }
        
        /// Remove the old and create a new menu
        if (m_CurrentMenu != undefined)
        {
            m_CurrentMenu.removeMovieClip();
        }
        
        m_CurrentMenu = createEmptyMovieClip("m_Menu", getNextHighestDepth());
        m_CurrentMenu.attachMovie( "Treeview", "m_TreeView", m_CurrentMenu.getNextHighestDepth());
        m_CurrentMenu.m_TreeView.SetSize(m_MenuWidth, m_MenuAllowedHeight, false );
        m_CurrentMenu.m_TreeView.SetData(m_CurrentTreeRootNode, true);
        m_CurrentMenu.m_TreeView.SizeChanged.Connect( UpdateMenuScrollBar, this);
        m_CurrentMenu._x = m_Padding;
        m_CurrentMenu._y = m_MenuY;
        
        /// update the main progressbar
        m_MainProgress.m_PanelNameText.text = m_CurrentTreeRootNode.m_Name;
        UpdateProgressView(m_CurrentTreeRootNode, m_MainProgress);

        var panelRenderer:String = m_TabButtonArray[ m_CurrentTab ].view;
        
        if(m_CurrentTab == ACHIEVEMENT)
        {
            UpdateAchievementProgressView();
        }
        
        /// remove the old and create a new view
        if (m_CurrentView != undefined)
        {
            m_CurrentView.removeMovieClip();
        }
        m_CurrentView = createEmptyMovieClip("m_View", getNextHighestDepth());
        m_CurrentView.attachMovie("ViewPanelBackground", "m_ViewPanelBackground", m_CurrentView.getNextHighestDepth());
        m_CurrentView.m_ViewPanelBackground.onPress = function() { };
        m_CurrentViewPanel = m_CurrentView.attachMovie(panelRenderer, "m_ViewPanel_" + MovieClip(this).UID(), m_CurrentView.getNextHighestDepth());
        m_CurrentViewPanel.SignalMediaAdded.Connect( UpdateViewScrollBar, this);
        m_CurrentViewPanel.SignalClicked.Connect(SlotAchievementClicked, this);
        m_CurrentView._x = m_MenuWidth + (2 * m_Padding);
        m_CurrentView._y = m_ViewY;
    }
    
    private function SlotAchievementClicked()
    {
        UpdateViewScrollBar();
    }
    
    private function SlotNodeSelected()
    {
		LoreBase.StopTagSound();
        var id:Number = m_NodeFocus.GetValue();
        m_CurrentSelectedNode = Lore.GetDataNodeById(id);
        m_CurrentViewPanel.SetData(m_CurrentSelectedNode);
        
        UpdateViewScrollBar();
                
        if (m_CurrentSelectedNode != null)
        {
            if (m_CurrentTab == LORE)
            {
                UpdateProgressView(m_CurrentSelectedNode, m_MainProgress);
            }
            else if (m_CurrentTab == ACHIEVEMENT)
            {
                UpdateAchievementProgressView();
            }
        }
    }

    private function UpdateMenuScrollBar()
    {
        m_MenuScrollbarEnabled = ScrollBar(m_CurrentMenu, m_CurrentMenu.m_TreeView, m_MenuAllowedHeight, m_MenuWidth, "m_MenuScrollbar", "m_MenuMask", m_MenuY);
    }

    private function UpdateViewScrollBar()
    {
        m_ViewScrollbarEnabled = ScrollBar(m_CurrentView, m_CurrentViewPanel, m_ViewAllowedHeight, m_ViewWidth, "m_ViewScrollbar", "m_ViewMask", m_ViewY); 
    }

    private function ScrollBar(parent:MovieClip, target:MovieClip, maxHeight:Number, width:Number, scrollbarName:String, maskName:String, defaultY:Number) : Boolean
    {
        var isScrollBar:Boolean = false;
        if (target != undefined)
        {
            var scrollbarPos:Number = 0;
            if (this[scrollbarName] != undefined)
            {
                if (m_IsResizing)
                {
                    target._y = 0;
                }
                if (this[scrollbarName].position != 0)
                {
                    scrollbarPos = this[scrollbarName].position / this[scrollbarName].maxPosition;
                }
                this[scrollbarName].removeEventListener("scroll", this, "OnScrollbarUpdate");
                this[scrollbarName].removeMovieClip();
                this[scrollbarName] = undefined;
            }
            if (this[maskName] != undefined)
            {
                this[maskName].removeMovieClip();
                target.setMask( null );
                this[maskName] = undefined;
            }
            if ( target._height > maxHeight && target._visible )
            {
                this[maskName] = com.GameInterface.ProjectUtils.SetMovieClipMask(target, parent, maxHeight, width);
                this[maskName]._y = 0; // this must be here. see ProjectUtils.as
                this[scrollbarName] = parent.attachMovie("ScrollBar", "m_Scrollbar", parent.getNextHighestDepth());
                this[scrollbarName]._x = width - 6;
                var maxScroll:Number = Math.ceil((target._height - maxHeight) / 10);
                this[scrollbarName].setScrollProperties( 10, 0, maxScroll); 
                this[scrollbarName]._height = maxHeight;
                this[scrollbarName].addEventListener("scroll", this, "OnScrollbarUpdate");
                this[scrollbarName].position = scrollbarPos * maxScroll;
                this[scrollbarName].trackMode = "scrollPage";
                this[scrollbarName].trackScrollPageSize = maxHeight;
                this[scrollbarName].disableFocus = true;
                this[scrollbarName].target = target;
                this[scrollbarName]._visible = true;
                this[scrollbarName].update();
                //if (scrollbar.target.ID != target.ID)
                //{
                //  scrollbar.position = 0;
                //}
                Mouse.addListener( this );
                isScrollBar = true;
            }
            else
            {
                target._y = 0;
                parent._y = defaultY
                isScrollBar = false;
            }
        }
        return isScrollBar;
    }

    /// listrens for scrollwheel and updates the correct area
    private function onMouseWheel( delta:Number )
    {
        var event:Object

        if (Mouse["IsMouseOver"]( m_CurrentMenu ) && m_MenuScrollbarEnabled)
        {
            var newPos:Number = m_MenuScrollbar.position + -(delta);
            event = { target : m_MenuScrollbar };
            
            m_MenuScrollbar.position = Math.min(Math.max(0.0, newPos), m_MenuScrollbar.maxPosition);
        }
        else if (Mouse["IsMouseOver"]( m_CurrentView ) && m_ViewScrollbarEnabled)
        {
            var newPos:Number = m_ViewScrollbar.position + -(delta);
            event = { target : m_ViewScrollbar };
            
            m_ViewScrollbar.position = Math.min(Math.max(0.0, newPos), m_ViewScrollbar.maxPosition);
        }
        
        OnScrollbarUpdate(event);
    }

    private function OnScrollbarUpdate(event:Object) : Void
    {
        var target:MovieClip = event.target;
        var pos:Number = event.target.position;
        
        if (target == m_MenuScrollbar)
        {
            m_CurrentMenu.m_TreeView._y = -(pos * 10);
        }
        else if (target == m_ViewScrollbar)
        {
            m_CurrentViewPanel._y = -(pos * 10 );
        }
        
        Selection.setFocus( null );
    }
    
    private function UpdateAchievementProgressView()
    {
        var max:Number = m_CurrentSelectedNode.m_TargetCount;
        var current:Number = m_CurrentSelectedNode.m_HasCount;

        m_AchievementProgress.m_CompletionText.htmlText = current + "/" + max
        if (current > 0)
        {
            m_AchievementProgress.m_Bar._visible = true;
            m_AchievementProgress.m_Bar._width = (m_ViewWidth - 19) * (current / max);
        }
        else
        {
            m_AchievementProgress.m_Bar._visible = false;
        }

        m_AchievementProgress.m_MainText.htmlText = "<b>" + Lore.GetTagName( m_CurrentSelectedNode.m_Id ) + "</b>";
    }

    /// updates the progressbar for all views that use it
    private function UpdateProgressView(inputNode:LoreNode, progressBar:MovieClip)
    {
        var dataNode:LoreNode = Lore.GetFirstNonLeafNode(Lore.GetDataNodeById(inputNode.m_Id)); // ensure fresh data
        var max:Number = dataNode.m_TargetCount;
        var current:Number = dataNode.m_HasCount;
        
        progressBar.m_CounterText.text = current + "/" + max;

        var percent:Number = (max / current)
        
        var realSize:Number = progressBar.m_Background._width -8;

        progressBar.m_Progress._width = realSize * (current / max);
        progressBar.m_Text.text = dataNode.m_Name.toUpperCase();
    }

    /// Returns a LoreNode obejct, but this is cached, so only retrieves when its not there or being forced
    private function CreateDataNode(type:Number, forceLoad:Boolean) : LoreNode
    {
        if (type == ACHIEVEMENT)
        {
            if (m_AchievementDataNode == undefined || forceLoad)
            {
                m_AchievementDataNode = Lore.GetAchievementTree();
            }
            return m_AchievementDataNode;
        }
        else if (type == LORE)
        {
            if (m_LoreDataNode == undefined || forceLoad)
            {
                m_LoreDataNode = Lore.GetLoreTree();
            }
            return m_LoreDataNode;
        }
        else
        {
            trace("Data node type not supported, aborting");
        }
    }

    private function RemoveFocus():Void
    {
        Selection.setFocus(null);
    }
    
    
    private function SlotCloseWindow(event:Object)
    {
        SignalClose.Emit()
    }
    
    private function HelpButtonClickedEventHandler():Void
    {
        Selection.setFocus(null);
        
        LoreBase.OpenTag(5220)
    }

    private function SlotResizePress()
    {
        if (Mouse["IsMouseOver"](m_ResizeButton))
        {
            m_IsResizing = true;
        }
    }

    private function SlotResizeRelease()
    {
        if (m_IsResizing)
        {
            m_IsResizing = false;
        }
    }

    private function SlotResizeMove()
    {
        if (m_IsResizing)
        {
            ResizeWindow();
        }
    }

    private function StartDragAchievementWindow()
    {
        startDrag(this, false, -_width + 40, -_height + 40, Stage.width - 40, Stage.height-40);
    }

    private function StopDragAchievementWindow()
    {
        this.stopDrag();
        m_CurrentSizePos.x = this._x;
        m_CurrentSizePos.y = this._y;
    }
}