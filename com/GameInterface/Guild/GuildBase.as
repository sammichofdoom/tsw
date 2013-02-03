import com.GameInterface.Guild.GuildRenownHistoryEntry;
import com.GameInterface.Guild.GuildRenownStatus;
import com.GameInterface.Guild.GuildMemberRenownStatus;
import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.Guild.GuildBase
{
	
	public var m_GuildName:String;
	public var m_MessageOfTheDay:String;
	public var m_NumMembers:Number;
	public var m_PvpKillPoints:Number;
	public var m_PvpMinigamePoints:Number;
	public var m_GoverningformID:Number;
	public var m_RecruitmentID:Number;
	public var m_RankID:Number;
	public var m_Cash:Number;

	public var m_CanChangeGuildName:Boolean;
	public var m_CanChangeMessageOfTheDay:Boolean;
	public var m_CanChangeRecruitment:Boolean;
	public var m_CanChangeGoverningform:Boolean;
	public var m_CanKick:Boolean;
	public var m_CanPromote:Boolean;
	public var m_CanDemote:Boolean;

	public var m_GoverningFormArray:Array;
	public var m_RecruitmentArray:Array;

	public var m_MemberArray:Array;

	public var m_PermissionArray:Array;
	public var m_RanksArray:Array;

	public var m_TotalRenown:Number;
	public var m_RenownRank:Number;
	public var m_RenownLevel:Number;
	public var m_NextLevelRenown:Number;
	public var m_LastLevelRenown:Number;
	public var m_TopContributor:String;
	public var m_NextRankingCalculationTime:Date;

	public var m_CurrentHistoryEntry:GuildRenownHistoryEntry;
	public var m_LastHistoryEntry:GuildRenownHistoryEntry;
	public var m_HighestHistoryEntry:GuildRenownHistoryEntry;
	public var m_AverageHistoryEntry:GuildRenownHistoryEntry;

	public var m_ValorRenownCapped:Boolean;
	public var m_GloryRenownCapped:Boolean;
	public var m_ArtistryRenownCapped:Boolean;

	public var m_GuildStatus:GuildRenownStatus;
	public var m_GuildMemberStatus:GuildMemberRenownStatus;

	public var m_GuildRenownRewards:Array;

	public var m_GuildCityPlayfieldID:Number;
	public var m_GuildCityPlayfieldInstance:Number;
	public var m_GuildFeats:Array;

	public var m_TotalRankingArray:Array;
	public var m_ValorRankingArray:Array;
	public var m_GloryRankingArray:Array;
	public var m_ArtistryRankingArray:Array;
	
	public var SignalGuildCashUpdated:Signal;
	public var SignalGuildNameUpdated:Signal;
	public var SignalMessageOfTheDayUpdated:Signal;
	public var SignalGoverningformUpdated:Signal;
	public var SignalRankUpdated:Signal;
	public var SignalRecruitmentUpdated:Signal;
	public var SignalPvPPointsUpdated:Signal;
	public var SignalCurrentHistoryEntryUpdated:Signal;
	public var SignalGuildRenownHistoryUpdated:Signal;
	public var SignalGuildRenownRankingsUpdated:Signal;
	public var SignalGuildCreated:Signal;

	public var SignalRenownPointsUpdated:Signal;
	public var SignalUpdateGuildRenown:Signal;

	public var SignalValorRenownCapped:Signal;
	public var SignalGloryRenownCapped:Signal;
	public var SignalArtistryRenownCapped:Signal;

	public var SignalMembersUpdate:Signal;
    
    public var SignalCharacterLeftGuild:Signal; //(ID32)CharacterId
	
	public static function CloseGuildWindow():Void;
	public static function HasGuild() : Boolean;
	public static function LeaveGuild() : Void;
	public static function OpenRankingsWindow() : Void;
	public static function CloseRankingsWindow() : Void;
	
    public function GetGuildID() : ID32;
	public function GetGeneralGuildInfo() : Void;
	public function GetGuildRenown() : Void;
	public function GetGuildMembers() : Void;
	public function GetGuildCityInfo() : Void;
	public function GetGuildRenownRankings() : Void;
	public function GetNextRankingsUpdateTime() : Number;
	public function UpdateGuildInfo( guildUpdateObject:Object ) : Void;
	public function PromoteGuildMembers( members:String) : Void;
	public function DemoteGuildMembers( members:String ) : Void;
	public function KickGuildMembers( members:String ) : Void;
	public function BookCitySpot(playfieldID:Number) : Void;
	public function HasUnlockedGuildRenown() : Boolean;
	public function SendCash(amount:Number) : Void;
	public function WithdrawCash(amount:Number) : Void;
	
	
}
