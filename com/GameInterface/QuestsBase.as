import com.GameInterface.Quest;
import com.GameInterface.QuestGiver;
import com.Utils.ID32;
import com.Utils.Signal;

/// Important concepts:
/// Tier == MainQuest in GC == Quest in the quest tool.
/// Task == Quest in GC     == Task in the quest tool.
/// Goal == QuestGoal in GC == Goal in the quest tool.
///
/// A Mission consist of several Tiers linked together.
/// One Tier consist of one or many Tasks and each Task consist of one or many Goals.
/// You can not see the list of Tasks, only the CurrentTask.

intrinsic class com.GameInterface.QuestsBase
{
    /// Delete a tier. 
    /// @param tier:Number  The tier to delete.
    public static function DeleteCurrentQuestOfMainQuest( mainQuestTemplateID:Number ) : Void;

    /// Tell the questgiver that you would like to start the quest in question.
    /// If you got the quest, you should also get a "QuestAdded" signal.
    /// @param idQuestGiver:Number        The quest in question.
    /// @param questGiverType:Number      The type of the questgiver dynel.
    /// @param questGiverInstance:Number  The instance of the questgiver dynel.
    public static function AcceptQuestFromQuestgiver( mainQuestTemplateID:Number, questGiverID:ID32) : Void;

    /// Request infop about this quest
    public static function GetQuest( questID:Number, includeGoals:Boolean, isFromQuestGiver:Boolean ) : Quest;
    
    public static function GetQuestGiver( questGiverID:ID32, includeQuests:Boolean ) : QuestGiver;
    
    public static function GetQuestByQuestGiverID( questGiverID:Number ) : Quest;

    /// This will get an array containing the current missions.
    public static function GetAllAbandonedQuests() : Array;

	/// Returns the ID of the main quest for the quest identified by @a questID, or quests::INVALID_MAINQUEST_ID on error.
	public static function GetMainQuestIDByQuestID() : Number;
    
    /// This will get an array containing the current missions.
    public static function GetAllActiveQuests() : Array;
    
    /// This will get an array of all completed missions.
    public static function GetAllCompletedQuests() : Array;
    
    /// This will get an object containing arrays of completed missions per playfield.
    public static function GetAllCompletedQuestsByRegion() : Object;    
    
    /// Return true if a mission is active.
    public static function IsMissionActive( missionTemplateId:Number ) : Boolean;
    
    /// Return true if a mission is paused.
    public static function IsMissionPaused( missionTemplateId:Number ) : Boolean;
    
    public static function ShareQuest( questID:Number ) : Void;
    
    public static function ShareQuestUnderMouse( questId:Number ) : Void;
    
    public static function ShowQuestOnMap( questID:Number ) : Void;
    
    public static function AcceptQuestReward( taskInstance:Number, index:Number ) : Void;
    
    public static function IsSwitchNecessary(questID:Number) : Boolean;
    
    public static function ShowMedia( rdbType:Number, rdbID:Number ) : Void;

    public static function ShowQuestTaskMedia( questTaskID:Number ) : Void; 
	
	public static function GetSolvedTextForQuest(mainQuestID:Number, questID:Number);
    
    /// Get all uncollected quest rewards.
    /// @return Array of objects with m_QuestTaskID:Number, m_Rewards:Array, m_OptionalRewards:Array
    public static function GetAllRewards() : Array;
    
    /// Returns true or false depening if there are any unsubmitted reports with rewards pending
    /// @return Boolean: Are there quests with reward pending
    public static function AnyUnsentReports() : Boolean;
    
      /// You get this signal when someone has requested seeing the list of available quests for a given object.
      /// This could be triggered by the actionscript or by gamecode.
      /// You get 1 signal per available quest from this questGiverType/questGiverInstance.
      ///
      /// @param idQuestGiver:Number        The quest giver id. Points at exactly 1 quest.
      /// @param questName:String           The name of the quest.
      /// @param mainQuestType:Number       The type of quest. (TODO: figure out the types? Changes in the plan.)
      /// @param unused:Number              Unused.
      /// @param questGiverType:Number      The type of the questgiver dynel.
      /// @param questGiverInstance:Number  The instance of the questgiver dynel.
      /// @param tier:Number                The quest tier.
      public static var SignalQuestAvailable:Signal; // -> OnQuestAvailable( idQuestGiver:Number, questName:String, mainQuestType:Number, unused:Number, questGiverType:Number, questGiverInstance:Number, tier:Number )

      /// You get this signal when something causes the given quest to progress.
      /// This is triggered by gamecode for instance when you kill a monster or pick up an item in the form of having complete 4 of 10.
      /// Note that if a goals SolvedTimes == RepeatCount, then the goal is done. 
      ///
      /// @param tierId:Number        The id of the main quest.
      /// @param goalId:Number        The id of the goal.
      /// @param solvedTimes:Number   The new solved count.
      /// @param repeatCount:Number   The number of times to repeate until done.
      public static var SignalGoalProgress:Signal; // -> OnGoalProgress( tierId:Number, goalId:Number, solvedTimes:Number, repeatCount:Number )

      /// You get this signal when something causes the given quest to update its phase
      /// @param tierId:Number        The id of the main quest.
      public static var SignalGoalPhaseUpdated:Signal; // -> OnGoalPhaseUpdated( tierId:Number)


      /// You get this signal when a goal is completed.
      /// This is triggered by gamecode for instance when you kill a monster or pick up an item in the form of having complete 4 of 10.
      ///
      /// @param tierId:Number        The id of the tier.
      /// @param goalId:Number        The id of the goal.
      public static var SignalGoalFinished:Signal; // -> OnGoalFinished( tierId:Number, goalId:Number )


      /// Different events sent from Task.
      /// e_QuestEvent_Expired,    - A task expired.
      /// e_QuestEvent_Completed,  - A task was completed.
      /// e_QuestEvent_Failed,     - A task failed.
      /// e_QuestEvent_Removed,    - When you get this, the playertiers list is already updated.
      /// e_QuestEvent_RewardChanged,
      /// e_QuestEvent_UntrainCraft
      public static var SignalQuestEvent:Signal; // -> OnQuestEvent( idMainMission:Number, questEvent:Enums.QuestEvent )

      /// This is called when you get a new task. So it would be called when you just got a new tier, and when a task is completed
      /// and there exist more tasks for the given tier. The task number is not important as we only operate with current task.
      ///
      /// @param tierId:Number        The id of the tier.
      public static var SignalTaskAdded:Signal; // -> OnTaskAdded( tierId:Number )

      /// You get this signal when a tier is removed from the list.
      /// Note that this does not say anything about the tier being completed or failed. That info does not seem to exist. Checking the last questevent status might give a clue.
      ///
      /// @param tierId:Number        The id of the main quest.
      public static var SignalMissionRemoved; // ->OnMainQuestRemoved( mainQuestId:Number )

      /// TODO: Document the rest
      public static var SignalPlayerTiersChanged; // ->OnPlayerTiersChanged( ) Called when the questlist has been updated for some reason
      public static var SignalQuestChanged; // ->SlotQuestChanged(questID:Number )

      /// Fired when you complete a tier. TierRemoved will be sent afterwards.
      ///
      /// @param tier:Number        The id of the tier.
      public static var SignalTierCompleted; // ->OnTierCompleted( tier:Number )

      /// Fired when you've failed a tier. TierRemoved will be sent afterwards.
      ///
      /// @param tier:Number        The id of the tier.
      public static var SignalTierFailed; // ->OnTierFailed( tier:Number )
      
      /// Fired when you complete a mission.
      ///
      /// @param missionid:Number        The id of the mission.
      public static var SignalMissionCompleted; // ->OnMissionCompleted( missionID:Number )

      /// Fired when you've failed a tier. TierRemoved will be sent afterwards.
      ///
      /// @param tier:Number        The id of the mission.
      public static var SignalMissionFailed; // ->OnMissionFailed( missionID:Number )
      
      /// Fired when you've failed a tier. TierRemoved will be sent afterwards.
      ///
      /// @param tier:Number        The id of the mission.
      public static var SignalCompletedQuestsChanged; // ->CompletedQuestsChanged()
     
      /// Fired when a quest cooldown changes.
      ///
      /// @param tier:Number       
      /// @param tier:Number       
      
      public static var SignalQuestCooldownChanged;
      
      /// Triggered when you come within 30meter of a questgiver.
      /// Then use this info to call RequestAvailableQuests to see if it has any quests for you.
      /// Note that the c++ ASQuest class must have been setup correctly to use this feature.
      ///
      /// @param type:Number      The type of the quest giver.
      /// @param instance:Number  The instance of the quest giver.
      public static var SignalQuestGiverEnterVicinity:Signal; // -> OnQuestGiverEnterVicinity( type:Number, instance:Number )

      /// Triggered when a questgiver leaves your 30m vicinity. Either caused by distance, death, or playfield shift.
      ///
      /// @param type:Number      The type of the quest giver.
      /// @param instance:Number  The instance of the quest giver.
      public static var SignalQuestGiverLeaveVicinity:Signal; // -> OnQuestGiverLeaveVicinity( type:Number, instance:Number )
      
      /// Triggered when a goal updates its timelimit
      ///
      /// @param goalID:Number The goal template id
      public static var SignalGoalTimeLimitChanged:Signal;
      
      /// Triggered when there is a quest reward to choose.
      public static var SignalQuestRewardMakeChoice:Signal;
      
      /// ???
      public static var SignalQuestRewardInventorySpace:Signal;
      
      /// ???
      public static var SignalQuestRewardAcceptAcknowledged:Signal;        
}
