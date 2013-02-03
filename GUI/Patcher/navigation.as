import flash.filters.DropShadowFilter;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import com.PatcherInterface.Patcher;
import gfx.core.UIComponent;
import com.Utils.Colors;
import GUI.Patcher.PromptContainer
import gfx.motion.Tween;
//import gfx.controls.Button;

/***********************************************************************************************
*									DISABLING FOCUS AND TABENABLING			   		   		   *
***********************************************************************************************/
//disabling tab-navigation
this.tabChildren = false;

/***********************************************************************************************
* 											TEXT LABELS								   		   *
***********************************************************************************************/
var m_TDB_corrupted_resource_database_prompt:String = "$Patcher:corruptResourceDatabase_textLabel";
var m_TDB_compact_resource_files:String = "$Patcher:compactResourceFiles_textLabel";

var m_TDB_yes:String = "$Patcher:yes_textLabel";
var m_TDB_no:String = "$Patcher:no_textLabel";
//var m_TDB_ok:String = "$Patcher:ok_textLabel"; // unused?
//var m_TDB_cancel:String = "$Patcher:cancel_textLabel"; /// unused

var m_TDB_exit_prompt:String = "$Patcher:exitPrompt_text";
var m_TDB_accept:String = "$Patcher:accept_textLabel";
var m_TDB_decline:String = "$Patcher:decline_textLabel";

var m_DisabledAlpha:Number = 50;
var m_EnabledAlpha:Number = 100;

//var m_Shadow:DropShadowFilter;

var m_QuitPrompt:PromptContainer;

/***********************************************************************************************
* 									STATES & COORDINATES					   		  		   *
***********************************************************************************************/

var m_ItemStoreURL:String = "http://www.thesecretworld.com/itemstore/";
var m_RegisterURL:String = "https://register.thesecretworld.com";
var m_EULAURL:String = "http://msgs.ageofconan.com/eula.php?Format=html&UniverseName=";


//toggles
var m_IsEULAActivated:Boolean = false;
var m_IsPatchingDone:Boolean = false;
var m_IsStartButtonClicked:Boolean = false;
var m_IsClosePatcherDialogOpen:Boolean = false;
var m_FatalErrorOccurred:Boolean = false;

/***********************************************************************************************
* 										DRAG PATCHER WINDOW						   		   	                                 *
***********************************************************************************************/
var m_MouseDownX:Number = 0;
var m_MouseDownY:Number = 0;
var m_WasHitByMouse:Boolean = false;


/***********************************************************************************************
* 									     FUNCTIONS										   	                                     *
***********************************************************************************************/
// for testing it

/// init
function onLoad()
{
  //  m_Shadow = new DropShadowFilter( 1, 35, 0x000000, 0.7, 1, 2, 2, 3, false, false, false );
    
    SetBackgroundDragOperations();
    
    SetGlobalKeyListeners();
    
    m_AccountButton.label = "$Patcher:account_buttonLabel";
    m_AccountButton.addEventListener("click", this, "GoToAccount");
    
    m_ItemStoreButton.label = "$Patcher:ItemStore";
    m_ItemStoreButton.addEventListener("click", this, "GoToItemStore");
    
    m_InfoButton.label = "$Patcher:Info_textLabel";
    m_InfoButton.addEventListener("click", this, "WindowHandler");

    m_NotesButton.label = "$Patcher:patchNotes_textLabel"; 
    m_NotesButton.addEventListener("click", this, "WindowHandler");
    
    m_OptionsButton.label = "$Patcher:options_buttonLabel";
    m_OptionsButton.addEventListener("click", this, "WindowHandler");
    
    ///initialize the tween
    Tween.init();
    
    // panels and stuff
    m_Options._visible = false;
    m_EULA._visible = false;
    m_StartButton._visible = false
    m_StartButton.textField.text = "$Patcher:StartGame";
    m_Notes._visible = false;
    m_Info._visible = false;
    
    m_ProgressComponent.m_InfoText.text = "$Patcher:cancel_infoText";
    m_PromptContainer._visible = false;
    
    m_EULA.m_AcceptButton.label = m_TDB_accept;
    m_EULA.m_AcceptButton.addEventListener("click", this, "UELAAccepted");
   // RegisterButton( m_EULA.m_AcceptButton, this, "UELAAccepted");
    
    m_EULA.m_DeclineButton.label = m_TDB_decline;
    m_EULA.m_DeclineButton.addEventListener("click", this, "UELADeclined");
    
    RegisterButton( i_ExitPatcherButton, this, "QuitPatcherActivated");
    RegisterButton( i_MinimizePatcherButton, this, "MinimizePatcher");
    
    Patcher.SignalPatchingDone.Connect( SlotPatcherDone, this );
    Patcher.SignalRDBStatusChanged.Connect( SlotRDBStatusChanged, this );
    
    OpenWindow( m_Notes, m_NotesButton);
    
}

