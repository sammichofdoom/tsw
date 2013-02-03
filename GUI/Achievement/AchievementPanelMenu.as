import com.GameInterface.LoreNode
import gfx.utils.Delegate;
import com.Utils.Signal;
import com.GameInterface.Lore;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import gfx.motion.Tween; 
import mx.transitions.easing.*;

class GUI.Achievement.AchievementPanelMenu extends MovieClip
{
    private var STATE_OPEN:Number = 0;
    private var STATE_CLOSED:Number = 0;
    private var m_Data:LoreNode;
    private var m_RendererLinkageId:String = "TopLevelRenderer"; 
    private var m_LevelPadding:Number = 10;
    private var m_NodePadding:Number = 2;
    private var m_Width:Number;
    private var m_Height:Number;
    private var m_NodeFocus:DistributedValue;
    private var m_Type:Number;
    private var m_Redraw:Boolean;
    public var ID:Number;
    public var SizeChanged:Signal
        
    public function AchievementPanelMenu()
    {
        m_Redraw = true;
        m_NodeFocus = DistributedValue.Create( "achievement_window_focus" );
        m_NodeFocus.SignalChanged.Connect(SlotSetNodeFocus, this);
        SizeChanged = new Signal();
        Lore.SignalTagAdded.Connect(SlotTagAdded, this);
        GUI.Achievement.AchievementWindow.SignalTagRead.Connect(SlotTagRead, this);
    }
        
    public function SetData(data:LoreNode, forceUpdate:Boolean)
    {
        m_Data = data;
        m_Type = data.m_Type;
        
        ID = data.m_Id;
        
        if (forceUpdate)
        {
            if (this["clip" + ID] != undefined)
            {
                this["clip" + ID].removeMovieClip();
            }
           
            var toplevelClip:MovieClip = this.createEmptyMovieClip("clip" + ID, this.getNextHighestDepth());
            DrawNode(data, toplevelClip, 0);
            
            SlotSetNodeFocus();
        }
    }
    
    public function GetYPos(id:Number)
    {
        if (this["clip" + id] != undefined)
        {
            return this["clip" + id]._y;
        }
        return 0;
    }
    
    public function SetSize(width:Number, height:Number)
    {
        m_Width = width;
        m_Height = height;
    }

    
    
    private function DrawNode(node:LoreNode, parent:MovieClip, level:Number)
    {
        var nodeList:Array = node.m_Children;
        var ypos:Number = 0;
        var levelMultiplier:Number = level * 5;;
        var color:Number = GetLevelColor( level );
        var overColor:Number = GetLevelColor( level + 1 );
        
        /// check state and return if it is drawn allready
        if (parent.m_ChildClip != undefined)
        {
            if (parent.m_ChildClip.state == STATE_OPEN)
            {
                return parent.m_ChildClip;
            }
            else
            {
                parent.m_ChildClip.removeMovieClip();
                parent.m_ChildClip = undefined;
            }
        }
        var childClip:MovieClip = parent.createEmptyMovieClip("m_ChildClip", parent.getNextHighestDepth());
        childClip.state = STATE_OPEN;
        
        if (parent.m_Renderer != undefined)
        {
            childClip._y = parent.m_Renderer._y + parent.m_Renderer._height + m_NodePadding;
        }

        /// iterate the data and print the menu
        for (var i:Number = 0; i < nodeList.length; i++ )
        {
            var currentNode:LoreNode = nodeList[i];
            
            if (!Lore.IsLeafNode(currentNode))
            {
                var nodeClip:MovieClip = childClip.createEmptyMovieClip("clip" + currentNode.m_Id, childClip.getNextHighestDepth());
                var rendererClip:MovieClip = nodeClip.attachMovie(m_RendererLinkageId, "m_Renderer", nodeClip.getNextHighestDepth());
                
                var renderWidth:Number = m_Width - levelMultiplier;
                
                nodeClip._y = ypos;
                
                rendererClip.m_Background._width = renderWidth;
                rendererClip.ref = this;
                rendererClip.id = currentNode.m_Id;
                rendererClip.color = color;
                rendererClip.overColor = overColor;
                
                com.Utils.Colors.Tint( rendererClip.m_Background, color, 100 );
                
                var lockedPos:Number = 5;
                if (currentNode.m_IsNew)
                {
                    lockedPos = 15;
                    var notification:MovieClip = rendererClip.attachMovie( "NewNotification", "m_NewNotification", rendererClip.getNextHighestDepth());
                }
                else if (currentNode.m_Locked == true && currentNode.m_HasCount == 0)
                {
                    lockedPos = 15;
                    var lockScale:Number = (100 - levelMultiplier) * 0.4;
                    var lock:MovieClip = rendererClip.attachMovie("_Icon_Modifier_Lock", "lock", rendererClip.getNextHighestDepth() );
                    lock._xscale = lockScale;
                    lock._yscale = lockScale;
                    lock._x = 4;
                    lock._y = 3;
                    lock._alpha = 70;
                }
                
                rendererClip.m_Text._x = lockedPos;
                rendererClip.m_Text._width = renderWidth - (45 + lockedPos);
                rendererClip.m_Text.text = currentNode.m_Name;
            
                rendererClip.m_CounterText._x = rendererClip.m_Text._x + rendererClip.m_Text._width; // renderWidth - 35; // ((35) * (1 + (levelMultiplier * 0.01)))
                rendererClip.m_CounterText.text = currentNode.m_HasCount + "/" + currentNode.m_TargetCount;

                rendererClip._xscale = 100 - levelMultiplier;
                rendererClip._yscale = 100 - levelMultiplier;
                        
                rendererClip._x = m_Width - rendererClip._width;
                
                rendererClip.onRollOver = function()
                {
                    com.Utils.Colors.Tint(this.m_Background, this.overColor, 100);
                }
                
                rendererClip.onRollOut = function()
                {
                    com.Utils.Colors.Tint(this.m_Background, this.color, 100);
                }
                
                rendererClip.onRelease = function()
                {
                    this["ref"].RendererClickHandler( this["id"] );
                }
                
                ypos += rendererClip._height;
            }
        }

        return childClip;
    }

