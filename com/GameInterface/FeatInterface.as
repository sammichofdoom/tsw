import com.Utils.Signal;

intrinsic class com.GameInterface.FeatInterface
{
  /// Associavite array of all the spells the player has. This object is supposed to be const, but that is not supported in actionscript.
  /// This list will be kept in sync by gamecode but you will have to call BuildFeatList when you show the feat gui.
  /// You will get signals when the state of the list changes.
  public static var m_FeatList:Object;


  /// Train a feat.
  /// If it fail, message will pop on screen and false will be returned.
  /// SignalFeatTrained will be called on success.
  /// @param featId  [in]  The feat to train.
  /// @param         [out] True if all preliminary client checks was ok. False if not.
    public static function TrainFeat( featId:Number ) : Boolean;
    
  /// Refund a feat.
  /// @param featId  [in]  The feat to refund.
    public static function RefundFeat( featId:Number ) : Boolean;

  /// Request gamecode to rebuild the featlist. This should be called when you open the feat gui.
  /// Should also be called if featpoints or level of the clientchar changes.
    public static function BuildFeatList() : Void;
    
  /// Each object in the m_FeatList is an instance of a FeatData object and have these values:
  /// "m_Id"            - The featid 
  /// "m_Name"          - Localized name.
  /// "m_Desc"          - Localized description.
  /// "m_Icon"          - Icon resource id.
  /// "m_Trained"       - 1 if trained, else 0.
  /// "m_CanTrain"      - 1 if this feat can be trained at the given time. Else 0. Not this depends on the state of the characer; level, featpoints, etc. so if some of those changes then you should do BuildFeatList() again.
  /// "m_GuiCategory"   - Some kind of gui grouping we can define.
  /// "m_GuiColumn"     - Sub gui grouping.
  /// "m_GuiRow"        - Sub gui grouping.
  /// "m_AutoTrain"     - 1 if the will be auto trained by gamecode.
  /// "m_Level"         - Character must be at least this level to train the feat.
  /// "m_ClassId"       - The class this feat is for.
  /// "m_Category"      - The FeatType_e enum.
  /// "m_FeatGroupId"   - Id of the feat line if any. The order of the line is defined by DependencyId1.
  /// "m_DependencyId1" - The previous featid you must have to be able to get this feat.


  /// Signal sent when a new feat was trained. The m_FeatList has been update.
  /// @param featId:Number    The feat that was trained.
  public static var SignalFeatTrained:Signal; // -> OnSignalFeatTrained( featId:Number )

  /// Signal sent if all feats were untrained. The m_FeatList has been cleared.
  public static var SignalFeatsUntrained:Signal; // -> OnSignalFeatsUntrained()
  
  /// Signal sent if gamecode wants us to show the feat gui.
  public static var SignalOpenTrainFeatGUI:Signal; // -> OnSignalOpenTrainFeatGUI()

  /// Signal sent if gamecode wants us to close the feat gui.
  public static var SignalCloseTrainFeatGUI:Signal; // -> OnSignalCloseTrainFeatGUI()
  
  // Signal sent when featlist is finished rebuilt
  public static var SignalFeatListRebuilt:Signal;
  
}
