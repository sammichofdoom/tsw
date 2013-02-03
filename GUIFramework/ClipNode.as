import com.Utils.Signal;

class GUIFramework.ClipNode
{
    public function ClipNode( objecName:String, clipName:String, movie:MovieClip, stretchToScreen:Boolean, depthLayer:Number, subDepth:Number, loadArguments:Array )
    {
        m_ObjectName      = objecName; // 'logical' name referencing the movieclip from _root
        m_ClipName        = clipName;  // Name used in createEmptyMovieClip()
        m_Movie           = movie;
        m_StretchToScreen = stretchToScreen;
        m_DepthLayer      = depthLayer;
        m_SubDepth        = subDepth;
        m_ModalLevel      = 0;
        m_LoadArguments   = loadArguments;
        SignalLoaded = new Signal;
    }

    public function Compare( rhs:ClipNode ) : Number
    {
        if ( m_ModalLevel != rhs.m_ModalLevel )
        {
            return m_ModalLevel - rhs.m_ModalLevel;
        }
        else if ( m_DepthLayer != rhs.m_DepthLayer )
        {
            return m_DepthLayer - rhs.m_DepthLayer;
        }
        else
        {
            return m_SubDepth - rhs.m_SubDepth;
        }
    }
    
    public function toString():String
    {
        return m_Movie + " Depthlayer: " + m_DepthLayer + " SubDepth" + m_SubDepth + " Real depth: " + m_Movie.getDepth();
    }
    public var SignalLoaded:Signal;
    
    public var m_Movie:MovieClip;
    public var m_ObjectName:String;
    public var m_ClipName:String;
    public var m_StretchToScreen:Boolean;
    public var m_DepthLayer:Number;
    public var m_SubDepth:Number;
    public var m_ModalLevel:Number;
    public var m_LoadArguments:Array;
}
