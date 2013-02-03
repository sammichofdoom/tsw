import flash.external.*;
import com.Utils.Signal;

import GUIFramework.ClipNode;
import GUIFramework.SFClipLoaderBase;

class GUIFramework.SFClipLoader // extends SFClipLoaderBase
{
    private static var m_Loader:MovieClipLoader;
    private static var m_CurrentScreenRes:flash.geom.Point = new flash.geom.Point( Stage.width, Stage.height );
    private static var m_NextClipID:Number = 1;
    private static function SetupLoader() : Void
    {
        var listener:Object = new Object();
        listener.onLoadInit     = OnLoadInit;
        listener.onLoadComplete = OnLoadComplete;
        listener.onLoadError    = OnLoadError;
        m_Loader = new MovieClipLoader();
        m_Loader.addListener( listener );
    }

    public static var SignalDisplayResolutionChanged:Signal = new Signal; // SlotDisplayResolutionChanged( prevResolution:flash.geom.Point ) : Void
    public static var SignalFrameStarted:Signal = new Signal; // SlotFrameStarted() : Void
    
    ////////////////////////////////////////////////////////////////////////////////
    /// Update movieclip frames and send the SignalDisplayResolutionChanged.
    /// Note: Should only be called from GUIFramework.
    ////////////////////////////////////////////////////////////////////////////////

