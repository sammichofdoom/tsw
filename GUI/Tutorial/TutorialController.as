import flash.geom.Point;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import GUI.Tutorial.DirectoryNode;
import GUI.Tutorial.ResourceNode;
import com.Utils.Colors;
import com.Utils.ID32;
import com.GameInterface.DistributedValue;
import com.GameInterface.EscapeStackNode;
import com.GameInterface.EscapeStack;
import com.Utils.Archive;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.Utils.LDBFormat;
import com.Components.WinComp;
import com.Components.WindowComponentContent;


var m_TutorialTree:LoreNode;

var m_Window:WinComp;
var m_Content:MovieClip;

var m_X:Number;
var m_Y:Number;
var m_Height:Number;
var m_Width:Number;

var m_TopLevelNodes:Array;
var m_EventDictionaryDirectory:Object;
var m_EventDictionaryResource:Object;

var m_WindowMonitor:DistributedValue;
var m_EscapeStackNode:EscapeStackNode;

var m_ShowingWindow:Boolean;
var m_ScrollBarArchivedPosition:Number;
var m_HasScrollbar:Boolean;
var m_DeltaMultiplier:Number;

function onLoad()
{
    m_ScrollBarArchivedPosition = 0;
    m_DeltaMultiplier = 10;
    
    m_EventDictionaryDirectory = [];
    m_EventDictionaryResource = [];
    m_TopLevelNodes = [];
    
    m_TutorialTree = Lore.GetTutorialTree();
    LoadTutorialTree();
    
    m_ShowingWindow = false;
    m_HasScrollbar = false;
    
    m_X = 300;
    m_Y = 300;
    m_Height = Stage["visibleRect"].height / 2;
    m_Width = 250;
    
    m_WindowMonitor = DistributedValue.Create( "tutorial_window" );
    m_WindowMonitor.SignalChanged.Connect( SlotWindowMonitorUpdate, this );
    SlotWindowMonitorUpdate();
    
    Lore.SignalTagAdded.Connect(SlotTagAdded, this);
}



function OnModuleActivated(config:Archive)
{
    var visibleRect:Object = Stage["visibleRect"];
  
    m_X         = config.FindEntry("PosX", 300);
    m_Y         = config.FindEntry("PosY", 300);
    m_Height    = config.FindEntry("Height", visibleRect.height / 2);
    m_Width     = config.FindEntry("Width", 250);

    m_X         = Math.max(m_X, 0);
    m_Y         = Math.max(m_Y, 0);
    m_X     = Math.min(m_X, visibleRect.width - m_Width);
    m_Y    = Math.min(m_Y, visibleRect.height - m_Height);

    if (m_Window != undefined)
    {
        m_Window.SetSize(m_Width, m_Height);
        m_Window._x = m_X;
        m_Window._y = m_Y;
    }
}

function OnModuleDeactivated()
{
    var archive:Archive = new Archive();
    if (m_Window != undefined)
    {
        archive.AddEntry("PosX", m_Window._x);
        archive.AddEntry("PosY", m_Window._y);
        archive.AddEntry("Height", m_Window._height);
        archive.AddEntry("Width", m_Window._width);
    }
    return archive;
}

function CreateWindow()
{
    m_Window = attachMovie( "HelpWindow", "m_Window", getNextHighestDepth());
    m_Window.SetMinWidth( 250 );
    m_Window.SetMinHeight( 300 );
    m_Window.SetContent( "TutorialWindow" );
    m_Window.SignalClose.Connect( CloseWindow, this );
    m_Window.SetTitle( LDBFormat.LDBGetText("Gamecode","HelpUpperCase"), "left" );
    m_Window.ShowFooter( false );
    m_Window.SetSize( m_Width, m_Height );
    m_Window.ShowStroke( false );
    
    m_Content = m_Window.GetContent();
    m_Content.SignalRedraw.Connect( RedrawWindow, this);
   
       
    m_Window._y = m_Y;
    m_Window._x = m_X;
    
 
    m_EscapeStackNode = new EscapeStackNode;
    m_EscapeStackNode.SignalEscapePressed.Connect( CloseWindow, this );
    EscapeStack.Push( m_EscapeStackNode );
    
    DrawWindow();
}

function CloseWindow()
{
    m_WindowMonitor.SetValue(false);
}

function RedrawWindow()
{
    if (m_Window != undefined)
    {
        DrawWindow();
    }
    else
    {
        CreateWindow();
    }
}

function DrawWindow()
{
    if (m_Content != undefined)
    {
        if (m_HasScrollbar)
        {
            canvas.setMask( null );
            m_Content["mask"].removeMovieClip();
        }
        m_Content.ClearCanvas();
    }

    var canvas:MovieClip = m_Content.GetCanvas();
    var y:Number = 3;
   
    for (var i:Number = 0; i < m_TopLevelNodes.length; i++)
    {
 //       m_TopLevelNodes[i].SetWidth(canvasWidth);
        m_TopLevelNodes[i].Draw( canvas );
        m_TopLevelNodes[i].GetMovieClip()._y = y
        y += m_TopLevelNodes[i].GetMovieClip()._height;
    }
    
    if (canvas._height > m_Content.GetSize().y)
    {
        com.GameInterface.ProjectUtils.SetMovieClipMask( canvas, m_Content, m_Content.GetSize().y)
        AddScrollBar()
    }
    else
    {
        RemoveScrollBar()
    }
//    com.Utils.Draw.DrawRectangle( m_Background, 0, 0, maxWidth, y + 10, Colors.e_ColorPanelsBackground, 80, [8, 8, 8, 8]);
//    m_CloseButton._x = maxWidth - 20;
    
    m_ShowingWindow = true;
}

