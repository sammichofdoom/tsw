import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.Resource
{
    public static function GetResourceAmount( resourceType:Number, targetID:ID32 ) : Number

    /// @param resourceType:Number    The resource type (1-9).
    /// @param resourceAmount:Number  The new resource amount.
    /// @param targetID:ID32          The target, if the resource is built by the local player on a target.   
    public static var SignalResourceChanged:Signal;
}
