import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.Game.Character;
import gfx.motion.Tween;
import mx.transitions.easing.*;

class com.Components.HealthBar extends MovieClip
{
    public static var STATTEXT_PERCENT:Number = 0;
    public static var STATTEXT_NUMBER:Number = 1;
    
    private var m_Dynel:Dynel;
    private var m_GroupElement:GroupElement;
    private var m_Character:Character;
    
    private var m_CurrentStatID:Number;
    private var m_MaxStatID:Number;
    private var m_BoostStatID:Number;
    
    private var m_Max:Number;
    private var m_Current:Number;
    private var m_Boost:Number;
    private var m_BoostMask:MovieClip;
    
    private var m_Text:TextField;
    private var m_Bar:MovieClip;
    
    private var m_AlwaysVisible:Boolean;
    private var m_ShowText:Boolean;
    private var m_TextType:Number;
    
    private var m_TweenTime:Number;
    private var m_TweenLimitPercent:Number;

    public function HealthBar()
    {
       /// trace("healthbar initiated")
        m_ShowText = true;
        m_TextType = STATTEXT_NUMBER;
        m_BoostStatID = _global.Enums.Stat.e_BarrierHealthPool;
        m_CurrentStatID = _global.Enums.Stat.e_Health;
        m_MaxStatID = _global.Enums.Stat.e_Life;
        m_AlwaysVisible = true;
        
        m_TweenTime = 0.05;
        m_TweenLimitPercent = 10;
        
        m_BoostMask = com.GameInterface.ProjectUtils.SetMovieClipMask(m_Bar.m_Boost, null, m_Bar.m_Boost._height, m_Bar.m_Boost._width/2, false);
        
        m_Text.autoSize = "center";
    }
    
    public function SetDynel( dynel:Dynel )
    {        
        //trace("SetDynel "+dynel)
        //Disconnect from old signal
        if (m_Dynel != undefined)
        {
            m_Dynel.SignalStatChanged.Disconnect(SlotStatChanged, this);
        }
        m_Dynel = dynel;
        
        ClearBar();
        if (dynel == undefined)
        {
            return;
        }
        
        var currentValue = m_Dynel.GetStat( m_CurrentStatID, 2 /* full */ );
        var boostValue = m_Dynel.GetStat( m_BoostStatID, 2 /* full */ );
        //m_Bar.m_Boost._xscale = 0; // looks better to init this from 0
        SetCurrent( currentValue, boostValue, true );
        var maxValue = m_Dynel.GetStat( m_MaxStatID, 2 /* full */ );
        SetMax( maxValue, true );
        
        //Connect to stat updated
        m_Dynel.SignalStatChanged.Connect(SlotStatChanged, this);
    }
    
    function SlotCharacterEntered()
    {
        SetDynel(Dynel.GetDynel(m_GroupElement.m_CharacterId));
    }
    
    function SlotCharacterExited()
    {
        ClearBar();
    }
    
    /// sets the scaling of the bar and repositions the textfield, this will also scale the textfield (uniformly) based on the input
    /// @param xscale:Number - The xscale
    /// @param yscale:Number - the yscale
    /// @param scaleText:Number [opt] -the scale of text, if omitted no scaling will occur
    public function SetBarScale( xscale:Number, yscale:Number, textScale:Number)
    {
        m_Bar._xscale = xscale;
        m_Bar._yscale = yscale;
        
        if (!isNaN( textScale ))
        {
            m_Text._xscale = textScale;
            m_Text._yscale = textScale;
        }
        
        m_Text._x = (m_Bar._width - m_Text._width) * 0.5;
        if (m_Text.htmlText.length == 0)
        {
           // because of autosizing, it needs to have text in order to be measured
           m_Text.htmlText = "0";
           m_Text._y = (m_Bar._height - m_Text._height) * 0.5;
           m_Text.htmlText = "";
        }
        else
        {
            m_Text._y = (m_Bar._height - m_Text._height) * 0.5;
        }
    }
    
