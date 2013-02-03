import com.Utils.Signal;

/// Signals sent from gamecode.
class com.Utils.GlobalSignal
{
  /// OnScreen damage numbers and related into.
  /// @param statID:Number                  The stat that was affected
  /// @param damage:Number                  The amount to withdraw/add to that stat
  /// @param attackResultType:Number        The attack result type (Enums.AttackResultType).
  /// @param attackType:Number        The attack type (Enums.AttackType (Melee, ranged, Magic) ).
  /// @param attackOffensiveLevel:Number    The offensive level of the attack (Enums.AttackOffensiveLevel)
  /// @param attackDefensiveLevel:Number    The defensive level of the attack (Enums.AttackDefensiveLevel)
  /// @param context:Number                 Enums.InfoContext       - Yourself, your target or others.
  /// @param targetID:ID32                  The targetid
  public static var SignalDamageNumberInfo:Signal = new Signal();
  
    /// Show text flying over head.
  /// @param text:String                    The text to show
  /// @param context:Number                 Enums.InfoContext       - Yourself, your target or others.
  /// @param targetID:ID32                  The targetid
  public static var SignalDamageTextInfo:Signal = new Signal();
  
  /// Show inspect window
  /// @param text:String                    Show Inspect window for a character
  public static var SignalShowInspectWindow:Signal = new Signal();


  /// Fade screen in or out.
  /// @param fadeIn:Boolean   True if screen should fade back in. False if the screen should fade to black.
  /// @param time:Number      The time the fade should take in seconds.
  public static var SignalFadeScreen:Signal = new Signal();  // -> SlotFadeScreen( fadeIn:Boolean, time:Number )

  /// Loot bag opened.
  /// @param id:com.Utils:ID32 Loot bag ID.
  public static var SignalLootBagOpened:Signal = new Signal();  // -> SignalLootBagOpened( id:com.Utils:ID32 )
  
  /// MissionReport Sent
  /// 
  public static var SignalMissionReportSent:Signal = new Signal(); // -> SignalMissionReportSent();
  
  /// Mission Report window has been closed
  ///
  public static var SignalMissionReportWindowClosed:Signal = new Signal(); /// -> SignalMissionReportWindowClosed();
  
  
  // Signal for showing the friendly menu.
  public static var SignalShowFriendlyMenu:Signal = new Signal();  // -> SlotShowFriendlyMenu( slot:Number )
  
  /// Claim Window row selection toggle between multiple instances
  public static var SignalClaimRowSelected:Signal = new Signal();  // -> SlotClaimRowSelected():Void;
}


