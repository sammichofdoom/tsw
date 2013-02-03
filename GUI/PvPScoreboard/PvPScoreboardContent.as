//Imports
import com.Components.WindowComponentContent;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.Game.Character;
import com.GameInterface.PvPScoreboard;
import com.GameInterface.ProjectUtils;
import flash.geom.Point;

//Class
class GUI.PvPScoreboard.PvPScoreboardContent extends WindowComponentContent
{
    //Constants
    public static var RDB_DRAGON_ICON:Number = 7469011;
    public static var RDB_TEMPLARS_ICON:Number = 7469013;
    public static var RDB_ILLUMINATI_ICON:Number = 7469012;
    
    private static var EL_DORADO_ID:Number = 5820;
    private static var STONEHENGE_ID:Number = 5840;
    
    private static var DRAGON_WINS_EL_DORADO_LAST:String = "FCMinigameFaction1Wins_ElDorado_Last";
    private static var DRAGON_WINS_STONEHENGE_LAST:String = "FCMinigameFaction1Wins_Stonehenge_Last";
    
    private static var TEMPLARS_WINS_EL_DORADO_LAST:String = "FCMinigameFaction2Wins_ElDorado_Last";
    private static var TEMPLARS_WINS_STONEHENGE_LAST:String = "FCMinigameFaction2Wins_Stonehenge_Last";
    
    private static var ILLUMINATI_WINS_EL_DORADO_LAST:String = "FCMinigameFaction3Wins_ElDorado_Last";
    private static var ILLUMINATI_WINS_STONEHENGE_LAST:String = "FCMinigameFaction3Wins_Stonehenge_Last";
    
    private static var EL_DORADO_WON_MAJOR_ANIMA_FRAGMENT:String = "PvPElDoradoWinToken1Amount";
    private static var EL_DORADO_WON_MINOR_ANIMA_FRAGMENT:String = "PvPElDoradoWinToken2Amount";
    private static var EL_DORADO_LOST_MAJOR_ANIMA_FRAGMENT:String = "PvPElDoradoLossToken1Amount";
    private static var EL_DORADO_LOST_MINOR_ANIMA_FRAGMENT:String = "PvPElDoradoLossToken2Amount";
    
    private static var STONEHENGE_WON_MAJOR_ANIMA_FRAGMENT:String = "PvPStonehengeWinToken1Amount";
    private static var STONEHENGE_WON_MINOR_ANIMA_FRAGMENT:String = "PvPStonehengeWinToken2Amount";
    private static var STONEHENGE_LOST_MAJOR_ANIMA_FRAGMENT:String = "PvPStonehengeLossToken1Amount";
    private static var STONEHENGE_LOST_MINOR_ANIMA_FRAGMENT:String = "PvPStonehengeLossToken2Amount";
        
    //Properties
    private var m_Character:Character;
    private var m_ContentCanvas:MovieClip;
    private var m_Header:MovieClip;
    private var m_Table:MovieClip;
    private var m_Footer:MovieClip;
    private var m_FactionPlacement:Array;
    private var m_FactionScores:Array;
    
    //Constructor
    public function PvPScoreboardContent()
    {
        super();
    }
    
