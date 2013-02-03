import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.Character;
import com.GameInterface.DialogueBase;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Utils;
import gfx.controls.Button;
import gfx.core.UIComponent;
import com.Utils.ID32;
import flash.geom.Point;
import com.Utils.LDBFormat;
import com.GameInterface.MathLib.Vector3;
import com.GameInterface.QuestGiver;
import com.GameInterface.Quests;
import com.GameInterface.Quest;
import GUI.Mission.MissionSignals;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import com.Utils.Colors;
import com.Utils.Signal;
import flash.filters.DropShadowFilter;

class GUI.Dialogue.DialogueWindow extends UIComponent 
{
	/// state enums
    private var MISSION_STATE_IN_PROGRESS:Number = 0;
    private var MISSION_STATE_PAUSED:Number = 1;
    private var MISSION_STATE_COOLDOWN:Number = 2;
    private var MISSION_STATE_IDLE:Number = 3;
    private var MISSION_STATE_LOCKED:Number = 4;
	private var MISSION_STATE_COMPLETE_REPETABLE:Number = 5;
    private var MISSION_STATE_DLC:Number = 6;
	
    private var MOUSE_ACTION_OVER:Number = 0;
    private var MOUSE_ACTION_OUT:Number = 1
    private var MOUSE_ACTION_DOWN:Number = 2;
    private var ACTION_OPEN:Number = 3;
    private var ACTION_DISABLED:Number = 4;
    private var ACTION_ENABLE:Number = 5;
    private var ACTION_DISABLE:Number = 6;
    private var ACTION_OPEN_AND_ENABLE:Number = 7;
        	
	private var m_DynelName:MovieClip;
	private var m_MissionClip:MovieClip;
	private var m_MissionList:Array;
	private var m_DialogueClip:MovieClip;
	private var m_QuestionClips:Array;
	private var m_Questions:Array;
	private var m_Depths:Array;
	
	// properties set in the symbol when being attached (see DialogueController->CreateDialogueWindow())
	private var m_DynelID:ID32; 
	
    private var m_ResolutionScaleMonitor:DistributedValue;
	private var m_Dynel:Dynel;
    private var m_Character:Character;
	private var m_QuestGiver:QuestGiver
	private var m_IsDialogueStarted:Boolean;
	private var m_IsDialogueOpen:Boolean;
	private var m_HasReceivedQuestions:Boolean;
	private var m_CurrentDialoguePlaying:Number;
	
    private var m_IsInCombat:Boolean;
	private var m_IsInteractable:Boolean;
	private var m_IsOpeningInProgress:Boolean;
    private var m_OpenTimer:Number;
	private var m_WasOpen:Boolean;
	private var m_AnimationDuration:Number;
    private var m_TweenDuration:Number;
	private var m_MinInteractionDistance:Number;	
	private var m_ShowNames:Boolean;
    
	private var m_OpenMissionID:Number;
	
	// just a magic number used to control icon sizes, the higher the number, the bigger the icons (not pixel by pixel)
	private var m_IconSizes:Number; 
	private var m_IconSize:Number;
	private var m_IconTotal:Number;
	private var m_MaxScale:Number;
	private var m_TotalSelectorHeight:Number;
	private var m_MinAlpha:Number;
	private var m_MaxAlpha:Number;
    private var m_NormalScale:Number;
	private var m_MinScale:Number;
    private var m_ClipYAnchor:Number;
    private var m_MaxSizedIconX:Number;
    private var m_MissionThrottleIntervalId:Number;
    private var m_MissionThrottleInterval:Number// ms between the throttleeffect
	private var m_EnableInterval:Number;
    
    private var m_PowerRank:Number; // the players power rank, set when loading the UI, and updated when it changes
	
    private var m_Shadow:DropShadowFilter;
    
	private var m_HeadlineTextFormat:TextFormat; // textformat used to check the size of the header text
    private var m_ActionTextFormat:TextFormat; // textformat used to check the space taken by the actiontext (the text to the right on the selectors button, ie. accept, on cooldown...)
    private var m_TimerTextFormat:TextFormat;
	
	private var m_CurrentDialogueMask:MovieClip;
	private var m_LoadingSymbol:MovieClip;
	
	private var m_ShowWindow:Boolean;
		
	function DialogueWindow()
	{
		super();
		m_EnableInterval = -1;
		m_IsDialogueStarted = false;
		m_IsDialogueOpen = false;
		m_HasReceivedQuestions = false;
		m_IsInteractable = false;
		m_ShowWindow = true;
		m_WasOpen = false;
		m_IconSizes = 500;
		m_IconSize = 34;
		m_IconTotal = m_IconSize + 10;
		m_MaxScale = 130;
		m_TotalSelectorHeight = 0;
		m_AnimationDuration = 400;
        m_TweenDuration = m_AnimationDuration / 1000;
		m_MinAlpha = 75;
		m_MaxAlpha = 100;
		m_NormalScale = 90;
		m_MinScale = 80;
		m_MinInteractionDistance = 5;
		m_CurrentDialoguePlaying = -1;
        m_MissionThrottleIntervalId = -1;
        m_MissionThrottleInterval = 2000; 
		m_MaxSizedIconX = (m_IconSize - (m_IconSize * (m_MaxScale / 100)));
        
		m_OpenMissionID = -1;
		m_IsOpeningInProgress = false;
		
        m_ResolutionScaleMonitor = DistributedValue.Create("GUIResolutionScale");
		m_Dynel = Dynel.GetDynel(m_DynelID);
        m_Character = Character.GetClientCharacter();
		m_QuestGiver = Quests.GetQuestGiver(m_DynelID, true);
		
		DialogueBase.SignalVoiceStarted.Connect(SlotVoiceStarted, this);
		DialogueBase.SignalVoiceFinished.Connect(SlotVoiceFinished, this);
		DialogueBase.SignalVoiceAborted.Connect(SlotVoiceAborted, this);
		
		m_QuestionClips = new Array();
		m_MissionList = new Array();
        
         m_Shadow = new DropShadowFilter(1, 35, 0x000000, 0.7, 1, 2, 2, 3, false, false, false);
		
        m_Character.SignalToggleCombat.Connect(SlotToggleCombat, this);
        m_IsInCombat = m_Character.IsInCombat();

        m_Character.SignalStatChanged.Connect(SlotStatUpdated, this);
        SlotStatUpdated(_global.Enums.Stat.e_PowerRank);
        
        m_TimerTextFormat = new TextFormat;
        m_TimerTextFormat.font = "_TimerFont";
        m_TimerTextFormat.size = 12;
        m_TimerTextFormat.color = Colors.e_ColorLightOrange;
        
        m_HeadlineTextFormat = new TextFormat();
        m_HeadlineTextFormat.font = "_Headline";
        m_HeadlineTextFormat.size = 15;
        
        m_ActionTextFormat = new TextFormat();
        m_ActionTextFormat.font = "_Headline";
        m_ActionTextFormat.size = 12;
        
        m_ClipYAnchor = 38;// m_DynelName._height + 5;
        
	}
	
