import com.GameInterface.WaypointInterface
import com.GameInterface.Waypoint
import com.Utils.ID32;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Character;

var m_MovieClipLoader:MovieClipLoader;

var m_RenderedWaypoints:Object = new Object;
var m_RenderedStackingWaypoints:Object = new Object;
var m_RenderedStackingWaypointsCount:Number;

var m_StageWidth:Number; 

var m_WpPosLeftYBase:Number;
var m_WpPosRightYBase:Number;
var m_WpPosLeftY:Number;
var m_WpPosRightY:Number;

var m_PlayfieldID:Number = 0;
var m_CurrentPFInterface:WaypointInterface;

var m_WaypointPadding:Number = 5;

Init();

function ResizeHandler( w, h ,x, y )
{
    var visibleRect = Stage["visibleRect"];
    _x = Stage["visibleRect"].x;
    _y = Stage["visibleRect"].y;
    m_StageWidth = visibleRect.width;
    
    m_WpPosLeftYBase = visibleRect.height * 0.3;
    m_WpPosRightYBase = visibleRect.height * 0.45;
    
    UpdateScreenWaypoints();
}

///Initializes this movieclip
function Init()
{
    m_RenderedStackingWaypointsCount = 0;
    m_MovieClipLoader = new MovieClipLoader();
    m_MovieClipLoader.addListener( this );
    
    ResizeHandler();

    WaypointInterface.SignalPlayfieldChanged.Connect(SlotPlayfieldChanged, this);
    
    var clientCharID = CharacterBase.GetClientCharID();
    if (clientCharID !=  0 && clientCharID != undefined)
    {
        var character:Character = Character.GetClientCharacter();
		if (character != undefined)
		{
			var pfId:Number = character.GetPlayfieldID();
			if (pfId != 0)
			{
				SlotPlayfieldChanged(pfId);
			}
		}
    }
}

/// When playfield changes we need to connect to a different playfieldwaypoints interface, 
/// and get its waypoints
function SlotPlayfieldChanged(newPlayfield:Number)
{
    //Remove all the old waypoints
    for(var id in m_RenderedWaypoints)
    {
        RemoveWaypoint(id);
    }
    m_RenderedWaypoints = new Object();
    m_RenderedStackingWaypoints = new Object();
    m_RenderedStackingWaypointsCount = 0;

    m_PlayfieldID = newPlayfield;

    m_CurrentPFInterface = new WaypointInterface(m_PlayfieldID);

    m_CurrentPFInterface.SignalWaypointAdded.Connect( SlotWaypointAdded, this);
    m_CurrentPFInterface.SignalWaypointRemoved.Connect( SlotWaypointRemoved, this);
    m_CurrentPFInterface.SignalWaypointMoved.Connect( SlotWaypointMoved, this);
    m_CurrentPFInterface.SignalWaypointStateChanged.Connect(SlotWaypointStateChanged, this);
    m_CurrentPFInterface.SignalWaypointColorChanged.Connect(SlotWaypointColorChanged, this);
    m_CurrentPFInterface.SignalWaypointRenamed.Connect(SlotWaypointRenamed, this);

    m_CurrentPFInterface.GetExistingWaypoints(m_PlayfieldID);
}

/// Adds a waypoint to the screenrenderer. Adds waypoints depending on which type
function SlotWaypointAdded(id:ID32)
{
    var waypoint:Waypoint = m_CurrentPFInterface.m_Waypoints[id.toString()];
    if(waypoint.m_IsScreenWaypoint)
    {
        var waypointClip:MovieClip;
        switch(waypoint.m_WaypointType)
        {
            case _global.Enums.WaypointType.e_RMWPQuest_Sabotage:
            case _global.Enums.WaypointType.e_RMWPQuest_Investigation:
            case _global.Enums.WaypointType.e_RMWPQuest_Action:
            case _global.Enums.WaypointType.e_RMWPQuest_Story:
            case _global.Enums.WaypointType.e_RMWPQuest_Dungeon:
            case _global.Enums.WaypointType.e_RMWPQuest_Raid:
			case _global.Enums.WaypointType.e_RMWPQuest_PvP:
			case _global.Enums.WaypointType.e_RMWPQuest_Item:
			case _global.Enums.WaypointType.e_RMWPQuest_Lair:
			case _global.Enums.WaypointType.e_RMWPQuest_Massacre:
			case _global.Enums.WaypointType.e_RMWPQuest_Group:
                waypointClip = this.attachMovie("MissionWaypoint", id.toString(), this.getNextHighestDepth());
                break;
            case _global.Enums.WaypointType.e_RMWPTeamMember:
                waypointClip = this.attachMovie("FriendWaypoint", id.toString(), this.getNextHighestDepth());
                break;
            case _global.Enums.WaypointType.e_RMWPPvPDestination:
            case _global.Enums.WaypointType.e_RMWPTombStone:
            case _global.Enums.WaypointType.e_RMWPControlDragons:
            case _global.Enums.WaypointType.e_RMWPControlIlluminati:
            case _global.Enums.WaypointType.e_RMWPControlTemplars:
            case _global.Enums.WaypointType.e_RMWPPlayerDragons:
            case _global.Enums.WaypointType.e_RMWPPlayerIlluminati:
            case _global.Enums.WaypointType.e_RMWPPlayerTemplars:
            case _global.Enums.WaypointType.e_RMWPSpawnDragons:
            case _global.Enums.WaypointType.e_RMWPSpawnIlluminati:
            case _global.Enums.WaypointType.e_RMWPSpawnTemplars:
            case _global.Enums.WaypointType.e_RMWPTower:
            case _global.Enums.WaypointType.e_RMWPFacility:
            case _global.Enums.WaypointType.e_RMWPHotSpot:
                waypointClip = this.attachMovie("CustomWaypoint", id.toString(), this.getNextHighestDepth());
                break;
            default:
            return;
        }
        if (waypoint.m_WaypointState == _global.Enums.QuestWaypointState.e_WPStateInactive || waypoint.m_WaypointState == _global.Enums.QuestWaypointState.e_WPStateHidden)
        {
            waypointClip.Enable(false);
        }
        waypointClip.SetWaypoint(waypoint);
        m_RenderedWaypoints[id] = waypointClip;
    }
    if (waypoint.m_IsStackingWaypoint)
    {
        if (m_RenderedStackingWaypoints[id] == undefined)
        {
            m_RenderedStackingWaypointsCount++;
        }
        m_RenderedStackingWaypoints[id] = waypointClip;
    }
}

