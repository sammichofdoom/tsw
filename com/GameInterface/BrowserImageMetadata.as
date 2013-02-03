class com.GameInterface.BrowserImageMetadata
{
  public var m_browserType : String;
  public var m_textureWidth : Number;
  public var m_textureHeight : Number;
  public var m_browserWidth : Number;
  public var m_browserHeight : Number;
  public var m_offsetX : Number;
  public var m_offsetY : Number;
			
  public function BrowserImageMetadata()
	{
		m_browserType = "";
        m_textureWidth = 0;
  		m_textureHeight = 0;
  		m_browserWidth = 0;
  		m_browserHeight = 0;
  		m_offsetX = 0;
  		m_offsetY = 0;
	}

	public function SetBrowserType( browserType : String )
	{
	  m_browserType = browserType;
	}

	public function SetTextureDimensions( textureWidth : Number, textureHeight : Number)
	{
		m_textureWidth = textureWidth;
		m_textureHeight = textureHeight;
	}
	
	public function SetBrowserDimensions( browserWidth : Number, browserHeight : Number)
	{
		m_browserWidth = browserWidth;
		m_browserHeight = browserHeight;
	}
	
	public function SetOffset( offsetX : Number, offsetY : Number)
	{
		m_offsetX = offsetX;
		m_offsetY = offsetY;
	}
}