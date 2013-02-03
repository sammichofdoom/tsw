//Imports
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.Utils.LDBFormat;
import GUI.Team.RaidClip;
import flash.geom.Point;

//Class
class GUI.Team.TeamMenu extends MovieClip
{
    //Properties
    private var m_RaidClip:RaidClip;
    
    private var m_MenuItems:Array;
    private var m_GroupItems:Array;
    private var m_WindowFrameLocked:Boolean;
    private var m_ShowWindow:Boolean;
    private var m_ShowWindowFrame:Boolean;
    private var m_ShowGroupNames:Boolean;
    private var m_ShowHPNumbers:Boolean;
    private var m_ShowHealthBar:Boolean;
    private var m_ShowNametagIcons:Boolean;
    private var m_IsGroupDetached:Boolean;
    
    private var m_ShowWindowText:String;
    private var m_LockWindowFrameText:String;
    private var m_ShowWindowFrameText:String;
    private var m_ShowGroupNamesText:String;
    private var m_TDB_Show:String;
    private var m_TDB_Hide:String;
    private var m_TDB_ShowAll:String;
    private var m_ShowMaxMinHpText:String;
    private var m_ShowHealthBarText:String;
    private var m_ShowNametagIconsText:String;
    
    private var m_LastClicked:String;
    private var m_CurrentClicked:String;
    
    //Constructor
    public function TeamMenu()
    {
        super();
        
        Mouse.addListener(this);
        Key.addListener(this);
        
        m_TDB_Show = LDBFormat.LDBGetText("TeamGUI", "Show");
        m_TDB_Hide = LDBFormat.LDBGetText("TeamGUI", "Hide");

        var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
        escapeNode.SignalEscapePressed.Connect(RemoveMenu, this);
        
        com.GameInterface.EscapeStack.Push(escapeNode);
    }
    
