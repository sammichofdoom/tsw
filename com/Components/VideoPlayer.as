import flash.geom.Point;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.controls.Button;
import gfx.controls.Label;
import gfx.core.UIComponent;
import flash.filters.DropShadowFilter;

import mx.transitions.easing.*;

class com.Components.VideoPlayer extends UIComponent
{
	private var m_NetConnection:NetConnection;
	private var m_NetStream:NetStream;
	private var m_Sound:Sound;
	private var m_VideoView:Video;
	private var m_ShowOverlay:Boolean;
    private var m_IsInitialized:Boolean;
	private var m_IsPlaying:Boolean = false;
	private var m_AudioTracks:Array;
	private var m_SubtitleCount:Number;
	private var m_WantedAudioTrack:Number;
	private var m_WantedSubtitleTrack:Number;
	private var m_WantedVolume:Number;
    public var SignalInitialized:Signal;
	public var SignalLoaded:Signal;
	public var SignalFailedToLoad:Signal;
	public var SignalStopped:Signal;
	public var m_VideoPath:String;
	public var m_VideoStatusView:Label;
	public var m_VideoPlayerBg:MovieClip;
	public var m_PlayButton:Button;
	public var m_PauseButton:Button;
	public var m_Subtitle:TextField;
	
	private var counter:Number;
	
	public function VideoPlayer()
	{		
        m_IsInitialized = false;
		m_PlayButton._visible = false;
		m_PauseButton._visible = false;
		m_ShowOverlay = true;
		
		SignalInitialized = new com.Utils.Signal;
		SignalLoaded = new com.Utils.Signal;
		SignalStopped = new com.Utils.Signal;
		SignalFailedToLoad = new com.Utils.Signal;
			
		m_NetConnection = new NetConnection();
		m_NetConnection.connect(null);
		m_NetStream = new NetStream( m_NetConnection );
		m_NetStream.vol
		m_VideoPlayerBg.onPress = function() { };
		
		// Looks like onStatus needs to have the exact right signature, or it won't be called. So a delegate does not work.
        var videoPlayer = this; // Make a copy for the closure
		m_NetStream.onStatus = function(infoObject:Object) { videoPlayer.OnStatusUpdate( infoObject ); }
		m_NetStream.onMetaData = function(infoObject:Object)
		{
			if (videoPlayer.m_WantedAudioTrack != undefined && videoPlayer.m_WantedAudioTrack >= 0)
			{
				videoPlayer.m_AudioTracks = infoObject.audioTracks;
				if (videoPlayer.m_AudioTracks != undefined && videoPlayer.m_WantedAudioTrack < videoPlayer.m_AudioTracks.length)
				{
					videoPlayer.m_NetStream.audioTrack = videoPlayer.m_AudioTracks[videoPlayer.m_WantedAudioTrack].trackIndex;
				}
			}
			if (videoPlayer.m_WantedSubtitleTrack != undefined && videoPlayer.m_WantedSubtitleTrack >= 0)
			{
				videoPlayer.m_SubtitleCount = infoObject.subtitleTracksNumber;
				if (videoPlayer.m_SubtitleCount != undefined && videoPlayer.m_WantedSubtitleTrack <= videoPlayer.m_SubtitleCount)
				{
					videoPlayer.m_NetStream.subtitleTrack = videoPlayer.m_WantedSubtitleTrack + 1;
				}
			}
		}
		m_NetStream.onSubtitle = function(subtitle:String)
		{
			videoPlayer.m_Subtitle.htmlText = subtitle;
			videoPlayer.m_Subtitle._x = videoPlayer.m_VideoView._x + 1;
			videoPlayer.m_Subtitle._y = videoPlayer.m_VideoView._y + videoPlayer.m_VideoView._height - videoPlayer.m_Subtitle._height;
		}
		
		m_VideoView.attachVideo( m_NetStream );
		
		if (m_Subtitle != undefined)
		{
			m_Subtitle.autoSize = "left";
			m_Subtitle.multiline = true;
			m_Subtitle.wordWrap = true;
			m_Subtitle._width = m_VideoView._width - 2;
			m_Subtitle.html = true;
			m_Subtitle.htmlText = "";
			
			// shady...
			var shadow:DropShadowFilter = new DropShadowFilter( 40, 70, 0x000000, 0.7, 2.0, 2.0, 2.0, 2.5, false, false, false );
			m_Subtitle.filters = [shadow];
		}
		
		this.attachAudio( m_NetStream );
		m_Sound = new Sound(this);
		if (m_WantedVolume != undefined)
		{
			m_Sound.setVolume(m_WantedVolume);
		}
		
        UpdateLayout();
	}
	
	public function SetSubtitleTrack(track:Number)
	{
		m_WantedSubtitleTrack = track;
	}
	
	public function SetAudioTrack(track:Number)
	{
		m_WantedAudioTrack = track;
	}
	
	public function SetVolume(volume:Number)
	{
		m_WantedVolume = volume;
		if (m_Sound != undefined)
		{
			m_Sound.setVolume(volume);
		}
	}
	
	private function onMouseMove()
	{
		HideShowControls();
    }
	
	private function HideShowControls()
	{
		if ( m_IsPlaying )
        {
            if ( Mouse["IsMouseOver"]( this ) || Mouse["IsMouseOver"]( m_PauseButton ) )
            {
                MovieClip(m_PauseButton).tweenTo( 0.2, { _alpha: 100 }, None.easeOut );
            }
            else
            {
                MovieClip(m_PauseButton).tweenTo( 0.2, { _alpha: 0 }, None.easeOut );
            }
        }
	}
	
