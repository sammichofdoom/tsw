import com.GameInterface.LoreNode;
import GUI.Tutorial.TutorialNode;
import GUI.Tutorial.ResourceNode;
import com.GameInterface.Lore;
import GUI.Tutorial.TutorialWindow;

class GUI.Tutorial.DirectoryNode extends TutorialNode 
{   
    var m_DirectoryNodes:Array;
    var m_ResourceNodes:Array;
    private var m_Width:Number = -1;
    var m_IsOpen:Boolean;
    private var m_Depth;
    private var m_Indent:Number = 20;
    
    function DirectoryNode(id:Number, name:String)
    {
        super(id, name);
        m_Depth = Lore.GetDepth( id );
        m_DirectoryNodes = [];
        m_ResourceNodes = [];
        m_IsOpen = false;
    }
    
    public function AddDirectoryNode(node:DirectoryNode)
    {
        m_DirectoryNodes.push(node);
        node.m_ParentNode = this;
    }
    
    public function AddResourceNode(node:ResourceNode)
    {
        m_ResourceNodes.push(node);
    }
    
    public function ToggleIsOpen()
    {
        m_IsOpen = !m_IsOpen;
    }
    
    public function SetIsOpen(isOpen:Boolean)
    {
        m_IsOpen = isOpen;
    }
    
    public function Select()
    {
        ToggleIsOpen();
        SignalNodePressed.Emit();
    }
    
    public function Draw(parentClip:MovieClip)
    {
        m_MovieClip = parentClip.createEmptyMovieClip("i_Directory" + m_Id, parentClip.getNextHighestDepth());
        var mc:MovieClip = m_MovieClip.attachMovie( "Tutorial_Directory", "i_Directory", m_MovieClip.getNextHighestDepth());
        mc.m_TutorialNode = this;
        mc.onPress = function()
        {
            this.m_TutorialNode.Select();
        }
        mc.i_Name.text = m_Name;
        m_MovieClip._x = (m_Depth > 1) ? m_Indent : 0;
        mc.i_Name._width = TutorialWindow.s_Width - ( m_Depth * m_Indent) - 20;
        
       
        if (m_IsOpen)
        {
            mc.m_Arrow._rotation = 90;
            var y:Number = m_MovieClip._height;

            for (var i:Number = 0; i < m_DirectoryNodes.length; i++)
            {
                m_DirectoryNodes[i].Draw(m_MovieClip);
                m_DirectoryNodes[i].GetMovieClip()._y = y
                y += m_DirectoryNodes[i].GetMovieClip()._height;
            }
            
            for (var i:Number = 0; i < m_ResourceNodes.length; i++)
            {
                m_ResourceNodes[i].Draw(m_MovieClip);
                m_ResourceNodes[i].GetMovieClip()._y = y
                
                y +=  m_ResourceNodes[i].GetMovieClip()._height + 3
            }
        }
    }

}