import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Spell;
import com.GameInterface.DialogIF;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.Utils.Signal;
import mx.utils.Delegate;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import com.GameInterface.Utils;
import com.GameInterface.Game.Character;
import com.Utils.ID32;

var m_Slot:Number;
var m_BuffList:Array = new Array();
var m_moviecliploader:MovieClipLoader;
var m_IntervalId:Number;
var m_Direction:Number;
var SizeChanged:Signal; // Signal sent when this movieclip changed size.
var m_UseTimers:Boolean;
var m_ShowCharges:Boolean;
var m_TDB_Cancelbuff:String = "Are you sure you want to cancel ";
var m_TDB_QuestionMark:String = "?";

var m_Tooltip:TooltipInterface;
var m_TooltipBuffID:Number;

/// magics to control removal of buff debuffs
var BUFF:Number = 0;
var DEBUFF:Number = 1;
var ALL:Number = 2;

// controller
var m_ShowBuff:Boolean = true;
var m_ShowDebuff:Boolean = true;

var m_Character:Character;
var m_GroupElement:GroupElement;

function Init()
{
    m_UseTimers = true;
    m_ShowCharges = true;
    m_IntervalId = 0;
    m_Direction = -1; // Tell which direction the icons are layed out.

    m_moviecliploader = new MovieClipLoader();
    SizeChanged = new Signal();

    m_IntervalId = setInterval( Delegate.create(this, TimerCallback), 200, this );
}

function SetCharacter(character:Character)
{
    ClearAllBuffs( );
    if (m_Character != undefined)
    {
        m_Character.SignalBuffAdded.Disconnect(SlotBuffAdded, this);
        m_Character.SignalBuffRemoved.Disconnect(SlotBuffRemoved, this);
        m_Character.SignalBuffUpdated.Disconnect(SlotBuffAdded, this);
        m_Character.SignalCharacterDied.Disconnect(ClearAllBuffs, this);
        m_Character.SignalCharacterTeleported.Disconnect(ClearAllBuffs, this);
    }
    m_Character = character;
    
    if (character != undefined)
    {
        m_Character.SignalBuffAdded.Connect(SlotBuffAdded, this);
        m_Character.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
        m_Character.SignalBuffUpdated.Connect(SlotBuffAdded, this);
        m_Character.SignalCharacterDied.Connect(ClearAllBuffs, this);
        m_Character.SignalCharacterTeleported.Connect(ClearAllBuffs, this);
        
        AddExistingBuffs();
    }
}

function SetGroupElement(groupElement:GroupElement)
{
    if (m_GroupElement != undefined)
    {
        m_GroupElement.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
        m_GroupElement.SignalCharacterExitedClient.Disconnect(ClearAllBuffs, this);
    }
    m_GroupElement = groupElement;
    if (m_GroupElement.m_OnClient)
    {
        SetCharacter(Character.GetCharacter(groupElement.m_CharacterId));
    }
    else
    {
        SetCharacter(undefined);
    }
    if (groupElement != undefined)
    {
        m_GroupElement.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
        m_GroupElement.SignalCharacterExitedClient.Connect(ClearAllBuffs, this);
    }
}

function ClearAllBuffs()
{
    ClearBuffs(ALL);
}

function SlotCharacterEntered()
{
    SetCharacter(Character.GetCharacter(m_GroupElement.m_CharacterId));
}

function AddExistingBuffs()
{
    for(var prop in m_Character.m_BuffList)
    {
        AddBuff(m_Character.m_BuffList[prop]);
    }
}

function onUnload()
{
    CloseTooltip();
    clearInterval( m_IntervalId );
}

function NoTimers()
{
    m_UseTimers = false;
}

function NoCharges()
{
    m_ShowCharges = false;
}

function ShowBuffs( show:Boolean )
{
    m_ShowBuff = show;
    if (!show)
    {
        ClearBuffs(BUFF);
    }
    else
    {
        ShowAllBuffs();
    }
}

function ShowDebuffs(show:Boolean )
{
    m_ShowDebuff = show;
    if (!show)
    {
        ClearBuffs( DEBUFF );
    }
    else
    {
        ShowAllBuffs();
    }
}

function SetDirectionDown()
{
    m_Direction = 1;
    Layout();
}