    //On Load
    private function onLoad():Void
    {
        m_Character = Character.GetClientCharacter();
        m_MatchPlayfieldID = PvPScoreboard.m_PlayfieldID;

        var scoreBoardArray:Array = new Array();
        scoreBoardArray.push( { faction: _global.Enums.Factions.e_FactionDragon,     wins: PvPMinigame.GetSideScore(_global.Enums.Factions.e_FactionDragon, 0) } );
        scoreBoardArray.push( { faction: _global.Enums.Factions.e_FactionTemplar,    wins: PvPMinigame.GetSideScore(_global.Enums.Factions.e_FactionTemplar, 0) } );
        scoreBoardArray.push( { faction: _global.Enums.Factions.e_FactionIlluminati, wins: PvPMinigame.GetSideScore(_global.Enums.Factions.e_FactionIlluminati, 0) } );
        
        scoreBoardArray.sortOn("wins", Array.DESCENDING | Array.NUMERIC);

                
        if ( PvPScoreboard.m_MatchResult != _global.Enums.PvPMatchResult.e_MinigameNoResult )
        {        
            var winnerFaction:Number = GetFactionFromColor(PvPScoreboard.m_WinnerSide);
            var arraySize:Number = scoreBoardArray.length;
            
            for (var i:Number = 0; i < arraySize; ++i )
            {
                if (winnerFaction != -1 && scoreBoardArray[i].faction == winnerFaction)
                {
                    var winner:Array = scoreBoardArray.splice(i, 1);
                    scoreBoardArray = winner.concat(scoreBoardArray);
                    break;
                }
            }
        }        
        
        
        m_FactionPlacement = new Array();
        m_FactionPlacement.push(scoreBoardArray[0].faction);
        m_FactionPlacement.push(scoreBoardArray[1].faction);
        m_FactionPlacement.push(scoreBoardArray[2].faction);
        
        m_FactionScores = new Array();
        m_FactionScores.push(scoreBoardArray[0].wins);
        m_FactionScores.push(scoreBoardArray[1].wins);
        m_FactionScores.push(scoreBoardArray[2].wins);
        
        m_Header.SetResults(m_FactionPlacement, m_FactionScores);
        
        m_Table.SetTable(m_FactionPlacement, m_Character);
        
        var isWinner:Boolean = false;
        if (m_Character != undefined)
        {
            isWinner = (PvPMinigame.GetWinningSide() == m_Character.GetStat( _global.Enums.Stat.e_PlayerFaction ));
        }
        
        var majorAnimaFragment:String;
        var minorAnimaFragment:String;
        
        if (m_MatchPlayfieldID == EL_DORADO_ID)
        {
            if (isWinner)
            {
                majorAnimaFragment = EL_DORADO_WON_MAJOR_ANIMA_FRAGMENT;
                minorAnimaFragment = EL_DORADO_WON_MINOR_ANIMA_FRAGMENT;
            }
            else
            {
                majorAnimaFragment = EL_DORADO_LOST_MAJOR_ANIMA_FRAGMENT;
                minorAnimaFragment = EL_DORADO_LOST_MINOR_ANIMA_FRAGMENT;
            }
        }
        
        if (m_MatchPlayfieldID == STONEHENGE_ID)
        {
            if (isWinner)
            {
                majorAnimaFragment = STONEHENGE_WON_MAJOR_ANIMA_FRAGMENT;
                minorAnimaFragment = STONEHENGE_WON_MINOR_ANIMA_FRAGMENT;
            }
            else
            {
                majorAnimaFragment = STONEHENGE_LOST_MAJOR_ANIMA_FRAGMENT;
                minorAnimaFragment = STONEHENGE_LOST_MINOR_ANIMA_FRAGMENT;
            } 
        }
        
        m_Footer.SetRewards(ProjectUtils.GetUint32TweakValue(majorAnimaFragment), ProjectUtils.GetUint32TweakValue(minorAnimaFragment));
        
        m_Footer.SignalSortTypeSelected.Connect(SlotSortTypeSelected, this);
    }

    
    //@Warning This match between enums is INTENTIONALLY WRONG. Done to fix a problem with the data sent by PvPMatchMaking::SignalPvPMatchMakingMatchEnded
    //It's very difficult to fix that in the gamecode right now, so this temporary HACK will be here until http://jira.funcom.com/browse/TSW-94901 is done
    private function GetFactionFromColor(colorEnum:Number):Number
    {
        switch(colorEnum)
        {
            case _global.Enums.PvPMatchMakingSide.e_PvPSideRed: return _global.Enums.Factions.e_FactionDragon;
            case _global.Enums.PvPMatchMakingSide.e_PvPSideBlue: return _global.Enums.Factions.e_FactionTemplar;
            case _global.Enums.PvPMatchMakingSide.e_PvPSideGreen: return _global.Enums.Factions.e_FactionIlluminati;
        }
        return -1;
    }
    
    //Slot Sort Type Selected
    private function SlotSortTypeSelected(sortType:String):Void
    {
        m_Table.SlotSortRows(undefined, sortType);
    }
}
