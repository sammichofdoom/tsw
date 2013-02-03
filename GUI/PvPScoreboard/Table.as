//Class
import com.Utils.LDBFormat;
import com.GameInterface.ProjectUtils;
import com.GameInterface.PvPScoreboard;
import com.GameInterface.PvPScoreboardPlayerData;
import GUI.PvPScoreboard.SortButton;
import com.GameInterface.Game.Character;

//Class
class GUI.PvPScoreboard.Table extends MovieClip
{
    //Constants
    public static var SORT_TYPE_FACTION:String = "sortTypeFaction";
    public static var SORT_TYPE_ALL:String = "sortTypeAll";
    
    private static var EL_DORADO_ID:Number = 5820;
    private static var STONEHENGE_ID:Number = 5840;
    private static var SCROLL_WHEEL_SPEED:Number = 10;
 
    private static var RANK:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_rank");
    private static var PLAYER_NAME:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_playerName");
    private static var ROLE:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_role");
    private static var DAMAGE:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_damage");
    private static var HEALING:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_healing");
    private static var CROWD_CONTROL:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_crowdControl");
    private static var DAMAGE_TAKEN:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_damageTaken");
    private static var KILLS:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_kills");
    private static var DEATH:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_death");
    private static var RELIC:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_relic");
    private static var DOMINATION:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_domination");
    private static var POINTS:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_points");
    
    private static var RANK_OBJECT_NAME:String = "RANK_OBJECT_NAME";
    private static var PLAYER_NAME_OBJECT_NAME:String = "PLAYER_NAME_OBJECT_NAME";
    private static var ROLE_OBJECT_NAME:String = "ROLE_OBJECT_NAME";
    private static var DAMAGE_OBJECT_NAME:String = "DAMAGE_OBJECT_NAME";
    private static var HEALING_OBJECT_NAME:String = "HEALING_OBJECT_NAME";
    private static var CROWD_CONTROL_OBJECT_NAME:String = "CROWD_CONTROL_OBJECT_NAME";
    private static var DAMAGE_TAKEN_OBJECT_NAME:String = "DAMAGE_TAKEN_OBJECT_NAME";
    private static var KILLS_OBJECT_NAME:String = "KILLS_OBJECT_NAME";
    private static var DEATH_OBJECT_NAME:String = "DEATH_OBJECT_NAME";
    private static var POINTS_OBJECT_NAME:String = "POINTS_OBJECT_NAME";
    private static var DYNAMIC_OBJECT_NAME:String = "DYNAMIC_OBJECT_NAME";
    private static var FACTION_HEADER:String = "FACTION_HEADER";
    
    //Properties
    public var m_Character:Character;
    
    private var m_CategoryHeader:MovieClip;
    private var m_SortButtonArray:Array;
    private var m_SelectedSortButton:SortButton;
    
    private var m_ScrollContainer:MovieClip;
    private var m_RowsContainer:MovieClip;
    private var m_ScrollBar:MovieClip;
    private var m_ScrollBarPosition:Number;
    private var m_PreviousRowsContainerY:Number;
    private var m_ItemsArray:Array;
    private var m_RowsArray:Array;
        
    private var m_SortType:String;
    private var m_SortTarget:String;
    private var m_SortDirection:String;
    private var m_FactionPlacement:Array;
    
    private var m_IsLoaded:Boolean;
    private var m_CheckInterval:Number;
    
    //Constructor
    public function TableCategoryHeader()
    {
        super();
        
        m_IsLoaded = false;
    }
    
    //On Load
    private function onLoad():Void
    {
        m_IsLoaded = true;
    }
    
    //Set Table
    public function SetTable(factionPlacement:Array, clientCharacter:Character):Void
    {
        m_FactionPlacement = factionPlacement;
        m_Character = clientCharacter;
        
        m_CheckInterval = setInterval(CheckLoaded, 20, this);
    }
    
    //Check Loaded
    private function CheckLoaded(scope:Object):Void
    {
        if (scope.m_IsLoaded)
        {
            clearInterval(scope.m_CheckInterval);
            scope.InitTable();
        }
    }
    
