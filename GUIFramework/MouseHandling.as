_global.gfxExtensions = true;

var mouseListener:Object = new Object;

var m_LastClickedTime:Number = 0;
var m_ClickCount:Number = 0;
var m_LastClickedClip:MovieClip =  undefined;

mouseListener.onMouseDown = function(buttonIdx:Number, targetPath:String)
{
    SFClipLoader.MoveToFront( SFClipLoader.FindClipByPos( _xmouse, _ymouse ) );
    if (targetPath != undefined)
    {
        var date:Date = new Date();
        var mc:MovieClip = _root;
        var currentTime:Number = date.getTime();
        var splitArray:Array = targetPath.split(".");
        for (var i:Number = 0; i < splitArray.length; i++)
        {
            mc = mc[splitArray[i]];
        }
        
        while (mc != undefined)
        {
            if (mc.onMousePress != undefined)
            {
                if (m_LastClickedClip == mc && (currentTime - m_LastClickedTime) < _global.s_DoubleClickSpeed)
                {
                    m_ClickCount++;                    
                }
                else
                {
                    m_ClickCount = 1;
                }
                mc.onMousePress(buttonIdx, m_ClickCount);
                m_LastClickedTime = currentTime;
                m_LastClickedClip = mc;
                return;
            }
            mc = mc._parent;
        }
    }
}

mouseListener.onMouseUp = function(buttonIdx:Number, targetPath:String)
{
    if (targetPath != undefined)
    {
        var mc:MovieClip = _root;
        var splitArray:Array = targetPath.split(".");
        for (var i:Number = 0; i < splitArray.length; i++)
        {
            mc = mc[splitArray[i]];
        }
        
        while (mc != undefined)
        {
            if (mc.onMouseRelease != undefined)
            {
                mc.onMouseRelease(buttonIdx);
                return;
            }
            mc = mc._parent;
        }
    }
}

mouseListener.onMouseWheel = function(wheelDelta:Number, targetPath:String)
{
    SFClipLoader.MoveToFront( SFClipLoader.FindClipByPos( _xmouse, _ymouse ) );
    if (targetPath != undefined)
    {
        var mc:MovieClip = _root;
        var splitArray:Array = targetPath.split(".");
        for (var i:Number = 0; i < splitArray.length; i++)
        {
            mc = mc[splitArray[i]];
        }
        
        while (mc != undefined)
        {
            if (mc.onMouseWheel != undefined)
            {
                mc.onMouseWheel(wheelDelta);
                return;
            }
            mc = mc._parent;
        }
    }
}
  
Mouse.addListener( mouseListener );

Mouse["IsMouseOver"] = function(mc:MovieClip, testAll:Boolean)
{
    if (testAll == undefined) // if true, tests every clip, including those without mouse handlers - default true according to scaleform docs
    {
        testAll = true;
    }
	if (mc.hitTest(_root._xmouse, _root._ymouse, false))
	{
		var topMost:Object = Mouse.getTopMostEntity(testAll);
		while (topMost._parent != undefined)
		{
			if (topMost == mc)
			{
				return true;
			}
			topMost = topMost._parent;
		}
	}
    return false;
    
}