function RegisterButton(button:MovieClip, scope:Object, method:String) : Void
{
    button["disabled"] = false;
    button["method"] = method;
    button["scope"] = scope;
    button["selected"] = false;
    
    button.onRollOver = function()
    {
        if (!this.disabled)
        {
            this.gotoAndPlay("over");
        }
    }
    
    button.onRollOut = button.onReleaseOutside = function()
    {
        if (!button.selected)
        {
            this.gotoAndPlay("up");
        }
    }
    
    button.onRelease = function()
    {
        if (!this.disabled)
        {
            this["scope"][this.method]( { target:this } );
        }
        this.gotoAndPlay("up");
    }
}

function SetGlobalKeyListeners() : Void
{
    var keyListener:Object = new Object();
    keyListener.onKeyDown = function()
    {
        switch (Key.getCode()) 
        {
            /* Just a snippet of testcode. Please leave
            case Key.DOWN:
                OpenWindow(m_StartButton);

                m_ProgressComponent.tweenTo(0.5, { _alpha:0 }, None.easeNone);
                m_ProgressComponent.onTweenComplete = undefined;
            break;
            */
            case Key.ESCAPE:
                if ( !i_ExitPatcherButton.disabled && !m_IsClosePatcherDialogOpen )
                {
                    QuitPatcherActivated();
                }
            break;
            case Key.TAB:
                OptionsWindowsViewHandler();
            break;
        }
    }
    
    Key.addListener(keyListener);
}

function SetBackgroundDragOperations() : Void
{
    m_Background.onPress = function()
    {
        m_MouseDownX = _xmouse;
        m_MouseDownY = _ymouse;

        m_WasHitByMouse = true;
        Patcher.BeginMoveWindow();
    }

    m_Background.onMouseUp = function()
    {
        if ( m_WasHitByMouse )
        {
            m_WasHitByMouse = false;
            Patcher.EndMoveWindow();
        }
    }

    m_Background.onMouseMove = function()
    {
        if ( m_WasHitByMouse )
        {
            var deltaX:Number = _xmouse - m_MouseDownX;
            var deltaY:Number = _ymouse - m_MouseDownY;
            Patcher.MoveWindow( deltaX, deltaY );
        }
    }
}

function GoToItemStore(event:Object)
{
    Patcher.ShowExternalURL( m_ItemStoreURL );
}

/// call the accouunt settings website
function GoToAccount()
{
  Patcher.ShowExternalURL( m_RegisterURL );
}

/// WINDOW Handler
function WindowHandler(event:Object)
{
    var button:MovieClip = event.target;
//    button.gotoAndPlay("over");
    var window:MovieClip;
    trace( "button = " + button + ", m_InfoButton = " + m_InfoButton+", m_NotesButton = "+ m_NotesButton+", m_OptionsButton = "+ m_OptionsButton);
    switch(button)
    {
        case m_InfoButton:
            window = m_Info;
        break;
        case m_NotesButton:
            window = m_Notes;
        break;
        case m_OptionsButton:
            window = m_Options;
        break;
        default:
            return;
    }
    
    trace("window._visible = " + window._visible+" window = "+window);
    
    if ( !window._visible )
    {
        OpenWindow(window, button);
    }
    else
    {
        CloseWindow(window, button);
        
        if (m_IsEULAActivated && !m_EULA._visible)
        {
            OpenWindow(m_EULA);
        }
       //trace(ClientLog.txt.enable)
        if (!m_IsStartButtonClicked && m_IsPatchingDone && !m_StartButton._visible && !m_FatalErrorOccurred)
        {
            OpenWindow(m_StartButton);
            m_ProgressComponent.tweenTo(0.5, { _alpha:100 }, None.easeNone);
            m_ProgressComponent.onTweenComplete = undefined;
        }
    }
}

/// when patching is done
function SlotPatcherDone(succeded:Boolean)
{
	if (succeded)
	{
		StartButtonActivation();
	}
	else
	{
		m_FatalErrorOccurred = true;
	}
    m_IsPatchingDone = true;
}

