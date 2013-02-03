intrinsic class com.GameInterface.Playfield
{
    public var m_Name:String;
    public var m_InstanceId:Number;
    public var m_Difficulty:Array;
    
    //Check if the playfield can be played in a certain difficulty mode
    public function HasDifficultyMode(difficulty:Number):Boolean; 
}