	function configUI()
	{
		super.configUI();
		Clear();
		Draw();
        SetMissionThrottle()
		
	}
    
    public function onUnload()
    {
        super.onUnload();
        if (m_MissionThrottleIntervalId > -1)
        {
            clearInterval(m_MissionThrottleIntervalId);
        }
        DistributedValue.SetDValue("ForceShowMissionTracker", false);
    }

    private function onMousePress(buttonIndex:Number, clickNumber:Number)
    {
        swapDepths(_parent.getNextHighestDepth());
    }
    
	function SlotToggleCombat(enterCombat:Boolean)
    {
        m_IsInCombat = enterCombat;
    }
    
    function SlotStatUpdated(statId:Number)
    {
        if (statId == _global.Enums.Stat.e_PowerRank)
        {
            m_PowerRank = m_Character.GetStat(statId, 2);
        }
    }
	
	function SlotVoiceStarted(voiceHandle:Number)
	{
		clearInterval(m_EnableInterval);
		
		if (m_CurrentDialoguePlaying != -1)
		{
			m_QuestionClips[m_CurrentDialoguePlaying].SetVoiceHandle(voiceHandle);
			m_QuestionClips[m_CurrentDialoguePlaying].SetIsPlaying(true);
		}
		
        /// tell all conversations the to disable until the ongoing is done
        for (var i:Number = 0; i < m_QuestionClips.length; i++)
        {
            m_QuestionClips[ i].SetDisabled(true)
        }
	}
	
	function SlotVoiceFinished(voiceHandle:Number)
	{
		var voiceHandleClip = GetVoiceEntry(voiceHandle);
		if (voiceHandleClip != undefined)
		{
			voiceHandleClip.SetVoiceHandle(-1);
			voiceHandleClip.SetIsPlaying(false);
		}
        /// tell all conversations the chitchat is done
        for (var i:Number = 0; i < m_QuestionClips.length; i++)
        {
            m_QuestionClips[ i].SetDisabled(false)
        }
	}
	
	function SlotVoiceAborted(voiceHandle:Number)
	{
		SlotVoiceFinished(voiceHandle);
	}
	
	function GetVoiceEntry(voiceHandle:Number)
	{
		for (var i:Number = 0; i < m_QuestionClips.length; i++)
		{
			if (m_QuestionClips[i].GetVoiceHandle() == voiceHandle)
			{
				return m_QuestionClips[i];
			}
		}
		return undefined;
	}
	    
    function onEnterFrame() : Void
    {
        UpdateWindow();
    }
	
	private function UpdateWindow()
	{
        var los:Boolean = m_Dynel.IsRendered();
        /// hide and disable clicks on the missionWindow if it is blocked
        if (!los)
        {
            _visible = false;
            hitTestDisable = true;
        }
        else
        {
            if (!_visible)
            {
                _visible = m_ShowWindow;
                hitTestDisable = false;
            }
            var charpos:Vector3 = m_Character.GetPosition(_global.Enums.AttractorPlace.e_CameraAim);
            var dynelPos:Vector3 = m_Dynel.GetPosition(_global.Enums.AttractorPlace.e_CameraAim);
            var characterDistance:Number = Vector3.Sub(charpos, dynelPos).Len();
            
            var distance:Number = Math.min(m_Dynel.GetCameraDistance(), 10);
			_z = m_Dynel.GetCameraDistance();
            
            m_IsInteractable = (characterDistance < m_MinInteractionDistance && !m_IsInCombat);
            
            var realScale:Number = (m_IconSizes / distance);

            // Scale it according to the global scalefactor.
            realScale = Math.min(250, realScale * m_ResolutionScaleMonitor.GetValue());
			
			var pos:Point = m_Dynel.GetScreenPosition(141);
			
			_x = pos.x;
			_y = pos.y;
			
            _xscale = realScale;
            _yscale = realScale;

            if (this._height >= Stage["visibleRect"].height)
            {
                _alpha = Math.max(0, _alpha - 2);
            }
            else
            {
                _alpha = Math.min(100, _alpha + 2);
            }
			
			
			if (characterDistance < 5)
			{
				if (m_Dynel.HasDialogue() && !m_IsDialogueStarted)
				{
					DialogueBase.StartConversation(m_DynelID);
					m_IsDialogueStarted = true;
				}
			}
			else
			{
				EndConversation();
			}
        }		
	}
    
    private function SetMissionThrottle()
    {
        if (m_MissionThrottleIntervalId > -1)
        {
            clearInterval(m_MissionThrottleIntervalId);
        }
        m_MissionThrottleIntervalId = setInterval(Delegate.create(this, AnimateUnusedMissions),m_MissionThrottleInterval);
    }
    
    /// calls a throttle effect on missions you have not yet had
    private function AnimateUnusedMissions()
    {
        
        for (var i:Number = 0; i < m_MissionList.length; i++)
        {
            if (m_MissionList[i].state == MISSION_STATE_IDLE)
            {
                m_MissionList[i].m_Icon.m_IconAnimation.gotoAndPlay("throttle");
            }
        }
    }
	
	//////////// DIALOGUE STUFF ////////////////
	
