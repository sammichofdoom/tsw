//Imports
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.Utils.Format;
import com.Utils.Colors;

//Class
class GUI.WorldDomination.FvFCurrentResultsScoreBoard extends MovieClip
{
    //Constants
    private static var DRAGON_POINTS_WORLDSTAT:String = "PvPFvF_Score_Dragon";
    private static var TEMPLAR_POINTS_WORLDSTAT:String = "PvPFvF_Score_Templar";
    private static var ILLUMINATI_POINTS_WORLDSTAT:String = "PvPFvF_Score_Illuminati";
    
    
    private static var OUTER_FACILITY_RDB_ID:Number = 7969081;
    private static var INNER_FACILITY_RDB_ID:Number = 7969080;
    private static var TOWER_RDB_ID:Number = 7969082;
    private static var MINOR_ANIMA_FRAGMENT_RDB_ID:Number = 7460078;
    
    
    //Properties
    private var m_IlluminatiIcon:MovieClip;
    private var m_DragonIcon:MovieClip;
    private var m_TemplarsIcon:MovieClip;
    
    private var m_Faction:Number;

    private var m_InnerTextField:TextField;
    private var m_OuterTextField:TextField;
    private var m_TowerTextField:TextField;
    private var m_TotalTextField:TextField;
    
    private var m_DimensionID:Number;
    
    private var m_OutterMarker:MovieClip;
    private var m_InnerMarker:MovieClip;
    private var m_TowerMarker:MovieClip;
    private var m_ScoreMarker:MovieClip;
    
    //Constructor
    public function FvFCurrentResultsScoreBoard()
    {
        m_DimensionID = PvPMinigame.GetCurrentDimensionId();
        
        Init();
    }
    
    //Init
    private function Init():Void
    {
        HideIcons();
        createEmptyMovieClip("m_OuterIcon", getNextHighestDepth());
        
        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        var imageLoaderListener:Object = new Object();
        imageLoaderListener.onLoadInit = function(target:MovieClip)
        {
            target._xscale = 20;
            target._yscale = 20;
        }
        movieClipLoader.addListener( imageLoaderListener );
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", _global.Enums.RDBID.e_RDB_FlashFile, OUTER_FACILITY_RDB_ID), m_OutterMarker);
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", _global.Enums.RDBID.e_RDB_FlashFile, INNER_FACILITY_RDB_ID), m_InnerMarker);
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", _global.Enums.RDBID.e_RDB_FlashFile, TOWER_RDB_ID), m_TowerMarker);
        
        var animaFragmentLoader:MovieClipLoader = new MovieClipLoader();
        var animaFragmentLoaderListener:Object = new Object();
        animaFragmentLoaderListener.onLoadInit = function(target:MovieClip)
        {
            target._xscale = 25;
            target._yscale = 25;
        }
        animaFragmentLoader.addListener( animaFragmentLoaderListener );
        animaFragmentLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", _global.Enums.RDBID.e_RDB_FlashFile, MINOR_ANIMA_FRAGMENT_RDB_ID), m_ScoreMarker);
    }

    private function HideIcons():Void
    {
        m_DragonIcon._visible = false;
        m_TemplarsIcon._visible = false;
        m_IlluminatiIcon._visible = false;
    }
    
    //Set Faction
    public function SetFaction(faction:Number, facilities:Array):Void
    {
        m_Faction = faction;
        
        HideIcons();
        
        var totalPoints:Number = 0;
        var factionColor:Number;
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionTemplar:
                                factionColor = Colors.e_ColorPvPTemplar;
                                m_TemplarsIcon._visible = true;
                                totalPoints = PvPMinigame.GetWorldStat(TEMPLAR_POINTS_WORLDSTAT, 0, 0, m_DimensionID)
                                break;
            case _global.Enums.Factions.e_FactionDragon:
                                factionColor = Colors.e_ColorPvPDragon;
                                m_DragonIcon._visible = true;
                                totalPoints = PvPMinigame.GetWorldStat(DRAGON_POINTS_WORLDSTAT, 0, 0, m_DimensionID)
                                break;
            case _global.Enums.Factions.e_FactionIlluminati:
                                factionColor = Colors.e_ColorPvPIlluminati;
                                m_IlluminatiIcon._visible = true;
                                totalPoints = PvPMinigame.GetWorldStat(ILLUMINATI_POINTS_WORLDSTAT, 0, 0, m_DimensionID)
                                break;
        }
        
        var outerFacilityPoints:Number = 0;
        var innerFacilityPoints:Number = 0;
        var towerPoints:Number = 0;
        
        ClearMarkerColors();
        
        for (var i:Number = 0; i < facilities.length; i++)
        {
            if (i < 3 && facilities[i] == faction)
            {
                outerFacilityPoints++;
                Colors.ApplyColor(m_OutterMarker, factionColor);
            }
            
            if (i == 3 && facilities[i] == faction)
            {
                innerFacilityPoints++;
                Colors.ApplyColor(m_InnerMarker, factionColor);
            }
            
            if (i > 3 && facilities[i] == faction)
            {
                towerPoints++
                Colors.ApplyColor(m_TowerMarker, factionColor);
            }
        }
        
        m_OuterTextField.text = outerFacilityPoints.toString();
        m_InnerTextField.text = innerFacilityPoints.toString();
        m_TowerTextField.text = towerPoints.toString();
        m_TotalTextField.text = totalPoints.toString();  
    }

    private function ClearMarkerColors():Void
    {
        Colors.ApplyColor(m_OutterMarker, Colors.e_ColorDarkGray);
        //m_OutterMarker._alpha = 
        Colors.ApplyColor(m_InnerMarker, Colors.e_ColorDarkGray);
        Colors.ApplyColor(m_TowerMarker, Colors.e_ColorDarkGray);
    }
    
}
