import com.GameInterface.Game.DynelBase;
import com.GameInterface.Game.DynelFactory;
import com.GameInterface.MathLib.Vector3;
import com.Utils.ID32;
import com.Utils.Signal;
import flash.geom.Point;
import com.Utils.WeakList

class com.GameInterface.Game.Dynel extends DynelBase
{
    public function Dynel(dynelID:ID32)
    {
        super(dynelID);
    }
    
    //Gets a dynel object from character id
    public static function GetDynel(dynelID:ID32)
    {
        if (s_DynelList == undefined)
        {
            s_DynelList = new WeakList();
        }
        //Return undefined if it is a 0 ID
        if (dynelID.GetType() == 0 && dynelID.GetInstance() == 0)
        {
            return undefined;
        }
        
        var dynel:Dynel= FindDynel(dynelID);
        if (dynel == undefined)
        {
            dynel = DynelFactory.CreateDynel(dynelID);
            s_DynelList.PushBack(dynel);
        }
        return dynel;
    }
    
    private static function FindDynel(dynelID:ID32):Dynel
    {
        for (var i:Number = 0; i < s_DynelList.GetLength(); i++)
        {
            var dynel:Dynel = s_DynelList.GetObject(i);
            if (dynel != undefined && dynelID.Equal(dynel.GetID()))
            {
                return dynel;
            }
        }
        return undefined;
    }
    
    static var s_DynelList:WeakList;
}
