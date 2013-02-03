import com.Utils.ID32;

intrinsic class com.GameInterface.CharacterLFG
{
    public var m_Name:String;
    public var m_FirstName:String;
    public var m_LastName:String;
    public var m_FactionRank:Number;
    public var m_Id:ID32;
    public var m_Role:Array;
    public var m_Playfields:Array;
    public var m_Mode:Number;
    
    //Check if the character has a preferred rol
    public function HasRole(role:Number):Boolean; 
}
