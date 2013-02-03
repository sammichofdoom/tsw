//Imports
import com.Components.WindowComponentContent;
import com.GameInterface.ProjectUtils;
import com.Utils.LDBFormat;
import gfx.controls.Button;

//Class
class GUI.LogoutWindow.LogoutWindowContent extends WindowComponentContent
{
    //Properties
    private var m_NumSeconds:Number;
    private var m_EndTimestamp:Number;
    private var m_CurrentTimestamp:Number;
    private var m_CurrentFrame:Number;
    private var m_SecondsTextField:TextField;
    private var m_AnimationBar:MovieClip;
    private var m_ExitButton:Button;
    private var m_CancelButton:Button;

    //Constructor
    public function LogoutWindowContent()
    {      
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        var currentDate:Date = new Date();
        
        m_EndTimestamp = Math.round(currentDate.getTime()) + 15000;
        m_CurrentTimestamp = Math.round(currentDate.getTime());
        
        m_NumSeconds = 0;
        m_CurrentFrame = 0;
        
        m_ExitButton.label = LDBFormat.LDBGetText("GenericGUI", "LogoutGUI_ExitNow");
        m_ExitButton.addEventListener("click", this, "SlotExit");
        
        m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
        m_CancelButton.addEventListener("click", this, "SlotCancel");
        
        UpdateCountdown();
        
        m_Date = new Date();
    }
    
    //On Enter Frame
    function onEnterFrame():Void
    {
        var currentDate:Date = new Date();
        
        m_CurrentTimestamp = Math.round(currentDate.getTime());
        
        var targetFrame:Number = Math.round((m_EndTimestamp - m_CurrentTimestamp) / 15000 * 100);
        
        if (targetFrame != m_CurrentFrame)
        {
            m_CurrentFrame = targetFrame;
            m_AnimationBar.gotoAndStop(targetFrame);
        }
        
        if (m_EndTimestamp - m_CurrentTimestamp <= 0)
        {
            onEnterFrame = null;
            
            ProjectUtils.CloseLogoutWindow();
            ProjectUtils.QuitGame();
        }
        
        UpdateCountdown();
    }

    //Slot Cancel
    private function SlotCancel():Void
    {
        ProjectUtils.CloseLogoutWindow();
        ProjectUtils.CancelLogout();
    }

    //Slot Exit
    private function SlotExit():Void
    {
        ProjectUtils.CloseLogoutWindow();
        ProjectUtils.QuitGame();
    }
    
    //Update Countdown
    private function UpdateCountdown():Void
    {
        var timeRemaining:Number = Math.round((m_EndTimestamp - m_CurrentTimestamp) / 1000);
        
        m_SecondsTextField.text = LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "LogoutGUI_Seconds"), timeRemaining);
    }
}