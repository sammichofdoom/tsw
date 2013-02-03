import com.Utils.Signal;
import com.GameInterface.CharacterLFG;

intrinsic class com.GameInterface.LookingForGroup
{
    public var m_CharactersLookingForGroup:Array; //Array of com.GameInterface.CharacterLFG
    
    //List of possible playfields to sign up for a group
    static public var m_DungeonPlayfields:Array; //Array of com.GameInterface.Playfield
    static public var m_AdventurePlayfields:Array; //Array of com.GameInterface.Playfield
    
    public var SignalSearchResult:Signal;
    public var SignalCharacterCountResult:Signal; //(Dictionary[playfieldId]= characterCount, count:Number)
    
    static public var SignalClientJoinedTeam:Signal;
    static public var SignalClientJoinedLFG:Signal; //Void 
    static public var SignalClientLeftLFG:Signal; //Void
    
    public function LookingForGroup();
    public function SignUp(mode:Number, playfieldInstances:Array, rolesArray:Array):Void;
    public function SignOff():Void;
    public function DoSearch(mode:Number, playfieldInstances:Array, rolesArray:Array, getAllResults:Boolean, skipResults:Number):Void;
    public function RequestCharacterCount(mode:Number):Void;
    
    static public function GetPlayerSignedUpData():CharacterLFG;
    static public function HasCharacterSignedUp():Boolean;
    static public function CanCharacterJoinEliteDungeons():Boolean;
    static public function CanCharacterJoinNightmareDungeons():Boolean;
}
