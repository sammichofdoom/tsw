import com.Utils.Format;
import gfx.core.UIComponent;
import GUI.CharacterCreation.CameraController;
import mx.transitions.easing.*;

import gfx.controls.TileList;
import com.Components.FCSlider;
import gfx.controls.Button;
import gfx.controls.Label;

import com.Utils.LDBFormat;
import com.Utils.Signal;

import com.GameInterface.Game.Character;

    
dynamic class GUI.CharacterCreation.HeadSectionFacialTraits extends UIComponent
{   
    public var m_CameraController:CameraController;
    public var SignalSetSurgeryData:Signal;
    
    private var m_FacialControllers:Object;
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
    private var m_IsUILoaded:Boolean = false;
    private var m_IsInitialized:Boolean = false;
    
    private var m_HeadTitle:Label;
    private var m_RandomizeHeadButton:Button;
    private var m_BaseHeadSlider:FCSlider;
    
    private var m_SkinColorHeader:Label;
    private var m_RandomizeSkinColorButton:Button;
    private var m_SkinColorList:TileList;
    
    private var m_EyesTitle:Label;
    private var m_RandomizeEyesButton:Button;
    private var m_EyesSlider:FCSlider;
    private var m_EyeColorList:TileList;
    
    private var m_NoseTitle:Label;
    private var m_RandomizeNoseButton:Button;
    private var m_NoseSlider:FCSlider;
    
    private var m_LipsTitle:Label;
    private var m_RandomizeLipsButton:Button;
    private var m_LipsSlider:FCSlider;
    
    private var m_JawTitle:Label;
    private var m_RandomizeJawButton:Button;
    private var m_JawSlider:FCSlider;
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function HeadSectionFacialTraits()
    {
        SignalSetSurgeryData = new Signal();
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function Initialize()
    {
        m_RandomizeHeadButton._visible = false;
        m_RandomizeSkinColorButton._visible = false;
        m_RandomizeEyesButton._visible = false;
        m_RandomizeNoseButton._visible = false;
        m_RandomizeLipsButton._visible = false;
        m_RandomizeJawButton._visible = false;
        
        
        if ( m_IsInitialized || m_CharacterCreationIF == undefined || !m_IsUILoaded )
        {
            return;
        }
        m_IsInitialized = true;

        var subHeaderTitleFormat = new TextFormat();
        
        subHeaderTitleFormat.align = "left";
        subHeaderTitleFormat.size = 11;
        
        m_BaseHeadSlider.minimum = 0;
        m_BaseHeadSlider.snapping = true;
        m_BaseHeadSlider.snapInterval = 1;
        m_BaseHeadSlider.addEventListener("change", this, "OnBaseHeadChanged");
        
        m_CharacterCreationIF.SignalGenderChanged.Connect( SlotGenderChanged, this );
        //SlotGenderChanged( m_CharacterCreationIF.GetGender() );

        m_CharacterCreationIF.SignalBaseHeadChanged.Connect( SlotBaseHeadChanged, this );
        SlotBaseHeadChanged( m_CharacterCreationIF.GetBaseHead() );
        
        m_CharacterCreationIF.SignalSkinColorChanged.Connect( SlotSkinColorChanged, this );
        SlotSkinColorChanged( m_CharacterCreationIF.GetSkinColorIndex() );
        
        m_CharacterCreationIF.SignalEyeColorChanged.Connect( SlotEyeColorChanged, this );
        SlotEyeColorChanged( m_CharacterCreationIF.GetEyeColorIndex() );
        
        m_CharacterCreationIF.SignalFacialFeatureChanged.Connect( SlotFacialFeatureChanged, this );
        
        m_FacialControllers = {};
        
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureEye]  = { m_RandomizeButton:m_RandomizeEyesButton,
                                                                                 m_Slider:m_EyesSlider,
                                                                                 m_LabelView:m_EyesTitle,
                                                                                 m_LabelString:LDBFormat.LDBGetText( "CharCreationGUI", "TitleEyesSection" ) + " #%.0f"
        };
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureNose] = { m_RandomizeButton:m_RandomizeNoseButton,
                                                                                 m_Slider:m_NoseSlider,
                                                                                 m_LabelView:m_NoseTitle,
                                                                                 m_LabelString:LDBFormat.LDBGetText( "CharCreationGUI", "TitleNoseSection" ) + " #%.0f"
        };
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureLip]  = { m_RandomizeButton:m_RandomizeLipsButton,
                                                                                 m_Slider:m_LipsSlider,
                                                                                 m_LabelView:m_LipsTitle,
                                                                                 m_LabelString:LDBFormat.LDBGetText( "CharCreationGUI", "TitleLipsSection" ) + " #%.0f"
        };
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureJaw]  = { m_RandomizeButton:m_RandomizeJawButton,
                                                                                 m_Slider:m_JawSlider,
                                                                                 m_LabelView:m_JawTitle,
                                                                                 m_LabelString:LDBFormat.LDBGetText( "CharCreationGUI", "TitleJawSection" ) + " #%.0f"
        };
        
        m_HeadTitle.textField.setTextFormat(subHeaderTitleFormat);
        m_HeadTitle.textField.setNewTextFormat(subHeaderTitleFormat);
        
        m_SkinColorHeader.textField.setTextFormat(subHeaderTitleFormat);
        m_SkinColorHeader.textField.setNewTextFormat(subHeaderTitleFormat);
        
        m_SkinColorHeader.text = LDBFormat.LDBGetText( "CharCreationGUI", "SkinColor" );
        
        SetupFacialSlider( _global.Enums.FacialFeature.e_FacialFeatureEye,  subHeaderTitleFormat );
        SetupFacialSlider( _global.Enums.FacialFeature.e_FacialFeatureNose, subHeaderTitleFormat );
        SetupFacialSlider( _global.Enums.FacialFeature.e_FacialFeatureLip,  subHeaderTitleFormat );
        SetupFacialSlider( _global.Enums.FacialFeature.e_FacialFeatureJaw,  subHeaderTitleFormat );

        
        m_RandomizeHeadButton.addEventListener("click", this, "OnRandomizeBaseHead");
        m_SkinColorList.addEventListener( "change", this, "OnSkinColorSelected" );
        m_EyeColorList.addEventListener( "change", this, "OnEyeColorSelected" );        
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
        m_RandomizeHeadButton.disabled = state;
        m_BaseHeadSlider.disabled = state;
        
        m_RandomizeSkinColorButton.disabled = state;
        m_SkinColorList.disabled = state;
        
        m_RandomizeEyesButton.disabled = state;
        m_EyesSlider.disabled = state;
        m_EyeColorList.disabled = state;
        
        m_RandomizeNoseButton.disabled = state;
        m_NoseSlider.disabled = state;
        
        m_RandomizeLipsButton.disabled = state;
        m_LipsSlider.disabled = state;
        
        m_JawTitle.disabled = state;
        m_RandomizeJawButton.disabled = state;
        m_JawSlider.disabled = state;

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
    
    private function SetColorSkin()
    {
        m_SkinColorList.dataProvider = [];

        for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetSkinColorIndexes().length ; ++i )
        {
            m_SkinColorList.dataProvider.push( { _color:m_CharacterCreationIF.GetSkinColorValue( i ) } );
        }
        
    }
    

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SetColorEye()
    {
        m_EyeColorList.dataProvider = [];

        for ( var i:Number = 0 ; i < m_CharacterCreationIF.GetEyeColorIndexes().length ; ++i )
        {
            m_EyeColorList.dataProvider.push( { _color:m_CharacterCreationIF.GetEyeColorValue( i ) } );
        }
    }


    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function SetupFacialSlider( feature:Number, titleFormat:TextFormat ) : Void
    {
        var facialFeatureNode = m_FacialControllers[ feature ]

        facialFeatureNode.m_LabelView.textField.setTextFormat( titleFormat );
        facialFeatureNode.m_LabelView.textField.setNewTextFormat( titleFormat );

        facialFeatureNode.m_Slider.minimum = 0;
        facialFeatureNode.m_Slider.maximum = m_CharacterCreationIF.GetFacialFeatureCount( feature ) - 1;
        
        facialFeatureNode.m_Slider.position = m_CharacterCreationIF.GetFacialFeature( feature );
        facialFeatureNode.m_Slider.snapping = true;
        facialFeatureNode.m_Slider.snapInterval = 1;
        facialFeatureNode.m_Slider.m_FeatureID = feature;
        
        facialFeatureNode.m_Slider.addEventListener("change", this, "OnFacialSliderChanged");


        facialFeatureNode.m_RandomizeButton.m_FeatureID = feature;
        facialFeatureNode.m_RandomizeButton.addEventListener("click", this, "OnRandomizeFacialFeature");

        UpdateFacialSliderLabel( feature );
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function UpdateFacialSliderLabel( feature:Number )
    {
        var labelNode:Object = m_FacialControllers[ feature ];
        labelNode.m_LabelView.text = Format.Printf( labelNode.m_LabelString, labelNode.m_Slider.position + 1 );
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function RandomizePanel()
    {
        OnRandomizeBaseHead();
        
        var skinColorIndexes:Array = m_CharacterCreationIF.GetSkinColorIndexes();
        var randomSkinColor:Number = Math.floor(Math.random() * skinColorIndexes.length);
        m_CharacterCreationIF.SetSkinColorIndex(skinColorIndexes[randomSkinColor]);
        
        for ( var i in m_FacialControllers )
        {
            RandomizeFacialFeature( m_FacialControllers[i].m_RandomizeButton.m_FeatureID );
        }
        
        var eyeColorIndexes:Array = m_CharacterCreationIF.GetEyeColorIndexes();
        var randomEyeColor:Number = Math.floor(Math.random() * eyeColorIndexes.length);
        m_CharacterCreationIF.SetEyeColorIndex(eyeColorIndexes[randomEyeColor]);
    }

    private function OnRandomizeBaseHead()
    {
        GUI.CharacterCreation.HeadSection.RandomizeSlider( m_BaseHeadSlider );
        m_CharacterCreationIF.SetBaseHead( m_BaseHeadSlider.position );
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function RandomizeFacialFeature(feature:Number)
    {
        var slider = m_FacialControllers[feature].m_Slider;
        
        GUI.CharacterCreation.HeadSection.RandomizeSlider( slider );
        m_CharacterCreationIF.SetFacialFeature( feature, slider.position );
        UpdateFacialSliderLabel( feature );
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnBaseHeadChanged( event:Object )
    {
        m_CharacterCreationIF.SetBaseHead( event.target.position );
    }


    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnRandomizeFacialFeature( event:Object )
    {
        var button = event.target;
        RandomizeFacialFeature( button.m_FeatureID );
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnFacialSliderChanged( event:Object )
    {
        var slider  = event.target;
        var feature = slider.m_FeatureID;

        UpdateFacialSliderLabel( feature );
        
        m_CharacterCreationIF.SetFacialFeature( feature, slider.position );
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function UpdateServerMorphValues()
    {
        m_CharacterCreationIF.SetSurgeryData(0);
        SignalSetSurgeryData.Emit();
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    private function OnSkinColorSelected( event:Object )
    {
        var indexes:Array = m_CharacterCreationIF.GetSkinColorIndexes();
        m_CharacterCreationIF.SetSkinColorIndex(indexes[event.index]);
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////

    private function OnEyeColorSelected( event:Object )
    {
        var indexes:Array = m_CharacterCreationIF.GetEyeColorIndexes();
        m_CharacterCreationIF.SetEyeColorIndex(indexes[event.index]);
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SlotGenderChanged( gender:Number )
    {        
        var baseHeadCount = m_CharacterCreationIF.GetBaseHeadCount();

        m_BaseHeadSlider.maximum = baseHeadCount - 1;

        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureEye].m_Slider.maximum = m_CharacterCreationIF.GetFacialFeatureCount(_global.Enums.FacialFeature.e_FacialFeatureEye) - 1;
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureNose].m_Slider.maximum = m_CharacterCreationIF.GetFacialFeatureCount(_global.Enums.FacialFeature.e_FacialFeatureNose) - 1;
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureLip].m_Slider.maximum = m_CharacterCreationIF.GetFacialFeatureCount(_global.Enums.FacialFeature.e_FacialFeatureLip) - 1;
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureJaw].m_Slider.maximum = m_CharacterCreationIF.GetFacialFeatureCount(_global.Enums.FacialFeature.e_FacialFeatureJaw) - 1;

        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureEye].m_Slider.position = m_CharacterCreationIF.GetFacialFeature( _global.Enums.FacialFeature.e_FacialFeatureEye );
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureNose].m_Slider.position = m_CharacterCreationIF.GetFacialFeature( _global.Enums.FacialFeature.e_FacialFeatureNose );
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureLip].m_Slider.position = m_CharacterCreationIF.GetFacialFeature( _global.Enums.FacialFeature.e_FacialFeatureLip );
        m_FacialControllers[_global.Enums.FacialFeature.e_FacialFeatureJaw].m_Slider.position = m_CharacterCreationIF.GetFacialFeature( _global.Enums.FacialFeature.e_FacialFeatureJaw );
        
        UpdateServerMorphValues();
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////

    public function SlotBaseHeadChanged( index:Number)
    {
        m_HeadTitle.text = Format.Printf( LDBFormat.LDBGetText( "CharCreationGUI", "TitleHeadSection" ) + " #%.0f", index + 1);
        m_BaseHeadSlider.position = index;
        
        SetColorSkin();
        SetColorEye();
        UpdateServerMorphValues();
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SlotSkinColorChanged( index:Number)
    {
        var indexes:Array = m_CharacterCreationIF.GetSkinColorIndexes();
        for (var i = 0; i < indexes.length; i++)
        {
            if (indexes[i] == index)
            {
                m_SkinColorList.selectedIndex = i;
                break;
            }
        }
        UpdateServerMorphValues();
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////

    public function SlotEyeColorChanged( index:Number )
    {
        var indexes:Array = m_CharacterCreationIF.GetEyeColorIndexes();
        for (var i = 0; i < indexes.length; i++)
        {
            if (indexes[i] == index)
            {
                m_EyeColorList.selectedIndex = i;
                break;
            }
        }
        UpdateServerMorphValues();
    }

    ////////////////////////////////////////////////////////////////////////////////
    ///
    ////////////////////////////////////////////////////////////////////////////////
    
    public function SlotFacialFeatureChanged( feature:Number, value:Number )
    {
        var node:Object = m_FacialControllers[ feature ];
        
        node.m_Slider.position = value;
        UpdateFacialSliderLabel( feature );
        UpdateServerMorphValues();
    }
}