    //Initialize Table
    private function InitTable():Void
    {
        var dynamicPointsLabel:String;
        
        switch(PvPScoreboard.m_PlayfieldID) 
        {
            case EL_DORADO_ID:      dynamicPointsLabel = RELIC;
            
                                    break;
                                    
            case STONEHENGE_ID:     dynamicPointsLabel = DOMINATION;
        }
        
        m_SortButtonArray = new Array();
        
        SetCategoryHeading(m_CategoryHeader.m_Rank, RANK, RANK_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_PlayerName, PLAYER_NAME, PLAYER_NAME_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_Role, ROLE, ROLE_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_Damage, DAMAGE, DAMAGE_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_Healing, HEALING, HEALING_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_CrowdControl, CROWD_CONTROL, CROWD_CONTROL_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_DamageTaken, DAMAGE_TAKEN, DAMAGE_TAKEN_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_Kills, KILLS, KILLS_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_Death, DEATH, DEATH_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_DynamicPoints, dynamicPointsLabel, DYNAMIC_OBJECT_NAME);
        SetCategoryHeading(m_CategoryHeader.m_Points, POINTS, POINTS_OBJECT_NAME);
        
        CreateRowsContainer();
        
        ProjectUtils.SetMovieClipMask(m_RowsContainer, null, m_ScrollContainer._height, m_ScrollContainer.m_Background._width);
        
        m_ScrollBar = attachMovie("ScrollBar", "m_ScrollBar", getNextHighestDepth());
        m_ScrollBar._x = m_ScrollContainer._x + m_ScrollContainer.m_Background._width + 4; 
        m_ScrollBar._y = m_ScrollContainer._y - 5;
        m_ScrollBar._visible = true;
        m_ScrollBar.setScrollProperties(m_ScrollContainer._height, 0,  m_ScrollContainer._height); 
        m_ScrollBar._height = m_ScrollContainer._height + 10;
        m_ScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
        m_ScrollBar.position = m_ScrollBarPosition = 0;
        m_ScrollBar.trackMode = "scrollPage";
        m_ScrollBar.disableFocus = true;
        
        var bestCategoryName:String = GetCharactersBestCategory();
        
        CreateTable(SORT_TYPE_FACTION, bestCategoryName, SortButton.DESCENDING);
        
        for (var i:Number = 0; i < m_SortButtonArray.length; i++)
        {
            if (m_SortButtonArray[i].name == bestCategoryName)
            {
                m_SelectedSortButton = m_SortButtonArray[i];
            }
        }
    }
    
    //Get Characters Best Category
    private function GetCharactersBestCategory():String
    {
        for (var i:Number = 0; i < PvPScoreboard.m_Players.length; i++)
        {
            if (PvPScoreboard.m_Players[i].m_Name == m_Character.GetName())
            {
                var dynamicData:Number;
                
                switch(PvPScoreboard.m_PlayfieldID) 
                {
                    case EL_DORADO_ID:      dynamicData = PvPScoreboard.m_Players[i].m_FlagsTaken;
                                            
                                            break;
                                            
                    case STONEHENGE_ID:     dynamicData = PvPScoreboard.m_Players[i].m_TimeInDominationZone;
                }
        
                var bestCategoryArray:Array = new Array();
                
                bestCategoryArray.push  (
                                        {key: DAMAGE_OBJECT_NAME,           value: PvPScoreboard.m_Players[i].m_DamageDone},
                                        {key: HEALING_OBJECT_NAME,          value: PvPScoreboard.m_Players[i].m_HealingDone},
                                        {key: CROWD_CONTROL_OBJECT_NAME,    value: PvPScoreboard.m_Players[i].m_CCDone},
                                        {key: DAMAGE_TAKEN_OBJECT_NAME,     value: PvPScoreboard.m_Players[i].m_DamageAbsorbed},
                                        {key: KILLS_OBJECT_NAME,            value: PvPScoreboard.m_Players[i].m_Kills},
                                        {key: DYNAMIC_OBJECT_NAME,          value: dynamicData}
                                        );
                
                bestCategoryArray.sortOn("value", Array.NUMERIC | Array.DESCENDING);

                return bestCategoryArray[0].key;
            }
        }
        
        return DAMAGE_OBJECT_NAME;
    }
 
