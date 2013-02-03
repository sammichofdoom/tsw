import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import flash.geom.Point;
import com.Utils.ID32;
import gfx.motion.Tween; 
import gfx.controls.Label; 
import mx.transitions.easing.*;
import com.GameInterface.DistributedValue;
import GUI.DamageNumbers.DamageText;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Utils;
import com.GameInterface.Spell;
import com.GameInterface.Log;
import com.Utils.LDBFormat;

var m_ResolutionScale:Number;
var m_ResolutionScaleMonitor:DistributedValue;
var m_ShowTargetDamageMonitor:DistributedValue;
var m_ShowPlayerDamageMonitor:DistributedValue;
var m_ShowPlayerHealMonitor:DistributedValue;
var m_ShowTargetDamageText:Boolean;
var m_ShowPlayerDamageText:Boolean;
var m_ShowPlayerHealText:Boolean;
var m_PlayerDamageTexts:Array;
var m_TargetDamageTexts:Array;
var m_BuffCliploader:MovieClipLoader;

var m_ClientCharacter:Character;
var m_TargetCharacter:Character;

var m_StackPadding:Number = -5;
var m_TweenTime:Number = 1.5;

var m_DamageTextQueues:Array;

function onLoad()
{
    com.Utils.GlobalSignal.SignalDamageNumberInfo.Connect( SlotDamageInfo, this );
    com.Utils.GlobalSignal.SignalDamageTextInfo.Connect( SlotShowText, this );
	
    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ShowTargetDamageMonitor = DistributedValue.Create("Show3DDamageText");
    m_ShowPlayerHealMonitor = DistributedValue.Create("Show3DDamageTextPlayerHeal");
    m_ShowPlayerDamageMonitor = DistributedValue.Create("Show3DDamageTextPlayerDamage");
	
    m_ResolutionScaleMonitor.SignalChanged.Connect( SlotResolutionValueChanged, this );
    m_ShowTargetDamageMonitor.SignalChanged.Connect( SlotShowTargetDamageNumbersChanged, this );
    m_ShowPlayerDamageMonitor.SignalChanged.Connect( SlotShowPlayerDamageNumbersChanged, this );
    m_ShowPlayerHealMonitor.SignalChanged.Connect( SlotShowPlayerHealNumbersChanged, this );
	
	SlotShowTargetDamageNumbersChanged();
	SlotShowPlayerDamageNumbersChanged();
	SlotShowPlayerHealNumbersChanged();
    SlotResolutionValueChanged();
    
    m_PlayerDamageTexts = new Array();
    m_TargetDamageTexts = new Array();

    CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
    InitializeClientCharacter();
    
    m_BuffCliploader = new MovieClipLoader();
	m_DamageTextQueues = new Array();
}



function SlotResolutionValueChanged()
{
    m_ResolutionScale = m_ResolutionScaleMonitor.GetValue();
}

function SlotShowPlayerDamageNumbersChanged()
{
    m_ShowPlayerDamageText = m_ShowPlayerDamageMonitor.GetValue();
}

function SlotShowTargetDamageNumbersChanged()
{
    m_ShowTargetDamageText = m_ShowTargetDamageMonitor.GetValue();
}

function SlotShowPlayerHealNumbersChanged()
{
	m_ShowPlayerHealText = m_ShowPlayerHealMonitor.GetValue();
}


