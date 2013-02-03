//Imports
import mx.utils.Delegate;
import com.GameInterface.PlayerDeath;
import com.GameInterface.Log;
import com.GameInterface.Utils;
import com.GameInterface.Game.Character;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.Utils.LDBFormat;

//Constants
var AUTO_SELECT_TIMER:Number = 120;
var FVF_PLAYFIELD_ID:Number = 34171;
var DROPDOWN_MARGIN:Number = 40;

var m_TDB_ReleaseNow:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_ReleaseNow");
var m_TDB_Respawn:String =  LDBFormat.LDBGetText("GenericGUI", "DeathWindow_Respawn");
var m_TDB_RespawnQuestion:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_RespawnQuestion");
var m_TDB_GMResurrect:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_GMResurrect");
var m_TDB_In:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_In");
var m_TDB_Seconds:String = LDBFormat.LDBGetText("Gamecode", "Seconds");
var m_TDB_yes:String = LDBFormat.LDBGetText("Gamecode", "Yes");
var m_TDB_No:String = LDBFormat.LDBGetText("Gamecode", "No");
var m_TDB_PhysicalExhaustion:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_PhysicalExhaustion");
var m_TDB_AnimaFormMessage:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_AnimaReleaseMessage");
var m_TDB_Resurrect:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_Resurrect");
var m_TDB_ResurrectQuestion:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_ResurrectQuestion");
var m_TDB_ResurrectWithHelpQuestion:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_ResurrectWithHelpQuestion");
var m_TDB_SignUpMessage:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_SignUpMessage");
var m_TDB_SignUp:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_SignUp");
var m_TDB_SelectAnimaWellMessage:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_SelectAnimaWellMessage");
var m_TDB_RespawnWave:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_RespawnWave");
var m_TDB_MeterAbbreviation:String = LDBFormat.LDBGetText("GenericGUI", "DeathWindow_MeterAbbreviation");

//Properties
var m_AnimaWellArray:Array;

var m_StartTime:Number;
var m_Countdown:Number;
var m_CountdownInterval:Number;
var m_GhostingInterval:Number;

var m_DropdownMenu:MovieClip;
var m_DataWellArray:Array;
var m_AnimaWell:String;

var m_CurrentWindow:MovieClip;
var m_FeedbackClip:MovieClip;

var m_ShowingTombstone:Boolean;

//On Load
function onLoad():Void
{
    PlayerDeath.SignalPlayerCharacterDead.Connect(SlotPlayerCharacterDead, this);
    PlayerDeath.SignalPlayerCharacterAlive.Connect(SlotPlayerCharacterAlive, this);
	PlayerDeath.SignalResurrectRequest.Connect(SlotResurrectRequest, this);
	PlayerDeath.SignalNewAnimaWell.Connect(SlotNewAnimaWell, this);
	PlayerDeath.SignalNoAnimaWell.Connect(SlotNoAnimaWell, this);
	PlayerDeath.SignalAnimaWellIsClose.Connect(SlotAnimaWellIsClose , this);
	PlayerDeath.SignalAnimaWellIsGone.Connect(SlotAnimaWellIsGone, this);
	PlayerDeath.SignalTombstoneIsClose.Connect(SlotTombstoneIsClose, this);
	PlayerDeath.SignalTombstoneIsGone.Connect(SlotTombstoneIsGone, this);
    
    m_ShowingTombstone = false;
	m_GhostingInterval = undefined;
    
    Log.Info2("DeathWindowController", "onLoad")

    ResizeHandler();
    
  	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF("GenericHideModule");
  	moduleIF.SignalStatusChanged.Connect(SlotHideModuleStateUpdated, this);
    SlotHideModuleStateUpdated(moduleIF, moduleIF.IsActive());

	var mouseListener:Object = new Object();
    
	mouseListener.onMouseDown = function(button:Number, target)
	{
		if (m_CurrentWindow != undefined && !m_CurrentWindow.hitTest(_root._xmouse, _root._ymouse, true))
		{
			PlayerDeath.MouseButton(button, true);
		}
	}
    
	mouseListener.onMouseUp = function(button:Number, target)
	{
		if (m_CurrentWindow != undefined)
		{
			PlayerDeath.MouseButton(button, false);
		}
	}
    
	Mouse.addListener(mouseListener);

   /*
    *  get current state (we might be dead! zomg!)
    * 
    */
    
	if (PlayerDeath.PlayerIsDead())
	{
		SlotPlayerCharacterDead(PlayerDeath.DoWaveRespawn());
	}
}

