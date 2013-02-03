import com.Utils.Signal;

intrinsic class com.GameInterface.Chat
{
  /// Set the input field in the chat to the wanted text.
  public static function SetChatInput( text );

  public static var SignalShowFIFOMessage:Signal; // -> SlotShowFIFOMessage( text:String, mode:Number )
   
}
