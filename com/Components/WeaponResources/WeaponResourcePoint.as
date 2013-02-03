import com.Components.ResourceBase;



class com.Components.WeaponResources.WeaponResourcePoint extends ResourceBase
{
    public function WeaponResourcePoint()
    {
        super();
        m_ResourceDisplayType = DISPLAY_POINTS;
    }
    
    function configUI()
    {
        SetThrottle(m_Throttle && m_IsInCombat);
    }
    
    private function Layout(snap:Boolean)
    {
        // increasing
        if (m_Amount > m_PreviousAmount)
        {
            for (var i:Number = m_PreviousAmount; i <= m_Amount; i++)
            {
				if (i != 0)
				{
					if (snap)
					{
						this["point" + i].gotoAndStop("on");
					}
					else
					{
						this["point" + i].m_StopFrame = 10;
						this["point" + i].gotoAndStop("add");
						this["point" + i].onEnterFrame = function()
						{
							if (this._currentFrame < this.m_StopFrame)
							{
								this.nextFrame();
							}
							else
							{
								this.onEnterFrame = null;
							}
						}
					}
				}
            }
        }
        // decreasing
        else if (m_Amount < m_PreviousAmount && !m_Throttle)
        {
            for (var i:Number = m_Amount; i < m_PreviousAmount; i++)
            {
				if (snap)
				{
					this["point" + (i+1)].gotoAndStop("off");
				}
				else
				{
					this["point" + (i+1)].gotoAndPlay("remove");
				}
				
            }
        }

        m_PreviousAmount = m_Amount;
        SetThrottle(m_Amount == m_MaxAmount);
    }
    
    public function SetThrottle(throttle:Boolean)
    {
        /// removing throttle
        if ((m_Throttle && !throttle) || (!m_IsInCombat && m_Throttle))
        {
            for (var i:Number = 1; i <= m_MaxAmount; i++ )
            {
                if (i <= m_Amount)
                {
                    this["point" + i].gotoAndPlay("throttle_on");
                }
                else
                {
                    this["point" + i].gotoAndPlay("throttle_off");
                }
                
            }
        }
        else if (throttle && m_IsInCombat)
        {
            for (var i:Number = 1; i <= m_MaxAmount; i++ )
            {
                this["point" + i].gotoAndPlay("throttle");
            }
        }
        m_Throttle = throttle;
    }
}