    private function CloseNode()
    {
        var currentNode:LoreNode = Lore.GetFirstNonLeafNode(Lore.GetDataNodeById(m_NodeFocus.GetValue()));
        if (currentNode.m_Parent == undefined)
        {
            return;
        }
        
        var parentClip:MovieClip = GetClipFromDataNode(currentNode.m_Parent);

        var removeClip:MovieClip = GetClipFromDataNode(currentNode);
        removeClip._parent.clear();
        removeClip.removeMovieClip();
        removeClip = undefined;
        
        var ypos:Number = 0;
        for (var i:Number = 0; i < currentNode.m_Parent.m_Children.length; i++ )
        {
            var node:LoreNode = currentNode.m_Parent.m_Children[i];
            var clip:MovieClip = parentClip["clip" + node.m_Id];
            clip._y = ypos;
            ypos += clip._height;
        }
        m_Redraw = false;
        m_NodeFocus.SetValue(currentNode.m_Parent.m_Id);
        Reflow();
        
    }
    
    private function SlotSetNodeFocus()
    {
        if (!m_Redraw)
        {
            m_Redraw = true;
            return;
        }
        
        var currentNodeId:Number = m_NodeFocus.GetValue();
        var currentNode:LoreNode = Lore.GetDataNodeById(currentNodeId);
        var forcedParent:Boolean = false;
        
        if (Lore.IsLeafNode(currentNode))
        {
            currentNode = Lore.GetFirstNonLeafNode(currentNode);
            currentNodeId = currentNode.m_Id;
            forcedParent = true;
        }
    
        var type:Number = Lore.GetTagType(currentNodeId);

        var nodeList:Array = GetNodeList(currentNode);

        /// draw all children starting from the top
        var clip:MovieClip = this;
        var newHeight:Number = 0;
        for (var i:Number = 0; i < nodeList.length; i++ )
        {
            var node:LoreNode = nodeList[i];
            
            if (node.m_Children.length > 0)
            {
                var nodeClip:MovieClip = clip["clip" + node.m_Id];

                if (nodeClip == undefined || Lore.IsLeafNode( node ))
                {
                    if (clip != undefined)
                    {
                        nodeClip = clip._parent;
                        break;
                    }
                    else
                    {
                        trace("ERROR:failed to create valid clip, aborting AchievementPanelMenu:SlotSetNodeFocus - node id = " + currentNodeId);
                        return;
                    }
                 //   break;
                }
                
                clip = DrawNode(node, nodeClip, i);
            }
        }
        Reflow();
    }
    
    /// Iterates all nodes up from a specific node.
    /// adds it to a list and reverses it
    private function GetNodeList(node:LoreNode) : Array
    {
        var nodeList:Array = [];
        while (node != null)
        {
            nodeList.unshift( node );
            node = node.m_Parent;
        }
        return nodeList;
    }
    
