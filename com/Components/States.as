import com.GameInterface.Game.Character;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Log;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Utils.LDBFormat;
import flash.geom.Point;
import mx.utils.Delegate;
import gfx.motion.Tween;
import mx.transitions.easing.*;

import gfx.core.UIComponent;

class com.Components.States extends UIComponent
{
	private var m_States:Object;
	private var m_NumStacks:Number; /// number of stacks
	private var m_DisabledAlpha:Number;
	
	private var m_Character:Character;
	private var m_GroupElement:GroupElement;
	private var m_FadeTimer:Number;

	private var m_Hindered:MovieClip;
	private var m_Impaired:MovieClip;
	private var m_Weakened:MovieClip;
	private var m_Afflicted:MovieClip;
	
	private var m_Tooltip:TooltipInterface
	private var m_CurrentTooltipClip:MovieClip;
	/// initialises the script, called from the onLoad method embedded in the corresponding Flash file
	public function States()
	{
		m_CurrentTooltipClip = undefined;
		
		m_NumStacks = 5;
		m_DisabledAlpha = 20;
		m_FadeTimer = undefined;
		m_States = new Object();
		m_States[_global.Enums.CharacterState.e_CharacterState_Afflicted]   = { m_Name : "Afflicted",	m_MovieClip : m_Afflicted, m_TooltipText : LDBFormat.LDBGetText("GenericGUI", "AfflictedStateTooltip")};
		m_States[_global.Enums.CharacterState.e_CharacterState_Hindered]    = { m_Name : "Hindered",   	m_MovieClip : m_Hindered, m_TooltipText : LDBFormat.LDBGetText("GenericGUI", "HinderedStateTooltip") };
		m_States[_global.Enums.CharacterState.e_CharacterState_Impaired]    = { m_Name : "Impaired",    m_MovieClip : m_Impaired, m_TooltipText : LDBFormat.LDBGetText("GenericGUI", "ImpairedStateTooltip") };
		m_States[_global.Enums.CharacterState.e_CharacterState_Weakened]    = { m_Name : "Weakened",    m_MovieClip : m_Weakened, m_TooltipText : LDBFormat.LDBGetText("GenericGUI", "WeakenedStateTooltip") };
		
		m_Afflicted.onPress = function() { };
		m_Hindered.onPress = function() { };
		m_Impaired.onPress = function() { };
		m_Weakened.onPress = function() { };
		
		ClearAllStates();
	}
		
	private function onMouseMove()
	{
		var topMost:Object = Mouse.getTopMostEntity(false);
		var hitSomething:Boolean = false;
		for ( var i in m_States)
		{
			if (topMost == m_States[i].m_MovieClip)
			{
				hitSomething = true;
				if (m_CurrentTooltipClip != m_States[i].m_MovieClip)
				{
					if (m_Tooltip != undefined)
					{
						CloseTooltip();
					}
					ShowTooltip(m_States[i]);
				}
			}
		}
		if (!hitSomething && m_Tooltip != undefined)
		{
			CloseTooltip();
		}
	}
	
	private function ShowTooltip(state:Object)
	{
		var tooltipData:TooltipData = new TooltipData();
				
		tooltipData.m_Descriptions.push(state.m_TooltipText);
		tooltipData.m_Padding = 4;
		tooltipData.m_MaxWidth = _parent._width;
		m_CurrentTooltipClip = state.m_MovieClip;
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip( undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData );
		m_Tooltip.SignalLayout.Connect(SlotTooltipLayout, this);
	}
	
	private function SlotTooltipLayout()
	{
		var posThis:Point = new Point(0, 0);
		this.localToGlobal(posThis);
		var posParent:Point = new Point(0, 0);
		_parent.localToGlobal(posParent);
		
		var pos:Point = new Point(posParent.x, posThis.y - m_Tooltip.GetSize().y - 5);
		m_Tooltip.SetGlobalPosition(pos);
	}
	
	private function CloseTooltip()
	{
		m_CurrentTooltipClip = undefined;
		m_Tooltip.Close();
		m_Tooltip = undefined;
	}
	
	function AddExistingStates()
	{
		for (var i = 0; i <_global.Enums.CharacterState.e_CharacterState_Count; i++)
		{
			if (m_Character.m_StateList[i])
			{
				SlotStateAdded(i, 0, true );
			}
		}
	}

	function SetCharacter(character:Character)
	{    
		SetStatesVisibility( character != undefined );
		ClearAllStates();
		m_Character = character;
		
		if (m_Character != undefined)
		{
			m_Character.SignalStateAdded.Connect(SlotStateAdded, this);
			m_Character.SignalStateUpdated.Connect(SlotStateUpdated, this);
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
	function SlotStateAdded(stateID:Number, buffID:Number, snap:Boolean)
	{
        if (m_Character != undefined && m_Character.IsClientChar())
        {
            switch(stateID)
            {
                case _global.Enums.CharacterState.e_CharacterState_Afflicted:
                    m_Character.AddEffectPackage( "sound_fxpackage_GUI_state_afflicted.xml" );
                    break;
                case _global.Enums.CharacterState.e_CharacterState_Hindered:
                    m_Character.AddEffectPackage( "sound_fxpackage_GUI_state_hindered.xml" );
                    break;
                case _global.Enums.CharacterState.e_CharacterState_Impaired:
                    m_Character.AddEffectPackage( "sound_fxpackage_GUI_state_impaired.xml" );
                    break;
                case _global.Enums.CharacterState.e_CharacterState_Weakened:
                    m_Character.AddEffectPackage( "sound_fxpackage_GUI_state_weakened.xml" );
                    break;
            }
        }
		var state:Object = m_States[stateID];
		if (snap)
		{
			state.m_MovieClip.gotoAndStop("on");
		}
		else
		{
			state.m_MovieClip.gotoAndPlay("start_on");
		}
		HideIfEmpty();
	}
    
    function SlotStateUpdated( stateID:Number, buffID:Number )
    {
		var state:Object = m_States[stateID];
		state.m_MovieClip.gotoAndStop("on");
		HideIfEmpty();
    }

	///Called when a state is removed
	/// @param stateID:Number - the ID of the state that is removed;
	function SlotStateRemoved( stateID:Number, buffID:Number )
	{
		var state:Object = m_States[stateID] ;
	    state.m_MovieClip.gotoAndStop("off");
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

	function ClearAllStates()
	{
		for (var prop in m_States)
		{
			var obj:Object = m_States[prop];
			obj.m_MovieClip.gotoAndStop("off");
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
}
