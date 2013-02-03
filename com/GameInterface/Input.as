intrinsic class com.GameInterface.Input
{
  /// Register a hotkey to call a static actionscript function on key up/down.
  /// Example:    com.GameInterface.Input.RegisterHotkey( Enums.InputCommand.e_InputCommand_Debug_FramerateToggle, "FramerateView.ToggleFramerate", Enums.Hotkey.eHotkeyDown ,0 )
  /// @param input            [in] The input enum. Ex. Enums.InputCommand.
  /// @param callbackFunction [in] The static actionscript function to call when hotkey is pressed. Ex. "Game.Abilityview.ActivateItem". It takes 2 param, the hotkey enum as Number and the Enums.Hotkey state. To reset, set it to empty string.
  /// @param hotkeyState      [in] The state the hotkey should be in. Enums.Hotkey.eHotkeyDown / Enums.Hotkey.eHotkeyUp
  /// @param GMFlags          [in] What gmflags must be set to use this hotkey.
    public static function RegisterHotkey( input:Number, callbackFunction:String, hotkeyState:Number, GMFlags:Number ) : Void;
}