function onEnterFrame()
{
    for (var i:Number = 0; i < m_PlayerDamageTexts.length; i++)
    {
        m_PlayerDamageTexts[i].UpdatePosition(m_ResolutionScale);
		//Since we are tweening alpha from 500->0 we need to cap the alpha to 100 for it to work well
        m_PlayerDamageTexts[i].m_DamageClip.m_DamageClip._alpha = Math.min(100, m_PlayerDamageTexts[i].m_DamageClip.m_DamageClip.m_TweenAlpha );
    }
    for (var i:Number = 0; i < m_TargetDamageTexts.length; i++)
    {
        m_TargetDamageTexts[i].UpdatePosition(m_ResolutionScale);
    }
	
	for ( var i:Number = 0; i < m_DamageTextQueues.length; i++)
	{
		//Get the first entry in each queue and push it out if possible
		m_DamageTextQueues[i][0].m_DamageText.UpdatePosition(m_ResolutionScale);
		if (!IsOverlappingLastText(m_DamageTextQueues[i][0].m_DamageText, m_DamageTextQueues[i][0].m_DamageText.m_Character, m_DamageTextQueues[i][0].m_Context))
		{
            if (m_DamageTextQueues[i].length >= 3)
			{
                for (var j:Number = 1; j < m_DamageTextQueues[i].length; )
				{
                    if (m_DamageTextQueues[i][0].m_DamageText.Equal(m_DamageTextQueues[i][j].m_DamageText))
                    {
                        m_DamageTextQueues[i][0].m_DamageText.Add(m_DamageTextQueues[i][j].m_DamageText);
                        RemoveDamageInfo( m_DamageTextQueues[i][j].m_DamageText.m_DamageClip );
                        m_DamageTextQueues[i].splice(j, 1);
                    }
                    else
                    {
                        j++;
                    }
                }
            }
            m_DamageTextQueues[i][0].m_DamageText.UpdateText();
            
			//Put an object in the damagetexts list to update the position realtime
			StartAnimation(m_DamageTextQueues[i][0].m_DamageText.m_DamageClip);
			m_DamageTextQueues[i][0].m_DamageText.SetVisible(true);
			m_PlayerDamageTexts.push(m_DamageTextQueues[i][0].m_DamageText);
			//Update the position of the text immidiately as there might be more incoming the same frame before it is updated automatically
			m_PlayerDamageTexts[m_PlayerDamageTexts.length - 1].UpdatePosition(m_ResolutionScale);
			
			m_DamageTextQueues[i].shift();
		}
					
		if (m_DamageTextQueues[i].length <= 0)
		{
			m_DamageTextQueues.splice(i, 1);
		}
	}
}

function InitializeClientCharacter()
{
    if (m_ClientCharacter != undefined)
    {
        m_ClientCharacter.SignalBuffAdded.Disconnect(SlotClientCharacterBuffAdded, this);
		m_ClientCharacter.SignalStateAdded.Disconnect(SlotClientCharacterStateAdded, this);
        m_ClientCharacter.SignalOffensiveTargetChanged.Disconnect(SlotOffensiveTargetChanged, this);
    }
    m_ClientCharacter = Character.GetClientCharacter();
    if (m_ClientCharacter != undefined)
    {
        m_ClientCharacter.SignalBuffAdded.Connect(SlotClientCharacterBuffAdded, this);
        m_ClientCharacter.SignalOffensiveTargetChanged.Connect(SlotOffensiveTargetChanged, this);
		m_ClientCharacter.SignalStateAdded.Connect(SlotClientCharacterStateAdded, this);
        InitializeTarget(m_ClientCharacter.GetOffensiveTarget());
    }
}

function InitializeTarget(targetID:ID32)
{
    if (m_TargetCharacter != undefined)
    {
        m_TargetCharacter.SignalBuffAdded.Disconnect(SlotTargetCharacterBuffAdded, this);
		m_TargetCharacter.SignalStateAdded.Disconnect(SlotTargetCharacterStateAdded, this);
    }
    if (!targetID.IsNull() && targetID.GetType() == _global.Enums.TypeID.e_Type_GC_Character)
    {
        m_TargetCharacter = Character.GetCharacter(targetID);
        m_TargetCharacter.SignalBuffAdded.Connect(SlotTargetCharacterBuffAdded, this);
		m_TargetCharacter.SignalStateAdded.Connect(SlotTargetCharacterStateAdded, this);
    }
    else
    {
        m_TargetCharacter = undefined;
    }
}

function SlotOffensiveTargetChanged(targetID)
{
    InitializeTarget(targetID);    
}

function SlotClientCharacterAlive()
{
    InitializeClientCharacter();
}

function SlotClientCharacterBuffAdded(buffID:Number)
{
    ShowBuff(m_ClientCharacter, m_ClientCharacter.m_BuffList[buffID], _global.Enums.InfoContext.e_ToPlayer);
}

function SlotTargetCharacterBuffAdded(buffID:Number)
{
    ShowBuff(m_TargetCharacter, m_TargetCharacter.m_BuffList[buffID], _global.Enums.InfoContext.e_Other);    
}

