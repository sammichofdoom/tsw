import flash.geom.Point;
import flash.geom.Rectangle;
import mx.transitions.easing.*;
import gfx.controls.UILoader;
import gfx.controls.Button;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import gfx.controls.Label;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.DistributedValue;

var m_ContentMargin:Number = 25;
var m_ScreenMargin:Number = ((Stage.height/100)*5);//80;

var m_ResolutionScaleMonitor:DistributedValue;

function onLoad()
{
    m_CloseButton.addEventListener("click", this, "Close");

    var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
        
    moduleIF.SignalStatusChanged.Connect( SlotModuleStatusChanged, this );
    SlotModuleStatusChanged( moduleIF, moduleIF.IsActive() );

    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( UpdateLayout, this );

    var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
    escapeNode.SignalEscapePressed.Connect( Close, this );
    com.GameInterface.EscapeStack.Push( escapeNode );

    m_ContentBox._alpha = 0;
    m_ContentBox._width = 0;
    m_ContentBox._height = 0;
    m_CloseButton._alpha = 0;
    m_ImageView = undefined;
    m_VideoPlayer = undefined;
    m_TextView = undefined;
}

function SlotModuleStatusChanged( module:GUIModuleIF, isActive:Boolean ) : Void
{
    _visible = isActive;
}

function Close() : Void
{
    if ( m_TextView != undefined )
    {
        m_TextView.tweenTo(0.3, { _alpha: 0 }, Regular.easeOut);
    }

    if ( m_ImageView != undefined && m_VideoPlayer == undefined )
    {
        m_ImageView.tweenTo(0.3, { _alpha: 0 }, Regular.easeOut);
        
        m_ImageView.onTweenComplete = function ()
        {
            m_ImageView.tweenEnd();
            removeMovieClip ( m_ImageView );
            CloseContentBox();
        }
    }
    else if ( m_VideoPlayer != undefined && m_ImageView == undefined )
    {
        m_VideoPlayer.tweenTo(0.3, { _alpha: 0 }, Regular.easeOut);
        m_VideoPlayer.onTweenComplete = function ()
        {
            m_VideoPlayer.tweenEnd();
            removeMovieClip ( m_videoPlayer );
            CloseContentBox();
        }
        m_VideoPlayer.PauseVideo();
    }
    else
    {
        CloseContentBox();
    }    
}

function CloseContentBox () : Void
{
    m_CloseButton.tweenTo(0.1, { _alpha: 0 }, None.easeNone);
    m_CloseButton.onTweenComplete = undefined; 
    m_ContentBox.tweenTo(0.3, {_alpha: 0, _width: 0 , _height: 0, _x: _xmouse, _y: _ymouse}, Regular.easeOut );
    m_ContentBox.onTweenComplete = function ()
    {
        m_ContentBox._alpha = 0;
        //CloseMediaPlayer();
    }
}

function CloseMediaPlayer () : Void
{
    GUIFramework.SFClipLoader.MakeClipModal(this, false);
    this.UnloadClip();
}


function ParseResourceID( resourceID ) : String
{
    if ( resourceID.hasOwnProperty( "type" ) && resourceID.hasOwnProperty( "instance" ) )
    {
        return com.Utils.Format.Printf( "rdb:%.0f:%.0f", resourceID.type, resourceID.instance );
    }
    else if ( resourceID.hasOwnProperty( "m_Type" ) && resourceID.hasOwnProperty( "m_Instance" ) )
    {
        return com.Utils.Format.Printf( "rdb:%.0f:%.0f", resourceID.GetType(), resourceID.GetInstance() );
    }
    else
    {
        return resourceID;
    }
}

function GetContentBoxSize():Point
{
    var width:Number;
    var height:Number;
    
    if ( m_ImageView != undefined && m_TextView == undefined )
    {
        width = m_ImageView._width + 2*m_ContentMargin;
        height = m_ImageView._height + 2*m_ContentMargin;
    }
    else if ( m_ImageView == undefined && m_VideoPlayer == undefined && m_TextView != undefined )
    {
        width = m_TextView._width + 2*m_ContentMargin;
        height = m_TextView.textField._height + 4 * m_ContentMargin;
    }
    else
    {
        width = Stage.width - (m_ScreenMargin * 2);
        height = Stage.height - (m_ScreenMargin * 2);
    }
    
    return new Point(width, height);
}

