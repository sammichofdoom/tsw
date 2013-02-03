import com.Utils.Signal;

class GUI.Mission.MissionSignals
{
    /// GetEffects animation completed
    ///
    public static var SignalMissionRewardsAnimationDone:Signal = new Signal(); // -> SlotMissionRewardsAnimationDone();
  
    /// MissionReport Sent
    /// 
    public static var SignalMissionReportSent:Signal = new Signal(); // -> SlotMissionReportSent();

    /// Mission Report window has been closed
    ///
    public static var SignalMissionReportWindowClosed:Signal = new Signal(); /// -> SlotMissionReportWindowClosed();
    
	public static var SignalHighlightMissionType:Signal = new Signal(); //SlotHightlightMissionType(missionType:Number, highlight:Boolean)
}