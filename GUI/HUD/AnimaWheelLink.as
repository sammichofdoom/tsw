//Imports
import com.Components.Numbers;
import com.GameInterface.Claim;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Inventory;
import com.GameInterface.Lore;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import com.Utils.ID32;
import flash.filters.ColorMatrixFilter;
import flash.filters.DisplacementMapFilter;
import mx.transitions.easing.*;
import GUIFramework.SFClipLoader;
import mx.utils.Delegate;

//Constants
var ICON_GLOW_BLEED:Number = 2;
var ICON_DISPLACEMENT:Number = 45;
var AUXILIARY_VALUE:Number = 5437;

var ANIMA_POINTS:String = "animapoints";
var SKILL_POINTS:String = "skillpoints";
var LORE:String = "lore";
var ACHIEVEMENT:String = "achievement"
var BREAKING_ITEMS:String = "breakingitems"
var BROKEN_ITEMS:String = "brokenitems"
var TUTORIAL:String = "tutorial";
var PETITION:String = "petition";
var CLAIM:String = "claim";
var AUXILIARY:String = "auxiliary";

//Variables
var m_AnimaPointsIcon:MovieClip;
var m_SkillPointsIcon:MovieClip;
var m_LoreIcon:MovieClip;
var m_AchievementIcon:MovieClip;
var m_BreakingItemsIcon:MovieClip;
var m_BrokenItemsIcon:MovieClip;
var m_TutorialIcon:MovieClip;
var m_PetitionIcon:MovieClip;
var m_ClaimIcon:MovieClip;
var m_AuxiliaryIcon:MovieClip;

var m_Character:Character;
var m_EquipInventory:Inventory;

var m_NumBrokenItems:Number;
var m_NumBreakingItems:Number;

var m_NotificationThrottleIntervalId:Number;
var m_NotificationThrottleInterval:Number// ms between the throttleeffect

var m_AnimaWheelMonitor:DistributedValue;
var m_SkillPointsPanelMonitor:DistributedValue;
var m_AchievementWindowMonitor:DistributedValue;
var m_PetitionWindowMonitor:DistributedValue;
var m_PetitionUpdatedMonitor:DistributedValue;
var m_ClaimWindowMonitor:DistributedValue;

var m_IconHeight:Number;
var m_IconWidth:Number;
var m_VisibleNotificationsArray:Array;

var m_LastTag:Number;

//On Load
function onLoad():Void
{ 
    m_AnimaPointsIcon.m_NotificationText.text = LDBFormat.LDBGetText("GenericGUI", "AnimaPoints_Short");
    m_SkillPointsIcon.m_NotificationText.text = LDBFormat.LDBGetText("GenericGUI", "SkillPointsShort");
    
    m_AnimaWheelMonitor = DistributedValue.Create("anima_wheel_gui");
    m_AnimaWheelMonitor.SignalChanged.Connect(SlotAnimaWheelOpen, this);
    
    m_SkillPointsPanelMonitor = DistributedValue.Create("character_points_gui");
    m_SkillPointsPanelMonitor.SignalChanged.Connect(SlotSkillPointPanelOpen, this);
    
    m_AchievementWindowMonitor = DistributedValue.Create("achievement_lore_window");
    m_AchievementWindowMonitor.SignalChanged.Connect(SlotSkillPointPanelOpen, this);

    m_PetitionWindowMonitor = DistributedValue.Create("petition_browser");
    m_PetitionWindowMonitor.SignalChanged.Connect(SlotPetitionWindowOpen, this);
    
    m_PetitionUpdatedMonitor = DistributedValue.Create("HasUpdatedPetition");
    m_PetitionUpdatedMonitor.SignalChanged.Connect(SlotPetitionUpdated, this);
    
    m_ClaimWindowMonitor = DistributedValue.Create("claim_window");
    m_ClaimWindowMonitor.SignalChanged.Connect(SlotClaimWindowOpen, this);

    Claim.SignalClaimsUpdated.Connect(SlotClaimUpdated, this);
    Lore.SignalTagAdded.Connect(SlotAuxiliaryActivated, this);

    m_VisibleNotificationsArray = new Array();
    
    LoadDurabilityIcons();
    
    SetVisible(m_AnimaPointsIcon, false);
    SetVisible(m_SkillPointsIcon, false);
    SetVisible(m_LoreIcon, false);
    SetVisible(m_AchievementIcon, false);
    SetVisible(m_BrokenItemsIcon, false);
    SetVisible(m_BreakingItemsIcon, false);
    SetVisible(m_TutorialIcon, false);
    SetVisible(m_PetitionIcon, false);
    SetVisible(m_ClaimIcon, false);
    SetVisible(m_AuxiliaryIcon, false);
        
    m_IconHeight = m_SkillPointsIcon._height - ICON_GLOW_BLEED;
    m_IconWidth = m_SkillPointsIcon._width;
    
    AttatchBadge(m_SkillPointsIcon);
    AttatchBadge(m_AnimaPointsIcon);
    AttatchBadge(m_BrokenItemsIcon);
    AttatchBadge(m_BreakingItemsIcon);
    AttatchBadge(m_ClaimIcon);

    Character.SignalClientCharacterAlive.Connect(SlotCharacterAlive, this);
    
    SlotCharacterAlive();
    SlotClaimUpdated();
    SlotPetitionUpdated();
    SlotAuxiliaryActivated(undefined);
    
    m_NotificationThrottleIntervalId = -1;
    m_NotificationThrottleInterval = 2000; 
    
    if (m_NotificationThrottleIntervalId > -1)
    {
        clearInterval( m_NotificationThrottleIntervalId );
    }
    
    m_NotificationThrottleIntervalId = setInterval(Delegate.create(this, AnimateUnclickedNotifications), m_NotificationThrottleInterval );
}