function SlotClientCharacterStateAdded(stateID:Number)
{
	if (ShouldShowText(_global.Enums.InfoContext.e_ToPlayer))
	{
		var text:String = AddFontColor( GetStateName(stateID), GetStateColor(stateID));
		var damageText = new DamageText(m_ClientCharacter);
		damageText.m_OverrideText = text;
		damageText.m_Scale = 50;
		damageText.m_Context = _global.Enums.InfoContext.e_ToPlayer;
		damageText.m_EffectType = DamageText.NEUTRAL_EFFECT;
		damageText.UpdateText();
		CreateAndPositionText(damageText, m_ClientCharacter, undefined, 0);
	}
}

function SlotTargetCharacterStateAdded(stateID:Number)
{
	if (ShouldShowText(_global.Enums.InfoContext.e_FromPlayer))
	{
		var text:String = AddFontColor( GetStateName(stateID), GetStateColor(stateID));
		var damageText = new DamageText(m_TargetCharacter);
		damageText.m_OverrideText = text;
		damageText.m_Scale = 50;
		damageText.m_Context = _global.Enums.InfoContext.e_FromPlayer;
		damageText.m_EffectType = DamageText.NEUTRAL_EFFECT;
		damageText.UpdateText();
		CreateAndPositionText(damageText, m_TargetCharacter, undefined, 0);
	}
}


function GetStateName(stateID:Number):String
{
	switch(stateID)
	{
		case _global.Enums.CharacterState.e_CharacterState_Afflicted:
			return LDBFormat.LDBGetText("GenericGUI", "StateAfflicted");
		case _global.Enums.CharacterState.e_CharacterState_Hindered:
			return LDBFormat.LDBGetText("GenericGUI", "StateHindered");
		case _global.Enums.CharacterState.e_CharacterState_Impaired:
			return LDBFormat.LDBGetText("GenericGUI", "StateImpaired");
		case _global.Enums.CharacterState.e_CharacterState_Weakened:
			return LDBFormat.LDBGetText("GenericGUI", "StateWeakened");
	}
	
	return "";
}

function GetStateColor(stateID:Number):String
{
	switch(stateID)
	{
		case _global.Enums.CharacterState.e_CharacterState_Afflicted:
			return "DF886A";//DOT
		case _global.Enums.CharacterState.e_CharacterState_Hindered:
			return "8BD6BD";//ROOTSNARE
		case _global.Enums.CharacterState.e_CharacterState_Impaired:
			return "ECA153";//STUN
		case _global.Enums.CharacterState.e_CharacterState_Weakened:
			return "ADD564";//DEBUFFS
	}
	
	return "FFFFFF";
}


function RemoveDamageInfo(damageInfoClip:MovieClip)
{
    for (var i:Number = 0; i < m_PlayerDamageTexts.length; i++)
    {
        if (m_PlayerDamageTexts[i].m_DamageClip == damageInfoClip)
        {
            m_PlayerDamageTexts.splice(i, 1);
            break;
        }
    }
	
	for (var i:Number = 0; i < m_TargetDamageTexts.length; i++)
    {
        if (m_TargetDamageTexts[i].m_DamageClip == damageInfoClip)
        {
            m_TargetDamageTexts.splice(i, 1);
            break;
        }
    }
    damageInfoClip.removeMovieClip();
}
function SlotDamageInfo( statID:Number, damage:Number, absorb:Number, attackResultType:Number, attackType:Number,  attackOffensiveLevel:Number, attackDefensiveLevel:Number, context:Number, targetID:ID32, iconID:ID32, iconColorLine:Number, combatLogFeedbackType:Number )
{
    //Show only the interesting ones
	var isHeal:Boolean = attackResultType == _global.Enums.AttackResultType.e_AttackType_SpellHeal || attackResultType == _global.Enums.AttackResultType.e_AttackType_SpellCriticalHeal || (combatLogFeedbackType != undefined  && combatLogFeedbackType > -1);
    if (ShouldShowText(context, isHeal) && (damage != 0 || absorb != 0) )
    {
        var targetCharacter:Character = Character.GetCharacter(targetID);
        if (targetCharacter != undefined)
        {
	        var damageText:DamageText = new DamageText(targetCharacter);
            damageText.m_StatId = statID;
            damageText.m_Damage = damage;
            damageText.m_Absorb = absorb;
            damageText.m_AttackResultType = attackResultType;
            damageText.m_AttackType = attackType;
            damageText.m_AttackOffensiveLevel = attackOffensiveLevel;
            damageText.m_AttackDefensiveLevel = attackDefensiveLevel;
            damageText.m_Context = context;
			damageText.m_CombatLogFeedbackType = combatLogFeedbackType;
            
            damageText.UpdateText();
            
			//http://jira.funcom.com/browse/TSW-55621
			//Do not show connected buffs until they have decided            
            CreateAndPositionText(damageText, targetCharacter/*, iconID, iconColorLine*/);
        }
    }
}

