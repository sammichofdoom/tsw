import com.GameInterface.LoreNode
import gfx.utils.Delegate;
import com.Utils.Signal;
import com.GameInterface.Lore;


class com.Components.TreeViewSimpleComponent extends MovieClip
{
    private var m_Data:LoreNode;
    
    private var m_RendererLinkageId:String = "TopLevelRenderer";
    private var m_Width:Number;
    private var m_Height:Number;
    private var m_LevelPadding:Number = 10;
        
    private var m_CurrentClip:MovieClip;
    private var m_NameTextFormat:TextFormat;
    private var m_StatTextFormat:TextFormat;
    
    public var ID:Number;
    public var SignalClicked:Signal;
    
    public function TreeViewSimpleComponent()
    {
       // m_Width = this._width;
        SignalClicked = new Signal;
    }
    
    public function SetData(data:LoreNode, doDraw:Boolean)
    {
        m_Data = data;
        ID = data.m_Id;
        
        if (doDraw)
        {
            m_Data["mc"] == this;
            Draw(data.m_Children,this, 0);
        }
    }
    
    public function SetSize(width:Number, height:Number)
    {
        m_Width = width;
        m_Height = height;
    }

    public function SetRenderer(rendererId:String) : Void
    {
        m_RendererLinkageId = rendererId;
    }
    
    private function Draw(data:Array, context:MovieClip, level:Number)
    {
        var ypos:Number = 0;
        var levelMultiplier:Number = level * m_LevelPadding;
        var color:Number = GetLevelColor( level );
        var overColor:Number = GetLevelColor( level + 1 );

        /// iterate the data and print the menu
        for (var i:Number = 0; i < data.length; i++ )
        {
            var dataObject:LoreNode = data[i];
            var isLeafNode:Boolean = Lore.IsLeafNode(dataObject);
            var rendererClip:MovieClip = context.createEmptyMovieClip(""+dataObject.m_Id, context.getNextHighestDepth());
            var renderer:MovieClip = rendererClip.attachMovie(m_RendererLinkageId, "renderer", rendererClip.getNextHighestDepth());
            var renderWidth:Number = m_Width - levelMultiplier;
            var renderHeight:Number = renderer.m_Background._height - (renderer.m_Background._height*(levelMultiplier*0.01));
            
            rendererClip._y = ypos;
            renderer._x = levelMultiplier;
            renderer.m_Background._width = renderWidth;
            renderer.m_Background._height = renderHeight;
            renderer.ref = this;
            renderer.isOpen = dataObject["isOpen"];
            renderer.hasChildren = ( dataObject.m_Children.length > 0 ) ? true : false;
            renderer.isLeafNode = isLeafNode;
            renderer.id = dataObject.m_Id;
            renderer.level = level;
            renderer.color = color;
            renderer.overColor = overColor;
            
            com.Utils.Colors.Tint( renderer.m_Background, color, 100 );
            
            renderer.onRollOver = function()
            {
                if (!this.isOpen)
                {
                    com.Utils.Colors.Tint(this.m_Background, this.overColor, 100);
                }
            }
            
            renderer.onRollOut = function()
            {
                if (!this.isOpen)
                {
                    com.Utils.Colors.Tint(this.m_Background, this.color, 100);
                }
            }
            
            renderer.onRelease = function()
            {
                this["ref"].RendererClickHandler(this);
            }

            var lockedPos:Number = 5;
            
            if (dataObject.m_Locked == true && dataObject.m_HasCount == 0)
            {
                lockedPos = 15;
                var lockScale:Number = (100 - levelMultiplier) * 0.4;
                var lock:MovieClip = renderer.attachMovie("_Icon_Modifier_Lock", "lock", renderer.getNextHighestDepth() );
                lock._xscale = lockScale;
                lock._yscale = lockScale;
                lock._x = 4;
                lock._y = 3;
                lock._alpha = 70;
            }
            renderer.m_Text._x = lockedPos;
            renderer.m_Text._width = renderWidth - (35 + lockedPos);
            renderer.m_Text.text = dataObject.m_Name.toUpperCase();
            renderer.m_Text._xscale = 100 - levelMultiplier;
            renderer.m_Text._yscale = 100 - levelMultiplier;
         
            renderer.m_CounterText._x = renderWidth - (35 + lockedPos); // ((35) * (1 + (levelMultiplier * 0.01)))

            renderer.m_CounterText.text = dataObject.m_HasCount + "/" + dataObject.m_TargetCount;
            renderer.m_CounterText._xscale = 100 - levelMultiplier;
            renderer.m_CounterText._yscale = 100 - levelMultiplier;
         
            dataObject["mc"] = rendererClip;
            
            if (dataObject["isOpen"] == true && dataObject.m_Children.length != 0)
            {
                var childClip:MovieClip = rendererClip.createEmptyMovieClip("m_ChildClip", rendererClip.getNextHighestDepth());
                childClip._y = rendererClip._height + 5
                Draw(dataObject.m_Children, childClip, level+1);
            }
            
            ypos += rendererClip._height+1;
        }
        
        /// draw a background where needed
        if (level > 0)
        {
           com.Utils.Draw.DrawRectangle(context, levelMultiplier, -2, m_Width - levelMultiplier, context._height + 4, color, 100, [4, 4, 4, 4]);
        }

    }
    