function onUnload()
{
    if (m_NotificationThrottleIntervalId > -1)
    {
        clearInterval( m_NotificationThrottleIntervalId );
    }
}

//Load Durability Icons
function LoadDurabilityIcons()
{
    var brokenContainer:MovieClip = m_BrokenItemsIcon.createEmptyMovieClip("container", m_BrokenItemsIcon.getNextHighestDepth());
    var breakingContainer:MovieClip = m_BreakingItemsIcon.createEmptyMovieClip("container", m_BreakingItemsIcon.getNextHighestDepth());
    
    var imageLoader:MovieClipLoader = new MovieClipLoader();
    var imageLoaderListener:Object = new Object;
    
    imageLoaderListener.onLoadInit = function(target:MovieClip)
    {
        target._x = 1;
        target._y = 1;
        target._xscale = 33;
        target._yscale = 33;
    }
    
    imageLoader.addListener(imageLoaderListener);
    
    imageLoader.loadClip("rdb:1000624:7363471", brokenContainer);   
    imageLoader.loadClip("rdb:1000624:7363472", breakingContainer);     
}

//Slot Character Alive
function SlotCharacterAlive():Void
{
    m_Character = Character.GetClientCharacter();
    
    if (m_Character != undefined)
    {
        m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged, this);
        
        SlotTokenAmountChanged(_global.Enums.Token.e_Anima_Point, m_Character.GetTokens(_global.Enums.Token.e_Anima_Point), 0);
        SlotTokenAmountChanged(_global.Enums.Token.e_Skill_Point, m_Character.GetTokens(_global.Enums.Token.e_Skill_Point), 0);
        
        Lore.SignalGetAnimationComplete.Connect(SlotGetAnimationComplete, this);
        
        if (m_EquipInventory != undefined)
        {
            m_EquipInventory.SignalItemAdded.Disconnect(SlotItemAdded, this);
            m_EquipInventory.SignalItemLoaded.Disconnect(SlotItemAdded, this);
            m_EquipInventory.SignalItemRemoved.Disconnect(SlotItemAdded, this);
            m_EquipInventory.SignalItemStatChanged.Disconnect(SlotItemStatChanged, this);
        }
        
        m_EquipInventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, m_Character.GetID().GetInstance()));
        
        if (m_EquipInventory != undefined)
        {
            m_EquipInventory.SignalItemAdded.Connect(SlotItemAdded, this);
            m_EquipInventory.SignalItemLoaded.Connect(SlotItemAdded, this);
            m_EquipInventory.SignalItemRemoved.Connect(SlotItemAdded, this);
            m_EquipInventory.SignalItemStatChanged.Connect(SlotItemStatChanged, this);
            
            UpdateDurabilityItems();
        }
    }
}

//Slot Item Added
function SlotItemAdded(inventoryID:ID32, itemPos:Number):Void
{
    UpdateDurabilityItems();
}

//Slot Item Removed
function SlotItemRemoved(inventoryID:ID32, itemPos:Number, moved:Boolean):Void
{
    UpdateDurabilityItems();
}

//Slot Item Stat Changed
function SlotItemStatChanged(inventoryID:ID32, itemPos:Number, stat:Number, newValue:Number):Void
{
    if (stat == _global.Enums.Stat.e_Durability || stat == _global.Enums.Stat.e_MaxDurability)
    {
        UpdateDurabilityItems();
    }
}


