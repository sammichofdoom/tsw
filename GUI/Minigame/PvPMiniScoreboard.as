import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import flash.filters.GlowFilter;
import mx.utils.Delegate;
import flash.filters.BlurFilter;
import com.GameInterface.Log;
import com.GameInterface.Utils;
import com.Utils.Colors;
import com.Utils.LDBFormat;

var m_TimerPanel:MovieClip;
var m_TokenPanel:MovieClip;
var m_FlagPanel:MovieClip;

var SIDE_SCORE:Number = 0;
var SIDE_FLAGS:Number = 1;
var PLAYER_CAPTURED_FLAG:Number = 662;
var PLAYER_RETURNED_FLAG:Number = 663;

var PANEL_STATE_NORMAL:Number = 0;
var PANEL_STATE_DOMINATION:Number = 1;

var m_PanelState:Number = PANEL_STATE_NORMAL;


var m_TokenSize:Number = 22;
var m_MaxFlags:Number = 4;
var m_PlayerMaxFlags:Number = 4;
var m_UpdateTimer:Number = undefined;

/// domination, who got all flags
var m_DominationTime:Number = 120; // in seconds, 2 minutes
var m_DominationTimeStarted:Number;
var m_DominationTimerId:Number = undefined;
var m_DominationTimeRefreshSpeed:Number = 500;
var m_DominationSide:Number = 0;

var m_TokenLinkage:String = "Flag";
var m_TokenName:String = "";
var m_UseDropFlags:Boolean = true;

var m_DisabledAlpha:Number = 50;
var m_UnfocusedAlpha:Number = 80;

var m_TDB_Overtime:String = LDBFormat.LDBGetText("GenericGUI", "Overtime");
var m_TDB_Timeleft:String = LDBFormat.LDBGetText("GenericGUI", "time_left");
var m_TDB_TimeToStart:String = LDBFormat.LDBGetText("GenericGUI", "time_left_until_start");

// For some strange reason the import com.GameInterface.PvPMinigame.PvPMinigame fails.
// just setting the full path to the intrisic class to this variable to make code more readable
//var PVPClass:Object = PvPMinigame;//com.GameInterface.PvPMinigame.PvPMinigame;

var m_FilterArray:Array;
var m_Sides:Object = { };
var m_Character:Character;

var m_PlantFlagEnabled:Boolean = false;

/// the d value for the missiontierinfo
var m_MissionTierInfoDValue:DistributedValue;
var m_PVPMiniScoreDValue:DistributedValue;
var m_PvPNotifierDValue:DistributedValue;

function onLoad()
{

    /// get the distributed value for the MisionTierInfo as we will unload it whan we start a minigame, and reload it when done
    m_MissionTierInfoDValue = DistributedValue.Create( "mission_tier_info" );
 	m_PvPNotifierDValue =  DistributedValue.Create( "pvp_matchmaking_notifier" );
    
    m_Sides[_global.Enums.Factions.e_FactionDragon] = { color:  Colors.e_ColorPvPDragon, 
														textColor: Colors.e_ColorPvPDragonText,
                                                        score:  m_TokenPanel.m_ScoreGreen, 
                                                        tokens: m_TokenPanel.m_FlagGreen,
														tokenScore: 0
                                                        };
    m_Sides[_global.Enums.Factions.e_FactionTemplar] = {    color:  Colors.e_ColorPvPTemplar, 
															textColor: Colors.e_ColorPvPTemplarText,
                                                            score:  m_TokenPanel.m_ScoreRed, 
                                                            tokens: m_TokenPanel.m_FlagRed,
															tokenScore: 0
                                                            };
                                                            
    m_Sides[_global.Enums.Factions.e_FactionIlluminati] = { color:  Colors.e_ColorPvPIlluminati, 
															textColor: Colors.e_ColorPvPIlluminatiText,
                                                            score:  m_TokenPanel.m_ScoreBlue, 
                                                            tokens: m_TokenPanel.m_FlagBlue,
															tokenScore: 0
                                                            };
  
    m_Character = Character.GetClientCharacter();

    /// create the glow filter we'll use later
    var glowFilter:GlowFilter = new GlowFilter ( Colors.e_ColorWhite, 1, 9, 9, 1.5, 3, false, false);
    m_FilterArray = [glowFilter];
    
    m_FlagPanel.m_PlantFlagButton.addEventListener("click", this, "SlotPlantFlag");
	m_FlagPanel.m_PlantFlagButton.disableFocus = true;
    
   // loop and disable flags
    for (var i:Number = 0; i < m_PlayerMaxFlags; i++)
    {
        m_TimerPanel["m_Flag_" + i]._alpha = m_DisabledAlpha;
    }

    PvPMinigame.SignalPvPMinigameScoreChanged.Connect( SlotScoreChanged, this );
    PvPMinigame.SignalPvPMatchMakingMatchRemoved.Connect( SlotMatchRemoved, this );
    PvPMinigame.SignalPvPMatchMakingMatchStarted.Connect( SlotMatchStarted, this );
    PvPMinigame.SignalPvPMatchMakingMatchEnded.Connect( SlotMatchEnded, this );
    PvPMinigame.SignalMinigameStartsInXSeconds.Connect( SlotMinigameStartsInXSeconds, this );
    PvPMinigame.SignalMatchWantsToStart.Connect( SlotMatchWantsToStart, this );

     m_Character.SignalStatChanged.Connect( SlotStatChanged, this );
        
    UpdateVisibility();
    //SlotScoreChanged();
 
	InitLayout();
}

