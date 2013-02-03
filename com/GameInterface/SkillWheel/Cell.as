import com.GameInterface.SkillWheel.SkillWheel;
class com.GameInterface.SkillWheel.Cell
{
    public var m_Id:Number
    public var m_ClusterId:Number
    public var m_Name:String; //The name is gotten from tdb based on cluster and cellid
    public var m_Abilities:Array;
    public var m_Completion:Number;
    public var m_TrainedAbilities:Number;
    
    function Cell(id:Number, clusterId:Number)
    {
        m_Id = id;
        m_ClusterId = clusterId;
        
        m_Name = SkillWheel.GetCellName(m_ClusterId, m_Id);// "$SkillhiveGUI:Cluster" + m_ClusterId + "_Cell" + m_Id;
        
        m_Abilities = new Array();
        m_Completion = 0;
        m_TrainedAbilities = 0;
    }
}