	private function ToggleDialogue()
	{
		Selection.setFocus(null);
		if (!m_IsDialogueOpen)
		{
			if (m_HasReceivedQuestions)
			{
				OpenDialogue();
			}
			else
			{
				m_LoadingSymbol = m_DialogueClip.attachMovie("LoadingSymbol", "loading", m_DialogueClip.getNextHighestDepth());
				m_LoadingSymbol._x = m_DialogueClip.m_DialogueButton._width + 10;
				_global.setTimeout(this, "CheckOpenDialogue", 500);
			}
		}
		else if(m_IsDialogueOpen)
		{
			CloseDialogue();
		}
	}
	
	public function CheckOpenDialogue()
	{
		if (m_HasReceivedQuestions)
		{
			if (m_LoadingSymbol != undefined)
			{
				m_LoadingSymbol.removeMovieClip();
				m_LoadingSymbol = undefined;
			}
			OpenDialogue();
		}
		else
		{
			_global.setTimeout(this, "CheckOpenDialogue", 500);
		}
	}
	
	public function OpenDialogue()
	{
		m_IsDialogueOpen = true;
        m_ShowNames = true;
		
        m_DialogueClip.m_Frame._alpha = m_MinAlpha;
        
        m_DialogueClip.m_DialogueEntries._alpha = m_MinAlpha;
        
        m_DialogueClip.tweenTo(m_TweenDuration, { _y:m_ClipYAnchor, _yscale:m_MaxScale, _xscale:m_MaxScale, _x:m_MaxSizedIconX }, None.easeNone);
		m_DialogueClip.onTweenComplete = undefined; // Delegate.create(this, RemoveDialogueMask);
        
        if(m_OpenMissionID < 0) 
		{
            m_DynelName.gotoAndPlay("hide");
        }
        
        if (m_MissionClip != undefined)
		{
            CloseAllMissionClips();
            var missionY:Number = -((m_MissionList.length * m_IconTotal));
            m_MissionClip.tweenTo(m_TweenDuration, { _y: missionY }, None.easeNone);
		    m_MissionClip.onTweenComplete = undefined
		}
        
        FillQuestions();
	}

	public function CloseDialogue()
	{
        m_IsDialogueOpen = false;
        m_ShowNames = false;
        if (m_MissionClip != undefined)
        {
            m_MissionClip.tweenTo(m_TweenDuration, { _y: 10}, None.easeNone);
		    m_MissionClip.onTweenComplete = undefined
            
            for (var i:Number = 0; i < m_MissionList.length; i++)
            {
                var movieClip:MovieClip = m_MissionList[i];
                movieClip.m_Button.gotoAndPlay("close");
            }
            
        }
        
        m_DynelName.gotoAndPlay("show");
        
        var dialogueY:Number = m_ClipYAnchor + (m_MissionList.length * m_IconTotal) +10;
        m_DialogueClip.tweenTo(m_TweenDuration, { _y:dialogueY,_yscale:m_MinScale, _xscale:m_MinScale, _x: 0 }, None.easeNone);
		m_DialogueClip.onTweenComplete = undefined
        
        m_DialogueClip.m_Frame._alpha = 0;
        
        CloseDialogueContent();
	}
    
    private function CloseDialogueContent(snap:Boolean) : Void
    {
        if (snap)
        {
            m_DialogueClip.m_DialogueEntries._alpha = 0; 
            
        }
        else
        {
            m_DialogueClip.m_DialogueEntries.tweenTo(m_TweenDuration, { _alpha: 0 }, None.easeNone);
            m_DialogueClip.m_DialogueEntries.onTweenComplete = undefined;//Delegate.create(this, CleanDialogue);
        }
        m_DialogueClip.m_DialogueEntries.hitTestDisable = true;
    }
	
	public function CleanDialogue()
	{
		ClearQuestions();
        m_IsDialogueOpen = false;

		m_DialogueClip.m_DialogueEntries.removeMovieClip();		
	}
	
	public function EndConversation()
	{
		if (m_IsDialogueStarted && m_Dynel.HasDialogue())
		{
			DialogueBase.EndConversation(m_DynelID);
		}
		m_IsDialogueStarted = false;
	}
	
	public function SetQuestions(questions:Array)
	{
		m_HasReceivedQuestions = true;
				
		m_Questions = questions;
		
		if (m_IsDialogueOpen)
		{
			FillQuestions();
		}
	}
	
	public function SetTopicDepths(depths:Array)
	{
		m_Depths = depths;
		
		for (var i:Number = 0; i < depths.length; i++)
		{
			if (m_QuestionClips[i] != undefined)
			{
				m_QuestionClips[i].SetDepth(depths[i]);
			}
		}
	}
	
	private function FillQuestions()
	{
		//Only Create if they are not created or if we need to resize the questionarray
		if (m_QuestionClips.length == 0 || m_QuestionClips.length != m_Questions.length)
		{
			ClearQuestions();
			var y:Number = 0;
			for (var i:Number = 0; i < m_Questions.length; i++)
			{
				var entry = m_DialogueClip.m_DialogueEntries.attachMovie("DialogueEntry", "dialogueentry_" +i, m_DialogueClip.m_DialogueEntries.getNextHighestDepth());
				if (m_Depths != undefined)
				{
					entry.SetDepth(m_Depths[i]);
				}
				entry.SetIndex(i);
				entry.SignalClicked.Connect(SlotQuestionChosen, this);
				entry._y += y;

				m_QuestionClips.push(entry);
				y += entry._height + 3;
			}
		}
		
		for (var i:Number = 0; i < m_Questions.length; i++)
		{
			m_QuestionClips[i].SetText(m_Questions[i]);
		}
        
        m_DialogueClip.m_DialogueEntries.hitTestDisable = false;
	}
	
	private function SlotQuestionChosen(index:Number, topicDepth:Number)
	{
		DialogueBase.JumpToTopic(m_DynelID, index, topicDepth);
		m_QuestionClips[index].SetIsPlaying(true);
		m_CurrentDialoguePlaying = index;
		m_IsDialogueStarted = true;
        
		//Disable all dialogue immidiately to not be able to spam, but enable it after half a second if we havent gotten any answer from the server
        for (var i:Number = 0; i < m_QuestionClips.length; i++)
        {
            if (i != index)
            {
                m_QuestionClips[i].SetDisabled(true);
            }
        }
	}
	
