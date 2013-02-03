import com.Utils.ID32;
import com.Utils.Signal;
intrinsic class com.GameInterface.Game.TeamInterface
{
    //Request info about teams/raids. Will get back signals JoinedTeam/JoinedRaid
    public static function RequestTeamInformation( ) : Void;
    
    /// Returns true if the dynel is in a team. Returns false if not in team or if the dynel is not on the client.
    public static function IsInTeam( id:ID32 ) : Boolean;
        
    /// Returns true if the dynel is in a raid. Returns false if not in team or if the dynel is not on the client.
    public static function IsInRaid( id:ID32 ) : Boolean;
    
    /// Returns true if the team leader can summon other people to this playfield
    public static function CanSummonHere() : Boolean;

    /// Invite the id to join the players team.
    public static function InviteToTeam( id:ID32 );

    /// Promote the id to become leader of the players team.
    public static function PromoteToLeader( id:ID32 );

    /// Kick the id from the players team.
    public static function KickFromTeam( id:ID32 );

    /// Open the loot options GUI
    public static function ToggleLootOptions();

    /// Leave team.
    public static function LeaveTeam();
    
    /// Accept team invite from id.
    public static function AcceptTeamInvite( id:ID32 );

    /// Decline team invite from id.
    public static function DeclineTeamInvite( id:ID32 );
    
    /// Accept raid invite from id.
    public static function AcceptRaidInvite( id:ID32 );

    /// Decline raid invite from id.
    public static function DeclineRaidInvite( id:ID32 );
    
    public static function CreateRaid();
    
    public static function LeaveRaid();
    
    public static function InviteToRaid(id:ID32);
    
    public static function MarkForTeamMove(id:ID32);
    
    public static function GetCharacterMarkedForTeamMove():ID32;
    
    public static function CancelTeamMove();
    
    ///Swap the team of two characters
    public static function TeamSwap(charId1:ID32, charId2:ID32); 
    
    ///Move a character to a different team
    public static function TeamMove(charId:ID32, teamId:ID32); 
    
    public static function KickFromRaid(id:ID32);
    
    public static function SummonRequest(id:ID32);
    
    //Helper functions
    public static function IsClientTeamLeader();
    public static function IsTeamLeader(id:ID32);
    public static function IsClientRaidLeader();
    public static function IsInClientTeam(id:ID32);
    public static function IsInClientRaid(id:ID32);    
	
	public static function GetClientRaidID():ID32;
	public static function GetClientTeamID():ID32;
    
    ///Get the team of the client if it is in the Raid of the local player
    public static function GetTeamIDFromRaid(charID:ID32):ID32;

    public static var SignalTeamInvite:Signal; //ID32, String
    public static var SignalTeamInviteTimedOut:Signal; // void
    public static var SignalRaidInvite:Signal; //ID32, String
    public static var SignalRaidInviteTimedOut:Signal; //ID32
    public static var SignalClientJoinedTeam:Signal; //Team
    public static var SignalClientLeftTeam:Signal; //Void
    public static var SignalClientJoinedRaid:Signal; //Raid
    public static var SignalClientLeftRaid:Signal; //Void
    public static var SignalMarkForTeamMove:Signal; //ID32
    public static var SignalUnmarkForTeamMove:Signal; //ID32
}
