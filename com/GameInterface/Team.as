import flash.external.ExternalInterface;
import com.Utils.Signal;

class com.GameInterface.Team
{
  private static var m_ClassName:String = "Team";
  

  /// You get this signal when someone became leader of the players team.
  ///
  /// @param is:ID32  The id of the new leader.
  public static var SignalNewTeamLeader:Signal = new Signal; // -> SlotNewTeamLeader( id:com.Utils.ID32 )

  /// You get this signal when someone invites you to a team.
  ///
  /// @param is:ID32  The id of the new leader.
  public static var SignalTeamInvite:Signal = new Signal; // -> SlotTeamInvite( id:com.Utils.ID32 )

  /// You get this signal when someone invites you to a team.
  ///
  /// @param is:ID32  The id of the new leader.
  public static var SignalTeamInviteTimedOut:Signal = new Signal; // -> SlotTeamInviteTimedOut( id:com.Utils.ID32 )
}