    public function SetGroupElement(groupElement:GroupElement)
    {
        //trace("SetGroupElement "+groupElement)
        if (m_GroupElement != undefined)
        {
            m_GroupElement.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
            m_GroupElement.SignalCharacterExitedClient.Disconnect(SlotCharacterExited, this);
        }
        m_GroupElement = groupElement;
        if (m_GroupElement.m_OnClient)
        {
            SetDynel(Dynel.GetDynel(groupElement.m_CharacterId));
        }
        else
        {
            SetDynel(undefined);
        }
        if (groupElement != undefined)
        {
            m_GroupElement.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
            m_GroupElement.SignalCharacterExitedClient.Connect(SlotCharacterExited, this);
        }
        
    }

    public function SetCharacter(character:Character)
    {
        /// trace("SetCharacter "+character)
        if (m_Character != undefined)
        {
           // m_Character.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
           // m_Character.SignalCharacterExitedClient.Disconnect(SlotCharacterExited, this);
        }
        m_Character = character;

        if (m_Character)
        {
            SetDynel(m_Character);
        }
        else
        {
            SetDynel(undefined);
        }
        if (m_Character != undefined)
        {
            //m_Character.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
            //m_Character.SignalCharacterExitedClient.Connect(SlotCharacterExited, this);
        }
        
    }
    
    private function ClearBar( )
    {
        // Note: We now know that the next max and current updates will be because of a change of the slot and so we should not have any effect on the bar.

        // This will make the bar update only when both max and current has been set, and then without any effect.
        m_Current = undefined;
        m_Max = undefined;
        
        UpdateStatText();
        UpdateStatBar(true);        
    }
    
    /// listens to a change in stats.
    /// @param p_stat:Number  -  The type of stat, defined in the Stat  Enum
    /// @param p_value:Number -  The value of the stat
    private function SlotStatChanged( stat:Number, value:Number )
    {
        //trace("SlotStatChanged( "+stat+", "+value+" )")
        switch( stat )
        {
            case m_CurrentStatID:
            case m_BoostStatID:
              SetCurrent(  m_Dynel.GetStat( m_CurrentStatID, 2 ), m_Dynel.GetStat( m_BoostStatID, 2 ), false);
              break;
            case m_MaxStatID:
              SetMax( m_Dynel.GetStat( stat, 2  ), true);
              break;
        }
    }
    
    /// gets tha max and sets this as a member used to calculate the percent of health left (0 - 100, used for the _xscale)
    /// @param maxStat:String - the max stat as a string
    /// @return void
    private function SetMax( maxStat:Number, snap:Boolean) : Void
    {
		//trace('CommonLib.StatBar:SetMax(' + maxStat + ')')
		if( maxStat <= 0)
		{
			Hide();
			return;
		}
		else
		{
		   Show();
		}

		m_Max = maxStat;

		UpdateStatText();
		UpdateStatBar(snap);
    }
    
    /// Updates the stat text and bar
    /// @param stat:String - the health as a string
    /// @return void
    private function SetCurrent(currentValue:Number, boostValue:Number, snap:Boolean) : Void
    {
      //trace('CommonLib.StatBar:SetCurrent(' + stat + ')')
      if (currentValue == undefined || boostValue == undefined || m_Current == undefined || m_Boost == undefined ||
          Math.abs(currentValue + boostValue - m_Current - m_Boost) > m_Max / m_TweenLimitPercent)
      {
          snap = true;
      }
      m_Current = currentValue;
      m_Boost = boostValue;
      
      UpdateStatText();
      UpdateStatBar(snap);
    }
    
