//Imports
import com.GameInterface.Game.Character;
import com.GameInterface.ProjectUtils;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.UtilsBase;
import GUI.WorldDomination.PvPLatestResultsLeader;
import GUI.WorldDomination.PvPLatestResultsScoreBoard;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import mx.utils.Delegate;

//Class
class GUI.WorldDomination.StatusResults extends MovieClip
{
    //Constants
    public static var STATUS_STATE:Number = 0;
    public static var RESULTS_STATE:Number = 1;
    
    public static var STATUS:String = LDBFormat.LDBGetText("WorldDominationGUI", "statusTabButtonTitle");
    public static var RESULTS:String = LDBFormat.LDBGetText("WorldDominationGUI", "resultsTabButtonTitle");
    
    private static var EL_DORADO:String = LDBFormat.LDBGetText("WorldDominationGUI", "elDorado");
    private static var STONEHENGE:String = LDBFormat.LDBGetText("WorldDominationGUI", "stonehenge");
    private static var FUSANG_PROJECTS:String = LDBFormat.LDBGetText("WorldDominationGUI", "forbiddenCity");
    
    private static var UPDATE_SCOREBOARD_SOUND_EFFECT:String = "sound_fxpackage_GUI_PvP_update_results.xml";
    
    private static var SCOREBOARD_UPDATE_TIME:Number = 30;
    private static var MAX_WIDTH:Number = 270;
    private static var MIN_BAR_WIDTH:Number = 27;
    private static var BARS_GAP:Number = 4;
    private static var DISABLED_ALPHA:Number = 50;
    
    private static var CURRENT_HOUR:String = LDBFormat.LDBGetText("WorldDominationGUI", "currentStatus");
    private static var PREVIOUS_HOUR:String = LDBFormat.LDBGetText("WorldDominationGUI", "latestResults");
    private static var CURRENT_STATUS:String = LDBFormat.LDBGetText("WorldDominationGUI", "currentStatusTitle");
    private static var CURRENT_RESULT:String = LDBFormat.LDBGetText("WorldDominationGUI", "currentResultTitle");
    private static var RESETS_IN:String = LDBFormat.LDBGetText("WorldDominationGUI", "resetsIn");
    private static var UPDATES_IN:String = LDBFormat.LDBGetText("WorldDominationGUI", "updatesIn");
    private static var MINUTES:String = LDBFormat.LDBGetText("WorldDominationGUI", "minutes");
    private static var MINUTE:String = LDBFormat.LDBGetText("WorldDominationGUI", "minute");
    private static var SECONDS:String = LDBFormat.LDBGetText("WorldDominationGUI", "seconds");
    private static var SECOND:String = LDBFormat.LDBGetText("WorldDominationGUI", "second");
    
    private static var FACILITY_1:String = "FCAnimaFacility1";
    private static var FACILITY_2:String = "FCAnimaFacility2";
    private static var FACILITY_3:String = "FCAnimaFacility3";
    private static var FACILITY_4:String = "FCAnimaFacility4";

    private static var TOWER_1:String = "FCAnimaTower1";
    private static var TOWER_2:String = "FCAnimaTower2";
    private static var TOWER_3:String = "FCAnimaTower3";
    private static var TOWER_4:String = "FCAnimaTower4";
    private static var TOWER_5:String = "FCAnimaTower5";
    private static var TOWER_6:String = "FCAnimaTower6";
    private static var TOWER_7:String = "FCAnimaTower7";
    private static var TOWER_8:String = "FCAnimaTower8";
    private static var TOWER_9:String = "FCAnimaTower9";
    private static var TOWER_10:String = "FCAnimaTower10";
    private static var TOWER_11:String = "FCAnimaTower11";
    private static var TOWER_12:String = "FCAnimaTower12";

    private static var BUFF_SUPPORT_DRAGON:String = "PvPFusangUnderDogBotActivatedDragon";
    private static var BUFF_SUPPORT_TEMPLARS:String = "PvPFusangUnderDogBotActivatedTemplar";
    private static var BUFF_SUPPORT_ILLUMINATI:String = "PvPFusangUnderDogBotActivatedIlluminati";
    
