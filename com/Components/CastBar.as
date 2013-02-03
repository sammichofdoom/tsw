/// All logic for the castbar
import com.GameInterface.Command;
import com.GameInterface.Game.Character;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import mx.utils.Delegate;
import gfx.core.UIComponent;

class com.Components.CastBar extends UIComponent
{
	private var m_IntervalId:Number;
	private var m_Increments:Number;
	private var m_TotalFrames:Number; 
	private var m_StopFrame:Number;

	private var m_ProgressBarType:Number;

	private var m_Character:Character;
	
	private var m_CastBar:MovieClip;

	public function CastBar()
	{
		m_Increments = 20; // The smoothness of updates (ms between each redraw)
		m_TotalFrames = _totalframes;
		m_ProgressBarType = _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill;
		
		m_StopFrame = ((m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty) ? m_TotalFrames : 1);

		// remove the looks of the castbar on load
		_visible = false;
		gotoAndStop(m_StopFrame);
			
	}

	function SetCharacter(character:Character)
	{
		if (m_Character != undefined)
		{
			m_Character.SignalCommandStarted.Disconnect( SlotSignalCommandStarted, this);
			m_Character.SignalCommandEnded.Disconnect( SlotSignalCommandEnded, this);
			m_Character.SignalCommandAborted.Disconnect( SlotSignalCommandAborted, this);
		}
		clearInterval( m_IntervalId );
		_visible = false;
		
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
		
		if( _currentframe != 1 )
		{
			clearInterval(m_IntervalId);
		} 

		gotoAndStop( m_StopFrame );
		m_IntervalId = setInterval( Delegate.create( this, ExecuteCallback ), m_Increments );
		_visible = true;
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
			gotoAndStop(scaleNum);
		}
	}

	function SlotSignalCommandEnded() : Void
	{
		clearInterval( m_IntervalId );
		_visible = false;
		stop();
	}

	function SlotSignalCommandAborted() : Void
	{
		clearInterval( m_IntervalId );
		_visible = false;
	}

	function ResizeHandler() : Void
	{
	}
}