/// calls a throttle effect on missions you have not yet had
function AnimateUnclickedNotifications()
{
    for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++ )
    {
        if (!m_VisibleNotificationsArray[i].m_IsClicked)
        {
            m_VisibleNotificationsArray[i].m_AnimatingIcon.gotoAndPlay("throttle");
        }
    }
}

//Update Durability Items
function UpdateDurabilityItems():Void
{
    m_NumBrokenItems = 0;
    m_NumBreakingItems = 0;
    
    for (var i:Number = 0; i < m_EquipInventory.GetMaxItems(); i++)
    {
        if (m_EquipInventory.GetItemAt(i) != undefined)
        {
            if (m_EquipInventory.GetItemAt(i).IsBroken())
            {
                m_NumBrokenItems++;
            }
            else if (m_EquipInventory.GetItemAt(i).IsBreaking())
            {
                m_NumBreakingItems++;
            }
        }
    }
    
    UpdateDurabilityNotifications();
}

//Update Durability Notifications
function UpdateDurabilityNotifications():Void
{
    var headline:String = "";
    var bodyText:String = "";
    
    if (m_NumBreakingItems > 0 && m_NumBreakingItems != m_BreakingItemsIcon.m_Badge.m_Charge)
    {
        m_BreakingItemsIcon.m_Badge.SetCharge(m_NumBreakingItems);
        SetVisible(m_BreakingItemsIcon, true);
        
        headline = LDBFormat.LDBGetText("GenericGUI", "Notifications_BreakingItemsHeader");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "Notifications_BreakingItemsBody"), m_NumBreakingItems);

        CreateRealTooltip(m_BreakingItemsIcon, headline, bodyText);
        m_BreakingItemsIcon.onPress = RealPresshandler;
        m_BreakingItemsIcon.m_IsClicked = false;
    }
    else if (m_NumBreakingItems == 0)
    {
        m_BreakingItemsIcon.m_Badge.SetCharge(-1);
        SetVisible(m_BreakingItemsIcon, false);
    }
    
    if (m_NumBrokenItems > 0 && m_NumBrokenItems != m_BrokenItemsIcon.m_Badge.m_Charge)
    {
        m_BrokenItemsIcon.m_Badge.SetCharge(m_NumBrokenItems);
        SetVisible(m_BrokenItemsIcon, true);
        
        headline = LDBFormat.LDBGetText("GenericGUI", "Notifications_BrokenItemsHeader");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "Notifications_BrokenItemsBody"), m_NumBrokenItems);
        
        CreateRealTooltip(m_BrokenItemsIcon, headline, bodyText);
        m_BrokenItemsIcon.onPress = RealPresshandler;
        m_BrokenItemsIcon.m_IsClicked = false;
        
    }
    else if (m_NumBrokenItems == 0)
    {
        m_BrokenItemsIcon.m_Badge.SetCharge(-1);
        SetVisible(m_BrokenItemsIcon, false);
    }
}

//Attach Badge
function AttatchBadge(target:MovieClip):Void
{
    var badge:MovieClip = target.attachMovie("_Numbers", "m_Badge", target.getNextHighestDepth());
    badge.UseSingleDigits = true;
    badge.SetColor(0xFF0000);
    
    badge._x = target._x + m_IconWidth;
    badge._y = target._y + m_IconHeight + 2;
    badge._xscale = badge._yscale = 110;
}

