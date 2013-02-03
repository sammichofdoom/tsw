import gfx.core.UIComponent;

import com.Utils.LDBFormat;

import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Skills;

class GUI.CharacterSheet.StatItem extends UIComponent
{  
    private var m_Description:TextField;
    private var m_StatFirst:TextField;
    private var m_StatSecond:TextField;
    private var m_StatThird:TextField;
    
    private var m_Weapons:Array;
    
    private var m_Stats:Array;
    
    private var m_Skill:Number;
    
    public function StatItem()
    {
        super();
        
        m_Stats = new Array();        
        m_Stats.push(m_StatFirst);
        m_Stats.push(m_StatSecond);
        m_Stats.push(m_StatThird);

        m_Weapons = new Array();
    }
    
    public function SetSkill(skill:Number)
    {
        if (m_Skill)
        {
            ClearSignals();
        }
        
        m_Skill = skill;
        m_Description.text = LDBFormat.LDBGetText("SkillTypeNames", m_Skill);
        Skills.SignalSkillUpdated.Connect( SlotSkillUpdated, this );
        Skills.SignalUpdateAllSkills.Connect( SlotForceSkillUpdate, this);
        
        UpdateSkill();
    }
    
    public function ClearSignals():Void
    {
        Skills.SignalSkillUpdated.Disconnect( SlotSkillUpdated, this );
        Skills.SignalUpdateAllSkills.Disconnect( SlotForceSkillUpdate, this);
    }
    
    public function SlotSkillUpdated(skill:Number)
    {
        if (skill == m_Skill)
        {
            UpdateSkill();
        }
    }
    
    private function SlotForceSkillUpdate():Void
    {
        UpdateSkill();
    }
    
    public function SetWeapons(weapons:Array)
    {
        //Default to 1 weapon until its decided if we support several weapons
        m_Weapons = new Array()//weapons;
        var numWeapons:Number = 1 //Math.max(1, m_Weapons.length);
        for (var i:Number = 0; i < m_Stats.length; i++)
        {
            if (i < numWeapons)
            {
                m_Stats[i]._visible = true;
                m_Stats[i]._x = m_Stats[0]._x + m_Stats[0]._width*i;
            }
            else
            {
                m_Stats[i]._visible = false;
                m_Stats[i]._x = 0;
            }
        }
        
        
        UpdateSkill();
    }
    
    private function UpdateSkill()
    {
        var tooltipText:String = "";
        switch(m_Skill)
        {
            case _global.Enums.SkillType.e_Skill_PhysicalMitigation:
                tooltipText = LDBFormat.Printf(LDBFormat.LDBGetText("SkillTypeDescriptions", m_Skill), Skills.GetSkill(_global.Enums.SkillType.e_Skill_PhysicalBlockMitigation, 0), 
                    Skills.GetSkill(_global.Enums.SkillType.e_Skill_PhysicalNormalMitigation, 0), Skills.GetSkill(_global.Enums.SkillType.e_Skill_PhysicalPenetrateMitigation, 0));
                break;
            case _global.Enums.SkillType.e_Skill_MagicalMitigation:
                tooltipText = LDBFormat.Printf(LDBFormat.LDBGetText("SkillTypeDescriptions", m_Skill), Skills.GetSkill(_global.Enums.SkillType.e_Skill_MagicalBlockMitigation, 0), 
                    Skills.GetSkill(_global.Enums.SkillType.e_Skill_MagicalNormalMitigation, 0), Skills.GetSkill(_global.Enums.SkillType.e_Skill_MagicalPenetrateMitigation, 0));
                break;
            default:
                tooltipText = LDBFormat.LDBGetText("SkillTypeDescriptions", m_Skill)
                break;
        }
        TooltipUtils.AddTextTooltip(this, tooltipText, 200, TooltipInterface.e_OrientationHorizontal, true);
        
        if (m_Weapons.length > 0)
        {
            for (var i:Number = 0; i < m_Weapons.length; i++)
            {
                m_Stats[i].text = Skills.GetSkill(m_Skill, m_Weapons[i]);
            }
        }
        else
        {
            var str:String = Skills.GetSkill(m_Skill, 0);
            m_Stats[0].text = str;
        }
    }
}
