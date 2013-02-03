
import com.Utils.ID32;

class com.GameInterface.GameItem
{
	var m_iconID:Number;
	var m_iconType:Number;
	var m_name:String;
	var m_color:String;
	var m_descriptionText:String;
	var m_iconURL:String;
	var m_type:String;

	var m_level:Number;
	var m_cashPrice:Number;

	var m_hasLoadedIcon:Boolean;
	
	public function GameItem( name:String, descriptionText:String )
	{
		m_iconID 			= 0;
		m_iconType			= 0;
		m_name 				= name;
		m_color				= "";
		m_descriptionText 	= descriptionText;
		m_iconURL 			= "";
		m_hasLoadedIcon 	= false;
		m_level 			= 0;
		m_cashPrice 		= 0;
	}
	
	public function GetIconID():Number
	{
		return m_iconID;
	}
	
	public function GetIconType():Number
	{
		return m_iconType;
	}

	public function GetIconURL():String
	{
		return m_iconURL;
	}
	
	public function GetName():String
	{
		return m_name;
	}
	
	public function GetDescriptionText():String
	{
		return m_descriptionText;
	}
	
	public function GetCashPrice():Number
	{
		return m_cashPrice;
	}

	public function GetLevel():Number
	{
		return m_level;
	}
	
	public function GetColor():String
	{
		return m_color;
	}

	public function GetType():String
	{
		return m_type;
	}

	public function HasLoadedIcon():Boolean
	{
		return m_hasLoadedIcon;
	}
	
	public function SetHasLoadedIcon(hasLoaded:Boolean):Void
	{
		m_hasLoadedIcon = hasLoaded;
	}
	
	public function SetIconURL(iconURL:String):Void
	{
		m_iconURL = iconURL;
		m_hasLoadedIcon = true;
	}

}