	private function ClearQuestions()
	{
		for (var i:Number = 0; i < m_QuestionClips.length; i++)
		{
			m_QuestionClips[i].removeMovieClip();
		}
		m_QuestionClips = [];
		
	}
	
	////////////// MISSION STUFF //////////////////
	
    function SlotMissionCompleted(missionID:Number)
    {
        RedrawMissions()
        
        Utils.PlayFeedbackSound("sfx/gui/gui_mission_complete.wav")
    }
    
    function SlotQuestAvailable(idQuestGiver:Number, questName:String, mainQuestType:Number, unused:Number, questGiverType:Number, questGiverInstance:Number, tier:Number) : Void
    {
        RedrawMissions();
    } 

    function SlotTaskAdded(missionID:Number)
    {
        RedrawMissions();
    }
    
    function SlotQuestCooldownChanged(cooldownEvent:Number, cooldownID:Number)
    {
        RedrawMissions();
    }

    function SlotTierCompleted()
    {
        Utils.PlayFeedbackSound("sfx/gui/gui_tier_complete.wav")  
    }

    function SlotTierRemoved(missionID:Number)
    {
        RedrawMissions();
    }

    function SlotQuestEvent(missionID:Number, questEventID:Number)
    {
        if (questEventID == 4)
        {
			RedrawMissions();
        }
    }
    
    private function SlotQuestChanged()
    {
    }
	
	private function Clear()
	{
		ClearMissions();
		if (m_DialogueClip != undefined)
		{
			m_DialogueClip.removeMovieClip();
		}
	}
	
	private function Draw()
	{
		var needsName:Boolean = false;
		if (m_Dynel.IsMissionGiver())
		{
			Quests.SignalQuestAvailable.Connect(SlotQuestAvailable, this);        
			Quests.SignalMissionCompleted.Connect(SlotMissionCompleted, this);
			Quests.SignalTaskAdded.Connect(SlotTaskAdded, this);
			Quests.SignalTierCompleted.Connect(SlotTierCompleted, this);
			Quests.SignalMissionRemoved.Connect(SlotTierRemoved, this);
			Quests.SignalQuestEvent.Connect(SlotQuestEvent, this);
			Quests.SignalQuestCooldownChanged.Connect(SlotQuestCooldownChanged, this);        
			Quests.SignalQuestChanged.Connect(SlotQuestChanged, this);
			
			DrawMissions();
			needsName = true;
		}
        if (m_Dynel.HasDialogue())
		{
			needsName = true;
			DrawDialogue();
		}
		if (needsName)
		{
            m_DynelName = attachMovie("DynelName", "m_DynelName", getNextHighestDepth());
			m_DynelName.m_Name.textField.text = LDBFormat.Translate(m_Dynel.GetName());
		}
		
		CheckHide();
	}
	
	private function CheckHide()
	{
		if (m_DialogueClip == undefined && m_MissionList.length == 0)
		{
			m_ShowWindow = false;
			_visible = false;
		}
		else
		{
			m_ShowWindow = true;
			_visible = true;
		}
	}
	
	public function RedrawMissions()
	{
		ClearMissions();
        
        //Get the info again for the questgiver as some things might be updated
        m_QuestGiver = Quests.GetQuestGiver(m_DynelID, true);
        
		DrawMissions();
		
		CheckHide();
	}
	
	private function DrawDialogue()
	{
		m_DialogueClip = createEmptyMovieClip("m_DialogueClip", getNextHighestDepth());
        m_DialogueClip._y = m_ClipYAnchor + (m_MissionList.length * m_IconTotal) +10;
        m_DialogueClip._xscale = m_MinScale;
        m_DialogueClip._yscale = m_MinScale;
		
        var button = m_DialogueClip.attachMovie("Icon_Dialogue", "m_DialogueButton", m_DialogueClip.getNextHighestDepth(), { _xscale:m_NormalScale, _yscale:m_NormalScale });
		button.disableFocus = true;
		button.addEventListener("click", this, "ToggleDialogue");
       
        var dialogueEntries:MovieClip = m_DialogueClip.createEmptyMovieClip("m_DialogueEntries", m_DialogueClip.getNextHighestDepth());
        dialogueEntries._x = button._width + 10;
        dialogueEntries._y = button._height + 10;
        
        var frame = m_DialogueClip.attachMovie("DialogueFrame", "m_Frame", m_DialogueClip.getNextHighestDepth());
		frame._x = button._width + 10;
		frame.m_FrameText.text = LDBFormat.LDBGetText("GenericGUI", "Dialogue");;
        
        frame._alpha = 0;
	}
	
	public function DrawMissions()
	{
		m_MissionClip = createEmptyMovieClip("m_MissionClip", getNextHighestDepth());
        m_MissionClip._y = m_ClipYAnchor
		var quests:Array = m_QuestGiver.m_AvailableQuests;

		//Sort by sort order
		quests.sort(QuestCompare);

		var openClip:MovieClip = undefined;
        /// Add clips
        for (var i:Number = 0; i < quests.length; i++)
        {
			var quest:com.GameInterface.Quest = quests[i];
            var questID:Number = quest.m_ID;

            if (!(quest.m_HideIfLocked && quest.m_IsLocked) && (quest.m_IsRepeatable || !quest.m_HasCompleted))
            {
                // mc != null && 
                var mc:MovieClip = CreateSingleSelector(quest, m_MissionList.length);
                m_MissionList.push(mc);
      			if (m_OpenMissionID == questID)
                {
                    openClip = mc;
                }
            }

        }

        /// after redrawing, reopen with snap
        if (m_OpenMissionID > -1 && IsMissionValid(m_OpenMissionID))
        {
            AnimateSelector(mc.m_Icon, true);
        }
	}
  
    function QuestCompare(a:Quest, b:Quest):Number
	{
		return a.m_SortOrder - b.m_SortOrder;
	}
	  
    private function ClearMissions()
    {
        for (var i:Number = 0; i < m_MissionList.length; i++)
        {
            m_MissionList[i].removeMovieClip();
        }
        
        m_MissionList = [];
		
		if (m_MissionClip != undefined)
		{
			m_MissionClip.removeMovieClip();
		}
    }
	
