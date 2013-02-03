import com.Utils.Signal;
import com.GameInterface.Guild.*;


class com.GameInterface.Guild.Guild extends com.GameInterface.Guild.GuildBase
{
	private static var m_Instance:Guild;
	private var m_RankingsWindowOpen:Boolean;

	public static function GetInstance():Guild 
	{
		if (m_Instance == undefined) 
		{
			m_Instance = new Guild();
		}
		return m_Instance;
	}

	public function ToggleRankingsWindow()
	{
		if(!m_RankingsWindowOpen)
		{
			OpenRankingsWindow();
			m_RankingsWindowOpen = true;
		}
		else
		{
			CloseRankingsWindow();
			m_RankingsWindowOpen = false;
		}
	}
	
	public function SetRankingsWindowOpen(isOpen:Boolean)
	{
		m_RankingsWindowOpen = isOpen;
	}
		
	/// Function that should be called from the GUI to send 
	/// the updates that is done in the gui (Name, MOTD, RecruitmentMode and GoverningForm
	/// The updatedvariables should be set on beforehand
	///@author Håvard Homb
	public function UpdateGuildInfoData(newName:String, newMessageOfTheDay:String, newRecruitment:Number, newGoverningform:Number) 
	{
		var guildUpdateObject:Object = new Object;
		
		var sendUpdate:Boolean = false;
		if (newName != m_GuildName) 
		{
			guildUpdateObject.GuildName = newName;
			sendUpdate = true;
			m_GuildName = newName;
		}
		if (newMessageOfTheDay != m_MessageOfTheDay)
		{
			//Send the motd with newlines instead of carriage returns since carriage returns does not work well with the old gui
			guildUpdateObject.MessageOfTheDay = newMessageOfTheDay.split("\r").join("\n");
			sendUpdate = true;
			m_MessageOfTheDay = newMessageOfTheDay;
		}
		if (newGoverningform != m_GoverningformID) 
		{
			guildUpdateObject.GovernmentID = newGoverningform;
			sendUpdate = true;
			m_GoverningformID = newGoverningform;
		}

		if (newRecruitment != m_RecruitmentID)
		{
			guildUpdateObject.RecruitmentID = newRecruitment;
			sendUpdate = true;
			m_RecruitmentID = newRecruitment;
		}
		if (sendUpdate) 
		{
			UpdateGuildInfo( guildUpdateObject );
		}
	}

	public function FetchGuildRankings()
	{
		GetGuildRenownRankings();
		FetchNextGuildRankingsUpdateTime();
	}
	
	public function FetchNextGuildRankingsUpdateTime()
	{
		var nextUpdate:Number = GetNextRankingsUpdateTime();
		m_NextRankingCalculationTime = new Date();
		m_NextRankingCalculationTime.setTime(nextUpdate*1000);
	}

	public function PromoteMembers(memberInstanceArray:Array)
	{
		var newXml = new XML();
		var rootNode = newXml.createElement("Members");
		newXml.appendChild(rootNode);

		for (var i = 0; i<memberInstanceArray.length; ++i) {
			var instanceNode = newXml.createElement("Instance");
			var instanceText = newXml.createTextNode(memberInstanceArray[i]);
			instanceNode.appendChild(instanceText);
			rootNode.appendChild(instanceNode);

		}
		var xmlStr:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"+newXml.toString();
		PromoteGuildMembers( xmlStr );
	}

	public function DemoteMembers(memberInstanceArray:Array)
	{
		var newXml = new XML();
		var rootNode = newXml.createElement("Members");
		newXml.appendChild(rootNode);

		for (var i = 0; i<memberInstanceArray.length; ++i) {
			var instanceNode = newXml.createElement("Instance");
			var instanceText = newXml.createTextNode(memberInstanceArray[i]);
			instanceNode.appendChild(instanceText);
			rootNode.appendChild(instanceNode);

		}
		var xmlStr:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"+newXml.toString();
		DemoteGuildMembers(xmlStr);
	}

	public function KickMembers(memberInstanceArray:Array)
	{
		var newXml = new XML();
		var rootNode = newXml.createElement("Members");
		newXml.appendChild(rootNode);

		for (var i = 0; i<memberInstanceArray.length; ++i) {
			var instanceNode = newXml.createElement("Instance");
			var instanceText = newXml.createTextNode(memberInstanceArray[i]);
			instanceNode.appendChild(instanceText);
			rootNode.appendChild(instanceNode);

		}
		var xmlStr:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"+newXml.toString();
		KickGuildMembers(xmlStr);
	}

	public function SetName(newName:String)
	{
		m_GuildName = newName;
	}


	public function SetMessageOfTheDay(newMotd:String) 
	{
		m_MessageOfTheDay = newMotd;
    }
    
	public function GetPvPPoints():Number 
	{
		return m_PvpKillPoints + m_PvpMinigamePoints;
	}

	public function SetRecruitmentID(newRecruitmentID:Number) 
	{
		m_RecruitmentID = newRecruitmentID;
	}

	public function SetGoverningformID(newGoverningformID:Number)
	{
		m_GoverningformID = newGoverningformID;
	}

