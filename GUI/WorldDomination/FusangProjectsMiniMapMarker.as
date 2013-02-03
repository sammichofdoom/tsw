//Imports
import com.Utils.ID32;
import com.Utils.Format;
import com.Utils.Signal;
import mx.utils.Delegate;

//Class
class GUI.WorldDomination.FusangProjectsMiniMapMarker extends MovieClip
{
    //Constants
    private static var UNCONTROLLED_ICON_RDB_ID:Number = 0000000;
    private static var DRAGON_ICON_RDB_ID:Number = 7969079;
    private static var TEMPLARS_ICON_RDB_ID:Number = 7969077;
    private static var ILLUMINATI_ICON_RDB_ID:Number = 7969078;
    
    private static var MARKER_ICON_SCALE:Number = 25;
    
    //Properties
    public var SignalAllIconsLoaded:Signal;
    
    private var m_UncontrolledIcon:MovieClip;
    private var m_DragonIcon:MovieClip;
    private var m_TemplarsIcon:MovieClip;
    private var m_IlluminatiIcon:MovieClip;
    
    private var m_Faction:Number;
    private var m_MarkersArray:Array;
    private var m_CompleteCount:Number;
    
    //Constructor
    public function FusangProjectsMiniMapMarker()
    {
        SignalAllIconsLoaded = new Signal();
        
        m_CompleteCount = 0;
        
        Init();
    }
    
    //Init
    private function Init():Void
    {
        m_UncontrolledIcon = CreateIcon("m_UncontrolledIcon", UNCONTROLLED_ICON_RDB_ID);        
        m_DragonIcon = CreateIcon("m_DragonIcon", DRAGON_ICON_RDB_ID);
        m_TemplarsIcon = CreateIcon("m_TemplarsIcon", TEMPLARS_ICON_RDB_ID);
        m_IlluminatiIcon = CreateIcon("m_IlluminatiIcon", ILLUMINATI_ICON_RDB_ID);

        m_MarkersArray = new Array(m_UncontrolledIcon, m_DragonIcon, m_TemplarsIcon, m_IlluminatiIcon);        
    }
    
    //Create Icon
    private function CreateIcon(instanceName:String, RDBInstance:Number):MovieClip
    {
        var result:MovieClip = createEmptyMovieClip(instanceName, getNextHighestDepth());
        
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        icon.SetInstance(RDBInstance);

        var loadListener:Object = new Object();
        loadListener.onLoadInit = Delegate.create(this, CenterRegisterIcon);
        
        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        movieClipLoader.addListener(loadListener);
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), result);
        
        return result;
    }

    //Center Register Icon
    private function CenterRegisterIcon(target:MovieClip):Void
    {
        target._xscale = target._yscale = MARKER_ICON_SCALE;
        target._x -= target._width / 2;
        target._y -= target._height / 2;
        target._visible = false;
        
        m_CompleteCount++;
        
        if (m_CompleteCount >= m_MarkersArray.length - 1)
        {
            SignalAllIconsLoaded.Emit(this);            
        }
    }
       
    //Set Faction
    public function set faction(value:Number):Void
    {
       /*
        *   @param  value:Number
        * 
        *           0:  uncontrolled marker
        *           1:  _global.Enums.Factions.e_FactionDragon
        *           2:  _global.Enums.Factions.e_FactionTemplar
        *           3:  _global.Enums.Factions.e_FactionIlluminati
        * 
        */
        
        m_Faction = value;
        
        for (var i:Number = 0; i < m_MarkersArray.length; i++)
        {
            m_MarkersArray[i]._visible = (i == value) ? true : false;
        }
    }
    
    //Get Faction
    public function get faction():Number
    {
        return m_Faction;
    }
}