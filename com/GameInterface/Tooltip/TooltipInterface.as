import com.Utils.Signal;

class com.GameInterface.Tooltip.TooltipInterface
{
    static public var e_OrientationHorizontal  = 0;
    static public var e_OrientationVertical = 1;
    
    private var e_DirectionLeft  = 0;
    private var e_DirectionRight = 1;
    private var e_DirectionUp    = 2;
    private var e_DirectionDown  = 3;
    private var e_DirectionNone  = 4;
	public var SignalLayout:Signal;

    private function TooltipInterface( orientation:Number, tooltipDataArray:Array )
    {
        m_TooltipDataArray = tooltipDataArray;

        m_Orientation = orientation;
            
        m_TargetPosition = new flash.geom.Point(0,0);
        m_TargetSize = new flash.geom.Point(0,0);
        
        m_PanelSpacing = 10;
        m_PreferredArrowEdgeSpacing = 5;
        m_ArrowOverlap = 1;

        m_TooltipArray = [];
		
		SignalLayout = new Signal;
    }

    // Members that needs to be overloaded by a project specific class to implement the visual look:
    public function Close() {}
    public function MakeFloating() {}

    public function IsDoneLoading() : Boolean { return false; }
    public function GetPanelCount() : Number { return 0; }    

    public function GetSize() : flash.geom.Point { return new flash.geom.Point( 0, 0 ); }
    public function GetArrowSize() : flash.geom.Point { return new flash.geom.Point( 0, 0 ); }
    public function GetPanelSize( index:Number ) : flash.geom.Point { return new flash.geom.Point( 0, 0 ); }

    public function SetGlobalPosition( pos:flash.geom.Point ) : Void {}
    private function SetPanelPosition( index:Number, pos:flash.geom.Point ) : Void {}
    
    private function SetArrow( pos:flash.geom.Point, orientation:Number ) : Void {}


    // Project independed members for layout and positioning:
    public function IsFloating() : Boolean { return m_IsFloating; }
    
    public function SetPosition( targetPos:flash.geom.Point, targetSize:flash.geom.Point ) : Void
    {
        m_TargetPosition = targetPos;
        m_TargetSize     = targetSize;
        UpdatePosition();
    }

    private function SwapPoint( point:flash.geom.Point ) : flash.geom.Point
    {
        return new flash.geom.Point( point.y, point.x );
    }
    private function UpdatePosition() : Void
    {
        if ( IsDoneLoading() )
        {
            var disableArrow:Boolean = false;
            var totalSize:flash.geom.Point      = GetSize();
            var arrowSize:flash.geom.Point      = GetArrowSize();
            var screenSize:flash.geom.Point     = new flash.geom.Point( Stage.width, Stage.height );
            var targetPosition:flash.geom.Point = m_TargetPosition;
            var targetSize:flash.geom.Point     = new flash.geom.Point( m_TargetSize.x * 0.5, m_TargetSize.y * 0.5 );
            var position:flash.geom.Point       = new flash.geom.Point( targetPosition.x, targetPosition.y );

            // The logic is the same for horizontal and vertical orientation
            // except that the rules for x and y are swapped.
            // So we always calculate as if horizontal and just swap all
            // sizes/coordinates before and after if it is actually vertical.
            if ( m_Orientation == e_OrientationVertical )
            {
                totalSize      = SwapPoint( totalSize );
                arrowSize      = SwapPoint( arrowSize );
                screenSize     = SwapPoint( screenSize );
                targetPosition = SwapPoint( targetPosition );
                targetSize     = SwapPoint( targetSize );
                position       = SwapPoint( position );
            }
            
			var screenMax:Number = screenSize.y;
			
            var willFitLeft:Boolean  = position.x - totalSize.x - targetSize.x  >= 0;
            var willFitRight:Boolean = position.x + totalSize.x + targetSize.x < screenSize.x;
            var reverseOrder:Boolean = false;

            if ( willFitRight ) 
			{
                position.x += targetSize.x;
				position.x += arrowSize.y;
            } 
			else if ( willFitLeft ) 
			{
                position.x -= totalSize.x + targetSize.x;
				position.x -= arrowSize.y;
                reverseOrder = true;
            } 
			else 
			{
                position.x = screenSize.x * 0.5 - totalSize.x * 0.5;
                position.y = targetPosition.y + targetSize.y * 0.5;
                disableArrow = true;
            }
			
            if ( position.y < 0 ) 
			{
                position.y = 0;
            } 
			else if ( position.y + totalSize.y > screenMax ) 
			{
                position.y = screenMax - totalSize.y;
            }

            var arrowEdgeSpacing:Number = targetPosition.y - position.y - arrowSize.y * 0.5;

            if ( m_Orientation == e_OrientationVertical )
            {
                position   = SwapPoint( position );
            }

            SetGlobalPosition( position );
            Layout( arrowEdgeSpacing, reverseOrder, disableArrow );
        }
    }
    
    public function Layout( arrowEdgeSpacing:Number, reverseOrder:Boolean, disableArrow:Boolean )
    {
        var totalSize:flash.geom.Point = GetSize();
        var arrowSize:flash.geom.Point = GetArrowSize();
        var first:Boolean = true;
        var curPos:flash.geom.Point = new flash.geom.Point( 0, 0 );
        var arrowPos:flash.geom.Point = new flash.geom.Point( 0, 0 );
        
        if ( m_Orientation == e_OrientationVertical )
        {
            totalSize = SwapPoint( totalSize );
            arrowSize = SwapPoint( arrowSize );
        }
        if ( !reverseOrder )
        {
            curPos.x += arrowSize.x - m_ArrowOverlap;
        }
        var panelCount:Number = GetPanelCount();
        for ( var i:Number = 0 ; i < panelCount ; ++i )
        {
            var panelIndex = (reverseOrder) ? (panelCount - i - 1) : i;

            if ( !first )
            {
                curPos.x += m_PanelSpacing;
            }
            
            if ( m_Orientation == e_OrientationHorizontal )
            {
                SetPanelPosition( panelIndex, curPos );		
                curPos.x += GetPanelSize( panelIndex ).x;
            }
            else
            {
                SetPanelPosition( panelIndex, SwapPoint( curPos ) );		
                curPos.x += GetPanelSize( panelIndex ).y;
            }
            first = false;
        }
        if ( reverseOrder )
        {
            arrowPos.x = curPos.x - m_ArrowOverlap + (arrowSize.y);
        }
		else
		{
			arrowPos.x = m_ArrowOverlap + (arrowSize.y);
		}
        arrowPos.y = arrowEdgeSpacing;
        if ( m_Orientation == e_OrientationVertical )
        {
            arrowPos = SwapPoint( arrowPos );
        }

        var arrowDirection:Number = e_DirectionNone;
        if ( !m_IsFloating && !disableArrow )
        {
            if ( m_Orientation == e_OrientationHorizontal )
            {
                arrowDirection = (reverseOrder) ? e_DirectionRight : e_DirectionLeft;
            }
            else
            {
                arrowDirection = (reverseOrder) ? e_DirectionDown : e_DirectionUp;
            }
        }
        SetArrow( arrowPos, arrowDirection );
		
		SignalLayout.Emit();
    }
        
    private var m_TooltipDataArray:Array;
    private var m_Orientation:Number;
    private var m_TargetPosition:flash.geom.Point;
    private var m_TargetSize:flash.geom.Point;
    private var m_PanelSpacing:Number;
    private var m_PreferredArrowEdgeSpacing:Number;
    private var m_ArrowOverlap:Number;    
    private var m_IsFloating:Boolean;
    private var m_TooltipArray:Array;    
}