    private static var FACILITY_1_RDB_ID:Number = 7205220;
    private static var FACILITY_2_RDB_ID:Number = 7205221;
    private static var FACILITY_3_RDB_ID:Number = 7205222;
    private static var FACILITY_4_RDB_ID:Number = 7205223;
    
    private static var COUNCIL_SUPPORT_DRAGON_RDB_ID:Number = 7964955;
    private static var COUNCIL_SUPPORT_TEMPLARS_RDB_ID:Number = 7964956;
    private static var COUNCIL_SUPPORT_ILLUMINATI_RDB_ID:Number = 7964957;
    
    private static var CUSTODIAN_BUFF_DRAGON_RDB_ID:Number = 7964959;
    private static var CUSTODIAN_BUFF_TEMPLARS_RDB_ID:Number = 7964960;
    private static var CUSTODIAN_BUFF_ILLUMINATI_RDB_ID:Number = 7964961;
    
    private static var DRAGON_WINS_EL_DORADO:String = "FCMinigameFaction1Wins_ElDorado";
    private static var DRAGON_WINS_EL_DORADO_LAST:String = "FCMinigameFaction1Wins_ElDorado_Last";
    private static var TEMPLARS_WINS_EL_DORADO:String = "FCMinigameFaction2Wins_ElDorado";
    private static var TEMPLARS_WINS_EL_DORADO_LAST:String = "FCMinigameFaction2Wins_ElDorado_Last";
    private static var ILLUMINATI_WINS_EL_DORADO:String = "FCMinigameFaction3Wins_ElDorado";
    private static var ILLUMINATI_WINS_EL_DORADO_LAST:String = "FCMinigameFaction3Wins_ElDorado_Last";
    private static var DRAGON_WINS_STONEHENGE:String = "FCMinigameFaction1Wins_Stonehenge";
    private static var DRAGON_WINS_STONEHENGE_LAST:String = "FCMinigameFaction1Wins_Stonehenge_Last";
    private static var TEMPLARS_WINS_STONEHENGE:String = "FCMinigameFaction2Wins_Stonehenge";
    private static var TEMPLARS_WINS_STONEHENGE_LAST:String = "FCMinigameFaction2Wins_Stonehenge_Last";
    private static var ILLUMINATI_WINS_STONEHENGE:String = "FCMinigameFaction3Wins_Stonehenge";
    private static var ILLUMINATI_WINS_STONEHENGE_LAST:String = "FCMinigameFaction3Wins_Stonehenge_Last";
    
    private static var FVF_SCORE_UPDATE_TIME:String = "PvPFvF_Score_UpdateTime";
    private static var FVF_SCORE_DRAGON:String = "PvPFvF_Score_Dragon";
    private static var FVF_SCORE_TEMPLAR:String = "PvPFvF_Score_Templar";
    private static var FVF_SCORE_ILLUMANITI:String = "PvPFvF_Score_Illuminati";
    
    private static var FVF_INTERVAL_TIME:String = "PvPIntervalTime";
    private static var FVF_INTERVAL_REWARD_FACILITY_1:String = "PvPIntervalRewardFacility1";
    private static var FVF_INTERVAL_REWARD_FACILITY_4:String = "PvPIntervalRewardFacility4";
    private static var FVF_TICK_REWARD_SMALL_ANIMA_WELL:String = "PvPFusangTickRewardSmallAnimaWell";

    //Properties
    public var SignalStateChanged:Signal;
    
    private var m_ButtonBar:MovieClip;
    private var m_ButtonBarLine:MovieClip;
    private var m_TabButtonArray:Array;

    private var m_StatusTitle_1:TextField;
    private var m_StatusSubtitle_1:TextField;
    
    private var m_StatusTitle_2:TextField;
    private var m_StatusSubtitle_2:TextField;
    
    private var m_Character:Character;
    
    private var m_DimensionPvP:Number;
    private var m_DimensionFvF:Number;
        
    private var m_TemplarsBar:MovieClip;
    private var m_TemplarsBarIcon:MovieClip;
    private var m_IlluminatiBar:MovieClip;
    private var m_IlluminatiBarIcon:MovieClip;
    private var m_DragonBar:MovieClip;
    private var m_DragonBarIcon:MovieClip;
    
    private var m_FVFTotalScore:Number;
    
