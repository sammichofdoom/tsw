import com.Utils.Format;
import gfx.core.UIComponent;
import mx.transitions.easing.*;
import GUI.CharacterCreation.CameraController;
import GUI.CharacterCreation.HeadSection;

import gfx.controls.CheckBox;
import gfx.controls.TileList;
import gfx.controls.ScrollingList;
import com.Components.FCSlider;
import gfx.controls.Button;
import gfx.controls.Label;

import com.Utils.LDBFormat;
import com.Utils.Signal;

import com.GameInterface.Game.Character;

    
dynamic class GUI.CharacterCreation.HeadSectionHairMakeup extends UIComponent
{
    public var m_CameraController:CameraController;
    public var SignalBoxHeightChanged:Signal;
    public var SignalSetSurgeryData:Signal;
    
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
    private var m_IsUILoaded:Boolean = false;
    private var m_IsInitialized:Boolean = false;
    public var m_BoxHeight:Number;
    
    private var m_HairStyleTitle:Label;
    private var m_HairStyleScrollingList:ScrollingList;
    private var m_HairStyleBackground:MovieClip;
    private var m_HairColorList:TileList;
    private var m_HairstyleHorizontalDivider:MovieClip;
    
    private var m_FacialHairTitle:Label;
    private var m_FacialHairColorList:TileList;
    private var m_UseHairColorCheckbox:CheckBox;
    private var m_FacialHairHorizontalDivider:MovieClip;
    
    private var m_EyebrowTitle:Label;
    private var m_EyebrowSlider:FCSlider;
    private var m_EyeBrowHorizontalDivider:MovieClip;
    
    private var m_BeardMustacheTitle:Label;
    private var m_BeardMustacheScrollingList:ScrollingList;
    private var m_BeardMustacheBackground:MovieClip;
    private var m_BeardMustacheHorizontalDivider:MovieClip;
    
    private var m_MakeupGlamourTitle:Label;
    private var m_MakeupGlamourScrollingList:ScrollingList;
    private var m_MakeupGlamourBackground:MovieClip;
    private var m_MakeupGlamourColorList:TileList;
    
    private var m_IsHairColorsLinked:Boolean = false;
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function HeadSectionHairMakeup()
    {
        SignalBoxHeightChanged = new Signal;
        SignalSetSurgeryData = new Signal();
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SetTextFormat()
    {
        var subHeaderTitleFormat = new TextFormat();
        
        subHeaderTitleFormat.align = "left";
        subHeaderTitleFormat.size = 11;
        
        m_HairStyleTitle.textField.setTextFormat(subHeaderTitleFormat);
        m_HairStyleTitle.textField.setNewTextFormat(subHeaderTitleFormat);
        
        m_FacialHairTitle.textField.setTextFormat(subHeaderTitleFormat);
        m_FacialHairTitle.textField.setNewTextFormat(subHeaderTitleFormat);
        
        m_EyebrowTitle.textField.setTextFormat(subHeaderTitleFormat);
        m_EyebrowTitle.textField.setNewTextFormat(subHeaderTitleFormat);
        
        m_BeardMustacheTitle.textField.setTextFormat(subHeaderTitleFormat);
        m_BeardMustacheTitle.textField.setNewTextFormat(subHeaderTitleFormat);
        
        m_MakeupGlamourTitle.textField.setTextFormat(subHeaderTitleFormat);
        m_MakeupGlamourTitle.textField.setNewTextFormat(subHeaderTitleFormat);
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    /////////////////////////////////////////////////////////////////////////////
    
    private function Initialize()
    {
        if ( m_IsInitialized || m_CharacterCreationIF == undefined || !m_IsUILoaded )
        {
            return;
        }
        m_IsInitialized = true;
        
        m_FacialHairTitle.text = LDBFormat.LDBGetText( "CharCreationGUI", "FacialHairColorHeader" );
        m_UseHairColorCheckbox.label = LDBFormat.LDBGetText( "CharCreationGUI", "UseHairColor" );
        m_UseHairColorCheckbox.addEventListener( "select", this, "OnLinkHairFacialHairColor" );
        m_UseHairColorCheckbox.selected = true;
        
        m_BeardMustacheTitle.text = LDBFormat.LDBGetText( "CharCreationGUI", "BeardMustache" );
        m_HairStyleTitle.text = LDBFormat.LDBGetText( "CharCreationGUI", "HairStyle" );
        
        m_CharacterCreationIF.SignalGenderChanged.Connect( SlotGenderChanged, this );
        SlotGenderChanged( m_CharacterCreationIF.GetGender() );
        
        m_CharacterCreationIF.SignalHairStyleChanged.Connect( SlotHairStyleChanged, this );
        m_CharacterCreationIF.SignalHairStyleChanged.Connect( UpdateServerMorphValues, this );
        SlotHairStyleChanged( m_CharacterCreationIF.GetHairStyleIndex() );

        m_CharacterCreationIF.SignalEyebrowChanged.Connect( SlotEyebrowChanged, this );
        m_CharacterCreationIF.SignalEyebrowChanged.Connect( UpdateServerMorphValues, this );
        SlotEyebrowChanged( m_CharacterCreationIF.GetEyebrow() );

        m_CharacterCreationIF.SignalBeardChanged.Connect( SlotBeardChanged, this );
        m_CharacterCreationIF.SignalBeardChanged.Connect( UpdateServerMorphValues, this );
        SlotBeardChanged( m_CharacterCreationIF.GetBeard() );

        m_CharacterCreationIF.SignalMakeupChanged.Connect( SlotMakeupChanged, this );
        m_CharacterCreationIF.SignalMakeupChanged.Connect( UpdateServerMorphValues, this );
        SlotMakeupChanged( m_CharacterCreationIF.GetMakeup() );

        m_CharacterCreationIF.SignalMakeupColorChanged.Connect( SlotMakeupColorChanged, this );
        m_CharacterCreationIF.SignalMakeupColorChanged.Connect( UpdateServerMorphValues, this );
        SlotMakeupColorChanged( m_CharacterCreationIF.GetMakeupColorIndex() );
        
        m_CharacterCreationIF.SignalHairColorChanged.Connect( SlotHairColorChanged, this );
        m_CharacterCreationIF.SignalHairColorChanged.Connect( UpdateServerMorphValues, this );
        SlotHairColorChanged( m_CharacterCreationIF.GetHairColorIndex() );
        
        m_CharacterCreationIF.SignalFacialHairColorChanged.Connect( SlotFacialHairColorChanged, this );
        m_CharacterCreationIF.SignalFacialHairColorChanged.Connect( UpdateServerMorphValues, this );
        SlotFacialHairColorChanged( m_CharacterCreationIF.GetFacialHairColorIndex() );
        
        SetTextFormat();
        
        m_HairStyleScrollingList.addEventListener("change", this, "OnHairStyleChanged");
        m_BeardMustacheScrollingList.addEventListener("change", this, "OnBeardChanged");
        m_MakeupGlamourScrollingList.addEventListener("change", this, "OnMakeupChanged");
        
        m_EyebrowSlider.minimum      = 0;
        m_EyebrowSlider.snapping     = true;
        m_EyebrowSlider.snapInterval = 1;
        m_EyebrowSlider.addEventListener("change", this, "OnEyebrowChanged");

        m_HairColorList.addEventListener( "change", this, "OnHairColorSelected" );
        m_FacialHairColorList.addEventListener( "change", this, "OnFacialHairColorSelect" );
        m_MakeupGlamourColorList.addEventListener( "change", this, "OnMakeupColorSelect" );
    }
    
    private function UpdateServerMorphValues()
    {
        m_CharacterCreationIF.SetSurgeryData(0);
        SignalSetSurgeryData.Emit();
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function configUI()
    {
        m_IsUILoaded = true;
        Initialize();
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    public function Disable(state:Boolean)
    {
        m_HairStyleScrollingList.disabled = state;
        m_HairColorList.disabled = state;
        m_FacialHairColorList.disabled = state;
        m_UseHairColorCheckbox.disabled = state;
        m_EyebrowSlider.disabled = state;
        m_BeardMustacheScrollingList.disabled = state;
        m_MakeupGlamourScrollingList.disabled = state;
        m_MakeupGlamourColorList.disabled = state;
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SetCharacterCreationIF( characterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation )
    {
        m_CharacterCreationIF = characterCreationIF;
        Initialize();
    }

    public function RandomizePanel() : Void
    {
        OnRandomizeHairStyle();
        OnRandomizeEyebrow(); 
        OnRandomizeBeardMustache(); 
        
        var hairIndexes:Array = m_CharacterCreationIF.GetHairColorIndexes();
        var randomHair:Number = Math.floor(Math.random() * hairIndexes.length)
        m_CharacterCreationIF.SetHairColorIndex(hairIndexes[randomHair]);
        
        if ( !m_IsHairColorsLinked ) 
        {
            var hairColorIndexes:Array = m_CharacterCreationIF.GetFacialHairColorIndexes();
            var randomHairColor:Number = Math.floor(Math.random() * hairColorIndexes.length);
            m_CharacterCreationIF.SetFacialHairColorIndex(hairColorIndexes[randomHairColor]);
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SlotGenderChanged( gender:Number )
    {    
        if ( gender == _global.Enums.BreedSex.e_Sex_Female )
        {
            m_MakeupGlamourTitle.text = LDBFormat.LDBGetText( "CharCreationGUI", "MakeUp" );
            
            m_BeardMustacheTitle._visible = false;
            m_BeardMustacheScrollingList._visible = false;
            m_BeardMustacheBackground._visible = false;
            m_BeardMustacheHorizontalDivider._visible = false;
            
            m_MakeupGlamourTitle._y = m_EyeBrowHorizontalDivider._y + m_EyeBrowHorizontalDivider._height + 2;
            m_MakeupGlamourScrollingList._y = m_MakeupGlamourTitle._y + m_MakeupGlamourTitle._height + 2;
            m_MakeupGlamourBackground._y = m_MakeupGlamourScrollingList._y;
            m_MakeupGlamourColorList._y  = m_MakeupGlamourScrollingList._y + m_MakeupGlamourScrollingList._height + 5;
        }
        
        else if ( gender == _global.Enums.BreedSex.e_Sex_Male )
        {
            m_MakeupGlamourTitle.text = LDBFormat.LDBGetText( "CharCreationGUI", "FacialFeature" );
            
            m_BeardMustacheTitle._visible = true;
            m_BeardMustacheScrollingList._visible = true;
            m_BeardMustacheBackground._visible = true;
            m_BeardMustacheHorizontalDivider._visible = true;
            
            m_MakeupGlamourTitle._y = m_BeardMustacheHorizontalDivider._y + m_BeardMustacheHorizontalDivider._height + 2;
            m_MakeupGlamourScrollingList._y = m_MakeupGlamourTitle._y + m_MakeupGlamourTitle._height + 2;
            m_MakeupGlamourBackground._y = m_MakeupGlamourScrollingList._y;
            m_MakeupGlamourColorList._y  = m_MakeupGlamourScrollingList._y + m_MakeupGlamourScrollingList._height + 5;
        }
        
        m_BoxHeight = m_MakeupGlamourColorList._y + m_MakeupGlamourColorList._height + 80;
        SignalBoxHeightChanged.Emit(m_BoxHeight);
        
        m_EyebrowSlider.maximum       = m_CharacterCreationIF.GetEyebrowCount() - 1;
        
        SetBeard();
        SetHairStyle();
        SetColorMakeupGlamour();
        SetColorHair();
        SetColorFacialHair();
        SetMakeup();
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SetColorHair()
    {
        m_HairColorList.dataProvider = [];

        for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetHairColorIndexes().length ; ++i )
        {
            m_HairColorList.dataProvider.push( { _color:m_CharacterCreationIF.GetHairColorValue( i ) } );
        }
        
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SetBeard()
    {
        var beardData:Array = new Array();
        
        // to be replaced with proper indexes
        var beardIndexes:Array = new Array();
        for (var i:Number = 0; i < m_CharacterCreationIF.GetBeardCount(); ++i )
        {
            beardIndexes.push(i);
        }
        
        for ( var i:Number = 0; i < beardIndexes.length; ++i )
        {
            var ldbInstance:String = "BeardStyle_" + beardIndexes[i];
            var label:String = LDBFormat.LDBGetText( "CharCreationGUI", ldbInstance );
            beardData.push( { label:label, id:beardIndexes[i] } );
        }
        
        m_BeardMustacheScrollingList.dataProvider = beardData;
    }
    
    private function SetHairStyle()
    {
        var hairStyleData:Array = new Array();
        var hairStyleIndexes:Array = m_CharacterCreationIF.GetHairStyleIndexes();
        for ( var i:Number = 0; i < hairStyleIndexes.length; ++i )
        {
            var ldbInstance:String = "HairStyle_" + (m_CharacterCreationIF.GetGender() == _global.Enums.BreedSex.e_Sex_Female ? "Female_" : "Male_") + (hairStyleIndexes[i] + 1);
            var label:String = LDBFormat.LDBGetText( "CharCreationGUI", ldbInstance );
            hairStyleData.push( { label:label, id:hairStyleIndexes[i] } );
        }
        
        m_HairStyleScrollingList.dataProvider = hairStyleData;
    }
    
    private function SetMakeup()
    {
        var makeupData:Array = new Array();
        
        // to be replaced with proper indexes
        var makeupIndexes:Array = new Array();
        for (var i:Number = 0; i < m_CharacterCreationIF.GetMakeupCount(); ++i )
        {
            makeupIndexes.push(i);
        }
        
        for ( var i:Number = 0; i < makeupIndexes.length; ++i )
        {
            var ldbInstance:String = "Makeup_" + (m_CharacterCreationIF.GetGender() == _global.Enums.BreedSex.e_Sex_Female ? "Female_" : "Male_") + (makeupIndexes[i] + 1);
            var label:String = LDBFormat.LDBGetText( "CharCreationGUI", ldbInstance );
            makeupData.push( { label:label, id:makeupIndexes[i] } );
        }
        
        m_MakeupGlamourScrollingList.dataProvider = makeupData;
        
        GetFacialFeatureMakeUpHeight();
    }
    
    public function GetFacialFeatureMakeUpHeight():Number
    {
        var listHeight = m_CharacterCreationIF.GetMakeupCount() * 19.5;
        return listHeight;
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SetColorFacialHair()
    {
        m_FacialHairColorList.dataProvider = [];

        for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetFacialHairColorIndexes().length ; ++i )
        {
            m_FacialHairColorList.dataProvider.push( { _color:m_CharacterCreationIF.GetFacialHairColorValue( i ) } );
        }
        
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SetColorMakeupGlamour()
    {
        m_MakeupGlamourColorList.dataProvider = [];

        for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetMakeupColorIndexes().length ; ++i )
        {
            m_MakeupGlamourColorList.dataProvider.push( { _color:m_CharacterCreationIF.GetMakeupColorValue( i ) } );
        }
        
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function LinkHairColors( link:Boolean ) : Void
    {
        if ( link != m_IsHairColorsLinked )
        {
            m_IsHairColorsLinked = link;
            m_FacialHairColorList.disabled = m_IsHairColorsLinked;
            m_FacialHairColorList._alpha = (m_IsHairColorsLinked) ? 20 : 100;
            if ( m_IsHairColorsLinked )
            {
                m_FacialHairColorList.selectedIndex = m_HairColorList.selectedIndex % m_FacialHairColorList.dataProvider.length;
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnHairStyleChanged( event:Object )
    {
        var indexes:Array = m_CharacterCreationIF.GetHairStyleIndexes();
        m_CharacterCreationIF.SetHairStyleIndex(indexes[event.target.selectedIndex]);
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnEyebrowChanged( event:Object )
    {
        m_CharacterCreationIF.SetEyebrow( event.target.position );
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnBeardChanged( event:Object )
    {
        // to be replaced with proper indexes
        var indexes:Array = new Array();
        for (var i:Number = 0; i < m_CharacterCreationIF.GetBeardCount(); ++i )
        {
            indexes.push(i);
        }
        
        m_CharacterCreationIF.SetBeard(indexes[event.target.selectedIndex]);
        
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnMakeupChanged( event:Object )
    {
        // to be replaced with proper indexes
        var indexes:Array = new Array();
        for (var i:Number = 0; i < m_CharacterCreationIF.GetMakeupCount(); ++i )
        {
            indexes.push(i);
        }
        
        m_CharacterCreationIF.SetMakeup(indexes[event.target.selectedIndex]);
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnRandomizeHairStyle()
    {
        HeadSection.RandomizeList( m_HairStyleScrollingList );
        
        var indexes:Array = m_CharacterCreationIF.GetHairColorIndexes();
        m_CharacterCreationIF.SetHairStyleIndex(indexes[m_HairStyleScrollingList.selectedIndex]);
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnRandomizeHairColor()
    {
        HeadSection.RandomizeList( m_HairColorList );
        
        var indexes:Array = m_CharacterCreationIF.GetHairColorIndexes();
        m_CharacterCreationIF.SetHairColorIndex(indexes[m_HairColorList.selectedIndex]);
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnLinkHairFacialHairColor()
    {
        LinkHairColors( m_UseHairColorCheckbox.selected );        
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnRandomizeEyebrow()
    {
        m_CharacterCreationIF.SetEyebrow( Math.floor( Math.random() * m_CharacterCreationIF.GetEyebrowCount() ) );
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnRandomizeBeardMustache()
    {
        HeadSection.RandomizeList( m_BeardMustacheScrollingList );
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function OnRandomizeMakeupGlamour()
    {
        HeadSection.RandomizeList( m_MakeupGlamourScrollingList );
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function OnRandomizeMakeupGlamourColor()
    {
        HeadSection.RandomizeList( m_MakeupGlamourColorList ); 
        
        var indexes:Array = m_CharacterCreationIF.GetMakeupColorIndexes();
        m_CharacterCreationIF.SetMakeupColorIndex(indexes[m_MakeupGlamourColorList.selectedIndex]);
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////

    private function OnHairColorSelected( event:Object )
    {
        var indexes:Array = m_CharacterCreationIF.GetHairColorIndexes();
        m_CharacterCreationIF.SetHairColorIndex(indexes[event.index]);

        if ( m_IsHairColorsLinked )
        {
            m_FacialHairColorList.selectedIndex = m_HairColorList.selectedIndex % m_FacialHairColorList.dataProvider.length;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////

    private function OnFacialHairColorSelect( event:Object )
    {
        var indexes:Array = m_CharacterCreationIF.GetFacialHairColorIndexes();
        m_CharacterCreationIF.SetFacialHairColorIndex(indexes[event.index]);
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////

    private function OnMakeupColorSelect( event:Object )
    {
        var indexes:Array = m_CharacterCreationIF.GetMakeupColorIndexes();
        m_CharacterCreationIF.SetMakeupColorIndex(indexes[event.index]);
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SlotHairStyleChanged( index:Number )
    {
        var indexes:Array = m_CharacterCreationIF.GetHairStyleIndexes();
        for (var i = 0; i < indexes.length; i++)
        {
            if (indexes[i] == index)
            {
                m_HairStyleScrollingList.selectedIndex = i;
                break;
            }
        }
    }
    public function SlotMakeupColorChanged( index:Number )
    {
        var indexes:Array = m_CharacterCreationIF.GetMakeupColorIndexes();
        for (var i = 0; i < indexes.length; i++)
        {
            if (indexes[i] == index)
            {
                m_MakeupGlamourColorList.selectedIndex = i;
                break;
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SlotEyebrowChanged( index:Number )
    {
        m_EyebrowTitle.text = Format.Printf( LDBFormat.LDBGetText( "CharCreationGUI", "Eyebrow" ) + " #%.0f", index + 1 );
        m_EyebrowSlider.position = index;
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SlotBeardChanged( index:Number )
    {
        // to be replaced with proper indexes
        var indexes:Array = new Array();
        for (var i:Number = 0; i < m_CharacterCreationIF.GetBeardCount(); ++i )
        {
            indexes.push(i);
        }
        
        for (var i = 0; i < indexes.length; i++)
        {
            if (indexes[i] == index)
            {
                m_BeardMustacheScrollingList.selectedIndex = i;
                break;
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    
    
    public function SlotMakeupChanged( index:Number )
    {
        // to be replaced with proper indexes
        var indexes:Array = new Array();
        for (var i:Number = 0; i < m_CharacterCreationIF.GetMakeupCount(); ++i )
        {
            indexes.push(i);
        }
        
        for (var i = 0; i < indexes.length; i++)
        {
            if (indexes[i] == index)
            {
                m_MakeupGlamourScrollingList.selectedIndex = i;
                break;
            }
        }
        
        SetColorMakeupGlamour();
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////

    public function SlotHairColorChanged( index:Number)
    {
        var indexes:Array = m_CharacterCreationIF.GetHairColorIndexes();
        for (var i = 0; i < indexes.length; i++)
        {
            if (indexes[i] == index)
            {
                m_HairColorList.selectedIndex = i;
                break;
            }
        }
    }
        
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////

    public function SlotFacialHairColorChanged( index:Number)
    {
        var indexes:Array = m_CharacterCreationIF.GetFacialHairColorIndexes();
        for (var i = 0; i < indexes.length; i++)
        {
            if (indexes[i] == index)
            {
                m_FacialHairColorList.selectedIndex = i;
                if (m_FacialHairColorList.selectedIndex != m_HairColorList.selectedIndex)
                {
                    // this should certainly be deselected if the colors no longer match (happens in surgery)
                    m_UseHairColorCheckbox.selected = false;
                }
                break;
            }
        }
    }
}