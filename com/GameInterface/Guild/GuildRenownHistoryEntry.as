
class com.GameInterface.Guild.GuildRenownHistoryEntry
{
	var m_glory:Number;
	var m_valor:Number;
	var m_artistry:Number;
	var m_memberCount:Number;
	
	public function GuildRenownHistoryEntry(glory:Number, valor:Number, artistry:Number, memberCount:Number)
	{
		m_glory = glory;
		m_valor = valor;
		m_artistry = artistry;
		m_memberCount = memberCount;
	}
	
	public function GetTotalRenown():Number
	{
		return m_glory + m_valor + m_artistry;
	}
	
	public function GetTotalRenownAverage():Number
	{
		return int((m_glory + m_valor + m_artistry) / m_memberCount);
	}
	
	public function GetGloryRenown():Number
	{
		return m_glory;
	}
	
	public function GetGloryRenownAverage():Number
	{
		return int(m_glory / m_memberCount);
	}
	
	public function GetValorRenown():Number
	{
		return m_valor;
	}
	
	public function GetValorRenownAverage():Number
	{
		return int(m_valor / m_memberCount);
	}
	
		
	public function GetArtistryRenown():Number
	{
		return m_artistry;
	}
	
	public function GetArtistryRenownAverage():Number
	{
		return int(m_artistry / m_memberCount);
	}
}
