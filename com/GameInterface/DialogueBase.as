import com.Utils.Signal;
import com.Utils.ID32;
intrinsic class com.GameInterface.DialogueBase
{
    public static var SignalDialogueEnterVicinity:Signal;
    public static var SignalDialogueLeaveVicinity:Signal;
    public static var SignalOpenChatWindow:Signal;
    public static var SignalCloseChatWindow:Signal;
    public static var SignalNPCChatTextReceived:Signal;
    public static var SignalNPCChatQuestionListReceived:Signal;
	public static var SignalConversationInfoReceived:Signal;
	public static var SignalVoiceStarted:Signal;
	public static var SignalVoiceFinished:Signal;
	public static var SignalVoiceAborted:Signal;
	
	public static function StartConversation(npcID:ID32);
	public static function EndConversation(npcID:ID32);
	public static function ChooseTopic(npcID:ID32, topicIndex:Number);
	public static function JumpToTopic(npcID:ID32, topicIndex:Number, topicNum:Number);
}
