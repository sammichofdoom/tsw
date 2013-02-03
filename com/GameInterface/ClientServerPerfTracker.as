
intrinsic class com.GameInterface.ClientServerPerfTracker
{
    static public function GetLatency() : Number;
    static public function GetClientFramerate() : Number;
    static public function GetServerFramerate() : Number;
    static public function GetTotalRemainingDownloads():Number;
    static public function GetDownloadSecondsRemaining():Number;

    static public var SignalLatencyUpdated:com.Utils.Signal; // void SlotLatencyUpdated( latency:Number )
    static public var SignalClientFramerateUpdated:com.Utils.Signal; // void SlotClientFramerateUpdated( framerate:Number )
    static public var SignalServerFramerateUpdated:com.Utils.Signal; // void SlotServerFramerateUpdated( framerate:Number )

}