function ContentBoxLayout(snap:Boolean)
{
    var contentBoxSize:Point = GetContentBoxSize();
    var x:Number;
    var y:Number;

    if ( m_ImageView != undefined && m_VideoPlayer == undefined && m_TextView == undefined )
    { 
        x = m_ImageView._x - m_ContentMargin;
        y = m_ImageView._y - m_ContentMargin;
        GUIFramework.SFClipLoader.MakeClipModal(this, false);
    }
    else if ( m_ImageView == undefined && m_VideoPlayer == undefined && m_TextView != undefined )
    {
        x = m_TextView._x - m_ContentMargin;
        y = m_TextView._y - 2 * m_ContentMargin;
        GUIFramework.SFClipLoader.MakeClipModal(this, false);
    }
    else
    {
        x = Stage["visibleRect"].x + m_ScreenMargin;
        y = Stage["visibleRect"].y + m_ScreenMargin;
    }
    
    if (snap)
    {
        m_ContentBox._x = x;
        m_ContentBox._y = y;
        m_ContentBox._width = contentBoxSize.x;
        m_ContentBox._height = contentBoxSize.y;
        m_CloseButton._x = x + contentBoxSize.x - 25;
        m_CloseButton._y = y + 8;
        m_ContentBox._alpha = 100;
    }
    else
    {
        m_ContentBox._x = _root._xmouse;
        m_ContentBox._y = _root._ymouse;
        m_ContentBox.tweenTo( 0.1, {_alpha: 100, _width: contentBoxSize.x, _height: contentBoxSize.y, _x: x, _y: y}, None.easeNone);
        m_ContentBox.onTweenComplete = undefined;

        m_CloseButton._x = x + contentBoxSize.x - 25;
        m_CloseButton._y = y + 8;   
        m_CloseButton._alpha = 0;
        m_CloseButton.tweenTo(0.1, { _alpha: 100 }, None.easeNone);
        m_CloseButton.onTweenComplete = undefined;    
    }
}

function OpenContentBox() : Void
{
    ContentBoxLayout(false);
}

function LoadArgumentsReceived ( args:Array ) : Void
{
    GUIFramework.SFClipLoader.MakeClipModal(this, true);
    var mediaData = args[0];

    var stageRect:Rectangle = Stage["visibleRect"];
    
    if ( mediaData.hasOwnProperty ( "Text" ) )
    {
        m_TextView = attachMovie ( "TextView", "m_TextView", getNextHighestDepth() );    
        m_TextView.textField.multiline = true;
        m_TextView.textField.autoSize = "center";
        m_TextView.textField.html = true;
        m_TextView.textField.wordWrap = true;

        m_TextView.textField._width = Stage.width - (m_ScreenMargin * 2) - (m_ContentMargin * 2);
        var str:String = LDBFormat.Translate(mediaData.Text);
        m_TextView.textField.htmlText = str.split('\r\n').join('\r');
        
        if (m_TextView.textField.textHeight > Stage.height/3)
        {
            //if there are different font sizes in the textfield, all of them will be set to the same size
            var tfCommon:TextFormat = m_TextView.textField.getTextFormat();
            var newFontSize:Number = 14; //In case TextFormat getFontsSize fails
            if (tfCommon.size == undefined || tfCommon.size < 2)
            {
                var tfFirstCharacter:TextFormat = m_TextView.textField.getTextFormat(0);
                if (tfFirstCharacter!=undefined && tfFirstCharacter.size > 2)
                {
                    newFontSize = tfFirstCharacter.size - 2;
                }
            }
            else 
            {
                newFontSize = tfCommon.size - 2;
            }
            if (newFontSize >= 2)
            {
                tfCommon.size = newFontSize;
            }
            
            m_TextView.textField.setTextFormat(tfCommon);
        }
        
        m_TextView._alpha = 0;
        m_TextView._height = m_TextView.textField.textHeight;

        m_TextView._x = stageRect.x + ((Stage.width / 2 ) - ( m_TextView._width / 2 )) + 5;
        m_TextView._y = stageRect.y + ((Stage.height / 2 ) - ( m_TextView._height / 2 ));
        m_TextView.tweenTo(1, { _alpha: 100 }, Regular.easeOut );
    }
    
    if ( mediaData.hasOwnProperty ( "Image" ) )
    {
        m_ImagePath =  ParseResourceID ( mediaData.Image );
            
        m_ImageView = attachMovie ( "ImageViewer", "m_ImageView", this.getNextHighestDepth() );
        
        var imageLoader:MovieClipLoader = new MovieClipLoader();
        var imageListener:Object = new Object();
         
        imageListener.onLoadStart = function( target:MovieClip )
        {
            target._alpha = 0;
        }

        imageListener.onLoadComplete = function( target:MovieClip )
        {
            UpdateLayout();

            target.tweenTo( 1, { _alpha: 100 }, Strong.easeOut );
            target.onTweenComplete = undefined;
            OpenContentBox();
        }

        imageLoader.addListener( imageListener );
        imageLoader.loadClip( m_ImagePath, m_ImageView );
    }
    
    if ( mediaData.hasOwnProperty ( "Video" ) )
    {
        m_VideoPath = ParseResourceID( mediaData.Video );
        
        m_VideoPlayer = attachMovie ( "VideoPlayer", "m_VideoPlayer", this.getNextHighestDepth() );
        videoView = m_VideoPlayer.m_VideoView;
        
        m_VideoPlayer.LoadVideo( m_VideoPath );
        m_VideoPlayer._alpha = 0;
        
        setTimeout(OnSetupVideoPlayer, 10);
        
        m_VideoPlayer.tweenTo( 1, { _alpha: 100 }, Strong.easeOut );
    }
    if (m_ImageView == undefined)
    {
        OpenContentBox();
    }
}

