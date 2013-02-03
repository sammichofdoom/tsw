import flash.external.ExternalInterface;
import com.Utils.Signal;

intrinsic class com.GameInterface.DialogIF
{
  /// Called when a dialog should be shown. The project has to listen to this and show their visual dialog.
    public static var SignalShowDialog:Signal;    // SlotShowDialog( com.GameInterface.DialogIF dialogIF )

  /// 
  /// @param message   [in] The message to show.
  /// @param eButtons  [in] The buttons to show. Enums.StandardButtons
  /// @param context   [in] The context that applies for this box. This would be blank or a keyword.
  /// @param           [out] The created DialogIF object. 
//  public static function CreateDialog( String message, Number buttons, String context ) : DialogIF;
   

//   public AddButton( int buttonId, const String& labelName );
//   public RemoveButton( int buttonId );
    public function Go( userDefinedData );

    // These functions are not implemented anywhere, but must be "injected" by the functions connected to SignalShowDialog.
    public function Close();
	public function SetText(message:String);
  
    public function GetDialogData();
    
    public function SetAutocloseOnTeleport(autoClose:Boolean);
    public function SetAutocloseOnDeath(autoClose:Boolean);
    public function SetAutoCloseDistance(distance:Number);
    public function DisconnectAllSignals();
    
    public function SetIgnoreHideModule(ignore:Boolean);


  /// Called when someone clicks a button.
  /// @param buttonId   [in] The button that was pressed.
  /// @param userData   [in] The userdata given when the dialog was created.
    public var SignalSelectedAS:Signal;    // buttonId, dialogIF

	public var m_PositiveAnswer:String;
	public var m_NegativeAnswer:String;
    public var m_Message:String;
    public var m_Buttons:Number;
    public var m_Window:MovieClip;
    public var m_IgnoreHideModule:MovieClip;
}
