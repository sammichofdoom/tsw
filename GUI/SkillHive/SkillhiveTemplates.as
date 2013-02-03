//Imports
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Log;
import com.GameInterface.Lore;
import com.GameInterface.ProjectSpell;
import com.GameInterface.SkillWheel.SkillWheel;
import com.GameInterface.SkillWheel.SkillTemplate;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Spell;
import com.GameInterface.Utils;
import com.Utils.Colors;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.controls.Button;
import gfx.controls.DropdownMenu;
import gfx.controls.TextArea;
import gfx.core.UIComponent;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import GUI.SkillHive.SkillHiveFeatHelper;
import GUI.SkillHive.SkillHiveSignals;
import GUI.SkillHive.TemplateAbility;

//Class
dynamic class GUI.SkillHive.SkillhiveTemplates extends UIComponent
{
    //Constants
    private static var PANOPTIC_CORE_ACHIEVEMENT_ID_GAMETWEAK:Number = Utils.GetGameTweak("Panoptic_Core_Achievement_ID");
    
    //Properties
    public var SignalTemplateSelected:Signal;
    
    private var m_SelectedTemplateIndex:Number;
    
    private var m_TemplateData:Array;
    private var m_TemplatesDropdown:MovieClip;
    private var m_TemplateDescription:TextArea;
	private var m_ShowingDescription:Boolean;
	private var m_SelectedAchievement:Number;
    
    private var m_ImageContainer:MovieClip;
    private var m_WeaponRequirementClip:MovieClip;
    private var m_PassiveAbilitiesClip:MovieClip;
    private var m_ActiveAbilitiesClip:MovieClip;
    private var m_DetailedTextButton:MovieClip;
    private var m_NextButton:MovieClip;
    private var m_PreviousButton:MovieClip;
    private var m_ButtonBar:MovieClip;
	private var m_RewardsIcon:MovieClip;
	
    private var m_TabButtonArray:Array;
    
    private var m_ClaimButton:MovieClip;
    private var m_EquipButton:MovieClip;
    
    private var m_ClientCharacter:Character;
    
    //Config UI
	private function configUI():Void
	{
		SignalTemplateSelected = new Signal();
		
		Lore.SignalTagAdded.Connect(SlotTagAdded, this);
		
		m_SelectedAchievement = -1;
        m_ClientCharacter= Character.GetClientCharacter();
 
        m_ClaimButton.disableFocus = true;
        m_EquipButton.disableFocus = true;
       
        m_ClaimButton.label = LDBFormat.LDBGetText("SkillhiveGUI", "ClaimDeck")
        m_EquipButton.label = LDBFormat.LDBGetText("SkillhiveGUI", "EquipDeck")
        
        m_EquipButton.addEventListener("click", this, "OnClickEquip");
        m_ClaimButton.addEventListener("click", this, "OnClickClaim");
        m_NextButton.addEventListener("click", this, "OnClickNext");
        m_PreviousButton.addEventListener("click", this, "OnClickPrevious");
        
        var dropdownFormat:TextFormat = new TextFormat();
        dropdownFormat.size = 15;
        
        m_TemplatesDropdown.addEventListener("change", this, "OnTemplateSelected");
        m_TemplatesDropdown.textField.setNewTextFormat(dropdownFormat);
        m_TemplatesDropdown.offsetY = 2;
        
        FeatInterface.SignalFeatTrained.Connect(SlotUpdateTemplates, this);
        FeatInterface.SignalFeatsUntrained.Connect(SlotUpdateTemplates, this);
		m_ShowingDescription = false;
		
		m_TemplateDescription.disabled = true;
		m_TemplateDescription.editable = false;
		
		m_TabButtonArray = [];
        m_TabButtonArray[0] =  { label:LDBFormat.LDBGetText("SkillhiveGUI", "DeckOutfit"), view: m_ImageContainer };
        m_TabButtonArray[1] = { label:LDBFormat.LDBGetText("SkillhiveGUI", "DeckDescription"), view: m_TemplateDescription };
		
		InitButtonBar();
	}

    //Init Button Bar
	private function InitButtonBar():Void
	{
		m_ButtonBar._xscale = m_ButtonBar._yscale = 80;
        m_ButtonBar.tabChildren = false;
        m_ButtonBar.itemRenderer = "TabButton";
        m_ButtonBar.direction = "horizontal";
        m_ButtonBar.spacing = -5;
        m_ButtonBar.autoSize = true;
        m_ButtonBar.dataProvider = m_TabButtonArray;
        m_ButtonBar.addEventListener("change", this, "UpdateTabViews");
		m_ButtonBar.addEventListener("focusIn", this, "SlotButtonBarFocus");
        m_ButtonBar.selectedIndex = 0;
        m_ButtonBar._xscale = m_ButtonBar._yscale = 105;
        
		UpdateTabViews();
	}
	
    //Update Tab Views
	private function UpdateTabViews():Void
	{
		var selectedIndex:Number = m_ButtonBar.selectedIndex;
        
		for (var i:Number = 0; i < m_TabButtonArray.length; i++)
        {
            var view:MovieClip = m_TabButtonArray[i].view;
            
            if (i == selectedIndex)
            {
                view._visible = true;
            }
            else
            {
                view._visible = false;
            }
        }
	}
	
    //Slot Button Bar Focus
	private function SlotButtonBarFocus():Void
	{
		Selection.setFocus(null);
	}
	
    //Slot Tag Added
	function SlotTagAdded(tagId:Number):Void
	{
		if (m_SelectedAchievement == tagId)
		{
			m_ClaimButton._visible = false;
		}
	}
    
    //Set Faction
    function SetFaction(factionId:Number):Void
    {
        var templates:Array = SkillWheel.m_FactionSkillTemplates[factionId.toString()];
        m_TemplateData = new Array();

        for (var i:Number = 0; i < templates.length; i++)
        {
            var templateListItem:Object = new Object();
            templateListItem.label = LDBFormat.LDBGetText("SkillhiveGUI", templates[i].m_Id);
            templateListItem.m_Template = templates[i];
            
            m_TemplateData.push(templateListItem);
        }
            
        m_TemplateData.sortOn("label", [Array.CASEINSENSITIVE]);
        
        for (var i:Number = 0; i < m_TemplateData.length; i++)
        {
            if (m_TemplateData[i].m_Template.m_Achievement == PANOPTIC_CORE_ACHIEVEMENT_ID_GAMETWEAK)
            {
                m_TemplateData.splice(m_TemplateData.length, 0, m_TemplateData.splice(i, 1)[0]);
                break;
            }
        }
        
        var noneListItem:Object = new Object();
        noneListItem.label = LDBFormat.LDBGetText("Gamecode", "None");
        
        m_TemplateData.unshift(noneListItem);
        
        m_TemplatesDropdown.rowCount = m_TemplateData.length;
        m_TemplatesDropdown.dataProvider = m_TemplateData;
        m_TemplatesDropdown.invalidateData();
    }
    
    //On Template Selected
    private function OnTemplateSelected(event:Object):Void
    {
        var index:Number = m_TemplatesDropdown.selectedIndex;
        
        if (index != m_SelectedTemplateIndex)
        {
            SetTemplate(index);

            if (index <= 0)
            {
                SignalTemplateSelected.Emit(undefined);
            }
            else
            {
                SignalTemplateSelected.Emit(m_TemplateData[index].m_Template);
            }
        }
    
		Selection.setFocus(null);
    }
    
    //On Click Next
    private function OnClickNext():Void
    {
        m_TemplatesDropdown.selectedIndex = (m_TemplatesDropdown.selectedIndex + 1) % m_TemplatesDropdown.dataProvider.length;
    }
    
    //On Click Previous
    private function OnClickPrevious():Void
    {
        var previous:Number = m_TemplatesDropdown.selectedIndex - 1;
        
        if (previous < 0)
        {
            previous = m_TemplatesDropdown.dataProvider.length - 1;
        }
        
        m_TemplatesDropdown.selectedIndex = previous;
    }
    
    //On Click Claim
    private function OnClickClaim():Void
    {
        var template:SkillTemplate = m_TemplateData[m_SelectedTemplateIndex].m_Template;
        
        if (template != undefined)
        {
            SkillWheel.ClaimDeck(template.m_Id);
        }
    }
    
    //On Click Equip
    private function OnClickEquip():Void
    {
        var template:SkillTemplate = m_TemplateData[m_SelectedTemplateIndex].m_Template;
        
        if (template != undefined)
        {
            if (template.m_PassiveAbilities != undefined)
            {
                for (var i:Number = 0; i < template.m_PassiveAbilities.length; i++)
                {
                    var featData:FeatData = FeatInterface.m_FeatList[template.m_PassiveAbilities[i]];
                    if (featData != undefined)
                    {
                        if (featData.m_Trained)
                        {
                            Spell.EquipPassiveAbility(i, featData.m_Spell);
                        }
                    }
                }
            }
            
            if (template.m_ActiveAbilities != undefined)
            {
                for (var i:Number = 0; i < template.m_ActiveAbilities.length; i++)
                {
                    var featData:FeatData = FeatInterface.m_FeatList[template.m_ActiveAbilities[i]];
                    
                    if (featData != undefined)
                    {
                        if (featData.m_Trained)
                        {
                            Shortcut.AddSpell(_global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + i, featData.m_Spell);
                        }
                    }                    
                }
            }
        }
    }
    
    //Set Template
    private function SetTemplate(templateIndex:Number):Void
    {
        if (m_SelectedTemplateIndex != templateIndex)
        {
            RemoveTemplateClips();
            
            m_SelectedTemplateIndex = templateIndex;
            
            if (m_SelectedTemplateIndex == 0)
            {
                SetNoneTemplate();
                m_ButtonBar.disabled = true;
            }
            else
            {
                AddTemplateClips();
                m_ButtonBar.disabled = false;
            }
        }
    }

    //Set None Template
    private function SetNoneTemplate():Void
    {
        m_TemplateDescription.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", "GenericDeckInformation");
		m_ButtonBar.selectedIndex = 1;
		m_RewardsIcon._visible = false;
		m_SelectedAchievement = -1;
    }
    
    //Remove Template Clips
    private function RemoveTemplateClips():Void
    {
        if (m_WeaponRequirementClip != undefined)
        {
            m_WeaponRequirementClip.removeMovieClip();
        }
            
        if (m_PassiveAbilitiesClip != undefined)
        {
            m_PassiveAbilitiesClip.removeMovieClip();
        }
            
        if (m_ActiveAbilitiesClip != undefined)
        {
            m_ActiveAbilitiesClip.removeMovieClip();
        }
        
        m_ClaimButton._visible = false;
        m_EquipButton._visible = false;
    }
    
    //Add Template Clips
    private function AddTemplateClips():Void
    {
        var padding:Number = 5;
        var template:SkillTemplate = m_TemplateData[m_SelectedTemplateIndex].m_Template;
        var weaponRequirements:Array = new Array();
        
        var selectedDeckName:String = m_TemplatesDropdown.dataProvider[m_TemplatesDropdown.selectedIndex].label;
        
		m_RewardsIcon._visible = (SkillHiveFeatHelper.DeckIsComplete(template)) ? true : false;
        
        if (m_RewardsIcon._visible)
        {
            if (Lore.IsLocked(template.m_Achievement))
            {
                Colors.ApplyColor(m_RewardsIcon, 0xFFFFFF);
                
                var deckClaimable:String = LDBFormat.LDBGetText("SkillhiveGUI", "DeckClaimableTooltip");
                var tooltipText:String = LDBFormat.Printf(deckClaimable, selectedDeckName);
                
                TooltipUtils.AddTextTooltip(m_RewardsIcon, tooltipText, 130, TooltipInterface.e_OrientationHorizontal, true);
                TooltipUtils.AddTextTooltip(m_ClaimButton, tooltipText, 130, TooltipInterface.e_OrientationHorizontal,  true);
            }
            else
            {
                var deckClaimed:String = LDBFormat.LDBGetText("SkillhiveGUI", "DeckClaimedTooltip");
                
                Colors.ApplyColor(m_RewardsIcon, 0x888888);
                TooltipUtils.AddTextTooltip(m_RewardsIcon, LDBFormat.Printf(deckClaimed, selectedDeckName), 130, TooltipInterface.e_OrientationHorizontal, true);
            }
        }
        else
        {
            var deckIncomplete:String = LDBFormat.LDBGetText("SkillhiveGUI", "DeckIncompleteTooltip");
            
            TooltipUtils.AddTextTooltip(m_ClaimButton, LDBFormat.Printf(deckIncomplete, selectedDeckName), 130, TooltipInterface.e_OrientationHorizontal,  true);            
        }
        
        m_ClaimButton._y = Stage.height - m_ClaimButton._height - 18;
        m_EquipButton._y = Stage.height - m_EquipButton._height - 18; 
        
        m_TemplateDescription.htmlText = LDBFormat.LDBGetText("SkillhiveGUI", template.m_Description);
        
        m_SelectedAchievement = template.m_Achievement;
        
        var numTrainedAbilities:Number = 0;
        
        m_WeaponRequirementClip = attachMovie("TemplateWeapons", "m_WeaponRequirementClip", getNextHighestDepth());
        m_PassiveAbilitiesClip = attachMovie("TemplateAbilities", "m_PassiveAbilitiesClip", getNextHighestDepth());
        m_ActiveAbilitiesClip = attachMovie("TemplateAbilities", "m_ActiveAbilitiesClip", getNextHighestDepth());
        
		if (m_SelectedAchievement != PANOPTIC_CORE_ACHIEVEMENT_ID_GAMETWEAK)
        {                
            m_PassiveAbilitiesClip.m_Ref = this;
            m_PassiveAbilitiesClip.configUI = function()
            {
                for (var i:Number = 0; i < 7; i++)
                {
                    this["m_Ability_" + i].SignalClicked.Connect(this.m_Ref.SlotClickedTemplateAbility, this.m_Ref);
                }
            }
            
            m_ActiveAbilitiesClip.m_Ref = this;
            m_ActiveAbilitiesClip.configUI = function()
            {
                for (var i:Number = 0; i < 7; i++)
                {
                    this["m_Ability_" + i].SignalClicked.Connect(this.m_Ref.SlotClickedTemplateAbility, this.m_Ref);
                }
            }
            
            m_WeaponRequirementClip.m_Title.text = LDBFormat.LDBGetText("SkillhiveGUI", "WeaponRequirements");
            m_PassiveAbilitiesClip.m_Title.text = LDBFormat.LDBGetText("SkillhiveGUI", "PassiveAbilities");
            m_ActiveAbilitiesClip.m_Title.text = LDBFormat.LDBGetText("SkillhiveGUI", "ActiveAbilities");
            
            if (template.m_PassiveAbilities != undefined)
            {
                for (var i:Number = 0; i < 7; i++)
                {
                    var passiveClip:TemplateAbility = m_PassiveAbilitiesClip["m_Ability_" + i];
                    
                    var featData:FeatData = FeatInterface.m_FeatList[template.m_PassiveAbilities[i]];
                    
                    if (passiveClip.SetFeatData != undefined)
                    {
                        passiveClip.SetFeatData(featData);
                    }
                    else
                    {
                        passiveClip.m_FeatData = featData;
                    }
                    
                    if (featData != undefined)
                    {
                        passiveClip._visible = true;
                        
                        if (!featData.m_Trained)
                        {
                            passiveClip._alpha = 20;
                        }
                        else
                        {
                            numTrainedAbilities++;
                            passiveClip._alpha = 100;
                        }
                    }
                    else
                    {
                        passiveClip._visible = false;
                    }
                }
            }
            
            if (template.m_ActiveAbilities != undefined)
            {
                for (var i:Number = 0; i < 7; i++)
                {
                    var activeClip:TemplateAbility = m_ActiveAbilitiesClip["m_Ability_" + i];
                    var featData:FeatData = FeatInterface.m_FeatList[template.m_ActiveAbilities[i]];
                    
                    if (activeClip.SetFeatData != undefined)
                    {
                        activeClip.SetFeatData(featData);
                    }
                    else
                    {
                        activeClip.m_FeatData = featData;
                    }
                    
                    if (featData != undefined)
                    {
                        activeClip._visible = true;
                        
                        if (!featData.m_Trained)
                        {
                            activeClip._alpha = 20;
                        }
                        else
                        {
                            numTrainedAbilities++;
                            activeClip._alpha = 100;
                        }
                        
                        var weaponRequirement:Number = ProjectSpell.GetWeaponRequirement(featData.m_Spell);
                        var addRequirement = true;
                        
                        for (var j = 0; j < weaponRequirements.length; j++)
                        {
                            if (weaponRequirements[j] == weaponRequirement)
                            {
                                addRequirement = false;
                            }
                        }
                        
                        if (addRequirement)
                        {
                            weaponRequirements.push(weaponRequirement);
                        }
                        
                    }
                    else
                    {
                        activeClip._visible = false;
                    }
                }
            }
            
            for (var i:Number = 0; i < 2; i++)
            {
                var weaponClip:MovieClip = m_WeaponRequirementClip["m_Weapon_" + i];
                
                if (weaponClip.i_WeaponRequirement != undefined)
                {
                    weaponClip.i_WeaponRequirement.removeMovieClip();
                }
                
                if (weaponRequirements[i] > 0 && TooltipUtils.CreateWeaponRequirementsIcon(weaponClip, weaponRequirements[i], {_xscale:23,_yscale:23,_x:1,_y:1}))
                {
                    TooltipUtils.AddTextTooltip(weaponClip, LDBFormat.LDBGetText("WeaponTypeGUI", weaponRequirements[i]), 0, TooltipInterface.e_OrientationVertical, false);
                    weaponClip._visible = true;
                }
                else
                {
                    weaponClip._visible = false;
                }
            }
            
            m_EquipButton._visible = true;            
        }
        
        m_ActiveAbilitiesClip._visible = m_PassiveAbilitiesClip._visible = m_WeaponRequirementClip._visible = (m_SelectedAchievement != PANOPTIC_CORE_ACHIEVEMENT_ID_GAMETWEAK);
        
        m_ClaimButton._visible = true;
        
        m_ActiveAbilitiesClip._y = m_ClaimButton._y - m_ActiveAbilitiesClip._height - 10; 
        m_ActiveAbilitiesClip._x = 30;
        
        m_PassiveAbilitiesClip._y = m_ActiveAbilitiesClip._y - m_PassiveAbilitiesClip._height - 2; 
        m_PassiveAbilitiesClip._x = 30;
        
        m_WeaponRequirementClip._y = m_PassiveAbilitiesClip._y - m_WeaponRequirementClip._height - 2; 
        m_WeaponRequirementClip._x = 30;        
            
        if (template.m_Achievement != undefined && template.m_Achievement != 0)
        {
            if (!Lore.IsLocked(template.m_Achievement))
            {
                 m_ClaimButton._visible = false;
            }
        }
        
        m_EquipButton.disabled = numTrainedAbilities == 0;
        m_ClaimButton.disabled = (SkillHiveFeatHelper.DeckIsComplete(template)) ? false : true;
        
        if (!m_ClaimButton.disabled && m_ClientCharacter.GetStat(_global.Enums.Stat.e_PowerHouse, 1) == 0)
        {
            Colors.ApplyColor(m_ClaimButton, 0xFFFF00);
        }
        
        LoadImage(m_ImageContainer, new ID32(1000624, template.m_ImageID));
		
        m_TemplateDescription._y = m_ButtonBar._y + m_ButtonBar._height + 2;
		m_TemplateDescription.height = m_WeaponRequirementClip._y - m_TemplateDescription._y - 20;
    }
    
    //Slot Click Template Ability
    public function SlotClickedTemplateAbility(featData:FeatData):Void
    {
        SkillHiveSignals.SignalSelectAbility.Emit(featData.m_ClusterIndex, featData.m_CellIndex, featData.m_AbilityIndex);
    }
    
    //Load Image
    private function LoadImage(container:MovieClip, mediaId:ID32):Void
    {
        var gender:Number = m_ClientCharacter.GetStat(_global.Enums.Stat.e_Sex);
        var listener:Object = new Object();
        var imageWidth:Number = i_Text._width;
		var imageY:Number = m_ButtonBar._y + m_ButtonBar._height + 2;
        var imageCenterX:Number = m_TemplatesDropdown._x + m_TemplatesDropdown._width / 2;
        
        listener.onLoadComplete = function(targetMC, status)
        {
            if (gender == 2)
            {
                targetMC.gotoAndStop("male");
            }
            else
            {
                targetMC.gotoAndStop("female");
            }
            
            if (targetMC._width > imageWidth)
            {
                var scale:Number = imageWidth / targetMC._height * 100;
                targetMC._xscale = scale;
                targetMC._yscale = scale;
            }
            
			targetMC._y = imageY;            
            targetMC._x = imageCenterX - targetMC._width / 2;
            
			targetMC._parent.UpdateTabViews();
            
        }
        
        var imageLoader:MovieClipLoader = new MovieClipLoader();
        imageLoader.addListener(listener);
        imageLoader.loadClip(Utils.CreateResourceString(mediaId), container);
    }
    
    //Slot Update Templates
    function SlotUpdateTemplates():Void
    {
        RemoveTemplateClips();
        AddTemplateClips();
    }
    
    //Get Selected Template Index
    public function GetSelectedTemplateIndex():Number
    {
        return m_SelectedTemplateIndex;
    }
    
    //Set Selected Template
    public function SetSelectedTemplate(templateIndex:Number):Void
    {
        m_TemplatesDropdown.selectedIndex = templateIndex;
    }
    
    //Get Tab Index
    public function GetTabIndex():Number
    {
        return m_ButtonBar.selectedIndex;
    }
    
    //Set Tab Index
    public function SetTabIndex(tabIndex:Number):Void
    {
        m_ButtonBar.selectedIndex = tabIndex;
        
        UpdateTabViews();
    }
}