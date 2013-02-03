//Imports
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.ProjectFeatInterface;
import com.GameInterface.FeatInterface;
import com.GameInterface.ProjectUtils;
import com.Utils.LDBFormat;
import flash.geom.Rectangle;
import mx.transitions.easing.*;
import com.Components.Numbers;

//Class 
class GUI.SkillHive.CharacterSkillPointPanel extends MovieClip
{
    //Constants
    private var SCROLL_SPEED:Number = 1;
    
    //Properties
    private var m_Background:MovieClip;
	private var m_CharacterSkillPointButton:MovieClip;
    private var m_ButtonPulse:MovieClip;
    private var m_ButtonBackground:MovieClip;
    private var m_CharacterSkillsListBackground:MovieClip;
    private var m_CharacterSkillsList:MovieClip;
    private var m_CharacterSkillsSidePanel:MovieClip;
    private var m_Character:Character;
    private var m_ScrollBar:MovieClip;
    private var m_IsAnimating:Boolean;
    private var m_ScrollInterval:Number;
	private var m_SkillWheelLabel:String;
    private var m_CharacterSkillPointsLabel:String;
    private var m_NumbersBadgeAP:MovieClip;
    private var m_NumbersBadgeSP:MovieClip;
    
    //Constructor
    public function CharacterSkillPointPanel()
    {
        super();
        
        m_Character = Character.GetClientCharacter();
		m_Character.SignalTokenAmountChanged.Connect(SlotTokenChanged, this);
        FeatInterface.SignalFeatTrained.Connect(SlotFeatTrained, this);
        
        m_IsAnimating = false;
        m_ScrollInterval = 10;
        
        m_Character = Character.GetClientCharacter();

        m_CharacterSkillPointButton.m_NumbersBadgeSP.UseSingleDigits = true;
        m_CharacterSkillPointButton.m_NumbersBadgeSP.SetColor(0xFF0000);
        m_CharacterSkillPointButton.m_NumbersBadgeSP._visible = false;
        
        m_CharacterSkillPointButton.m_NumbersBadgeAP.UseSingleDigits = true;
        m_CharacterSkillPointButton.m_NumbersBadgeAP.SetColor(0xFF0000);
        m_CharacterSkillPointButton.m_NumbersBadgeAP._visible = false;
    
        Init();
		
		Mouse.addListener(this);
        
        m_Background.onPress = function()
        {
        }
    }
    
    //Init
    private function Init():Void
    {
        m_CharacterSkillsListBackground = attachMovie("CharacterSkillsListBackground", "m_CharacterSkillsListBackground", getNextHighestDepth());
        m_CharacterSkillsList = attachMovie("CharacterSkillsList", "m_CharacterSkillsList", getNextHighestDepth());
        m_CharacterSkillsSidePanel = attachMovie("CharacterSkillsSidePanel", "m_CharacterSkillsSidePanel", getNextHighestDepth());
        
        m_SkillWheelLabel = LDBFormat.LDBGetText("CharacterSkillsGUI", "SkillWheelLabel");
        m_CharacterSkillPointsLabel = LDBFormat.LDBGetText("CharacterSkillsGUI", "CharacterSkillPointsLabel");
    
        m_CharacterSkillPointButton.swapDepths(getNextHighestDepth());
        
        SetButtonText();
        UpdateSidePanelText();
        
        m_CharacterSkillsList.SignalStartAnimation.Connect(SlotStartAnimation, this);
        m_CharacterSkillsList.SignalStopAnimation.Connect(SlotStopAnimation, this);
		
        _global['setTimeout'](this, 'UpdateCharacterSkillPoints', 100);
		     
        CreateScrollBar();
    }
	
    //Update Character Skill Points
	private function UpdateCharacterSkillPoints():Void
	{
        var APAmount:Number = m_Character.GetTokens(1);
        var SPAmount:Number = m_Character.GetTokens(2);

        m_CharacterSkillPointButton.m_NumbersBadgeAP._visible = (APAmount > 0) ? true : false;
        m_CharacterSkillPointButton.m_NumbersBadgeAP.SetCharge(APAmount);
                
        m_CharacterSkillPointButton.m_NumbersBadgeSP._visible = (SPAmount > 0) ? true : false;
        m_CharacterSkillPointButton.m_NumbersBadgeSP.SetCharge(SPAmount);
        
        m_CharacterSkillsList.UpdateCharacterSkillPoints(SPAmount);
        
        UpdateSidePanelText();
	}
    
    //Animate Button Pulse
    public function AnimateButtonPulse(animate:Boolean):Void
    {
        m_CharacterSkillPointButton.m_ButtonPulse._visible = animate;
        
        if (animate)
        {
            m_CharacterSkillPointButton.m_ButtonPulse.play();
        }
        else
        {
            m_CharacterSkillPointButton.m_ButtonPulse.stop();
        }
    }
    
    //Create Scroll Bar
    private function CreateScrollBar():Void
    {
        m_ScrollBar = attachMovie("ScrollBar", "m_ScrollBar", getNextHighestDepth());
        m_ScrollBar._y = 0;
        m_ScrollBar._x = m_Background._width - m_ScrollBar._width;
        m_ScrollBar._height = m_Background._height - m_CharacterSkillPointButton._height / 2;;
        m_ScrollBar.setScrollProperties(1, 0, 0);
        m_ScrollBar.addEventListener("scroll", this, 'ScrollBarEventHandler');
        m_ScrollBar.position = 1;
        m_ScrollBar.trackMode = "scrollPage";
        m_ScrollBar.trackScrollPageSize = 4;
        m_ScrollBar.disableFocus = true;
    }
    
