import GUI.Interaction.InteractionBubble;
import com.GameInterface.Utils;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.Utils.ID32;
import com.GameInterface.VicinitySystem;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.Character;
import com.GameInterface.ProjectUtils;

var m_InteractionDynels:Object;
var m_ActiveDynelBubble:InteractionBubble;

function onLoad()
{
	m_InteractionDynels = new Object();
	m_ActiveDynel = undefined;

    VicinitySystem.SignalDynelEnterVicinity.Connect( SlotDynelEnterVicinity, this );
    VicinitySystem.SignalDynelLeaveVicinity.Connect( SlotDynelLeaveVicinity, this );
	
	setInterval(UpdateInteractionDynel, 500);
}

function SlotDynelEnterVicinity( dynelID:ID32)
{
	var dynel:Dynel = Dynel.GetDynel(dynelID);
	if (dynel != undefined)
	{		
		var dynel:Dynel = m_InteractionDynels[dynelID];

		if ( dynel == undefined)
		{
			m_InteractionDynels[dynelID] = new Dynel( dynelID );
		}
	}
}

function SlotDynelLeaveVicinity( dynelID:ID32 )
{
	var dynel = m_InteractionDynels[dynelID];
	if (dynel != undefined)
	{
		if (m_ActiveDynelBubble != undefined && m_ActiveDynelBubble.GetDynel().GetID() == dynelID)
		{
			m_ActiveDynelBubble.removeMovieClip();
			m_ActiveDynelBubble = undefined;
		}
		m_InteractionDynels[dynelID] = undefined;
	}
}

function UpdateInteractionDynel()
{
	var closest:Number = 5;
	var closestDynel:Dynel = undefined;
	for (var prop in m_InteractionDynels)
	{
		if (m_InteractionDynels[prop] != undefined)
		{
			var interactionType:Number = ProjectUtils.GetInteractionType(m_InteractionDynels[prop].GetID());
			if (interactionType != _global.Enums.InteractionType.e_InteractionType_None)
			{
				var dist:Number = m_InteractionDynels[prop].GetDistanceToPlayer();
				if (dist < closest && m_InteractionDynels[prop].IsRendered())
				{
					closest = dist;
					closestDynel = m_InteractionDynels[prop];
				}
			}
		}
	}
	if (closestDynel != undefined )
	{
		if(m_ActiveDynelBubble == undefined || closestDynel != m_ActiveDynelBubble.GetDynel())
		{
			SetActiveDynel(closestDynel);
		}
	}
	else
	{
		if (m_ActiveDynelBubble != undefined)
		{
			m_ActiveDynelBubble.removeMovieClip();
			m_ActiveDynelBubble = undefined;
		}
	}
}

function SetActiveDynel(dynel:Dynel)
{
	if (m_ActiveDynelBubble != undefined)
	{
		m_ActiveDynelBubble.removeMovieClip();
	}
	
	var initObject:Object = new Object();
    initObject["m_Dynel"] =  dynel;
	m_ActiveDynelBubble = this.attachMovie("InteractionBubble", "InteractionBubble" + dynelID.GetType() + "_" + dynelID.GetInstance(), this.getNextHighestDepth(), initObject );
	ProjectUtils.SetInteractionDynel(dynel.GetID());
}
