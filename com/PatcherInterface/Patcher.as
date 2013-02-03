import flash.external.*;
import com.Utils.Signal;

class com.PatcherInterface.Patcher
{
  private static var m_ClassName:String = "Patcher";


  public static function GetProgress() : Number {
    var result = ExternalInterface.call( "GetProgress", m_ClassName );
	return result
  }

  public static function GetShowEULAFlag() : Boolean {
    var result = ExternalInterface.call( "GetShowEULAFlag", m_ClassName );
	return result
  }
  public static function RequestEULA() : Boolean {
    var result = ExternalInterface.call( "RequestEULA", m_ClassName );
	return result
  }
  public static function GetEULAText() : String {
    var result = ExternalInterface.call( "GetEULAText", m_ClassName );
	return result
  }

  public static function GetTotalDownloadSize() : String {
    var result = ExternalInterface.call( "GetTotalDownloadSize", m_ClassName );
    return result;
  }
  
  public static function GetLanguageCount() : Number {
    var result = ExternalInterface.call( "GetLanguageCount", m_ClassName );
    return result;
  }
  public static function GetLanguageName( index:Number ) : String {
    var result = ExternalInterface.call( "GetLanguageName", m_ClassName, index );
    return result;
  }
  public static function GetLanguageCode( index:Number ) : String {
    var result = ExternalInterface.call( "GetLanguageCode", m_ClassName, index );
    return result;
  }
  public static function SelectLanguage( index:Number ) : Void {
    ExternalInterface.call( "SelectLanguage", m_ClassName, index );
  }
  public static function GetLanguageSelection() : Number {
    var result = ExternalInterface.call( "GetLanguageSelection", m_ClassName );
    return result;
  }
  /// @todo  change this to reflect the audiolanguage
  public static function GetAudioLanguageSelection() : Number {
    var result = ExternalInterface.call( "GetAudioLanguageSelection", m_ClassName );
    return result;
  }
  /// @todo  change this to reflect the audiolanguage
  public static function GetAudioLanguageCount() : Number {
    var result = ExternalInterface.call( "GetAudioLanguageCount", m_ClassName );
    return result;
  }
  /// @todo change this to reflect the audiolanguage
  public static function GetAudioLanguageName( index:Number ) : String {
    var result = ExternalInterface.call( "GetAudioLanguageName", m_ClassName, index );
    return result;
  }
  public static function SelectAudioLanguage( index:Number ) : Void {
    trace(" setting  audio Language");
    ExternalInterface.call( "SelectAudioLanguage", m_ClassName, index );
  }  
 
  public static function CheckForDirectX10Hardware() : Boolean {
    var result = ExternalInterface.call( "CheckForDirectX10Hardware", m_ClassName );
    return result;
  }
	//danger danger.. no such cpp method
  public static function CheckForDirectX11Hardware() : Boolean {
    var result = ExternalInterface.call( "CheckForDirectX11Hardware", m_ClassName );
    return result;
  }
  
  public static function GetScreenResX() : Number {
    var result = ExternalInterface.call( "GetScreenResX", m_ClassName );
    return result;
  }
  public static function GetScreenResY() : Number {
    var result = ExternalInterface.call( "GetScreenResY", m_ClassName );
    return result;
  }


  public static function GetDisplayModeCount() : Number {
    var result = ExternalInterface.call( "GetDisplayModeCount", m_ClassName );
    return result;
  }
  public static function GetDisplayModeWidth( index:Number ) : Number {
    var result = ExternalInterface.call( "GetDisplayModeWidth", m_ClassName, index );
    return result;
  }
  public static function GetDisplayModeHeight( index:Number ) : Number {
    var result = ExternalInterface.call( "GetDisplayModeHeight", m_ClassName, index );
    return result;
  }
  public static function GetScreenModeSelection() : Number {
    var result = ExternalInterface.call( "GetScreenModeSelection", m_ClassName );
    return result;
  }
  public static function SelectScreenMode( index:Number ) :Void {
    ExternalInterface.call( "SelectScreenMode", m_ClassName, index );
  }

  public static function GetOptionIPointX( name:String ) : Number {
    var result = ExternalInterface.call( "GetOptionIPointX", m_ClassName, name );
    return result;
  }
  public static function GetOptionIPointY( name:String ) : Number {
    var result = ExternalInterface.call( "GetOptionIPointY", m_ClassName, name );
    return result;
  }
  public static function SetOptionIPoint( name:String, x:Number, y:Number ) : Void {
    ExternalInterface.call( "SetOptionIPoint", m_ClassName, name, x, y );
  }
  public static function GetOptionBool( name:String ) : Boolean {
    var result = ExternalInterface.call( "GetOptionBool", m_ClassName, name );
    return result;
  }
  public static function SetOptionBool( name:String, value:Boolean ) : Void {
    ExternalInterface.call( "SetOptionBool", m_ClassName, name, value );
  }
  public static function GetOptionInt( name:String ) {
    return ExternalInterface.call( "GetOptionInt", m_ClassName, name );
  }
  public static function SetOptionInt( name:String, value:Number ) : Void {
    ExternalInterface.call( "SetOptionInt", m_ClassName, name, value );
  }

