import com.Utils.ID32;

intrinsic class com.GameInterface.QuestGiver
{
    public var m_ID:ID32;
    public var m_Name:String;
    public var m_AvailableQuests:Array;
    public var m_QuestWindowPos:flash.geom.Point;
    public var m_QuestWindowDistance:Number;
    public var m_QuestWindowLOS:Boolean;
}
