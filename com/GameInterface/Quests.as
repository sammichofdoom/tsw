import com.Utils.Signal;

class com.GameInterface.Quests extends com.GameInterface.QuestsBase
{
    /// Fired when you request visual mission update.
    ///
    /// @param missionid:Number        The id of the mission.
    public static var SignalMissionRequestFocus:Signal = new Signal(); // ->OnMissionRequestFocus( missionID:Number )
    
    /// variable holding the id of the current mission a player holds
    ///
    public static var m_CurrentMissionId:Number;
}
