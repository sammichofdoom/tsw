
class com.GameInterface.Guild.GuildRankingEntry
{
	var m_guildName:String
	var m_rank:Number;
	var m_lastRank:Number;
	var m_renownAmount:Number;
	var m_renownLevel:Number;
	var m_memberCount:Number;
	var m_focus:String;
	
	public function GuildRankingEntry(guildName:String, rank:Number, lastRank:Number, renownAmount:Number, renownLevel:Number, memberCount:Number, focus:String)
	{
		m_guildName = guildName;
		m_rank = rank;
		m_lastRank = lastRank;
		m_renownAmount = renownAmount;
		m_renownLevel = renownLevel;
		m_memberCount = memberCount;
		m_focus = focus;
	}
	
	public function GetGuildName():String
	{
		return m_guildName;
	}
	
	public function GetRank():Number
	{
		return m_rank;
	}
	
	public function GetLastRank():Number
	{
		return m_lastRank;
	}
	
	public function GetRenownAmount():Number
	{
		return m_renownAmount;
	}
	
	public function GetMemberCount():Number
	{
		return m_memberCount;
	}
	
	public function GetFocus():String
	{
		return m_focus;
	}
	
	public function GetRenownLevel():Number
	{
		return m_renownLevel;
	}
	
	public function GetRankChange():String
	{
		if(m_lastRank == 0)
		{
			return "-";
		}
		var rankChange:String = "";
		var rankDiff = m_lastRank - m_rank;
		
		if(rankDiff > 0)
		{
			rankChange += "+";
		}
		rankChange += rankDiff;
		return rankChange;
		
	}

}
