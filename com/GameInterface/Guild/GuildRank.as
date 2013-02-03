
class com.GameInterface.Guild.GuildRank
{
	public var m_rankNr:Number
	public var m_name:String;
	public var m_access:Number;
	
	public function GuildRank(rankNr:Number, name:String, access:Number)
	{
		m_rankNr = rankNr;
		m_name = name;
		m_access = access;
	}
	
	public function GetName():String
	{
		return m_name;
	}
	
	public function GetRankNr():Number
	{
		return m_rankNr;
	}
	
	public function GetAccess():Number
	{
		return m_access;
	}
	
	public function HasAccess(accessID:Number):Boolean
	{
		if((m_access & accessID) > 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}
