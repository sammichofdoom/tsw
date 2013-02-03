import com.GameInterface.GUIUtils.StringUtils;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.GroupElement;
import com.GameInterface.DistributedValue;
import mx.utils.Delegate;
import gfx.motion.Tween;
import mx.transitions.easing.*;

/// the statbar components will extend any MovieClip
/// tha statbar references two items,
/// * i_Bar - the bar that moves, used to add or remove "chunks" wne big changes to the stats are invoked
/// * i_StatText - a textfield that will display percent or numbers representing the bar

class com.Components.StatBar extends MovieClip
{
    var m_Dynel:Dynel;
    var m_GroupElement:GroupElement;
    // The value of the current stat.
    var m_Current:Number;
    var i_StatText:TextField;
    var i_Bar:MovieClip
    // The value of the max stat.
    var m_Max:Number;
    var m_CurrentFrame:Number;
    var m_TargetFrame:Number;
    var m_NameXOrgPos:Number; // Used for placing the star and for moving the text back to org pos.
    var m_ShowStatText:Boolean;
    var m_ShowStatTextAsPercent:Boolean;
    var m_CurrentStatID:Number;
    var m_MaxStatID:Number;
    var m_FadeWhenInactive:Boolean;
    var m_FadeTimer:Number;
	var m_Fading:Boolean;
    var m_AlwaysVisible:Boolean;
    
    //Dirty hacks
    var m_FrameCount:Number;
    var m_FrameResetHack:Number = 30;
    var m_CurrentFrameHack:Number;
    var m_CurrentFrameHackMax:Number = 20;
        
    public function StatBar()
    {
        //trace('CommonLib.StatBar:StatBar()')
        super();
        m_CurrentFrame = 1;
        m_TargetFrame  = 1;
		m_ShowStatText = true;
		m_ShowStatTextAsPercent = false;
		m_CurrentStatID = 0;
		m_MaxStatID = 0;
		m_FadeWhenInactive = false;
		m_FadeTimer = undefined;
		m_Fading = false;
        m_CurrentFrameHack = 0;
        m_FrameCount = 0;
    }

    public function Init(CurrentStatID:Number, MaxStatID:Number, AlwaysVisible:Boolean)
    {
        //trace('CommonLib.StatBar:Init(' + CurrentStatID + ', ' + MaxStatID + ', '+AlwaysVisible+')');
        
        m_CurrentStatID = CurrentStatID;
        m_MaxStatID = MaxStatID;
        m_CurrentFrame = 0;
        m_TargetFrame  = 1;
        m_AlwaysVisible = AlwaysVisible;
        stop();
    }

	public function SetFadeWhenInactive(fade:Boolean)
	{
		m_FadeWhenInactive = fade;
	}
    
    public function SetDynel(dynel:Dynel)
    {        
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
        SetCurrent( currentStat );
        var maxStat = m_Dynel.GetStat( m_MaxStatID, 2 /* full */ );
        SetMax( maxStat );
        
        //Connect to stat updated
        m_Dynel.SignalStatChanged.Connect(SlotStatChanged, this);
    }
    
    public function SetGroupElement(groupElement:GroupElement)
    {
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
    
    function SlotCharacterEntered()
    {
        SetDynel(Dynel.GetDynel(m_GroupElement.m_CharacterId));
    }
    
    function SlotCharacterExited()
    {
        ClearBar();
    }

    private function ClearBar( )
    {
        // Note: We now know that the next max and current updates will be because of a change of the slot and so we should not have any effect on the bar.

        // This will make the bar update only when both max and current has been set, and then without any effect.
        m_Current = undefined;
        m_Max = undefined;
        
        m_CurrentFrame = 0;
        m_TargetFrame = 1;
        UpdateStatText();
        UpdateStatBar();        
    }
    
    /// listens to a change in stats.
    /// @param p_stat:Number  -  The type of stat, defined in the Stat  Enum
    /// @param p_value:Number -  The value of the stat
    private function SlotStatChanged( stat:Number, value:Number )
    {
        switch( stat )
        {
            case m_CurrentStatID:
              SetCurrent(  m_Dynel.GetStat( stat, 2 ))
              break;
            case m_MaxStatID:
              SetMax( m_Dynel.GetStat( stat, 2  ));
              break;
        }
    }

    /// Retrieves the maxhealt and creates a factor by dividing it with the number of frames in the active 
    /// statbar, if max health is 0 remove the healthbar, othervise set the max health text
    /// @param maxStat:String - the max stat as a string
    /// @return void
    private function SetMax( maxStat:Number) : Void
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
		UpdateStatBar();
    }
    
