import com.Utils.Signal;
intrinsic class com.GameInterface.Game.GroupElement
{
    public var m_CharacterId:com.Utils.ID32;
    public var m_Name:String;
    public var m_OnClient:Boolean;
    public var m_GroupIndex:Number;
	public var m_Dimension:Number;
    public var m_Role:Number;
    
    public var SignalCharacterEnteredClient:Signal;
    public var SignalCharacterExitedClient:Signal;
}