	    /// returns the current state of the mission
    ///
    private function GetMissionState(quest:Quest)
    {
        if (Quests.IsMissionActive(quest.m_ID))
        {
            return MISSION_STATE_IN_PROGRESS;
        }
        else if (quest.m_CooldownExpireTime != undefined && quest.m_CooldownExpireTime > 0)
        {
            return MISSION_STATE_COOLDOWN;
        }
        else if (Quests.IsMissionPaused(quest.m_ID))
        {
            return MISSION_STATE_PAUSED;
        }
		else if (quest.m_IsLocked)
		{
			return MISSION_STATE_LOCKED;
		}
		else if (quest.m_IsRepeatable && IsMissionCompleted(quest.m_ID))
		{
			return MISSION_STATE_COMPLETE_REPETABLE;
		}
        else if (quest.m_MissionIsDLC)
		{
			return MISSION_STATE_DLC;
		}
        else
        {
            return MISSION_STATE_IDLE;
        }
    }
	
    /// Checks if a given id is a valid quest (to see if it was not removed)
    /// @param is:Number -  the quest id to validate
    /// @return boolean, true if quest is valid
    private function IsMissionValid(id:Number):Boolean
    {
        var quests:Array = Quests.GetAllActiveQuests();
        
        for (var i = 0; i < quests.length; ++i)
        {
            var quest:com.GameInterface.Quest = quests[i];
            if (quest.m_ID == id)
            {
                return true;
            }
        }
        return false;
    }
	
	
	private function IsMissionCompleted(id:Number):Boolean
	{
        var quests:Array = Quests.GetAllCompletedQuests();
        
        for (var i = 0; i < quests.length; ++i)
        {
            var quest:com.GameInterface.Quest = quests[i];
            if (quest.m_ID == id)
            {
                return true;
            }
        }
        return false;
	}
	
	 /// attaches an instance of the Selector library item to the i_Frame and populates it with 
    /// data from the Quests.m_AvailableTiers object
	private function CreateSingleSelector(quest:com.GameInterface.Quest, currentIndex:Number) : MovieClip
    {   
        var currentTask:com.GameInterface.QuestTask = quest.m_CurrentTask;
        var questState:Number = GetMissionState(quest);
        var isSwitchNecessary:Boolean = Quests.IsSwitchNecessary(quest.m_Tiers[0].m_ID);
        var isOpen:Boolean = m_OpenMissionID == quest.m_ID;
        
        /// the selector, a container for all assets belonging to one mission, atatching reference to all important properties here
        var selectorItem:MovieClip = m_MissionClip.attachMovie("Selector", "selector_" + quest.m_ID, m_MissionClip.getNextHighestDepth());
        selectorItem._y = (currentIndex * m_IconTotal) + 10;
        selectorItem._xscale = m_MinScale;
        selectorItem._yscale = m_MinScale;
        selectorItem["id"] = quest.m_ID;
        selectorItem["index"] = currentIndex;
        selectorItem["type"] = quest.m_MissionType
        selectorItem["state"] = questState;
        selectorItem["isSwitchNecessary"] = isSwitchNecessary;
        
        //The Mission type icon and its modifier
        var missionIcon:MovieClip = selectorItem.attachMovie("_Icon_Mission_" + GUI.Mission.MissionUtils.MissionTypeToString(quest.m_MissionType), "m_Icon", selectorItem.getNextHighestDepth(), {_xscale:m_NormalScale, _yscale:m_NormalScale});
        missionIcon.disableFocus = true;
        missionIcon.doubleClickEnabled = true;
        missionIcon.addEventListener("click", this, "SlotMissionIconClicked");
 
        AddIconModifier(questState, missionIcon);/// adds the icon modifier if any
                
        /// get the requirements for text
        var missionName:String = LDBFormat.Translate(quest.m_MissionName );
        var headlineWidth:Number = m_HeadlineTextFormat.getTextExtent(missionName).textFieldWidth;
        var actionText:String = GetActionText(questState);
        var actionWidth:Number = m_ActionTextFormat.getTextExtent(actionText).textFieldWidth;
        
        selectorItem.m_Button.m_MissionTitle.textField.text = missionName;
		selectorItem.m_Button.m_WarningText.autoSize = "left";

        selectorItem.m_Button.m_ActionText.textField.text = actionText;
        selectorItem.m_Button.hitTestDisable = true;
        
        if ((headlineWidth + actionWidth) > 330) // if required space is bigger than provided
        {
            selectorItem.m_Button.m_MissionTitle.textField._width = 330 - actionWidth - 10;
            Utils.TruncateText(selectorItem.m_Button.m_MissionTitle.textField);
        }
        
        /// set the button to the disabled state
        MoveButtonPlayhead(selectorItem.m_Button, ACTION_DISABLED, isSwitchNecessary, questState, quest.m_ID, quest.m_MissionType);
		
        var subTextContainer:MovieClip = selectorItem.createEmptyMovieClip("m_SubTextContainer", selectorItem.getNextHighestDepth());
        
        /// adds a cooldown timer if any
        if(questState == MISSION_STATE_COOLDOWN)
        {    
            subTextContainer.m_Cooldown = quest.m_CooldownExpireTime;
            /// sub text
            var cooldownText:TextField = subTextContainer.createTextField("m_CooldownText", subTextContainer.getNextHighestDepth(),0, 37, 0, 0, 0);
            cooldownText.selectable = false;
            cooldownText.autoSize = "left";
            cooldownText.setNewTextFormat(m_TimerTextFormat);
            cooldownText.text = "";
            cooldownText._x = 55;

        }
        else
        {
            var difficultyText:TextField = subTextContainer.createTextField("m_DifficultyText", subTextContainer.getNextHighestDepth(),0, 37, 0, 0, 0);
            difficultyText.selectable = false;
            difficultyText.autoSize = "left";
            difficultyText.html = true;
            difficultyText.filters = [m_Shadow];
            difficultyText.htmlText =  "<b>"+GUI.Mission.MissionUtils.GetMissionDifficultyText(quest.m_CurrentTask.m_Difficulty - m_PowerRank, {face: "_StandardFont", size:14})+"</b>";
            difficultyText._x = 55
        }
        
        subTextContainer._alpha = 0;


        
        // The container for the mission
        selectorItem.m_Content._visible = false;
        selectorItem.m_Content.hitTestDisable = true;
        selectorItem.m_Content.m_MissionDescriptionTextField.autoSize = true;
        selectorItem.m_Content.m_MissionDescriptionTextField.text = quest.m_MissionDesc;
        
        // tier description
        selectorItem.m_Content.m_TierDescriptionTextField.autoSize = true;
        selectorItem.m_Content.m_TierDescriptionTextField.text = LDBFormat.LDBGetText("Quests", "Mission_Tier") + " " + currentTask.m_Tier + "  " + currentTask.m_TierDesc;
        selectorItem.m_Content.m_TierDescriptionTextField._y = selectorItem.m_Content.m_MissionDescriptionTextField._height + 15;
        
        // rewardframe
        selectorItem.m_Content.m_RewardFrame._y =  selectorItem.m_Content.m_TierDescriptionTextField._y + selectorItem.m_Content.m_TierDescriptionTextField._height + 5;
        selectorItem.m_Content.m_RewardFrame.m_XPTextField.autoSize = true;
        selectorItem.m_Content.m_RewardFrame.m_XPTextField.text =  quest.m_Xp;
        
        selectorItem["height"] = selectorItem.m_Content._height + selectorItem.m_Content._y;
     
        /// mouse events
        var rootScope:Object = this;
  
        selectorItem.m_Button.onRollOver = function()
        {
            if (!rootScope.m_IsInteractable)
            {
                return;
            }
            var parent:Object = this._parent;
            if(rootScope.IsMissionOpen(parent.id))
            {
                rootScope.MoveButtonPlayhead(this, rootScope.MOUSE_ACTION_OVER, parent.isSwitchNecessary, parent.state, parent.id, parent.type);
            }
        }

        selectorItem.m_Button.onRollOut = function()
        {
            if (!rootScope.m_IsInteractable)
            {
                return;
            }
            var parent:Object = this._parent;
            if(rootScope.IsMissionOpen(parent.id))
            {
                rootScope.MoveButtonPlayhead(this, rootScope.MOUSE_ACTION_OUT, parent.isSwitchNecessary, parent.state, parent.id, parent.type);
            }
        }

        selectorItem.m_Button.onRelease = function()
        {
            var parent:MovieClip = this._parent;
           
            if (!rootScope.m_IsInteractable)
            {
                return;
            }
            
            if(rootScope.IsMissionOpen(parent.id))
            {
                rootScope.MoveButtonPlayhead(this, rootScope.MOUSE_ACTION_DOWN, parent.isSwitchNecessary, parent.state, parent.id, parent.type);
                var event:Object = new Object();
                event.target = this;
                rootScope.SlotMissionIconClicked({target:this});
                Quests.AcceptQuestFromQuestgiver(parent.id, m_DynelID);
            }
        }
        
        return selectorItem;
    }
	