    private function UpdateStatText()
    {
        //trace('CommonLib.StatBar:UpdateStatText()')
        
        if ( this.i_StatText )
        {
            var s:String = "";
            if (  this.i_StatText && m_Current != undefined && m_Max != undefined && m_ShowStatText)
            {
                if (m_ShowStatTextAsPercent)
                {
                    s = Math.round(100 * m_Current / m_Max) + "%";
                }
                else
                {
                    s = Math.floor(m_Current) + " / " + Math.floor(m_Max);
                }
            }
            this.i_StatText.text = s;
        }
    }
    
    /// Updates the stat text and bar
    /// @param stat:String - the health as a string
    /// @return void
    private function SetCurrent(stat:Number) : Void
    {
      //trace('CommonLib.StatBar:SetCurrent(' + stat + ')')    
      
      m_Current = stat;
      
      UpdateStatText();
      UpdateStatBar();
    }
	
	public function Update()
	{
        m_FrameCount++; 
        if (m_CurrentFrameHack > 0)
        {
            m_CurrentFrameHack--;
            gotoAndStop(1);
            if (m_CurrentFrameHack == 0) gotoAndStop(m_TargetFrame);
            m_CurrentFrame = m_TargetFrame;
            return;
        }
        
        if (m_FrameCount == m_FrameResetHack)
        {
            var currentFrame:Number = _currentframe;
            gotoAndStop(1);
            gotoAndStop(currentFrame);
            m_FrameCount = 0;
        }
        
		if ( m_TargetFrame != m_CurrentFrame )
		{
			// movement!
			m_Fading=false;
			if (m_FadeTimer != undefined)
			{
				clearInterval( m_FadeTimer );
				m_FadeTimer = undefined;
			}
		}

        if ( m_TargetFrame == m_CurrentFrame )
        {
         	//var delay:Number = DistributedValue.GetDValue("HudFadeDelay");
			//if (m_FadeWhenInactive && m_FadeTimer == undefined && m_Current == m_Max && delay != 0)
			//{
				//m_FadeTimer = setInterval( Delegate.create( this, OnFadeTimer ), delay*1000 );
			//}

        }
        else if ( m_TargetFrame > m_CurrentFrame )
        {
            var dist = m_TargetFrame - m_CurrentFrame;
            if ( dist > 4 )
            {
                m_CurrentFrame = Math.floor( m_CurrentFrame + (dist*0.3) );
            }
            else
            {
                m_CurrentFrame = m_TargetFrame;
            }
            gotoAndStop( m_CurrentFrame );
        }
        else
        {
            var oldPos = this.i_Bar.getBounds(this);
          
            m_CurrentFrame = m_TargetFrame;
            gotoAndStop( m_CurrentFrame );
            
            if( this.i_Bar )
            {
                var newPos = this.i_Bar.getBounds(this);

                // Show effect if not too small chunk.
                var size = (oldPos.xMax - oldPos.xMin) - (newPos.xMax - newPos.xMin);

                if( size > 5 )
                {
                    var clip = attachMovie( "Fade", "fade", this.getNextHighestDepth() )
                        if (clip._totalframes > 1)
                        {
                            clip.gotoAndStop( m_CurrentFrame )
                        }
                    clip._x = newPos.xMax;
                    clip._y = this.i_Bar._y ;

                    clip._xscale = size;
                    clip._yscale = this.i_Bar._height;

                    clip.onEnterFrame = function()
                    {
                        this._alpha -= 4;
                        if( this._alpha <= 1 )
                        {
                            this.removeMovieClip();
                        }
                    }
                }
            }
        }
	}
    private function onEnterFrame()
    {
      Update();
    }
    
    private function UpdateStatBar()
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
            //m_CurrentFrameHack = m_TargetFrame;
            //gotoAndStop(1);

            m_TargetFrame = Math.min( _totalframes, Math.floor(_totalframes * m_Current / m_Max) );
            if (m_CurrentFrame < 1 && m_CurrentFrameHack <= 0)
            {            
                m_CurrentFrame = m_TargetFrame;
                gotoAndStop(m_TargetFrame);
            }
        }
    }
    
    public function Hide()
    {
        _visible = false;
        gotoAndStop(1);
        m_CurrentFrameHack = m_CurrentFrameHackMax;
        m_CurrentFrame = 1;
    }
    public function Show()
    {
        _visible =  ( m_Current == m_Max) ? m_AlwaysVisible : true;
    }
    
    public function SetShowText(show:Boolean)
    {
        m_ShowStatText = show;
        UpdateStatText();
    }

    private function OnFadeTimer()
    {
        //trace('CommonLib.StatBar:OnFadeTimer()')  
        clearInterval( m_FadeTimer );
		m_Fading = true;
        m_FadeTimer = undefined;
        super.tweenTo( 6.0, {_alpha:1}, Back.easeOut );
    }
}
