//Imports
import com.Components.WindowComponentContent;
import flash.geom.Rectangle;
import flash.geom.Point;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import gfx.controls.UILoader;
import com.Utils.ID32;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import gfx.controls.Label;
import com.Components.VideoPlayer;


//Class
class GUI.MediaPlayer.MediaPlayerContent extends WindowComponentContent
{
    //Properties
    private var m_TextView:MovieClip;
    private var m_ImageView:MovieClip;
    private var m_VideoPlayer:MovieClip;
    
    public var SignalContentLoaded:Signal;
    public var SignalErrorLoading:Signal;
    
    private var m_ContentMargin:Number = 25;
    private var m_ScreenMargin:Number = ((Stage.height / 100) * 2);
    private var m_HasPreviouslyFailedLoading:Boolean = false;
    private var m_ImagePath:String;
    
    //Constructor
    public function MediaPlayerContent()
    {
        super();
        
        SignalContentLoaded = new Signal();
        SignalErrorLoading = new Signal();
    }
    
    
    //On Load
    private function onLoad():Void
    {
        m_ImagePath = undefined;
    }
    
    public function Close() : Void
    {
        if ( m_ImageView != undefined && m_VideoPlayer == undefined )
        {
            removeMovieClip ( m_ImageView );
        }
        else if ( m_VideoPlayer != undefined && m_ImageView == undefined )
        {
            m_VideoPlayer.PauseVideo();
            removeMovieClip ( m_VideoPlayer );
        }
    }

    
    public function SetText(text:String) : Void
    {
        m_TextView = this.attachMovie ( "TextView", "m_TextView", getNextHighestDepth() );    
        m_TextView.textField.multiline = true;
        m_TextView.textField.autoSize = "left";
        m_TextView.textField.html = true;
        m_TextView.textField.wordWrap = false;

        var str:String = LDBFormat.Translate(text);
        m_TextView.textField.htmlText = str.split('\r\n').join('\r');

        m_TextView._width = m_TextView.textField.textWidth;
        m_TextView._height = m_TextView.textField.textHeight;

        m_TextView._x = stageRect.x + ((Stage.width / 2 ) - ( m_TextView._width / 2 )) + 5;
        m_TextView._y = stageRect.y + ((Stage.height / 2 ) - ( m_TextView._height / 2 ));
    }
    
    public function SetImage(image:Object) : Void
    {
        m_ImagePath =  ParseResourceID ( image );
            
        if ( m_ImageView != undefined )
        {
            m_ImageView.removeMovieClip();
            m_ImageView = undefined;
        }
        
        m_ImageView = this.attachMovie ( "ImageViewer", "m_ImageView", this.getNextHighestDepth() );
        var imageLoader:MovieClipLoader = new MovieClipLoader();
        var imageListener:Object = new Object();

        imageListener.onLoadComplete = function( target:MovieClip )
        {
            target._parent.SlotFinishLoading();
        }
        
        imageListener.onLoadError = Delegate.create(this, SlotLoadImageError);
        
        imageLoader.addListener( imageListener );
        imageLoader.loadClip( m_ImagePath, m_ImageView );
    }

    private function SlotLoadImageError(target_mc:MovieClip, errorCode:String, httpStatus:Number) : Void
    {
        trace("[MediaPlayerConten.as] loadListener.onLoadError()");
        trace("==========================");
        trace("errorCode: " + errorCode);
        
        //try to load image as a .swf
        if (!m_HasPreviouslyFailedLoading && m_ImagePath!=undefined)
        {
            m_HasPreviouslyFailedLoading = true;
            var pathArray:Array = m_ImagePath.split(":");
            if (pathArray.length >= 3)
            {
                var newPath:String = com.Utils.Format.Printf( "rdb:%.0f:%.0f", _global.Enums.RDBID.e_RDB_FlashFile, pathArray[2] );
                SetImage(newPath);
            }
        }
        else
        {
            SignalErrorLoading.Emit();
        }
    }

        
    public function SetVideo(video:Object) : Void
    {
        var path:String = ParseResourceID( video );
        
        m_VideoPlayer = this.attachMovie ( "VideoPlayer", "m_VideoPlayer", this.getNextHighestDepth() );
        videoView = m_VideoPlayer.m_VideoView;

        m_VideoPlayer.SignalLoaded.Connect(SlotFinishLoading, this);
        m_VideoPlayer.LoadVideo( path );
        m_VideoPlayer._visible = false;
    }
    
    private function SlotFinishLoading():Void
    {
        SignalContentLoaded.Emit();
    }
    
    private function GetContentBoxSize():Point
    {
        var width:Number = Stage["visibleRect"].width - (m_ScreenMargin * 2) - (m_ContentMargin * 2);
        var height:Number = Stage["visibleRect"].height - (m_ScreenMargin * 2) - (m_ContentMargin * 2);
        return new Point(width, height);
    }
    
