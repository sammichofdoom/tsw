import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Dynel;
import com.GameInterface.MathLib.Vector3;
import com.Utils.ID32;
import com.Utils.Signal;
import flash.geom.Point;
import com.Utils.WeakList

class com.GameInterface.Game.Character extends CharacterBase
{
    public function Character(charID:ID32)
    {
        super(charID);
    }
    
    //Gets a character object from character id
    public static function GetCharacter(charID:ID32) : Character
    {
        return Dynel.GetDynel(charID)
    }
    
    public static function GetClientCharacter() : Character
    {
        var charID = GetClientCharID();
        return GetCharacter(charID);
    }
	
	public static function ReInitializeClientCharacter()
	{
		var clientChar:Character = GetClientCharacter();
		if (clientChar != undefined)
		{
			clientChar.ReInitialize();
		}
	}
}
