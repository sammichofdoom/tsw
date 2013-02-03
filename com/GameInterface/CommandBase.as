intrinsic class com.GameInterface.CommandBase
{
    /// Returns the progress of the current executing command.
    /// There seems to be no way to get the exact time as it varies depending on the network lag.
    /// @param    [out] Value between 0 and 1. As in percent for the time it takes. If no command is running, 0 is returned.
    public static function GetCommandProgress() : Number;
}
