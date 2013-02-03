import com.Utils.Signal;
class GUI.Dialogue.DialogueEntry extends MovieClip
{
	private var m_Background:MovieClip;
	private var m_Icon:MovieClip;
	private var m_Text:TextField;
	
	private var m_IsPlaying:Boolean;
	private var m_IsExhausted:Boolean;
	private var m_Disabled:Boolean;
    
	private var m_ActiveIndex:Number
	private var m_TopicDepth:Number;
	
	private var m_Index:Number;
	
    private var m_TextContent:String;
	public var SignalClicked:Signal;
	
	private var m_VoiceHandle:Number;
	private var m_FirstQuestionId:Number;
	private var m_HasBeenPlayed:Boolean;
    
    private static var BUTTON_STATE_PLAYING:String = "playing";
    private static var BUTTON_STATE_DISABLED:String = "disabled";
    private static var BUTTON_STATE_NORMAL:String = "normal";
    private static var BUTTON_STATE_NORMAL_OVER:String = "normal_over";
    private static var BUTTON_STATE_EXHAUSTED:String = "exhausted";
    private static var BUTTON_STATE_EXHAUSTED_OVER:String = "exhausted_over";

    private var m_ButtonState:String;
	
	public function DialogueEntry()
	{
		m_Index = -1;
		m_IsPlaying = false;
        m_Disabled = false;
		m_IsExhausted = false;
		m_ActiveIndex = 0;
		m_TopicDepth = 0;
		
		SetExhausted(false);
		SignalClicked = new Signal;
	}
	
	public function SetExhausted(exhausted:Boolean)
	{
		m_IsExhausted = exhausted;
		//m_ButtonState = (exhausted ? BUTTON_STATE_EXHAUSTED : BUTTON_STATE_NORMAL);
        UpdateButtons()
	}
	
	public function IsExhausted()
	{
		return m_IsExhausted;
	}
	
	public function onRollOver()
	{
        m_ButtonState = (m_IsExhausted ? BUTTON_STATE_EXHAUSTED_OVER : BUTTON_STATE_NORMAL_OVER);
		if (!m_IsPlaying && !m_Disabled)
        {
            UpdateButtons();
        }
	}
	
	public function onRollOut()
	{
		m_ButtonState = (m_IsExhausted ? BUTTON_STATE_EXHAUSTED : BUTTON_STATE_NORMAL);
		if (!m_IsPlaying && !m_Disabled )
        {
            UpdateButtons();
        }
	}
	
	public function onRelease()
	{
        if (!m_IsPlaying && !m_Disabled)
        {
		    m_ActiveIndex++;
		    SignalClicked.Emit(m_Index, m_ActiveIndex);
            CheckExhausted();
        }
      //  m_ButtonState = (m_IsExhausted ? BUTTON_STATE_EXHAUSTED : BUTTON_STATE_NORMAL);
	//	UpdateButtons();
		
	}
	
	public function SetText(text:String)
	{
        m_TextContent = text;
		m_Text.text = m_TextContent;
	}
	
	public function SetIndex(index:Number)
	{
		m_Index = index;
	}
	
	public function SetIsPlaying(playing:Boolean)
	{
        m_IsPlaying = playing;
        m_ButtonState = (playing ? BUTTON_STATE_PLAYING : BUTTON_STATE_NORMAL);
		UpdateButtons();
	}
    
    public function SetDisabled(disabled:Boolean)
    {
        m_Disabled = disabled
        if (disabled)
        {
            m_ButtonState = BUTTON_STATE_DISABLED;
        }
        else
        {
            m_ButtonState = ( m_IsExhausted ? BUTTON_STATE_EXHAUSTED : BUTTON_STATE_NORMAL );
        }
        UpdateButtons();
    }
	
	public function UpdateButtons()
	{
        gotoAndPlay(m_ButtonState);
        m_Text.text = m_TextContent;   
	}
	
	public function SetVoiceHandle(voiceHandle:Number)
	{
		m_VoiceHandle = voiceHandle;
	}
	
	public function GetVoiceHandle()
	{
		return m_VoiceHandle
	}
	
	public function SetDepth(depth:Number)
	{
		m_TopicDepth = depth;
	}
	
	
	public function CheckExhausted()
	{
		if (m_ActiveIndex >= m_TopicDepth)
		{
			SetExhausted(true);
			m_ActiveIndex = 0;
		}
	}
}