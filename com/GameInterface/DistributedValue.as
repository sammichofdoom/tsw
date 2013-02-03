import com.Utils.Signal;

class com.GameInterface.DistributedValue extends com.GameInterface.DistributedValueBase
{
    public static function Create( name:String )
    {
        return new DistributedValue( name );
    }
    
    public function DistributedValue( name:String )
    {
        super( name );
    }
}
