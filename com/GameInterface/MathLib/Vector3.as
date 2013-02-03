
class com.GameInterface.MathLib.Vector3
{
  public function Vector3( i_x:Number, i_y:Number, i_z:Number )
  {
    x = i_x;
    y = i_y;
    z = i_z;
  }

  public function Len() : Number {
    return Math.sqrt( x*x + y*y + z*z );
  }
  public function Normalize( length:Number ) {
    var scale:Number = length / Len();
    x *= scale;
    y *= scale;
    z *= scale;
  }
  static public function Add( v1:Vector3, v2:Vector3 ) : Vector3 
	{
    return new Vector3( v1.x + v2.x, v1.y + v2.y, v1.z + v2.z );
  }
  static public function Sub( v1:Vector3, v2:Vector3 ) : Vector3 
	{
    return new Vector3( v1.x - v2.x, v1.y - v2.y, v1.z - v2.z );
  }
  static public function Interpolate( v1:Vector3, v2:Vector3, value:Number ) : Vector3 
	{
    return new Vector3( v1.x + (v2.x - v1.x) * value, v1.y + (v2.y - v1.y) * value, v1.z + (v2.z - v1.z) * value );
  }
  public var x:Number;
  public var y:Number;
  public var z:Number;
}
