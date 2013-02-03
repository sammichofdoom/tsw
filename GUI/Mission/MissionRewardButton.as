import gfx.core.UIComponent;
import gfx.controls.Button;
import com.GameInterface.Quests;
import com.Utils.LDBFormat;
import com.Utils.Signal;

class GUI.Mission.MissionRewardButton extends UIComponent
{
    private var m_ReportsButton:Button;
    public static var SignalReportSent:Signal
    
    
    public function MissionRewardButton()
    {
        super();
        SignalReportSent = new Signal();

    }
    
    private function configUI()
    {
        SignalReportSent.Connect( ReportSent, this);
        m_ReportsButton.addEventListener("click", this, "SendReport");
        SetText();
    }
    
    public function SetText()
    {
        var rewardQuests:Array = Quests.GetAllRewards();
        var numRewards:Number = rewardQuests.length;
        if (numRewards > 1)
        {
           m_ReportsButton.textField.htmlText = LDBFormat.LDBGetText("Quests", "Mission_SendReportPlural") + " ("+numRewards+")";
        }
        else
        {
           m_ReportsButton.textField.htmlText = LDBFormat.LDBGetText("Quests", "Mission_SendReport")
        }
        
    }
    
    public function Run()
    {
        this.gotoAndPlay(3);
    }
    
    public function Snap()
    {
        //this.gotoAndPlay(35);
        this.gotoAndStop("complete");
    }
    
    private function SendReport(event:Object)
    {
        var button:MovieClip = event.target;
        button.hitTestDisable = true;
        button.textField.text = LDBFormat.LDBGetText("Quests", "Mission_Sending")
        button.disableFocus = true;
        GUI.Mission.MissionSignals.SignalMissionReportSent.Emit();
        
        /*
        button.onEnterFrame = function()
        {
            trace("this._currentframe = "+this._currentframe)
            if (this._currentframe == 70)
            {
                GUI.Mission.MissionSignals.SignalMissionReportSent.Emit();
                this.onEnterFrame = null;
                trace("done and emitting")                
                
            }
        }
        */
    }
    
    private function ReportSent()
    {
        
    }
}