    //Initialize
    public function Initialize():Void
    {
        var sizeItems:Array = [];
        sizeItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "AutoSize"), callback: "SetWindowSize", args: RaidClip.SIZE_AUTO, enabled:true });
        sizeItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "SmallSize"), callback: "SetWindowSize", args: RaidClip.SIZE_SMALL, enabled:true });
        sizeItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "MediumSize"), callback: "SetWindowSize", args: RaidClip.SIZE_MEDIUM, enabled:true });
        //sizeItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "LargeSize"), callback: "SetWindowSize", args: RaidClip.SIZE_LARGE, enabled:true });
        
        var alignmentItems:Array = [];
        alignmentItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "Left"), callback: "SetMenuAlignment", args: RaidClip.MENU_ALIGNMENT_LEFT, enabled:true });
        alignmentItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "Right"), callback: "SetMenuAlignment", args: RaidClip.MENU_ALIGNMENT_RIGHT, enabled:true });
        
        var nametagsItems:Array = [];
        nametagsItems.push({ name: m_ShowMaxMinHpText, callback: "ToggleMaxMinHP", enabled:true });
        nametagsItems.push({ name: m_ShowHealthBarText, callback: "ToggleHealthBar", enabled:true });
        nametagsItems.push({ name: m_ShowNametagIconsText, callback: "ToggleNametagIcons", enabled:false });
        
        m_GroupItems = [];
        
        var teamClips:Array = m_RaidClip.GetTeamClips();
        
        for (var i:Number = 0; i < teamClips.length; i++)
        {
            var itemName:String;
            var isVisible:Boolean = teamClips[i].GetTeamVisibility();
            var groupName:String = teamClips[i].GetTeamName();
            
            if (isVisible)
            {
                itemName = LDBFormat.Printf(m_TDB_Hide, groupName);
            }
            else
            {
                itemName = LDBFormat.Printf(m_TDB_Show, groupName);  
            }
            
            m_GroupItems.push({ name: itemName, callback: "ToggleGroupVisibility", args: i, enabled:true, visible:isVisible, groupName:groupName});
        }

        m_GroupItems.push({ name: LDBFormat.LDBGetText("TeamGUI","ShowAll"), callback: "ShowAllGroups", enabled:true});
        
        m_MenuItems = [];
        m_MenuItems.push({ name: m_ShowWindowText, callback: "ToggleShowWindow", enabled:true });
        m_MenuItems.push({ name: m_LockWindowFrameText, callback: "ToggleWindowLock", enabled:m_ShowWindowFrame });
        m_MenuItems.push({ name: m_ShowWindowFrameText, callback: "ToggleWindowFrame", enabled:true });
        m_MenuItems.push({ name: m_ShowGroupNamesText, callback: "ToggleGroupNames", enabled:true });
        
        m_MenuItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "WindowSize"), callback: "OpenSubMenu", args: m_MenuItems.length, children: sizeItems, enabled:true});
        m_MenuItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "MenuAlignment"), callback: "OpenSubMenu", args: m_MenuItems.length, children: alignmentItems, enabled:true});
        m_MenuItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "ShowHideGroups"), callback: "OpenSubMenu", args: m_MenuItems.length, children: m_GroupItems, enabled:true});
        m_MenuItems.push({ name: LDBFormat.LDBGetText("TeamGUI", "CustomizeNametags"), callback: "OpenSubMenu", args: m_MenuItems.length, children: nametagsItems, enabled:true});
        
        DrawMenu(m_MenuItems, 0, 0);
    }
    
    //Draw Menu
    private function DrawMenu(items:Array, y:Number, depth:Number):Void
    {
        if (this["menu_" + depth] != undefined)
        {
            this["menu_" + depth].removeMovieClip();
            
            if (m_CurrentClicked == m_LastClicked)
            {
                return;
            }
        }

        var alignment:Number = m_RaidClip.GetMenuAlignment();
        
        var menu:MovieClip = this.createEmptyMovieClip("menu_" + depth, this.getNextHighestDepth());
        menu.attachMovie("TeamMenuBackground", "m_Background", menu.getNextHighestDepth());
        
        var ypos:Number = 5;
        var maxWidth:Number = 0;

        for (var i:Number = 0; i < items.length; i++ )
        {
            var menuItem:Object = items[i];
            var renderer:MovieClip = menu.attachMovie("TeamMenuItemRenderer", "renderer_" + i, menu.getNextHighestDepth());
            
            renderer.m_Background._alpha = 0;
            renderer._x = 4;
            renderer._y = ypos;
            renderer.m_Name.autoSize = (alignment == RaidClip.MENU_ALIGNMENT_LEFT) ? "left" : "right";
            renderer.m_Name.text = menuItem.name;
            renderer.callback = menuItem.callback;
            renderer.args = menuItem.args
            renderer.depth = depth;
            renderer.ref = this;
            
            maxWidth = Math.max(maxWidth, renderer.m_Name._width);
            
            if (menuItem.children == undefined)
            {
                renderer.m_LeftArrow._visible = false;
                renderer.m_RightArrow._visible = false;
            }
            else
            {
                if (alignment == RaidClip.MENU_ALIGNMENT_LEFT)
                {
                    renderer.m_LeftArrow._visible = false;
                    renderer.m_RightArrow._visible = true;
                }
                else
                {
                    renderer.m_LeftArrow._visible = true;
                    renderer.m_RightArrow._visible = false;
                }
            }
            
            if (menuItem.enabled == true)
            {
                renderer.onRollOver = function()
                {
                    this.m_Background._alpha = 100;
                    
                    if (this["m_LeftArrow"]._visible || this["m_RightArrow"]._visible)
                    {
                        this["ref"].m_CurrentClicked = this["m_Name"]
                        this["ref"][this["callback"]](this["args"]);
                    }
                    else
                    {
                        var newClip:MovieClip = this["ref"]["menu_" + (Number(this["depth"]) + 1)];
                        if (newClip != undefined)
                        {
                            newClip.removeMovieClip();
                        }
                    }
                }

                renderer.onRollOut = function()
                {
                    if (this["m_LeftArrow"]._visible || this["m_RightArrow"]._visible)
                    {
                        var newClip:MovieClip = this["ref"]["menu_" + (Number(this["depth"]) + 1)];
                               
                        if ((_xmouse < -newClip._width && _xmouse >= 0) && (_ymouse < -1 && _ymouse >= newClip._height))
                        {
                            this["ref"][this["callback"]](this["args"]);
                        }
                    }
                    
                    this.m_Background._alpha = 0;
                }
                
                renderer.onRelease = function()
                {
                    this["ref"].m_CurrentClicked = this["m_Name"]
                    this["ref"][this["callback"]](this["args"]);
                }
            }
            else
            {
                renderer.m_Name._alpha = 60;
            }
            
            menuItem.ypos = ypos;
            ypos += renderer._height + 2;
        }

        for (var i:Number = 0; i < items.length; i++)
        {
            var renderer:MovieClip = this["menu_" + depth]["renderer_" + i];
            
            renderer.m_Background._xscale = maxWidth + 41;
            
            if (alignment == RaidClip.MENU_ALIGNMENT_LEFT)
            {
                renderer.m_Name._x = 10;
                renderer.m_RightArrow._x = renderer.m_Background._width - renderer.m_RightArrow._width - 8;
            }
            else
            {
                renderer.m_Name._x = renderer.m_Background._width - renderer.m_Name._width - 10;;
                renderer.m_LeftArrow._x = 8;
            }
        }
        
        menu.m_Background._height = ypos + 4;
        menu.m_Background._width = maxWidth + 50;
        
        var xpos:Number = 0;              
        
        if (alignment == RaidClip.MENU_ALIGNMENT_LEFT)
        {
            for (var i:Number = 0; i < depth; i++)
            {
                xpos += this["menu_" + i]._width + 1;
            }
        }
        else
        {
            for (var i:Number = depth; i > 0; i--)
            {
                xpos -= this["menu_" + i]._width - 1;
            }
        }
        
        menu._x = xpos
        menu._y = y;
        
        m_LastClicked = m_CurrentClicked;
    }
    
    //On Mouse Up
    private function onMouseUp():Void
    {
        if (!this.hitTest(_root._xmouse, _root._ymouse) && m_RaidClip.MissedButton())
        {
            RemoveMenu();
        }
    }
    
    //Remove Menu
    public function RemoveMenu():Void
    {
        m_RaidClip.RaidMenuRemoved();
        
        this.removeMovieClip();
    }
        
    //Toggle Show Window
    private function ToggleShowWindow():Void
    {
        m_ShowWindow = !m_ShowWindow;
        m_RaidClip.SetShowWindow(m_ShowWindow);
        RemoveMenu();
    }
    
    //Toggle Window Lock
    private function ToggleWindowLock():Void
    {
        m_WindowFrameLocked = !m_WindowFrameLocked;
        m_RaidClip.SetWindowFrameLocked(m_WindowFrameLocked, true)
        RemoveMenu();
    }
    
    //Toggle Window Frame
    private function ToggleWindowFrame():Void
    {
        m_ShowWindowFrame = !m_ShowWindowFrame
        m_RaidClip.SetShowWindowFrame(m_ShowWindowFrame, true);
        RemoveMenu();
    }

    //Toggle Max Min HP
    private function ToggleMaxMinHP():Void
    {
        m_ShowHPNumbers = !m_ShowHPNumbers;
        m_RaidClip.SetShowHPNumbers(m_ShowHPNumbers, true);
        RemoveMenu();
    }
    
    //Toggle Health Bar
    private function ToggleHealthBar():Void
    {
        m_ShowHealthBar = !m_ShowHealthBar;
        m_RaidClip.SetShowHealthBar(m_ShowHealthBar, true);
        RemoveMenu();
    }
    
    //Toggle Nametag Icons
    private function ToggleNametagIcons():Void
    {
        
    }
    
    //Toggle Group Names
    private function ToggleGroupNames():Void
    {
        m_ShowGroupNames = !m_ShowGroupNames;
        m_RaidClip.SetShowGroupNames(m_ShowGroupNames);
        m_RaidClip.Layout(false);
        RemoveMenu();
    }
    
    //Show All Groups
    private function ShowAllGroups():Void
    {
        var update:Boolean = false;
        
        for (var i:Number = 0; i < m_GroupItems.length; i++)
        {
            if (m_GroupItems[i].visible == false)
            {
                m_RaidClip.SetGroupVisibility(i, true, false);
                update = true;
            }
        }
        
        if (update)
        {
            m_RaidClip.Layout(false);
        }
        
        RemoveMenu();
    }
    
    //Toggle Group Visibility
    private function ToggleGroupVisibility(index):Void
    {
        var groupItem:Object = m_GroupItems[index];
        groupItem.visible  = !groupItem.visible;
        
        m_RaidClip.SetGroupVisibility(index, groupItem.visible, true);
        
        var newName:String
        
        if (groupItem.visible == true)
        {
            newName = LDBFormat.Printf(m_TDB_Hide, groupItem.groupName);
        }
        else
        {
            newName = LDBFormat.Printf(m_TDB_Show, groupItem.groupName);  
        }
        
        this["menu_1"]["renderer_" + index].m_Name.text = newName;
        
        RemoveMenu();
    }
    
    //Open Sub Menu
    private function OpenSubMenu(index):Void
    {
        var menuItem:Object = m_MenuItems[index]
        var itemArray:Array = menuItem.children;
        var itemY:Number = menuItem.ypos;
        
        DrawMenu(itemArray, itemY, 1);   
    }
    
    //Set Show Window
    public function SetShowWindow(value:Boolean):Void
    {
        m_ShowWindow = value;
        m_ShowWindowText = (m_ShowWindow ? LDBFormat.LDBGetText("TeamGUI", "HideWindow") : LDBFormat.LDBGetText("TeamGUI", "ShowWindow"));
    }
    
    //Set Window Frame Locked
    public function SetWindowFrameLocked(value:Boolean):Void
    {
        m_WindowFrameLocked = value;
        m_LockWindowFrameText = (m_WindowFrameLocked ? LDBFormat.LDBGetText("TeamGUI", "UnlockWindowFrame") : LDBFormat.LDBGetText("TeamGUI", "LockWindowFrame"));
    }

    //Set Show Window Frame
    public function SetShowWindowFrame(value:Boolean):Void
    {
        m_ShowWindowFrame = value;
        m_ShowWindowFrameText = (m_ShowWindowFrame ? LDBFormat.LDBGetText("TeamGUI", "HideWindowFrame") : LDBFormat.LDBGetText("TeamGUI", "ShowWindowFrame"));
    }

    //Set Show Group Names
    public function SetShowGroupNames(value:Boolean):Void
    {
        m_ShowGroupNames = value;
        m_ShowGroupNamesText = (m_ShowGroupNames ? LDBFormat.LDBGetText("TeamGUI", "HideGroupNames") : LDBFormat.LDBGetText("TeamGUI", "ShowGroupNames"));
    }

    //Set Window Size
    private function SetWindowSize(size:Number):Void
    {
        if (m_RaidClip.GetWindowSize() != size)
        {
            m_RaidClip.SetWindowSize(size);            
        }
        
        RemoveMenu();
    }
    
    //Set Menu Alignment
    public function SetMenuAlignment(value:Number):Void
    {
        if (m_RaidClip.GetMenuAlignment() != value)
        {
            m_RaidClip.SetMenuAlignment(value);
        }
        
        RemoveMenu();
    }

    //Set Show HP Numbers
    public function SetShowHPNumbers(value:Boolean):Void
    {
        m_ShowHPNumbers = value;
        m_ShowMaxMinHpText = (m_ShowHPNumbers ? LDBFormat.LDBGetText("TeamGUI", "HideMaxMinHp") : LDBFormat.LDBGetText("TeamGUI", "ShowMaxMinHp"));
    }

    //Set Show Health Bar
    public function SetShowHealthBar(value:Boolean):Void
    {
        m_ShowHealthBar = value;
        m_ShowHealthBarText = (m_ShowHealthBar ? LDBFormat.LDBGetText("TeamGUI", "HideHealthBar") : LDBFormat.LDBGetText("TeamGUI", "ShowHealthBar"));
    }

    //Set Show Nametag Icons
    public function SetShowNametagIcons(value:Boolean):Void
    {
        m_ShowNametagIcons = value;
        m_ShowNametagIconsText = (m_ShowNametagIcons ? LDBFormat.LDBGetText("TeamGUI", "HideNametagIcons") : LDBFormat.LDBGetText("TeamGUI", "ShowNametagIcons"));
    }

    //Set Is Group Detached
    public function SetIsGroupDetached(value:Boolean):Void
    {
        m_IsGroupDetached = value;
    }
}