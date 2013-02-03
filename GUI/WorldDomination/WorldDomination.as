//Imports
import com.Utils.Archive;
import flash.geom.Rectangle;
import com.Utils.LDBFormat;
import GUI.WorldDomination.MiniMap;
import GUI.WorldDomination.StatusResults;
import GUI.WorldDomination.JoinType;

//Constants
var EL_DORADO:String = LDBFormat.LDBGetText("WorldDominationGUI", "elDorado");
var STONEHENGE:String = LDBFormat.LDBGetText("WorldDominationGUI", "stonehenge");
var FUSANG_PROJECTS:String = LDBFormat.LDBGetText("WorldDominationGUI", "forbiddenCity");

var STAGE:Rectangle;
var HEADER_HEIGHT_PERCENTAGE:Number = 0.045;
var MARGIN:Number = 20;

var EL_DORADO_QUEUE:String = "elDoradoQueue";
var EL_DORADO_ZONE:String = "elDoradoZone";
var STONEHENGE_QUEUE:String = "stonehengeQueue";
var STONEHENGE_ZONE:String = "stonehengeZone";
var FUSANG_PROJECTS_QUEUE:String = "forbiddenCityQueue";
var FUSANG_PROJECTS_ZONE:String = "forbiddenCityZone";

var ARCHIVED_SELECTED_INDEX:String = "archivedSelectedIndex";
var ARCHIVED_SELECTED_MINI_MAP_STATE:String = "archivedSelectedMiniMapState";
var ARCHIVED_SELECTED_FVF_STATUS_STATE:String = "archivedSelectedFVFStatusState";
var ARCHIVED_SELECTED_UNIFORM_TYPES:String = "archivedSelectedUniformTypes";
var ARCHIVED_SELECTED_JOIN_TYPE:String = "archivedSelectedJoinType";

//Properties
var m_SidePanel:MovieClip;
var m_WorldMap:MovieClip;
var m_Header:MovieClip;
var m_PlayfieldNameData:Array;

var m_ArchiveSelectedIndex:Number;
var m_ArchiveSelectedMiniMapState:Number;
var m_ArchivedSelectedFvFStatusState:Number;
var m_ArchiveSelectedUniformTypes:Array;
var m_ArchiveSelectedJoinType:Number;

//On Load
function onLoad():Void
{
    super();
}

//On Module Activated
function OnModuleActivated(config:Archive):Void
{
    m_ArchiveSelectedIndex = Number(config.FindEntry(ARCHIVED_SELECTED_INDEX, 2));
    m_ArchiveSelectedMiniMapState = Number(config.FindEntry(ARCHIVED_SELECTED_MINI_MAP_STATE, MiniMap.MAP_STATE));
    m_ArchivedSelectedFvFStatusState = Number(config.FindEntry(ARCHIVED_SELECTED_FVF_STATUS_STATE, StatusResults.STATUS_STATE));
    m_ArchiveSelectedUniformTypes = config.FindEntryArray(ARCHIVED_SELECTED_UNIFORM_TYPES);
    
    if (m_ArchiveSelectedUniformTypes == undefined)
    {
        m_ArchiveSelectedUniformTypes = new Array(true, true, true, true, false, false);
    }
    
    m_ArchivedSelectedJoinType = Number(config.FindEntry(ARCHIVED_SELECTED_JOIN_TYPE, JoinType.JOIN_SOLO_SELECTION));
    
    Init();    
}

//On Module Deactivated
function OnModuleDeactivated():Archive
{
    var archive:Archive = new Archive();
    archive.ReplaceEntry(ARCHIVED_SELECTED_INDEX, m_SidePanel.m_SelectedIndex);
    archive.ReplaceEntry(ARCHIVED_SELECTED_MINI_MAP_STATE, m_SidePanel.m_MiniMapSelectedState);
    archive.ReplaceEntry(ARCHIVED_SELECTED_FVF_STATUS_STATE, m_SidePanel.m_StatusResultsSelectedState);
    
    for (var i:Number = 0; i < m_SidePanel.m_UniformTypesSelectionArray.length; i++)
    {
        archive.AddEntry(ARCHIVED_SELECTED_UNIFORM_TYPES, m_SidePanel.m_UniformTypesSelectionArray[i]);
    }

    archive.ReplaceEntry(ARCHIVED_SELECTED_JOIN_TYPE, m_SidePanel.m_JoinTypeSelection);
    
    return archive;
}

//Initialize
function Init():Void
{
    STAGE = Stage["visibleRect"];
    
    m_PlayfieldNameData = new Array(EL_DORADO, STONEHENGE, FUSANG_PROJECTS);

    var sidePanelInitObject:Object =    {
                                        m_SelectedIndex: m_ArchiveSelectedIndex,
                                        m_MiniMapSelectedState: m_ArchiveSelectedMiniMapState,
                                        m_StatusResultsSelectedState: m_ArchivedSelectedFvFStatusState,
                                        m_UniformTypesSelectionArray: m_ArchiveSelectedUniformTypes,
                                        m_JoinTypeSelection: m_ArchivedSelectedJoinType
                                        };
    
    m_SidePanel = attachMovie("SidePanel", "m_SidePanel", getNextHighestDepth(), sidePanelInitObject);
    m_SidePanel._x = STAGE.x + STAGE.width - m_SidePanel._width;
    m_SidePanel._y = STAGE.y + STAGE.height - m_SidePanel._height;

    var worldMapInitObject:Object =     {
                                        m_SidePanelWidth: m_SidePanel._width
                                        };
    
    m_WorldMap = attachMovie("WorldMap", "m_WorldMap", getNextHighestDepth(), worldMapInitObject);
    m_WorldMap._x = STAGE.x;
    m_WorldMap._y = STAGE.y;

    m_Header = attachMovie("Header", "m_Header", getNextHighestDepth());
    m_Header._x = STAGE.x;
    m_Header._y = STAGE.y;
}

//
//Resize Handler
//function ResizeHandler(w:Number, h:Number, x:Number, y:Number):Void
//{
    //STAGE = Stage["visibleRect"];
//
    //m_SidePanel.Resize();
    //m_SidePanel._x = STAGE.x + STAGE.width - m_SidePanel._width;
    //m_SidePanel._y = STAGE.y + STAGE.height - m_SidePanel._height;
    //
    //m_WorldMap.m_SidePanelWidth = m_SidePanel._width;
    //m_WorldMap.Layout();
        //m_WorldMap._x = STAGE.x;
    //m_WorldMap._y = STAGE.y;
    //
    //m_Header.Layout();
        //m_Header._x = STAGE.x;
    //m_Header._y = STAGE.y;
//}