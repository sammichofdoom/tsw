import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.Game.Raid
{
    public function IsRaidMember(id:ID32) : Boolean;
    public function IsRaidLeader(id:ID32) : Boolean;
    public function GetRaidLeader() : ID32;
    
    //Signals
    public var SignalRaidDisbanded:Signal; //Void
    public var SignalRaidGroupAdded:Signal; //ID32
    public var SignalRaidGroupRemoved:Signal; //ID32
    public var SignalNewRaidLeader:Signal; //ID32
    public var SignalMasterLooterChanged:Signal; //masterLooter:ID32
    
    //Variables
    public var m_Teams:Object;
    public var m_RaidId:ID32;    
}