function GetName() : String
{
    return "PVPMiniScoreboard";
}

/// the method called by SFClipLoader
function OnUnload()
{
    //trace("PvPMiniScoreboard.OnUnload()")
    ///
    /// cannot solve the issue with signals disconnection, so manual disconnecting till this is sortid
    ///
    PvPMinigame.SignalPvPMinigameScoreChanged.Disconnect( SlotScoreChanged, this );
    PvPMinigame.SignalPvPMatchMakingMatchRemoved.Disconnect( SlotMatchRemoved, this );
    PvPMinigame.SignalPvPMatchMakingMatchStarted.Disconnect( SlotMatchStarted, this );
    PvPMinigame.SignalPvPMatchMakingMatchEnded.Disconnect( SlotMatchEnded, this );
    PvPMinigame.SignalMinigameStartsInXSeconds.Disconnect( SlotMinigameStartsInXSeconds, this );
    PvPMinigame.SignalMatchWantsToStart.Disconnect( SlotMatchWantsToStart, this );
   
    if ( m_UpdateTimer != undefined )
    {
        clearInterval( m_UpdateTimer );
    }
	
	if ( m_DominationTimerId != undefined )
	{
		clearInterval( m_DominationTimerId );
		m_DominationTimerId = undefined;
	}
}


function UpdateVisibility()
{
    var inMatchPlayfield:Boolean = PvPMinigame.InMatchPlayfield();
    var status:Number = PvPMinigame.GetMinigameStatus();
    
    /// its a minigame
    if ( inMatchPlayfield &&
         PvPMinigame.GetMatchType() != _global.Enums.MinigameType.e_FactionVsFaction &&
         (
            status == _global.Enums.PvPMinigameStatus.e_MinigameStarted ||
            status == _global.Enums.PvPMinigameStatus.e_MinigameEnded ||
            status == _global.Enums.PvPMinigameStatus.e_MinigameWarmup
         )
       )
    {
		if (_alpha < 100)
        {
            InitLayout();
        }
        
        /// set the text depending on status
        if (status == _global.Enums.PvPMinigameStatus.e_MinigameStarted)
        {
            m_TimerPanel.m_TimeLeft.text = m_TDB_Timeleft
        }
        else if (status == _global.Enums.PvPMinigameStatus.e_MinigameEnded)
        {
            m_TimerPanel.m_TimeLeft.text = "";
        }
        else
        {
            m_TimerPanel.m_TimeLeft.text = m_TDB_TimeToStart;
        }
        
        /// set visiblity
        _alpha = 100;
        m_MissionTierInfoDValue.SetValue( false );
		m_PvPNotifierDValue.SetValue( false );
        
        /// start the countdowm
        if ( m_UpdateTimer == undefined )
        {
            m_UpdateTimer = setInterval( Delegate.create( this, OnUpdateTimer ), 100 );
            OnUpdateTimer();
        }
        
        UpdateFlags();
    }
    else
    {
        _alpha = 0;
        m_MissionTierInfoDValue.SetValue( true );
        m_PvPNotifierDValue.SetValue( true );    
        if ( m_UpdateTimer != undefined )
        {
            clearInterval( m_UpdateTimer );
            m_UpdateTimer = undefined;
        }
    }
}
/**/


