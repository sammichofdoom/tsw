intrinsic class com.GameInterface.Quest
{
    public var m_ID:Number;
    public var m_MissionName:String;
    public var m_MissionDesc:String;
    public var m_Xp:Number;
    public var m_Cash:Number;
    public var m_MissionType:Number;
    public var m_TierMax:Number;
    public var m_HasCooldown:Boolean;
    public var m_IsRepeatable:Boolean;
    public var m_HasCompleted:Boolean;
    public var m_IsLocked:Boolean;
    public var m_HideIfLocked:Boolean;
    public var m_CooldownExpireTime:Number;    
    public var m_Tiers:Array;
    public var m_CurrentTask:com.GameInterface.QuestTask;
    public var m_Rewards:Array;
    public var m_OptionalRewards:Array;
    public var m_SolvedText:String;
    public var m_MissionIsDLC:Boolean;
    
    // True if it is possible to locate this quest on the current playfield's map.
    public var m_CanLocateOnMap:Boolean;
	
    // The sortorder on the missiongiver
	public var m_SortOrder:Number;
}
