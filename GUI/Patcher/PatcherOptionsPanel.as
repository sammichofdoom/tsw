import mx.transitions.easing.*;
import com.PatcherInterface.Patcher;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.DistributedValue;
import GUI.Patcher.PromptContainer
import gfx.controls.DropdownMenu;
import gfx.motion.Tween;
import mx.utils.Delegate;

var m_SelectedResolutionIndex:Number;
var m_SelectedLanguageIndex:Number;
var m_SelectedAudioLanguageIndex:Number;
var m_LanguageTempIndex:Number;

var m_DXStartValue:Number;
var m_LanguageSelectionPrompt:PromptContainer;
var m_ResetPrefsPrompt:PromptContainer;
var m_BrokenDataPrompt:PromptContainer;

var m_DisplayModeData:Array;


var m_PromptHeight:Number =  200;
var m_PromptWidth:Number = 350;
var m_PromptButtonHeight:Number = 45;


var m_TDB_change_language_prompt:String = "$Patcher:ChangeLanguagePrompt_txt";
var m_TDB_repair_broken_data_prompt:String = "$Patcher:repairBrokenDataPrompt_text";
var m_TDB_reset_preferences:String = "$Patcher:resetPrefsPrompt_text";

var m_TDB_yes:String = "$Patcher:yes_textLabel";
var m_TDB_no:String = "$Patcher:no_textLabel";

var m_PrefVariables:Object;


function onLoad()
{
    i_BundlesList.dataProvider = [];



    m_PrefVariables = {    DisplayMode:undefined,
                           RenderSetting_DirectXVersion:undefined,
                           AudioSoundsOnOff:undefined,
						   AudioMusicOnOff:undefined
    };
                                   
    for ( name in m_PrefVariables )
    {
        m_PrefVariables[name] = DistributedValue.Create( name );
    }
    
    /// disable focus
    m_ApplyButton.disableFocus                      = true;
    m_DirectX9RdBtn.disableFocus                    = true;
    m_DirectX11RdBtn.disableFocus                   = true;
    m_SoundChkBox.disableFocus                      = true;
    m_MusicChkBox.disableFocus                      = true;

    m_RepairEffect._visible = false;
    /// GENERAL
    ///
    m_GeneralSettingsLabel.text                     = "$Patcher:general_textLabel";
    
    /// REPAIR BROKEN DATA
    m_RepairBrokenDataButton.label                  = "$Patcher:repairBrokenData_textLabel"
    /// LANGUAGE
    m_LanguageLabel.text                            = "$Patcher:language_textLabel"
    /// AUDIO LANGUAGE
    m_AudioLanguageLabel.text                       = "$Patcher:AudioLanguage";
    /// RESOURCE DOWNLOAD
    m_ResourceDownloadText.text                     = "$Patcher:resourceDownload_textLabel";
    m_TotalDataSizeLabel.text                       = "$Patcher:totalDataSize_textLabel";

    /// GRAPHIC
    ///
    m_GraphicSettingsLabel.text                     = "$Patcher:graphic_textLabel";
    
    /// SCREEN RESOLUTION
    m_ScreenResolutionLabel.text                    = "$Patcher:screenResolution_textLabel";
    /// DISPLAY OPTIONS
    m_DisplayOptionLabel.text                       = "$Patcher:DisplayOption";
    ///CLIENT
    m_DirectXLabel.text                             = "$Patcher:client_textLabel";
    m_DirectX9RdBtn.m_Text.textField.text          	= "$Patcher:directX9_option";
 	m_DirectX11RdBtn.m_Text.textField.text          = "$Patcher:directX11_option";
    
    /// AUDIO
    ///
    m_AudioSettingsLabel.text                       = "$Patcher:audio_textLabel";
    /// SOUND ON/OFF
    m_SoundChkBox.m_Text.textField.text             = "$Patcher:SoundOnOff";
    m_MusicChkBox.m_Text.textField.text             = "$Patcher:MusicOnOff";
    
    m_ResetButton.label                             = "$Patcher:ResetOptions";
    m_ApplyButton.label                             = "$Patcher:apply_textLabel";
    
    EnableApplyButtons(false);
    

    SetupLanguageDropdown();
    SetupResolutionDropdown();
    SetupAudioLanguageDropdown();
    SetupDisplayModeDropdown();
    
    UpdateBundleList();
    
    SlotTotalDownloadSizeChanged( Patcher.GetTotalDownloadSize() );

    m_PrefVariables["RenderSetting_DirectXVersion"].SignalChanged.Connect( SlotPrefDXVersionChanged, this );
    m_DXStartValue = SlotPrefDXVersionChanged( m_PrefVariables["RenderSetting_DirectXVersion"] ); //set the current DX version

    m_PrefVariables["DisplayMode"].SignalChanged.Connect( SlotPrefFullScreenChanged, this );
    
 //   SlotPrefFullScreenChanged( value:DistributedValue )m_FullscreenModeChkBox.
    
    
    m_PrefVariables["AudioSoundsOnOff"].SignalChanged.Connect( SlotPrefAudioSoundsOnOffChanged, this );
    m_PrefVariables["AudioMusicOnOff"].SignalChanged.Connect( SlotPrefAudioMusicOnOffChanged, this );
    SlotPrefAudioSoundsOnOffChanged( m_PrefVariables["AudioSoundsOnOff"] );
    SlotPrefAudioMusicOnOffChanged( m_PrefVariables["AudioMusicOnOff"] );
 
    
    if ( !Patcher.CheckForDirectX11Hardware() ) 
    {
        m_DirectX9RdBtn.disabled = true;
        m_DirectX11RdBtn.disabled = true;
    }
    
    /// eventlsiteners
    m_RepairBrokenDataButton.addEventListener("click", this, "RepairBrokenDataActivated");
    m_DirectX9RdBtn.addEventListener("click", this, "ClientOptionHandler");
    m_DirectX11RdBtn.addEventListener("click", this, "ClientOptionHandler");
    m_SoundChkBox.addEventListener("click", this, "SoundOptionHandler");
    m_MusicChkBox.addEventListener("click", this, "MusicOptionHandler");
    m_ApplyButton.addEventListener("click", this, "ApplyBundles");
    m_ResetButton.addEventListener("click", this, "ResetPrefsActivated");
    
    Patcher.SignalRDBStatusChanged.Connect( SlotRDBStatusChanged, this);
    Patcher.SignalBundleGroupsUpdated.Connect( UpdateBundleList, this );
    Patcher.SignalDownloadSizeChanged.Connect( SlotTotalDownloadSizeChanged, this );
    Patcher.SignalValidatingRDB.Connect( SlotValidatingRDB, this );
}

