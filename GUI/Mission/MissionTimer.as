import com.Utils.Colors;
import mx.controls.gridclasses.DataGridColumn;
import mx.utils.Delegate;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import com.GameInterface.Utils
import com.Utils.Destructor;
import com.GameInterface.Log;

class GUI.Mission.MissionTimer extends MovieClip
{
    private var m_UpdateSpeed:Number = 500;
    private var m_IntervalId:Number = undefined;
    private var m_ThrottleCounter:Number = 0; /// controller used to set alpha when operating on slow updates and low numbers (seconds, not ms)
    private var m_EndTime:Number;
    private var textField:TextField;
    private var i_Back:MovieClip;
    private var m_MinWidth:Number = 100 /// the minimum witdth of the textField;
    private var m_IsColorized:Boolean = false;
    private var m_StartThrottleAt:Number = 20000 /// when to start flashing the number
    private var m_ChriticalWarningAt:Number = 10000 /// when to flash red critically
    private var m_Destructor:Destructor;
    private var m_IsSuccessOnCompletion:Boolean = true;
    private var m_TimeoutColor:Number;
    
    public function MissionTimer()
    {
        super.init();
        m_Destructor = new Destructor();
        m_Destructor.SignalDying.Connect( GUI.Mission.MissionTimer.SlotInstanceDying );
        textField.autoSize = "center"
        m_TimeoutColor = Colors.e_ColorTimeoutSuccess;
    }
    
    /**
     * sets the timer and starts it
     * 
     * @param	timestamp:Numbing       the gametime when the timer completes
     * @param	firstWarning:Number     MS before end where the thing should start flashing
     * @param	criticalWarning:Number  MS before end where the timer changes color
     */
    public function SetTimer(timestamp:Number, firstWarning:Number, criticalWarning:Number)
    {
        Log.Info2("MissionTimer", "SetTimer(" + timestamp+", "+firstWarning+", "+criticalWarning+")");
        m_EndTime = timestamp;
        m_StartThrottleAt = (firstWarning ? firstWarning : m_StartThrottleAt);
        m_ChriticalWarningAt = (criticalWarning ? criticalWarning : m_ChriticalWarningAt);
        
        if ( m_IntervalId != undefined )
        {
            clearInterval( m_IntervalId );
        }
        m_IntervalId = setInterval( Delegate.create(this, TimerCallback), m_UpdateSpeed, this );
        m_Destructor.Set( new Object( { id:m_IntervalId } ));
    }
    
    /**
     * sets a flag defining if the completed timer will result in success or fail (this will be used to determine) if the flashing missions at the end will flash green or red
     * 
     * @param	isSuccessOnCompletion:Boolean
     */
    public function SetSuccessType(isSuccessOnCompletion:Boolean) : Void
    {
        m_IsSuccessOnCompletion = isSuccessOnCompletion;
        m_TimeoutColor = ( m_IsSuccessOnCompletion ? Colors.e_ColorTimeoutSuccess : Colors.e_ColorTimeoutFail);
    }
    
    private function UpdateBorder()
    {
        var width:Number = textField._width;
        i_Back._xscale = (width > m_MinWidth) ? width : 100
    }
    
    // Decrease timer until zero.
    function TimerCallback()
    {
        m_ThrottleCounter++;
        var time = Utils.GetServerSyncedTime();
        var timeLeft = (m_EndTime - time) * 1000;
        if( timeLeft > 0 )
        {
            if( timeLeft > 60*60*1000 )
            {
                // Show "hour:min" if more than 1 hour left.
                timeLeft = timeLeft/60;
            }
  
            // Add blinking as first warning
            if( timeLeft <= m_StartThrottleAt && timeLeft > 0 )
            {
                i_Back._alpha = ((m_ThrottleCounter % 2) * 70) + 30;
                
                // colorize when time is critical
                if (timeLeft <= m_ChriticalWarningAt && !m_IsColorized)
                {
                    Colors.ApplyColor(i_Back.i_TintLayer, m_TimeoutColor)
                    i_Back.i_TintLayer._alpha = 60;
                    m_IsColorized = true;
                }
            }
            
            var str:String = com.Utils.Format.Printf( "%02.0f:%02.0f", Math.floor(timeLeft / 60000), Math.floor(timeLeft / 1000) % 60 );
            
            textField.text = str;

            UpdateBorder()
        }
        else
        {
            clearInterval( m_IntervalId );
            m_IntervalId = undefined;
            m_Destructor.Set(  null );
        }
    }
    
    public static function SlotInstanceDying(obj:Object)
    {
        if (obj != null)
        {
            clearInterval(  obj.id );
        }
    }
}