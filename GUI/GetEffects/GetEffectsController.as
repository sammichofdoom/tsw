//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import flash.geom.Point;
import flash.geom.Rectangle;
import GUIFramework.SFClipLoader;

//Constants
var AP_VALUE:Number = 1;
var SP_VALUE:Number = 2;
var AUXILIARY_VALUE:Number = 5437;
var TDB_AUXILIARY_UNLOCKED:String = LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AuxiliaryWeaponSlotActivated");

//Variables
var m_Character:Character;
var m_HorisontalCenter:Number;
var m_LoreStartPos:Point;
var m_AchievementStartPos:Point;
var m_TutorialStartPos:Point;
var m_GetEffectStartPos:Point;
var m_Scale:Number = 100;
var m_Language:String;
var m_LanguageMonitor:DistributedValue;

var m_AnimationQueue:Array;
var m_PlayingAnimation:Object;

//On Load
function onLoad():Void
{
    m_AnimationQueue = [];
	m_PlayingAnimation = undefined;
    
    m_Character = Character.GetClientCharacter();
          
    m_ResolutionScaleMonitor = DistributedValue.Create("GUIResolutionScale");
    m_ResolutionScaleMonitor.SignalChanged.Connect(SlotResolutionChange, this);

    SlotClientCharacterAlive();
    CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
    
    Lore.SignalTagAdded.Connect(SlotTagAdded, this);
	Lore.SignalGetAnimationComplete.Connect(SlotGetAnimationComplete, this);
    
	com.GameInterface.Quests.SignalQuestRewardMakeChoice.Connect(SlotMissionComplete, this);
        
    SlotResolutionChange();
    
    m_LanguageMonitor = DistributedValue.Create("Language");
    m_LanguageMonitor.SignalChanged.Connect(SlotSetLanguage, this);
    SlotSetLanguage()
}

//Slot Get Animation Complete
function SlotGetAnimationComplete(tagId:Number):Void
{
	m_PlayingAnimation = undefined;
	RunAnimationQueue();
}