/// clears all buffs from the visuals
/// @param type:Number - BUFF, DEBUFF or ALL depending on what you want to remove
/// @return Void
function ClearBuffs(type:Number) : Void
{
    if (m_BuffList.length != NaN)
    {
        for(var i:Number = m_BuffList.length-1; i >= 0; i--)
        {
            /// remove all
            if (type === ALL)
            {
                SlotBuffRemoved( m_BuffList[i].m_BuffId )
            }
            /// remove debuffs
            else if ((type === DEBUFF) && m_BuffList[i].m_Hostile)
            {
                SlotBuffRemoved( m_BuffList[i].m_BuffId )
            }
            /// remove buffs
            else if ((type === BUFF) && !m_BuffList[i].m_Hostile)
            {
                SlotBuffRemoved( m_BuffList[i].m_BuffId )
            }
        }
    }
}

/// @todo implement method to request all buffs on a dynel
/// enables all buffs if these have not been showed
/// @return Void
function ShowAllBuffs() : Void
{
    AddExistingBuffs();
}


function AddBuff(buffData:BuffData)
{
    if (buffData == undefined)
    {
        return;
    }
    /// disregard states as they are being dealth with on their own
    if (Spell.IsTokenState(buffData.m_BuffId))
    {
        return;
    }
    /// disregard buffs if set to not show
    else if (buffData.m_Hostile && !m_ShowDebuff)
    {
        return;
    }
    // disregard debuffs if set to not show
    else if (!buffData.m_Hostile && !m_ShowBuff)
    {
        return;
    }

    // Create buff if it does not exist.
    buffClip = this[buffData.m_BuffId];
    if( !buffClip )
    {
        buffClip = attachMovie( "BuffBorder", ""+buffData.m_BuffId, getNextHighestDepth() );

        buffClip.GetHeight = function() : Number
        {
            // Must use the border and txt to not get wrong size when having buffcharge that animates.
            return this.i_Border._height + (this.txt ? this.txt._height : 0 );
        }

        buffClip.m_BuffId = buffData.m_BuffId;
        buffClip.m_BuffName = buffData.m_Name;
        buffClip.m_Hostile = buffData.m_Hostile;
        buffClip.m_CasterId = buffData.m_CasterId;
        
        m_BuffList.push( buffClip );
    }

    // Load and rescale icon.
    var xscale = buffClip.i_Icon._width;
    var yscale = buffClip.i_Icon._height;
    m_moviecliploader.loadClip( Utils.CreateResourceString(buffData.m_Icon), buffClip.i_Icon )
    /// do not scale an icon if it has been scaled before
    if ( !buffClip["isScaled"] )
    {
        buffClip.i_Icon._xscale = xscale;
        buffClip.i_Icon._yscale = yscale;
        buffClip["isScaled"] = true;
    }
    com.Utils.Colors.ApplyColor(buffClip.i_Border.i_Background, com.Utils.Colors.GetColor( buffData.m_ColorLine ) )
    var clientCharacterID:ID32 = Character.GetClientCharID();
    if (m_Character != undefined && m_Character.GetID().Equal(clientCharacterID))
    {
        buffClip.onMousePress = function(mouseBtnId:Number)
        {
            if (mouseBtnId == 2 && !this.m_Hostile)
            {
                var dialogIF = new com.GameInterface.DialogIF( m_TDB_Cancelbuff + this.m_BuffName + m_TDB_QuestionMark, Enums.StandardButtons.e_ButtonsYesNo, "CancelBuff" );
                dialogIF.SignalSelectedAS.Connect( SlotCancelBuff, this );
                dialogIF.Go( this.m_BuffId ); // <-  the buff is userdata.
                CloseTooltip();
            }
            else if(mouseBtnId == 1 && this.m_Tooltip != undefined && Key.isDown( Key.SHIFT ))
            {
                m_Tooltip.MakeFloating();
            }
        }
    }
    
    buffClip.onRollOver = function()
    {
        var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( this.m_BuffId );
        var delay:Number = DistributedValue.GetDValue( "HoverInfoShowDelayShortcutBar" );
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip( m_Ability, TooltipInterface.e_OrientationVertical, delay, tooltipData );
        m_TooltipBuffID = this.m_BuffId;
    }
    
    buffClip.onRollOut = function()
    {
        CloseTooltip();
    }

    if( m_ShowCharges && buffData.m_Count > 0)
    {
        // Set it as BuffCharges.
       // First check if we have the buffcharge movieclip and create it if not.
        if( !buffClip.m_BuffCharge )
        {
            buffClip.attachMovie( "_BuffCharge", "m_BuffCharge", buffClip.getNextHighestDepth() );
        }

        buffClip.m_BuffCharge.SetMax( buffData.m_MaxCounters );
        buffClip.m_BuffCharge.SetCharge( buffData.m_Count );
        buffClip.m_BuffCharge.SetColor( 0x0000ff ); // TODO: Change. Maybe add color if charge == max

        // Place it in the lower left corner of the buff.
        buffClip.m_BuffCharge._x = buffClip.i_Border._width/2;
        buffClip.m_BuffCharge._y = buffClip.i_Border._height/2;
    }

    // Make the icon white and 100 
    buffClip.i_Icon._alpha = 100;

    // Buff times arrives as millisecond.
    buffClip.m_EndTime = getTimer() + buffData.m_RemainingTime;

    // Only show timer if we got any time.
    buffClip.txt._visible = (buffData.m_RemainingTime>0 && buffClip.txt && m_UseTimers);

    Layout();
}

