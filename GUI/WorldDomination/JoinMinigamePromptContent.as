//Imports
import com.Utils.LDBFormat;
import com.Components.WindowComponentContent;
import GUI.WorldDomination.UniformTypes;
import com.GameInterface.PvPMinigame.PvPMinigame;
import flash.geom.Point;

//Class
class GUI.WorldDomination.JoinMinigamePromptContent extends WindowComponentContent
{
    //Constants
    private static var TEAM_MESSAGE:String = LDBFormat.LDBGetText("WorldDominationGUI", "JoinPvPMiniGamePromptTeamMessage");
    private static var MESSAGE:String = LDBFormat.LDBGetText("WorldDominationGUI", "JoinPvPMiniGamePromptMessage");
    private static var SELECTED_UNIFORM:String = LDBFormat.LDBGetText("WorldDominationGUI", "JoinPvPMiniGamePromptSelectedUniform");
    private static var DECLINE:String = LDBFormat.LDBGetText("WorldDominationGUI", "JoinPvPMiniGamePromptDecline");
    private static var JOIN:String = LDBFormat.LDBGetText("WorldDominationGUI", "JoinPvPMiniGamePromptJoin");
    
    //Properties
    private var m_SelectedUniform:Number;
    private var m_MessageTextField:TextField;
    private var m_TimerTextField:TextField;
    private var m_Separator:MovieClip;
    private var m_UniformTypes:MovieClip;
    private var m_DeclineButton:MovieClip;
    private var m_JoinButton:MovieClip;
    private var m_CountdownInterval:Number;
    private var m_CountdownTimer:Number;
    
    //Constructor
    public function JoinMinigamePromptContent()
    {
        super();
        
        m_MessageTextField.autoSize = "center";
        m_CountdownTimer = PvPMinigame.m_TimeToJoinGame;
        m_SelectedUniform = PvPMinigame.m_SelectedRole;
    }
 
    //Selected Uniform Is Valid
    private function SelectedUniformIsValid(selectedUniform:Number):Boolean
    {
        switch (selectedUniform)
        {
            case _global.Enums.Class.e_Damage:
            case _global.Enums.Class.e_Tank:
            case _global.Enums.Class.e_Heal:    return true;
        }
        
        return false;
    }
    
    //On Load
    private function onLoad():Void
    {
        var playfieldName:String = PvPMinigame.m_GamePlayFieldName;
        
        if (!SelectedUniformIsValid(m_SelectedUniform))
        {
            m_MessageTextField.text = LDBFormat.Printf(TEAM_MESSAGE, playfieldName); 
        }
        else
        {
            m_MessageTextField.text = LDBFormat.Printf(MESSAGE, playfieldName) + "\n\n" + SELECTED_UNIFORM + "\n" + GetUniformName(m_SelectedUniform);
        }
        
        m_TimerTextField._y = m_MessageTextField._y + m_MessageTextField._height + 12;
        
        var lastDisplayObject:Object = m_TimerTextField;
        
        if (!SelectedUniformIsValid(m_SelectedUniform))
        {
            m_Separator = attachMovie("Separator", "m_Separator", getNextHighestDepth());
            m_Separator._y = m_TimerTextField._y + m_TimerTextField._height + 12;
            
            m_UniformTypes = attachMovie("UniformTypes", "m_UniformTypes", getNextHighestDepth());
            m_UniformTypes._y = m_Separator._y + m_Separator._height + 8;
            m_UniformTypes.mode = UniformTypes.FVF_MODE;
            m_UniformTypes.SetValidRadioButtonUniforms(m_SelectedUniform);
            
            lastDisplayObject = m_UniformTypes;
        }
        
        m_DeclineButton = attachMovie("ChromeButtonWhite", "m_DeclineButton", getNextHighestDepth());
        m_DeclineButton._x = 1.5;
        m_DeclineButton._y = lastDisplayObject._y + lastDisplayObject._height + 25;
        m_DeclineButton.label = DECLINE;
        m_DeclineButton.addEventListener("click", this, "DeclineEventHandler");
        
        m_JoinButton = attachMovie("ChromeButtonWhite", "m_JoinButton", getNextHighestDepth());
        m_JoinButton._x = 172;
        m_JoinButton._y = lastDisplayObject._y + lastDisplayObject._height + 25;
        m_JoinButton.label = JOIN;
        m_JoinButton.addEventListener("click", this, "JoinEventHandler");

        _parent.Layout();
        Position();
        
        m_TimerTextField.text = "00:" + m_CountdownTimer;
        m_CountdownInterval = setInterval(Countdown, 1000, this);
    }
    
    //Countdown
    private function Countdown(scope:Object):Void
    {
        scope.m_CountdownTimer--

        scope.m_TimerTextField.text = (scope.m_CountdownTimer < 10) ? "00:0" + scope.m_CountdownTimer : "00:" + scope.m_CountdownTimer;
        
        if (scope.m_CountdownTimer <= 0)
        {
            clearInterval(scope.m_CountdownInterval);
            scope.DeclineEventHandler();
        }
    }
    
    //Get Uniform Name
    public function GetUniformName(uniformID:Number):String
    {
        switch (uniformID)
        {
            case _global.Enums.Class.e_Damage:  return UniformTypes.HIGH_POWERED_WEAPONRY;
            case _global.Enums.Class.e_Tank:    return UniformTypes.REINFORCED_ARMOR;
            case _global.Enums.Class.e_Heal:    return UniformTypes.INTEGRATED_ANIMA_CONDUITS;
        }
    }
    
    //Position
    private function Position():Void
    {
        var visibleRect = Stage["visibleRect"];

        _parent._x = (visibleRect.width / 2) - (_parent._width / 2);
        _parent._y = (visibleRect.height / 2) - (_parent._height / 2);
    }
    
    //Get New Uniform Selection
    private function GetNewUniformSelection():Number
    {
        var selection:Number;
        
        if      (m_UniformTypes.m_HighPoweredWeaponryRadioButton.selected)      selection = _global.Enums.Class.e_Damage;
        else if (m_UniformTypes.m_ReinforcedArmorRadioButton.selected)          selection = _global.Enums.Class.e_Tank;
        else                                                                    selection = _global.Enums.Class.e_Heal;
        
        return selection;
    }
    
    //Decline Event Handler
    private function DeclineEventHandler():Void
    {
        Selection.setFocus(null);
        clearInterval(m_CountdownInterval);
        
        PvPMinigame.DeclineJoinGame();
    }
    
    //Join Event Handler
    private function JoinEventHandler():Void
    {
        Selection.setFocus(null);
        clearInterval(m_CountdownInterval);
        
        var selectedUniform:Number = (SelectedUniformIsValid(m_SelectedUniform)) ? m_SelectedUniform : GetNewUniformSelection();
        PvPMinigame.JoinGame(selectedUniform); 
    }
}