//Get Achievement
function GetAchievement(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_achievement_get.xml");
    }
    
    var name:String = Lore.GetTagName(tagId);
    var tagText:String = Lore.GetTagText(tagId);

    var loreNode:LoreNode = Lore.GetDataNodeById(tagId, Lore.GetAchievementTree().m_Children);
    var achievementGet:MovieClip = attachMovie("AchievementGet", "m_Animation", getNextHighestDepth());
	
	if (achievementGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    achievementGet._xscale = m_Scale;
    achievementGet._yscale = m_Scale;
    achievementGet._x = m_AchievementStartPos.x;
    achievementGet._y = m_AchievementStartPos.y;
    
    if (loreNode.m_Icon > 0)
    {
        LoadImage(achievementGet.m_Icon.m_Container, loreNode.m_Icon);
    }
    else
    {
        AttachDefaultImage(achievementGet.m_Icon.m_Container);
    }
    
    achievementGet.m_AchievementText.m_Name.autoSize = "center"
    achievementGet.m_AchievementText.m_Name.text = name;
    achievementGet.m_AchievementText.m_Description.autoSize = "center";
    achievementGet.m_AchievementText.m_Description.text = tagText;
    achievementGet.m_Id = tagId;
    
    achievementGet.gotoAndPlay(1);
    
    achievementGet.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//Get Tutorial
function GetTutorial(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_lore_get.xml");
    }
    
    var text:String = Lore.GetTagText(tagId);
    var tutorialGet:MovieClip = attachMovie("TutorialGet", "m_Animation", getNextHighestDepth());
    
	if (tutorialGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    tutorialGet._xscale = m_Scale;
    tutorialGet._yscale = m_Scale;
    tutorialGet._x = m_TutorialStartPos.x;
    tutorialGet._y = m_TutorialStartPos.y;
 
    tutorialGet.m_TextClip.m_Text.autoSize = "left";
    tutorialGet.m_TextClip.m_Text._width = 280;
    tutorialGet.m_TextClip.m_Text.htmlText = text;
    
    if (tutorialGet.m_TextClip.m_Text._height > 75)
    {
        tutorialGet.m_TextClip.m_Text._height = 75; // force size to prevent text overflowing
    }
    
    tutorialGet.m_TextClip.m_Text._y = (37 - (tutorialGet.m_TextClip.m_Text._height * 0.5)) -4;
    
    tutorialGet.m_Id = tagId;
    tutorialGet.gotoAndPlay(1);
    
    tutorialGet.onRelease = function()
    {
		this.onTweenComplete = function()
		{
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
		}
		this.tweenTo(0.3, { _alpha:0 }, None.easeNone);
    }
    
    // break after expanding, wait 4 secs and continue
    tutorialGet.onEnterFrame = function()
    {
        if (this._currentframe  == 36)
        {
            this.stop();
            setTimeout(function(ref:MovieClip) { ref.gotoAndPlay(37); }, 2000, this);
        }
        else if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//Get Lore
function GetLore(tagId:Number):Void
{
    if (m_Character != undefined)
    {
        m_Character.AddEffectPackage("sound_fxpackage_GUI_lore_get.xml");
    }
    
    var name:String = Lore.GetTagName(Lore.GetTagParent(tagId));
    var tagText:String = Lore.GetTagText(tagId);
    var loreNode:LoreNode = Lore.GetDataNodeById(tagId, Lore.GetLoreTree().m_Children);
    
    var loreGet:MovieClip = attachMovie("LoreGet", "m_Animation", getNextHighestDepth());
	
	if (loreGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    loreGet._xscale = m_Scale;
    loreGet._yscale = m_Scale;
    loreGet._x = m_LoreStartPos.x;
    loreGet._y = m_LoreStartPos.y;
    loreGet.m_LoreText.m_TagText.text = tagText;
    loreGet.m_LoreText.m_TagName.text = name;
    loreGet.m_Id = tagId;
        
    loreGet.gotoAndPlay(1);
    
    loreGet.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//Get Notification Effect
function GetNotificationEffect(value:Number):Void
{
    var effectSound:String;
    var effectClip:String;
    
    switch (value)
    {
        case AP_VALUE:          effectSound = "sound_fxpackage_GUI_anima_point_get.xml";
                                effectClip = "ApGet";
                            
                                break;
                            
        case SP_VALUE:          effectSound = "sound_fxpackage_GUI_skill_point_get.xml";
                                effectClip = "SpGet";
                            
                                break;
                            
        case AUXILIARY_VALUE:   effectSound = "sound_fxpackage_GUI_achievement_get.xml";
                                effectClip = "AuxiliaryGet";
    }
    
    if (m_Character != undefined && effectSound != undefined)
    {
        m_Character.AddEffectPackage(effectSound);
    }
        
    var clip:MovieClip = attachMovie(effectClip, "m_Animation", getNextHighestDepth());
	
	if (clip == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}
	
    clip._xscale = m_Scale;
    clip._yscale = m_Scale;
    clip._x = m_GetEffectStartPos.x;
    clip._y = m_GetEffectStartPos.y;
    
    if (value == AP_VALUE || value == SP_VALUE)
    {
        clip.m_Icon.m_IconEn._visible = (m_Language == "en");
        clip.m_Icon.m_IconFr._visible = (m_Language == "fr");
        clip.m_Icon.m_IconDe._visible = (m_Language == "de");
    }
    
    clip.gotoAndPlay(1);
    
    clip.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

//Queue Animation
function QueueAnimation(animationInfo:Object):Void
{
	switch(animationInfo.callback)
	{
		case GetAP:
		case GetSP:
		case GetSendReport:     if (m_PlayingAnimation.callback == animationInfo.callback)
                                {
                                    return;
                                }
                                for (var i:Number = 0; i < m_AnimationQueue.length; i++)
                                {
                                    if (m_AnimationQueue[i].callback == animationInfo.callback)
                                    {
                                        return;
                                    }
                                }
		
                                break;
	}
    
	m_AnimationQueue.push(animationInfo);
}

//Get Send Report
function GetSendReport():Void
{
    var sendReport:MovieClip = attachMovie("SendReport", "m_Animation", getNextHighestDepth());
	
	if (sendReport == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit();
		return;
	}
	
    sendReport._xscale = m_Scale;
    sendReport._yscale = m_Scale;
    sendReport._x = m_GetEffectStartPos.x;
    sendReport._y = m_GetEffectStartPos.y;
    sendReport.m_SendReportText.textField.autoSize = "center";
    sendReport.m_SendReportText.textField.htmlText = LDBFormat.LDBGetText("Quests", "Mission_SendReport");
    sendReport.gotoAndPlay(1);
    
    sendReport.onEnterFrame = function()
    {
        if (this._currentframe == this._totalframes)
        {
            GUI.Mission.MissionSignals.SignalMissionRewardsAnimationDone.Emit();
			Lore.SignalGetAnimationComplete.Emit();
            this.removeMovieClip();
        }
    }
}

//Slot Set Language
function SlotSetLanguage():Void
{
    m_Language = m_LanguageMonitor.GetValue();
}

//Slot Mission Complete
function SlotMissionComplete():Void
{
    QueueAnimation({ callback: GetSendReport });
    RunAnimationQueue();
}

//Slot Tag Added
function SlotTagAdded(tagId:Number, characterId:ID32):Void
{
    if (tagId == AUXILIARY_VALUE)
    {
        QueueAnimation( { callback: GetNotificationEffect, argument: [tagId] } );
        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(TDB_AUXILIARY_UNLOCKED, 0)
        RunAnimationQueue();
        
        return;
    }

    if (!characterId.Equal(Character.GetClientCharID()))
    {
        return;
    }
    
    if (!Lore.ShouldShowGetAnimation(tagId))
    {
        return;
    }
    
    var loreNodeType:Number = Lore.GetTagType(tagId);
    
    switch(loreNodeType)
    {
        case _global.Enums.LoreNodeType.e_Achievement:
        case _global.Enums.LoreNodeType.e_SubAchievement:   QueueAnimation({ callback: GetAchievement, argument: [tagId] });
                                                            break;
                                                            
        case _global.Enums.LoreNodeType.e_Lore:             QueueAnimation({ callback: GetLore, argument: [tagId] });
                                                            break;
                                                            
        case _global.Enums.LoreNodeType.e_TutorialTip:      QueueAnimation({ callback: GetTutorial, argument: [tagId] });
                                                            break;
                                                            
        case _global.Enums.LoreNodeType.e_Tutorial:         Lore.OpenTag(tagId);
                                                            break;
                                                            
        case _global.Enums.LoreNodeType.e_Title:            //TITLE
                                                            break;
                                                            
        case _global.Enums.LoreNodeType.e_FactionTitle:     QueueAnimation({ callback: GetRank, argument: [tagId] });
    }
    
    RunAnimationQueue();
}

//Slot Client Character Alive
function SlotClientCharacterAlive():Void
{
    m_Character = Character.GetClientCharacter();
    
    if (m_Character != undefined)
    {
        m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
    }
}

//Get Rank
function GetRank(tagId:Number):Void
{
    var faction:String = com.Utils.Faction.GetFactionNameNonLocalized(m_Character.GetStat(_global.Enums.Stat.e_PlayerFaction));
    var rank:Number = Lore.GetRank(tagId);
    var rankGet:MovieClip = attachMovie(faction+"_"+rank, "m_Animation", getNextHighestDepth());
	
	if (rankGet == undefined)
	{
		Lore.SignalGetAnimationComplete.Emit(tagId);
		return;
	}
	
    rankGet._xscale = m_Scale;
    rankGet._yscale = m_Scale;
    rankGet._x = m_GetEffectStartPos.x;
    rankGet._y = m_GetEffectStartPos.y;
    rankGet.m_Animation.gotoAndPlay(1);
    rankGet.m_Id = tagId;
    
    rankGet.onEnterFrame = function()
    {
        if (this["m_Animation"]._currentframe == this["m_Animation"]._totalframes)
        {
			Lore.SignalGetAnimationComplete.Emit(this.m_Id);
            this.removeMovieClip();
        }
    }
}

//Slot Resolution Change
function SlotResolutionChange():Void
{
    var visibleRect:Rectangle = Stage["visibleRect"];
    var realScale:Number = m_ResolutionScaleMonitor.GetValue();
    
    m_Scale = realScale * 100;
    m_HorisontalCenter = visibleRect.width * 0.5;
    
    var loreStartY:Number = visibleRect.height - (170 * realScale);
    m_LoreStartPos = new Point(m_HorisontalCenter, loreStartY);
    
    var tutorialStartY:Number = (visibleRect.height * 0.30) - (50 * realScale);
    m_TutorialStartPos = new Point(m_HorisontalCenter - (710 * realScale), tutorialStartY);
    
    var achievementsY:Number = visibleRect.height - (300 * realScale);
    m_AchievementStartPos = new Point(m_HorisontalCenter, achievementsY);
    
    var getEffectsStartY:Number = 200 * realScale;
    m_GetEffectStartPos = new Point(m_HorisontalCenter, getEffectsStartY);
}

//Slot Token Amount Changed
function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number):Void
{
    if (newValue > oldValue)
    {
        QueueAnimation({callback: GetNotificationEffect, argument: [id]});
        
        RunAnimationQueue();
    }
}

//Run Animation Queue
function RunAnimationQueue()
{
    if (m_PlayingAnimation == undefined)
    {
        if (m_AnimationQueue.length > 0)
        {
            m_PlayingAnimation = m_AnimationQueue.shift();
            m_PlayingAnimation.callback.apply(this, m_PlayingAnimation.argument);
        }
    }
}

//Load Image
function LoadImage(container:MovieClip, mediaId:Number):Void
{
    var imageLoader:MovieClipLoader = new MovieClipLoader();
    var path = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + mediaId;
    
    imageLoader.addListener(this);
    imageLoader.loadClip(path, container);
}

//On Load Init
function onLoadInit(target:MovieClip):Void
{
    target._height = 108;
    target._width = 108;
    target._alpha = 100;
    target._x = 3;
    target._y = 3;
}

//On Load Error
function onLoadError(target:MovieClip, errorcode:String):Void
{
    AttachDefaultImage(target);
}

//Attach Default Image
function AttachDefaultImage(container:MovieClip):Void
{
    var attachedIcon:MovieClip = container.attachMovie("AchievementDefaultIcon", "defaultIcon", container.getNextHighestDepth());
    
    attachedIcon._height = 108;
    attachedIcon._width = 108;
    attachedIcon._alpha = 100;
}