    private var m_StatusScoreBoardLeader:PvPLatestResultsLeader;
    private var m_FirstPlaceStatusScoreBoard:PvPLatestResultsScoreBoard;
    private var m_SecondPlaceStatusScoreBoard:PvPLatestResultsScoreBoard;
    private var m_ThirdPlaceStatusScoreBoard:PvPLatestResultsScoreBoard;
    
    private var m_TokenDistribution:MovieClip;
    private var m_FirstPlaceResultsScoreBoard:MovieClip;
    private var m_SecondPlaceResultsScoreBoard:MovieClip;
    private var m_ThirdPlaceResultsScoreBoard:MovieClip;
    
    private var m_IntervalID_FvF:Number;
    private var m_StartTime_FvF:Number;
    private var m_Time_FvF:Number;
    
    private var m_State:Number;
    
    private var m_CurrentPlayfield:String;
    
    //Constructor
    public function StatusResults()
    {
        SignalStateChanged = new Signal();
        
        Init();
    }
    
    //Initialize
    private function Init():Void
    {
        m_Character = Character.GetClientCharacter();
        m_DimensionPvP = 0;
        m_DimensionFvF = PvPMinigame.GetCurrentDimensionId();
        
        m_TabButtonArray = new Array();
        m_TabButtonArray.push({label: STATUS});
        m_TabButtonArray.push({label: RESULTS});

        m_ButtonBar = attachMovie("ButtonBar", "m_ButtonBar", getNextHighestDepth());
        m_ButtonBar.tabChildren = false;
        m_ButtonBar.itemRenderer = "PvPTabButton";
        m_ButtonBar.direction = "horizontal";
        m_ButtonBar.spacing = -5;
        m_ButtonBar.autoSize = "center";
        m_ButtonBar.dataProvider = m_TabButtonArray;
        m_ButtonBar.selectedIndex = m_State;
        m_ButtonBar._y = -3;
        m_ButtonBar.addEventListener("change", this, "SelectedTabBarEventHandler");
        
        m_ButtonBarLine = createEmptyMovieClip("buttonBarLine", getNextHighestDepth());
        m_ButtonBarLine.lineStyle(1, 0x656565, 100, true, "noScale");
        m_ButtonBarLine.moveTo(0, 0);
        m_ButtonBarLine.lineTo(270, 0);
        m_ButtonBarLine.endFill();
        m_ButtonBarLine._y = m_ButtonBar._y + 27;  
    }
    
    //On Load
    private function onLoad():Void
    {
        m_StatusTitle_1.text = CURRENT_HOUR;
        
        var rewardFacility1:Number = ProjectUtils.GetUint32TweakValue(FVF_INTERVAL_REWARD_FACILITY_1);
        var rewardFacility4:Number = ProjectUtils.GetUint32TweakValue(FVF_INTERVAL_REWARD_FACILITY_4);
        var rewardTickSmallAnimaWell:Number = ProjectUtils.GetUint32TweakValue(FVF_TICK_REWARD_SMALL_ANIMA_WELL);
        
        m_DimensionFvF = PvPMinigame.GetCurrentDimensionId();
        
        m_FVFTotalScore = rewardFacility1 * 3 + rewardFacility4 + rewardTickSmallAnimaWell * 12;
    
        RequestTimeToStatusUpdate();
        setInterval(this, "RequestTimeToStatusUpdate", 1000);
        
        UpdateCurrentResultsScoreBoard();
        
        PvPMinigame.SignalStatusUpdateTime.Connect(SlotUpdateHourSubtitles, this);
        PvPMinigame.SignalWorldStatChanged.Connect(SlotUpdateStatus, this);
        
        UpdateStatusBars();
        UpdateStatusScoreBoard();
        
        ResetCurrentResultsTime();
    }
    
    //Request Time To Status Update
    private function RequestTimeToStatusUpdate():Void
    {
        /*
         *  This function requests the execution of "SignalStatusUpdateTime" each
         *  second as that signal is only requested, does not continuously fire.
         * 
         */

        PvPMinigame.RequestTimeToStatusUpdate();
    }
    
