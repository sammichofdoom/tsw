import com.Utils.ID32
import com.GameInterface.Game.Character;
import com.Utils.LDBFormat;

import flash.geom.Point;

class GUI.DamageNumbers.DamageText
{    
    public var m_Character:Character;
    
    public var m_DamageClip:MovieClip;
    public var m_ScreenOffset:Point;
	
	public var m_IsPlayer:Boolean;
    
    private var m_Text:String
    
    public var m_OverrideText:String
    public var m_StatId:Number
    public var m_Damage:Number
    public var m_Absorb:Number
    public var m_AttackResultType:Number
    public var m_AttackType:Number
    public var m_AttackOffensiveLevel:Number;
    public var m_AttackDefensiveLevel:Number;
    public var m_Context:Number
    public var m_Scale:Number;
    public var m_EffectType:Number;
	public var m_CombatLogFeedbackType:Number;
    
    private var m_NumHits:Number;

    static public var NEGATIVE_EFFECT:Number = 0;
    static public var NEUTRAL_EFFECT:Number = 1;
    static public var POSITIVE_EFFECT:Number = 2;
    
    public function DamageText(character:Character)
    {
        m_Character = character;
		m_IsPlayer = m_Character == Character.GetClientCharacter();
        m_Damage = 0;
        m_Absorb = 0;
        m_NumHits = 1;
		m_CombatLogFeedbackType = -1;
    }
    