function SlotWaypointRemoved(id:ID32)
{
    RemoveWaypoint(id.toString());
}

function RemoveWaypoint(id:String)
{
    m_RenderedWaypoints[id].removeMovieClip();
    m_RenderedWaypoints[id] = undefined;
    if (m_RenderedStackingWaypoints[id] != undefined)
    {
        m_RenderedStackingWaypointsCount--;
    }
    m_RenderedStackingWaypoints[id] = undefined;
}

function SlotWaypointMoved(id:String)
{
  //Dont need to do anything as c++ updates the wp references
}


///Listens to state change for waypoints, and makes them visible if they become active
function SlotWaypointStateChanged(id:ID32)
{
    var waypoint:Waypoint = m_CurrentPFInterface.m_Waypoints[id.toString()];
    if (m_RenderedWaypoints[id] != undefined)
    {
        if(waypoint.m_WaypointState == _global.Enums.QuestWaypointState.e_WPStateActive)
        {
            m_RenderedWaypoints[id].Enable(true);
        }
        else
        {
            m_RenderedWaypoints[id].Enable(false);
        }
    }
}

function SlotWaypointColorChanged(id:ID32)
{
    var waypoint:Waypoint = m_CurrentPFInterface.m_Waypoints[id.toString()];
    if (m_RenderedWaypoints[id] != undefined)
    {
        m_RenderedWaypoints[id].UpdateColor();
    }
}
function SlotWaypointRenamed(id:ID32)
{
    var waypoint:Waypoint = m_CurrentPFInterface.m_Waypoints[id.toString()];
    if (m_RenderedWaypoints[id] != undefined)
    {
        m_RenderedWaypoints[id].SetName(waypoint.m_Label);
    }
}


///Updates the position for each waypoint on screen each frame
function UpdateScreenWaypoints()
{
  m_WpPosLeftY = m_WpPosLeftYBase-40;
  m_WpPosRightY = m_WpPosRightYBase;
  for( var id in m_CurrentPFInterface.m_Waypoints )
  {
    var waypoint = m_CurrentPFInterface.m_Waypoints[id];
    if(waypoint.m_IsScreenWaypoint)
    {
      var wpObj:Object = m_RenderedWaypoints[id];
      if (wpObj != undefined)
      {
          if(wpObj.m_Direction == "left")
          {
              wpObj._y = m_WpPosLeftY;
              m_WpPosLeftY -= wpObj._height + m_WaypointPadding;
          }
          else if(wpObj.m_Direction == "right")
          {
              wpObj._y = m_WpPosRightY;
              m_WpPosRightY += wpObj._height + m_WaypointPadding;
          }
          else if (waypoint.m_IsStackingWaypoint)
          {
              waypoint.m_CollisionOffsetX = 0;
              waypoint.m_CollisionOffsetY = 0;
              var collision:Boolean = (m_RenderedStackingWaypointsCount < 10);
              while (collision)
              {
                  collision = false;
                  for ( var idCompare in m_RenderedStackingWaypoints )
                  {
                      if (id == idCompare)
                      {
                          break;
                      }
                      var waypointCompare = m_CurrentPFInterface.m_Waypoints[idCompare];
                      var wpObjCompare = m_RenderedStackingWaypoints[idCompare];
                      if (wpObjCompare != undefined) // don't collide with undefined stuff...
                      {
                          var posX:Number = waypoint.m_ScreenPositionX + waypoint.m_CollisionOffsetX;
                          var posY:Number = waypoint.m_ScreenPositionY + waypoint.m_CollisionOffsetY;
                          var comparePosX:Number = waypointCompare.m_ScreenPositionX + waypointCompare.m_CollisionOffsetX;
                          var comparePosY:Number = waypointCompare.m_ScreenPositionY + waypointCompare.m_CollisionOffsetY;
                          if (!( posX > comparePosX + wpObjCompare.GetWidth() ||  // wpObjCompare is to the left
                                 posX + wpObj.GetWidth() < comparePosX ||         // wpObjCompare is to the right
                                 posY > comparePosY + wpObjCompare.GetHeight() || // wpObjCompare is above
                                 posY + wpObj.GetHeight() < comparePosY ))        // wpObjCompare is below
                          {
                              // collision! move up!
                              waypoint.m_CollisionOffsetY -= posY + wpObj.GetHeight() - waypointCompare.m_ScreenPositionY - waypointCompare.m_CollisionOffsetY + m_WaypointPadding;
                              collision = true;
                              break;
                          }
                      }
                  }
              }
          }      
          wpObj.Update(m_StageWidth);
      }
      else
      {
          com.GameInterface.Log.Error( "Waypoints", "UpdateScreenWaypoints() found waypoint in m_CurrentPFInterface that was not in m_RenderedStackingWaypoints" );
      }
    }
  }
}

function onEnterFrame()
{
  UpdateScreenWaypoints();
}
