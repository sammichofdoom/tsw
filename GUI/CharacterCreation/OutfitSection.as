import com.Utils.Format;
import gfx.core.UIComponent;
import mx.utils.Delegate;
import flash.geom.Point;

import mx.transitions.easing.*;
import gfx.controls.TileList;

import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.CharacterCreation.CameraController;

dynamic class GUI.CharacterCreation.OutfitSection extends UIComponent
{   
	private var m_CloseSectionButton:MovieClip;
	private var m_OutfitSectionIcon:MovieClip;
	private var m_RandomizeOutfitButton:MovieClip;
	private var m_SectionBox:MovieClip;
	private var m_TitleOutfitSection:MovieClip;
	private var m_TitleDescription:MovieClip;
	private var m_SelectedItemTitle:MovieClip;
	public var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
	private var m_Content:MovieClip;
	private var m_ClickAreaCollapsed:MovieClip;
	
	private var m_SectionBoxWidth:Number;
	private var m_SectionBoxHeightCollapsed:Number;
	private var m_ContentMargin:Number;
	private var m_SectionOriginalY:Number;
	public var m_SectionExtended:Boolean;
	private var m_IsInitialized:Boolean = false;
    private var m_IsUILoaded:Boolean = false;
    private var m_Locations:Array;
    private var m_CurrentLocation:Number;


    public var SignalCameraFocusChanged:Signal;
    
    public function OutfitSection()
    {
        SignalCameraFocusChanged = new Signal();
        
		m_SectionOriginalY = (Stage.height / 2) - 50;
		m_SectionBoxWidth = 296;
		m_SectionBoxHeightCollapsed = 50;
		m_ContentMargin = 4;
		m_CurrentLocation = 0;
        
		m_SectionBox.onRelease = function() { };
    }

    public function GetCurrentCameraFocus() : Number
    {
        if ( m_SectionExtended )
        {
            switch ( m_CurrentLocation )
            {
              case _global.Enums.ItemEquipLocation.e_Wear_Face:  return CameraController.e_ModeFace;
              case _global.Enums.ItemEquipLocation.e_Wear_Chest: return CameraController.e_ModeTop;
              case _global.Enums.ItemEquipLocation.e_Wear_Back:  return CameraController.e_ModeBody;
              case _global.Enums.ItemEquipLocation.e_Wear_Legs:  return CameraController.e_ModeLegs;
              case _global.Enums.ItemEquipLocation.e_Wear_Feet:  return CameraController.e_ModeFeet;
              default:                                           return CameraController.e_ModeBody;
            }
        }
        else
        {
            return CameraController.e_ModeBody
        }
    }
                
	private function CollapseOutfitSection()
	{
		var titleHeadSectionY:Number = 8;
		var titleHeadSectionX:Number = m_OutfitSectionIcon._width + (m_ContentMargin * 2);
		
		var headerTextFormat = new TextFormat();
		headerTextFormat.size = 16;
		
		var descriptionTextFormat = new TextFormat();
		descriptionTextFormat.size = 10;
		
		m_TitleOutfitSection.html = false;
		m_TitleDescription.html = false;
		
		m_TitleOutfitSection.textField.setTextFormat(headerTextFormat);
		m_TitleOutfitSection.textField.setNewTextFormat(headerTextFormat);
		m_TitleDescription.textField.setTextFormat(descriptionTextFormat);
		m_TitleDescription.textField.setNewTextFormat(descriptionTextFormat);
		
		m_TitleOutfitSection.text = LDBFormat.LDBGetText( "CharCreationGUI", "Outfit" );
		m_TitleDescription.text = LDBFormat.LDBGetText( "CharCreationGUI", "OutfitTitleDescription" );
		
		m_TitleOutfitSection.tweenTo( 0.1, { _x:  titleHeadSectionX,_y: titleHeadSectionY }, None.easeInOut );
		m_TitleDescription.tweenTo( 0.1, { _alpha:100, _x: titleHeadSectionX, _y: titleHeadSectionY +  m_TitleOutfitSection._height - 4 }, None.easeInOut );
		m_Content.tweenTo( 0.1, { _alpha:0, _x: m_ContentMargin, _y: titleHeadSectionY +  m_TitleHeadSection._height + m_ContentMargin }, Strong.easeOut );
		m_OutfitSectionIcon.tweenTo( 1, { _alpha: 100, _x: m_ContentMargin, _y: m_ContentMargin }, Strong.easeOut );
		m_CloseSectionButton.tweenTo( 0.3, { _alpha:0 }, Strong.easeOut );
		m_SectionBox.tweenTo( 1, { _width: m_SectionBoxWidth, _height: m_SectionBoxHeightCollapsed, _x: 0, _y: 0 }, Strong.easeOut );
		m_RandomizeOutfitButton.tweenTo( 1, { _x: m_ContentMargin, _y: m_SectionBox._y + m_SectionBoxHeightCollapsed + m_ContentMargin }, Strong.easeOut );
		_parent.m_Title.tweenTo( 0.5, { _alpha: 100 }, Strong.easeOut );
		_parent.m_MouseNavigationInfoText.tweenTo( 0.5, { _alpha: 100 }, Strong.easeOut );
		
		this.tweenTo( 1, { _y: m_SectionOriginalY }, Strong.easeOut );
		
		m_ClickAreaCollapsed._visible = true;
		m_ClickAreaCollapsed._alpha = 1;
		m_ClickAreaCollapsed._width = m_SectionBoxWidthExtended;
		m_ClickAreaCollapsed._height = m_SectionBoxHeightCollapsed;
		
		m_ClickAreaCollapsed.onRelease = Delegate.create(this, ExtendOutfitSection);
		m_ClickAreaCollapsed.onRollOver = Delegate.create(this, OnRollOverSectionBox);
		m_ClickAreaCollapsed.onRollOut = Delegate.create(this, OnRollOutSectionBox);
		
		m_Content.m_SectionDropdown.disabled = true;

        if ( m_SectionExtended )
        {
            m_SectionExtended = false;
            SignalCameraFocusChanged.Emit( GetCurrentCameraFocus() );
        }
	}
	
	private function OnRollOverSectionBox()
	{
		m_OutfitSectionIcon.gotoAndPlay("over");
	}
	
	private function OnRollOutSectionBox()
	{
		m_OutfitSectionIcon.gotoAndPlay("up");
	}
	
	public function ExtendOutfitSection()
	{
		m_BoxHeight = m_Content._height + 40 ;
		
		m_CloseSectionButton.tweenTo( 0.5, { _alpha: 100 }, Strong.easeOut );
		m_OutfitSectionIcon.tweenTo( 0.7, { _x: m_CloseSectionButton._x, _y: m_CloseSectionButton._y }, Strong.easeOut );
		m_OutfitSectionIcon.tweenTo( 0.5, { _alpha: 0 }, Strong.easeOut );
		m_TitleOutfitSection.tweenTo( 0.3, { _y: 2, _x: m_ContentMargin }, None.easeInOut );
		m_TitleDescription.tweenTo( 0.3, { _alpha:0 }, None.easeInOut );
		m_SectionBox.tweenTo( 0.5, { _width: m_SectionBoxWidth, _height: m_BoxHeight, _x: 0 }, Strong.easeOut );
		m_RandomizeOutfitButton.tweenTo( 0.5, { _y: m_SectionBox._y + m_BoxHeight + m_ContentMargin }, Strong.easeOut );
		_parent.m_Title.tweenTo( 0.5, { _alpha: 0 }, Strong.easeOut );
		_parent.m_MouseNavigationInfoText.tweenTo( 0.5, { _alpha: 0 }, Strong.easeOut );
		
		this.tweenTo( 1, { _y: (Stage.height/2) -  (m_BoxHeight/2) - 45 }, Strong.easeOut );
		
		m_CloseSectionButton.addEventListener("click", this, "CollapseOutfitSection");
		m_OutfitSectionIcon.removeEventListener("rollOut", this, "CollapseOutfitSection");
		m_OutfitSectionIcon.removeEventListener("rollOver", this, "RolloverOutfitSection");
		m_Content.tweenTo( 1, { _alpha:100 }, Strong.easeInOut );
		
		m_Content.m_SectionDropdown.disabled = false;
		m_SectionExtended = true;
        SignalCameraFocusChanged.Emit( GetCurrentCameraFocus() );
		
		delete m_ClickAreaCollapsed.onRelease;
		delete m_ClickAreaCollapsed.onRollOver;
		delete m_ClickAreaCollapsed.onRollOut;
		m_ClickAreaCollapsed._visible = false;
	}
	
	private function Initialize()
    {
        if ( m_IsInitialized || m_CharacterCreationIF == undefined || !m_IsUILoaded )
        {
            return;
        }
        m_IsInitialized = true;
		


        m_Locations = [{m_Label: LDBFormat.LDBGetText( "CharCreationGUI", "Accessories" ), m_Location:_global.Enums.ItemEquipLocation.e_Wear_Face},
                       {m_Label: LDBFormat.LDBGetText( "CharCreationGUI", "Chest" ), m_Location:_global.Enums.ItemEquipLocation.e_Wear_Chest},
                       {m_Label: LDBFormat.LDBGetText( "CharCreationGUI", "Outfit_Back" ), m_Location:_global.Enums.ItemEquipLocation.e_Wear_Back},
                       {m_Label: LDBFormat.LDBGetText( "CharCreationGUI", "Legs" ), m_Location:_global.Enums.ItemEquipLocation.e_Wear_Legs},
                       {m_Label: LDBFormat.LDBGetText( "CharCreationGUI", "Shoes" ), m_Location:_global.Enums.ItemEquipLocation.e_Wear_Feet}
                       ];
        
		m_Content.m_SectionDropdown.dataProvider = [];
        m_CurrentLocation = m_Locations[0].m_Location;

        for ( var i:Number = 0 ; i < m_Locations.length ; ++i )
        {
            m_Content.m_SectionDropdown.dataProvider.push( m_Locations[i].m_Label );
        }
        m_Content.m_SectionDropdown.selectedIndex = 0;
		m_Content.m_SectionDropdown.addEventListener("change", this, "OnLocationSelected");
		
        m_Content.m_ContentScrollingList.addEventListener( "change", this, "OnClothingItemSelected" );
		
		m_Content.m_RandomizeActiveSubSectionButton._visible = false;
        m_Content.m_RandomizeActiveSubSectionButton.addEventListener( "click", this, "OnRandomizeCurrentLocationButton" );
        m_RandomizeOutfitButton.addEventListener( "click", this, "OnRandomizeOutfitButton" );
        
        m_CharacterCreationIF.SignalGenderChanged.Connect( SlotGenderChanged, this );
        SlotGenderChanged( m_CharacterCreationIF.GetGender() );
        m_CharacterCreationIF.SignalClothingChanged.Connect( SlotClothingChanged, this );
    }
	
	
    private function configUI()		
    {
		m_IsUILoaded = true;
        Initialize();
		CollapseOutfitSection();
		m_RandomizeOutfitButton.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "Tooltip_RandomizeOutfit" ));
	}
	
	public function SetCharacterCreationIF( characterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation )
	{
		m_CharacterCreationIF = characterCreationIF;
        Initialize();
    }
	
    private function OnLocationSelected( event:Object )
    {
        SetLocation( m_Locations[ m_Content.m_SectionDropdown.selectedIndex ].m_Location );
    }
    
    private function OnClothingItemSelected( event:Object )
    {
        var selectedItem:Object = m_Content.m_ContentScrollingList.dataProvider[ event.index ];
		
        if ( m_CharacterCreationIF.GetClothSelection( m_CurrentLocation ) != selectedItem.m_ClothIndex )
        {
            m_CharacterCreationIF.WearCloth( m_CurrentLocation, selectedItem.m_ClothIndex );
        }
    }

    private function RandomizeLocation( location:Number )
    {
        var currentIndex:Number = m_CharacterCreationIF.GetClothSelection( location );

        var clothCount:Number = m_CharacterCreationIF.GetClothCount( location );
        var firstIndex = 0;
        if ( m_CharacterCreationIF.CanClothSlotBeEmpty( location ) )
        {
            firstIndex = -1;
            clothCount++;
        }
        for ( var i:Number = 0 ; i < 10 ; ++i )
        {
            var newIndex = firstIndex + Math.floor( clothCount * Math.random() );
            if ( newIndex != currentIndex )
            {
                m_CharacterCreationIF.WearCloth( location, newIndex );
                break;
            }            
        }
    }

    private function OnRandomizeCurrentLocationButton()
    {
        RandomizeLocation( m_CurrentLocation );
    }
    
    private function OnRandomizeOutfitButton()
    {
        for ( var i:Number = 0 ; i < m_Locations.length ; ++i )
        {
            var location:Number = m_Locations[i].m_Location;
            RandomizeLocation( location );
        }
    }
    
    private function SetLocation( location:Number ) : Void
    {
        if ( location != m_CurrentLocation )
        {
            m_CurrentLocation = location;
            UpdateClothingList();
            SignalCameraFocusChanged.Emit( GetCurrentCameraFocus() );
        }
    }
    
	private function SlotGenderChanged( gender:Number )
    {
        UpdateClothingList();
    }

    private function UpdateClothingList()
    {
        var count:Number = m_CharacterCreationIF.GetClothCount( m_CurrentLocation );

        m_Content.m_ContentScrollingList.removeEventListener( "change", this, "OnClothingItemSelected" );
        m_Content.m_ContentScrollingList.dataProvider = [];


        if ( m_CharacterCreationIF.CanClothSlotBeEmpty( m_CurrentLocation ) )
        {
            var emptyItem:Object = new Object;
            emptyItem.m_ItemName = LDBFormat.LDBGetText( "CharCreationGUI", "NoItemSelected" );
            emptyItem.m_IconID = 0;
            emptyItem.m_ClothIndex = -1;
            m_Content.m_ContentScrollingList.dataProvider.push( emptyItem );
        }
        
        for ( var i = 0 ; i < count ; ++i )
        {
            var item:Object = new Object;
            item.m_ItemName = m_CharacterCreationIF.GetClothName( m_CurrentLocation, i );
            item.m_IconID = m_CharacterCreationIF.GetClothIcon( m_CurrentLocation, i );
            item.m_ClothIndex = i;
            m_Content.m_ContentScrollingList.dataProvider.push( item );
        }
		
        SlotClothingChanged( m_CurrentLocation, m_CharacterCreationIF.GetClothSelection( m_CurrentLocation ) );
        m_Content.m_ContentScrollingList.addEventListener( "change", this, "OnClothingItemSelected" );
    }
	
    private function SlotClothingChanged( location:Number, index:Number )
    {
        if ( location == m_CurrentLocation )
        {
            if ( m_CharacterCreationIF.CanClothSlotBeEmpty( m_CurrentLocation ) ) index++;
            m_Content.m_ContentScrollingList.selectedIndex = index ;
			
			var selectedItem:Object = m_Content.m_ContentScrollingList.dataProvider[ m_Content.m_ContentScrollingList.selectedIndex ];
			m_Content.m_SelectedItemTitle.htmlText = selectedItem.m_ItemName;
        }
    }
}
