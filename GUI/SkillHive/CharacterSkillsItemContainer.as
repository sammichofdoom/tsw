//Imports
import com.Utils.GlobalSignal;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import GUI.SkillHive.CharacterPointsSkillsBar;
import GUI.SkillHive.CharacterPointsSubSkillsBar;
import GUI.SkillHive.CharacterSkillsSubItemContainer;
import com.GameInterface.Log;
import com.GameInterface.CharacterPointRowData;
import com.GameInterface.CharacterPointData;
import com.Utils.Signal;
import com.GameInterface.ProjectFeatInterface;
import com.GameInterface.FeatInterface;
import com.Utils.LDBFormat;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;

//Class 
class GUI.SkillHive.CharacterSkillsItemContainer extends MovieClip
{
    //Constants
    private var COLLAPSED_HEIGHT:Number = 49;
    private var SUBSKILL_HEIGHT:Number = 40;
    private var FOOTER_HEIGHT:Number = 10;
    private var TWEEN_SPEED:Number = 0.2;
    private var ICON_EXPANDED_PERCENT:Number = 200;
    private var ICON_DEFAULT_X:Number = 52;
    
    //Localize Text
    private var m_TDB_Rank:String;
    
    //Properties
    private var m_TopLine:MovieClip;
    private var m_IconContainer:MovieClip;
    private var m_Label:TextField;
    private var m_ToolTipHitTest:MovieClip;
    private var m_Category:String;
    private var m_MoreIcon:MovieClip;
    private var m_SkillsBar:CharacterPointsSkillsBar;
    private var m_Background:MovieClip;
	private var m_SubSkills:Array;
    private var m_Data:CharacterPointData;
    private var m_Levels:Number;
	
    public var m_Index:Number;
    public var SignalStartAnimation:Signal;
    public var SignalStopAnimation:Signal;
    
    //Variables
    private var m_IsCollapsed:Boolean = true;
    
    //Constructor
    public function CharacterSkillsItemContainer()
    {
        super();
        
        m_TDB_Rank = LDBFormat.LDBGetText("CharacterSkillsGUI", "Rank");
        
		m_SubSkills = new Array();
                
        SignalStartAnimation = new Signal();
        SignalStopAnimation = new Signal();
		
        FeatInterface.SignalFeatTrained.Connect(SlotFeatTrained, this);
    }
    
    //On Load
    public function onLoad():Void
    {
    
    }
    
    //Add Sub Skills
    public function AddSubSkills():Void
    {
		var subSkills:Array = ProjectFeatInterface.GetSkillRows(m_Data.m_Id);
		var numSubSkills = 0;
        var thisScope = this;
        
		var numSubskillLevels:Number = CountLevels(subSkills);
        
		SetLevels(numSubskillLevels);
		m_SkillsBar.SetLevels(numSubskillLevels);
        
        
        for (var i:Number = 0; i < subSkills.length; i++)
        {
			var subskillExists:Boolean = false;
			for (var j:Number = 0; j < m_SubSkills.length; j++)
			{
				if (m_SubSkills[j].GetID() == subSkills[i].m_Column)
				{
					//Add
					m_SubSkills[j].AddSubSkill(subSkills[i]);
					subskillExists = true;
					break;
				}
			}
            
			if (!subskillExists)
			{
				var subSkillsContainer = attachMovie("CharacterSkillsSubItemContainer", "m_SubSkillsContainer_" + i, getNextHighestDepth());
				subSkillsContainer._y = COLLAPSED_HEIGHT + SUBSKILL_HEIGHT * numSubSkills;
				subSkillsContainer._alpha = 0;
				subSkillsContainer.SetID(subSkills[i].m_Column);
				subSkillsContainer.SetParentID(m_Data.m_Id);
				subSkillsContainer.SetIconName(GetIconName(m_Data.m_Id));
				subSkillsContainer.AddSubSkill(subSkills[i]);
                subSkillsContainer.SetCategory(m_Category);
				subSkillsContainer.SetLevels(numSubskillLevels);
                
				subSkillsContainer.onLoad = function()
				{
					this.UpdateData();
				}
                
				m_SubSkills.push(subSkillsContainer);
				numSubSkills++;
			}
        }
	    
        m_ToolTipHitTest.onRelease = Delegate.create(this, BackgroundClickHandler);
        m_Background.onRelease = Delegate.create(this, BackgroundClickHandler);
        
        //The tooltip instance name in the TDB is retreived based on the data's ID (m_Data.m_Id)
        TooltipUtils.AddTextTooltip(m_ToolTipHitTest, LDBFormat.LDBGetText("CharacterSkillsGUI", "ItemContainerTooltipID_" + m_Data.m_Id), 200, TooltipInterface.e_OrientationVertical, true);
        
        UpdateSkillBarLabelAlpha();
    }
	