	function SlotMissionIconClicked(event:Object)
	{
        var target:MovieClip = event.target;
        var index:Number = target._parent.index;
        
        if (m_DialogueClip != undefined)
        {
            var dialogueAlpha:Number = 0;
            if (m_OpenMissionID < 0 || m_OpenMissionID != m_MissionList[ index ].id)
            {
                dialogueAlpha = m_MinAlpha;
            }
            m_DialogueClip.m_Frame.tweenTo(m_TweenDuration, { _alpha:dialogueAlpha }, None.easeNone);
        }
        
		AnimateSelector(target, false);
	}
    
    private function CooldownFrameHandler()
    {
        var t:Number = (this["m_Cooldown"] - Utils.GetServerSyncedTime()) * 1000;
        if (t < 1000)
        {
            this.onEnterFrame = undefined;
        }
        this["m_CooldownText"].text = com.Utils.Format.Printf("%02.0f:%02.0f:%02.0f",Math.floor(t / 3600000), Math.floor(t / 60000) % 60, Math.floor(t / 1000) % 60); 
    }
    
    private function AddIconModifier(state:Number, parent:MovieClip)
    {
        var modifier:MovieClip;
        if (state == MISSION_STATE_PAUSED)
        {
            modifier = parent.attachMovie("_Icon_Modifier_Paused", "i_Paused", parent.getNextHighestDepth());
        }
        else if (state== MISSION_STATE_IN_PROGRESS)
        {
            modifier = parent.attachMovie("_Icon_Modifier_InProgress", "i_InProgress", parent.getNextHighestDepth());
        }
        else if (state == MISSION_STATE_COOLDOWN)
        {
            modifier = parent.attachMovie("_Icon_Modifier_Cooldown", "i_Cooldown", parent.getNextHighestDepth());
        }
		else if (state == MISSION_STATE_LOCKED)
		{
			modifier = parent.attachMovie("_Icon_Modifier_Lock", "i_Lock", parent.getNextHighestDepth());
		}
		else if (state == MISSION_STATE_COMPLETE_REPETABLE)
		{
			modifier = parent.attachMovie("_Icon_Modifier_Checked", "i_Checked", parent.getNextHighestDepth());
		}
        else if (state == MISSION_STATE_DLC)
        {
            modifier = parent.attachMovie("_Icon_Modifier_DLC_Lock", "i_DLC_Lock", parent.getNextHighestDepth());
        }
        
        modifier._x = parent._width - 19;
        modifier._y = parent._height - 19;
    }

    private function GetActionText(state:Number) : String
    {
        if (state == MISSION_STATE_PAUSED)
        {
            return LDBFormat.LDBGetText("Quests", "Mission_Paused");
        }
        else if (state == MISSION_STATE_IN_PROGRESS)
        {
            return LDBFormat.LDBGetText("Quests", "Mission_InProgress");;
        }
        else if (state == MISSION_STATE_COOLDOWN)
        {
            return LDBFormat.LDBGetText("Quests", "Mission_OnCooldown")
        }
        else
        {
            return LDBFormat.LDBGetText("Quests", "Mission_Accept");;
        }
    }
	