//Slot Hide Module State Updated
function SlotHideModuleStateUpdated(module:GUIModuleIF, isActive:Boolean):Void
{
	if (m_CurrentWindow != undefined)
	{
		m_CurrentWindow._visible=isActive;
	}
}

//Create Clip
function CreateClip(windowID:String, windowName:String):Void
{
    CloseWindow(false);
    
    var clipName:String = "DeathWindow_" + UID();
	
	GUIModuleIF.CloseFullscreenModule();
    
    m_CurrentWindow = this.attachMovie(windowID, windowName, this.getNextHighestDepth());
}

//Get Anima Well Array
function GetAnimaWellArray():Array
{
    m_DataWellArray = PlayerDeath.GetAnimaWellArray();
    
   /*
    *  If C++ hasn't sorted the array by m_DistanceInMeters
    *  uncomment the following line to sort the array with
    *  ActionScript.
    * 
    */
   
    //m_DataWellArray.sortOn("m_DistanceInMeters", Array.NUMERIC);
    
    m_AnimaWellArray = new Array();
    
    for (var i:Number = 0; i < m_DataWellArray.length; i++)
    {
        m_AnimaWellArray.push(m_DataWellArray[i].m_Name + " (" + Math.round(m_DataWellArray[i].m_DistanceInMeters) + m_TDB_MeterAbbreviation + ")");
    }
    
    return m_AnimaWellArray;
}

//Slot Player Character Alive
function SlotPlayerCharacterAlive():Void
{
    CloseWindow(false);
}

//Respawn Wave Sign Up
function RespawnWaveSignUp():Void
{
    clearInterval(m_CountdownInterval);
    PlayerDeath.SignupForRespawnPoint(PlayerDeath.GetAnimaWellArray()[0].m_Id);
    if (!PlayerDeath.SignalRespawnWaveTimeUpdate.IsSlotConnected(SlotRespawnWaveTimeUpdate, this))
    {
        PlayerDeath.SignalRespawnWaveTimeUpdate.Connect(SlotRespawnWaveTimeUpdate, this);
    }
    
    m_CurrentWindow.i_Header.htmlText = m_TDB_RespawnWave;
	if (m_AnimaWell == undefined)
	{
		m_AnimaWell = PlayerDeath.GetAnimaWellArray()[0].m_Name
	}
    m_CurrentWindow.i_InfoText.htmlText = LDBFormat.Printf(m_TDB_AnimaFormMessage, m_AnimaWell);
    m_CurrentWindow.i_Countdown._visible = true;
    
    m_CurrentWindow.i_ReleaseButton._alpha = 50;
    m_CurrentWindow.i_ReleaseButton.enabled = false;
    m_CurrentWindow.i_ReleaseFeedback.gotoAndStop("Neutral_Green");
}

//Slot Respawn Wave Time Update
function SlotRespawnWaveTimeUpdate(timeLeft:Number):Void
{
    m_CurrentWindow.i_Countdown.text = m_TDB_In + " " + timeLeft + " " + m_TDB_Seconds;
}

