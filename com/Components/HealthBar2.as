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
    private var m_Percent:Number;
    
    private var m_Max:Number;
    private var m_Current:Number;
    
    private var m_Text:TextField;
    private var m_Bar:MovieClip;
    
    private var m_AlwaysVisible:Boolean;
    private var m_ShowText:Boolean;
    private var m_TextType:Number;

    public function HealthBar()
    {
       /// trace("healthbar initiated")
        m_ShowText = true;
        m_TextType = STATTEXT_NUMBER;
        m_CurrentStatID = _global.Enums.Stat.e_Health;
        m_MaxStatID = _global.Enums.Stat.e_Life;
        m_AlwaysVisible = true;
        
        m_Text.autoSize = "center";
    }
    /*
    private function Init(CurrentStatID:Number, MaxStatID:Number, AlwaysVisible:Boolean)
    {
        //trace('CommonLib.StatBar:Init(' + CurrentStatID + ', ' + MaxStatID + ', '+AlwaysVisible+')');
        
        m_CurrentStatID = CurrentStatID;
        m_MaxStatID = MaxStatID;

        m_AlwaysVisible = AlwaysVisible;
    }
    */
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
        
        var currentStat = m_Dynel.GetStat( m_CurrentStatID, 2 /* full */ );
        SetCurrent( currentStat, true );
        var maxStat = m_Dynel.GetStat( m_MaxStatID, 2 /* full */ );
        SetMax( maxStat, true );
        
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
        m_Text._y = (m_Bar._height - m_Text._height) * 0.5;
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
        UpdateStatBar();        
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
              SetCurrent(  m_Dynel.GetStat( stat, 2 ), false)
              break;
            case m_MaxStatID:
              SetMax( m_Dynel.GetStat( stat, 2  ), false);
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
    private function SetCurrent(stat:Number, snap:Boolean) : Void
    {
      //trace('CommonLib.StatBar:SetCurrent(' + stat + ')')    
      
      m_Current = stat;
      
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
            // FIXME: HACK TO AVIOD SOME VISUAL ARTIFACTS WHEN CHANGING _visible FROM false TO true IN SCALEFORM 4.0.13. SHOULD SET _visible INSTEAD.
            Show();
            m_Percent = Math.min(100, Math.round(100 * m_Current / m_Max));
            var scale:Number = 100 - m_Percent ;
            
            m_Bar.m_Gray.tweenEnd( false );
            if (snap)
            {
                m_Bar.m_Gray._xscale = scale;
                
            }
            else
            {
                m_Bar.m_Gray.tweenTo(0.5, { _xscale: scale }, None.easeNone);
            }
            
            if (m_Percent < 25)
            {
                m_Bar.m_Red._visible = true;
                m_Bar.m_Red._alpha = 100;
            }
            else if (m_Percent < 35)
            {
                var alpha = 100 - ((m_Percent - 25 ) * 10);
                m_Bar.m_Red.tweenEnd( false );
                if (snap)
                {
                    m_Bar.m_Red._alpha = alpha
                }
                else
                {
                    m_Bar.m_Red.tweenTo(0.5, { _alpha: alpha }, None.easeNone);
                }
            }
            else
            {
                m_Bar.m_Red._visible = false;
                m_Bar.m_Red._alpha = 100;
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