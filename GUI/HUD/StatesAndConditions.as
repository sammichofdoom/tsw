import com.GameInterface.Game.Character;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Log;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
import gfx.motion.Tween;
import mx.transitions.easing.*;

var m_States:Object;
var m_NumStacks:Number = 5; /// number of stacks
var m_DisabledAlpha:Number = 20;
//var m_BeneficialName:String = "Beneficial" // the name of the banefical movieclip 
//var m_DetrimentalName:String = "Detrimental" // the name of the detrimental movieclip 

var m_Character:Character;
var m_GroupElement:GroupElement;
var m_FadeTimer:Number;

var m_OnStateLabel:String = "on";
var m_OffStateLabel:String = "off";
/// initialises the script, called from the onLoad method embedded in the corresponding Flash file
function Init()
{
	m_FadeTimer = undefined;
    m_States = new Object();
    m_States[_global.Enums.CharacterState.e_CharacterState_Afflicted]   = { m_Name : "Dot",         m_MovieClip : i_Dot,        m_ActiveBuffsArray: []};
    m_States[_global.Enums.CharacterState.e_CharacterState_Hindered]    = { m_Name : "RootSnare",   m_MovieClip : i_RootSnare,  m_ActiveBuffsArray: []};
    m_States[_global.Enums.CharacterState.e_CharacterState_Impaired]    = { m_Name : "Stun",        m_MovieClip : i_Stun,       m_ActiveBuffsArray: []};
    m_States[_global.Enums.CharacterState.e_CharacterState_Weakened]    = { m_Name : "Debuffs",     m_MovieClip : i_Debuffs,    m_ActiveBuffsArray: []};
	
	TooltipUtils.AddTextTooltip(i_Dot, LDBFormat.LDBGetText("GenericGUI", "AfflictedStateTooltip"), 130, TooltipInterface.e_OrientationVertical,  false);
	TooltipUtils.AddTextTooltip(i_RootSnare, LDBFormat.LDBGetText("GenericGUI", "HinderedStateTooltip"), 130, TooltipInterface.e_OrientationVertical, false);
	TooltipUtils.AddTextTooltip(i_Stun, LDBFormat.LDBGetText("GenericGUI", "ImpairedStateTooltip"), 130, TooltipInterface.e_OrientationVertical, false);
	TooltipUtils.AddTextTooltip(i_Debuffs, LDBFormat.LDBGetText("GenericGUI", "WeakenedStateTooltip"), 130, TooltipInterface.e_OrientationVertical, false);
    ClearAllStates();
}

function AddExistingStates()
{
    for (var i = 0; i <_global.Enums.CharacterState.e_CharacterState_Count; i++)
    {
        if (m_Character.m_StateList[i])
        {
            SlotStateAdded(i);
        }
    }
}

function SetCharacter(character:Character)
{    
    SetStatesVisibility( character != undefined );
    ClearAllStates();
    
    if (m_Character != undefined)
    {
        m_Character.SignalStateAdded.Disconnect(SlotStateAdded, this);
        m_Character.SignalStateRemoved.Disconnect(SlotStateRemoved, this);
        
    }
    m_Character = character;
    
    if (character != undefined)
    {
        m_Character.SignalStateAdded.Connect(SlotStateAdded, this);
        m_Character.SignalStateUpdated.Connect(SlotStateAdded, this);
        m_Character.SignalStateRemoved.Connect(SlotStateRemoved, this);
        
        AddExistingStates();
		
		HideIfEmpty();
    }
}

function SetGroupElement(groupElement:GroupElement)
{
    if (m_GroupElement != undefined)
    {
        m_GroupElement.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
        m_GroupElement.SignalCharacterExitedClient.Disconnect(SlotCharacterExited, this);
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
        m_GroupElement.SignalCharacterExitedClient.Connect(SlotCharacterExited, this);
    }
}

function SlotCharacterEntered()
{
    SetCharacter( Character.GetCharacter(m_GroupElement.m_CharacterId) );
}

function SlotCharacterExited()
{
    SetCharacter(undefined);
}

///Called when a state is added
/// @param stateID:Number - the ID of the state that is added;
function SlotStateAdded(stateID:Number, buffID:Number)
{
    var state:Object = m_States[stateID];
    AddBuffToState(stateID, buffID);
    state.m_MovieClip.gotoAndStop(m_OnStateLabel);
	HideIfEmpty();
}

///Called when a state is removed
/// @param stateID:Number - the ID of the state that is removed;
function SlotStateRemoved( stateID:Number, buffID:Number )
{
    var state:Object = m_States[stateID] ;
    RemoveBuffFromState(stateID, buffID);
    if (state.m_ActiveBuffsArray.length <= 0)
    {
        state.m_MovieClip.gotoAndStop(m_OffStateLabel);
    }
	HideIfEmpty();
}

function HideIfEmpty()
{
	var hide:Boolean = true;
	for (var i in m_States)
	{
		if (m_States[i].m_ActiveBuffsArray.length != 0)
		{
			hide = false;
			break;
		}
	}
	if (hide)
	{
		var delay:Number = DistributedValue.GetDValue("HudFadeDelay");
		if (m_FadeTimer == undefined && delay != 0)
		{
			m_FadeTimer = setInterval( Delegate.create( this, OnFadeTimer ), delay*1000 );
		}
	}
	else
	{
		if (m_FadeTimer != undefined)
		{
			clearInterval( m_FadeTimer );
			m_FadeTimer = undefined;
		}
	    for (var i in m_States)
	    {
	        m_States[i].m_MovieClip.tweenTo( 0.5, {_alpha:100}, Back.easeOut );
		}
	}
}

function OnFadeTimer()
{
	clearInterval( m_FadeTimer );
	m_FadeTimer = undefined;
	for (var i in m_States)
	{
		m_States[i].m_MovieClip.tweenTo( 6.0, {_alpha:0}, Back.easeOut );
	}
}

function AddBuffToState(stateID:Number, buffID:Number)
{
    var state:Object = m_States[stateID];
    for (var i:Number = 0; i < state.m_ActiveBuffsArray.length; i++)
    {
        if (state.m_ActiveBuffsArray[i] == buffID)
        {
            return;
        }
    }
    state.m_ActiveBuffsArray.push(buffID);
}

function RemoveBuffFromState(stateID:Number, buffID:Number)
{
    var state:Object = m_States[stateID];
    for (var i:Number = 0; i < state.m_ActiveBuffsArray.length; i++)
    {
        if (state.m_ActiveBuffsArray[i] == buffID)
        {
            state.m_ActiveBuffsArray.splice(i, 1);
            return;
        }
    }  
}

function ClearAllStates()
{
    for (var prop in m_States)
    {
        var obj:Object = m_States[prop];
        obj.m_MovieClip.gotoAndStop(m_OffStateLabel);
    }
	HideIfEmpty();
}

function SetStatesVisibility(visibility:Boolean)
{
    for (var prop in m_States)
    {
        m_States[ prop ].m_MovieClip._visible = visibility
    }
}