//Slot Player Character Dead
function SlotPlayerCharacterDead(wait:Boolean):Void
{
    CreateClip("BigWindow", "i_BigWindow");

    m_FeedbackClip = m_CurrentWindow.i_ReleaseFeedback;
    
    m_CurrentWindow.i_Header.htmlText = m_TDB_PhysicalExhaustion;
    m_CurrentWindow.i_ReleaseButton.enabled = true;
    m_CurrentWindow.i_ReleaseButton.onRollOver = Delegate.create(this, MouseOverPositiveHandler);
    m_CurrentWindow.i_ReleaseButton.onRollOut = Delegate.create(this, MouseOutPositiveHandler);
    m_CurrentWindow.i_ReleaseButton._alpha = 100;
        
    if (wait)
    {
        m_CurrentWindow.i_InfoText.htmlText = m_TDB_SignUpMessage;
        m_CurrentWindow.i_Countdown._visible = false;
        m_CurrentWindow.i_ReleaseButton.onRelease = Delegate.create(this, RespawnWaveSignUp);
        m_CurrentWindow.i_ReleaseButton.i_ReleaseText.text = m_TDB_SignUp;
        
        m_StartTime = getTimer();
        clearInterval(m_CountdownInterval);
        m_CurrentWindow.i_Countdown._visible = true;
        m_CountdownInterval = setInterval(Delegate.create(this, CountdownSignIn), 1000);        
    }
    else
    {
        m_CurrentWindow.i_InfoText.htmlText = m_TDB_SelectAnimaWellMessage;
            
        m_DropdownMenu = m_CurrentWindow.attachMovie("LightDropdownMenu", "m_DropdownMenu", m_CurrentWindow.getNextHighestDepth());
        m_DropdownMenu.direction = "down";
        m_DropdownMenu.dropdown = "LightScrollingList";
        m_DropdownMenu.itemRenderer = "LightListItemRenderer";
        m_DropdownMenu.setSize(m_CurrentWindow._width - DROPDOWN_MARGIN * 2, 20);
        m_DropdownMenu._x = DROPDOWN_MARGIN;
        m_DropdownMenu._y = m_CurrentWindow.i_Countdown._y - 43;
        m_DropdownMenu.dataProvider = GetAnimaWellArray();
        m_DropdownMenu.rowCount = m_AnimaWellArray.length;
        m_DropdownMenu.selectedIndex = 0;
        
        m_CurrentWindow.i_ReleaseButton.i_ReleaseText.text = m_TDB_ReleaseNow;
        m_CurrentWindow.i_ReleaseButton.onRelease = Delegate.create(this, ReleaseAnimaForm);

        m_StartTime = getTimer();
        
        clearInterval(m_CountdownInterval);
        CountdownRespawn();
        
        m_CountdownInterval = setInterval(Delegate.create(this, CountdownRespawn), 1000);
    }
    
    var gmlevel:Number = Character.GetClientCharacter().GetStat(Enums.Stat.e_GmLevel, 2);
    
    if (gmlevel != 0)
    {
        m_CurrentWindow.m_GMButton._visible = true;
        m_CurrentWindow.m_GMButton.textField.text = m_TDB_GMResurrect;
        m_CurrentWindow.m_GMButton.onRollOver = function() {this.gotoAndStop("over");};
        m_CurrentWindow.m_GMButton.onRollOut = function() {this.gotoAndStop("out");};
        m_CurrentWindow.m_GMButton.onRelease =  Delegate.create(this, GMResurrect)
    }
    else
    {
        m_CurrentWindow.m_GMButton._visible = false;
    }
    
    CenterWindow();
}

//Slot Anima Well Is Close
function SlotAnimaWellIsClose()
{
    CreateClip("SmallWindow", "i_WindowWellClose");
    
    m_CurrentWindow.i_Header.htmlText = m_TDB_Respawn;
    m_CurrentWindow.i_InfoText.htmlText = m_TDB_RespawnQuestion;
    m_CurrentWindow.i_YesButton.i_YesText.text = m_TDB_yes;
    m_CurrentWindow.i_NoButton.i_NoText.text = m_TDB_No;
    
    m_FeedbackClip = m_CurrentWindow.i_ReleaseFeedback;
    
    m_CurrentWindow.i_YesButton.onRollOver = Delegate.create(this, MouseOverPositiveHandler);
    m_CurrentWindow.i_YesButton.onRollOut = Delegate.create(this, MouseOutPositiveHandler);
    
    m_CurrentWindow.i_NoButton.onRollOver = Delegate.create(this, MouseOverNegativeHandler);
    m_CurrentWindow.i_NoButton.onRollOut = Delegate.create(this, MouseOutNegativeHandler);
    
    m_CurrentWindow.i_NoButton.onRelease = Delegate.create(this, Decline);
    m_CurrentWindow.i_YesButton.onRelease = Delegate.create(this, Resurrect);

    CenterWindow();
}

//Resize Handler
function ResizeHandler():Void
{
    _x = Stage["visibleRect"].x;
    _y = Stage["visibleRect"].y;
}

