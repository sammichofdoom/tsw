
class com.GameInterface.Guild.GuildRenownStatus
{
	var m_glory:Number;
	var m_valor:Number;
	var m_artistry:Number;
	var m_totalLastWeek:Number;
	var m_totalRanking:Number;
	var m_valorRanking:Number;
	var m_gloryRanking:Number;
	var m_artistryRanking:Number;
	var m_totalRankingLastWeek:Number;
	
	public function GuildRenownStatus(glory:Number, valor:Number, artistry:Number, totalLastWeek:Number, totalRanking:Number, gloryRanking:Number, valorRanking:Number, artistryRanking:Number, totalRankingLastWeek:Number)
	{
		m_glory = glory;
		m_valor = valor;
		m_artistry = artistry;
		m_totalLastWeek = totalLastWeek;
		m_totalRanking = totalRanking;
		m_valorRanking = valorRanking;
		m_gloryRanking = gloryRanking;
		m_artistryRanking = artistryRanking;
		m_totalRankingLastWeek = totalRankingLastWeek;
	}
	
	public function GetTotalRenown():Number
	{
		return m_glory + m_valor + m_artistry;
	}
	
	public function GetGloryRenown():Number
	{
		return m_glory;
	}
	
	public function GetValorRenown():Number
	{
		return m_valor;
	}
			
	public function GetArtistryRenown():Number
	{
		return m_artistry;
	}
	
	public function GetTotalRenownLastWeek():Number
	{
		return m_totalLastWeek;
	}
	
	public function GetTotalRanking():Number
	{
		return m_totalRanking;
	}
	
	public function GetGloryRanking():Number
	{
		return m_gloryRanking;
	}
	
	public function GetValorRanking():Number
	{
		return m_valorRanking;
	}
	
	public function GetArtistryRanking():Number
	{
		return m_artistryRanking;
	}
	
	public function GetTotalRankingLastWeek():Number
	{
		return m_totalRankingLastWeek;
	}
}
