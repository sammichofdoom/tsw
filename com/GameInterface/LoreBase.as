import com.Utils.Signal;

intrinsic class com.GameInterface.LoreBase
{	
    // SIGNALS
	public static var SignalTagAdded:Signal; // (tagId:Number, character:ID32)
	public static var SignalTagRemoved:Signal; // (tagId:Number, character:ID32)
	public static var SignalCounterUpdated:Signal; // (stat:Number)
	public static var SignalGetAnimationComplete:Signal; // (tagId:Number)
	
	// FUNCTIONS
	public static function GetHeaderNodeId() : Number;
	public static function GetTagChildrenIdArray(tagId:Number, tagType:Number) : Array; // <Number>
	public static function GetTagType(tagId:Number) : Number; // LoreNodeType
	public static function GetTagParent(tagId:Number) : Number; // tagId
	public static function GetTagText(tagId:Number) : String;
	public static function GetTagName(tagId:Number) : String;
	public static function IsVisible(tagId:Number) : Boolean;
	public static function IsValidId(tagId:Number) : Boolean;
	public static function IsNew(tagId:Number) : Boolean; // Returns true if the tag is new
	public static function MarkAsOld(tagId:Number) : Void; // Mark a tag as not new
	public static function IsLocked(tagId:Number) : Boolean;
	public static function HasCounter(tagId:Number) : Boolean;
	public static function HasPlayerFaction(tagId:Number) : Boolean;
	public static function GetIcon(tagId:Number) : Number; // DON'T USE THIS IN GUI. IT'S USED WHEN BUILDING THE TREE ONLY (calling this function directly will not do inheritance)
	public static function GetIcon2(tagId:Number) : Number; // This you can use in GUI :)
	public static function GetBackgroundGradientFrom(tagId:Number) : String; // #AAFF33
	public static function GetBackgroundGradientTo(tagId:Number) : String; // #AAFF33
	public static function GetForegroundGradientFrom(tagId:Number) : String; // #AAFF33
	public static function GetForegroundGradientTo(tagId:Number) : String; // #AAFF33
	public static function GetCounterStat(tagId:Number) : Number; // StatId
	public static function GetCounterCurrentValue(tagId:Number) : Number;
	public static function OpenTag(tagId:Number) : Void; // The player interacted with a GUI element that should open this tag
    public static function GetRequiredQuest(tagId:Number) : Number; // TemplateID
	public static function GetCounterTargetValue(tagId:Number) : Number;
	public static function GetRank(tagId:Number) : Number; // StatId
	public static function GetMediaId(tagId:Number, mediaType:Number) : Number;
	public static function GetRewardIdArray(tagId:Number, rewardType:Number) : Array; // <Number>
	public static function SetSelectedTag(tagId:Number) : Void; // Sets selected tag node for the player tags
	public static function OpenTagOnce(tagId:Number) : Void;
	public static function IsPlayingTagSound() : Boolean; // returns true if the tag sound has started playing and not finished (also true if paused)
	public static function LoadTagSound(tagId:Number) : Boolean; // returns true if the tag has a sound
	public static function PlayTagSound(tagId:Number) : Void;
	public static function PauseTagSound() : Void;
	public static function StopTagSound() : Void;
}