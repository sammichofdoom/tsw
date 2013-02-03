import mx.transitions.easing.*;
import gfx.motion.Tween;
import gfx.controls.UILoader;
import com.GameInterface.DistributedValue;

var m_VideoPlayer:com.Components.VideoPlayer

var m_VideoList:Array = [ 7688350, 7688351, 7747579, 7688352 ];
var m_VolumeList:Array = [ 75, 75, 45, 60 ];
var m_CurrentVideo:Number = -1;

function onLoad()
{
    SetupESCHandler();

	m_VideoPlayer.SignalLoaded.Connect(SlotVideoLoaded, this);
	m_VideoPlayer.SignalStopped.Connect(SlotVideoEnded, this);
	m_VideoPlayer.SignalFailedToLoad.Connect(SlotVideoEnded, this);

    if ( m_VideoPlayer.IsInitialized() )
    {
        SlotPlayerInitialized();
    }
    else
    {
        m_VideoPlayer.SignalInitialized.Connect( SlotPlayerInitialized, this ); // Flips the first domino chip.
    }
}

function SetupESCHandler()
{
    var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
    escapeNode.SignalEscapePressed.Connect( SlotESCPressed, this );
    com.GameInterface.EscapeStack.Push( escapeNode );
}

function SlotPlayerInitialized()
{
	m_VideoPlayer.SetShowOverlay(false);
	m_VideoPlayer.SetLoop(false);
	m_VideoPlayer._alpha = 0;
    MovieClip(m_VideoPlayer).tweenTo( 1, { _alpha: 100 }, Strong.easeOut );

	var visibleRect = Stage["visibleRect"];
	
	
	m_VideoPlayer._width = visibleRect.width;
	m_VideoPlayer._height  = visibleRect.width * 9 / 16;
	
	_x = visibleRect.x;
	_y = visibleRect.y + (visibleRect.height - m_VideoPlayer._height) / 2;
    
    SlotVideoEnded(); // Flip the first domino chip.
}

function SlotVideoLoaded()
{
	m_VideoPlayer.StartVideo();
}

function SlotVideoEnded()
{
    m_CurrentVideo++;
    if ( m_CurrentVideo < m_VideoList.length )
    {
        var videoPath:String = com.Utils.Format.Printf( "rdb:1000635:%.0f", m_VideoList[m_CurrentVideo] );
        m_VideoPlayer.LoadVideo( videoPath );
		m_VideoPlayer.SetVolume( m_VolumeList[m_CurrentVideo] );
    }
    else
    {
        CloseMediaPlayer();
    }
}

function SlotESCPressed()
{
    SetupESCHandler();
    if (DistributedValue.GetDValue("CanSkipStartupVideos") != false)
    {
        SlotVideoEnded();
    }
}

function CloseMediaPlayer () : Void
{
	m_VideoPlayer.PauseVideo();
	DistributedValue.SetDValue("PlayingStartupSequence", false);
	DistributedValue.SetDValue("CanSkipStartupVideos", true);
	this.UnloadClip();
}