    //Create Table
    private function CreateTable(sortType:String, sortTarget:String, sortDirection:String):Void
    {
        m_SortType = sortType;
        m_SortTarget = (sortTarget == undefined) ? m_SortTarget : sortTarget;
        m_SortDirection = (sortDirection == undefined) ? m_SortDirection : sortDirection;
        
        CreateItems();

        ActivateInitialSortButtonDisplay();
    }
    
    //Set Category Heading
    private function SetCategoryHeading(target:MovieClip, label:String, name:String):Void
    {
        target.m_Title.text = label;
        target.m_SortButton.name = name;
        target.m_SortButton.SignalSortItems.Connect(SlotSortRows, this);

        m_SortButtonArray.push(target.m_SortButton);
    }
    
    //Slot Sort Rows
    public function SlotSortRows(sortButton:SortButton, sortType:String):Void
    {
        if (sortButton != undefined)
        {
            if (m_SelectedSortButton != sortButton && m_SelectedSortButton != undefined)
            {   
                m_SelectedSortButton.Deselect();
            }
            
            m_SelectedSortButton = sortButton;
        }
        else
        {
            m_SortType = sortType;
        }
        
        m_SortTarget = m_SelectedSortButton.name;
        m_SortDirection = m_SelectedSortButton.direction;
        
        SortItems(m_SortTarget, m_SortDirection);
    }
    
    //Create Rows Container
    private function CreateRowsContainer():Void
    {
        m_RowsContainer = createEmptyMovieClip("m_RowsContainer", getNextHighestDepth());
        m_RowsContainer._x = m_ScrollContainer._x;
        m_RowsContainer._y = m_ScrollContainer._y;
    }

    //Create Items
    private function CreateItems():Void
    {
        m_ItemsArray = new Array();

        for (var i:Number = 0; i < PvPScoreboard.m_Players.length; i++)
        {
            if (PvPScoreboard.m_Players[i].m_Name == undefined || PvPScoreboard.m_Players[i].m_Name == "")
            {
                trace("[PvPScoreboard.Table.CreateItems()] ERROR:Player without Name:"+PvPScoreboard.m_Players[i].m_PlayerID);
            }
            var playerData:PvPScoreboardPlayerData = PvPScoreboard.m_Players[i];
            var dynamicData:Number;
            switch(PvPScoreboard.m_PlayfieldID) 
            {
                case EL_DORADO_ID:      dynamicData = playerData.m_FlagsTaken;
                                        
                                        break;
                                        
                case STONEHENGE_ID:     dynamicData = playerData.m_TimeInDominationZone;
            }
                                                            
            m_ItemsArray.push   ({
                                RANK_OBJECT_NAME:             playerData.m_Faction,
                                PLAYER_NAME_OBJECT_NAME:      playerData.m_Name,
                                ROLE_OBJECT_NAME:             playerData.m_Role,
                                DAMAGE_OBJECT_NAME:           playerData.m_DamageDone,
                                HEALING_OBJECT_NAME:          playerData.m_HealingDone,
                                CROWD_CONTROL_OBJECT_NAME:    playerData.m_CCDone,
                                DAMAGE_TAKEN_OBJECT_NAME:     playerData.m_DamageAbsorbed,
                                KILLS_OBJECT_NAME:            playerData.m_Kills,
                                DEATH_OBJECT_NAME:            playerData.m_Deaths,
                                DYNAMIC_OBJECT_NAME:          dynamicData,
                                POINTS_OBJECT_NAME:           playerData.m_DamageDone + playerData.m_HealingDone + playerData.m_CCDone + playerData.m_DamageAbsorbed + playerData.m_Kills - playerData.m_Deaths,
                                faction:                      playerData.m_Faction
                                });   
        }
        
        SortItems(m_SortTarget, m_SortDirection);
    }
    