function OnUpdateTimer()
{
    var time:Number = -1;
    
    var status:Number = PvPMinigame.GetMinigameStatus();
    if ( status == _global.Enums.PvPMinigameStatus.e_MinigameWarmup )
    {
        time = PvPMinigame.GetToGameTimeLeft();
        
    }
    else if ( status == _global.Enums.PvPMinigameStatus.e_MinigameStarted )
    {
        time = PvPMinigame.GetTimeLeft();
    }
    
    if ( time >= 0 )
    {
        m_TimerPanel.m_TimeView.text = com.Utils.Format.Printf( "%02.0f:%02.0f:%02.0f", Math.floor(time / 60 / 60), Math.floor(time / 60) % 60, time % 60 );
    }
	else if ( status == _global.Enums.PvPMinigameStatus.e_MinigameStarted )
	{
        m_TimerPanel.m_TimeView.text = m_TDB_Overtime;
        m_TimerPanel.m_TimeLeft.text = "";
        
    }
	else
	{
		m_TimerPanel.m_TimeView.text = "";
	}
}
/**/

/**
 * Listens to StatChanges on the character and passing on the stat to update in necessary
 */
function SlotStatChanged(stat:Number):Void
{    
	
    if (m_UseDropFlags && (stat == PLAYER_CAPTURED_FLAG || stat == PLAYER_RETURNED_FLAG))
    {
        UpdateFlags();
    }
}

/**
 * Updates the flags a character holds
 */
function UpdateFlags() : Void
{
    var capturedflags:Number = m_Character.GetStat(PLAYER_CAPTURED_FLAG, 0);
    var returnedflags:Number = m_Character.GetStat(PLAYER_RETURNED_FLAG, 0);
    var totalFlags:Number = capturedflags - returnedflags;
	
    if (totalFlags <= 0)
	{
		m_PlantFlagEnabled = false;
		//Colors.Tint( m_FlagPanel.m_PlantFlagButton.m_FlagIcon.m_Background, 0xCCCCCC, 100);
		
	}
	else
	{
		m_PlantFlagEnabled = true;
		//Colors.Tint( m_FlagPanel.m_PlantFlagButton.m_FlagIcon.m_Background, 0xCCCCCC, 0);
		
	}
	
    Log.Info2("PvPMiniScoreBoard","UpdatePlayerFlags capturedflags " + capturedflags + " returnedflags " + returnedflags);
    
    for (var i:Number = 0; i < m_PlayerMaxFlags; i++ )
    {
        if ( i < totalFlags)
        {
            m_TimerPanel["m_Dot_" + i]._alpha = 100;
        }
        else
        {
            m_TimerPanel["m_Dot_" + i]._alpha = m_DisabledAlpha;
        }
    }
}

/**
 * calculates and returns the max number of flags
 * @return Number - the max number of flags
 */
function GetMaxNumFlags() : Number
{
    var dragonCaptured:Number       = PvPMinigame.GetSideScore( _global.Enums.Factions.e_FactionDragon, SIDE_FLAGS );
    var templarCaptured:Number      = PvPMinigame.GetSideScore( _global.Enums.Factions.e_FactionTemplar, SIDE_FLAGS );
    var illuminatiCaptured:Number   = PvPMinigame.GetSideScore( _global.Enums.Factions.e_FactionIlluminati, SIDE_FLAGS );
        
    return Math.max( dragonCaptured, Math.max( templarCaptured, illuminatiCaptured) );
}


/**
 * Updates the flag tokens by resizing the bacground of the tokens, lay them out and highlight the dominant faction
 * @param	side:Number - the side to update
 */
