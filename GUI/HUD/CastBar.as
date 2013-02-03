/// All logic for the castbar
import com.GameInterface.Command;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import mx.utils.Delegate;

var m_IntervalId:Number;
var m_Increments:Number;
var m_TotalFrames:Number; 
var m_StopFrame:Number;

var m_ProgressBarType:Number;

var m_Character:Character;

function Init()
{
    m_Increments = 20; // The smoothness of updates (ms between each redraw)
    m_TotalFrames = i_Castbar._totalframes;
    m_ProgressBarType = _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill;
    
    m_StopFrame = ((m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty) ? m_TotalFrames : 1);

    // remove the looks of the castbar on load
    i_Castbar._visible = false;
    i_Castbar.gotoAndStop(m_StopFrame);
		
}

function onUnload()
{
    clearInterval( m_IntervalId );
}

function SetCharacter(character:Character)
{
	if (m_Character != undefined)
    {
        m_Character.SignalCommandStarted.Disconnect( SlotSignalCommandStarted, this);
        m_Character.SignalCommandEnded.Disconnect( SlotSignalCommandEnded, this);
        m_Character.SignalCommandAborted.Disconnect( SlotSignalCommandAborted, this);
    }
    if ( character != undefined && character.GetID().GetType() != _global.Enums.TypeID.e_Type_GC_Character )
    {
        character = undefined;
    }
	clearInterval( m_IntervalId );
    i_Castbar._visible = false;
    m_SpellNameText._visible = false;
    
    m_Character = character
    if (m_Character != undefined)
    {
        m_Character.SignalCommandStarted.Connect( SlotSignalCommandStarted, this);
        m_Character.SignalCommandEnded.Connect( SlotSignalCommandEnded, this);
        m_Character.SignalCommandAborted.Connect( SlotSignalCommandAborted, this);
        m_Character.ConnectToCommandQueue();
    }
}

/// Signal sent when a command is started.
/// @param name:String    The name of the command.
/// @param progressBarType:The type of progressbar _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill or _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty
function SlotSignalCommandStarted( name:String, progressBarType:Number) : Void
{
    m_ProgressBarType = progressBarType;
    
    if( i_Castbar._currentframe != 1 )
    {
        clearInterval(m_IntervalId);
    }

    i_Castbar.gotoAndStop( m_StopFrame );
    m_IntervalId = setInterval( Delegate.create( this, ExecuteCallback ), m_Increments );
    i_Castbar._visible = true;
    
    m_SpellNameText.htmlText = name;
    m_SpellNameText._visible = true;
}

function ExecuteCallback(): Void
{
    if (m_Character != undefined)
    {
        var scaleNum:Number = Math.min( Math.round( m_Character.GetCommandProgress() * m_TotalFrames ), m_TotalFrames);

        if (m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty)
        {
            scaleNum = m_TotalFrames - scaleNum;
        }
        i_Castbar.gotoAndStop(scaleNum);
    }
}

function SlotSignalCommandEnded() : Void
{
	clearInterval( m_IntervalId );
    i_Castbar._visible = false;
    m_SpellNameText._visible = false;
	i_Castbar.stop();
}

function SlotSignalCommandAborted() : Void
{
	clearInterval( m_IntervalId );
    i_Castbar._visible = false;
    m_SpellNameText._visible = false;
}

function ResizeHandler() : Void
{
}
