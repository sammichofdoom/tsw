//Imports
import com.GameInterface.PvPMinigame.PvPMinigame;
import GUI.WorldDomination.FusangProjectsMiniMapMarker;

//Class
class GUI.WorldDomination.FusangProjectsMiniMap extends MovieClip
{
    //Constants
    private static var SOUTH_DISTRICT:String = "FCAnimaFacility1";
    private static var EAST_DISTRICT:String = "FCAnimaFacility2";
    private static var WEST_DISTRICT:String = "FCAnimaFacility3";
    private static var CENTER_DISTRICT:String = "FCAnimaFacility4";
    
    //Properties
    private var m_SouthMarker:MovieClip;
    private var m_EastMarker:MovieClip;
    private var m_WestMarker:MovieClip;
    private var m_CenterMarker:MovieClip;
    
    private var m_DimensionID:Number;
    
    //Constructor
    public function FusangProjectsMiniMap()
    {
        m_DimensionID = PvPMinigame.GetCurrentDimensionId();
        
        Init();
    }
    
    //Init
    private function Init():Void
    {
        m_SouthMarker = CreateMarker("m_SouthMarker", 134, 205);
        m_EastMarker = CreateMarker("m_EastMarker", 189, 106);
        m_WestMarker = CreateMarker("m_WestMarker", 78, 106);
        m_CenterMarker = CreateMarker("m_CenterMarker", 134, 140);
        
        PvPMinigame.SignalWorldStatChanged.Connect(SlotUpdateWorldStats, this);
    }
    
    //Create Marker
    private function CreateMarker(instanceName:String, x:Number, y:Number):MovieClip
    {
        var result:MovieClip = attachMovie("FusangProjectsMiniMapMarker", instanceName, getNextHighestDepth());
        result._x = x;
        result._y = y;
        result.SignalAllIconsLoaded.Connect(InitializeMarkerFaction, this);
        
        return result;
    }
    
    //Slot Initialize Marker Faction
    private function InitializeMarkerFaction(target:MovieClip):Void
    {
        switch (target)
        {
            case m_SouthMarker:     m_SouthMarker.faction = PvPMinigame.GetWorldStat(SOUTH_DISTRICT, 0, 0, m_DimensionID);
                                    break;
                                    
            case m_EastMarker:      m_EastMarker.faction = PvPMinigame.GetWorldStat(EAST_DISTRICT, 0, 0, m_DimensionID);
                                    break;
                                    
            case m_WestMarker:      m_WestMarker.faction = PvPMinigame.GetWorldStat(WEST_DISTRICT, 0, 0, m_DimensionID);
                                    break;
                                    
            case m_CenterMarker:    m_CenterMarker.faction = PvPMinigame.GetWorldStat(CENTER_DISTRICT, 0, 0, m_DimensionID);
                                    break;
        }
    }

    //Slot Update World Stats
    private function SlotUpdateWorldStats(statName:String, value:Number, type1:Number, type2:Number, dimensionID:Number):Void
    {
        if (m_DimensionID == dimensionID)
        {
            switch (statName)
            {
                case SOUTH_DISTRICT:    m_SouthMarker.faction = value;
                                        break;
                                        
                case EAST_DISTRICT:     m_EastMarker.faction = value;
                                        break;
                                        
                case WEST_DISTRICT:     m_WestMarker.faction = value;
                                        break;
                                        
                case CENTER_DISTRICT:   m_CenterMarker.faction = value;   
                                        break;
            }
        }
    }
}