// Repair Broken data prompt window
function RepairBrokenDataActivated():Void 
{
	_root.patcher.DisableButtons();
    
    m_BrokenDataPrompt  = new PromptContainer(m_TDB_repair_broken_data_prompt, m_TDB_yes, m_TDB_no, RepairBrokenDataHandler, this, this, m_PromptHeight, m_PromptWidth, m_PromptButtonHeight);
    
    var promptwindow:MovieClip = m_BrokenDataPrompt.Get();
    promptwindow._x = ((Stage.width * 0.5) - (m_PromptWidth * 0.5)) - this._x;
    promptwindow._y = ((Stage.height * 0.5) - (m_PromptHeight * 0.5)) - this._y;
}

function RepairBrokenDataHandler( buttonState:Number ) : Void 
{
    if (buttonState == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        _root.patcher.m_Progressbar.m_InfoText.htmlText = "$Patcher:PleaseDoNotInterrupt";
        m_RepairBrokenDataButton.label = "";
        m_RepairEffect.textField.text = "$Patcher:RepairButtonLabel_PendingRepair";
        m_RepairEffect.m_Background._xscale = 0;
        m_RepairEffect._visible = true;
        m_RepairEffect._alpha = 100;
        Patcher.ValidateRDB( false );
    }
    else
    {
        _root.patcher.EnableButtons();
    }
    
    m_BrokenDataPrompt.Close();
}

function SlotRDBProgressChanged(progress:Number, progressText:String):Void
{
    trace( "Repair progress: '" + progressText + "' (" + progress + ")" );
    m_RepairEffect.m_Background._xscale = progress * 100;
}

function SlotValidatingRDB( isValidating:Boolean ):Void
{
    if ( isValidating )
    {
        m_RepairBrokenDataButton.label = "";
        m_RepairEffect.textField.text = "$Patcher:Repairing";
        Patcher.SignalProgressChanged.Connect( SlotRDBProgressChanged, this );
    }
    else
    {
        Patcher.SignalProgressChanged.Disconnect( SlotRDBProgressChanged, this );
        m_RepairBrokenDataButton.label = "$Patcher:repairBrokenData_textLabel";
    
        m_RepairEffect.m_Background.onTweenComplete = undefined;
        m_RepairEffect.tweenTo(0.2, { _alpha:0 }, None.easeNone);
        m_RepairEffect.onTweenComplete = function()
            {
                this._visible = false;
            }
    
        _root.patcher.EnableButtons();
    }
}

