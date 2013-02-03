import flash.filters.DropShadowFilter;
import com.GameInterface.Game.Camera;
import com.GameInterface.DistributedValue;
import com.GameInterface.Log;

class com.GameInterface.ProjectUtils extends com.GameInterface.ProjectUtilsBase
{
    /// Creates and sets a mask for a movieclip,, matching size and position
    /// @param mc:MovieClip - the movieclip to mask
    /// @param parent:MovieClip - the context, where to create the mask
    /// @param nomask:Boolean - Debug, draws the clip, but does not set it as a mask
    /// @return mask:Movieclip - the newly created mask;
    public static function SetMovieClipMask(mc:MovieClip, parent:MovieClip, overrideHeight:Number, overrideWidth:Number, nomask:Boolean ) : MovieClip
    {
        if (parent == null)
        {
            parent = mc._parent;
        }
        if (parent["mask"])
        {
            parent["mask"].removeMovieClip();
        }
        if (nomask == null)
        {
            nomask = false;
        }
        
        var h:Number = ( isNaN( overrideHeight ) ? mc._height : overrideHeight);
        var w:Number = ( isNaN( overrideWidth ) ? mc._width : overrideWidth);

        var mask:MovieClip = parent.createEmptyMovieClip("mask", parent.getNextHighestDepth());
        mask.beginFill(0xFF0000);
        mask.moveTo(0, 0);
        mask.lineTo(w, 0);
        mask.lineTo(w, h);
        mask.lineTo(0, h);
        mask.lineTo(0, 0);
        mask._x = mc._x;
        mask._y = mc._y;
        if (!nomask)
        {
            mc.setMask( mask );
        }
        else
        {
            mask._alpha = 40;
        }
        return mask;
        
    }
	
  private static var s_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );

  /// Shows a text on the screen, behind the gui. It will show onscreen for the duration given.
  /// A handle is returned so you can removed before the time is up via Remove2DText.
  /// 
  public static function Show2DText( text:String, duration:Number, x:Number, y:Number, style:Number, align:String, fadeIn:Number, fadeOut:Number, transition:String ) : Number
  {
	var uid = _root.UID();
	var padding:Number = 60;
    var clipName = "Layer2DText_" + uid;

    Log.Info2("", "Show2DText(clipName=" + clipName + ", x=" + x + ", y=" + y +")");      

    var visibleRect = Stage["visibleRect"];
	var availableWidth = visibleRect.width - (padding * 2);
	
    var letterbox = com.GameInterface.Game.Camera.m_CinematicStripHeight;
	
    var clip:MovieClip = GUIFramework.SFClipLoader.CreateEmptyMovieClip(clipName, _global.Enums.ViewLayer.e_ViewLayerSplashScreenTop, 0 );

    // Scale related to default screensize.
    var scale = s_ResolutionScaleMonitor.GetValue();
    clip._xscale *= scale;
    clip._yscale *= scale;
        
    var language:String = DistributedValue.Create("Language").GetValue();

    clip.createTextField("label", clip.getNextHighestDepth(), 0, 0, 0, 0);

	// Set style and text.
    var font:String = "_StandardFont";
	var size:Number = 11;
	var color:String = "#FFFFFF";
	var bold:Boolean = false;

    /*
     *  The following conditional improves the display of incidental subtitles 
     *  in non english languages:  http://jira.funcom.com/browse/TSW-98448
     * 
     */
    
    var incidentalPadding:Number = 0;
    
    if (language != "en" && style == 2)
    {
        style = 4;
        incidentalPadding = 620;
    }
 
    /*
     * 
     */
        
	switch( style )
	{
		case 1:
			size = 44;
		break;
		case 2:
			font = "_StandardFont";
			bold = true;
			size = 33;
			color = "#DDDDDD";
		break;
		case 3: // cinematic subtitles
			font = "_StandardFont";
			bold = true;
			size = 32;
		break;
        case 4: // ingame subtitles
			y = letterbox == 0 ? 1.0 - (100 * scale / visibleRect.height) : 0.95;
			font = "_StandardFont";
			bold = true;
			size = 22;
		break;
    }
    
	text = "<p align='"+align+"'><font face='"+font+"' size='"+size+"' color='"+color+"' >" + text + "</font></p>";
	
	var shadow:DropShadowFilter = new DropShadowFilter( 52, 70, 0x000000, 0.7, 2, 2, 2, 3, false, false, false );
	
    clip.label.filters = [shadow];
	clip.label.multiline = true;
	clip.label.wordWrap = true;
	clip.label.autoSize = align;

	var clipX:Number = visibleRect.x + padding; 
	var labelWidth:Number = visibleRect.width - (padding * 2)
	
	if (x > 0)
	{
		padding = 10; /// we just need a bit of padding, resetting it
		if (align == "left")
		{
			clipX = visibleRect.width * x;
			labelWidth = visibleRect.width - ((visibleRect.width * x) + padding);
		}
		else if (align == "right")
		{
			labelWidth = (visibleRect.width * x) -padding;
			clipX = padding;
		}
		else if (align == "center")
		{
			var position:Number = (visibleRect.width * x);
			clipX = padding;
			
			if (x > 0.5)
			{
				position = visibleRect.width - (visibleRect.width * x);
			}
			
			labelWidth = ((position - 10 ) * 2) - incidentalPadding;
			clipX = (visibleRect.width * x) - ((labelWidth - 10) * 0.5);
		}
	}	
	
    // don't eat mouse input
    clip.label.selectable = false;
	
    // label stuff
	labelWidth *=  (1 / scale);
	clip.label._width = labelWidth;
	clip._x = clipX
	clip.label.html = true;
    clip.label.htmlText = text;
	
    clip._y = letterbox + (y*(visibleRect.height-letterbox*2)) + visibleRect.y;
    clip.startTime = getTimer();

    // draw above origo, so multiple lines are moved up instead of down into the black cinematic bars
    clip.label._y = -clip.label._height;

    // Start the fade in transition and setup fade out timer.
    duration *= 1000;
    fadeIn *= 1000;
    fadeOut *= 1000;
    if( true /*transition == "Fade"*/ )
    {
     clip._alpha = 0;
      
      clip.onEnterFrame = function()
      {
        var time = getTimer();
        
        if( time > this.startTime + duration )
        {
          // Done.
          this.UnloadClip();
        }
        else if( time < this.startTime + fadeIn )
        {
			// Fade in.
			this._alpha = 100*(time - this.startTime)/fadeIn;
        }
        else if( time > this.startTime + duration - fadeOut )
        {
			// Fade out.
			this._alpha = 100*(fadeOut-(time - (this.startTime + duration - fadeOut)))/fadeOut;
        }
        else
        {
        	this._alpha = 100;
        }
      }
	  /* */
    }
    
    return uid;
  }

  // Remove an earlier started text.
  public static function Remove2DText( handle:Number )
  {
      var clipName = "Layer2DText_" + handle;    
      
      Log.Info2("", "Remove2DText(clipName=" + clipName + ")");
      
      var window = _root[clipName];

      if(window)
      {
          Log.Info2("", "Removing window '" + clipName + "'.");
      
          window.UnloadClip();
      }
      else
      {
          Log.Info2("", "Failed to remove window '" + clipName + "', it could not be found.");          
      }
  }
}