function OnSetupVideoPlayer()
{
    m_VideoPlayer.SignalLoaded.Connect(UpdateLayout, this);
    UpdateLayout();
    ContentBoxLayout(true);
}

function ScaleImage(target:MovieClip):Void
{
    target._xscale = target._yscale = 100;
    var windowWidth:Number = Stage.width - (m_ContentMargin * 2) - (m_ScreenMargin * 2);
    var textHeight:Number = 0;
    if (m_TextView != undefined)
    {
        textHeight = m_TextView.textField._height;
    }
    windowHeight = Stage.height - (m_ContentMargin * 2) - (m_ScreenMargin * 2) - textHeight;
   
    target._xscale = target._yscale = Math.min(Math.min(windowWidth / target._width, windowHeight / target._height), 1) * 100;
}

function ScaleVideo()
{
    var contentBoxSize:Point = GetContentBoxSize();
    var videoSize:Point = m_VideoPlayer.GetVideoSize();
    var textHeight:Number = 0;
    
    if (m_TextView != undefined)
    {
        textHeight = m_TextView.textField.textHeight + m_ContentMargin;
    }
    
    m_VideoPlayer._height = contentBoxSize.y - (m_ContentMargin * 2) - textHeight;
    vidScaled = m_VideoPlayer._height / videoSize.y;
    m_VideoPlayer._width = videoSize.x * vidScaled;
    
    if ( m_VideoPlayer._width > contentBoxSize.x )
    {
        m_VideoPlayer._width = contentBoxSize.x - (m_ContentMargin * 2);
        vidScaled = m_VideoPlayer._width / videoSize.x;
        m_VideoPlayer._height = videoSize.y * vidScaled;
        if (m_TextView != undefined)
        {
            textHeight = m_TextView.textField._height;
        }
        m_VideoPlayer._height = _VideoPlayer._height - textHeight;
        vidScaled2 = (m_VideoPlayer._height / videoSize.y);
        m_VideoPlayer._width = videoSize.x * vidScaled;
    }
}

function VerticalPositionWithText(target:MovieClip, hasText:Boolean):Void
{
    if (hasText)
    {
        target._y = Stage["visibleRect"].y + ((Stage.height / 2) - (target._height / 2) - (m_ContentMargin / 4) - (m_TextView._height / 2))
        m_TextView._y = target._y + target._height + (m_ContentMargin / 2);
    }
    else
    {
        target._y = Stage["visibleRect"].y + ((Stage.height / 2) - (target._height / 2));
    }
}

function UpdateLayout()
{
    if ( m_VideoPlayer != undefined )
    {
        ScaleVideo();
        
        m_VideoPlayer._x = Stage["visibleRect"].x + ((Stage.width/2) - (m_VideoPlayer._width/2) );
        VerticalPositionWithText(m_VideoPlayer, m_TextView != undefined);
            
        if ( m_TextView != undefined )
          {            
            m_TextView._x = (Stage.width / 2 ) - ( m_TextView._width/2 ) + Stage["visibleRect"].x;
            m_TextView._y = m_VideoPlayer._y + m_VideoPlayer._height + m_ContentMargin;
          }
    }
    else if ( m_ImageView != undefined )
    {
        ScaleImage(m_ImageView);
        
        m_ImageView._x = Stage["visibleRect"].x + ((Stage.width/2) - (m_ImageView._width/2) );
        VerticalPositionWithText( m_ImageView, m_TextView != undefined );
            
        if ( m_TextView != undefined )
          {
            m_TextView._x = (Stage.width / 2 ) - ( m_TextView._width/2 ) + Stage["visibleRect"].x;
            m_TextView._y = m_ScreenMargin + m_ContentMargin + m_ImageView._height + Stage["visibleRect"].y - 2;
          }
    }
}