	private function onMouseUp()
    {
		if ( Mouse["IsMouseOver"]( this ) )
		{
			PausePlayVideo();
		}
    }

    private function configUI()
	{
		m_PlayButton.addEventListener("click", this, "PlayVid");
		m_PauseButton.addEventListener("click", this, "StopVid");
		
        m_IsInitialized = true;
        SignalInitialized.Emit();
	}
	
	private function PausePlayVideo()
	{		
		if (m_IsPlaying) 
		{
			StopVid();
		}
		else PlayVid();
	}
	
    private function onUnload()
    {
        super.onUnload();

        SetIsPlaying( false );
    }

    private function onEnterFrame()
    {
        m_NetStream.pause( !m_IsPlaying );  // HACK!!! Need this until Scaleform fix Netstream.pause(). It does not work when called from OnStatusUpdate() anymore.
    }

	private function PlayVid(){	StartVideo(); };
	private function StopVid(){ PauseVideo(); };
	
	private function OnStatusUpdate( infoObject:Object )
	{
		switch( infoObject.code )
		{
			case "NetStream.Play.Start":
                if ( m_VideoStatusView != undefined )
                {
                    m_VideoStatusView.text = (m_IsPlaying) ? "" : LDBFormat.LDBGetText( "VideoPlayer", "VideoReady" ).toUpperCase();
                }
				if (m_ShowOverlay)
				{
                    m_PlayButton._visible = !m_IsPlaying;
                    m_PauseButton._visible = m_IsPlaying;
				}
				m_NetStream.pause( !m_IsPlaying );
				SignalLoaded.Emit( this );
				UpdateLayout();
			break;
			case "NetStream.Play.StreamNotFound":
                if ( m_VideoStatusView != undefined )
                {
                    m_VideoStatusView.text = LDBFormat.LDBGetText( "VideoPlayer", "FailToLoad" );
                }
                UpdateLayout();
				trace ( "Video failed to load" );
				SignalFailedToLoad.Emit( this );
			break;
			case "NetStream.Play.Stop":
                SetIsPlaying( false );
				SignalStopped.Emit( this );
				break;
			case "NetStream.Seek.Notify":
				trace("NetStream.Seek.Notify");
				break;
			default:
				trace("NetStream.onStatus called with unhandled code: ("+getTimer()+" ms)");
				for (var prop in infoObject)
				{
					trace("\t"+prop+":\t"+infoObject[prop]);
				}
                if ( m_IsPlaying && infoObject.level == "error" )
                {
                    SetIsPlaying( false );
                    SignalStopped.Emit( this );
                }
			break;
		}
	}

    public function IsInitialized() : Boolean
    {
        return m_IsInitialized;
    }
    
	public function LoadVideo( path:String ) : Void
	{
        if ( m_VideoStatusView != undefined )
        {
            m_VideoStatusView.text = LDBFormat.LDBGetText( "VideoPlayer", "LoadingVideo" );
        }
        UpdateLayout();
        m_NetStream.close();
		m_NetStream.play( path );
        SetIsPlaying( true );
	}
	
	private function UpdateLayout()
	{
		m_PlayButton._xscale = 100 / ( this._xscale/100 );
		m_PlayButton._yscale = 100 / ( this._yscale/100 );
		m_PauseButton._xscale = 100 / ( this._xscale/100 );
		m_PauseButton._yscale = 100 / ( this._yscale/100 );
        if ( m_VideoStatusView != undefined )
        {
            m_VideoStatusView._xscale = 100 / ( this._xscale/100 );
            m_VideoStatusView._yscale = 100 / ( this._yscale / 100 );
        }
	}
	
	public function GetVideoSize():Point
	{
		return new Point(m_VideoView.width, m_VideoView.height);
	}
	
	public function PauseVideo()
	{
		if ( m_IsPlaying )
		{
			SetIsPlaying( false );
			m_NetStream.pause( true );
		}
	}
	
	public function StartVideo()
	{
		if ( !m_IsPlaying )
		{
			SetIsPlaying( true );
			m_NetStream.pause( false );
            if ( m_VideoStatusView != undefined )
            {
                m_VideoStatusView.text = "";
            }
		}
	}
    
	public function SetShowOverlay(show:Boolean)
	{
		m_ShowOverlay = show;
		if (!show)
		{
			m_PlayButton._visible = false;
			m_PauseButton._visible = false;
		}
		else
		{
            m_PlayButton._visible = !m_IsPlaying;
            m_PauseButton._visible = m_IsPlaying;
		}
        if ( m_VideoStatusView != undefined )
        {
            m_VideoStatusView._visible = m_ShowOverlay;
        }
	}
	
	public function SetLoop(loop:Boolean)
	{
		m_NetStream.loop = loop;
	}

    private function SetIsPlaying( isPlaying:Boolean )
    {
        if ( isPlaying != m_IsPlaying )
        {
            m_IsPlaying = isPlaying;
			if (m_ShowOverlay)
			{
				m_PlayButton._visible = !m_IsPlaying;
				m_PauseButton._visible = m_IsPlaying;
			}
            com.GameInterface.UtilsBase.AttenuateGameSounds( isPlaying );
        }
    }    
}