function UpdateTokens( side:Number )
{
    var numTokens:Number =  PvPMinigame.GetSideScore( side, SIDE_FLAGS );
    
   
    Log.Info2("PvPMiniScoreBoard", "UpdateTokens() SIDE = " + side + ", numTokens = " + numTokens); 

	/// add the win state to panels
	if (numTokens == m_MaxFlags && m_PanelState == PANEL_STATE_NORMAL )
	{
		SetPanelStateDomination(side, true);
	}
	/// remove the win state from panels
	else if (numTokens < m_MaxFlags && m_DominationSide == side && m_PanelState == PANEL_STATE_DOMINATION)
	{
		SetPanelStateDomination(side, false);
	}
	
    var sideTokens:MovieClip = m_Sides[ side ].tokens;
    var tokenX:Number = 0
	if (m_Sides[ side ].tokenScore != numTokens)
	{
		m_Sides[ side ].tokenScore = numTokens;
		//Remove Existing ones
		// add the necessary flags, remove the unnecessary.
		for (var i:Number = 0; i < m_MaxFlags; i++ )
		{
			var token:MovieClip = sideTokens["token_" + i];
			if (token != undefined)
			{
				token.removeMovieClip();
			}
		}
		
		//Add the number of tokens you have
		for (var i:Number = 0; i < numTokens; i++)
		{
			var token:MovieClip = sideTokens.attachMovie( m_TokenLinkage, "token_" + i, sideTokens.getNextHighestDepth(), {_xscale:70, _yscale:70} );
			token._alpha = m_UnfocusedAlpha;

			com.Utils.Colors.ApplyColor(token, m_Sides[ side ].color );
			token._x = tokenX + (m_TokenSize * i);
			
			if (numTokens == m_MaxFlags)
			{
				token._alpha = 100;
				token.filters = m_FilterArray;
			}
		}
    }
}

/**
 * Updates the TokenPanel and TimerPanel, adding the leading team's color and, text and a timer
 * @param	side:Number				- The faction enum and index of m_Sides array
 * @param	isDominating:Boolean	- Add or the remove the dominationframe 
 */
function SetPanelStateDomination(side:Number, isDominating:Boolean)
{
	m_TokenPanel.m_PanelBackground.m_TintLayer._visible = isDominating
	m_TokenPanel.m_DominationText._visible = isDominating;
	
	m_TimerPanel.m_PanelBackground.m_TintLayer._visible = isDominating
	m_TimerPanel.m_DominationTimer._visible = isDominating;
	
	if (isDominating)
	{
		m_DominationSide = side;
		m_PanelState = PANEL_STATE_DOMINATION;
		
		// tokenpanel
		m_TokenPanel.m_PanelBackground._yscale = 120;
		Colors.ApplyColor( m_TokenPanel.m_PanelBackground.m_TintLayer, m_Sides[side].color);
		
		var sideName:String = com.Utils.Faction.GetName(side);
		var unFormattedFeedback:String = LDBFormat.LDBGetText("GenericGUI", "pvp_controlling_side");
		var formattedFeedback = LDBFormat.Printf( unFormattedFeedback, sideName, m_TokenName );
	
		m_TokenPanel.m_DominationText.htmlText = formattedFeedback;
		m_TokenPanel.m_DominationText.textColor =  m_Sides[side].textColor
		
		// timer panel
		m_TimerPanel.m_PanelBackground._yscale = 120;
		Colors.ApplyColor( m_TimerPanel.m_PanelBackground.m_TintLayer, m_Sides[side].color);
		m_TimerPanel.m_DominationTimer.textColor =  m_Sides[side].textColor
		
	
		if ( m_DominationTimerId == undefined )
        {
			m_DominationTimeStarted = Number(PvPMinigame.GetLastUpdateTimestamp());
			//m_TimerPanel.m_DominationTimer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", Math.floor(m_DominationTime / 60), Math.floor(m_DominationTime % 60) );
			OnDominationTimerUpdate();
	        m_DominationTimerId = setInterval( Delegate.create( this, OnDominationTimerUpdate ), m_DominationTimeRefreshSpeed );
        }
	}
	else
	{
		m_DominationSide = 0;
		m_PanelState = PANEL_STATE_NORMAL;
		m_TokenPanel.m_PanelBackground._yscale = 92;
		m_TimerPanel.m_PanelBackground._yscale = 92;
		
		if ( m_DominationTimerId != undefined )
        {
            clearInterval( m_DominationTimerId );
            m_DominationTimerId = undefined;
        }
	}
}

