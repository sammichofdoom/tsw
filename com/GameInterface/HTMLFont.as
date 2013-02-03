class com.GameInterface.HTMLFont 
{
	public var m_Color : Number;
	public var m_Size : Number;
	public var m_Family : String;
	public var m_Style : String;
	public var m_Bold : Boolean;
	public var m_Italic : Boolean;
	public var m_Underline : Boolean;
	public var m_Kerning : Boolean;
	// Number of seconds to stay on the screen before starting to fade out
	public var m_WaitOnScreen : Number;
	public var m_Speed : Number;
	// Y direction to move the text in
	public var m_FlyingDirection : Number;

  public function HTMLFont()
	{
		m_Color 					= 0xFFFFFF;
		m_Size  					= 1.0;
		m_Family 					= "Arial";
		m_Style  					= "";	
		m_Bold 		  			= false;
		m_Italic 	  			= false;
		m_Underline 			= false;
		m_Kerning   			= false;
		m_WaitOnScreen 		= 1.0;
		m_FlyingDirection	= 1.0;
		m_Speed						= 100;
	}

	public function SetColor( rgb : Number )
	{
	  m_Color = rgb;
	}

	public function SetWaitOnScreen( numSeconds : Number )
	{
		m_WaitOnScreen = numSeconds;
	}
	
	public function SetSpeed( speed : Number )
	{
		m_Speed = speed;
	}

	public function SetFlyingDirection( flyingDirection : Number )
	{
		trace("Set flying direction:" + flyingDirection);
		m_FlyingDirection = flyingDirection;
	}

	public function SetSize( fontSize : String )
	{
		// magic conversion
		m_Size = 1.0;

		if (fontSize == "xx-small")
		{
			m_Size = 0.25;
		}
		else if (fontSize == "x-small")
		{
			m_Size = 0.5;
		}
		else if (fontSize == "small")
		{
			m_Size = 0.75;
		}
		else if (fontSize == "medium")
		{
			m_Size = 1.0;
		}
		else if (fontSize == "large")
		{
			m_Size = 1.25;
		}
		else if (fontSize == "x-large")
		{
			m_Size = 1.5;
		}
		else if (fontSize == "xx-large")
		{
			m_Size = 1.75;
		}
		else if (fontSize == "smaller")
		{
			m_Size = 0.75;
		}
		else if (fontSize == "larger")
		{
			m_Size = 1.25;
		}
		else if (fontSize == "inherit")
		{
			m_Size = 1.0;
		}
		else if (fontSize.indexOf("px") != -1)
		{
			//3px is the default, i.e. 1.0
			m_Size = parseInt(fontSize.substr(0, fontSize.indexOf("px")));
			m_Size /= 3.0;
		}
	}

	public function SetStyle( fontStyle : String )
	{
		m_Style = fontStyle;
		
		m_Bold 			= (fontStyle.indexOf("bold") != -1);
		m_Italic 		= (fontStyle.indexOf("italic") != -1);
		m_Underline = (fontStyle.indexOf("underline") != -1);
		m_Kerning 	= (fontStyle.indexOf("kerning") != -1);
		
		if (fontStyle.indexOf("normal") != -1)
		{
			m_Bold 		  = false;
			m_Italic 	  = false;
			m_Underline = false;
			m_Kerning   = false;
		}
	}
	
	public function SetFamily( fontFamily : String )
	{
	  m_Family = fontFamily;
	}
}