/// startbutton
function StartButtonActivation()
{
  //  OpenWindow(m_StartButton);
    m_StartButton._alpha = 0;
    m_StartButton._visible = true;
    m_StartButton.tweenTo(1, { _alpha: m_EnabledAlpha}, None.easeNone); 
    m_StartButton.onTweenComplete = function()
    {
        m_StartButton.hitTestDisable = false;
    }
    m_StartButton.onRelease = Delegate.create(this, StartButtonEventHandler);
    m_StartButton.gotoAndPlay("out");
    
    m_ProgressComponent.tweenTo(0.5, { _alpha:0 }, None.easeNone);
    m_ProgressComponent.onTweenComplete = undefined;
        
}


function StartButtonDeactivation()
{
    CloseWindow(m_StartButton);
    m_ProgressComponent.tweenTo(0.5, { _alpha:100 }, None.easeNone);
    m_ProgressComponent.onTweenComplete = undefined;
}


function StartButtonEventHandler()
{
    if ( !m_StartButton.disabled )
    {
        m_IsStartButtonClicked = true;
        StartButtonDeactivation();
        if ( Patcher.GetShowEULAFlag() )
        {    
            m_IsEULAActivated = true;
            Patcher.SignalEULADownloaded.Connect(  SlotEULATextUpdated );
            if ( Patcher.RequestEULA( m_EULAURL ) )
            {
                SlotEULATextUpdated( Patcher.GetEULAText() );
            }
        }
        else
        {
            Patcher.StartGame();
        }

        OpenWindow(m_EULA);
    }
}



///
/// GENERIC OPEN AND CLOSE METHODS
///
function OpenWindow(window:MovieClip, button:MovieClip)
{
    trace("Openwindow");
    /// close any other window that might be opemn
    CloseAllWindows(window, button);

    if (button)
    {
        trace(button + " is selected ");
        button.selected = true;
  //      button.gotoAndPlay("over"); // only for non scaleform buttons
    }
  /*    */ 
    /// create the tween to tween the currently selected window in
    window._alpha = 0;
    window._visible = true;
    window.tweenTo(1, { _alpha: m_EnabledAlpha}, None.easeNone); 
    window.onTweenComplete = function()
    {
        this.hitTestDisable = false;
    }
}

function CloseWindow( window:MovieClip, button:MovieClip )
{
    trace("CloseWindow")
    if (button)
    {
        trace(button+" is de selected ")
        button.selected = false;
//        button.gotoAndPlay("up");
        //button.state = "up";
    }
  /*    */
    window.tweenTo(0.5, { _alpha: 0 }, None.easeNone); 
    window.onTweenComplete = function()
    {
        this._visible = false;
        this.hitTestDisable = true;
    }
}

function CloseAllWindows(window:MovieClip)
{
    if ( m_Notes._visible && (window != m_Notes) )
    {
        CloseWindow(m_Notes, m_NotesButton)
    }
    
    if ( m_Options._visible && (window != m_Options) )
    {
        CloseWindow(m_Options, m_OptionsButton)
    }
    
    if ( m_Info._visible && (window != m_Info) )
    {
        CloseWindow(m_Info, m_InfoButton)
    }
    
    if ( m_EULA._visible && (window != m_EULA) )
    {
        CloseWindow(m_EULA)
    }
    
    if (m_ProgressComponent._visible && (window != m_ProgressComponent) && m_IsPatchingDone)
    {
        CloseWindow(m_ProgressComponent);
    }
    
    if (m_IsStartButtonClicked && !m_StartButton._visible)
    {
        StartButtonActivation();
    }
}



function SlotEULATextUpdated(txt:String){
  
  var eula_css = new TextField.StyleSheet();
  
  eula_css.onLoad = function(success:Boolean)
  {
    if (success)
    {
        m_EULA.m_TextArea.textField.styleSheet = eula_css;
        m_EULA.m_TextArea.html = true;
        m_EULA.m_TextArea.htmlText = UpdateHRefTags( txt );
    }
    else
    {
        m_EULA.m_TextArea.htmlText = "css failed to load!";
    }
  }

  eula_css.load("eula.css");
}

/// Licence accepted, proceed
function UELAAccepted()
{
    Patcher.StartGame();
}

/// Licence not accepted
function UELADeclined()
{
    QuitPatcherActivated();
}

