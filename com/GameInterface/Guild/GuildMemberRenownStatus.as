
class com.GameInterface.Guild.GuildMemberRenownStatus
{
	var m_glory:Number;
	var m_valor:Number;
	var m_artistry:Number;
	var m_totalLastWeek:Number;
	var m_averageGlory:Number;
	var m_averageValor:Number;
	var m_averageArtistry:Number;
	var m_averageTotalLastWeek:Number;
	
	public function GuildMemberRenownStatus(glory:Number, valor:Number, artistry:Number, totalLastWeek:Number, averageGlory:Number, averageValor:Number, averageArtistry:Number, averageTotalLastWeek:Number)
	{
		m_glory = glory;
		m_valor = valor;
		m_artistry = artistry;
		m_totalLastWeek = totalLastWeek;
		m_averageGlory = averageGlory;
		m_averageValor = averageValor;
		m_averageArtistry = averageArtistry;
		m_averageTotalLastWeek = averageTotalLastWeek;
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
	
	public function GetTotalRenownAverage():Number
	{
		return m_averageGlory + m_averageValor + m_averageArtistry;
	}
	
	public function GetGloryRenownAverage():Number
	{
		return m_averageGlory;
	}
	
	public function GetValorRenownAverage():Number
	{
		return m_averageValor;
	}
			
	public function GetArtistryRenownAverage():Number
	{
		return m_averageArtistry;
	}
	
	public function GetAverageTotalLastWeek():Number
	{
		return m_averageTotalLastWeek;
	}
	
}
