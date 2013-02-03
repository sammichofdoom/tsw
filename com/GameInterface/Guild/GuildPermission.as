
class com.GameInterface.Guild.GuildPermission
{
	
	public var m_permissionId:Number;
	public var m_permissionText:String;
	
	public function GuildPermission( permissionId:Number, permissionText:String)
	{
		m_permissionId = permissionId;
		m_permissionText = permissionText;
	}
	
	public function GetPermissionID():Number
	{
		return m_permissionId;
	}
	
	public function GetPermissionText():String
	{
		return m_permissionText;
	}
}