//Slot Resurrect Request
function SlotResurrectRequest(name:String, spell:String)
{
    CreateClip("SmallWindow", "i_ResurrectRequest");
    
    m_CurrentWindow.i_Header.htmlText = m_TDB_Resurrect
    m_CurrentWindow.i_InfoText.htmlText = LDBFormat.Printf(m_TDB_ResurrectWithHelpQuestion, name);
    m_CurrentWindow.i_YesButton.i_YesText.text = m_TDB_yes;
    m_CurrentWindow.i_NoButton.i_NoText.text = m_TDB_No;
    
    m_FeedbackClip = m_CurrentWindow.i_ReleaseFeedback;
    
    m_CurrentWindow.i_YesButton.onRollOver = Delegate.create(this, MouseOverPositiveHandler);
    m_CurrentWindow.i_YesButton.onRollOut = Delegate.create(this, MouseOutPositiveHandler);
    
    m_CurrentWindow.i_NoButton.onRollOver = Delegate.create(this, MouseOverNegativeHandler);
    m_CurrentWindow.i_NoButton.onRollOut = Delegate.create(this, MouseOutNegativeHandler);
    
    m_CurrentWindow.i_NoButton.onRelease = Delegate.create(this, DeclineResurrect);
    m_CurrentWindow.i_YesButton.onRelease = Delegate.create(this, AcceptResurrect);

    CenterWindow();
}

//Slot Tombstone Is Close
function SlotTombstoneIsClose():Void
{
    if (m_ShowingTombstone)
    {
        return;
    }
	var player:Character = Character.GetClientCharacter();
	if (player != undefined)
	{
		player.SignalStatChanged.Connect(SlotStatChanged, this);
	}

    CreateClip("SmallWindow","i_WindowTombstoneClose");
    m_ShowingTombstone = true;
    
    m_CurrentWindow.i_Header.htmlText = m_TDB_Resurrect
    m_CurrentWindow.i_InfoText.htmlText = m_TDB_ResurrectQuestion;
    m_CurrentWindow.i_YesButton.i_YesText.text = m_TDB_yes;
    m_CurrentWindow.i_NoButton.i_NoText.text = m_TDB_No;
    
    m_FeedbackClip = m_CurrentWindow.i_ReleaseFeedback;
    
    m_CurrentWindow.i_YesButton.onRollOver = Delegate.create(this, MouseOverPositiveHandler);
    m_CurrentWindow.i_YesButton.onRollOut = Delegate.create(this, MouseOutPositiveHandler);
    
    m_CurrentWindow.i_NoButton.onRollOver = Delegate.create(this, MouseOverNegativeHandler);
    m_CurrentWindow.i_NoButton.onRollOut = Delegate.create(this, MouseOutNegativeHandler);
    
    m_CurrentWindow.i_NoButton.onRelease = Delegate.create(this, Decline);
    m_CurrentWindow.i_YesButton.onRelease = Delegate.create(this, ClearGhosting);

    CenterWindow();
}

function SlotStatChanged(statId:Number)
{
	if (m_ShowingTombstone && statId == _global.Enums.Stat.e_PlayerFlags)
	{
		var player:Character = Character.GetClientCharacter();
		if (player != undefined && !player.IsGhosting())
		{
			CloseWindow(false);
		}
	}
}

//Slot New Anima Well
function SlotNewAnimaWell(well:String):Void
{
    if (well != "")
    {
        m_AnimaWell = "(" + well + ") ";
    }
    else
    {
        m_AnimaWell = "";
    }
}

//Slot No Anima Well
function SlotNoAnimaWell():Void
{
    m_AnimaWell = "";
}

//Slot Anima Well Is Gone
function SlotAnimaWellIsGone():Void
{
    if (m_CurrentWindow.i_WindowWellClose != undefined)
    {
        CloseWindow(false);
    }
}

//Slot Tombstone Is Gone
function SlotTombstoneIsGone():Void
{
    if (m_ShowingTombstone)
    {
        CloseWindow(false);
    }
}

//Center Window
function CenterWindow():Void
{
    m_CurrentWindow._xscale = 80;
    m_CurrentWindow._yscale = 80;
    m_CurrentWindow._x = (Stage.width / 2) - (m_CurrentWindow._width / 2);
    m_CurrentWindow._y = (Stage.height / 2) - (m_CurrentWindow._height / 2);
}

//Mouse Over Positive Handler
function MouseOverPositiveHandler():Void
{
    m_FeedbackClip.gotoAndPlay("Neutral_Green");
}

//Mouse Over Negative handler
function MouseOverNegativeHandler():Void
{
    m_FeedbackClip.gotoAndPlay("Neutral_Red");
}

//Mouse Out Positive Handler
function MouseOutPositiveHandler():Void
{
    m_FeedbackClip.gotoAndPlay("Green_Neutral");
}

//Mouse Out Negative Handler
function MouseOutNegativeHandler():Void
{
    m_FeedbackClip.gotoAndPlay("Red_Neutral");
}

