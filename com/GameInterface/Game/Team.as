import com.Utils.ID32;
import com.Utils.Signal;
import com.GameInterface.Game.GroupElement;

intrinsic class com.GameInterface.Game.Team
{
    ///Get the teammember id in a given index
    public function IsTeamLeader(id:ID32) : Boolean;
    public function GetTeamMemberID(memberIndex:Number ) : ID32;
    public function GetTeamMemberIndex(id:ID32) : Number;
    public function IsTeamMember(id:ID32) : Boolean;
    
    //Signals
    public var SignalCharacterJoinedTeam:Signal;
    public var SignalCharacterLeftTeam:Signal;
    public var SignalNewTeamLeader:Signal;
    public var SignalTeamDisband:Signal;
    public var SignalMasterLooterChanged:Signal; //masterLooter:ID32
    
    //Variables
    public var m_TeamMembers:Object;
    public var m_TeamId:ID32;
    public var m_TeamName:String;
}