    public static function OnScreenResChanged() : Void
    {
        var prevResolution:flash.geom.Point = m_CurrentScreenRes;
        m_CurrentScreenRes = new flash.geom.Point( Stage.width, Stage.height );

        if ( m_CurrentScreenRes != prevResolution )
        {
            for ( var i:Number = 0 ; i < s_TopLevelClips.length ; ++i )
            {
                UpdateClipSize( s_TopLevelClips[i] );
            }
            SignalDisplayResolutionChanged.Emit( prevResolution );
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    /// Create an empty top-level movie clip that will be handled like a
    /// movie clip created with LoadClip() in regard to depth arangement.
    ///
    /// To remove the clip again call clip.UnloadClip() on the returned movieclip.
    /// This will assure the the movieclip itself and any meta-data will be removed.
    ////////////////////////////////////////////////////////////////////////////////

    public static function CreateEmptyMovieClip(name:String, depthLayer:Number, subDepth:Number):MovieClip
    {
        var returnClip:MovieClip = _root.createEmptyMovieClip(name, _root.getNextHighestDepth());
        GUIFramework.SFClipLoader.AddClip( name, returnClip, depthLayer, subDepth );
        returnClip.UnloadClip = function () : Void { SFClipLoader.RemoveClipNode( this ); this.removeMovieClip(); }

        return returnClip;
    }
    
    public static function LoadClip( url:String, objectName:String, stretchToScreen:Boolean, depthLayer:Number, subDepth:Number, loadArguments:Array ) : ClipNode
    {
        if ( m_Loader == undefined )
        {
            SetupLoader();
        }
        var clipName:String = objectName + "_" + m_NextClipID++ + "_";
        
        var movie:MovieClip = _root.createEmptyMovieClip( clipName, _root.getNextHighestDepth() );
        _root[objectName] = movie;
        
        var clipNode = new ClipNode( objectName, clipName, movie, stretchToScreen, depthLayer, subDepth, loadArguments );
        SFClipLoader.AddClipNode( clipNode );
        m_Loader.loadClip( url, movie );
        return clipNode;
    }

    public static function AddClip( objectName:String, clip:MovieClip, depthLayer:Number, subDepth:Number ) : ClipNode
    {
        var clipNode:ClipNode = new ClipNode( objectName, objectName, clip, false, depthLayer, subDepth, undefined );

        SFClipLoader.AddClipNode( clipNode );

        return clipNode;
    }
    
    public static function UnloadClip( objectName:String )
    {
        var movie:MovieClip = _root[objectName];
        if ( movie instanceof MovieClip )
        {
            if (movie.OnUnload != undefined)
            {
                movie.OnUnload();
            }
            m_Loader.unloadClip( objectName );
            movie.removeMovieClip();
            RemoveClipNode( movie );
            SFClipLoaderBase.ClipUnloaded( objectName );
        }
    }
    
    /// Returns the index of the topmost toplevel clip that intersects with (x,y).
    /// If no clip intersects -1 is returned.
    
    public static function FindClipByPos( x:Number, y:Number ) : Number
    {
        for ( var i:Number = s_TopLevelClips.length - 1 ; i >= 0 ; --i )
        {
            var movie:MovieClip = s_TopLevelClips[i].m_Movie;
            if ( movie.hitTest( x, y, true,true ) )
            {
                return i;
            }
        }
        return -1;
    }

    /// Search the list of toplevel clips for \a movie. If found the index
    /// is returned, if not -1 is returned.
    
    public static function GetClipIndex( movie:MovieClip ) : Number
    {
        for ( var i:Number = 0 ; i < s_TopLevelClips.length ; ++i )
        {
            if ( s_TopLevelClips[i].m_Movie == movie )
            {
                return i;
            }
        }
        return -1;
    }

    /// Move the clip at position \a index to the frontmost position
    /// within it's sorting layer. I.e. in front of all other clips
    /// with equal depth layer and sub depth as itself.
    
    public static function MoveToFront( index:Number ) : Void
    {
        if ( index >= 0 && index < (s_TopLevelClips.length - 1) )
        {
            var movie:MovieClip = s_TopLevelClips[index].m_Movie;
            
            // "Bubble" the view up both in depth level, and in s_TopLevelClips until it reach the top or it is just below
            // another clip with a higher depth sort value.
            for (  var j:Number = index + 1 ; j < s_TopLevelClips.length && s_TopLevelClips[j].Compare( s_TopLevelClips[index] ) <= 0 ; ++j )
            {
                movie.swapDepths( s_TopLevelClips[ j ].m_Movie.getDepth() );
                var tmp = s_TopLevelClips[j];
                s_TopLevelClips[j] = s_TopLevelClips[j-1];
                s_TopLevelClips[j-1] = tmp;
            }
        }
    }

    public static function SetClipLayer( index:Number, depthLayer:Number, subDepth:Number ) : Void
    {
        if ( index >= 0 && index < s_TopLevelClips.length )
        {
            var clipNode:ClipNode = s_TopLevelClips[index];
            RemoveClipByIndex( index, false );
            clipNode.m_Movie.swapDepths( _root.getNextHighestDepth() );
            clipNode.m_DepthLayer = depthLayer;
            clipNode.m_SubDepth   = subDepth;
            AddClipNode( clipNode );

        }
    }

    /// Add a movie clip to the list of toplevel clips, and sort it according to depth layer and sub depth.
    /// This function should only be useed by GUIFramework.swf.
    
    public static function AddClipNode( clipNode:ClipNode )
    {
        for ( var i = s_TopLevelClips.length - 1 ; i >= -1 ; --i )
        {
            if ( i == -1 || s_TopLevelClips[i].Compare( clipNode ) <= 0 )
            {
                // Bubble the new movie down to it's designated position.
                for ( var j = s_TopLevelClips.length - 1 ; j > i ; --j )
                {
                    clipNode.m_Movie.swapDepths( s_TopLevelClips[ j ].m_Movie.getDepth() );
                }
                s_TopLevelClips.splice( i + 1, 0, clipNode );
                break;
            }
        }
  
    }

    /// Remove a movie clip to the list of toplevel clips.
    /// This function should only be useed by GUIFramework.swf.
    
    public static function RemoveClipByIndex( index:Number /*, [removeFromModal:Boolean]*/ ) : Void
    {
        if ( index != -1 )
        {
            var removeFromModal:Boolean = true;
            if ( arguments.length > 1 )
            {
                removeFromModal = arguments[1];
            }
            if ( removeFromModal )
            { 
                var clipNode:ClipNode = s_TopLevelClips[index];
                if ( clipNode.m_ModalLevel != 0 )
                {
                    for ( var i:Number = 0 ; i < s_ModalClips.length ; ++i )
                    {
                        if ( s_ModalClips[i] == clipNode.m_Movie )
                        {   
                            s_ModalClips.splice( i, 1 );
                            break;
                        }
                    }              
                }
            }
            s_TopLevelClips.splice( index, 1 );
            
            if (clipNode.m_ModalLevel != 0 && s_ModalClips.length == 1 )
            {
                RemoveModalBlocker();
            }
        }
    }

    public static function RemoveClipNode( movie:MovieClip ) : Void
    {
        RemoveClipByIndex( GetClipIndex( movie ) );
    }
    
    public static function OnLoadInit( clip:MovieClip )
    {
        var clipNode:ClipNode = s_TopLevelClips[GetClipIndex( clip )];
        var objectName = clipNode.m_ObjectName; // Make sure it is included in the closure
        clip.UnloadClip = function () : Void { SFClipLoader.UnloadClip( objectName ); delete _root[objectName]; }
        UpdateClipSize( clipNode );
    }

    private static function UpdateClipSize( clipNode:ClipNode )
    {
        var resizeHandler:Function = clipNode.m_Movie['ResizeHandler'];
        if( resizeHandler == undefined )
        {
            if ( clipNode.m_StretchToScreen )
            {
                clipNode.m_Movie._x = 0;
                clipNode.m_Movie._y = 0;
                clipNode.m_Movie._width  = Stage.width;
                clipNode.m_Movie._height = Stage.height;
            }
        }
        else 
        {
            resizeHandler(Stage.height, Stage.width, 0, 0);
        }
    }

    private static function OnLoadComplete( movie:MovieClip, status:Number) : Void
    {
        var clipIndex:Number = GetClipIndex( movie );
        if ( clipIndex != -1 )
        {
            var clipNode:ClipNode = s_TopLevelClips[clipIndex];

            SFClipLoaderBase.ClipLoaded( clipNode.m_ObjectName, true );
            
            if ( movie.hasOwnProperty( "LoadArgumentsReceived" ) )
            {
                movie.LoadArgumentsReceived( clipNode.m_LoadArguments );
            }
            clipNode.SignalLoaded.Emit( clipNode, true );
        }
    }
    
    private static function OnLoadError( movie:MovieClip, status:Number) : Void 
    {
        trace("onLoadError. Failed loading: " + movie);

        var clipIndex:Number = GetClipIndex( movie );
        if ( clipIndex != -1 )
        {
            var clipNode:ClipNode = s_TopLevelClips[clipIndex];
            clipNode.SignalLoaded.Emit( clipNode, false );
            SFClipLoader.RemoveClipByIndex( clipIndex );
            
            SFClipLoaderBase.ClipLoaded( clipNode.m_ObjectName, false );
        }
    }
    
    private static function AddModalBlocker()
    {
        var mouseCaptureClip:MovieClip = _root.createEmptyMovieClip( "MouseCaptureLayer", _root.getNextHighestDepth() );
        mouseCaptureClip.onPress = function() {}
        mouseCaptureClip.onRelease = function() {}
        mouseCaptureClip.onMouseDown = function() {}
        mouseCaptureClip.onMouseRelease = function() {}

        var visibleRect = Stage["visibleRect"];
        mouseCaptureClip.beginFill(0, 0);
        mouseCaptureClip.moveTo(visibleRect.x, visibleRect.y);
        mouseCaptureClip.lineTo(visibleRect.x + visibleRect.width, visibleRect.y);
        mouseCaptureClip.lineTo(visibleRect.x + visibleRect.width, visibleRect.y + visibleRect.height);
        mouseCaptureClip.lineTo(visibleRect.x, visibleRect.y + visibleRect.height);
        mouseCaptureClip.endFill();
            
        var mouseCaptureNode = new ClipNode( "MouseCaptureLayer", "MouseCaptureLayer", mouseCaptureClip, false, 0, 0, undefined );
        mouseCaptureNode.m_ModalLevel = 1;
        s_ModalClips.push( mouseCaptureClip );
        SFClipLoader.AddClipNode( mouseCaptureNode );
    }
    
    private static function RemoveModalBlocker()
    {
        var clip = s_ModalClips[0];
        s_ModalClips = [];
        
        RemoveClipNode( clip );
        clip.removeMovieClip();
        
    }
    
    public static function MakeClipModal( clip:MovieClip, makeModal:Boolean )
    {
        var index:Number = GetClipIndex( clip );
        if ( index >= 0 && index < s_TopLevelClips.length )
        {
            var clipNode:ClipNode = s_TopLevelClips[index];
            var wasModal:Boolean = clipNode.m_ModalLevel != 0;

            if ( makeModal != wasModal )
            {
                if ( makeModal )
                {
                    if ( s_ModalClips.length == 0 )
                    {
                        AddModalBlocker();
                    }
                    s_ModalClips.push( clip );
                    clipNode.m_ModalLevel = s_ModalClips.length;
                }
                else
                {
                    for ( var i:Number = 0 ; i < s_ModalClips.length ; ++i )
                    {
                        if ( s_ModalClips[i] == clip )
                        {
                            s_ModalClips.splice( i, 1 );
                            break;
                        }
                    }
                    clipNode.m_ModalLevel = 0;
                    if ( s_ModalClips.length == 1 )
                    {
                        RemoveModalBlocker();
                    }
                }
                //Update the index to remove the correct one
                index = GetClipIndex( clip );
                RemoveClipByIndex( index, false );
                clipNode.m_Movie.swapDepths( _root.getNextHighestDepth() );
                AddClipNode( clipNode );
            }
        }
    }

    
    public static function PrintTopLevelClipsDebug()
    {
        for (var i:Number = 0; i < s_TopLevelClips.length; i++)
        {
            trace(i +": " + s_TopLevelClips[i]);
        }
    }

    private static var s_TopLevelClips:Array = [];
    private static var s_ModalClips:Array = [];
}
