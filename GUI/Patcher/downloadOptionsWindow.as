import com.PatcherInterface.Patcher;
import com.GameInterface.DistributedValue;

/***********************************************************************************************
*											DISABLING FOCUS		   		   					   *
***********************************************************************************************/
hightTextureQuality_radioButton.disableFocus = true;
lowTextureQuality_radioButton.disableFocus = true;
surroundMusic_radioButton.disableFocus = true;
stereoMusic_radioButton.disableFocus = true;
apply_btn.disableFocus = true;

/***********************************************************************************************
* 											TEXT LABELS								   		   *
***********************************************************************************************/
var m_TDB_resource_download_label:String = "$Patcher:resourceDownload_textLabel";
var totalDataSizeText_tdb:String = "$Patcher:totalDataSize_textLabel";
var textureQualityTextLabel_tdb:String = "$Patcher:textureQuality_textLabel";
var hightTextureQualitytextLabel_tdb:String = "$Patcher:hightTextureQuality_option";
var lowTextureQualitytextLabel_tdb:String = "$Patcher:lowTextureQuality_option";
var audioQualityTextLabel_tdb:String = "$Patcher:audioQuality_textLabel";
var surroundMusicTextLabel_tdb:String = "$Patcher:surroundMusic_option";
var stereoMusicTextLabel_tdb:String = "$Patcher:stereoMusic_option";
var applyTextLabel_tdb:String = "$Patcher:apply_textLabel";

var m_PrefVariables:Object;

    
i_ResourceDownloadText.text = m_TDB_resource_download_label;
totalDataSize_txt.text = totalDataSizeText_tdb;
bundles_list.dataProvider = [];
/*textureQuality_textLabel.text = textureQualityTextLabel_tdb;

hightTextureQuality_radioButton.label = hightTextureQualitytextLabel_tdb;
hightTextureQuality_radioButton.selected = !Patcher.GetOptionBool( "LowQualityTextures" );


lowTextureQuality_radioButton.label = lowTextureQualitytextLabel_tdb;
lowTextureQuality_radioButton.selected = Patcher.GetOptionBool( "LowQualityTextures" );*/

audioQuality_textLabel.text = audioQualityTextLabel_tdb;
surroundMusic_radioButton.label = surroundMusicTextLabel_tdb;
stereoMusic_radioButton.label = stereoMusicTextLabel_tdb;

apply_btn.label = applyTextLabel_tdb;




/***********************************************************************************************
* 											INTERACTIONS							   		   *
***********************************************************************************************/
bundles_list.addEventListener("itemClick", this, "SelectedBundles");
apply_btn.addEventListener("click", this, "ApplyBundles");

/***********************************************************************************************
* 											FUNCTIONS 								   		   *
***********************************************************************************************/

function SetPrefVariables( prefVariables:Object )
{
    m_PrefVariables = prefVariables;
    m_PrefVariables["LowQualityAudio"].SignalChanged.Connect( SlotPrefAudioQualityChanged, this );
    SlotPrefAudioQualityChanged( m_PrefVariables["LowQualityAudio"] );
}

function SlotPrefAudioQualityChanged( value:DistributedValue )
{
    var lowQuality:Boolean = value.GetValue();

    surroundMusic_radioButton.selected = !lowQuality;
    stereoMusic_radioButton.selected = lowQuality;
}

function SelectedBundles( event:Object ):Void
{
    var bundle = bundles_list.dataProvider[event.index];
    if ( !bundle.disabled )
    {
        bundle.activated = !bundle.activated;
        bundles_list.invalidateData();
    }
}


function ApplyBundles()
{
    var somethingChanged:Boolean = false;

    for ( var i:Number = 0 ; i < bundles_list.dataProvider.length ; ++i ) 
    {
        var bundle = bundles_list.dataProvider[i];
        if ( bundle.activated != bundle.saved_activated_state )
        {
            Patcher.ActivateBundle( i, bundle.activated );
            bundle.saved_activated_state = bundle.activated;
            somethingChanged = true;
        }
    }
    /*  if ( lowTextureQuality_radioButton.selected != m_PrefVariables["LowQualityTextures"].GetValue() ) {
    m_PrefVariables["LowQualityTextures"].SetValue( lowTextureQuality_radioButton.selected );
    somethingChanged = true;
    }*/
    if ( stereoMusic_radioButton.selected != m_PrefVariables["LowQualityAudio"].GetValue() ) 
    {
        m_PrefVariables["LowQualityAudio"].SetValue( stereoMusic_radioButton.selected );
        somethingChanged = true;
    }
    if ( somethingChanged ) 
    {
        _root.StartButtonDeactivation();
        Patcher.RestartDownload();
    }
}


function UpdateBundleList() : Void
{
  oldBundleSelection = {}

  for ( var i = 0 ; i < bundles_list.dataProvider.length ; ++i )
  {
    var bundle = bundles_list.dataProvider[i];
    oldBundleSelection[bundle.label] = bundle.activated;
  }
  bundles_list.dataProvider = [];

  var count:Number = Patcher.GetBundleCount();

  for ( var i:Number = 0 ; i < count ; ++i ) {
    var name:String = Patcher.GetBundleName( i );

    var bundle = {};
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
    bundles_list.dataProvider.push( bundle );
  }
  bundles_list.invalidateData();
}

function SlotTotalDownloadSizeChanged( totalSize:String )
{
  totalDataSize_value.text = totalSize
}

Patcher.SignalBundleGroupsUpdated.Connect( g_SignalGroup, UpdateBundleList );
Patcher.SignalDownloadSizeChanged.Connect( g_SignalGroup, SlotTotalDownloadSizeChanged );
UpdateBundleList();
SlotTotalDownloadSizeChanged( Patcher.GetTotalDownloadSize() );
Patcher.SignalRDBStatusChanged.Connect( g_SignalGroup, function( isActive:Boolean ) { apply_btn.disabled = !isActive; } );
