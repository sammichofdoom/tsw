import com.Utils.SignalGroup;

class com.Utils.UnitTests
{
    public function UnitTests()
    {
        TestWeakList();
    }
    
    private static var m_WeakList:com.Utils.WeakList;
    private static var m_NormalList:Array;

    public function TestWeakList() : Void
    {
        if ( m_WeakList == undefined )
        {
            m_WeakList = new com.Utils.WeakList();
            m_NormalList = [];
        
            m_WeakList.SignalObjectDied.Connect( null, SlotWeakListObjDied );

            var a = new SignalGroup();
            var b = new SignalGroup();
            var c = new SignalGroup();
            var d = new SignalGroup();

            m_WeakList.PushBack( a, "Object A" );
            m_WeakList.PushBack( b, "Object B-1" );
            m_WeakList.PushBack( b, "Object B-2" );
            m_WeakList.PushBack( b, "Object B-3" );
            m_WeakList.PushBack( c );
            m_WeakList.PushBack( d, 4 );
            m_WeakList.PushBack( b, "Object B-4" );

            m_NormalList.push( a );
            m_NormalList.push( b );
            m_NormalList.push( c );
            m_NormalList.push( d );

            setInterval( StripList, 2000 );
        
            trace( m_WeakList.toString() );
        }
    }
    private static function StripList()
    {
        if ( m_NormalList.length > 0 )
        {
            var index:Number = Math.floor( Math.random() * (m_NormalList.length - 1) );
            trace( "Remove " + index );
            m_NormalList.splice( index, 1 );
        }
    }
    private static function SlotWeakListObjDied( index:Number, userData )
    {
        trace( "Obj died at " + index + " : " + userData );
        trace( m_WeakList.toString() );
    }
    
}