    public function UpdateText()
    {
        if (m_OverrideText != undefined)
        {
            m_Text = m_OverrideText;
        }
        else
        {          
            var color:String = "FFFFFF";
            var text:String = Math.floor(m_Damage) + "";
			if (m_Absorb != 0)
			{
				text += "<font color='#FFFF00'>(" +m_Absorb + ")</font>";
			}
			var prependingTexts:Array = new Array();
			var additionalTexts:Array = new Array();
            var offensiveText:String = "";
            var defensiveText:String = "";
			var criticalText:String = "";
            m_EffectType = NEUTRAL_EFFECT;
            m_Scale = 50;
            
			
			if (m_CombatLogFeedbackType != undefined && m_CombatLogFeedbackType >= 0)
			{
				m_EffectType = POSITIVE_EFFECT;
				color = "FFFF00";
				switch(m_CombatLogFeedbackType)
				{
					case _global.Enums.CombatLogFeedbackType.e_BarrierIncreased:
					{
						break;
					}
					case _global.Enums.CombatLogFeedbackType.e_BarrierIncreasedCritical:
					{
						m_Scale = 100;
						prependingTexts.push(LDBFormat.LDBGetText("CombatOverhead","CombatTextCriticalHit"));
						break;
					}
				}
			}
			else
			{
				switch(m_AttackResultType)
				{
					case _global.Enums.AttackResultType.e_AttackType_Hit:
					{
						m_EffectType = NEGATIVE_EFFECT;
						if(m_Context == _global.Enums.InfoContext.e_ToPlayer)
						{
							color = "FF2200";
						}
						else
						{
							color = "FFFFFF";
						}
						break;
					}
					case _global.Enums.AttackResultType.e_AttackType_CriticalHit:
					{
						m_EffectType = NEGATIVE_EFFECT;
						m_Scale = 100;
						prependingTexts.push(LDBFormat.LDBGetText("CombatOverhead","CombatTextCriticalHit"));
						if(m_Context == _global.Enums.InfoContext.e_ToPlayer)
						{
							color = "FF2200";
						}
						else
						{
							color = "FFFFFF";
						}
						break;
					}
					case _global.Enums.AttackResultType.e_AttackType_Evade:
					{
						m_EffectType = NEGATIVE_EFFECT;
						text = LDBFormat.LDBGetText("CombatOverhead", "CombatTextEvade");
						
						if(m_Context == _global.Enums.InfoContext.e_ToPlayer)
						{
							color = "FFFFFF";
						}
						else
						{
							color = "FF2200";
						}
						break;
					}
					case _global.Enums.AttackResultType.e_AttackType_SpellHeal:
					{
						m_EffectType = POSITIVE_EFFECT;
						color = "22FF00";
						break;
					}
					case _global.Enums.AttackResultType.e_AttackType_SpellCriticalHeal:
					{
						m_EffectType = POSITIVE_EFFECT;
						prependingTexts.push(LDBFormat.LDBGetText("CombatOverhead","CombatTextCriticalHit"));
						m_Scale = 100;
						color = "22FF00";
						break;
					}
					default:
					{
						break;
					}
				}
				if (m_AttackResultType != _global.Enums.AttackResultType.e_AttackType_Evade)
				{
					switch(m_AttackDefensiveLevel)
					{
						case _global.Enums.AttackDefensiveLevel.e_DefensiveLevel_Penetrated:
						{
							prependingTexts.push(LDBFormat.LDBGetText("DefensiveLevel", m_AttackDefensiveLevel));
							break;
						}
						case _global.Enums.AttackDefensiveLevel.e_DefensiveLevel_Blocked:
						{
							if (prependingTexts.length > 0)
							{
								prependingTexts.push(LDBFormat.LDBGetText("DefensiveLevel",m_AttackDefensiveLevel));
							}
							else
							{
								additionalTexts.push(LDBFormat.LDBGetText("DefensiveLevel",m_AttackDefensiveLevel));
							}
							break;
						}
					}
					
					switch(m_AttackOffensiveLevel)
					{
						case _global.Enums.AttackOffensiveLevel.e_OffensiveLevel_Glancing:
						{
							if (prependingTexts.length > 0)
							{
								prependingTexts.push(LDBFormat.LDBGetText("CombatOverhead", "CombatTextGlance"));
							}
							else
							{
								text = LDBFormat.LDBGetText("CombatOverhead", "CombatTextGlance");
								additionalTexts = [];
								prependingTexts = [];
							}
							if(m_Context == _global.Enums.InfoContext.e_ToPlayer)
							{
								color = "FFFFFF";
							}
							else
							{
								color = "FF2200";
							}
							m_Scale = 40;
							break
						}
						case _global.Enums.AttackOffensiveLevel.e_OffensiveLevel_Heavy:
						case _global.Enums.AttackOffensiveLevel.e_OffensiveLevel_Overwhelming:
						{
							if (prependingTexts.length > 0)
							{
								prependingTexts.push(LDBFormat.LDBGetText("DefensiveLevel",m_AttackDefensiveLevel));
							}
							else
							{
								additionalTexts.push(LDBFormat.LDBGetText("OffensiveLevel",m_AttackOffensiveLevel));
							}
							break;
						}
					}
				}
			}
			var prependingText:String = "";
			
			for (var i:Number = 0; i < prependingTexts.length; i++)
			{
				if (i != 0 && prependingText != "")
				{
					prependingText += ", ";
				}
				prependingText += prependingTexts[i];
			}
			
			text = "<font size='28'>" + prependingText +"</font> " + text;
			
			var additionText:String = "";
			for (var i:Number = 0; i < additionalTexts.length; i++)
			{
				if (i != 0 && additionText != "")
				{
					additionText += ", ";
				}
				additionText += additionalTexts[i];
				
			}
			if (additionText != "")
			{
				additionText = " <font size='30'>" + additionText +"</font>";
			}
			
			text += additionText;
			
            if (m_NumHits > 1)
            {
                text = text + " ("+LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "NumberOfHits"),m_NumHits)+")";
            }
			m_Text = AddFontColor(text, color);
			if (m_DamageClip != undefined)
			{
				m_DamageClip.m_DamageClip.textField.htmlText = m_Text;
			}
        }
    }
    
    function AddFontColor(text:String, color:String)
    {
        return com.Utils.Format.Printf("<font color='#%s'>%s</font>", color, text);
    }
    
    public function UpdatePosition(scale:Number)
    {
        var screenPos:Point = m_Character.GetScreenPosition(_global.Enums.AttractorPlace.e_CameraAim);
		if (m_IsPlayer)
		{
			screenPos.x = Stage.width / 2;
		}
        m_DamageClip._x = (screenPos.x / scale) + m_ScreenOffset.x;
        m_DamageClip._y = (screenPos.y / scale) + m_ScreenOffset.y;
    }
		
	public function SetVisible(visible:Boolean)
	{
		m_DamageClip._visible = visible;
	}
	
	public function AddScreenOffset(offset:Point)
	{
		m_ScreenOffset = m_ScreenOffset.add(offset);
	}
    
    public function GetText()
    {
        return m_Text;
    }
    
    public function Equal(damageText:DamageText):Boolean
    {
        return  m_StatId == damageText.m_StatId &&
                m_AttackResultType == damageText.m_AttackResultType &&
                m_AttackType == damageText.m_AttackType &&
                m_AttackOffensiveLevel == damageText.m_AttackOffensiveLevel &&
                m_AttackDefensiveLevel == damageText.m_AttackDefensiveLevel &&
                m_Context == damageText.m_Context &&
                m_Scale == damageText.m_Scale;        
    }
    
    public function Add(damageText:DamageText)
    {
        m_Damage += damageText.m_Damage;
        m_Absorb += damageText.m_Absorb;
        m_NumHits++;
    }
}
