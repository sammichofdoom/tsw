import com.Utils.Signal;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import flash.geom.Matrix;
import flash.filters.DropShadowFilter;

// This button does not require any resources from any fla file.
//
// This is how the graphics is built up and why:
// Symbol:  MultiStateButton     = The button.
//            m_Red              = The no part of the button. Contains diagonal lines drawn into it.
//            m_Green            = The yes part.



class com.Components.MultiStateButton
{
  // To avoid having to link this class to an empty symbol in a fla file, things are done like this. I think it makes it cleaner when constructing the object.
  // The returned clip will have a SignalSelected that you connect to.
  // parent - The parent movieclip.
  // name   - The name to give this button.
  // width  - The width the button will have.
  // height - The height of the button
  // numButtons - The number of answer options on this button
  // yesText - The yes answer text. Will be centered.
  // noText  - The no answer text. Will be to the right.
  // curve   - Number of pixels used in the anchor point in the curveTo function to curve the lower parts of the button.
  static public function CreateButton( parent:MovieClip, name:String, width:Number, height:Number, numButtons:Number, yesText:String, noText:String, curve:Number ) : MovieClip
  {
		var style:TextFormat = new TextFormat;
		style.font = "_StandardFont";
		style.size = height/2;
		style.color = 0xFFFFFF;
		
		var styleBold:TextFormat = new TextFormat;
		styleBold.font = "_StandardFont";
		styleBold.size = height/2;
		styleBold.color = 0xFFFFFF;
			
    var button:MovieClip = parent.createEmptyMovieClip(name, parent.getNextHighestDepth());

    var shadow:DropShadowFilter = new DropShadowFilter( 1, 35, 0x000000, 0.7, 1, 2, 2, 3, false, false, false );

    var matrix = new Matrix();
    matrix = { matrixType:"box", x:0, y:0, w:width, h:height-2, r:0 };
    
	button.m_Enabled = true;
    button.m_NumButtons = numButtons;
    var background:MovieClip = button.createEmptyMovieClip("m_Background", button.getNextHighestDepth());
    var textClip:MovieClip = button.createEmptyMovieClip("m_Text", button.getNextHighestDepth());
    
    var grey:MovieClip = background.createEmptyMovieClip("m_Grey", background.getNextHighestDepth());
            
    grey.lineStyle(0, 0x000000, 0);
    grey.beginFill( 0x313131, 80 );
    grey.moveTo( 1,0 )
    grey.lineTo( width-1, 0 );
    grey.lineTo( width-1, height-curve );
    grey.curveTo( width-1, height-1, width-curve, height-1 )
    grey.lineTo( curve, height );
    grey.curveTo( 1, height-1, 1, height-curve )
    grey.endFill();
		
	var green:MovieClip = background.createEmptyMovieClip("m_Green", background.getNextHighestDepth());
    // The green background.
    green.lineStyle(0, 0x000000,0);
    green.beginGradientFill("linear", [0x4ACD00, 0x555555], [100,20], [0,255], matrix);
    green.moveTo( 1,0 )
    green.lineTo( width, 0 );
    green.lineTo( width, height-curve );
    green.curveTo( width, height-1, width-curve, height-1 )
    green.lineTo( curve, height );
    green.curveTo( 1, height-1, 1, height-curve )
    green.endFill();

    var red:MovieClip = background.createEmptyMovieClip("m_Red", background.getNextHighestDepth());
    if (numButtons > 1)
    {
			//The red background.
			red.lineStyle(0, 0x000000, 0);
			red.beginGradientFill("linear", [0x555555, 0xFF0000], [20,100], [0,255], matrix);
			red.moveTo( 1,0 )
			red.lineTo( width-1, 0 );
			red.lineTo( width-1, height-curve  );
			red.curveTo( width-1, height-1, width-curve, height-1 )
			red.lineTo( curve, height-1 );
			red.curveTo( 1, height-1, 1, height-curve )
			red.endFill();

			var m_YesLabel:TextField = textClip.createTextField("m_yesLabel", textClip.getNextHighestDepth(), 10, 0, 0, 0);
			m_YesLabel.setNewTextFormat( style);
			m_YesLabel.autoSize = "left";
			m_YesLabel.text = yesText;
			m_YesLabel.setTextFormat( style);
			//m_YesLabel.filters = [ shadow ];
			m_YesLabel._y = (( height - button.m_YesLabel._height )/2) + 5;
			
			var m_NoLabel:TextField = textClip.createTextField("m_noLabel", textClip.getNextHighestDepth(), width*0.94, 0, 0, 0);
			m_NoLabel.setNewTextFormat( style );
			m_NoLabel.autoSize = "right";
			m_NoLabel.text = noText;
			m_NoLabel.setTextFormat( style );
			//m_NoLabel.filters = [ shadow ];
			m_NoLabel._y = (height-red.button._height)/2;

			// The lines on the red.
			var s = height;
			var sw = 10
			for( var i = width+height-sw; i > 0; i-=sw )
            {
                red.lineStyle(2, 0x552222, 20*i/width);
                // Clip the line to the edge, but don't care about the curve.
                var tx = i;
                var ty = 0;
                var bx = i-s;
                var by = height;
                if( i > width )
                {
                    tx = width;
                    ty = i-width;
                }
                if( bx < 0 )
                {
                    bx = 0;
                    by = i;
                }
                red.moveTo(tx,ty);
                red.lineTo(bx,by);
            }

        red._alpha = 0;
    }
    else if(numButtons == 1 )
    {
        var m_YesLabel:TextField = textClip.createTextField("m_yesLabel", textClip.getNextHighestDepth(),width*0.5, 0, 0, 0);
        m_YesLabel.setNewTextFormat( style );
        m_YesLabel.autoSize = "center";
        m_YesLabel.text = yesText;
        m_YesLabel.setTextFormat( style);
        m_YesLabel._y = (( height - button.m_YesLabel._height )/2) + 5;
    }
	button.m_NoEnabled = true;
    button.m_YesEnabled = true;
    button.m_PositiveAnswer = true;
    button.SignalSelected = new Signal;  // -> SlotSignalSelected( button ) 0 = no, 1 = yes.
    
    button.onMouseMove = function()
    {
        var time = 0.2
        
        if (this.m_NumButtons > 1)
        {
            var onYes = this._xmouse > this._width * 0.5;
            if( onYes && this.m_PositiveAnswer && this.m_NoEnabled ) 
            {
                // Go No.
                green.tweenTo( time, {_alpha:0}, Regular.easeIn);
                red.tweenTo( time, {_alpha:100}, Regular.easeIn);
                this.m_PositiveAnswer = false;
            }
            else if( !onYes && !this.m_PositiveAnswer && this.m_YesEnabled )
            {
                // Go Yes.
                red.tweenTo( time, {_alpha:0}, Regular.easeIn);
                green.tweenTo( time, {_alpha:100}, Regular.easeIn);
                this.m_PositiveAnswer = true;
            }
        }
    }

    button.onMouseUp = function()
    {
			if (this.hitTest(_root._xmouse, _root._ymouse))
			{
				var buttonID:Number = -1;
				// Call signal on release.
				if (this.m_PositiveAnswer)
				{
					buttonID = _global.Enums.StandardButtonID.e_ButtonIDYes;
				}
				else
				{
					buttonID = _global.Enums.StandardButtonID.e_ButtonIDNo;
				}
				this.SignalSelected.Emit( buttonID );
			}
    }
	/// Just pass any number != e_ButtonIDNo || e_ButtonIDYes to enable without updating the visuals
	button.Disable = function(focusButton:Number)
	{
        /// we might get multiple calls to this one, retain the colors of the previously set colors
        this.m_Background.m_Green._alpha = (this.m_YesEnabled) ? 100 : 0;
        this.m_Background.m_Red._alpha = (this.m_NoEnabled) ? 100 : 0;
		
		if (focusButton == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
            this.m_YesEnabled = false;
			this.m_Background.m_Green._alpha = 0;
            this.m_PositiveAnswer = false;
		}
		else if (focusButton == _global.Enums.StandardButtonID.e_ButtonIDNo)
		{
            this.m_NoEnabled = false;
            this.m_Background.m_Red._alpha = 0;
            this.m_PositiveAnswer = true;
		}
	}
	
	/// Just pass any number != e_ButtonIDNo || e_ButtonIDYes to disable without updating the visuals
	button.Enable = function(focusButton:Number)
	{
		this.m_Background.m_Green._alpha = 0;		
		this.m_Background.m_Red._alpha = 0;
		
		if (focusButton == _global.Enums.StandardButtonID.e_ButtonIDNo)
		{
            this.m_NoEnabled = true;
			this.m_Background.m_Red._alpha = 100;
		}
		else if (focusButton == _global.Enums.StandardButtonID.e_ButtonIDYes)
		{
            this.m_YesEnabled = true;
			this.m_Background.m_Green._alpha = 100;
            this.m_PositiveAnswer = true;

		}

	}

    return button;
  }

  

}