// lore and achievements updated
function SlotGetAnimationComplete(tagId:Number):Void
{
	if (tagId == undefined)
	{
		return; // this happens for ap, sp and mission reports - no tagId
	}
	
    var dataType:Number = Lore.GetTagCategory(tagId);
    
    // tutorial nodes (TYPE tutorial, not category) pop up in your face and therefore need no button
    if (Lore.GetTagType(tagId) == _global.Enums.LoreNodeType.e_Tutorial)
    {
        return;
    }
	
    var targetIcon:MovieClip;
    var headline:String = "";
    var bodyText:String = "";
    
    var loreName:String = Lore.GetTagName(tagId);
    
    if (loreName == "") // lots of lore and acievement items has no name
    {
        loreName = Lore.GetTagName(Lore.GetTagParent(tagId));
    }

    if (dataType == _global.Enums.LoreNodeType.e_Achievement)
    {
        if (!Lore.ShouldShowGetAnimation(tagId))
        {
            return; // invisible node - don't update the icon
        }
        
        headline = LDBFormat.LDBGetText("GenericGUI", "Achievements_AllCaps");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "Achievements_Tooltip"), loreName);
        targetIcon = m_AchievementIcon;
    }
    else if (dataType == _global.Enums.LoreNodeType.e_Lore)
    {
        if (!Lore.ShouldShowGetAnimation(tagId))
        {
            return; // invisible node - don't update the icon
        }

        headline = LDBFormat.LDBGetText("GenericGUI", "Lore_AllCaps");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "LoreTooltip"), loreName);
        targetIcon = m_LoreIcon;
    }
	else if (dataType == _global.Enums.LoreNodeType.e_Tutorial)
    {
        
		if (!Lore.ShouldShowGetAnimation(tagId) || !Lore.IsVisible(tagId))
        {
            // tutorial nodes hide the (possibly) existing icon if an invisible one is added
            SetVisible(targetIcon, false);
            return;
        }
        else
        {
            headline = LDBFormat.LDBGetText("GenericGUI", "Notifications_TutorialHeader");
            bodyText = LDBFormat.LDBGetText("GenericGUI", "Notifications_TutorialBody");
            targetIcon = m_TutorialIcon;
        }
	}
    
    if (targetIcon != undefined)
    {
        CreateRealTooltip(targetIcon, headline, bodyText);
        targetIcon.m_Id = tagId;
        targetIcon.m_IsClicked = false;
        SetVisible(targetIcon, true);
        targetIcon.onPress = RealPresshandler;
    }
}

//Slot Token Amount Changed
function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number):Void
{
    var targetIcon:MovieClip;
    var totalPoints:Number;
    var headline:String;
    var bodyText:String;
    
    if (id == 1) //Anima Points
    {
        targetIcon = m_AnimaPointsIcon;
        totalPoints = GetAnimaPoints();
        headline = LDBFormat.LDBGetText("GenericGUI", "AnimaWheelLink_AnimaPointsHeader");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "AnimaWheelLink_AnimaPointsBody"), totalPoints);
    }
    
    if (id == 2) //Skill Points
    {
        targetIcon = m_SkillPointsIcon;
        totalPoints = GetSkillPoints();
        headline = LDBFormat.LDBGetText("GenericGUI", "AnimaWheelLink_SkillPointsHeader");
        bodyText = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "AnimaWheelLink_SkillPointsBody"), totalPoints);    
    }
    
    CreateRealTooltip(targetIcon, headline, bodyText);
    
    SetVisible(targetIcon, totalPoints > 0 && oldValue < newValue);
    targetIcon.m_IsClicked = false;
    targetIcon.m_Badge.SetCharge(totalPoints);
    targetIcon.onPress = RealPresshandler;
}

function RealPresshandler()
{
    this.m_IsClicked = true;
    
    var character:Character = Character.GetClientCharacter();
    var allowedToReceiveItems:Boolean = character.CanReceiveItems();
    
    switch (this)
    {
        case m_AnimaPointsIcon:     DistributedValue.SetDValue("skillhive_window", !DistributedValue.GetDValue("skillhive_window"));
                                    break;
                                    
        case m_SkillPointsIcon:     DistributedValue.SetDValue("character_points_gui", !DistributedValue.GetDValue("character_points_gui"));
                                    DistributedValue.SetDValue("skillhive_window", !DistributedValue.GetDValue("skillhive_window"));
                                    break;
        
        case m_LoreIcon:
        case m_TutorialIcon:
        case m_AchievementIcon:     Lore.OpenTag(this.m_Id);
                                    SetVisible(this, false);
                                    break;
                                    
        case m_BrokenItemsIcon:     DistributedValue.SetDValue("character_sheet", true);
                                    SetVisible(this, false);
                                    break;
                                    
        case m_BreakingItemsIcon:   DistributedValue.SetDValue("character_sheet", true);
                                    SetVisible(this, false);
                                    break;
                                    
        case m_PetitionIcon:        DistributedValue.SetDValue("petition_browser", true);
                                    DistributedValue.SetDValue("HasUpdatedPetition", false);
                                    SetVisible(this, false);
                                    break;
                                    
        case m_ClaimIcon:           if (allowedToReceiveItems)
                                    {
                                        DistributedValue.SetDValue("claim_window", true);
                                    }
                                    SetVisible(this, false);
                                    break;
                                    
        case m_AuxiliaryIcon:       DistributedValue.SetDValue("skillhive_window", true);
                                    SetVisible(this, false);
                                    break;
    }
}

