
class com.Utils.Interpolator
{
    public function Interpolator()
    {
        m_StartTime = getTimer() / 1000;
        m_EndTime   = m_StartTime;
        
        m_StartValue = 0;
        m_EndValue   = 0;
    }
    
    public function Start( duration:Number, startValue, endValue, ease:Function ) : Void
    {
        if ( duration >= 0 )
        {
            m_StartTime = getTimer() / 1000;
            m_EndTime = m_StartTime + duration;
        }
        m_StartValue = startValue;
        m_EndValue = endValue;
        m_EaseFunction = ease;
    }
    public function SetEndValue( duration:Number, endValue, ease:Function ) : Void
    {
        var curTime:Number = getTimer() / 1000;
        
        m_StartValue = GetTimeValue( curTime );        
        m_EndValue   = endValue;

        m_EaseFunction = ease;

        if ( duration >= 0 )
        {
            m_StartTime = curTime;
            m_EndTime = m_StartTime + duration;
        }
    }
    
    public function GetValue( progress:Number )
    {
        if ( progress < 0 )
        {
            return m_StartValue;
        }
        else if ( progress >= 1 )
        {
            return m_EndValue;
        }
        else
        {
            if ( m_EaseFunction )
            {
                return m_EaseFunction( progress, m_StartValue,  m_EndValue - m_StartValue, 1 );
            }
            else
            {
                return m_StartValue + (m_EndValue - m_StartValue) * progress;
            }
        }
    }

    public function GetTimeValue( time:Number )
    {
        return GetValue( (time - m_StartTime) / (m_EndTime - m_StartTime) );
    }

    public function GetCurrentValue()
    {
        return GetTimeValue( getTimer() / 1000 );
    }

    public function GetStartValue()
    {
        return m_StartValue;
    }

    public function GetEndValue()
    {
        return m_EndValue;
    }
    
    public function SetTarget( object:Object, property:String )
    {
        var hadTarget:Boolean = m_TargetProperty != undefined;
        var hasTarget:Boolean = Object != undefined;
        
        m_TargetObj = object;
        m_TargetProperty = property;

        if ( hadTarget != hasTarget )
        {
            if ( hasTarget )
            {
                GUIFramework.SFClipLoader.SignalFrameStarted.Connect( SlotFrameStarted, this );
            }
            else
            {
                GUIFramework.SFClipLoader.SignalFrameStarted.Disconnect( SlotFrameStarted, this );
            }
        }
    }

    private function SlotFrameStarted() : Void
    {
        m_TargetObj[m_TargetProperty] = GetCurrentValue();
    }

    private var m_StartValue;
    private var m_EndValue;
    private var m_StartTime:Number;
    private var m_EndTime:Number;
    private var m_EaseFunction:Function;
    
    private var m_TargetObj:Object;
    private var m_TargetProperty:String;
}