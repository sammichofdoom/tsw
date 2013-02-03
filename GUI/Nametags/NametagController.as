import com.GameInterface.Nametags;
import com.Utils.ID32;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Components.Nametag;
import com.GameInterface.DistributedValue;

var m_NametagArray:Array;
var m_NametagIncomingQueue:Array;

var m_ClientCharacter:Character;

var m_CurrentOffensiveTarget:ID32;
var m_CurrentDefensiveTarget:ID32;

var m_ResolutionScaleMonitor:DistributedValue;

function onLoad()
{
	Nametags.SignalNametagAdded.Connect(SlotNametagAdded, this);
	Nametags.SignalNametagRemoved.Connect(SlotNametagRemoved, this);
	Nametags.SignalNametagUpdated.Connect(SlotNametagUpdated, this);
	Nametags.SignalNametagAggroUpdated.Connect(SlotNametagAggroUpdated, this);
	Nametags.SignalAllNametagsRemoved.Connect(SlotAllNametagsRemoved, this);
	
		
	m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( Layout, this );
	
	m_NametagArray = new Array();
    m_NametagIncomingQueue = new Array();
	
	CharacterBase.SignalClientCharacterAlive.Connect( SlotClientCharacterAlive, this);
	SlotClientCharacterAlive();
	
	com.GameInterface.Nametags.RefreshNametags();
	
	Layout();
}

function onUnload()
{
}
function onEnterFrame()
{
    if ( m_NametagIncomingQueue.length > 0 )
    {
        CreateNametag( ID32(m_NametagIncomingQueue.pop()) );
    }
	SortNametags();
}

function SortNametags()
{
	//Sort nametags depending on distance/selected
	for ( var i:Number = 1 ; i  < m_NametagArray.length ; i++ )
	{
		var bubbleTag:Nametag = m_NametagArray[i];
		var bubbleIndex:Number = i;
		for (var j:Number = i - 1; j >= 0; j--)
		{
			if ( m_NametagArray[j].Compare( bubbleTag ) > 0 )
			{
				bubbleTag.swapDepths( m_NametagArray[ j ] );
				m_NametagArray[bubbleIndex] = m_NametagArray[j];
				bubbleIndex = j;
				m_NametagArray[j] = bubbleTag;
			}
			else
			{
				break;
			}
		}
	}
}

function Layout()
{
	var visibleRect = Stage["visibleRect"]
	_x = visibleRect.x;
	_y = visibleRect.y;
}

function SlotClientCharacterAlive()
{
	SetClientCharacter( Character.GetClientCharacter());
}

function SlotClientCharacterDead()
{
	if (m_CurrentDefensiveTarget != undefined && !m_CurrentDefensiveTarget.IsNull())
	{
		SetTarget(new ID32(0, 0), m_CurrentDefensiveTarget);
	}
	if (m_CurrentOffensiveTarget != undefined && !m_CurrentOffensiveTarget.IsNull())
	{
		SetTarget(new ID32(0, 0), m_CurrentOffensiveTarget);
	}
}

function SetClientCharacter(clientChar:Character)
{
	if (clientChar != undefined)
	{
		clientChar.SignalCharacterDied.Connect(SlotClientCharacterDead, this);
		clientChar.SignalDefensiveTargetChanged.Connect(SlotDefensiveTargetChanged, this);
		clientChar.SignalOffensiveTargetChanged.Connect(SlotOffensiveTargetChanged, this);
	}
	
	m_ClientCharacter = clientChar;
}

function SlotNametagAdded(characterID:ID32)
{
	if ( SlotNametagRemoved(characterID) )
    {
        CreateNametag(characterID);
    }
    else
    {
        m_NametagIncomingQueue.push( characterID );
    }
}

