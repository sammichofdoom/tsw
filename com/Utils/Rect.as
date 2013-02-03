
intrinsic class com.Utils.Rect
{
    public function Rect( l:Number, t:Number, r:Number, b:Number );

    public function IsValid() : Boolean;



    public function Invalidate() : Void;
    public function DoIntersectPoint( point:com.Utils.Point ) : Boolean;
    public function DoIntersectRect( rect:com.Utils.Rect ) : Boolean;
    public function Width() : Number;
    public function Height() : Number;
    public function Size() : com.Utils.Point;
    public function LeftTop() : com.Utils.Point;
    public function RightBottom() : com.Utils.Point;
    public function Bounds() : com.Utils.Rect;
    public function Floor() : com.Utils.Rect;
    public function Ceil() : com.Utils.Rect;
    public function SetSize( size:com.Utils.Point ) : com.Utils.Rect;
    public function SetPosition( pos:com.Utils.Point ) : com.Utils.Rect;
    public function SetSizeAndPos( pos:com.Utils.Point, size:com.Utils.Point ) : com.Utils.Rect;
    public function Resize( left:Number, top:Number, right:Number, bottom:Number ) : com.Utils.Rect;
    public function AddBorders( borders:com.Utils.Rect ) : com.Utils.Rect;
    public function RemoveBorders( borders:com.Utils.Rect ) : com.Utils.Rect;
    public function Scale( xScale:Number, yScale:Number ) : com.Utils.Rect;
    public function ScaleCentered( xScale:Number, yScale:Number ) : com.Utils.Rect;
  
    public function TranslateTL( rect:com.Utils.Rect ) : com.Utils.Rect;
    public function TranslateTR( rect:com.Utils.Rect ) : com.Utils.Rect;
    public function TranslateBL( rect:com.Utils.Rect ) : com.Utils.Rect;
    public function TranslateBR( rect:com.Utils.Rect ) : com.Utils.Rect;

    public function TranslateBorderLeft( cornerTop:com.Utils.Rect, cornerBottom:com.Utils.Rect ) : com.Utils.Rect;
    public function TranslateBorderRight( cornerTop:com.Utils.Rect, cornerBottom:com.Utils.Rect ) : com.Utils.Rect;
    public function TranslateBorderTop( cornerLeft:com.Utils.Rect, cornerRight:com.Utils.Rect ) : com.Utils.Rect;
    public function TranslateBorderBottom( cornerLeft:com.Utils.Rect, cornerRight:com.Utils.Rect ) : com.Utils.Rect;
    public function TranslateCenter( child:com.Utils.Rect ) : com.Utils.Rect;

    public function GetArea() : Number;


    public function AddPoint( point:com.Utils.Point ) : Void;
    public function SubPoint( point:com.Utils.Point ) : Void;
    public function Clip( other:com.Utils.Rect ) : Void;
    public function Merge( other:com.Utils.Rect ) : Void;
    public function Equal( other:com.Utils.Rect ) : Boolean;
    public function NotEqual( other:com.Utils.Rect ) : Boolean;


    
    public function get left() : Number;
    public function set left( v:Number ) : Void;

    public function get top() : Number;
    public function set top( v:Number ) : Void;
    
    public function get right() : Number;
    public function set right( v:Number ) : Void;
    
    public function get bottom() : Number;
    public function set bottom( v:Number ) : Void;
}