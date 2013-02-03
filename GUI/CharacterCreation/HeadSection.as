import com.Utils.Format;
import gfx.core.UIComponent;
import gfx.controls.Button;
import com.Components.FCButton;
import GUI.CharacterCreation.CameraController;
import mx.events.EventDispatcher;
import mx.transitions.easing.*;
import GUI.CharacterCreation.HeadSectionHairMakeup;
import GUI.CharacterCreation.HeadSectionFacialTraits;

import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.Utils.Signal;

import com.GameInterface.Game.Character;

    
dynamic class GUI.CharacterCreation.HeadSection extends UIComponent
{   
    public var m_CameraController:CameraController;
    
    private var m_CloseSectionButton:Button;
    private var m_HeadSectionIcon:MovieClip;
    private var m_RandomizeHeadButton:FCButton;
    private var m_SectionBox:MovieClip;
    private var m_TitleHeadSection:MovieClip;
    private var m_TitleDescription:MovieClip;
    private var m_Content:MovieClip;
    private var m_ClickAreaCollapsed:MovieClip;
    
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
    private var m_IsUILoaded:Boolean = false;
    private var m_IsInitialized:Boolean = false;
    
    private var m_SectionBoxWidth:Number;
    private var m_SectionBoxWidthCollapsed:Number;
    private var m_SectionBoxHeightCollapsed:Number;
    private var m_ContentMargin:Number;
    private var m_SectionOriginalY:Number;
    private var m_BoxHeight:Number;
    public var m_SectionExtended:Boolean;
    private var m_FacialTraitsPanel:HeadSectionFacialTraits;
    private var m_HairMakeupPanel:HeadSectionHairMakeup;
    
    private static var PANEL_FACIAL = 0;
    private static var PANEL_MAKEUP = 1;
    
    private var m_CurrentPanel:Number = -1;

    public var SignalCameraFocusChanged:Signal;
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function HeadSection()
    {
        SignalCameraFocusChanged = new Signal();
        m_SectionOriginalY = (Stage.height / 2) - 50;
        m_ContentMargin = 4;
        m_SectionBoxWidth = 296;
        m_SectionBoxHeightCollapsed = 50;
        
        m_SectionBox.onRelease = function() { };
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function Initialize()
    {
        if ( m_IsInitialized || m_CharacterCreationIF == undefined || !m_IsUILoaded )
        {
            return;
        }
        m_IsInitialized = true;
        
        LoadPanels();
        
        m_FacialTraitsPanel.SetCharacterCreationIF(m_CharacterCreationIF);
        m_HairMakeupPanel.SetCharacterCreationIF(m_CharacterCreationIF);
        
        m_FacialTraitsPanel.onTweenComplete = function() { _visible = _alpha != 0; }
        m_HairMakeupPanel.onTweenComplete = function() { _visible = _alpha != 0; }
        
        m_RandomizeHeadButton.addEventListener("click", this, "RandomizeHead")
        
        m_Content.m_SectionDropdown.dataProvider = [ LDBFormat.LDBGetText( "CharCreationGUI", "FacialTraits" ), LDBFormat.LDBGetText( "CharCreationGUI", "HairMakeUp" )];
        m_Content.m_SectionDropdown.addEventListener("change", this, "SelectPanel");
        
        m_Content.m_RandomizeActiveSubSectionButton._visible = false;
        m_Content.m_RandomizeActiveSubSectionButton.addEventListener("click", this, "RandomizeActiveSubSection");
        
        m_Content.m_HeadSectionViewer.autoSize = true;

        SetPanel( PANEL_FACIAL );
        
        m_TitleHeadSection.text = LDBFormat.LDBGetText("CharCreationGUI", "TitleHeadSection");
        m_TitleDescription.text = LDBFormat.LDBGetText("CharCreationGUI", "TitleHeadSectionDescription");
        
        CollapseHeadSection();
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function LoadPanels()
    {
        m_FacialTraitsPanel = m_Content.m_FacialTraitsPanelLoader.attachMovie( "FacialTraitsPanel", "facialTraitsPanel", m_Content.m_FacialTraitsPanelLoader.getNextHighestDepth() );
        m_HairMakeupPanel = m_Content.m_HairMakeupPanelLoader.attachMovie( "HairMakeupPanel", "hairMakeupPanel", m_Content.m_HairMakeupPanelLoader.getNextHighestDepth() );
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function configUI()
    {
        m_IsUILoaded = true;
        
        Initialize();
        m_RandomizeHeadButton.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "Tooltip_RandomizeHead" ));
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function GetCurrentCameraFocus() : Number
    {
        if ( m_SectionExtended )
        {
            return CameraController.e_ModeFace;
        }
        else
        {
            return CameraController.e_ModeBody
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function RandomizeActiveSubSection()
    {
        //randomize stuff in currently view
        if ( m_CurrentPanel == PANEL_FACIAL )
        {
            m_FacialTraitsPanel.RandomizePanel();
        }
        else
        {
            m_HairMakeupPanel.RandomizePanel();
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SetPanel( panel:Number)
    {
        m_FacialTraitsPanel._visible = true;
        m_HairMakeupPanel._visible = true;
        
        
        if ( panel == PANEL_FACIAL )
        {
            m_FacialTraitsPanel.tweenTo( 1, { _alpha: 100 }, Strong.easeOut );
            m_HairMakeupPanel.tweenTo( 0.1, { _alpha: 0 }, NONE.easeInOut );
            UpdateBoxHeight( m_FacialTraitsPanel._height + 80 );
            m_HairMakeupPanel.SignalBoxHeightChanged.Disconnect(UpdateBoxHeight, this);
        }
        else
        {
            m_FacialTraitsPanel.tweenTo( 0.1, { _alpha: 0 }, NONE.easeInOut );
            m_HairMakeupPanel.tweenTo( 1, { _alpha: 100 }, Strong.easeOut );
            UpdateBoxHeight( m_HairMakeupPanel.m_BoxHeight );
            m_HairMakeupPanel.SignalBoxHeightChanged.Connect(UpdateBoxHeight, this);
        }
        m_CurrentPanel = panel;
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SelectPanel(e:Object)
    {
        
        SetPanel( e.target.selectedIndex );
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SetCharacterCreationIF( characterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation )
    {
        m_CharacterCreationIF = characterCreationIF;
        Initialize();
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function CollapseHeadSection()
    {
        var titleHeadSectionY:Number = 8;
        var headSectionIconX:Number = m_SectionBoxWidth - 42.65 - m_ContentMargin;
        
        m_SectionBoxWidthCollapsed = m_TitleDescription.textLength + (m_ContentMargin * 4) + m_HeadSectionIcon._width;
        
        if ( m_SectionExtended )
        {
            m_SectionExtended = false;
            SignalCameraFocusChanged.Emit( GetCurrentCameraFocus() );
        }
        
        var descriptionTextFormat = new TextFormat();
        var TitleCollapsedTextFormat = new TextFormat();
        
        descriptionTextFormat.align = "right";
        descriptionTextFormat.size = 10;
        
        TitleCollapsedTextFormat.align = "right";
        TitleCollapsedTextFormat.size = 16;
        
        
        m_TitleHeadSection.textField.setTextFormat(TitleCollapsedTextFormat);
        m_TitleHeadSection.textField.setNewTextFormat(TitleCollapsedTextFormat);
        m_TitleDescription.textField.setTextFormat(descriptionTextFormat);
        m_TitleDescription.textField.setNewTextFormat(descriptionTextFormat);
        
        m_TitleHeadSection.tweenTo( 0.1, { _alpha: 100, _x: headSectionIconX - m_TitleHeadSection._width -  m_ContentMargin, _y: titleHeadSectionY}, None.easeInOut );
        m_TitleDescription.tweenTo( 0.1, { _alpha: 100, _x: headSectionIconX - m_TitleDescription._width -  m_ContentMargin, _y: titleHeadSectionY + m_TitleHeadSection._height - 4 }, None.easeInOut );
        m_Content.tweenTo( 0.1, { _alpha: 0, _x: m_ContentMargin, _y: titleHeadSectionY +  m_TitleHeadSection._height + m_ContentMargin }, Strong.easeOut );
        
        MovieClip(m_CloseSectionButton).tweenTo( 0.3, { _alpha:0 }, Strong.easeOut );
        m_HeadSectionIcon.tweenTo( 1, { _alpha: 100, _x: headSectionIconX, _y: m_ContentMargin, _width: 42.65, _height: 42.5 }, Strong.easeOut );
        _parent.m_Title.tweenTo( 2, { _alpha: 100 }, Strong.easeOut );
        _parent.m_MouseNavigationInfoText.tweenTo( 2, { _alpha: 100 }, Strong.easeOut );
        
        m_SectionBox.tweenTo( 1, { _alpha: 100, _width: m_SectionBoxWidthCollapsed, _height: m_SectionBoxHeightCollapsed, _x: m_SectionBoxWidth - m_SectionBoxWidthCollapsed }, Strong.easeOut );
        MovieClip(m_RandomizeHeadButton).tweenTo( 1, { _x: m_SectionBoxWidth - m_RandomizeHeadButton._width - m_ContentMargin, _y: m_SectionBox._y + m_SectionBoxHeightCollapsed + m_ContentMargin }, Strong.easeOut );
        
        this.tweenTo( 1, { _y: m_SectionOriginalY }, Strong.easeOut );
        
        m_ClickAreaCollapsed._visible = true;
        m_ClickAreaCollapsed._alpha = 1;
        m_ClickAreaCollapsed._width = m_SectionBoxWidthExtended;
        m_ClickAreaCollapsed._height = m_SectionBoxHeightCollapsed;
        
        m_ClickAreaCollapsed.onRelease = Delegate.create(this, ExtendHeadSection);
        m_ClickAreaCollapsed.onRollOver = Delegate.create(this, OnRollOverSectionBox);
        m_ClickAreaCollapsed.onRollOut = Delegate.create(this, OnRollOutSectionBox);
        
        m_Content.m_SectionDropdown.disabled = true;
    }

    private function OnRollOverSectionBox()
    {
        m_HeadSectionIcon.gotoAndPlay("over");
    }
    
    private function OnRollOutSectionBox()
    {
        m_HeadSectionIcon.gotoAndPlay("up");
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function UpdateBoxHeight( boxHeight:Number)
    {
        m_BoxHeight = boxHeight;
        if ( m_SectionExtended )
        {
            m_SectionBox.tweenTo( 0.5, { _alpha: 100, _width: m_SectionBoxWidth, _height: m_BoxHeight, _x: 0 }, Strong.easeOut );
            MovieClip(m_RandomizeHeadButton).tweenTo( 0.5, { _y: m_SectionBox._y + m_BoxHeight + m_ContentMargin }, Strong.easeOut );
            m_HeadSectionIcon.tweenTo( 0.2, { _alpha: 0, _x: m_CloseSectionButton._x, _y: m_CloseSectionButton._y, _width: m_CloseSectionButton._width, _height: m_CloseSectionButton._height }, Strong.easeOut );
            m_TitleHeadSection.tweenTo( 0.3, { _alpha: 100, _y: 2, _x: m_ContentMargin }, None.easeInOut );
            m_TitleDescription.tweenTo( 0.3, { _alpha: 0, _y: 2 + m_TitleHeadSection._height }, None.easeInOut ); 
            this.tweenTo( 1, { _y: (Stage.height/2) -  m_BoxHeight/2 - 45}, Strong.easeOut );
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function ExtendHeadSection()
    {
        m_SectionExtended = true;
        
        var extendedTextFormat = new TextFormat();
        
        extendedTextFormat.align = "left";
        extendedTextFormat.size = 16;
        
        m_TitleHeadSection.textField.setTextFormat(extendedTextFormat);
        m_TitleHeadSection.textField.setNewTextFormat(extendedTextFormat);
        
        _parent.m_Title.tweenTo( 0.5, { _alpha: 0 }, Strong.easeOut );
        _parent.m_MouseNavigationInfoText.tweenTo( 0.5, { _alpha: 0 }, Strong.easeOut );
        m_Content.tweenTo( 1, { _alpha:100 }, Strong.easeInOut );
        MovieClip(m_CloseSectionButton).tweenTo( 0.5, { _alpha: 100 }, Strong.easeOut );
        
        UpdateBoxHeight( m_BoxHeight );

        m_CloseSectionButton.addEventListener("click", this, "CollapseHeadSection");
        
        m_Content.m_SectionDropdown.disabled = false;
        
        SignalCameraFocusChanged.Emit( GetCurrentCameraFocus() );
        
        delete m_ClickAreaCollapsed.onRelease;
        delete m_ClickAreaCollapsed.onRollOver;
        delete m_ClickAreaCollapsed.onRollOut;
        m_ClickAreaCollapsed._visible = false;
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function RandomizeHead()
    {
        m_CharacterCreationIF.SetRandomFacialPreset();
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    static public function RandomizeSlider( slider )
    {
        var count:Number = slider.maximum - slider.minimum + 1;
        
        if ( count > 0 )
        {
            for ( var i:Number = 0 ; i < 10 ; ++i ) // Try at most 10 times to get a new value
            {
                var newValue:Number = Math.floor( Math.random() * count );
                
                if ( newValue != slider.position )
                {
                    slider.position = newValue;
                    break;
                }
            }
        }
    }
    
    static public function RandomizeList( list )
    {
        var listLength:Number = list.dataProvider.length;
        
        if ( listLength > 0 )
        {
            for ( var i:Number = 0 ; i < 10 ; ++i ) // Try at most 10 times to get a new value
            {
                var newValue:Number = Math.floor( Math.random() * listLength );
                
                if ( newValue != list.selectedIndex )
                {
                    list.selectedIndex = newValue;
                    break;
                }
            }
        }
    }
}