function UpdateHRefTags( src:String )
{
    var dst:String = "";

    var tagStart:Number = 0;
    var currentQuote:String = "";
    var isInTag:Boolean = false;


    var lowercaseSrc = src.toLowerCase();

    var i:Number = 0;
    while( true )
    {
        tagStart = lowercaseSrc.indexOf( "<a", i );
        if ( tagStart >= 0 )
        {
            tagStart = lowercaseSrc.indexOf( "href", tagStart + 2 );
            if ( tagStart >= 0 )
            {
                tagStart += 4;
                while( lowercaseSrc.charAt( tagStart ) == ' ' || lowercaseSrc.charAt( tagStart ) == '\t' ) tagStart++;
                
                if ( lowercaseSrc.charAt( tagStart ) == '=' )
                {
                    tagStart += 1;
                    while ( lowercaseSrc.charAt( tagStart ) == ' ' || lowercaseSrc.charAt( tagStart ) == '\t' ) tagStart++;
                    
                    if ( lowercaseSrc.charAt( tagStart ) == '"' || lowercaseSrc.charAt( tagStart ) == "'" )
                    {
                        tagStart += 1;
                    }
                    dst += src.substring( i, tagStart );
                    i = tagStart;
                    dst += "asfunction:_root.patcher.HyperLinkClicked,";
                }
            }
        }
        else
        {
            dst += src.substring( i );
            break;
        }
    }
    return dst;
}

function HyperLinkClicked( target:String )
{
  Patcher.ShowExternalURL( target );
}

function MinimizePatcher(e:Object)
{
    Patcher.MinimizeWindow();
}

/// 
function QuitPatcherActivated() : Void
{
    var width:Number = 350;
    var height:Number = 200;
    m_QuitPrompt = new PromptContainer(m_TDB_exit_prompt, m_TDB_yes, m_TDB_no, QuitPatcherHandler, this, "i_QuitPrompt", height, width, 45);
    var promptwindow:MovieClip = m_QuitPrompt.Get();
    promptwindow._x = (Stage.width * 0.5) - (width * 0.5); 
    promptwindow._y = (Stage.height * 0.5) - (height * 0.5);
    m_IsClosePatcherDialogOpen = true;
	DisableButtons();

}

function QuitPatcherHandler( buttonState:Number ) : Void 
{
    m_IsClosePatcherDialogOpen = false;
    if (buttonState == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        Patcher.Cancel();
    }
    else
    {
        EnableButtons();
        m_QuitPrompt.Close();
    }
}

function ButtonHandler(disable:Boolean)
{
    var alpha:Number = (disable) ? m_DisabledAlpha : m_EnabledAlpha;
    
    i_ExitPatcherButton.disabled = disable;
    i_ExitPatcherButton._alpha = alpha;
    m_AccountButton.disabled = disable;
    m_AccountButton._alpha = alpha;
    m_InfoButton.disabled = disable;
    m_InfoButton._alpha = alpha;
    m_NotesButton.disabled = disable;
    m_NotesButton._alpha = alpha;
    m_OptionsButton.disabled = disable;
    m_OptionsButton._alpha = alpha;
    m_StartButton.disabled = disable;
    m_StartButton._alpha = alpha;
    m_Options.m_RepairBrokenDataButton.disabled = disable;
    m_Options.m_ApplyButton.disabled = disable;
    m_Options.m_ResetButton.disabled = disable;
    m_Options.m_LanguageDropdown.disabled = disable;
    m_Options.m_AudioLanguageDropdown.disabled = disable;
    m_Options.m_ResolutionDropdown.disabled = disable;
    m_Options.m_DisplayOptionDropdown.disabled = disable;
    m_Options.m_SoundChkBox.disabled = disable;
    m_Options.m_MusicChkBox.disabled = disable;
    m_Options.m_DirectX9RdBtn.disabled = disable;
    m_Options.m_DirectX11RdBtn.disabled = disable;
    m_ItemStoreButton.disabled = disable;
	m_EULA.m_AcceptButton.disabled = disable;
	m_EULA.m_DeclineButton.disabled = disable;

    if ( disable )
    {
        m_ProgressComponent.m_InfoText.text = "";
    }
    else
    {
        m_ProgressComponent.m_InfoText.text = "$Patcher:cancel_infoText";
    }
}

function DisableButtons():Void
{
    ButtonHandler( true );
}

function EnableButtons():Void 
{
	ButtonHandler( false );
}

/// there is no exit patcher button
function SlotRDBStatusChanged(isActive:Boolean )
{
    i_ExitPatcherButton.disabled = !isActive; 
    i_ExitPatcherButton._alpha = (isActive) ? m_EnabledAlpha : m_DisabledAlpha; 
}


