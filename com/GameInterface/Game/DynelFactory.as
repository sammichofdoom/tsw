/**
 * ...
 * @author Håvard Homb
 */
import com.Utils.ID32;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.Character;

class com.GameInterface.Game.DynelFactory 
{
    public static function CreateDynel(dynelID:ID32) :Dynel
    {
        switch(dynelID.GetType())
        {
            case _global.Enums.TypeID.e_Type_GC_Character:
                return new Character(dynelID);
            case _global.Enums.TypeID.e_Type_GC_SimpleDynel:
            case _global.Enums.TypeID.e_Type_GC_Destructible:
                return new Dynel(dynelID);
            default:
                return undefined;
        }
    }
}