function ShouldShowText(context:Number, isHeal:Boolean)
{
	return ((context == Enums.InfoContext.e_FromPlayer && m_ShowTargetDamageText) || 
			(context == Enums.InfoContext.e_ToPlayer && (isHeal == undefined || (!isHeal && m_ShowPlayerDamageText) || (isHeal && m_ShowPlayerHealText))));
}

function SlotShowText(text:String, context:Number, targetID:ID32)
{
    if (ShouldShowText(context))
    {        
        var targetCharacter:Character = Character.GetCharacter(targetID);
		text = AddFontColor(text, "FF2200");
        
        var damageText:DamageText = new DamageText(targetCharacter);
        
        damageText.m_Scale = 30;
        damageText.m_Context = context;
        damageText.m_EffectType = DamageText.NEUTRAL_EFFECT;
        damageText.m_OverrideText = text;
        damageText.UpdateText();
        
        CreateAndPositionText(damageText, targetCharacter);
    }
}

function AddFontColor(text:String, color:String)
{
	return com.Utils.Format.Printf("<font color='#%s'>%s</font>", color, text);
}

function CreateAndPositionText(damageText:DamageText, character:Character, iconID:ID32, iconColorLine:Number)
{
    var damageClip:MovieClip = CreateDamageClip(damageText, iconID, iconColorLine);
	if(damageText.m_Context == Enums.InfoContext.e_ToPlayer)
	{
		damageClip._xscale = damageText.m_Scale;
		damageClip._yscale = damageText.m_Scale;
		var offset:Point = new Point((1 - 2 * Math.random()) * 5, (1 - 2 * Math.random()) * 5);
    
        offset.x = GetXPlayerOffset(damageText.m_EffectType);
		
		damageText.m_ScreenOffset = offset;
		
		if (!QueueExists(character) && !IsOverlappingLastText(damageText, character, damageText.m_Context))
		{
			//Put an object in the damagetexts list to update the position realtime
			StartAnimation(damageClip);
			m_PlayerDamageTexts.push(damageText);
			
			//Update the position of the text immidiately as there might be more incoming the same frame before it is updated automatically
			m_PlayerDamageTexts[m_PlayerDamageTexts.length - 1].UpdatePosition(m_ResolutionScale);
		}
		else
		{
			var queueObject = { m_DamageText:damageText, m_Context:damageText.m_Context }
			damageText.SetVisible(false);
			var characterQueue:Array;
			for (var i:Number = 0; i < m_DamageTextQueues.length; i++)
			{
				if (m_DamageTextQueues[i][0].m_DamageText.m_Character == character)
				{
					characterQueue = m_DamageTextQueues[i];
				}
			}
			if (characterQueue == undefined)
			{
				characterQueue = new Array();
				m_DamageTextQueues.push(characterQueue);
			}
			characterQueue.push(queueObject);
		}
	}
	else
	{
		m_TargetDamageTexts.push(damageText);
		//Update the position of the text immidiately as there might be more incoming the same frame before it is updated automatically
		m_TargetDamageTexts[m_TargetDamageTexts.length - 1].UpdatePosition(m_ResolutionScale);
	}
		


}

function GetLastText(character:Character)
{
    for (var i:Number = m_PlayerDamageTexts.length - 1; i > -1; i--)
    {
        if (m_PlayerDamageTexts[i].m_Character == character)
        {
            return m_PlayerDamageTexts[i];
        }
    }
    return undefined;
}

function QueueExists(character:Character)
{
	for (var i:Number = 0; i < m_DamageTextQueues.length; i++)
	{
		if (m_DamageTextQueues[i][0].m_DamageText.m_Character == character)
		{
			return true;
		}
	}
	return false;
}

function GetGlobalHeight(mc:MovieClip):Number
{
    var bounds = mc.getBounds(_root);
    return bounds.yMax - bounds.yMin;
}


