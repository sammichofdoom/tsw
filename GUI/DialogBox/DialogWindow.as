import com.Utils.SignalGroup;
import com.Utils.Signal;
import com.GameInterface.Utils;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.Utils.LDBFormat;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;

// makes a box with curved corners.
MovieClip.prototype.Frame = function(x,y,w,h,ctl,ctr,cbr,cbl )
{
  this.moveTo( x+ctl, y)
  this.lineTo( x+w-ctr, y );
  this.curveTo( x+w, y, x+w, y+ctr )

  this.lineTo( x+w, y+h-cbr );
  this.curveTo( x+w, y+h, x+w-cbr, y+h);

  this.lineTo( x+cbl, y+h );
  this.curveTo( x, y+h, x, y+h-cbl);

  this.lineTo( x, y+ctl );
  this.curveTo( x, y, x+ctl, y);
}

// NOTE:
// Due to the nature of scaleforms scaling of strokes, the strokes used in this file will not scale as scaleform don't scale strokes at all.

function onLoad()
{
  // Connect it.
  com.GameInterface.DialogIF.SignalShowDialog.Connect( SlotShowDialog, this );


  // Example of how to use it:

//   // Invoke it.
//   var dialogIF = new com.GameInterface.DialogIF( "Do you really want to exit\nThe Secret World?", Enums.StandardButtons.e_ButtonsYesNo, "ExitGame" );
// 
//   dialogIF.SignalSelectedAS.Connect( null, SlotSelectedAS, this )
//   dialogIF.Go( 4 );   // <-  4 is userdata.

}

// Example of callback form a dialog.
// function SlotSelectedAS( buttonId, dialogIF:com.GameInterface.DialogIF )
// {
//   trace(buttonId)
//   trace(dialogIF)
// }

