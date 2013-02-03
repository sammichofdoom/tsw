import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
function onLoad() 
{
	i_SprintBar.Init( _global.Enums.Stat.e_Stamina, _global.Enums.Stat.e_MaxStamina, false);
	CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
	i_SprintBar.SetDynel(Character.GetClientCharacter());
}

function SlotClientCharacterAlive()
{
	i_SprintBar.SetDynel( Character.GetClientCharacter());
}