    /// Updates the text that overlays the healthbar updates it as percent or real numbers
    private function UpdateStatText()
    {
        //trace('CommonLib.StatBar:UpdateStatText()')
        
        if ( m_ShowText )
        {
            if (  m_Current != undefined && m_Max != undefined)
            {
                if (m_TextType == STATTEXT_PERCENT)
                {
                    m_Text.htmlText = Math.round(100 * m_Current / m_Max) + "%";
                }
                else if(m_TextType == STATTEXT_NUMBER)
                {
                    m_Text.htmlText = Math.floor(m_Current) + " / " + Math.floor(m_Max);
                }
            }
        }
    }
    
        
    private function UpdateStatBar(snap:Boolean)
    {
        //trace('CommonLib.StatBar:UpdateStatBar()')
        if ( m_Current == undefined || m_Max == undefined )
        {
            Hide(); // FIXME: HACK TO AVIOD SOME VISUAL ARTIFACTS WHEN CHANGING _visible FROM false TO true IN SCALEFORM 4.0.13. SHOULD SET _visible INSTEAD.
        }
        else
        {
            Show(); // FIXME: HACK TO AVIOD SOME VISUAL ARTIFACTS WHEN CHANGING _visible FROM false TO true IN SCALEFORM 4.0.13. SHOULD SET _visible INSTEAD.
            
            // scale of the gray overlay
            var scale:Number = Math.max(0, Math.min(100, 100 - (100 * (m_Current + m_Boost) / (m_Max + m_Boost))));
            
            // find left side of gray overlay (set scale to 1 temporarily, because we can't do this if the scale is 0
            var oldScale = m_Bar.m_Gray._xscale;
            m_Bar.m_Gray._xscale = 1;
            var grayLeft = m_Bar.m_Gray._x - (m_Bar.m_Gray._width * scale);
            m_Bar.m_Gray._xscale = oldScale;
           
            // percent factor of the visible health bar that should be covered by boost
            var boostFactor:Number = m_Boost > 0 ? Math.max(0, Math.min(100, m_Boost / (m_Boost + m_Current))) : 0;
            
            // find width of boost bar
            var boostWidth = (grayLeft - m_Bar.m_Boost._x) * boostFactor;
            
            m_Bar.m_Gray.tweenEnd( false );
            m_Bar.m_Boost.tweenEnd( false );
            if (snap)
            {
                m_Bar.m_Gray._xscale = scale;
                m_BoostMask._x = grayLeft - boostWidth;
                m_BoostMask._width = boostWidth;
            }
            else
            {
                m_Bar.m_Gray.tweenTo(m_TweenTime, { _xscale: scale }, None.easeNone);
                m_BoostMask.tweenTo(m_TweenTime, { _x: grayLeft - boostWidth, _width: boostWidth }, None.easeNone);
            }
            
            // percent of health - determines color
            var percent:Number = Math.min(100, Math.round(100 * m_Current / m_Max));
            
            // color change points
            var redPoint = 30;
            var orangePoint = 50;
            var yellowPoint = 70;
            var greenPoint = 90;
            
            // alpha levels
            var redAlpha:Number    = Math.max(0, Math.min(100, 100 - ((percent - redPoint)    / (orangePoint - redPoint)    * 100)));
            var orangeAlpha:Number = Math.max(0, Math.min(100, 100 - ((percent - orangePoint) / (yellowPoint - orangePoint) * 100)));
            var yellowAlpha:Number = Math.max(0, Math.min(100, 100 - ((percent - yellowPoint) / (greenPoint - yellowPoint)  * 100)));
            
            // end previous tweens
            m_Bar.m_Red.tweenEnd( false );
            m_Bar.m_Orange.tweenEnd( false );
            m_Bar.m_Yellow.tweenEnd( false );
            
            // adjust alphas
            if (snap)
            {
                m_Bar.m_Red._alpha = redAlpha;
                m_Bar.m_Orange._alpha = orangeAlpha;
                m_Bar.m_Yellow._alpha = yellowAlpha;
            }
            else
            {
                m_Bar.m_Red.tweenTo(m_TweenTime, { _alpha: redAlpha }, None.easeNone);
                m_Bar.m_Orange.tweenTo(m_TweenTime, { _alpha: orangeAlpha }, None.easeNone);
                m_Bar.m_Yellow.tweenTo(m_TweenTime, { _alpha: yellowAlpha }, None.easeNone);
            }
        }
    }

    public function Hide()
    {
        _visible = false;
    }
    public function Show()
    {
        _visible =  ( m_Current == m_Max) ? m_AlwaysVisible : true;
    }
    
    /// show the text
    /// @param showText:Boolean - Show the text or not
    public function SetShowText(showText:Boolean)
    {
        m_ShowText = showText;
        m_Text._visible = m_ShowText;
        UpdateStatText();
    }
    
    /// How to display the text, as numbers or percent
    /// @param textType:Number - How is the text displayed, using the static HealtBar.STATTEXT_...
    public function SetTextType(textType:Number)
    {
        if (textType == STATTEXT_PERCENT || textType == STATTEXT_NUMBER)
        {
            m_TextType = textType;
            UpdateStatText();
        }
    }
}