	public function GetGuildGoverningForm():String 
	{
		return m_GoverningFormArray[m_GoverningformID];
	}
	
	public function GetGuildRecruitmentType():Array
	{
		return m_RecruitmentArray[m_RecruitmentID];
	}
	public function GetRankName():String
	{
		var memberRank:GuildRank = undefined;
		memberRank = GetMemberRank();
		if(memberRank != undefined)
		{
			return memberRank.GetName();
		}
		return "NoRank";
	}
	
	public function GetMemberRank():GuildRank
	{
		for (var i = 0; i<m_RanksArray.length; ++i) {
			if (m_RanksArray[i].GetRankNr() == m_RankID) {
				return m_RanksArray[i];
			}
		}
	}

	public function GetRankID():Number 
	{
		return m_RankID;
	}

	public function GetMaxRank():Number
	{
		var maxRank:Number = 0;
		for (var i = 0; i<m_RanksArray.length; ++i) {
			if (m_RanksArray[i].GetRankNr()>maxRank) {
				maxRank = m_RanksArray[i].GetRankNr();
			}

		}
		return maxRank;
	}

	public function GetRankArray():Array {
		return m_RanksArray;
	}

	public function GetGuildPermissions():Array
	{
		return m_PermissionArray;
	}

	public function IsValorRenownCapped()
	{
		return m_ValorRenownCapped;
	}

	public function IsGloryRenownCapped()
	{
		return m_GloryRenownCapped;
	}

	public function IsArtistryRenownCapped()
	{
		return m_ArtistryRenownCapped;
	}
	public function GetCurrentHistoryEntry():GuildRenownHistoryEntry 
	{
		return m_CurrentHistoryEntry;
	}

	public function GetLastHistoryEntry():GuildRenownHistoryEntry 
	{
		return m_LastHistoryEntry;
	}

	public function GetHighestHistoryEntry():GuildRenownHistoryEntry
	{
		return m_HighestHistoryEntry;
	}

	public function GetAverageHistoryEntry():GuildRenownHistoryEntry 
	{
		return m_AverageHistoryEntry;
	}

	public function GetGuildRenownStatus():GuildRenownStatus 
	{
		return m_GuildStatus;
	}

	public function GetGuildMemberRenownStatus():GuildMemberRenownStatus 
	{
		return m_GuildMemberStatus;
	}

	public function GetRewardsForLevel(level:Number):Array 
	{
		return m_GuildRenownRewards[level];
	}

	public function GetNumRewardLevels():Number 
	{
		return m_GuildRenownRewards.length;
	}

	public function GetTotalRankings() 
	{
		return m_TotalRankingArray;
	}

	public function GetValorRankings() 
	{
		return m_ValorRankingArray;
	}

	public function GetGloryRankings() 
	{
		return m_GloryRankingArray;
	}

	public function GetArtistryRankings()
	{
		return m_ArtistryRankingArray;
	}

	public function BookCitySpot( playfieldID:Number ):Void
	{
		BookCitySpot( playfieldID );
	}

	public function GetGuildCityPlayfieldID():Number 
	{
		return m_GuildCityPlayfieldID;
	}

	public function GetGuildCityPlayfieldInstance():Number 
	{
		return m_GuildCityPlayfieldInstance;
	}

	public function GetGuildFeats():Array
	{
		return m_GuildFeats;
	}

	public function CanChangeName():Boolean
	{
		return m_CanChangeGuildName;
	}

	public function CanChangeMessageOfTheDay():Boolean
	{
		return m_CanChangeMessageOfTheDay;
	}

	public function CanChangeRecruitment():Boolean
	{
		return m_CanChangeRecruitment;
	}

	public function CanChangeGoverningform():Boolean 
	{
		return m_CanChangeGoverningform;
	}
	
	public function CanKick():Boolean 
	{
		return m_CanKick;
	}

	public function CanPromote():Boolean 
	{
		return m_CanPromote;
	}

	public function CanDemote():Boolean 
	{
		return m_CanDemote;
	}
	
	public function GetGold():Number
	{
		return int(m_Cash/100/100/100);
	}

	public function GetSilver():Number 
	{
		return int(m_Cash/100/100%100);
	}

	public function GetCopper():Number
	{
		return int(m_Cash/100%100);
	}

	public function GetTin():Number
	{
		return int(m_Cash%100);
	}

	public function GetMembers():Array 
	{
		return m_MemberArray;
	}
	
	public function SetMemberSelected(memberID:Number, isSelected:Boolean):Void
	{
		for(var i:Number=0;i < m_MemberArray.length;i++)
		{
			if(m_MemberArray[i].m_Instance == memberID)
			{
				m_MemberArray[i].m_IsSelected = isSelected;
			}
		}
	}

	function TrimString(str:String):String 
	{
		for (var i = 0; str.charCodeAt(i)<33; i++) {}
		for (var j = str.length-1; str.charCodeAt(j)<33; j--){}
		return str.slice(i, j+1);
	}
	
	function GetBool(str:String):Boolean
	{
		if(str == "false")
		{
			return false;
		}
		else if(str == "true")
		{
			return true;
		}
		return false;
	}
}