function OnDisplayModeSelection(event:Object):Void
{
    var index:Number = event.target.selectedIndex

    m_PrefVariables["DisplayMode"].SetValue( m_DisplayModeData[index].id );
}    

function SetupDisplayModeDropdown() : Void
{
    var dataProviderArray:Array = [];
    m_DisplayModeData = [];
    
    m_DisplayModeData.push( { name:"$Patcher:Options_DisplayMode_Fullscreen", id:_global.Enums.DisplayModes.e_DisplayMode_Fullscreen } );
    m_DisplayModeData.push( { name:"$Patcher:Options_DisplayMode_Windowed", id:_global.Enums.DisplayModes.e_DisplayMode_Windowed } );
    m_DisplayModeData.push( { name:"$Patcher:Options_DisplayMode_WindowedBorderless", id:_global.Enums.DisplayModes.e_DisplayMode_WindowedBorderless } );

    // copy name string into flat one dimensional array, getting the selected item
    for (var i:Number = 0; i < m_DisplayModeData.length; i++ )
    {
        dataProviderArray.push( m_DisplayModeData[i].name );
    }
    
    m_DisplayOptionDropdown.dropdown     = "ScrollingListGray";
    m_DisplayOptionDropdown.itemRenderer = "ListItemRendererGray";  
    m_DisplayOptionDropdown.dataProvider = dataProviderArray;
    m_DisplayOptionDropdown.rowCount     = dataProviderArray.length;

    m_DisplayOptionDropdown.addEventListener("select", this, "OnDisplayModeSelection");

    SlotPrefFullScreenChanged( m_PrefVariables["DisplayMode"] );
}

function SetupLanguageDropdown() : Void
{
    m_SelectedLanguageIndex = Patcher.GetLanguageSelection();  
    
    var count:Number = Patcher.GetLanguageCount();
    var dataProviderArray:Array = new Array();
   
    for ( var i:Number = 0 ; i < count ; ++i )
    {
        var name:String = Patcher.GetLanguageName( i );
        dataProviderArray.push( name );
    }
    
    m_LanguageDropdown.dropdown = "ScrollingListGray";
    m_LanguageDropdown.itemRenderer = "ListItemRendererGray";    
    m_LanguageDropdown.dataProvider = dataProviderArray;
    m_LanguageDropdown.rowCount = count;
    m_LanguageDropdown.selectedIndex = m_SelectedLanguageIndex;
    m_LanguageDropdown.addEventListener("select", this, "OnLanguageSelection");
}

function SetupAudioLanguageDropdown() : Void
{
    m_SelectedAudioLanguageIndex    = Patcher.GetAudioLanguageSelection();
    var count:Number = Patcher.GetAudioLanguageCount();
    var dataProviderArray:Array = [];
   
    for ( var i:Number = 0 ; i < count ; ++i )
    {
        var name:String = Patcher.GetAudioLanguageName( i );
        dataProviderArray.push( name );
    }
    
    m_AudioLanguageDropdown.dropdown = "ScrollingListGray";
    m_AudioLanguageDropdown.itemRenderer = "ListItemRendererGray";    
    m_AudioLanguageDropdown.dataProvider = dataProviderArray;
    m_AudioLanguageDropdown.rowCount = count;
    m_AudioLanguageDropdown.selectedIndex = m_SelectedAudioLanguageIndex;
    m_AudioLanguageDropdown.addEventListener("select", this, "OnAudioLanguageSelection");
}

function EnableApplyButtons(enabled:Boolean)
{
    m_ApplyButton.disabled = !enabled;
}