function CreateDamageClip(damageText:DamageText, iconID:ID32, iconColorLine:Number ) : MovieClip
{
    var holder:MovieClip = createEmptyMovieClip( "DamageHolder" + UID(), getNextHighestDepth() );
    var textClip = holder.attachMovie( "DamageText", "m_DamageClip", holder.getNextHighestDepth() );

	textClip.textField.html = true;
	textClip.textField.htmlText = damageText.GetText();
    textClip.textField.autoSize = "left";
		
	var width = textClip.textField.getTextFormat().getTextExtent(textClip.textField.text).textFieldWidth;
	var height = textClip.textField.getTextFormat().getTextExtent(textClip.textField.text).textFieldHeight;
	textClip.textField._x = -width / 2
	textClip.textField._y = -height / 2
    
	
	if (damageText.m_Context == Enums.InfoContext.e_ToPlayer)
	{
		var buffClip = undefined;
		var endY:Number = 200 *(100/damageText.m_Scale);
	
		if (iconID != undefined && !iconID.IsNull() && iconID.GetInstance() != 0)
		{
			buffClip = CreateBuffClip(holder, iconID, iconColorLine)
			buffClip._x = width * 0.5;
			buffClip._y = 12;
			buffClip._xscale = 140;
			buffClip._yscale = 140;
			endY += 12;
		}
		
		if (damageText.m_Context != _global.Enums.InfoContext.e_ToPlayer)
		{
			endY = -endY
		}
		holder.m_EndAnimationY = endY;
	}
	else
	{
		var offset:Point = undefined;
		if (damageText.m_AttackResultType == _global.Enums.AttackResultType.e_AttackType_CriticalHit 
			|| damageText.m_AttackDefensiveLevel == _global.Enums.AttackDefensiveLevel.e_DefensiveLevel_Penetrated)
		{
			offset =  new Point((1 - 2 * Math.random()) * 20, ((1 - 2 * Math.random()) * 30) - 180);
			textClip._alpha = 0;
			textClip._xScale = 300;
			textClip._yScale = 300;
			var endPoint:Point = new Point(textClip._x + ((1 - 2 * Math.random()) * 70), (1-2 * Math.random()) * 10);
			textClip._x = textClip._x + ((1 - 2 * Math.random()) * 70);
			textClip.tweenTo(0.3, { _x:endPoint.x, _y:endPoint.y, _alpha:100, _xscale:100, _yscale:100 }, mx.transitions.easing.Strong.easeOut);
			textClip.onTweenComplete = function()
			{
				this.tweenTo(0.8, {  }, mx.transitions.easing.None.easeNone);
				this.onTweenComplete = function()
				{
					this.tweenTo(0.5, { _alpha:0 }, mx.transitions.easing.Regular.easeOut);
					this.onTweenComplete = function()
					{
						RemoveDamageInfo(holder);
					}
				}
			}
		}
		else if (damageText.m_EffectType == DamageText.NEUTRAL_EFFECT)
		{
			offset = new Point(0,0);
			textClip._alpha = 0;
			textClip._xScale = 0;
			textClip._yScale = 0;
			
			textClip.tweenTo(0.2, {_x:_x, _y:-100, _xscale:70, _yscale:70, _alpha:100 }, mx.transitions.easing.None.easeNone);
			textClip.onTweenComplete = function()
			{
				
				this.tweenTo(1.2, { _xscale:90, _yscale:90}, mx.transitions.easing.None.easeNone);
				this.onTweenComplete = function()
				{
					this.tweenTo(0.4, { _alpha:0, _xscale:100, _yscale:100 }, mx.transitions.easing.None.easeNone);
					this.onTweenComplete = function()
					{
						RemoveDamageInfo(holder);
					}
				}
				
			}
		}
		else
		{
			//White damage shows jumping
			offset = new Point((1 - 2 * Math.random()) * 20, ((1 - 2 * Math.random()) * 20));
			
			var curveStart:Point = new Point(0, 0);
			var curveEnd:Point = new Point( Math.random() * 70 + 80 , 0);
			var curveTop:Point = new Point((curveEnd.x - curveStart.x) / 2, -100);
			
			var tweenInTime:Number = 0.3;
			var tweenOutTime:Number = 0.4;
			var alpha1:Number = 60;
			var alpha2:Number = 50;
			var alpha3:Number = 30;
			
			if (damageText.m_AttackOffensiveLevel == _global.Enums.AttackOffensiveLevel.e_OffensiveLevel_Glancing ||
				damageText.m_AttackDefensiveLevel == _global.Enums.AttackDefensiveLevel.e_DefensiveLevel_Blocked ||
				damageText.m_AttackResultType == _global.Enums.AttackResultType.e_AttackType_Evade)
			{
				curveTop.x += 25;
				curveEnd.x += 50;
				tweenInTime = 0.6;
				tweenOutTime = 1.0
				alpha1 = 90;
				alpha2 = 80;
				alpha3 = 70;
			}
			
			var start:Point = GetPointOnBezier( 0, curveStart, curveTop, curveEnd);
			var p1:Point = GetPointOnBezier( 0.25, curveStart, curveTop, curveEnd);
			var p2:Point = GetPointOnBezier( 0.50, curveStart, curveTop, curveEnd);
			var p3:Point = GetPointOnBezier( 0.75, curveStart, curveTop, curveEnd);
			var p4:Point = GetPointOnBezier( 1, curveStart, curveTop, curveEnd);
			
			textClip._alpha = 100;
			textClip._xScale = 120;
			textClip._yScale = 120;
			
			textClip.tweenTo(tweenInTime / 2, { _x:p1.x, _y:p1.y, _xscale:60, _yscale:60, _alpha:alpha1 }, mx.transitions.easing.None.easeNone);
			textClip.onTweenComplete = function()
			{
				this.tweenTo(tweenInTime / 2, { _x:p2.x, _y:p2.y, _xscale:50, _yscale:50,  _alpha:alpha2}, mx.transitions.easing.None.easeNone);
				this.onTweenComplete = function()
				{
					this.tweenTo(tweenOutTime/2, { _x:p3.x, _y:p3.y, _xscale:40, _yscale:40,  _alpha:alpha3}, mx.transitions.easing.None.easeNone);
					this.onTweenComplete = function()
					{
						this.tweenTo(tweenOutTime/2, { _x:p4.x, _y:p4.y, _xscale:40, _yscale:40,  _alpha:0}, mx.transitions.easing.None.easeNone);
						this.onTweenComplete = function()
						{
							RemoveDamageInfo(holder);
						}
					}
				}
			}
		}
		damageText.m_ScreenOffset = offset;
	}

    damageText.m_DamageClip = holder;
    
    return holder;
}

