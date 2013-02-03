//Imports
import com.Utils.LDBFormat;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.DistributedValue;
import gfx.controls.Button;

var m_ResolutionScaleMonitor:DistributedValue;

//On Load
function onLoad()
{
    m_Window.SetTitle("", "left");
    m_Window.SetContent("MediaPlayerContent");
    m_Window.GetContent().SignalErrorLoading.Connect(CloseWindowHandler, this);
        
    m_Window.ShowCloseButton(true);
    m_Window.ShowStroke(false);
    m_Window.ShowResizeButton(false);
    m_Window.ShowFooter(false);
    m_Window.SetDraggable(true);
    
    m_Window.m_CloseButton.addEventListener("click", this, "CloseWindowHandler");
    m_Window._visible = false;
    
    var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
    moduleIF.SignalStatusChanged.Connect( CloseWindowHandler, this );
    
    var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
    escapeNode.SignalEscapePressed.Connect( CloseWindowHandler, this );
    com.GameInterface.EscapeStack.Push( escapeNode );
    
    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( SlotUpdateLayout, this );
}

//arguments coming from C++
function LoadArgumentsReceived ( args:Array ) : Void
{
    var mediaData:Object = args[0];
    var onlyText:Boolean = false;
    
    if ( mediaData.hasOwnProperty ( "Text" ) )
    {
        m_Window.GetContent().SetText(mediaData.Text);
        onlyText = true;
    }
    if ( mediaData.hasOwnProperty ( "Image" ) )
    {
        m_Window.GetContent().SignalContentLoaded.Connect(SlotUpdateLayout,this);
        m_Window.GetContent().SetImage(mediaData.Image);
        onlyText = false;
    }
    else if ( mediaData.hasOwnProperty ( "Video" ) )
    {
        m_Window.GetContent().SignalContentLoaded.Connect(SlotUpdateLayout,this);
        m_Window.GetContent().SetVideo(mediaData.Video);
        onlyText = false;
    }
    
    if ( onlyText )
    {
        SlotUpdateLayout();
    }  
}

function SlotUpdateLayout():Void
{
    m_Window._visible = true;
    m_Window.GetContent().Layout();
    m_Window.Layout();
    CenterWindow();
}

//Close Window Handler
function CloseWindowHandler():Void
{
    this.m_Window.GetContent().Close();
    this.UnloadClip();
}

function CenterWindow():Void
{
    var visibleRect = Stage["visibleRect"];
    _x = visibleRect.x;
    _y = visibleRect.y;
    
    m_Window._x = (visibleRect.width / 2) - (m_Window.m_Background._width / 2);
    m_Window._y = (visibleRect.height / 2) - (m_Window.m_Background._height / 2);    
}