    public function GoToNode(id:Number)
    {
        var dataNode:LoreNode = Lore.GetDataNodeById(id, m_Data.m_Children);
        if (m_CurrentClip.m_ChildClip == undefined)
        {
            OpenRenderer( m_CurrentClip.renderer );
        }
        for (var prop in m_CurrentClip.m_ChildClip)
        {
            if (prop == String(id))
            {
                var clip:MovieClip = m_CurrentClip.m_ChildClip[prop];
                if (CanOpenRenderer(id))
                {
                    OpenRenderer( clip.renderer );
                }
                else
                {
                    com.Utils.Colors.Tint( clip.renderer.m_Background, clip.renderer.overColor, 100 );
                }
                
            }
        }
        
    }
    
    private function RendererClickHandler( target:MovieClip )
    {
        if (target.isOpen)
        {
            CloseRenderer(target);
            m_CurrentClip = target._parent; // ._parent;
        }
        else
        {
            if (CanOpenRenderer(target.id))
            {
                OpenRenderer(target)
                m_CurrentClip = target._parent;
            }
            else
            {
                com.Utils.Colors.Tint( target.m_Background, target.overColor, 100 );
            }
        }
        
        SignalClicked.Emit( target.id );
    }
  
    
    private function CloseRenderer( target )
    {
        var dataObject:Object = Lore.GetDataNodeById(target.id, m_Data.m_Children);
        dataObject.isOpen = false;
        target.isOpen = false;
        if (target._parent.m_ChildClip != undefined)
        {
            var height:Number = target._parent.m_ChildClip._height + 2;
            
            target._parent.m_ChildClip.removeMovieClip();
            Reflow(target, -height);
        }
    }

    
    private function OpenRenderer( target )
    {
        var dataObject:LoreNode = Lore.GetDataNodeById(target.id, m_Data.m_Children);
        var rendererClip:MovieClip = target._parent;
        var level:Number = target.level;
        var newSpace:Number;

        if (dataObject.m_Children != undefined)
        {
            dataObject["isOpen"] = true;
            var childClip:MovieClip = rendererClip.createEmptyMovieClip("m_ChildClip", rendererClip.getNextHighestDepth());
            childClip._y = rendererClip._height + 3;
            Draw(dataObject.m_Children, childClip, level + 1);
            
            newSpace = childClip._height;
        }

        target.isOpen = true;
        com.Utils.Colors.Tint(target.m_Background, target.color, 100);
     
        Reflow(target, newSpace+2);
    }


    /// reflows and redraws the menu. All clips "below" target moves spaceChange in the _y dimension
    /// @param target:MovieClip - the target that expand or contracta and triggers the change
    /// @param spaceChange:Number - the change in height that occurs
    private function Reflow(target:MovieClip, spaceChange:Number)
    {
        var targetId:Number = target.id;
        var level:Number = target.level
        var parentNode:LoreNode = Lore.GetDataNodeById( target._parent.renderer.id, m_Data.m_Children);

        while ( parentNode != null)
        {
            var change:Boolean = false;
            var color:Number = parentNode["mc"].renderer.color;
            
            parentNode = parentNode.m_Parent;

            for (var i:Number = 0; i < parentNode.m_Children.length; i++ )
            {
                if (change)
                {
                    var mc:MovieClip = parentNode.m_Children[i].mc;
                    mc._y += spaceChange;
                }
                else if (parentNode.m_Children[i].m_Id == targetId)
                {
                    change = true;
                }
            }
            
            var childClip:MovieClip = parentNode["mc"]["m_ChildClip"];
            if (childClip != null)
            {
                childClip.clear();
                com.Utils.Draw.DrawRectangle( childClip, m_LevelPadding * level, -3, m_Width - (level * m_LevelPadding), childClip._height+2, color , 100, [4, 4, 4, 4]);   
            }
            
            level--;
            targetId = parentNode.m_Id;
        }
    }
    
    private function CanOpenRenderer(id:Number) : Boolean
    {
        var node:LoreNode = Lore.GetDataNodeById( id, m_Data.m_Children );
        var isLeafNode:Boolean = Lore.IsLeafNode( node );
        if (!isLeafNode && node.m_Type == _global.Enums.LoreNodeType.e_AchievementCategory)
        {
            if (node.m_Children[0].m_Type != _global.Enums.LoreNodeType.e_AchievementCategory )
            {
                return false;
            }
            return true;
        }
        else if (node.m_Type == _global.Enums.LoreNodeType.e_Achievement || node.m_Type == _global.Enums.LoreNodeType.e_SubAchievement)
        {
            return false;
        }
        
        return !isLeafNode;
    }
    
    private function GetLevelColor(level:Number) : Number
    {
        
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