function GetPointOnBezier( t:Number, p0:Point, p1:Point, p2:Point ) : Point 
{    
	t = Math.max( Math.min( 1, t ), 0 );    
	var tSq:Number = t * t;
    var diff:Number = 1 - t;
    var diffSq:Number = diff * diff;
    diff *= 2 * t; //don't need to recalculate this for x and y
    var point:Point = new Point();
	point.x = diffSq * p0.x + diff * p1.x + tSq * p2.x;
    point.y = diffSq * p0.y + diff * p1.y + tSq * p2.y;
    return point; 
}

function StartAnimation(damageClip:MovieClip)
{
	if (damageClip.m_DamageClip != undefined)
	{
		damageClip.m_DamageClip.m_TweenAlpha = 500;
		damageClip.m_DamageClip.tweenTo(m_TweenTime, { _y: damageClip.m_EndAnimationY, m_TweenAlpha: 0 }, None.easeNone)
		damageClip.m_DamageClip.onTweenComplete = function()
		{
			RemoveDamageInfo(damageClip);
		}
	}
}

function ShowBuff(character:Character, buffData:BuffData, context:Number)
{
    if (!Spell.IsTokenState(buffData.m_BuffId) && m_ShowPlayerHealText && context == _global.Enums.InfoContext.e_ToPlayer)
    {
		var damageClip = createEmptyMovieClip( "BuffHolder" + UID(), getNextHighestDepth() );
        var buffClip:MovieClip = CreateBuffClip(damageClip, buffData.m_Icon, buffData.m_ColorLine, context);
		buffClip._x = -buffClip._width / 2;
		
		    
		var endY:Number = 200;
		if (context != _global.Enums.InfoContext.e_ToPlayer)
		{
			endY = -endY;
		}
		
        var offset:Point = new Point((1 - 2 * Math.random()) * 5, (1 - 2 * Math.random()) * 5);
                
        ///If its the player, good things are on the left, bad things on the right
        if (context == Enums.InfoContext.e_ToPlayer)
        {
            offset.x = GetXPlayerOffset(buffData.m_Hostile ? DamageText.NEGATIVE_EFFECT:DamageText.POSITIVE_EFFECT);
        }
        
        //Put an object in the damagetexts list to update the position realtime
        var damageText:DamageText = new DamageText(character);
        damageText.m_DamageClip = damageClip;
        damageText.m_ScreenOffset = offset;
		damageClip.m_EndAnimationY = endY;
        damageClip.m_Context = context;
    
		if (!QueueExists(character) && !IsOverlappingLastText(damageText, character, context))
		{
			//Put an object in the damagetexts list to update the position realtime
			StartAnimation(damageClip);
			m_PlayerDamageTexts.push(damageText);
			
			//Update the position of the text immidiately as there might be more incoming the same frame before it is updated automatically
			m_PlayerDamageTexts[m_PlayerDamageTexts.length - 1].UpdatePosition(m_ResolutionScale);
		}
		else
		{
			var queueObject = { m_DamageText:damageText, m_Context:context }
			damageText.SetVisible(false);
			var characterQueue:Array;
			for (var i:Number = 0; i < m_DamageTextQueues.length; i++)
			{
				if (m_DamageTextQueues[i][0].m_DamageText.m_Character == character)
				{
					characterQueue = m_DamageTextQueues[i];
				}
			}
			if (characterQueue == undefined)
			{
				characterQueue = new Array();
				m_DamageTextQueues.push(characterQueue);
			}
			characterQueue.push(queueObject);
			
		}
    }
}

