import flash.external.*;
import gfx.motion.Tween;

import GUIFramework.SFClipLoader;
import GUIFramework.ClipNode;

#include "KeyboardHandling.as"

var m_ResizeListener:Object;

#include "MouseHandling.as"

function onLoad()
{
    _global.gfxExtensions = true;

    Tween.init();
    
    Stage.scaleMode = "noScale";
    Stage.align = "TL";
    // Turn off Tab to move to the next button.
    _root.tabChildren = false;

    m_ResizeListener = new Object();
    m_ResizeListener.onResize = OnScreenResChanged;
    Stage.addListener( m_ResizeListener );
    
    OnScreenResChanged();
}

function OnScreenResChanged()
{
    SFClipLoader.OnScreenResChanged();
}


function onFrameBegin()
{
    SFClipLoader.SignalFrameStarted.Emit();
}

function LoadFlash( url:String, objectName:String, stretchToScreen:Boolean, depthLayer:Number, subDepth:Number, loadArguments:Array )
{
    SFClipLoader.LoadClip( url, objectName, stretchToScreen, depthLayer, subDepth, loadArguments );
}

function UnloadFlash( objectName:String )
{
    SFClipLoader.UnloadClip( objectName );
}

function CustomHitTest( pos:flash.geom.Point ) : Boolean
{
    return Mouse.getTopMostEntity( pos.x + Stage["visibleRect"].x, pos.y + Stage["visibleRect"].y, false ) != undefined;
}
