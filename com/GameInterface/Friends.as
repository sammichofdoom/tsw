import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.Friends
{
    public static var m_Friends : Array; //Dictionary of [friendInstanceID:Number]->FriendInfo objects
    public static var m_GuildFriends : Array; //Dictionary of [friendInstanceID:Number]->FriendGuildInfo objects
    public static var m_IgnoredFriends : Array; //Array of FriendIgnoredInfo objects
    
    public static var SignalFriendsUpdated : Signal; // ()
    public static var SignalGuildUpdated : Signal; // ()
    public static var SignalIgnoreListUpdated : Signal; // ()

    public static function UpdateIgnoreList() : Void;
    public static function GetTotalFriends() : Number;
    public static function GetOnlineFriends() : Number;
    public static function GetTotalGuildMembers() : Number;
    public static function GetOnlineGuildMembers() : Number;
    public static function AddFriend(friendName:String) : Void;
    public static function RemoveFriend(friendName:String) : Void;
    public static function GetGuildName() : String;
    public static function InviteToGuildByName(memberName:String) : Void;
    public static function PromoteGuildMember(memberID:ID32) : Void;
    public static function DemoteGuildMember(memberID:ID32) : Void;
    public static function RemoveFromGuild(memberID:ID32) : Void;
    public static function Ignore(name:String) : Boolean;
    public static function Unignore(name:String) : Boolean;
    public static function InviteToGroup(memberID:ID32) : Void;
    public static function InviteToGroupByName(name:String) : Void;
    public static function KickFromGroup(memberID:ID32) : Void;
    public static function Tell(name:String, message:String) : Void;
    public static function MeetUp(memberID:ID32) : Void;
    public static function GetFriendDimension(friendID:ID32) : Number;
    public static function CanAddFriend(memberID:ID32) : Boolean;
    public static function CanRemoveFriend(memberID:ID32) : Boolean;
    public static function CanInviteToGuild(memberID:ID32) : Boolean;
    public static function CanPromote(memberID:ID32) : Boolean;
    public static function CanWithdrawFromBank(memberID:ID32) : Boolean;
    public static function CanDemote(memberID:ID32) : Boolean;
    public static function CanRemoveFromGuild(memberID:ID32) : Boolean;
    public static function CanIgnore(name:String) : Boolean;
    public static function CanUnignore(name:String) : Boolean;
    public static function CanInviteToGroup(memberID:ID32) : Boolean;
    public static function CanKickFromGroup(memberID:ID32) : Boolean;    
}