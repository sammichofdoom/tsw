class com.GameInterface.LoreNode
{
    public var m_Id:Number;
    public var m_Name:String;
    public var m_Icon:Number;
	public var m_Type:Number; // LoreNodeType
	public var m_Locked:Boolean;
    public var m_IsNew:Boolean;
    public var m_IsInProgress:Boolean;
	
	// public relations
	public var m_Parent:LoreNode;
    public var m_Children:Array;
	
	// counters for how many of the children we have
	public var m_HasCount:Number;
	public var m_TargetCount:Number;
}
