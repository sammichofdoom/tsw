class com.Utils.Draw
{ 
    public function Draw()
    {
        
    }
    
    /// draws a rectangle with no or rounded cornesr
    /// @param mc:MovieClip - the movieclip to draw in
    /// @param x:Number - xpos in pixels
    /// @param y:Number - ypos in pixels
    /// @param width:Number - height in pixels
    /// @param height:Number - width in pixels
    /// @param rgb:Number - color of fill rgb
    /// @param alpha:Number - alpha 0 - 100 
    /// @param corners:Array - array containing four values [topLeft, topRight, bottomRight, bottomLeft]

    /// ---- Optional vbvalues, skips line if not set or if line == 0 ------
    /// @param line:Number - thickness of line in pixels
    /// @param lineRgb:Number - rgb color of the line
    /// @param lineAlpha - alpha 0-100
    /// @param glowEdges:Boolean - unused?
    /// @param accumulate:Boolean - retains all previously drawn graphics objects within the mc.
    
    public static function DrawRectangle(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, rgb:Number, alpha:Number, corners:Array, line:Number, lineRgb:Number, lineAlpha:Number, glowEdges:Boolean, accumulate:Boolean)
    {
		var topLeftCorner:Number = 0;
		var topRightCorner:Number = 0;
		var bottomRightCorner:Number = 0;
		var bottomLeftCorner:Number = 0;
		
		if(corners.length == 4)
		{
			topLeftCorner = corners[0];
			topRightCorner = corners[1];
			bottomRightCorner = corners[2];
			bottomLeftCorner = corners[3];
		}
		
        var w:Number = width + x;
		var h:Number = height + y;
        
	    if (accumulate == undefined)
        {
            mc.clear();
        }
        
        if (line != undefined)
        {
            mc.lineStyle(line, lineRgb, (lineAlpha != undefined) ? lineAlpha : 0);
        }
        else
        {
            mc.lineStyle();
        }
        
        mc.beginFill(rgb, alpha);
        mc.moveTo(topLeftCorner+x, y);
        mc.lineTo(w - topRightCorner, y);
        mc.curveTo(w, y, w, topRightCorner+y);
		mc.lineTo(w, topRightCorner+y);
		mc.lineTo(w, h - bottomRightCorner);
        mc.curveTo(w, h, w - bottomRightCorner, h);
        mc.lineTo(w - bottomRightCorner, h);
        mc.lineTo( bottomLeftCorner+x, h);
        mc.curveTo(x, h, x, h - bottomLeftCorner);
        mc.lineTo(x, h - bottomLeftCorner);
        mc.lineTo(x, topLeftCorner+y);
		mc.curveTo(x, y, topLeftCorner+x, y);
        mc.lineTo(topLeftCorner+x, y);
        mc.endFill();
    }
}