    //Reset Current Results Time
    private function ResetCurrentResultsTime():Void
    {
        if (m_IntervalID_FvF)
        {
            clearInterval(m_IntervalID_FvF);
            m_IntervalID_FvF = null;
        }

        m_Time_FvF = PvPMinigame.GetWorldStat(FVF_SCORE_UPDATE_TIME, 0, 0, m_DimensionFvF) - UtilsBase.GetServerSyncedTime();
        m_StartTime_FvF = getTimer();
        
        if (m_Time_FvF < 0)
        {
            m_Time_FvF = ProjectUtils.GetUint32TweakValue(FVF_INTERVAL_TIME);
        }        
        
        UpdateCurrentResultsTimer();
        m_IntervalID_FvF = setInterval(this, "UpdateCurrentResultsTimer", 1000);
    }
    
    //Update Current Results Timer
    private function UpdateCurrentResultsTimer():Void
    {
        if (m_CurrentPlayfield == FUSANG_PROJECTS)
        {
            var timeLeft:Number = m_Time_FvF - (Math.round((getTimer() - m_StartTime_FvF) / 1000));
            var timeNumber:Number;
            var timeString:String;
            var updateScoreBoardCounter:Number = 0;
            
            if (timeLeft >= 0)
            {
                if (timeLeft >= 60)
                {
                    timeNumber = Math.ceil(timeLeft / 60);
                    timeString = (timeNumber == 1) ? MINUTE : MINUTES;
                }
                else
                {
                    timeNumber = timeLeft;
                    timeString = (timeNumber == 1) ? SECOND : SECONDS;
                }

                updateScoreBoardCounter = timeLeft % SCOREBOARD_UPDATE_TIME;
            }
            else
            {
                timeNumber = 0;
                updateScoreBoardCounter = 0;
                timeString = SECONDS;
                m_Time_FvF = PvPMinigame.GetWorldStat(FVF_SCORE_UPDATE_TIME, 0, 0, m_DimensionFvF) - UtilsBase.GetServerSyncedTime();
            }

            if (updateScoreBoardCounter == 1)
            {
                _global["setTimeout"]( Delegate.create(this, UpdateCurrentResultsScoreBoard), 1000);
            }
            
            m_TokenDistribution.UpdateLabel(timeNumber.toString() + " " + timeString);
            
            m_StatusSubtitle_2.text = UPDATES_IN + " " + updateScoreBoardCounter.toString() + " " + ((updateScoreBoardCounter == 1) ? SECOND : SECONDS);
            
            if (timeLeft < 0)
            {
                ResetCurrentResultsTime();
            }
        }        
    }
    
    //Update Current Results Score Board
    private function UpdateCurrentResultsScoreBoard():Void
    {
        var dragonScore:Number = PvPMinigame.GetWorldStat(FVF_SCORE_DRAGON, 0, 0, m_DimensionFvF);
        var templarsScore:Number = PvPMinigame.GetWorldStat(FVF_SCORE_TEMPLAR, 0, 0, m_DimensionFvF);
        var illuminatiScore:Number = PvPMinigame.GetWorldStat(FVF_SCORE_ILLUMANITI, 0, 0, m_DimensionFvF);
        
        var facilityConstantsArray:Array = new Array    (
                                                        FACILITY_1,
                                                        FACILITY_2,
                                                        FACILITY_3,
                                                        FACILITY_4,
                                                        TOWER_1,
                                                        TOWER_2,
                                                        TOWER_3,
                                                        TOWER_4,
                                                        TOWER_5,
                                                        TOWER_6,
                                                        TOWER_7,
                                                        TOWER_8,
                                                        TOWER_9,
                                                        TOWER_10,
                                                        TOWER_11,
                                                        TOWER_12
                                                        );

        var facilitiesArray:Array = new Array();
        
        for (var i:Number = 0; i < facilityConstantsArray.length; i++)
        {
            facilitiesArray.push(PvPMinigame.GetWorldStat(facilityConstantsArray[i], 0, 0, m_DimensionFvF));
        }
                                                
        var scoreBoardArray:Array = new Array();
        
        scoreBoardArray.push({faction: _global.Enums.Factions.e_FactionDragon, score: dragonScore});
        scoreBoardArray.push({faction: _global.Enums.Factions.e_FactionTemplar, score: templarsScore});
        scoreBoardArray.push({faction: _global.Enums.Factions.e_FactionIlluminati, score: illuminatiScore});
        
        scoreBoardArray.sortOn("score", Array.DESCENDING | Array.NUMERIC);
        
        m_FirstPlaceResultsScoreBoard.SetFaction(scoreBoardArray[0].faction, facilitiesArray);       
        m_SecondPlaceResultsScoreBoard.SetFaction(scoreBoardArray[1].faction, facilitiesArray);        
        m_ThirdPlaceResultsScoreBoard.SetFaction(scoreBoardArray[2].faction, facilitiesArray);
    }
    