	private function CountLevels(subSkills:Array)
	{
		var count:Number = 0;
		var columnId:Number = -1;
		for (var i:Number = 0; i < subSkills.length; i++)
		{
			if (i == 0)
			{
				columnId = subSkills[i].m_Column;
				count++;
				continue
			}
			if (subSkills[i].m_Column == columnId)
			{
				count++;
				continue
			}
		}
		return count;
	}
    
    //Background Click Handler
    public function BackgroundClickHandler():Void
    {
        m_ToolTipHitTest.onRelease = null;
        m_Background.onRelease = null;
        
        if (m_IsCollapsed)
        {
            ToggleBackgroundExpansion();
        }
        else
        {
            ToggleSubSkillsAlpha();
        }
    }
    
    //Get Background Height
    public function GetBackgroundHeight():Number
    {
        return m_Background._height;
    }
    
    //Toggle Background Expansion
    private function ToggleBackgroundExpansion():Void
    {
        if (m_IsCollapsed)
        {
            m_IconContainer.tweenTo(TWEEN_SPEED, { _xscale: ICON_EXPANDED_PERCENT, _yscale: ICON_EXPANDED_PERCENT, _x: m_IconContainer._x - m_IconContainer._width }, None.easeNone);
            m_MoreIcon.tweenTo(TWEEN_SPEED, { _alpha: 0 }, None.easeNone);
            m_Background.tweenTo(TWEEN_SPEED, { _height: COLLAPSED_HEIGHT + SUBSKILL_HEIGHT * m_SubSkills.length + FOOTER_HEIGHT }, None.easeNone);
            m_Background.onTweenComplete = Delegate.create(this, ToggleSubSkillsAlpha);
        }
        else
        {
            m_IconContainer.tweenTo(TWEEN_SPEED, { _xscale: 100, _yscale: 100, _x: ICON_DEFAULT_X }, None.easeNone);
            m_MoreIcon.tweenTo(TWEEN_SPEED, { _alpha: 100 }, None.easeNone);
            m_Background.tweenTo(TWEEN_SPEED, { _height: COLLAPSED_HEIGHT }, None.easeNone);
            
            m_Background.onTweenComplete = Delegate.create(this, ToggleComplete);
        }
        
        SignalStartAnimation.Emit();
    }
    
    //Toggle Sub Skills Alpha
    private function ToggleSubSkillsAlpha():Void
    {
        var lastSubItemContainer:MovieClip;
        
        for (var i:Number = 0; i < m_SubSkills.length; i++)
        {
			m_SubSkills[i].tweenTo(TWEEN_SPEED, { _alpha: m_IsCollapsed ? 100 : 0 }, None.easeNone);
			lastSubItemContainer = m_SubSkills[i];
        }
        
        if (m_IsCollapsed)
        {
            lastSubItemContainer.onTweenComplete = Delegate.create(this, ToggleComplete);
        }
        else
        {
            lastSubItemContainer.onTweenComplete = Delegate.create(this, ToggleBackgroundExpansion);
        }
    }
    
    //Toggle Complete
    private function ToggleComplete():Void
    {        
        m_IsCollapsed = !m_IsCollapsed;
        m_ToolTipHitTest.onRelease = Delegate.create(this, BackgroundClickHandler);
        m_Background.onRelease = Delegate.create(this, BackgroundClickHandler);
        _global['setTimeout'](this, 'SlotStopAnimation', 100);
    }
    
    //Slot Stop Animation
    public function SlotStopAnimation():Void
    {
        SignalStopAnimation.Emit();
    }
    
    //Slot Feat Trained
    public function SlotFeatTrained(featId:Number):Void
    {
		m_Data.m_Level = ProjectFeatInterface.GetHighestLearnedSkillLevel(m_Data.m_Id);

        m_SkillsBar.SetPurchasedTotal(m_Data.m_Level);
		
		//Special case for 1 level skills
		var level:Number = m_Data.m_Level;
		if (m_Levels == 1 && m_Data.m_Level > 0)
		{
			level = 10;
		}
		m_SkillsBar.SetLabel(m_TDB_Rank + " " + level.toString()); 
		
        for (var i:Number = 0; i < m_SubSkills.length; i++)
        {
            if (m_SubSkills[i].HasFeat(featId))
            {
				ClearSubSkillsData();
				AddSubSkills();
            }
            
			m_SubSkills[i].UpdateData();
        }        
    }
    
    //Toggle More Icon
    private function ToggleMoreIcon():Void
    {
        var disabledTotal:Number = 0;
        
        for (var i:Number = 0; i < m_SubSkills.length; i++)
        {
            if (m_SubSkills[i].m_BuyButton._visible == false || m_SubSkills[i].m_BuyButton.disabled == true)
            {   
                disabledTotal++
            }
        }
        
        if (disabledTotal == m_SubSkills.length) 
        {
            m_MoreIcon._visible = false;
        }
        else
        {
            m_MoreIcon._visible = true;
        }
    }
    