function CreateRealTooltip(target:MovieClip, headline:String, bodyText:String)
{
    var htmlText:String = "<b>" + com.GameInterface.Utils.CreateHTMLString( headline, { face:"_StandardFont", color: "#FFFFFF", size: 14 } )+"</b>";
    htmlText += "<br/>" + com.GameInterface.Utils.CreateHTMLString( bodyText,{ face:"_StandardFont", color: "#FFFFFF", size: 12 }  );

    com.GameInterface.Tooltip.TooltipUtils.AddTextTooltip( target, htmlText, 210, TooltipInterface.e_OrientationHorizontal, false );
}

//Slot Petition Updated
function SlotPetitionUpdated():Void
{
    var visible:Boolean = DistributedValue.GetDValue("HasUpdatedPetition");
    SetVisible(m_PetitionIcon, visible );
    
    if (visible)
    {
        CreateRealTooltip(m_PetitionIcon, LDBFormat.LDBGetText("GenericGUI", "Notifications_PetitionHeader"), LDBFormat.LDBGetText("GenericGUI", "Notifications_PetitionBody"));
        m_PetitionIcon.onPress = RealPresshandler;
        m_PetitionIcon.m_IsClicked = false;
    }
}

//Slot Claim Window Open
function SlotClaimWindowOpen():Void
{
    SetVisible(m_ClaimIcon, false);
}

//Slot Claim Updated
function SlotClaimUpdated():Void
{
    var claimsCount:Number = GetClaims();
    
    var character:Character = Character.GetClientCharacter();
    var allowedToReceiveItems:Boolean = character.CanReceiveItems();
    
    SetVisible(m_ClaimIcon, (claimsCount > 0 && allowedToReceiveItems));
    m_ClaimIcon.m_Badge.SetCharge(claimsCount);

    var claimBody:String = LDBFormat.Printf( LDBFormat.LDBGetText("GenericGUI", "Notifications_ClaimBody"), GetClaims());
    CreateRealTooltip(m_ClaimIcon, LDBFormat.LDBGetText("GenericGUI", "Notifications_ClaimHeader"), claimBody );
    m_ClaimIcon.onPress = RealPresshandler;
    m_ClaimIcon.m_IsClicked
}

//Slot Auxiliary Activated
function SlotAuxiliaryActivated(tagId:Number):Void
{
    if (tagId == undefined || tagId == AUXILIARY_VALUE)
    {
        var visible:Boolean;
        
        switch (tagId)
        {
            case undefined:         visible = DistributedValue.GetDValue("DisplayAuxiliaryNotification");
                                    break;
                                
            case AUXILIARY_VALUE:   DistributedValue.SetDValue("DisplayAuxiliaryNotification", true);
                                    visible = true;
        }
        
        if (visible)
        {
            SetVisible(m_AuxiliaryIcon, true);
            CreateRealTooltip(m_AuxiliaryIcon, LDBFormat.LDBGetText("GenericGUI", "Notifications_AuxiliaryHeader"), LDBFormat.LDBGetText("GenericGUI", "GetEffectsController_AuxiliaryWeaponSlotActivated"));
            m_AuxiliaryIcon.onPress = RealPresshandler;
            m_AuxiliaryIcon.m_IsClicked = false;
        }
    }
}

//Slot Anima Wheel Open
function SlotAnimaWheelOpen():Void
{
    SetVisible(m_AnimaPointsIcon, false);
}

//Slot Character Skill Point Panel Open
function SlotSkillPointPanelOpen():Void
{
    SetVisible(m_SkillPointsIcon, false);
}

//Slot Petition Window Open
function SlotPetitionWindowOpen():Void
{
    SetVisible(m_PetitionIcon, false);
}

//Get Anima Points
function GetAnimaPoints():Number
{
    if (m_Character != null)
    {
        return m_Character.GetTokens(1);
    }
    
    return 0;
}

//Get Skill Points
function GetSkillPoints():Number
{
    if (m_Character != null)
    {
        return m_Character.GetTokens(2);
    }
    
    return 0;
}

//Get Claims
function GetClaims():Number
{
    return Claim.m_Claims.length;
}

//Set Visible
function SetVisible(targetIcon:MovieClip, visible:Boolean):Void
{
    if (visible == targetIcon._visible )
    {
        return;
    }
    
    if (visible)
    {
        m_VisibleNotificationsArray.push(targetIcon);
    }
    else
    {
        
        for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++)
        {
            if (m_VisibleNotificationsArray[i] == targetIcon)
            {
                m_VisibleNotificationsArray.splice(i, 1);
            }
        }
    }

    targetIcon._visible = visible;
    
    for (var i:Number = 0; i < m_VisibleNotificationsArray.length; i++)
    {
        m_VisibleNotificationsArray[i]._y = 0 - ICON_DISPLACEMENT * i;
    }
}