    //Slot Update Hour Subtitles
    private function SlotUpdateHourSubtitles(timeLeft:Number):Void
    {
        var timeNumber:Number;
        var timeString:String;
        
        if (timeLeft >= 60)
        {
            timeNumber = Math.floor(timeLeft / 60);
            timeString = (timeNumber == 1) ? MINUTE : MINUTES;
        }
        else
        {
            timeNumber = timeLeft;
            timeString = (timeNumber == 1) ? SECOND : SECONDS;
            
            if (timeNumber == 0 && m_Character != undefined)
            {
                m_Character.AddEffectPackage(UPDATE_SCOREBOARD_SOUND_EFFECT);
            }
        }
        
        m_StatusSubtitle_1.text = RESETS_IN + " " + timeNumber.toString() + " " + timeString;
        
        if (m_CurrentPlayfield != FUSANG_PROJECTS)
        {
            m_StatusSubtitle_2.text = UPDATES_IN + " " + timeNumber.toString() + " " + timeString;            
        }
    }

    //Slot Update Status
    private function SlotUpdateStatus(statName:String, value:Number, type1:Number, type2:Number, dimID:Number):Void
    {
        switch (statName)
        {
            case DRAGON_WINS_EL_DORADO:
            case TEMPLARS_WINS_EL_DORADO:
            case ILLUMINATI_WINS_EL_DORADO:
                
            case DRAGON_WINS_STONEHENGE:
            case TEMPLARS_WINS_STONEHENGE:
            case ILLUMINATI_WINS_STONEHENGE:
                
            case FVF_SCORE_DRAGON:
            case FVF_SCORE_TEMPLAR:
            case FVF_SCORE_ILLUMANITI:                  UpdateStatusBars();
                                                        break;
                                                
            case DRAGON_WINS_EL_DORADO_LAST:
            case TEMPLARS_WINS_EL_DORADO_LAST:
            case ILLUMINATI_WINS_EL_DORADO_LAST:
                
            case DRAGON_WINS_STONEHENGE_LAST:
            case TEMPLARS_WINS_STONEHENGE_LAST:
            case ILLUMINATI_WINS_STONEHENGE_LAST:       UpdateStatusScoreBoard();
                                                        break;

            case FVF_SCORE_UPDATE_TIME:                 if (m_DimensionFvF == dimID)
                                                        {
                                                            UpdateCurrentResultsScoreBoard();
                                                            ResetCurrentResultsTime();
                                                        }
                                                        break;
                                                        
            case FACILITY_1:
            case FACILITY_2:
            case FACILITY_3:
            case FACILITY_4:
            case BUFF_SUPPORT_DRAGON:
            case BUFF_SUPPORT_TEMPLARS:
            case BUFF_SUPPORT_ILLUMINATI:               UpdateStatusScoreBoard();
                                                        break;
        }
    }
    
