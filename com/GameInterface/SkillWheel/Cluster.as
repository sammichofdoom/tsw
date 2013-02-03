import com.GameInterface.SkillWheel.SkillWheel;
class com.GameInterface.SkillWheel.Cluster
{
    public var m_Id:Number;
    public var m_Name:String;
    public var m_Cells:Array;
    public var m_Clusters:Array;
    public var m_Completion:Number;
    public var m_TrainedAbilities:Number;
    public var m_DependenyCluster:Number;
    public var m_DependenyCells:Array;
	public var m_OverrideLocked:Boolean;
    
    function Cluster( id:Number)
    {
        m_Id = id;
        m_Name = SkillWheel.GetClusterName(m_Id);
        m_Cells = [];
        m_DependenyCells = [];
        m_TrainedAbilities = 0;
		m_OverrideLocked = undefined;
    }
    
    function SetDependency(clusterID:Number, cellIDArray:Array)
    {
        m_DependenyCluster = clusterID;
        m_DependenyCells = cellIDArray;
    }
}