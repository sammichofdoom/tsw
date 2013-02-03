import com.Utils.Signal;

/// Note: Only commands that are defined to show in progress bar will be dispatched to actionscripts.
class com.GameInterface.Command extends com.GameInterface.CommandBase
{
  /// Signal sent when a command is started.
  /// @param name:String    The name of the command.
  /// @param type:Number    CommandType_e. Currenly not exposed. Not sure if needed.
  public static var SignalCommandStarted:Signal = new Signal; // -> OnSignalCommandStarted( name:String, type:Number )

  /// Signal sent when a command is ended.
  public static var SignalCommandEnded:Signal = new Signal; // -> OnSignalCommandEnded()

  /// Signal sent when a command is aborted.
  public static var SignalCommandAborted:Signal = new Signal; // -> OnSignalCommandAborted()
}
