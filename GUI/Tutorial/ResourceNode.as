import GUIFramework.SFClipLoader;
import GUI.Tutorial.TutorialNode;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import GUI.Tutorial.TutorialWindow;
import com.Utils.Colors;
class GUI.Tutorial.ResourceNode extends TutorialNode 
{
    private var m_Args:Object;
    private var m_HasData:Boolean;
    private var m_Depth:Number;
    private var m_Indent:Number = 20;
    private var m_IsRead:Boolean;
    private var m_ReadAlpha:Number = 40
    
    function ResourceNode(id:Number, name:String)
    {
        super(id, name);
        
        m_Args = GUI.Tutorial.ResourceNodeUtils.GetArgs(id);// new Object();
        m_Depth = Lore.GetDepth( id );
    }
    
    public function Draw(parentClip:MovieClip, width:Number)
    {
        m_MovieClip = parentClip.createEmptyMovieClip("i_Resource" + m_Id, parentClip.getNextHighestDepth());
        m_MovieClip._x = m_Indent;
        
        var isRead:Boolean = !Lore.IsLocked( m_Id );
                
        var mc:MovieClip = m_MovieClip.attachMovie("Tutorial_Resource", "i_Resource", m_MovieClip.getNextHighestDepth())
        var width:Number = TutorialWindow.s_Width - (m_Indent * m_Depth) + 10;

        if (m_Args["Image"] != undefined)
        {
            mc.attachMovie("ShowImage", "m_Identifier", mc.getNextHighestDepth(),{ _x:5, _y:4});
        }
        else if (m_Args["Text"] != undefined)
        {
            mc.attachMovie("ShowText", "m_Identifier", mc.getNextHighestDepth(),{ _x:5, _y:4});
        }
        else if (m_Args["Video"] != undefined)
        {
            mc.attachMovie("ShowVideo", "m_Identifier", mc.getNextHighestDepth(),{ _x:3, _y:2});
        }

        mc.m_Background._width = width;

        if (mc.m_Identifier != undefined)
        {
            mc.i_Name._x = mc.m_Identifier._x + mc.m_Identifier._width + 5;
            mc.m_Identifier._alpha = (isRead) ? m_ReadAlpha : 100;
            mc.i_Name._alpha = (isRead) ? m_ReadAlpha : 100;
        }

        mc.i_Name._width = width - mc.i_Name._x - 5;
        mc.i_Name.text = m_Name;
        
        /// check if it has been used
        if (false)
        {
            var notifier:MovieClip = mc.attachMovie("_Icon_Modifier_Notice", "notifier", mc.getNextHighestDepth());
            notifier._x = mc.i_Name._width + 7;
            notifier._y = 2;
            notifier._xscale = 56;
            notifier._yscale = 56;
            mc.i_Name._width -= 20;
            
        }
        
        mc.m_TutorialNode = this;
        mc.onPress = function()
        {
            this.m_TutorialNode.Select();
            Colors.Tint( this.m_Background, Colors.e_ColorWhite, 0);
            this.m_Identifier._alpha = this.m_TutorialNode.m_ReadAlpha;
            this.i_Name._alpha = this.m_TutorialNode.m_ReadAlpha;
            
        }
        mc.onRollOver = function()
        {
            Colors.Tint( this.m_Background, Colors.e_ColorWhite, 30);
        }
        
        mc.onRollOut = function()
        {
            Colors.Tint( this.m_Background, Colors.e_ColorWhite, 0);
        }
    }
    
    public function Select()
    {
    }
}