    /// For the selectorbutton, moves the playhead
    /// @param button:MovieClip - the button to update
    /// @param action:Number - the action to perform, opne, close ...
    /// @param isActive:Boolean - is the mission type active
    /// @param state:Number - the state of the mission, paused, in progress....
    private function MoveButtonPlayhead(button:MovieClip, action:Number, isSwitchNecessary:Boolean, state:Number, questID:Number, missionType:Number)
	{
        if (action == MOUSE_ACTION_OVER)
        {
            if (state == MISSION_STATE_LOCKED)
            {
                button.gotoAndPlay("over_exists");
                button.m_WarningText.htmlText = LDBFormat.LDBGetText("QuestUnavailableFeedback", questID);
                var oldHeight:Number = button.m_WarningTextBackground._height;
                button.m_WarningTextBackground._height = button.m_WarningText.textHeight + 10;
                button.m_WarningTextBackground._y -= button.m_WarningTextBackground._height - oldHeight
                
            }
            else if (!isSwitchNecessary || state == MISSION_STATE_PAUSED) 
            {
                button.gotoAndPlay("over");
            }
            else
            {
                if (state == MISSION_STATE_IN_PROGRESS)
                {
                    button.gotoAndPlay("over_inprogress");
                }
                else
                {
                    button.gotoAndPlay("over_exists");
                    button.m_WarningText.htmlText = LDBFormat.LDBGetText("Quests", "Mission_SelectWillCancel");
                }
            }
			
			MissionSignals.SignalHighlightMissionType.Emit(missionType, true);
			button.m_WarningText._height = button.m_WarningText.textHeight + 5;
			button.m_WarningText._y = -(button.m_WarningText._height);
            
        }
        else if (action == MOUSE_ACTION_OUT)
        {
			MissionSignals.SignalHighlightMissionType.Emit(missionType, false);
            if (!isSwitchNecessary || state == MISSION_STATE_PAUSED)
            {
                button.gotoAndPlay("up");
            }
            else
            {
                if(state == MISSION_STATE_IN_PROGRESS)
                {
                    button.gotoAndPlay("up_inprogress");
                }
                else
                {
                    button.gotoAndPlay("up_exists");
                }
            }
        }
        else if (action == ACTION_OPEN)
        {
            if (!isSwitchNecessary)
            {
                //button.gotoAndStop("open_normal")
                button.gotoAndPlay("open");
            }
            else
            {
                button.gotoAndStop("open_inprogress");
                button.i_WarningText.text = LDBFormat.LDBGetText("Quests", "Mission_SelectWillCancel");;
            }
        }
        else if (action == MOUSE_ACTION_DOWN)
        {
            button.gotoAndPlay("down")
        }
        else if (action == ACTION_DISABLED)
        {
            button.gotoAndStop("disabled")
        }
        else if (action == ACTION_ENABLE)
        {
            button.gotoAndPlay("enable");
        }
        else if (action == ACTION_DISABLE)
        {
            button.gotoAndPlay("disable");
        }
        else if (action == ACTION_OPEN_AND_ENABLE)
        {
            button.gotoAndPlay("openenable");
        }
    }
	
	public function IsMissionOpen(missionID:Number)
	{
		return m_OpenMissionID == missionID;
	}
   
    private function CloseAllMissionClips(snap:Boolean)
    {
        m_OpenMissionID = -1
        for (var i:Number = 0; i < m_MissionList.length; i++)
        {
            var y:Number = m_ClipYAnchor + (i * m_IconTotal);
            m_MissionList[i].m_SubTextContainer._alpha = 0;
            Animate(m_MissionList[i], y, snap);
        }
        
        DistributedValue.SetDValue("ForceShowMissionTracker", false);
    }
	
	/// Fires when a mission icon from the mission selector interface has been clicked
	/// can and will be optimised.
	/// But not  today
	public function AnimateSelector(movieclipIcon:MovieClip, snap:Boolean, callee:String) : Void
	{
		if ((movieclipIcon._parent.state == MISSION_STATE_LOCKED || m_IsOpeningInProgress) && callee == "mission")
        {
            return;
        }
        
        if (m_IsDialogueOpen)
        {
            m_IsDialogueOpen = false;
            CloseDialogueContent(snap);
        }
        
        var index:Number = movieclipIcon._parent.index;		
        var dialogueY:Number;
        var missionClipY:Number;
        var missionLength:Number = m_MissionList.length
        // opening or reopening
        if (m_OpenMissionID < 0 || m_OpenMissionID != m_MissionList[ index ].id)
		{
			DistributedValue.SetDValue("ForceShowMissionTracker", true);
            m_ShowNames = true;
			//None is open, so hide the name
			if(m_OpenMissionID < 0) 
			{
                m_DynelName.gotoAndPlay("hide");
            }
			
            
            var i:Number;
            /// iterate and set the m_OpenMissionId to the selected id            
            for (i = 0; i < missionLength; i++)
            {
                if(i == index)
                {
                    m_OpenMissionID = m_MissionList[i].id;
                    break;
                }
            }
           
            var newY:Number = 0;
            
            for(var i:Number = 0; i < missionLength; i++)
            {
                var selectorItem:MovieClip = m_MissionList[i];

                if(i == index)
                {
                    CooldownLayout(selectorItem, true);
                    selectorItem.m_SubTextContainer._alpha = 100; // enable the mission difficulty text
					m_OpenMissionID = selectorItem.id;
                    Animate(selectorItem, newY, snap);
                    newY += (selectorItem.height + 10) * (m_MaxScale * 0.01);
                }
                else
                {
                    CooldownLayout(selectorItem, false);
                    selectorItem.m_SubTextContainer._alpha = 0;
                    Animate(selectorItem, newY, snap);
                    newY += m_IconTotal;
                }
            }

            missionClipY = -(index * m_IconTotal)
            dialogueY = newY + missionClipY;
            m_WasOpen = true; 
        }
        else
        { 
			DistributedValue.SetDValue("ForceShowMissionTracker", false);
            m_DynelName.gotoAndPlay("show");

            m_OpenMissionID = -1;
            m_ShowNames = m_IsDialogueOpen;
            if (!m_IsDialogueOpen)
            {
                if (m_DialogueClip.m_Frame._alpha > 0 && m_ShowNames)
                {
                    m_DialogueClip.m_Frame.tweenTo(m_TweenDuration, { _alpha:0 }, None.easeNone);
                }
                
            }
            for(var i:Number = 0; i < missionLength; i++)
            {
                var selector:MovieClip = m_MissionList[i]
                CooldownLayout(selector, false);
                selector.m_SubTextContainer._alpha = 0;
                var yPosNew:Number = (i * m_IconTotal) +10;
                Animate(selector,  yPosNew, snap);
            }
            
            dialogueY = m_ClipYAnchor+(missionLength * m_IconTotal) + 10
            missionClipY = m_ClipYAnchor
            m_WasOpen = false;
        
        }
        
        if (snap)
        {
            if (m_DialogueClip != undefined)
            {
                m_DialogueClip._y = dialogueY;
                m_DialogueClip._yscale = m_MinScale;
                m_DialogueClip._xscale = m_MinScale;
                m_DialogueClip._x = 0;
            }
            m_MissionClip._y = -(index * m_IconTotal)
        }
        else
        {
            m_MissionClip.tweenTo(m_TweenDuration, { _y: missionClipY }, None.easeNone);
            m_MissionClip.onTweenComplete = undefined;
            
            if (m_DialogueClip != undefined)
            {
                m_DialogueClip.tweenTo(m_TweenDuration , { _y: dialogueY, _yscale:m_MinScale, _xscale:m_MinScale, _x: 0  }, None.easeNone);
                m_DialogueClip.onTweenComplete = undefined;
            }
            if (m_OpenTimer != undefined)
            {
                _global.clearTimeout(m_OpenTimer);
            }
            m_IsOpeningInProgress = true;
            m_OpenTimer = _global.setTimeout(Delegate.create(this, ToggleOpeningProgress), m_AnimationDuration);
        }
	}
    
