import com.Utils.Signal;

intrinsic class com.GameInterface.RadioButtonsDialog
{
    /// Called when someone clicks a button.
    /// @param buttonId   [in] The button that was pressed.
    /// @param userData   [in] The userdata given when the dialog was created.
    /// @param selection  [in] The Index of the selected option
    public var SignalSelectedAS:Signal;    // buttonId, Variant, selection
    
    static function CreateDialogAS() : RadioButtonsDialog;
    
    function Respond(buttonIdx:Number, selection:Number) : Void;
    function Show() : Void;
    public function Close() : Void;
    public function SetAutocloseOnTeleport(autoClose:Boolean) : Void;
    public function SetAutocloseOnDeath(autoClose:Boolean) : Void;
    public function SetAutoCloseDistance(distance:Number) : Void;    
}