function GetXPlayerOffset(effectType:Number):Number
{
    var offset:Number = 0;
    if (effectType == DamageText.NEGATIVE_EFFECT)
    {
        offset = 150
    }
    else if (effectType == DamageText.POSITIVE_EFFECT)
    {
        offset = -150;
    }
    if (DistributedValue.GetDValue("InvertDamageSides"))
    {
        offset = -offset;
    }
    return offset;
}

function IsOverlappingLastText(damageText:DamageText, character:Character, context:Number)
{
	//Get the last text belonging to this character
    var lastText:DamageText = GetLastText(character);
    var isOverlapping:Boolean= false;
    if (lastText != undefined)
    {
        //Get the position of the new text, and move it into the global coordinatesystem
        var newPos:Point = character.GetScreenPosition(_global.Enums.AttractorPlace.e_CameraAim);
        newPos.x = newPos.x / m_ResolutionScale;
        newPos.y = newPos.y / m_ResolutionScale;
        this.localToGlobal(newPos);
        
        //Get the position of the last text and get it into the global coordinatesystem
        var lastPos = new Point(lastText.m_DamageClip.m_DamageClip._x, lastText.m_DamageClip.m_DamageClip._y);
        lastText.m_DamageClip.localToGlobal(lastPos);
        

		if (context == Enums.InfoContext.e_ToPlayer)
		{
			//If this is on a player, we check if the new text is overlapping or below the last text, in that case move it above the old text
			var newHeight:Number = GetGlobalHeight(damageText.m_DamageClip) + m_StackPadding;
			var overlappingX:Boolean = (damageText.m_ScreenOffset.x > 0 && lastText.m_ScreenOffset.x > 0) || (damageText.m_ScreenOffset.x < 0 && lastText.m_ScreenOffset.x < 0);
			var distance:Number = newPos.y + newHeight - lastPos.y;
			if (newPos.y + newHeight >= lastPos.y && overlappingX)
			{
				isOverlapping = true;
			}
		}
		else
		{
			//If this isnt a player, we check if the new text is overlapping or above the last text, and in that case move it below the old text
			var lastHeight:Number = GetGlobalHeight(lastText.m_DamageClip) + m_StackPadding;
			if (lastPos.y + lastHeight >= newPos.y)
			{
				isOverlapping = true;
			}
		}		
    }
    return isOverlapping;	
}

function CreateBuffClip(parentClip:MovieClip, buffIcon:ID32, buffColorLine:Number)
{
    var buffClip:MovieClip = parentClip.attachMovie( "BuffBorder", "m_DamageClip", parentClip.getNextHighestDepth() );
    
    m_BuffCliploader.loadClip( Utils.CreateResourceString(buffIcon), buffClip.i_Icon );
    buffClip.i_Icon._xscale = buffClip.i_Icon._width;
    buffClip.i_Icon._yscale = buffClip.i_Icon._height;
    
    com.Utils.Colors.ApplyColor(buffClip.i_Border.i_Background, com.Utils.Colors.GetColor( buffColorLine) )

	return buffClip
}