    private function ParseResourceID( resourceID:Object ) : String
    {
        var resource:String = "";
        if ( resourceID.hasOwnProperty( "type" ) && resourceID.hasOwnProperty( "instance" ) )
        {
            resource = com.Utils.Format.Printf( "rdb:%.0f:%.0f", resourceID.type, resourceID.instance );
        }
        else if ( resourceID.hasOwnProperty( "m_Type" ) && resourceID.hasOwnProperty( "m_Instance" ) )
        {
            resource = com.Utils.Format.Printf( "rdb:%.0f:%.0f", resourceID.GetType(), resourceID.GetInstance() );
        }
        else if( resourceID!= undefined )
        {
            resource = resourceID.toString(); //"rdb:1000624:7636004";
        }
        //trace("Loading:"+resource);
        return resource;
    }
    
    private function ScaleText():Void
    {
        if ( m_TextView._height > Stage.height/3 || (m_TextView._width+ 2*m_ScreenMargin + 2*m_ContentMargin) > Stage.width )
        {
            if ( (m_TextView._width+ 2*m_ScreenMargin + 2*m_ContentMargin) > Stage.width )
            {
                m_TextView.textField.wordWrap = true;
                m_TextView._width = m_TextView.textField.textWidth = m_TextView.textField._width = Stage.width - 2 * m_ScreenMargin - 2 * m_ContentMargin;
            }
            
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
            
            m_TextView._width = m_TextView.textField.textWidth;
            m_TextView._height = m_TextView.textField.textHeight;
        }
    }
    
    private function ScaleImage(target:MovieClip):Void
    {
        var contentBoxSize:Point = GetContentBoxSize();
        target._xscale = target._yscale = 100;
        var windowWidth:Number = Stage.width - (m_ContentMargin * 2) - (m_ScreenMargin * 2);
        var textHeight:Number = 0;
        if (m_TextView != undefined)
        {
            textHeight = m_TextView._height + m_ContentMargin;
        }
        windowHeight = contentBoxSize.y - (m_ContentMargin * 2) - textHeight;
       
        target._xscale = target._yscale = Math.min(Math.min(windowWidth / target._width, windowHeight / target._height), 1) * 100;
    }

    private function ScaleVideo()
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
                textHeight = m_TextView.textField._height + m_ContentMargin;
            }
            m_VideoPlayer._height = _VideoPlayer._height - textHeight;
            vidScaled2 = (m_VideoPlayer._height / videoSize.y);
            m_VideoPlayer._width = videoSize.x * vidScaled;
        }
    }

    private function Layout()
    {
        super.Layout();
        if ( m_TextView != undefined )
        {
            ScaleText();
        }
        
        if ( m_VideoPlayer != undefined )
        {
            m_VideoPlayer._visible = true;
            ScaleVideo();
            
            m_VideoPlayer._x = m_VideoPlayer._y = m_ContentMargin;
                
            if ( m_TextView != undefined )
            {            
                m_TextView._x = Math.max( m_ContentMargin, ( m_VideoPlayer._x + m_VideoPlayer._width / 2) - ( m_TextView._width / 2 ));
                m_TextView._y = m_VideoPlayer._y + m_VideoPlayer._height + m_ContentMargin;
                if (m_TextView._width >  m_VideoPlayer._width)
                {
                    m_VideoPlayer._x = m_TextView._x + m_TextView._width / 2 - m_VideoPlayer._width / 2;
                }
            }
        }
        else if ( m_ImageView != undefined )
        {
            ScaleImage(m_ImageView);
            
            m_ImageView._x = m_ImageView._y = m_ContentMargin;
                
            if ( m_TextView != undefined )
            {
                m_TextView._x =  Math.max( m_ContentMargin, ( m_ImageView._x + m_ImageView._width / 2) - ( m_TextView._width / 2 ));
                m_TextView._y = m_ImageView._y + m_ImageView._height + m_ContentMargin;
                
                if (m_TextView._width >  m_ImageView._width)
                {
                    m_ImageView._x = m_TextView._x + m_TextView._width / 2 - m_ImageView._width / 2;
                }
            }
        }
        SignalSizeChanged.Emit();
    }
    
    public function GetSize():Point
    {
        var width:Number = this._width;
        var height:Number = this._height;
        
        if (m_ImageView != undefined) 
        {
            width = Math.max( width, m_ImageView._width );
            height = Math.max( height, m_ImageView._height );
        }
        
        if (m_VideoPlayer != undefined) 
        {
            width = Math.max( width, m_VideoPlayer._width );
            height = Math.max( height, m_VideoPlayer._height );
        }
  /*      
        if (m_TextView != undefined) 
        {
            width = Math.max( width, m_TextView._width );
            height += m_TextView._height ;// + m_ContentMargin;
        }
    */           
        width += 2 * m_ContentMargin;
        height += 2 * m_ContentMargin;
        
        return new Point(width, height);
    }
    
}