    private function ToggleOpeningProgress()
    {
        m_IsOpeningInProgress = !m_IsOpeningInProgress;
    }
    
    private function CooldownLayout(selector:MovieClip, add:Boolean)
    {
        if (selector.state == MISSION_STATE_COOLDOWN)
        {
            if (add)
            {
                selector.m_SubTextContainer.onEnterFrame = CooldownFrameHandler
            }
            else
            {
                delete selector.m_SubTextContainer.onEnterFrame;
                selector.m_CooldownFrame.m_CooldownText.text = "";
            }
        }
    }
	
	private function Animate(movieClip:MovieClip, y:Number, snap:Boolean):Void
	{
		var x:Number = 0;
		var alpha:Number = m_MaxAlpha;
		var scale:Number = m_NormalScale;
		var isopen:Boolean = IsMissionOpen(movieClip.id);

        /// get the params ready for tweening
        if(isopen) /// we open this specific node
        {
            scale = m_MaxScale;
            x = m_MaxSizedIconX;
            if(m_WasOpen) // if the panel is enabled allready, just add the white frame
            {
                MoveButtonPlayhead(movieClip.m_Button, ACTION_ENABLE, movieClip.isSwitchNecessary, movieClip.state, movieClip.id, movieClip.type );
            }
            else
            {
                MoveButtonPlayhead(movieClip.m_Button, ACTION_OPEN_AND_ENABLE, movieClip.isSwitchNecessary, movieClip.state, movieClip.id, movieClip.type );
            }
            movieClip.m_Button.hitTestDisable = false;
        }
        else if(m_OpenMissionID > 0 || m_IsDialogueOpen) // if the panel is opening, but not this specific node
        {
            scale = m_MinScale;
            alpha = m_MinAlpha;

            if(movieClip.m_Content._visible) /// if this node was active
            {
                MoveButtonPlayhead(movieClip.m_Button, ACTION_DISABLE, movieClip.isSwitchNecessary, movieClip.state, movieClip.id, movieClip.type );
            }
            else if (!m_WasOpen || m_ShowNames)
            {
                MoveButtonPlayhead(movieClip.m_Button, ACTION_OPEN, false, movieClip.state, movieClip.id, movieClip.type);
            }
            movieClip.m_Button.hitTestDisable = false;
        }
        else // we are closing
        {
            scale = m_MinScale;
            alpha = m_MaxAlpha;
            m_ShowNames = m_IsDialogueOpen;
            movieClip.m_Button.gotoAndPlay("close");
            movieClip.m_Button.hitTestDisable = true;
        }
        
        ///
        /// if snapping, just pop to the pos
        ///
        if (snap)
        {
            movieClip._y = y;
            movieClip._x = x;
            movieClip._alpha = alpha;
            movieClip._xscale = scale;
            movieClip._yscale = scale;
            
            if(movieClip.m_Content._visible)
            {
                movieClip.m_Content._visible = false;
            }
            else if(isopen)
            {
                movieClip.m_Content._visible = true;
                movieClip.m_Content._alpha = 100;
            }
            
        }
        ///
        /// Nu snap, tween
        ///
        else
        {
            // tween
            movieClip.tweenTo(m_TweenDuration , {_y:y, _x:x, _alpha:alpha, _xscale:scale, _yscale:scale}, None.easeNone)

            /// tween tewards
            if (movieClip.m_Content.m_RewardFrame)
            {
                if(alpha == 0) // if we tween down, do it quick, if not do it slow
                {
                    movieClip.m_Content.m_RewardFrame.tweenTo((m_TweenDuration/2) , {_alpha:alpha},None.easeNone)
                } 
                else
                {
                    movieClip.m_Content.m_RewardFrame.tweenTo((m_TweenDuration*2) , {_alpha:alpha},None.easeNone)
                }
            }

            /// tween text
            if(movieClip.m_Content._visible)
            {
                movieClip.m_Content.tweenTo(m_TweenDuration , {_alpha:0}, None.easeNone);
            }
            if(isopen)
            {
                movieClip.m_Content._visible = true;
                movieClip.m_Content.tweenTo(m_TweenDuration , {_alpha:100}, None.easeNone);
            }

            movieClip.m_Content.onTweenComplete = function()
            {
                this._visible = (this._alpha == 0) ? false : true;
            }
        }
    }
}