    private function Reflow()
    {
        var id:Number = m_NodeFocus.GetValue();
        var parent:LoreNode = Lore.GetDataNodeById(id);
        var clip:MovieClip = GetClipFromDataNode(parent);
        var change:Boolean;
        var newY:Number;
        var changeClip:MovieClip;
        while ( parent != null)
        {
            id = parent.m_Id;
            parent = parent.m_Parent;
            clip = GetClipFromDataNode(parent);
            change = false;
            for (var i:Number = 0; i < parent.m_Children.length; i++)
            {
                if (parent.m_Children[i].m_Id == id)
                {
                    changeClip = clip["clip" + parent.m_Children[i].m_Id];
                    changeClip.clear();
                    change = true;
                    newY = changeClip._y + changeClip._height;
                    var level:Number = GetLevel(parent);
                    var indent:Number = (level * m_LevelPadding);
                    var yModifier:Number = (20 - (20 / indent))
                    if (changeClip._height - yModifier > 5) // 5 cause it can be pushed a bit by the yModifier, better be safe - What is this I don't even...
                    {
                        com.Utils.Draw.DrawRectangle(changeClip, indent , yModifier, m_Width - indent, changeClip._height - yModifier, GetLevelColor(level), 100, [4, 4, 4, 4]);
                    }
                }
                else if (change)
                {
                    changeClip = clip["clip" + parent.m_Children[i].m_Id];
                    changeClip._y = newY;
                    newY += changeClip._height;
                }
            }
        }
        SizeChanged.Emit();
    }
    
    private function SlotTagRead(tagId:Number)
    {
        var data:LoreNode = Lore.GetAchievementTree();
        SetData(data, true);
       // m_NodeFocus.SetValue(tagId);
    }
    
    private function SlotTagAdded(tagId:Number, character:ID32)
    {
        if (character.Equal(Character.GetClientCharID()))
        {
            var node:LoreNode = Lore.GetDataNodeById(tagId);
            var renderer:MovieClip;
            var clip:MovieClip = this;
            var tempClip:MovieClip;
            var list:Array = GetNodeList( node );

            for (var i:Number = 0; i < list.length; i++ )
            {
                tempClip = clip["clip" + list[i].m_Id]
                
                if (tempClip.m_ChildClip == undefined)
                {
                    if (tempClip.m_Renderer != undefined)
                    {
                        renderer = tempClip.m_Renderer
                    }
                    else
                    {
                        renderer = clip._parent.m_Renderer;
                    }
                    break;
                }
                else
                {
                    clip = tempClip.m_ChildClip;
                }
            }

            if (renderer.lock != undefined)
            {
                renderer.lock.removMovieClip();
                renderer.lock = undefined;
            }
            
            var notification:MovieClip = renderer.attachMovie( "NewNotification", "m_NewNotification", renderer.getNextHighestDepth());

        }
    }
    
    private function GetLevel(node:LoreNode):Number
    {
        var level:Number = 0
        while (node != null)
        {
            level++;
            node = node.m_Parent;
        }
        return level;
    }
    
    private function GetClipFromDataNode(node:LoreNode) : MovieClip
    {
        var clip:MovieClip = this;
        var list:Array = GetNodeList( node );
        for (var i:Number = 0; i < list.length; i++ )
        {
            clip = clip["clip" + list[i].m_Id]["m_ChildClip"];
            if (clip == undefined)
            {
                return null;
            }
        }
        return clip;
    }
    
    private function RendererClickHandler( id:Number )
    {
        var currentNodeId = 0;
        var leafMenuNode:Boolean = false;
        if (m_NodeFocus.GetValue() != 0)
        {
            var currentNode:LoreNode = Lore.GetDataNodeById(m_NodeFocus.GetValue());
            currentNodeId = Lore.GetFirstNonLeafNode(currentNode).m_Id;
            if (currentNode.m_Children.length > 0 && Lore.GetFirstNonLeafNode(currentNode.m_Children[0]).m_Id == currentNodeId)
            {
                leafMenuNode = true;
            }
        }
        var currentNodeId:Number = Lore.GetFirstNonLeafNode(Lore.GetDataNodeById(m_NodeFocus.GetValue())).m_Id;
        if (currentNodeId == id && !leafMenuNode)
        {
            CloseNode();
        }
        else
        {
            m_NodeFocus.SetValue(id);
        }
    }
    
    private function GetLevelColor(level:Number) : Number
    {
        //switch()
        if (level < 1)
        {
            return 0x000000;
        }
        else if (level == 1)
        {
            return 0x333333;
        }
        else if (level == 2)
        {
            return 0x444444;
        }
        else if (level == 3)
        {
            return 0x666666;
        }
        else if( level == 4)
        {
            return 0x999999;
        }
        else
        {
            return 0xCCCCCC;
        }
      
    }
}