    //Update Status Bars
    private function UpdateStatusBars():Void
    {
        var dragonWins:Number;
        var templarsWins:Number;
        var illuminatiWins:Number;
        
        var wins:Number;
        var totalWins:Number;
        
        if (m_CurrentPlayfield == EL_DORADO)
        {
            dragonWins = PvPMinigame.GetWorldStat(DRAGON_WINS_EL_DORADO, 0, 0, m_DimensionPvP);
            templarsWins = PvPMinigame.GetWorldStat(TEMPLARS_WINS_EL_DORADO, 0, 0, m_DimensionPvP);
            illuminatiWins = PvPMinigame.GetWorldStat(ILLUMINATI_WINS_EL_DORADO, 0, 0, m_DimensionPvP);
            
            wins = dragonWins + templarsWins + illuminatiWins;
            totalWins = wins;
        }
        
        if (m_CurrentPlayfield == STONEHENGE)
        {
            dragonWins = PvPMinigame.GetWorldStat(DRAGON_WINS_STONEHENGE, 0, 0, m_DimensionPvP);
            templarsWins = PvPMinigame.GetWorldStat(TEMPLARS_WINS_STONEHENGE, 0, 0, m_DimensionPvP);
            illuminatiWins = PvPMinigame.GetWorldStat(ILLUMINATI_WINS_STONEHENGE, 0, 0, m_DimensionPvP);
            
            wins = dragonWins + templarsWins + illuminatiWins;
            totalWins = wins;
        }
        
        if (m_CurrentPlayfield == FUSANG_PROJECTS)
        {
            dragonWins = PvPMinigame.GetWorldStat(FVF_SCORE_DRAGON, 0, 0, m_DimensionFvF);
            templarsWins = PvPMinigame.GetWorldStat(FVF_SCORE_TEMPLAR, 0, 0, m_DimensionFvF);
            illuminatiWins = PvPMinigame.GetWorldStat(FVF_SCORE_ILLUMANITI, 0, 0, m_DimensionFvF);
            
            wins = dragonWins + templarsWins + illuminatiWins;
            totalWins = m_FVFTotalScore;
        }
                
        var dragonPercent:Number = (wins == 0) ? 0.333333333 : dragonWins / totalWins;
        var templarsPercent:Number = (wins == 0) ? 0.333333333 : templarsWins / totalWins;
        var illuminatiPercent:Number = (wins == 0) ? 0.333333333 : illuminatiWins / totalWins;
        
        var statusBarsArray:Array = new Array();
        statusBarsArray.push({bar: m_DragonBar, icon: m_DragonBarIcon, percentage: dragonPercent});
        statusBarsArray.push({bar: m_TemplarsBar, icon: m_TemplarsBarIcon, percentage: templarsPercent});
        statusBarsArray.push({bar: m_IlluminatiBar, icon: m_IlluminatiBarIcon, percentage: illuminatiPercent});
        
        statusBarsArray.sortOn("percentage", Array.DESCENDING | Array.NUMERIC);
        
        var zeros:Number = 0;
        
        for (var i:Number = 0; i < statusBarsArray.length; i++)
        {
            statusBarsArray[i].icon.m_Percentage.autoSize = "center";

            if (statusBarsArray[i].percentage == 0)
            {
                zeros++
            }
        }
        
        var maxBarWidth:Number = MAX_WIDTH - (MIN_BAR_WIDTH * zeros) - BARS_GAP * 2;
        
        for (var i:Number = 0; i < statusBarsArray.length; i++)
        {
            var bar:Object = statusBarsArray[i].bar;
            var icon:Object = statusBarsArray[i].icon;
            var percentage:Number = statusBarsArray[i].percentage;
            
            bar._width = Math.max(MIN_BAR_WIDTH, maxBarWidth * percentage);
            bar._x = (i == 0) ? 0 : statusBarsArray[i - 1].bar._x + statusBarsArray[i - 1].bar._width + BARS_GAP;
            icon._x = bar._x + bar._width / 2 - icon._width / 2;
            icon.m_Percentage.text = (Math.round(percentage * 100)) + "%";
            
            if (percentage == 0)
            {
                bar._alpha = DISABLED_ALPHA;
                icon._alpha = DISABLED_ALPHA;
            }
        }
    }
    
