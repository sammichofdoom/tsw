import GUI.Tutorial.DirectoryNode;
import com.Utils.Signal;

class GUI.Tutorial.TutorialNode 
{
    private var m_Id:Number;
    private var m_Name:String;
    
    private var m_ParentNode:DirectoryNode;
    
    private var m_MovieClip:MovieClip;
    
    public var SignalNodePressed:Signal
    
    function TutorialNode(id:Number, name:String)
    {
        m_Id = id;
        m_Name = name;
        
        SignalNodePressed = new Signal;
    }
    
    public function SetParent(parentNode:DirectoryNode)
    {
        m_ParentNode = parentNode;
    }
        
    public function GetParentNode():DirectoryNode
    {
        return m_ParentNode;
    }
    
    public function GetName():String
    {
        return m_Name;
    }
    
    public function GetMovieClip():MovieClip
    {
        return m_MovieClip;
    }
    
    public function Draw(parentClip:MovieClip)
    {
    }
    
    public function Select()
    {
    }
}