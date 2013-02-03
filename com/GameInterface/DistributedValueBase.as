import com.Utils.Signal;
intrinsic class com.GameInterface.DistributedValueBase
{
    public function DistributedValueBase( name:String );


    public function SetName( name:String );
    public function GetName() : String;

    public static function AddVariable( name:String, value, isPeristent:Boolean ) : Void;
    public static function DeleteVariable( name:String ) : Boolean;
    public static function DoesVariableExist( name:String ) : Boolean;

    public static function GetMinMaxValues( variableName:String ) : Array;

    public static function SetDValue( name:String, value ) : Void;
    public static function GetDValue( name:String );

    public function GetValue();
    public function SetValue( value ) : Void;

    public static function SetDefaultDValue( variableName:String, value ) : Void;
    public static function GetDefaultDValue( variableName:String );

    public static function GetVariableCategory( name:String ) : Number;

    public function Observe( variableName:String ) : Void;
    public function Forget( variableName:String ) : Void;

    public function ObserveAll() : Void;
    public function ForgetAll() : Void;
    

    public var SignalChanged:Signal;    
}
