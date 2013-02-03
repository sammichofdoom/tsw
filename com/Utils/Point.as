intrinsic class com.Utils.Point
{
    public function Point( x:Number, y:Number );


    public function Scale( scale : Number ) : Point;
    public function Normalize() : Point;
    public function GetLengthSqr() : Number;
    public function GetLength() : Number;

    public function Floor() : Point;
    public function GetFloored() : Point;
    
    public function get x() : Number;
    public function set x( v:Number) : Void;

    public function get y() : Number;
    public function set y( v:Number) : Void;
}