
class com.GameInterface.Guild.GuildFeat
{
	var m_iconHandle:Number;
	var m_name:String;
	var m_descriptionText:String;
	var m_modificationText:String;
	var m_iconURL:String;
	
	var m_hasLoadedIcon:Boolean;
	
	public function GuildFeat( iconHandle:Number, name:String, descriptionText:String, modificationText:String)
	{
		m_iconHandle = iconHandle;
		m_name = name;
		m_descriptionText = descriptionText;
		m_modificationText = modificationText;
		m_iconURL = "";
		m_hasLoadedIcon = false;
	}
	
	public function GetIconHandle():Number
	{
		return m_iconHandle;
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
	
	public function GetModificationText():String
	{
		return m_modificationText.split(" <font").join("\n <font").substr(2,m_modificationText.length);
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