    //Sort Items
    private function SortItems(sortTarget:String, sortDirection:String):Void
    {       
        var sortOption:Number;
        
        if (sortTarget == PLAYER_NAME)
        {
            sortOption = (sortDirection != SortButton.DESCENDING) ? Array.CASEINSENSITIVE : Array.CASEINSENSITIVE | Array.DESCENDING;
        }
        else
        {
            sortOption = (sortDirection != SortButton.DESCENDING) ? Array.NUMERIC : Array.NUMERIC | Array.DESCENDING;
        }        
        
        m_ItemsArray.sortOn(sortTarget, sortOption);
        
        CreateRows(sortTarget);
    }
    
    //Create Rows
    private function CreateRows(sortTarget:String):Void
    {
        if (m_SortType == SORT_TYPE_FACTION)
        {
            var firstPlaceArray:Array = new Array();
            firstPlaceArray.push({FACTION_HEADER: m_FactionPlacement[0]});
            
            var secondPlaceArray:Array = new Array();
            secondPlaceArray.push({FACTION_HEADER: m_FactionPlacement[1]});
            
            var thirdPlaceArray:Array = new Array();
            thirdPlaceArray.push( { FACTION_HEADER: m_FactionPlacement[2] } );
            
            for (var i:Number = 0; i < m_ItemsArray.length; i++)
            {
                switch (m_ItemsArray[i].faction)
                {
                    case m_FactionPlacement[0]:     firstPlaceArray.push(m_ItemsArray[i]);
                                                    break;
                                                    
                    case m_FactionPlacement[1]:     secondPlaceArray.push(m_ItemsArray[i]);
                                                    break;
                                                    
                    case m_FactionPlacement[2]:     thirdPlaceArray.push(m_ItemsArray[i]);
                                                    break;
                }
            }

            m_ItemsArray = firstPlaceArray.concat(secondPlaceArray, thirdPlaceArray); 
        }
        else
        {
            for (var i:Number = m_ItemsArray.length - 1; i > -1; i--)
            {
                if (m_ItemsArray[i].FACTION_HEADER != undefined)
                {
                    m_ItemsArray.splice(i, 1);
                }
            }
        }
        
        if (m_ScrollBar)
        {
            m_ScrollBarPosition = m_ScrollBar.position;
        }

        m_PreviousRowsContainerY = m_RowsContainer._y;
            
        m_RowsContainer.removeMovieClip();
        m_RowsContainer = null;
        
        CreateRowsContainer();
        
        m_RowsArray = new Array();
        
        for (var i:Number = 0; i < m_ItemsArray.length; i++)
        {
            var row:MovieClip = m_RowsContainer.attachMovie("TableRow", "m_Row_" + i, m_RowsContainer.getNextHighestDepth());
            
            if (m_SortType == SORT_TYPE_FACTION && m_ItemsArray[i].FACTION_HEADER != undefined)
            {
                row.SetFactionHeader(m_ItemsArray[i].FACTION_HEADER);
            }
            else
            {
                row.SetRankIcon(m_ItemsArray[i].faction);   //(m_ItemsArray[i].RANK_OBJECT_NAME);
                row.m_Rank.name = RANK_OBJECT_NAME;
                
                row.m_PlayerName.m_Label.text = m_ItemsArray[i].PLAYER_NAME_OBJECT_NAME;
                row.m_PlayerName.name = PLAYER_NAME_OBJECT_NAME;
                
                row.SetRoleIcon(m_ItemsArray[i].ROLE_OBJECT_NAME);
                row.m_Role.name = ROLE_OBJECT_NAME;
                
                row.m_Damage.m_Label.text = m_ItemsArray[i].DAMAGE_OBJECT_NAME;
                row.m_Damage.name = DAMAGE_OBJECT_NAME;
                
                row.m_Healing.m_Label.text = m_ItemsArray[i].HEALING_OBJECT_NAME;
                row.m_Healing.name = HEALING_OBJECT_NAME;
                
                row.m_CrowdControl.m_Label.text = m_ItemsArray[i].CROWD_CONTROL_OBJECT_NAME;
                row.m_CrowdControl.name = CROWD_CONTROL_OBJECT_NAME;
                
                row.m_DamageTaken.m_Label.text = m_ItemsArray[i].DAMAGE_TAKEN_OBJECT_NAME;
                row.m_DamageTaken.name = DAMAGE_TAKEN_OBJECT_NAME;
                
                row.m_Kills.m_Label.text = m_ItemsArray[i].KILLS_OBJECT_NAME;
                row.m_Kills.name = KILLS_OBJECT_NAME;
                
                row.m_Death.m_Label.text = m_ItemsArray[i].DEATH_OBJECT_NAME;
                row.m_Death.name = DEATH_OBJECT_NAME;
                
                row.m_DynamicPoints.m_Label.text = m_ItemsArray[i].DYNAMIC_OBJECT_NAME;
                row.m_DynamicPoints.name = DYNAMIC_OBJECT_NAME;
                
                row.m_Points.m_Label.text = m_ItemsArray[i].POINTS_OBJECT_NAME;
                row.m_Points.name = POINTS_OBJECT_NAME;

                row.SetRowColors(m_ItemsArray[i].faction, sortTarget, m_ItemsArray[i].PLAYER_NAME_OBJECT_NAME == m_Character.GetName())
            }
            
            row._y = (i == 0) ? 0 : m_RowsArray[i - 1]._y + m_RowsArray[i - 1]._height + 1;
            
            m_RowsArray.push(row);
        }

        UpdateScrollBar();
    }