function SetupResolutionDropdown():Void 
{
    m_SelectedResolutionIndex = Patcher.GetScreenModeSelection();
    
    var currentWidth:Number = Patcher.GetDisplayModeWidth( m_SelectedResolutionIndex );
    var currentHeight:Number = Patcher.GetDisplayModeHeight( m_SelectedResolutionIndex );
 
    var count:Number = Patcher.GetDisplayModeCount();
    var dataProviderArray:Array = [];
    
    for ( var i:Number = 0 ; i < count ; ++i ) 
    {
        var width:Number = Patcher.GetDisplayModeWidth( i );
        var height:Number = Patcher.GetDisplayModeHeight( i );
        dataProviderArray.push( width + " x " + height );
    }
    
    m_ResolutionDropdown.dataProvider = dataProviderArray;
    m_ResolutionDropdown.label = currentWidth + "x" + currentHeight;
    m_ResolutionDropdown.dropdown = "ScrollingListGray";
    m_ResolutionDropdown.itemRenderer = "ListItemRendererGray";
    m_ResolutionDropdown.rowCount = count //screenResolution_list.dataProvider.length;
    m_ResolutionDropdown.addEventListener("select", this, "OnResolutionSelection");
    m_ResolutionDropdown.selectedIndex = m_SelectedResolutionIndex;
}



function OnResolutionSelection(event:Object) : Void 
{
    var index:Number = event.target.selectedIndex;
    if (m_SelectedResolutionIndex != index)
    {
        m_SelectedResolutionIndex = index
        Patcher.SelectScreenMode( m_SelectedResolutionIndex )
        Selection.setFocus(null);
        
        EnableApplyButtons(true);
    }
    else if (!event.target.isOpen)
    {
      Selection.setFocus(null);
    }
}

function OnLanguageSelection( event:Object ):Void 
{
    m_LanguageTempIndex = event.target.selectedIndex;
    if (m_LanguageTempIndex != m_SelectedLanguageIndex)
    {
        _root.patcher.DisableButtons();
        
        m_LanguageSelectionPrompt = new PromptContainer(m_TDB_change_language_prompt, m_TDB_yes, m_TDB_no, ChangeLanguageHandler, this, "i_LanguageSelectionPrompt", m_PromptHeight, m_PromptWidth, m_PromptButtonHeight);
        
        var promptwindow:MovieClip = m_LanguageSelectionPrompt.Get();
        promptwindow._x = ((Stage.width * 0.5) - (m_PromptWidth * 0.5)) - this._x;
        promptwindow._y = ((Stage.height * 0.5) - (m_PromptHeight * 0.5)) - this._y;
        
        EnableApplyButtons(true);
    }
}
function OnAudioLanguageSelection( event:Object ):Void 
{
    if (event.target.selectedIndex != m_SelectedAudioLanguageIndex)
    {
        Patcher.SelectAudioLanguage( event.target.selectedIndex )
        m_SelectedAudioLanguageIndex = event.target.selectedIndex;

    }
}

function ChangeLanguageHandler( buttonState:Number ) : Void 
{
    _root.patcher.EnableButtons();
    if ( buttonState == _global.Enums.StandardButtonID.e_ButtonIDYes )
    {
        m_SelectedLanguageIndex = m_LanguageTempIndex;
        Patcher.SelectLanguage( m_SelectedLanguageIndex );
                
       // EnableApplyButtons(true);
    }
    else
    {
        m_LanguageDropdown.selectedIndex = m_SelectedLanguageIndex;
        
    }
    m_LanguageSelectionPrompt.Close();
}

function ClientOptionHandler():Void 
{
    if (m_DirectX9RdBtn.selected == true)
    {
        m_PrefVariables["RenderSetting_DirectXVersion"].SetValue( 0 );
    }
    else if (m_DirectX11RdBtn.selected == true) 
    {
        m_PrefVariables["RenderSetting_DirectXVersion"].SetValue( 1 );
    }
    EnableApplyButtons(true);
};
	
function SoundOptionHandler():Void 
{
    m_PrefVariables["AudioSoundsOnOff"].SetValue( m_SoundChkBox.selected );
    EnableApplyButtons(true);
}
	
function MusicOptionHandler():Void 
{
    m_PrefVariables["AudioMusicOnOff"].SetValue( m_MusicChkBox.selected );
    EnableApplyButtons(true);
}

