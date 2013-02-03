import mx.utils.Delegate;

import gfx.core.UIComponent;
import mx.transitions.easing.*;
import com.Utils.LDBFormat;
import com.Utils.Signal;

import gfx.controls.ButtonGroup;
import gfx.controls.Slider;
import gfx.controls.Label;
import gfx.controls.TextArea;

import GUI.CharacterCreation.CameraController;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.*;

dynamic class GUI.CharacterCreation.CharacterEditor extends UIComponent
{
    public var SignalBack:com.Utils.Signal;
    public var SignalForward:com.Utils.Signal;
    
    private var m_CameraController:CameraController;
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
	
	private var m_Title:Label;
    private var m_GenderSelector:MovieClip;
	private var m_HeadSection:MovieClip;
	private var m_OutfitSection:MovieClip;
    private var m_CharacterSizeSliderLabel:MovieClip;
    private var m_CharacterSizeSlider:Slider;
    private var m_NavigationBar:MovieClip;
	private var m_BackButton:MovieClip;
	private var m_ForwardButton:MovieClip;
    private var m_HelpIcon:MovieClip;

	private var m_NameInputDefaultText:String;
    private var m_LastClickedPanel:MovieClip;
    private var m_LastCameraFocusPanel:MovieClip;
    
    public function CharacterEditor()
    {
        SignalBack = new com.Utils.Signal;
        SignalForward = new com.Utils.Signal;
		
		m_HeadSection.m_CameraController = m_CameraController;
		m_OutfitSection.m_CharacterCreationIF = m_CharacterCreationIF;		
    }
	
	 private function configUI()
    {
		m_HeadSection.SetCharacterCreationIF( m_CharacterCreationIF );
		
		//set default gender to female
        m_CharacterCreationIF.SignalGenderChanged.Connect( SlotGenderChanged, this );
        SlotGenderChanged( m_CharacterCreationIF.GetGender() );
		
		var characterButtonGroup:ButtonGroup = new ButtonGroup("characterButtons");
		
		m_BackButton.m_BackwardArrow._alpha = 100;
		m_ForwardButton.m_ForwardArrow._alpha = 100;
		
		m_GenderSelector.m_ButtonGenderMale.toggle = true;
		m_GenderSelector.m_ButtonGenderFemale.toggle = true;
      	
		var genderButtonGroup:ButtonGroup = new ButtonGroup("genderButtons");
		m_GenderSelector.m_ButtonGenderMale.group = genderButtonGroup;
		m_GenderSelector.m_ButtonGenderFemale.group = genderButtonGroup;
		
		m_GenderSelector.m_ButtonGenderMale.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "Tooltip_Male" ));
		m_GenderSelector.m_ButtonGenderFemale.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "Tooltip_Female" ));
		
		m_GenderSelector.m_ButtonGenderMale.addEventListener("click", this, "ClickedMale");
		m_GenderSelector.m_ButtonGenderFemale.addEventListener("click", this, "ClickedFemale");
		
		m_BackButton.SignalButtonSelected.Connect(BackToFactionSelection, this);
		m_ForwardButton.SignalButtonSelected.Connect(GoForward, this);
        
        m_CharacterSizeSlider.minimum = m_CharacterCreationIF.GetCharacterMinScale();
        m_CharacterSizeSlider.maximum = m_CharacterCreationIF.GetCharacterMaxScale();
        m_CharacterSizeSlider.liveDragging = true;
        m_CharacterSizeSlider.addEventListener( "change", this, "OnCharacterSizeSliderChanged" );
        
        m_CharacterCreationIF.SignalCharacterScaleChanged.Connect( SlotCharacterScaleChanged, this );
        SlotCharacterScaleChanged( m_CharacterCreationIF.GetCharacterScale() );
		
        m_HeadSection.SignalCameraFocusChanged.Connect( SlotOutfitCameraFocusChanged, this );
        m_OutfitSection.SignalCameraFocusChanged.Connect( SlotOutfitCameraFocusChanged, this );
		
		SetLabels();
		LayoutHandler();
    }
	
	private function SetLabels()
	{		
		m_BackButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "ReselectFaction" );
        m_CharacterSizeSliderLabel.text = LDBFormat.LDBGetText( "CharCreationGUI", "CharacterSizeLabel" );
        
        TooltipUtils.AddTextTooltip( m_HelpIcon, LDBFormat.LDBGetText( "CharCreationGUI", "MouseNavigationInfo" ), 250, TooltipInterface.e_OrientationHorizontal,  true, false); 
        
		m_ForwardButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "CreateName" );
		m_Title.htmlText = LDBFormat.LDBGetText( "CharCreationGUI", "MainTitle" );
	}
	
	private function CenterHorizontal(component:MovieClip)
	{
		component._x = (Stage.width/2) - (component._width/2)
	}
	
	public function LayoutHandler()
	{
		m_GenderSelector._x = 5;
		m_GenderSelector._y = 5;
		
		CenterHorizontal(m_Title);
		m_Title._y = 20;
		
		m_HeadSection._y = (Stage.height / 2) - 50;
		m_HeadSection._x =  Stage.width/2 - Stage.width/4  - m_HeadSection._width/2 - 100;
		
		m_OutfitSection._y = m_HeadSection._y;
		m_OutfitSection._x = Stage.width/2 + Stage.width/4  - m_OutfitSection._width/2 + 100;
		
		m_NavigationBar._width = Stage.width + 2;
		CenterHorizontal(m_NavigationBar);
		m_NavigationBar._y = Stage.height - m_NavigationBar._height;
		
		CenterHorizontal(m_CharacterSizeSlider);
		m_CharacterSizeSlider._y = m_NavigationBar._y - m_CharacterSizeSlider._height - 10;
		m_CharacterSizeSliderLabel._y = m_CharacterSizeSlider._y - 3;// - m_CharacterSizeSliderLabel._height - 5;
        m_CharacterSizeSliderLabel._x = m_CharacterSizeSlider._x - m_CharacterSizeSliderLabel._width -7;

        m_HelpIcon._x = Stage.width - m_HelpIcon._width - 20;
        m_HelpIcon._y = 20;
        
		m_BackButton._x = 10;
		m_BackButton._y = Stage.height - (m_NavigationBar._height / 2) - (m_BackButton._height / 2) + 5;
		m_ForwardButton._y = m_BackButton._y;
		m_ForwardButton._x = Stage.width - m_ForwardButton._width - 10;
		
		if ( m_OutfitSection.m_SectionExtended )
		{
			m_OutfitSection.ExtendOutfitSection();
		}
		
		if ( m_HeadSection.m_SectionExtended )
		{
			m_HeadSection.ExtendHeadSection();
		}
	}
	
    private function SlotGenderChanged( gender:Number )
    {
        if ( gender == _global.Enums.BreedSex.e_Sex_Male )
        {
            m_GenderSelector.m_ButtonGenderMale.selected = true;
        }
        else
        { 
            m_GenderSelector.m_ButtonGenderFemale.selected = true;
        }        
        m_CameraController.SetLockPosUpdate(false);
    }
    
	private function BackToFactionSelection()
	{
		this.SignalBack.Emit();
	}
	
	private function GoForward()
	{
		m_CameraController.SetZoomMode( CameraController.e_ModeBody, 1 );
		SignalForward.Emit();
	}
	
	private function ClickedMale()
	{
        m_CharacterCreationIF.SetGender( _global.Enums.BreedSex.e_Sex_Male );
        m_CameraController.SetLockPosUpdate(true);
	}
	
	private function ClickedFemale()
	{
        m_CharacterCreationIF.SetGender( _global.Enums.BreedSex.e_Sex_Female );
        m_CameraController.SetLockPosUpdate(true);
	}
    
    private function OnCharacterSizeSliderChanged()
    {
        m_CharacterCreationIF.SetCharacterScale( m_CharacterSizeSlider.value );
	}
    
    private function DumpObjectMembers( value ) : String
    {
        if ( value == undefined )
        {
            return "undefined";
        }
        var type = typeof value;
        if ( type == "string" || type == "number"  || type == "boolean" || type == "function" )
        {
            return value.toString();
        }
        else
        {
            var result:String = "";
            for ( i in value )
            {
                result += ( result.length == 0 ) ? "{" : ", ";
                result += i + ":" + value[i].toString();
            }
            result += "}";
            return result;
        }
    }

    public function onMouseDown()
    {
        if ( m_HeadSection.hitTest( _root._xmouse, _root._ymouse ) )
        {
            m_LastClickedPanel = m_HeadSection;
        }
        else if ( m_OutfitSection.hitTest( _root._xmouse, _root._ymouse ) )
        {
            m_LastClickedPanel = m_OutfitSection;
        }
    }
    
    public function onMouseUp()
    {
        if ( m_LastClickedPanel == m_HeadSection && m_LastCameraFocusPanel != m_HeadSection && m_HeadSection.hitTest( _root._xmouse, _root._ymouse ) )
        {
            m_LastCameraFocusPanel = m_HeadSection;
            m_CameraController.SetZoomMode( m_HeadSection.GetCurrentCameraFocus(), 2 );
        }
        else if ( m_LastClickedPanel == m_OutfitSection && m_LastCameraFocusPanel != m_OutfitSection && m_OutfitSection.hitTest( _root._xmouse, _root._ymouse ) )
        {
            m_LastCameraFocusPanel = m_OutfitSection;
            m_CameraController.SetZoomMode( m_OutfitSection.GetCurrentCameraFocus(), 1 );
        }
    }

    public function SlotOutfitCameraFocusChanged( mode:Number )
    {
        m_CameraController.SetZoomMode( mode, 1 );
    }
    
    private function SlotCharacterScaleChanged( value:Number )
    {
        m_CharacterSizeSlider.value = value;
    }    
}