    //Update Scroll Bar
    private function UpdateScrollBar():Void
    {
        ProjectUtils.SetMovieClipMask(m_RowsContainer, null, m_ScrollContainer._height, m_ScrollContainer.m_Background._width);
        
        if (m_RowsContainer._height > m_ScrollContainer._height)
        {
            m_ScrollBar._visible = true;
            m_ScrollBar.setScrollProperties(m_ScrollContainer._height, 0, m_RowsContainer._height - m_ScrollContainer._height);

            if (m_ScrollBarPosition > m_ScrollBar.maxPosition)
            {
                m_ScrollBar.position = m_ScrollBar.maxPosition;
                m_PreviousRowsContainerY = m_ScrollContainer._y + m_ScrollContainer._height - m_RowsContainer._height;
            }
            else
            {
                m_ScrollBar.position = m_ScrollBarPosition;
            }
            
            m_RowsContainer._y = m_PreviousRowsContainerY;
        }
        else
        {
            m_ScrollBar._visible = false;
            
            m_ScrollBar.position = 0;
        }
    }
    
    //Activate Initial Sort Button Display
    private function ActivateInitialSortButtonDisplay():Void
    {
        for (var i:Number = 0; i < m_SortButtonArray.length; i++)
        {
            if (m_SortButtonArray[i].name == m_SortTarget)
            {
                m_SortButtonArray[i].ActivateDisplay(m_SortDirection);
            }
        }
    }
    
    //On Mouse Wheel
    function onMouseWheel(delta:Number):Void
    {
        if (Mouse["IsMouseOver"](this) && m_ScrollBar._visible)
        {
            var newPos:Number = m_ScrollBar.position + -(delta * SCROLL_WHEEL_SPEED);
            var event:Object = {target: m_ScrollBar};
            
            m_ScrollBar.position = Math.min(Math.max(0.0, newPos), m_ScrollBar.maxPosition);
            
            OnScrollbarUpdate(event);
        }
    }
    
    //On Scroll Bar Update
    private function OnScrollbarUpdate(event:Object):Void
    {
        var target:MovieClip = event.target;
        var pos:Number = event.target.position;
        
        m_RowsContainer._y = m_ScrollContainer._y - pos;
        
        Selection.setFocus(null);
    }
}