    //Update Score Board
    private function UpdateStatusScoreBoard():Void
    {
        var dragonWins:Number;
        var templarsWins:Number;
        var illuminatiWins:Number;
        
        if (m_CurrentPlayfield == EL_DORADO)
        {
            dragonWins = PvPMinigame.GetWorldStat(DRAGON_WINS_EL_DORADO_LAST, 0, 0, m_DimensionPvP);
            templarsWins = PvPMinigame.GetWorldStat(TEMPLARS_WINS_EL_DORADO_LAST, 0, 0, m_DimensionPvP);
            illuminatiWins = PvPMinigame.GetWorldStat(ILLUMINATI_WINS_EL_DORADO_LAST, 0, 0, m_DimensionPvP);
        }
        
        if (m_CurrentPlayfield == STONEHENGE)
        {
            dragonWins = PvPMinigame.GetWorldStat(DRAGON_WINS_STONEHENGE_LAST, 0, 0, m_DimensionPvP);
            templarsWins = PvPMinigame.GetWorldStat(TEMPLARS_WINS_STONEHENGE_LAST, 0, 0, m_DimensionPvP);
            illuminatiWins = PvPMinigame.GetWorldStat(ILLUMINATI_WINS_STONEHENGE_LAST, 0, 0, m_DimensionPvP);
        }
        
        if (m_CurrentPlayfield == FUSANG_PROJECTS)
        {
            dragonWins = PvPMinigame.GetWorldStat(FVF_SCORE_DRAGON, 0, 0, m_DimensionFvF);
            templarsWins = PvPMinigame.GetWorldStat(FVF_SCORE_TEMPLAR, 0, 0, m_DimensionFvF);
            illuminatiWins = PvPMinigame.GetWorldStat(FVF_SCORE_ILLUMANITI, 0, 0, m_DimensionFvF);
        }
        
        var scoreBoardArray:Array = new Array();
        
        scoreBoardArray.push({faction: _global.Enums.Factions.e_FactionDragon, wins: dragonWins});
        scoreBoardArray.push({faction: _global.Enums.Factions.e_FactionTemplar, wins: templarsWins});
        scoreBoardArray.push({faction: _global.Enums.Factions.e_FactionIlluminati, wins: illuminatiWins});
        
        scoreBoardArray.sortOn("wins", Array.DESCENDING | Array.NUMERIC);

        m_StatusScoreBoardLeader.SetLeader(scoreBoardArray[0].faction);
        
        m_FirstPlaceStatusScoreBoard.SetFaction(scoreBoardArray[0].faction);
        m_SecondPlaceStatusScoreBoard.SetFaction(scoreBoardArray[1].faction);
        m_ThirdPlaceStatusScoreBoard.SetFaction(scoreBoardArray[2].faction);
        if (m_CurrentPlayfield == FUSANG_PROJECTS)
        {
            m_FirstPlaceStatusScoreBoard.SetBuffs(GetCurrentFactionBuffs(scoreBoardArray[0].faction));
            m_SecondPlaceStatusScoreBoard.SetBuffs(GetCurrentFactionBuffs(scoreBoardArray[1].faction));
            m_ThirdPlaceStatusScoreBoard.SetBuffs(GetCurrentFactionBuffs(scoreBoardArray[2].faction));
        }
        else
        {
            m_FirstPlaceStatusScoreBoard.SetWins(scoreBoardArray[0].wins);
            m_SecondPlaceStatusScoreBoard.SetWins(scoreBoardArray[1].wins);
            m_ThirdPlaceStatusScoreBoard.SetWins(scoreBoardArray[2].wins);
        }
    }
    
    //Get Current Faction Buffs
    private function GetCurrentFactionBuffs(faction:Number):Array
    {
        var buffIDs:Array = new Array();
        
        var factionBuffs:Array = new Array();
        factionBuffs.push   (
                            {name: FACILITY_1, id: FACILITY_1_RDB_ID},
                            {name: FACILITY_2, id: FACILITY_2_RDB_ID},
                            {name: FACILITY_3, id: FACILITY_3_RDB_ID},
                            {name: FACILITY_4, id: FACILITY_4_RDB_ID}
                            )
        
        var buffSupport:String;
        var councilRDB:Number;
        var custodianRDB:Number;
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon: 
                buffSupport = BUFF_SUPPORT_DRAGON; 
                councilRDB = COUNCIL_SUPPORT_DRAGON_RDB_ID;
                custodianRDB = CUSTODIAN_BUFF_DRAGON_RDB_ID
                break;
                                        
            case _global.Enums.Factions.e_FactionTemplar: 
                buffSupport = BUFF_SUPPORT_TEMPLARS; 
                councilRDB = COUNCIL_SUPPORT_TEMPLARS_RDB_ID;
                custodianRDB = CUSTODIAN_BUFF_TEMPLARS_RDB_ID
                break;
                                        
            case _global.Enums.Factions.e_FactionIlluminati: 
                buffSupport = BUFF_SUPPORT_ILLUMINATI; 
                councilRDB = COUNCIL_SUPPORT_ILLUMINATI_RDB_ID;
                custodianRDB = CUSTODIAN_BUFF_ILLUMINATI_RDB_ID
                break;
        }
        
