import com.Utils.Signal;
import com.Components.StatBar;
import com.Components.Resources;
import com.GameInterface.Game.TeamInterface;
import com.Utils.ID32;

var m_Name:MovieClip;
var m_HealthBar:MovieClip;
var m_Resources:MovieClip;
var m_States:MovieClip;
var m_LockIcon:MovieClip;

var SizeChanged:Signal;

var m_ShowName:Boolean = false;

var m_Dynel:Dynel;

function Initialize()
{
	SizeChanged = new Signal();
		
	var y:Number = 0;
	
	if (m_ShowName)
	{
		m_Name = attachMovie("NameBox", "name", getNextHighestDepth());
		m_Name.Init();
		m_Name._y = y;
		m_Name._x = -5
		y += m_Name._height + 12;
	}

	           
	m_HealthBar = attachMovie("HealthBar2", "health", getNextHighestDepth()); 
    m_HealthBar.SetTextType( com.Components.HealthBar.STATTEXT_NUMBER );
    m_HealthBar.SetBarScale(100, 85, 70);
    m_HealthBar.Show();
	m_HealthBar._x = 0;
	m_HealthBar._y = y;
	//m_HealthBar.Init(_global.Enums.Stat.e_Health, _global.Enums.Stat.e_Life, true);
	//m_HealthBar.SetFadeWhenInactive(false);
	
	y += 18;
	
	m_Resources = attachMovie("Resources", "resources", getNextHighestDepth());
	m_Resources.SetHideWhenEmpty(false);
	m_Resources._y = y;
	
	y += 30;
	
	m_States = attachMovie("States", "states", getNextHighestDepth());
	m_States._y = y;
	
	m_Buffs = attachMovie("Buffs", "buffs", getNextHighestDepth());
	m_Buffs.SetMaxPerLine(4);
	m_Buffs._y = 0;
    m_Buffs._xscale = 80;
    m_Buffs._yscale = 80;
    m_Buffs.SetWidth(_width * (100/80));
	m_Buffs.SizeChanged.Connect(SlotBuffSizeChanged, this);
}

function SetDynel(dynel:Dynel)
{
	if (m_Dynel != undefined)
	{
		m_Dynel.SignalLockedToTarget.Disconnect(SlotLockedToTarget, this);
	}
	
	m_Dynel = dynel;
	
	if (m_Name != undefined)
	{
		m_Name.SetDynel(m_Dynel);
	}
 
	m_HealthBar.SetDynel(m_Dynel);
	
	var character:Character = undefined;

    if ( m_Dynel != undefined && m_Dynel.GetID().GetType() == _global.Enums.TypeID.e_Type_GC_Character )
    {
        character = Character.GetCharacter(m_Dynel.GetID());
    }
	m_Resources.SetCharacter(character);
	m_States.SetCharacter(character);
	m_Buffs.SetCharacter(character);
	
	if (m_Dynel != undefined)
	{
		m_Dynel.SignalLockedToTarget.Connect(SlotLockedToTarget, this);
		SlotLockedToTarget(m_Dynel.GetLockedTo());
	}
	else
	{
		RemoveLockIcon();
	}
}

function RemoveLockIcon()
{
	if (m_LockIcon != undefined)
	{
		m_Name._x = m_LockIcon._x;
		m_LockIcon.removeMovieClip();
		m_LockIcon = undefined;
	}
}

function SlotLockedToTarget(targetID:ID32)
{
	var clientCharacter:Character = Character.GetClientCharacter();
	if (targetID == undefined || targetID.IsNull() || targetID.Equal(clientCharacter.GetID()) || targetID.Equal(TeamInterface.GetClientTeamID()) || targetID.Equal(TeamInterface.GetClientRaidID()))
	{
		RemoveLockIcon();		
	}
	else
	{
		RemoveLockIcon();
		m_LockIcon = attachMovie("LockIcon", "m_LockIcon", getNextHighestDepth())
		m_LockIcon._x = m_Name._x
		m_LockIcon._y = m_Name._y
		
		m_Name._x = m_LockIcon._x + m_LockIcon._width + 5;
	}
}

function ShowName(show:Boolean)
{
	m_ShowName = show;
}

function SlotBuffSizeChanged()
{
	SizeChanged.Emit();
}