function CloseTooltip()
{
    if (m_Tooltip != undefined)
    {
        if ( !m_Tooltip.IsFloating() )
        {
            m_Tooltip.Close();
        }
        m_TooltipBuffID = 0;
        m_Tooltip = undefined;
    }
}

function SlotBuffAdded(buffId:Number)
{
    AddBuff(m_Character.m_BuffList[buffId]);
}

// Deactivates a buff.
/// @param buffId:Number - the ID of the buff to deactivate;
function SlotBuffRemoved( buffId:Number )
{
    for(var i:Number = 0; i < m_BuffList.length; i++)
    {
        if( m_BuffList[i].m_BuffId == buffId)
        {
            var buff = m_BuffList[i];
            buff.removeMovieClip();
            if (m_TooltipBuffID == buffId)
            {
                CloseTooltip();
            }
            m_BuffList.splice(i,1);
            Layout();
            break;
        }
    }
}

function SlotCancelBuff( buttonId:Number, buffId:Number)
{
    if (buttonId == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        Spell.CancelBuff(buffId, GetBuffClip(buffId).m_CasterId);
    }
}

function GetBuffClip(buffId):MovieClip
{
    for( var i:Number = 0; i < m_BuffList.length; i++)
    {
        if (m_BuffList[i].m_BuffId == buffId)
        {
            return m_BuffList[i];
        }
    }
    return undefined;
}

// Decrease timer until null.
function TimerCallback()
{
    var time = getTimer();
    var len = m_BuffList.length;
  //  trace("Buff:TimerCallback time "+time)
    for( var i:Number = 0; i < len; i++)
    {
        var buff = m_BuffList[i];
        var timeLeft = buff.m_EndTime - getTimer();

        // Add blinking when 4 sec left.
        if( timeLeft <= 4000 && timeLeft > 0 )
        {
            // Inverted bounce.
            var x = ((timeLeft % 1000) - 500)/1000;
            var alpha = (30+(x*x*4)*70);
            buff.i_Border._alpha = alpha;
        }

        if( buff.txt && timeLeft > 0 )
        {
            // Normaly show "min:sec"
            if( timeLeft > 60*60*1000 )
            {
                // Show "hour:min" if more than 1 hour left.
                timeLeft = timeLeft/60;
            }
            //TODO: Make a std. function.
            var tmpms:Number = timeLeft%1000;
            var tmps:Number = timeLeft%60000;
            var s:Number =  ((timeLeft%60000) - tmpms)/1000;
            var m:Number = ((timeLeft-tmps)/60000);

            var str_s:String = (s <10) ? "0"+s : s;
            var str_m:String = (m < 10) ? "0"+ m : m;
            var str:String = str_m+":"+str_s;
            buff.txt.text = str;
        }
    }
}

// Repositions the buffs after a buff is removed somewhere in the stack.
function Layout()
{
    var maxPerLine = 6;

    for( var i:Number = 0; i < m_BuffList.length; i++)
    {
        var line = Math.floor(i / maxPerLine);

        var buffmc:MovieClip = m_BuffList[i];
        var xAddition:Number = 10;
        buffmc._x = ((buffmc.i_Border._width + 10) * (i - (line * maxPerLine))) + xAddition; // Must use the border and txt to not get wrong size when having buffcharge that animates.
        line += (m_Direction==-1 ? 1 : 0); // Make all coords negative to get static bottom alignment on parent.
        buffmc._y = m_Direction * line * (buffmc.GetHeight() + 18)
    }
    SizeChanged.Emit();
}
