import com.GameInterface.Utils;
import com.Utils.SignalGroup;
import gfx.motion.Tween; 
import mx.transitions.easing.*;

var m_SignalGroup:SignalGroup;
var m_Active:Array;
var m_Waiting:Array;
var m_MainLine:Object;

function onLoad()
{
  m_Active = new Array();
  m_Waiting = new Array();

  m_SignalGroup = new SignalGroup;
  com.GameInterface.Chat.SignalShowFIFOMessage.Connect( m_SignalGroup, SlotShowFIFOMessage );
}

function onUnload()
{
  m_SignalGroup.DisconnectAll();
}

// Move all lines up.
function MoveUp()
{
  for( idx in m_Active )
  {
    var clip = m_Active[idx];
    clip.tweenTo( 1, {_alpha:clip._alpha-20,_y:clip._y-clip._height}, Strong.easeOut);
    clip.onTweenComplete = function()
    {
      // Remove line if above screen.
      if( this._y < 0 )
      {
        this.removeMovieClip();
        m_Active.shift();
      }
    }
  }
}


function SlotShowFIFOMessage( text:String, mode:Number )
{
  // Don't add the line if it's already shown or in the waiting list.
  for( entry in m_Waiting )
  {
    if( m_Waiting[entry].i_Fade.i_Txt.text == text )
    {
      return;
    }
  }
  for( idx in m_Active )
  {
    var clip = m_Active[idx];
    if( clip.i_Fade.i_Txt.htmlText == text )
    {
      return;
    }
  }

  // Add the line to the array, if will start fading in as soon as any other lines has moved away.
  var label = attachMovie( "_Text", "label"+UID(), getNextHighestDepth() );
  label.i_Fade.i_Txt.autoSize = "center";
  label.i_Fade.i_Txt.htmlText = text;
  label.i_Fade._alpha = 0;
  label._visible = false;
  label._y = 3*label._height;

  label.FadeOut = function()
  {
    // Fade away and remove.
    this.i_Fade.tweenTo( 3, {_alpha:0}, Back.easeIn );
    this.i_Fade.onTweenComplete = function()
    {
      label.removeMovieClip();
      m_Active.shift();
    }
  }

  m_Waiting.push( label );

  StartLineIfReady();
}


function StartLineIfReady()
{
  if( !m_MainLine )
  {
    StartNextLine();
  }
}

// Checks if there is a next line and starts it's journey.
function StartNextLine()
{
  m_MainLine = undefined;
  // Find first in the array.
  var clip = m_Waiting.shift();
  if( clip )
  {
    m_Active.push( clip );
    m_MainLine = clip;

    // Fade in.
    clip._visible = true;
    clip.i_Fade.tweenTo( 0.5, {_alpha:100}, Back.easeOut );
    clip.i_Fade.onTweenComplete = function()
    {
      // Fade down, scale down, and tell all to move up.
      this.tweenTo( 0.5, {_xscale:90,_yscale:90}, Strong.easeOut );
      this.onTweenComplete = function()
      {
        // Start full fadeout in 10 sec.
        _global.setTimeout( clip, "FadeOut", 10*1000 );

        // Next mainline can now start.
        StartNextLine();
      }

      // Tell all active lines to move 1 up.
      MoveUp();
    }
  }
}