function SlotNametagRemoved(characterID:ID32) : Boolean
{
    for ( var i:Number = 0 ; i < m_NametagIncomingQueue.length ; ++i )
    {
        if ( m_NametagIncomingQueue[i].Equal( characterID ) )
        {
            m_NametagIncomingQueue.splice( i, 1 );
            return true;
        }
    }
	var nametagIndex:Number = GetNametagIndex(characterID);
	if (nametagIndex != -1)
	{
		m_NametagArray[nametagIndex].removeMovieClip();
		m_NametagArray.splice(nametagIndex, 1);
        return true;
	}
    return false;
}
function SlotNametagUpdated(characterID:ID32)
{
	if (GetNametagIndex(characterID) != -1)
	{
		SlotNametagRemoved(characterID);
		CreateNametag(characterID);
	}
}

function SlotNametagAggroUpdated(characterID:ID32, aggroStatus:Number)
{
	var index:Number = GetNametagIndex(characterID);
	if (m_NametagArray[index] != undefined)
	{
		m_NametagArray[index].UpdateAggro(aggroStatus);
	}
}

function GetNametagIndex(characterID:ID32)
{
	for (var i:Number = 0; i < m_NametagArray.length; i++)
	{
		if (m_NametagArray[i] != undefined && m_NametagArray[i].GetDynelID().Equal(characterID))
		{
			return i;
		}
	}
	return -1;
}

function SlotAllNametagsRemoved()
{
	for (var i:Number = 0; i < m_NametagArray.length;i++)
	{
		m_NametagArray[i].removeMovieClip();
	}
	m_NametagArray = [];
	m_NametagIncomingQueue = [];
}

function CreateNametag(characterID:ID32) : Nametag
{
	var nametag:Nametag = attachMovie("Nametag", "m_Nametag_" +characterID.GetType()+"_"+characterID.GetInstance(), getNextHighestDepth());
	nametag.SetDynelID(characterID);
	nametag.Update();
	
	m_NametagArray.push(nametag);
	SortNametags();
	
	if (m_ClientCharacter != undefined)
	{
		if (characterID.Equal(m_ClientCharacter.GetDefensiveTarget()))
		{
			SlotDefensiveTargetChanged(characterID);
		}
		else if (characterID.Equal(m_ClientCharacter.GetOffensiveTarget()))
		{
			SlotOffensiveTargetChanged(characterID);
		}
	}
	
	return nametag;
}

function SlotDefensiveTargetChanged(targetID:ID32)
{
	if (IsValidTarget(targetID) || targetID == undefined)
	{
		SetTarget(targetID, m_CurrentDefensiveTarget);
		m_CurrentDefensiveTarget = targetID;
	}
}

function SlotOffensiveTargetChanged(targetID:ID32)
{
	if (IsValidTarget(targetID))
	{
		SetTarget(targetID, m_CurrentOffensiveTarget);
		m_CurrentOffensiveTarget = targetID;
	}
}

function IsValidTarget(targetID:ID32)
{
	return targetID.GetType() == _global.Enums.TypeID.e_Type_GC_Character || targetID.GetType() == 0;
}

function SetTarget(newTarget:ID32, oldTarget:ID32)
{
	if ((oldTarget != undefined && newTarget.Equal(oldTarget)) || !DistributedValue.GetDValue("ShowTargetNametags", false))
	{
		return;
	}
	
	if (oldTarget != undefined && !oldTarget.IsNull())
	{
		var index:Number = GetNametagIndex(oldTarget);
		
		if (index != -1)
		{
			m_NametagArray[index].SetAsTarget(false);
		}
	}
	
	var clientCharID:ID32 = Character.GetClientCharID();
	if (clientCharID != undefined && clientCharID.Equal(newTarget) && !DistributedValue.GetDValue("ShowPlayerNametag", false))
	{
		return;
	}
	
	if (newTarget != undefined && !newTarget.IsNull())
	{
		var index:Number = GetNametagIndex(newTarget);
		if (index != -1)
		{
			//Nametag already exists, set it as target
			m_NametagArray[index].SetAsTarget(true);
		}
		else
		{
			//No nametag on target, need to create it before selecting it
			var nameTag:Nametag = CreateNametag(newTarget);
			nameTag.SignalRemoveNametag.Connect(SlotNametagRemoved, this);
			nameTag.SetRemoveOnDeselect(true);
			
			nameTag.SetAsTarget(true);
		}
	}
}