    //Update Skill Bar Label Alpha
    private function UpdateSkillBarLabelAlpha():Void
    {
        if (m_Data.m_Level == 0) 
        {
            m_SkillsBar.SetLabelAlpha(50);
        }
        else
        {
            m_SkillsBar.SetLabelAlpha(100);
        }   
    }
	
    //Clear Sub Skills Data
	public function ClearSubSkillsData()
	{
		for (var i:Number = 0; i < m_SubSkills.length; i++)
        {
			m_SubSkills[i].ClearData();
		}
	}
    
    //Set Category
    public function SetCategory(value:String):Void
    {
        m_Category = value;
    }

    //Set Data
    public function SetData(value:CharacterPointData):Void
    {
        m_Data = value;
        
        SetTopLineVisibility((this.m_Index == 0) ? true : false);
        SetIcon(GetIconName(m_Data.m_Id));
        SetLabel(m_Data.m_Name);

		//Special case for 1 level skills
		var level:Number = m_Data.m_Level;
		if (m_Levels == 1 && m_Data.m_Level > 0)
		{
			level = 10;
		}
		m_SkillsBar.SetLabel(m_TDB_Rank + " " + level.toString()); 
		
        m_SkillsBar.SetCategory(m_Category);
        m_SkillsBar.SetPurchasedTotal(m_Data.m_Level);
        
        AddSubSkills();
    }
	
	private function SetLevels(levels:Number) : Void
	{
		m_Levels = levels;
		
		//Special case for 1 level skills
		var level:Number = m_Data.m_Level;
		if (m_Levels == 1 && m_Data.m_Level > 0)
		{
			level = 10;
		}
		m_SkillsBar.SetLabel(m_TDB_Rank + " " + level.toString()); 
	}
	
	public function UpdateCharacterSkillPoints(newAmount:Number)
	{
        for (var i:Number = 0; i < m_SubSkills.length; i++)
        {
            m_SubSkills[i].UpdateCharacterSkillPoints(newAmount);
        }
        
        ToggleMoreIcon();
	}
    
    //Get Icon Name
    private function GetIconName(itemIndex:Number):String
    {
        switch (itemIndex)
        {
            //Melee Icons
            case _global.Enums.CharacterSkills.e_Blades:            return "BladesIcon";
            case _global.Enums.CharacterSkills.e_FistWeapons:       return "FistsIcon";
            case _global.Enums.CharacterSkills.e_Hammers:           return "HammersIcon";
            
            //Ranged Icons
            case _global.Enums.CharacterSkills.e_Shotgun:           return "ShotgunsIcon";
            case _global.Enums.CharacterSkills.e_AssaultRifle:      return "AssaultRiflesIcon";
            case _global.Enums.CharacterSkills.e_DualPistols:       return "PistolsIcon";
                        
            //Magic Icons
            case _global.Enums.CharacterSkills.e_Blood:             return "BloodIcon";
            case _global.Enums.CharacterSkills.e_Chaos:             return "ChaosIcon";
            case _global.Enums.CharacterSkills.e_Elementalism:      return "ElementalsIcon";
            
            //Chakra Icons
            case _global.Enums.CharacterSkills.e_HeadChakra:        return "AstralIcon";
            case _global.Enums.CharacterSkills.e_UpperTorsoChakra:  return "MajorIcon";
            case _global.Enums.CharacterSkills.e_LowerTorsoChakra:  return "MinorIcon";

            case _global.Enums.CharacterSkills.e_RocketLauncher:	return "RocketLauncherIcon";

            case _global.Enums.CharacterSkills.e_ChainSaw:          return "ChainSawIcon";
            
            case _global.Enums.CharacterSkills.e_QuantumWeapon:     return "QuantumIcon";
            
            //Error
            default: Log.Error("CharacterSkillsItemContainer", "Icon global enum (" + itemIndex + ") doesn't exist");
        }
    }
    
    //Set Icon
    public function SetIcon(value:String):Void
    {
        var iconWidth:Number = m_IconContainer._width;
        var iconHeight:Number = m_IconContainer._height;
        
        var icon = m_IconContainer.attachMovie(value, "m_" + value, m_IconContainer.getNextHighestDepth());
        icon._xscale = iconWidth;
        icon._yscale = iconHeight;
        icon._x = icon._y = 0;
    }
    
    //Set Label
    public function SetLabel(value:String):Void
    {
        m_Label.text = value;
    }
    
    //Set Top Line Visibility
    public function SetTopLineVisibility(value:Boolean):Void
    {
        m_TopLine._visible = value;
    }
}