function SlotShowDialog( dialogIF:com.GameInterface.DialogIF )
{
    var clipName:String = "Dialog_" + UID();
    
    var window:MovieClip = GUIFramework.SFClipLoader.CreateEmptyMovieClip(clipName, _global.Enums.ViewLayer.e_ViewLayerDialogs, 0);
    
    GUIFramework.SFClipLoader.MakeClipModal( window, true );
    
    var positiveText:String = "";
    var negativeText:String = "";
    var numButtons:Number = 2;
    switch(dialogIF.m_Buttons)
    {
        case _global.Enums.StandardButtons.e_ButtonsOk:
        {
            positiveText = LDBFormat.LDBGetText("GenericGUI","Ok");
            numButtons = 1;
            break;
        }
        case _global.Enums.StandardButtons.e_ButtonsCancel:
        {
            positiveText = LDBFormat.LDBGetText("GenericGUI", "Cancel");
            numButtons = 1;
            break;
        }
        case _global.Enums.StandardButtons.e_ButtonsYesNo:
        {
            positiveText = LDBFormat.LDBGetText("GenericGUI","Yes");
            negativeText = LDBFormat.LDBGetText("GenericGUI","No");
            break;
        }
        case _global.Enums.StandardButtons.e_ButtonsOkCancel:
        {
            positiveText = LDBFormat.LDBGetText("GenericGUI","Ok");
            negativeText = LDBFormat.LDBGetText("GenericGUI","Cancel");
            break;
        }
        case _global.Enums.StandardButtons.e_ButtonsAcceptDecline:
        {
            positiveText = LDBFormat.LDBGetText("GenericGUI","Accept");
            negativeText = LDBFormat.LDBGetText("GenericGUI","Decline");
            break;
        }
        default:
        {
            positiveText = LDBFormat.LDBGetText("GenericGUI","Yes");
            negativeText = LDBFormat.LDBGetText("GenericGUI", "No");
            break;
        }
    }
    var parent = window;
    var name = "m_Button";
    var width = 280;
    var height = 40;
    var curve = 10;

    var frame = window.createEmptyMovieClip( "m_Frame", window.getNextHighestDepth() );

    frame.onPress = function()
    {
		var visibleRect = Stage["visibleRect"];
        // Keep the box inside the screen.
        startDrag( window, false, visibleRect.x, visibleRect.y, visibleRect.x + Stage["visibleRect"].width-window._width, visibleRect.y + Stage["visibleRect"].height-window._height );
    }

    frame.onRelease = frame.onReleaseOutside = function()
    {
        stopDrag();
    }

    var style = new TextFormat;
    style.font = "_StandardFont";
    style.size = 16;
    //style.color = 0xffffff;
    style.align = "center";

    frame.createTextField( "m_Label", frame.getNextHighestDepth(), 0, 0, 0, 0);
    frame.m_Label.setNewTextFormat( style );
    frame.m_Label.multiline = true;
    frame.m_Label._width = width;
    frame.m_Label.autoSize = "center";
    frame.m_Label.wordWrap = true;
    frame.m_Label.html = true
    frame.m_Label.htmlText = "<font color='#ffffff'>" + dialogIF.m_Message + "</font>";
    frame.m_Label.setTextFormat( style );
	
	var maxHeight:Number = Stage["visibleRect"].height - 50;
	var maxWidth:Number = Stage["visibleRect"].width;
	if (frame.m_Label._height > maxHeight)
	{
		width = maxHeight;
		frame.m_Label._width = width;
	}
		
	var minAspect = 1.8;
	while (true)
	{
		if (frame.m_Label._width + 50 < maxWidth && frame.m_Label._width / frame.m_Label._height < minAspect)
		{
			width += 50;
			frame.m_Label._width = width;
		}
		else
		{
			break;
		}
	}
	
	
    
    // Draw the background. (Should be atleast 2 lines high, 60px)
    frame.lineStyle( 0, 0, 0 );
    frame.beginFill( 0x000000, 60 );
    frame.Frame(0, 0, width, height + Math.max(frame.m_Label._height, 60), curve, curve, curve, curve );
    frame.endFill();

    // Draw the outer border. (Should be atleast 2 lines high, 60px).
    frame.lineStyle( 2, 0xffffff, 100 );
    frame.Frame(0, 0, width, height + Math.max(frame.m_Label._height, 60), curve, curve, curve, curve );

    //Make button
    var button = com.Components.MultiStateButton.CreateButton( parent, name, width, height,numButtons, positiveText, negativeText, curve );
    
    //Default autoclose to true
    dialogIF.SetAutocloseOnTeleport(true);
    dialogIF.SetAutocloseOnDeath(true);
    
    // Needed to store the dialogIF here instead of using it directly or else it would not garbage colloect it.
    window.m_DialogIF = dialogIF;
    window.SlotButtonSelected = function( buttonId )
    {
		var character:Character = Character.GetClientCharacter();
		if (character != undefined) { character.AddEffectPackage( "sound_fxpackage_GUI_click_tiny.xml" ); }
        this.m_DialogIF.Respond( buttonId );
        this.m_DialogIF.Close();
    }
    
    window.SlotHideModuleStateUpdated = function( module:GUIModuleIF, isActive:Boolean )
    {
        if (!this.m_DialogIF.m_IgnoreHideModule)
        {
            this._visible = isActive;
        }
    }
    
  	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
  	moduleIF.SignalStatusChanged.Connect( window.SlotHideModuleStateUpdated, window );
    window.SlotHideModuleStateUpdated( moduleIF, moduleIF.IsActive() );


    button._y = window._height-button._height;
    button.SignalSelected.Connect( null, window.SlotButtonSelected, window );

    // Center it. Should be done nicer.
    window._x = Stage["visibleRect"].x+ ((Stage["visibleRect"].width - window._width)/2);
    window._y = Stage["visibleRect"].y +((Stage["visibleRect"].height - window._height) / 2);

    dialogIF.m_Window = window;

    dialogIF.Close = function() : Void 
    {
        this.DisconnectAllSignals();
        GUIFramework.SFClipLoader.RemoveClipNode( this.m_Window );
        this.m_Window.removeMovieClip();
    }
	
	dialogIF.SetText = function(message:String) : Void
	{
		frame.m_Label.htmlText = "<font color='#ffffff'>" + message + "</font>";
		frame.m_Label.setTextFormat( style );
	}
	window.SlotESCPressed = function()
	{
		var character:Character = Character.GetClientCharacter();
		if (character != undefined) { character.AddEffectPackage( "sound_fxpackage_GUI_click_tiny.xml" ); }
		this.m_DialogIF.Respond( -1 );
		this.m_DialogIF.Close();
	}

    var escapeNode:com.GameInterface.EscapeStackNode = new com.GameInterface.EscapeStackNode;
    escapeNode.SignalEscapePressed.Connect( window.SlotESCPressed, window );
    com.GameInterface.EscapeStack.Push( escapeNode );
}

function ResizeHandler( w, h ,x, y )
{
  _x = Stage["visibleRect"].x;
  _y = Stage["visibleRect"].y;
}

function onUnload()
{
}