function AddScrollBar()
{
    if (!m_HasScrollbar)
    {
        m_ScrollBar = m_Content.attachMovie("TutorialScrollBar", "m_ScrollBar", m_Content.getNextHighestDepth());
        m_ScrollBar._y = 0
        m_ScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
        m_ScrollBar.trackMode = "scrollPage"
        m_ScrollBar.disableFocus = true;        

        Mouse.addListener( this );
        m_HasScrollbar = true;
    }
    
       
    UpdateScrollbarSize()
}

function RemoveScrollBar()
{
    if (m_HasScrollbar)
    {
        m_ScrollBar.removeEventListener("scroll", this, "OnScrollbarUpdate");
        m_ScrollBar.removeMovieClip();
        Mouse.removeListener( this );
        m_HasScrollbar = false;
    }
}

function UpdateScrollbarSize()
{
    var size:Point = m_Content.GetSize()
    m_ScrollBar._x = size.x - 10;
    m_ScrollBar.setScrollProperties( size.y, 3, m_Content._height - size.y); 
    m_ScrollBar._height = size.y - 10;
    m_ScrollBar.position = m_ScrollBarArchivedPosition; 
    m_ScrollBar.trackScrollPageSize = ( m_Content._height - size.y); // size.y;
    
}

function OnScrollbarUpdate(event:Object) : Void
{
    var target:MovieClip = event.target;
    var pos:Number = event.target.position;
    
    m_Content.GetCanvas()._y = -pos;
    m_ScrollBarArchivedPosition = m_ScrollBar.position;
    
    Selection.setFocus(null);
}

function onMouseWheel( delta:Number )
{
    if ( Mouse["IsMouseOver"]( m_Content ) )
    {
        var newPos:Number = m_ScrollBar.position + -(delta* m_DeltaMultiplier);
        var event:Object = { target : m_ScrollBar };
        
        m_ScrollBar.position = Math.min(Math.max(0.0, newPos), m_ScrollBar.maxPosition);
        
        OnScrollbarUpdate(event);
    }
}

function RemoveWindow()
{
    m_Window.removeMovieClip();
    m_Window = undefined;
    m_EscapeStackNode.SignalEscapePressed.Disconnect(CloseWindow, this);
    m_EscapeStackNode = undefined;
    m_ShowingWindow = false;
}

function SlotWindowMonitorUpdate()
{
    var shouldShow:Boolean = Boolean(m_WindowMonitor.GetValue());
    if (shouldShow && !m_ShowingWindow)
    {
        RedrawWindow();
    }
    else if(m_ShowingWindow && !shouldShow)
    {
        RemoveWindow();
    }
}

function SlotTagAdded(tagId:Number, characterId:ID32)
{
    if (!characterId.Equal(Character.GetClientCharID()) || Lore.GetTagType(tagId) != _global.Enums.LoreNodeType.e_Tutorial)
    {
        return;
    }
    ShowTutorial(tagId);
}
function ShowTutorial(id:Number)
{
    var directoryNode:DirectoryNode = m_EventDictionaryDirectory[id];
    if (directoryNode != undefined)
    {
        var parentNode:DirectoryNode = directoryNode
        while (parentNode != undefined)
        {
            parentNode.SetIsOpen(true);
            parentNode = parentNode.GetParentNode();
        }
        RedrawWindow();
        m_WindowMonitor.SetValue(true);
        return;
    }
    
    var resourceNode:DirectoryNode = m_EventDictionaryResource[id];
    if (resourceNode != undefined)
    {
        resourceNode.Select();
    }
}

function LoadTutorialTree()
{
    if (m_TutorialTree != undefined)
    {
        var topLevelNodes:Array = m_TutorialTree.m_Children;
        for (var i:Number = 0; i < topLevelNodes.length; i++)
        {
            if (topLevelNodes[i].m_Type == _global.Enums.LoreNodeType.e_TutorialCategory)
            {
                ParseDirectoryNode(topLevelNodes[i], undefined);
            }
            if (topLevelNodes[i].m_Type == _global.Enums.LoreNodeType.e_Tutorial)
            {
                ParseResourceNode(topLevelNodes[i], undefined);            
            }
        }
    }
}

function ParseDirectoryNode(node:LoreNode, parentNode:DirectoryNode)
{
    var newDirectoryNode:DirectoryNode = new DirectoryNode(node.m_Id, node.m_Name);
    newDirectoryNode.SignalNodePressed.Connect(SlotDirectoryPressed, this);
    m_EventDictionaryDirectory[node.m_Id] = newDirectoryNode;
    if (parentNode != undefined)
    {
        parentNode.AddDirectoryNode(newDirectoryNode);
    }
    else
    {
        m_TopLevelNodes.push(newDirectoryNode);
    }
    
    for (var i:Number = 0; i < node.m_Children.length; i++)
    {
        if (node.m_Children[i].m_Type == _global.Enums.LoreNodeType.e_TutorialCategory)
        {
            ParseDirectoryNode(node.m_Children[i], newDirectoryNode);
        }
        else if(node.m_Children[i].m_Type == _global.Enums.LoreNodeType.e_Tutorial)
        {
            ParseResourceNode(node.m_Children[i], newDirectoryNode);            
        }
    }
}

function ParseResourceNode(node:LoreNode, parentNode:DirectoryNode)
{
    var newResourceNode:ResourceNode = new ResourceNode(node.m_Id, node.m_Name);
    m_EventDictionaryResource[node.m_Id] = newResourceNode;
    if (parentNode != undefined)
    {
        parentNode.AddResourceNode(newResourceNode);   
    }
    else
    {
        m_TopLevelNodes.push(newResourceNode);
    }
}

function SlotDirectoryPressed()
{
    RedrawWindow();
}