  public static function GetOptionString( name:String ) {
    return ExternalInterface.call( "GetOptionString", m_ClassName, name );
  }
  public static function SetOptionString( name:String, value:String ) : Void {
    ExternalInterface.call( "SetOptionString", m_ClassName, name, value );
  }


  public static function GetBundleCount() {
    return ExternalInterface.call( "GetBundleCount", m_ClassName );
  }

  public static function GetBundleName( index:Number ) {
    return ExternalInterface.call( "GetBundleName", m_ClassName, index );
  }

  public static function IsBundleMandatory( index:Number ) : Boolean {
    var result = ExternalInterface.call( "IsBundleMandatory", m_ClassName, index );
    return result;
  }

  public static function IsBundleSelected( index:Number ) : Boolean {
    var result = ExternalInterface.call( "IsBundleSelected", m_ClassName, index );
    return result;
  }

  public static function ActivateBundle( index:Number, active:Boolean ) {
    ExternalInterface.call( "ActivateBundle", m_ClassName, index, active );
  }

  public static function StartGame() : Void {
    ExternalInterface.call( "StartGame", m_ClassName );
  }
  public static function Cancel() : Void {
    ExternalInterface.call( "Cancel", m_ClassName );
  }

  public static function ShowAccountPage() : Void {
    ExternalInterface.call( "ShowAccountPage", m_ClassName );
  }
  public static function ShowSupportPage() : Void {
    ExternalInterface.call( "ShowSupportPage", m_ClassName );
  }

  public static function ShowExternalURL( url:String ) : Void {
    ExternalInterface.call( "ShowExternalURL", m_ClassName, url );
  }
  
  public static function MinimizeWindow() : Void {
    ExternalInterface.call( "MinimizeWindow", m_ClassName );
  }

  public static function BeginMoveWindow() : Void {
    ExternalInterface.call( "BeginMoveWindow", m_ClassName );
  }
  public static function EndMoveWindow() : Void {
    ExternalInterface.call( "EndMoveWindow", m_ClassName );
  }
  public static function MoveWindow( deltaX:Number, deltaY:Number ) : Void {
    ExternalInterface.call( "MoveWindow", m_ClassName, deltaX, deltaY );
  }
  public static function ValidateRDB( compact:Boolean ) : Void {
    ExternalInterface.call( "ValidateRDB", m_ClassName, compact );
  }
  public static function RestartDownload() : Void {
    ExternalInterface.call( "RestartDownload", m_ClassName );
  }    
  public static function GetBannerCount() : Number {
    var result = ExternalInterface.call( "GetBannerCount", m_ClassName );
    return result;
  }
  public static function GetBannerPath( index:Number ) : String {
    var result = ExternalInterface.call( "GetBannerPath", m_ClassName, index );
    return result;
  }
  public static function GetBannerTargetURL( index:Number ) : String {
    var result = ExternalInterface.call( "GetBannerTargetURL", m_ClassName, index );
    return result;
  }
  public static function GetBannerDisplayTime( index:Number ) : Number {
    var result = ExternalInterface.call( "GetBannerDisplayTime", m_ClassName, index );
    return result;
  }
    
  public static var SignalStatusTextChanged:Signal = new Signal;        // text:String
  public static var SignalProgressChanged:Signal = new Signal;          // progress:Number, progressText:String
  public static var SignalPatchNotesDownloaded:Signal = new Signal;     // text:String
  public static var SignalEULADownloaded:Signal = new Signal;           // text:String
  public static var SignalDownloadSizeChanged:Signal = new Signal;      // text:String
  public static var SignalPatchingDone:Signal = new Signal;             // succeded:Boolean
  public static var SignalValidatingRDB:Signal = new Signal;            // SlotValidatingRDB( isValidating:Boolean )
  public static var SignalInitialize:Signal = new Signal;
  public static var SignalBundleGroupsUpdated:Signal = new Signal;
  public static var SignalRDBStatusChanged:Signal = new Signal;         // enabledStatus:Boolean
  public static var SignalBannerNodeAdded:Signal = new Signal; // SlotBannerNodeAdded( imagePath:String, targetURL:String, displayTime:Number )
  
}