//Countdown Respawn
function CountdownRespawn():Void
{
    if ( m_CurrentWindow != undefined )
    {
        m_Countdown = AUTO_SELECT_TIMER - (Math.round((getTimer() - m_StartTime) / 1000));
        m_CurrentWindow.i_Countdown.text = m_TDB_In + " " + m_Countdown + " " + m_TDB_Seconds;

        if (m_Countdown <= 0)
        {
            clearInterval(m_CountdownInterval);
            ReleaseAnimaForm();
        }
    }
}

//Countdown Respawn
function CountdownSignIn():Void
{
    if ( m_CurrentWindow != undefined )
    {
        m_Countdown = AUTO_SELECT_TIMER - (Math.round((getTimer() - m_StartTime) / 1000));
        m_CurrentWindow.i_Countdown.text = m_Countdown + " " + m_TDB_Seconds;

        if (m_Countdown <= 0)
        {
            clearInterval(m_CountdownInterval);
            RespawnWaveSignUp();
        }
    }
}

//GM Resurrect
function GMResurrect():Void
{
    clearInterval(m_CountdownInterval);
    Log.Info2("DeathWindowController", "GM Resurrect");
    CloseWindow(false);
    PlayerDeath.ResurrectGm();
}

//Release Anima Form
function ReleaseAnimaForm():Void
{
    clearInterval(m_CountdownInterval);
    Log.Info2("DeathWindowController", "Releasing Anima Form");
    CloseWindow(false);
    
    if (!PvPMinigame.InMatchPlayfield() || PvPMinigame.GetMatchType() == _global.Enums.MinigameType.e_FactionVsFaction)
    {
        Resurrect(m_DataWellArray[m_DropdownMenu.selectedIndex].m_Id);
    }
    else
    {
        Resurrect(PlayerDeath.GetAnimaWellArray()[0].m_Id);
    }
}

//Decline
function Decline():Void
{
    Log.Info2("DeathWindowController", "Decline respawning");
    CloseWindow(true);
}

//Accept Resurrect
function AcceptResurrect():Void
{
    CloseWindow(false);
    PlayerDeath.ResurrectRequestAccept();
}

//Decline Resurrect
function DeclineResurrect():Void
{
    Log.Info2("DeathWindowController", "Decline resurrect");
    CloseWindow(true);
    PlayerDeath.ResurrectRequestReject();
}

//Resurrect
function Resurrect(respawnPoint:Number):Void
{
    Log.Info2("DeathWindowController", "Resurrect");
    CloseWindow(false);
    PlayerDeath.Resurrect(respawnPoint);
}

//Clear Ghosting
function ClearGhosting():Void
{
    Log.Info2("DeathWindowController", "ClearGhosting");
    CloseWindow(false);
    PlayerDeath.ClearGhosting();
}

//Slot Clear Ghosting Timeout
function SlotClearGhostingTimeout():Void
{
	var player:Character = Character.GetClientCharacter();
	if (player != undefined)
	{
		player.SignalStatChanged.Disconnect(SlotStatChanged, this);
	}
	
    m_ShowingTombstone = false;
    clearInterval(m_GhostingInterval);
	m_GhostingInterval = undefined;
}

//Close Window
function CloseWindow(declined:Boolean):Void
{
    if (m_CurrentWindow != undefined)
    {
        if (m_ShowingTombstone)
        {
            if (declined)
            {
                /*
                 *  Since the close to tombstone is spamming, we need to wait
                 *  for a second to "Close" the tombstone window, as it would
                 *  show another one before actually clearing the ghosting.
                 * 
                 */
            
                if (m_GhostingInterval == undefined)
                {
                    m_GhostingInterval = setInterval(Delegate.create(this, SlotClearGhostingTimeout), 5000);
                }
            }
            else
            {
                SlotClearGhostingTimeout();
            }
        }
	
        if (PlayerDeath.SignalRespawnWaveTimeUpdate.IsSlotConnected(SlotRespawnWaveTimeUpdate, this))
        {
            PlayerDeath.SignalRespawnWaveTimeUpdate.Disconnect(SlotRespawnWaveTimeUpdate, this);
        }
        
        clearInterval(m_CountdownInterval);
        GUIFramework.SFClipLoader.RemoveClipNode(this);
    
        m_CurrentWindow.removeMovieClip();
		m_CurrentWindow = undefined;
    }
}