        if (buffSupport != undefined)
        {
            switch (PvPMinigame.GetWorldStat(buffSupport, 0, 0, m_DimensionFvF))
            {
                case 2:     if ( councilRDB && councilRDB > 0 )
                            {
                                buffIDs.push(councilRDB);
                            }
                            break;
                            
                case 3:     if ( custodianRDB && custodianRDB > 0 )
                            {
                                buffIDs.push(custodianRDB);
                            }
                            break;
            }
        }

        for (var i:Number = 0; i < factionBuffs.length; i++)
        {
            var stat:Number = PvPMinigame.GetWorldStat(factionBuffs[i].name, 0, 0, m_DimensionFvF);
            if ( stat == faction)
            {
                buffIDs.push(factionBuffs[i].id)
            }
        }
        
        return buffIDs;
    }
    
    //Selected Tab Bar Event Handler
    private function SelectedTabBarEventHandler(event:Object):Void
    {
        state = event.index;
        
        Selection.setFocus(null);
    }
    
    //Set FvF Visibility
    private function SetFvFVisibility(visible:Boolean):Void
    {
        m_ButtonBar._visible = visible;
        m_ButtonBarLine._visible = visible;

        m_StatusTitle_1._visible = !visible;
        m_StatusSubtitle_1._visible = !visible;
    }
    
    //Set Status Visibility
    private function SetStatusVisibility(visible:Boolean):Void
    {
        m_IlluminatiBar._visible = visible;
        m_DragonBar._visible = visible;
        m_TemplarsBar._visible = visible;
        m_IlluminatiBarIcon._visible = visible;
        m_DragonBarIcon._visible = visible;
        m_DragonBarIcon._visible = visible;
        m_TemplarsBarIcon._visible = visible;
        m_StatusScoreBoardLeader._visible = visible;
        m_FirstPlaceStatusScoreBoard._visible = visible;
        m_SecondPlaceStatusScoreBoard._visible = visible;
        m_ThirdPlaceStatusScoreBoard._visible = visible;
    }
    
    //Set Results Visibility
    private function SetResultsVisibility(visible:Boolean):Void
    {
        m_TokenDistribution._visible = visible;
        m_FirstPlaceResultsScoreBoard._visible = visible;
        m_SecondPlaceResultsScoreBoard._visible = visible;
        m_ThirdPlaceResultsScoreBoard._visible = visible;
    }
    
    //Set State
    public function set state(state:Number):Void
    {
        if (state == STATUS_STATE)
        {
            m_ButtonBar.selectedIndex = STATUS_STATE;
            
            SetStatusVisibility(true);
            SetResultsVisibility(false);
            
            m_StatusTitle_2.text = CURRENT_STATUS;
        }

        if (state == RESULTS_STATE)
        {
            m_ButtonBar.selectedIndex = RESULTS_STATE;
            
            SetStatusVisibility(false);
            SetResultsVisibility(true);
            
            m_StatusTitle_2.text = CURRENT_RESULT;
        }
        
        m_State = state;

        SignalStateChanged.Emit(state);
    }
    
    //Get State
    public function get state():Number
    {
        return m_State;
    }
    
    //Set Playfield
    public function set playfield(playfieldName:String):Void
    {
        m_CurrentPlayfield = playfieldName;
        
        switch (m_CurrentPlayfield)
        {
            case EL_DORADO:
            case STONEHENGE:        SetFvFVisibility(false);
                                    SetStatusVisibility(true);
                                    SetResultsVisibility(false);
                                    
                                    m_StatusTitle_2.text = PREVIOUS_HOUR; 
                                    
                                    break;
                                    
            case FUSANG_PROJECTS:   SetFvFVisibility(true);
        }
        
        UpdateStatusBars();
        UpdateStatusScoreBoard();
    }
    
    //Get Playfield
    public function get playfield():String
    {
        return m_CurrentPlayfield;
    }
}