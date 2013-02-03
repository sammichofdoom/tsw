/// All logic for the castbar
import com.GameInterface.Command;
import com.GameInterface.Utils;
import com.GameInterface.ProjectUtils;
import com.Utils.LDBFormat;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import mx.utils.Delegate;

var m_IntervalId:Number;
var m_Increments:Number;
var m_TotalFrames:Number; 
var m_StopFrame:Number;

var m_ProgressBarType:Number;

var m_DodgeBuffSpellID:Number;

var m_Character:Character;

var m_BuffStartTime:Number;
var m_BuffDuration:Number;

function Init()
{
    m_Increments = 20; // The smoothness of updates (ms between each redraw)
    m_TotalFrames = i_Castbar._totalframes;
    m_ProgressBarType = _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill;
    
    m_StopFrame = ((m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty) ? m_TotalFrames : 1);

    // remove the looks of the castbar on load
    i_Castbar._visible = false;
    i_Castbar.gotoAndStop(m_StopFrame);
    
    m_DodgeBuffSpellID = ProjectUtils.GetUint32TweakValue("DashCooldownSpellID");
    m_SpellNameText.htmlText = LDBFormat.LDBGetText( "MiscGUI", "ActiveDodge" );
}

function onUnload()
{
    clearInterval( m_IntervalId );
}

function SetCharacter(character:Character)
{
	clearInterval( m_IntervalId );
    i_Castbar._visible = false;
    m_SpellNameText._visible = false;
    
    m_Character = character
    if (m_Character != undefined)
    {
        m_Character.SignalInvisibleBuffAdded.Connect( SlotBuffAdded, this);
        m_Character.SignalInvisibleBuffUpdated.Connect( SlotBuffUpdated, this);
        m_Character.SignalBuffRemoved.Connect( SlotBuffRemoved, this);
    }
}

/// Signal sent when a command is started.
/// @param name:String    The name of the command.
/// @param progressBarType:The type of progressbar _global.Enums.CommandProgressbarType.e_CommandProgressbar_Fill or _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty
function SlotBuffAdded(buffId:Number) : Void
{
    if (buffId != m_DodgeBuffSpellID || m_Character == undefined) { return; }
    
    if( i_Castbar._currentframe != 1 )
    {
        clearInterval(m_IntervalId);
    }
    i_Castbar.gotoAndStop( m_StopFrame );
    
    m_BuffStartTime = Utils.GetNormalTime();
    m_BuffDuration = m_Character.m_InvisibleBuffList[m_DodgeBuffSpellID].m_TotalTime/1000 - m_BuffStartTime;
    m_IntervalId = setInterval( Delegate.create( this, ExecuteCallback ), m_Increments );
    
    i_Castbar._visible = true;
    m_SpellNameText._visible = true;
}

function ExecuteCallback(): Void
{
    if (m_Character != undefined)
    {
        var percentCompleteFactor:Number = (Utils.GetNormalTime() - m_BuffStartTime) / m_BuffDuration;
        var scaleNum:Number = Math.min( Math.round(percentCompleteFactor * m_TotalFrames), m_TotalFrames);

        if (m_ProgressBarType == _global.Enums.CommandProgressbarType.e_CommandProgressbar_Empty)
        {
            scaleNum = m_TotalFrames - scaleNum;
        }
        i_Castbar.gotoAndStop(scaleNum);
    }
}

function SlotBuffUpdated(buffId:Number) : Void
{
}

function SlotBuffRemoved(buffId:Number) : Void
{
    if (buffId != m_DodgeBuffSpellID) { return; }
    
	clearInterval( m_IntervalId );
    i_Castbar._visible = false;
    m_SpellNameText._visible = false;
}

function ResizeHandler() : Void
{
}