function OnDominationTimerUpdate()
{
	var timeLeft:Number = (m_DominationTimeStarted + m_DominationTime - Utils.GetServerSyncedTime());
	
	if ( timeLeft >= 0 )
    {
        m_TimerPanel.m_DominationTimer.text = com.Utils.Format.Printf( "%02.0f:%02.0f", Math.floor(timeLeft / 60), Math.floor(timeLeft % 60) );
    }
	else
	{
		clearInterval( m_DominationTimerId );
		m_DominationTimerId = undefined;
	}
}


/**
 * Called to clear teh graphics scores and flags when initializing and hiding
 * sets up the stage corresponding to the type of minigame
 */
function InitLayout() : Void
{
    m_UseDropFlags = (PvPMinigame.GetMatchType() == _global.Enums.MinigameType.e_CaptureTheFlagMinigame )  ? true : false;
	
    m_TokenName = LDBFormat.LDBGetText("GenericGUI", "relics");
    m_TokenLinkage = "Dot";
    m_FlagPanel.m_PlantFlagButton.m_Text.text = LDBFormat.LDBGetText("GenericGUI", "plant_relic");
   	
	m_TimerPanel.m_PanelBackground.m_TintLayer._visible = false;
	m_TokenPanel.m_PanelBackground.m_TintLayer._visible = false;
	m_FlagPanel.m_PanelBackground.m_TintLayer._visible = false;
	
	m_TimerPanel.m_DominationTimer._visible = false;
	m_TokenPanel.m_DominationText._visible = false;
	
    // remove score, tokens and points
    for (var prop in m_Sides )
    {
        var side:Object = m_Sides[ prop ];
        side.score.text = "0";
        var sideTokens:MovieClip = side.tokens;
        
        for (var i:Number = 0; i < m_MaxFlags; i++ )
        {
            var token:MovieClip = sideTokens["token_" + i];
            if (token)
            {
               token.removeMovieClip();
            }
        }
    }

    
    /// Remove player flags
    for (var j:Number = 0; j < m_PlayerMaxFlags; j++ )
    {
        m_FlagPanel["m_Flag_" + j]._alpha = m_DisabledAlpha;
    }

	UpdateFlags();
	
    if ( m_UseDropFlags )
    {
        m_FlagPanel._visible = true;
        m_FlagPanel.hitTestDisable = false;

    }
    else
    {
        m_FlagPanel._visible = false;
        m_FlagPanel.hitTestDisable = true;
    } 
    
    for (var i:Number = 0; i < m_PlayerMaxFlags; i++ )
    {
        m_TimerPanel["m_Dot_" + i]._visible = m_UseDropFlags;
      
    }
}

function SlotPlantFlag()
{
	PvPMinigame.PlantCTFFlags();
}

/**
 * Called when the PvPMinigame.SignalPvPMinigameScoreChanged signal is emitted.
 * Iterates the sides and gets their score, if  a score has changed, write the new values
 */
function SlotScoreChanged()
{
    for ( var i:Number = 1; i <= 3; i++ )
    {
        var sideScore:Number        = PvPMinigame.GetSideScore( i, SIDE_SCORE );
        var totalSideScore:Number   = PvPMinigame.GetTotalCharacterScore( i, 0 );

        Log.Info2("PvPMiniScoreBoard", "SlotScoreChanged() - sideScore: "+sideScore+", totalSideScore: " +totalSideScore);
        m_Sides[ i ].score.text = (sideScore + totalSideScore);
        UpdateTokens( i );
    }
}


function SlotMatchRemoved()
{
    UpdateVisibility();
}

function SlotMatchStarted()
{
    Log.Info2("PvPMiniScoreBoard", "SlotMatchStarted() " + PvPMinigame.GetMatchType() );
    UpdateVisibility();
}


function SlotMatchEnded()
{
    Log.Info2("PvPMiniScoreBoard", "SlotMatchEnded() ");
    UpdateVisibility();
}

function SlotMinigameStartsInXSeconds()
{
    Log.Info2("PvPMiniScoreBoard", "SlotMinigameStartsInXSeconds() "+PvPMinigame.GetMatchType());
    UpdateVisibility();
}

function SlotMatchWantsToStart()
{
    Log.Info2("PvPMiniScoreBoard", "SlotMatchWantsToStart()");
    UpdateVisibility();
}