    //Scroll Bar Event Handler
    private function ScrollBarEventHandler(event:Object):Void
    {   
		///update the position of the abilities
		var pos:Number = event.target.position;
		m_CharacterSkillsList._y = -(pos * m_ScrollInterval);
		Selection.setFocus(null);
    }
    
    //Update Scroll Bar
    private function UpdateScrollBar():Void
    {
        var endScroll:Number = 0;
        var maxScroll:Number = 0;
        var listHeight:Number = m_CharacterSkillsList.GetBackgroundHeight() * m_CharacterSkillsList._yscale / 100;
        var backgroundHeight:Number = m_Background._height - m_CharacterSkillPointButton._height / 2;;
        
        if (listHeight > backgroundHeight)
        {
            endScroll = listHeight - backgroundHeight;
            maxScroll = Math.ceil(endScroll / m_ScrollInterval);
            m_ScrollBar._visible = true;
        }
        else
        {
            m_ScrollBar.position = 0;
            m_ScrollBar._visible = false;
            
            m_CharacterSkillsList.tweenTo(0.25, {_y: m_Background._height / 2 - m_CharacterSkillsList.GetBackgroundHeight() * m_CharacterSkillsList._yscale / 100 / 2}, Regular.easeOut);
        }
        
        m_ScrollBar.setScrollProperties(m_ScrollInterval, 0, maxScroll);
    }
    
    //On Enter Frame
    private function onEnterFrame():Void
    {
        if (!m_ScrollBar._visible && m_IsAnimating)
        {
            m_CharacterSkillsList._y = m_Background._height / 2 - m_CharacterSkillsList.GetBackgroundHeight() * m_CharacterSkillsList._yscale / 100 / 2;
        }
    }
    
    //Update Side Panel Text
    private function UpdateSidePanelText():Void
    {
        var skillPoints:Number = m_Character.GetTokens(2);
        var totalPointsSpent:Number = ProjectFeatInterface.GetSpentSkillPoints();
        
        m_CharacterSkillsSidePanel.SetText(skillPoints, totalPointsSpent);        
    }
    
    //Slot Feat Trained
    public function SlotFeatTrained():Void
    {
        UpdateSidePanelText();
    }
	
    //Slot Token Changed
	public function SlotTokenChanged(tokenID:Number, newAmount:Number, oldAmount:Number):Void
	{
        UpdateCharacterSkillPoints();
	}
    
    //Set Button Text
    public function SetButtonText():Void
	{
		m_CharacterSkillPointButton.m_UpperText.text = m_SkillWheelLabel; 
		m_CharacterSkillPointButton.m_LowerText.text = m_CharacterSkillPointsLabel;
	}
	
    //Set Size
    public function SetSize(width:Number, height:Number):Void
    {
        m_Background._width = width + 5;
        m_Background._height = height;
		
		m_CharacterSkillPointButton._y = height
		m_CharacterSkillPointButton._x = ((width - m_CharacterSkillPointButton._width) * 0.5) + 60; // the 60 is to align it with the skill wheel (3*30 on the right, 1* 30 on the left)
    
        var listXPosition:Number = width * 0.25;
        
        /*
         *  The smallest resolution (1024 x 768) clips the Character Skills Point Panel at the standard scale 
         *  of 60 percent.  Therefore, if the player's resolution is set at 1024 x 768 than the panel must
         *  scale down to 50 percent to avoid clipping.
         * 
         */
        
        var listScale:Number = (Stage["visibleRect"].width == 1024 && Stage["visibleRect"].height == 768) ? 50 : 60;
        
        m_CharacterSkillsListBackground._x = listXPosition;
        m_CharacterSkillsListBackground._y = 0;
        m_CharacterSkillsListBackground.m_Background._width = (width - listXPosition) * 100 / listScale;
        m_CharacterSkillsListBackground.m_Background._height = m_CharacterSkillsListBackground.m_VerticalLines._height = height * 100 / listScale;
        m_CharacterSkillsListBackground._xscale = m_CharacterSkillsListBackground._yscale = listScale;
        
        m_CharacterSkillsList._x = listXPosition;
        m_CharacterSkillsList._xscale = m_CharacterSkillsList._yscale = listScale;
        m_CharacterSkillsList._y = height / 2 - m_CharacterSkillsList.GetBackgroundHeight() * m_CharacterSkillsList._yscale / 100 / 2;
        
        m_ScrollBar._y = 20;
        m_ScrollBar._x = m_Background._width - m_ScrollBar._width - 12;
        m_ScrollBar._height = m_Background._height - m_CharacterSkillPointButton._height / 2 + 10;
        UpdateScrollBar();
        
        m_CharacterSkillsSidePanel._x = listXPosition;
        m_CharacterSkillsSidePanel.SetSize(listXPosition, height);
        m_CharacterSkillsSidePanel.SetTextScale(listScale);
        
        var mask:MovieClip = ProjectUtils.SetMovieClipMask(m_CharacterSkillsList, this, height, m_CharacterSkillsList._width, false);
        mask._x = m_CharacterSkillsList._x;
        mask._y = m_CharacterSkillsListBackground._y;
    }
    
    //Slot Start Functionn
    public function SlotStartAnimation():Void
    {
        m_IsAnimating = true;
    }
    
    //Slot Stop Function
    public function SlotStopAnimation():Void
    {
        m_IsAnimating = false;
        UpdateScrollBar();
    }
	
    //On Mouse Wheel
	function onMouseWheel(delta:Number)
	{
		if (m_ScrollBar._visible && !m_IsAnimating)
		{
			m_ScrollBar.position -= delta * SCROLL_SPEED;
		}
	}
}