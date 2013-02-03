//Imports
import com.Utils.LDBFormat;
import GUI.PvPScoreboard.AnimaFragment;
import com.GameInterface.Game.Character;
import com.Utils.Signal;
import GUI.PvPScoreboard.Table;
import com.GameInterface.PvPMinigame.PvPMinigame;
import com.GameInterface.PvPScoreboard;
import com.GameInterface.DistributedValue;

//Class
class GUI.PvPScoreboard.Footer extends MovieClip
{
    //Constants
    private static var SORT_BY:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_sortBy");
    private static var FACTION:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_faction");
    private static var ALL:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_all");
    private static var REWARDS:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_rewards");
    private static var CLOSE:String = LDBFormat.LDBGetText("WorldDominationGUI", "Scoreboard_close");
    private static var EL_DORADO:String = LDBFormat.LDBGetText("WorldDominationGUI", "elDorado");
    private static var STONEHENGE:String = LDBFormat.LDBGetText("WorldDominationGUI", "stonehenge");
    
    private static var DEFAULT_GAP:Number = 12;
    private static var DEFAULT_RADIO_BUTTON_WIDTH:Number = 37;
    private static var SORT_RADIO_GROUP:String = "sortRadioGroup";
    
    private static var EL_DORADO_ID:Number = 5820;
    private static var STONEHENGE_ID:Number = 5840;
    
    //Properties
    public var SignalSortTypeSelected:Signal;
    public var SignalCloseWindow:Signal;
    
    private var m_Character:Character;
    
    private var m_Background:MovieClip;
    private var m_SortByTextField:TextField;
    private var m_FactionRadioButton:MovieClip;
    private var m_AllRadioButton:MovieClip;
    
    private var m_RewardsTextField:TextField;
    private var m_MajorAnimaFragment:MovieClip;
    private var m_MinorAnimaFragment:MovieClip;

    private var m_CloseButton:MovieClip;
    
    private var m_CheckInterval:Number;
    
    //Constructor
    public function Footer()
    {
        super();
        
        SignalSortTypeSelected = new Signal;
        SignalCloseWindow = new Signal;
        
        m_Character = Character.GetClientCharacter();
        
        Init();
    }
    
    //On Load
    private function Init():Void
    {
        m_SortByTextField.autoSize = "left";
        m_SortByTextField.text = SORT_BY;
        
        m_FactionRadioButton = m_Background.attachMovie("RadioButton", "m_FactionRadioButton", m_Background.getNextHighestDepth());
        m_FactionRadioButton.group = SORT_RADIO_GROUP;
        m_FactionRadioButton.textField.autoSize = "left";
        m_FactionRadioButton.label = FACTION;
        m_FactionRadioButton.selected = true;
        m_FactionRadioButton.addEventListener("click", this, "RadioButtonClickHandler");
        
        m_AllRadioButton = m_Background.attachMovie("RadioButton", "m_AllRadioButton", m_Background.getNextHighestDepth());
        m_AllRadioButton.group = SORT_RADIO_GROUP;
        m_AllRadioButton.textField.autoSize = "left";
        m_AllRadioButton.label = ALL;
        m_AllRadioButton.addEventListener("click", this, "RadioButtonClickHandler");

        m_CloseButton = attachMovie("ChromeButtonWhite", "m_CloseButton", m_Background.getNextHighestDepth());
        m_CloseButton.textField.autoSize = "center";
        m_CloseButton.label = CLOSE;
        m_CloseButton.addEventListener("click", this, "CloseButtonClickHandler");

        var controlsArray = new Array(m_FactionRadioButton, m_AllRadioButton, m_CloseButton);
                                                
        for (var i:Number = 0; i < controlsArray.length; i++)
        {
            controlsArray[i].addEventListener("click", this, "RemoveFocusEventHandler");
        }
        
        m_CheckInterval = setInterval(InitComponents, 20, this);
    }

    //Remove Focus Event Handler
    private function RemoveFocusEventHandler():Void
    {
        Selection.setFocus(null);
    }
    
    //Initialize Components
    private function InitComponents(scope:Object):Void
    {
        if (scope.m_FactionRadioButton._width != DEFAULT_RADIO_BUTTON_WIDTH)
        {
            clearInterval(scope.m_CheckInterval);
            scope.Layout();
        }
    }
    
    //Layout
    private function Layout():Void
    {
        m_FactionRadioButton._x = m_SortByTextField._x + m_SortByTextField._width + DEFAULT_GAP;
        m_AllRadioButton._x = m_FactionRadioButton._x + m_FactionRadioButton._width + DEFAULT_GAP;
        m_FactionRadioButton._y = m_AllRadioButton._y = m_Background._height / 2 - m_FactionRadioButton._height / 2 + 1;
        
        m_CloseButton._x = m_Background._x + m_Background._width - m_CloseButton._width;;
        m_CloseButton._y = 19;
    }
    
    //Close Button Click Handler
    private function CloseButtonClickHandler():Void
    {
        DistributedValue.SetDValue("pvp_scoreboard", false);
    }
    
    //Get Characters Role
    private function GetCharactersRole():Number
    {
        for (var i:Number = 0; i < PvPScoreboard.m_Players.length; i++)
        {
            if (PvPScoreboard.m_Players[i].m_Name == m_Character.GetName())
            {
                return PvPScoreboard.m_Players[i].m_Role;
            }
        }
    }
    
    //Radio Button Click Handler
    private function RadioButtonClickHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_FactionRadioButton:      SignalSortTypeSelected.Emit(Table.SORT_TYPE_FACTION);
                                            break;
                                            
            case m_AllRadioButton:          SignalSortTypeSelected.Emit(Table.SORT_TYPE_ALL);
        }
    }
    
    //Set Rewards
    public function SetRewards(majorAnimaAmount:Number, minorAnimaAmount:Number):Void
    {
        if (majorAnimaAmount != 0 || minorAnimaAmount != 0)
        {
            m_RewardsTextField.autoSize = "left";
            m_RewardsTextField.text = REWARDS;
        }
        
        if (majorAnimaAmount != 0)
        {
            m_MajorAnimaFragment = attachMovie("AnimaFragment", "m_MajorAnimaFragment", getNextHighestDepth());
            m_MajorAnimaFragment.SetReward(AnimaFragment.MAJOR_ANIMA_FRAGMENT, majorAnimaAmount);
            m_MajorAnimaFragment._x = m_RewardsTextField._x + m_RewardsTextField._width + DEFAULT_GAP;
            m_MajorAnimaFragment._y = m_RewardsTextField._y - 2;
        }
        
        if (minorAnimaAmount != 0)
        {
            m_MinorAnimaFragment = attachMovie("AnimaFragment", "m_MinorAnimaFragment", getNextHighestDepth());
            m_MinorAnimaFragment.SetReward(AnimaFragment.MINOR_ANIMA_FRAGMENT, minorAnimaAmount);
            
            if (majorAnimaAmount)
            {
                m_MinorAnimaFragment._x = m_MajorAnimaFragment._x + m_MajorAnimaFragment._width + DEFAULT_GAP - 4;
            }
            else
            {
                m_MinorAnimaFragment._x = m_RewardsTextField._x + m_RewardsTextField._width + DEFAULT_GAP;
            }
            
            m_MinorAnimaFragment._y = m_RewardsTextField._y - 2;
        }
    }
}