function UpdateBundleList() : Void
{
    var oldBundleSelection:Object = { };

    for ( var i = 0 ; i < i_BundlesList.dataProvider.length ; ++i )
    {
        var bundle = i_BundlesList.dataProvider[i];
        oldBundleSelection[ bundle.label ] = bundle.activated;
    }
    i_BundlesList.dataProvider = [];

    var count:Number = Patcher.GetBundleCount();

    for ( var i:Number = 0 ; i < count ; ++i ) 
    {
        var name:String = Patcher.GetBundleName( i );

        var bundle:Object = {};
        bundle.label = name;
        bundle.disabled = Patcher.IsBundleMandatory( i )
        
        if ( !bundle.disabled )
        {
            var active:Boolean = (oldBundleSelection.hasOwnProperty( name )) ? oldBundleSelection[name] : Patcher.IsBundleSelected( i );
            bundle.activated = active;
            bundle.saved_activated_state = bundle.activated;
        }
        else
        {
            bundle.activated = true;
            bundle.saved_activated_state = true;
        }
        i_BundlesList.dataProvider.push( bundle );
    }
    i_BundlesList.invalidateData();
}

function ResetPrefs()
{
    for ( name in m_PrefVariables )
    {
        m_PrefVariables[name].SetValue( DistributedValueBase.GetDefaultDValue( name ) );
    }
    EnableApplyButtons(false);
}

function SelectedBundles( event:Object ):Void
{
    var bundle = i_BundlesList.dataProvider[event.index];
    if ( !bundle.disabled )
    {
        bundle.activated = !bundle.activated;
        i_BundlesList.invalidateData();
    }
}

function ApplyBundles()
{
    var somethingChanged:Boolean = false;

    for ( var i:Number = 0 ; i < i_BundlesList.dataProvider.length ; ++i ) 
    {
        var bundle = i_BundlesList.dataProvider[i];
        if ( bundle.activated != bundle.saved_activated_state ) 
        {
            Patcher.ActivateBundle( i, bundle.activated );
            bundle.saved_activated_state = bundle.activated;
            somethingChanged = true;
        }
    }

/*    if ( m_StereoMusicButton.selected != m_PrefVariables["LowQualityAudio"].GetValue() ) 
    {
        m_PrefVariables["LowQualityAudio"].SetValue( m_StereoMusicButton.selected );
        somethingChanged = true;
        }*/
    
    if ( somethingChanged ) 
    {
        _root.StartButtonDeactivation();
        Patcher.RestartDownload();

    }
    EnableApplyButtons(true);
}

// Reset Game Options prompt window
function ResetPrefsActivated():Void 
{
	_root.patcher.DisableButtons();

    m_ResetPrefsPrompt = new PromptContainer(m_TDB_reset_preferences, m_TDB_yes, m_TDB_no, ResetPrefsHandler, this, "i_ResetPrefsPrompt", m_PromptHeight, m_PromptWidth, m_PromptButtonHeight);
    
    var promptwindow:MovieClip = m_ResetPrefsPrompt.Get();
    promptwindow._x = ((Stage.width * 0.5) - (m_PromptWidth * 0.5)) - this._x;
    promptwindow._y = ((Stage.height * 0.5) - (m_PromptHeight * 0.5)) - this._y;
}

/// is this supposed to do something?
function ResetPrefsHandler( buttonState:Number ):Void
{
	_root.patcher.EnableButtons();
   
    if (buttonState ==_global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        ResetPrefs();
    }
    m_ResetPrefsPrompt.Close();
}


function SlotPrefDXVersionChanged( value:DistributedValue ) : Number
{
    var dxVersion:Number = value.GetValue();
    if ( dxVersion == 0 ) 
    {
        m_DirectX9RdBtn.selected = true;
        m_DirectX11RdBtn.selected = false;
    } 
    else if ( dxVersion == 1 ) 
    {
        m_DirectX9RdBtn.selected = false;
        m_DirectX11RdBtn.selected = true;
    }
    return dxVersion;
}

function SlotPrefFullScreenChanged( value:DistributedValue )
{
    var newMode = value.GetValue();
    for (var i:Number = 0; i < m_DisplayModeData.length; ++i )
    {
        if (newMode == m_DisplayModeData[i].id)
        {
            m_DisplayOptionDropdown.selectedIndex = i;
            break;
        }
    }
}

function SlotPrefAudioSoundsOnOffChanged( value:DistributedValue )
{
    m_SoundChkBox.selected = value.GetValue();
}

function SlotPrefAudioMusicOnOffChanged( value:DistributedValue )
{
    m_MusicChkBox.selected = value.GetValue();
}

function SlotTotalDownloadSizeChanged( totalSize:String )
{
  m_TotalDataSize.text = totalSize
}

function SlotRDBStatusChanged( isActive:Boolean )
{ 
    m_RepairBrokenDataButton.disabled = !isActive;
    m_ApplyButton.disabled = !isActive;
} 