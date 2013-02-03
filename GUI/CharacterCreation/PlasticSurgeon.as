//Imports
import com.Components.FCButton;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.*;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.core.UIComponent;
import gfx.controls.Slider;
import mx.transitions.easing.*;
import mx.utils.Delegate;

//Class
dynamic class GUI.CharacterCreation.PlasticSurgeon extends UIComponent
{
    //Properties
    public var SignalBack:com.Utils.Signal;
    public var SignalForward:com.Utils.Signal;
    public var SignalBuyCoupon:com.Utils.Signal;
    
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
    
    private var m_WindowTitle:MovieClip;
    private var m_TopHorizontalDivider:MovieClip;
    
    private var m_FacialFeatures:MovieClip;
    private var m_FacialFeaturesBackground:MovieClip;
    private var m_CharacterSizeSliderLabel:MovieClip;
    private var m_CharacterSizeSlider:Slider;
    private var m_RandomizeButton:FCButton;
    
    private var m_CancelButton:MovieClip;
    private var m_AddCouponButton:MovieClip;
    private var m_ProceedButton:MovieClip;
    private var m_NavigationBar:MovieClip;
    
    private var m_InitialHeight:Number;
    
    private var m_KeyListener:Object;
    
    //Constructor
    public function PlasticSurgeon()
    {
        SignalBack = new com.Utils.Signal;
        SignalForward = new com.Utils.Signal;
        SignalBuyCoupon = new com.Utils.Signal;
        
        m_KeyListener = new Object();
        m_KeyListener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(m_KeyListener);
    }

    //Config UI
    private function configUI():Void
    {
        m_FacialFeatures.SetCharacterCreationIF(m_CharacterCreationIF);
        m_FacialFeatures.SignalSetSurgeryData.Connect(UpdateProceedButton, this);
        
        m_CancelButton.m_BackwardArrow._alpha = 100;
        m_ProceedButton.m_ForwardArrow._alpha = 100;
        m_ProceedButton.disabled = true;
        
        m_WindowTitle = attachMovie("TitleLabel", "m_WindowTitle", this.getNextHighestDepth())
        m_TopHorizontalDivider = attachMovie("HorizontalDivider", "m_TopHorizontalDivider", this.getNextHighestDepth())
        
        m_RandomizeButton.addEventListener("click", this, "RandomizeFacialFeature");
        m_CancelButton.SignalButtonSelected.Connect(ExitPlasticSurgeon, this);
        m_AddCouponButton.SignalButtonSelected.Connect(BuyCoupon, this);
        m_ProceedButton.SignalButtonSelected.Connect(GoToPayment, this);
        
        m_CharacterSizeSlider.minimum = m_CharacterCreationIF.GetCharacterMinScale();
        m_CharacterSizeSlider.maximum = m_CharacterCreationIF.GetCharacterMaxScale();
        m_InitialHeight = m_CharacterCreationIF.GetCharacterScale();
        m_CharacterSizeSlider.value = m_InitialHeight;
        m_CharacterSizeSlider.liveDragging = true;
        m_CharacterSizeSlider.addEventListener( "change", this, "OnCharacterSizeSliderChanged" );
        
        m_CharacterCreationIF.SignalCharacterScaleChanged.Connect( SlotCharacterScaleChanged, this );
        SlotCharacterScaleChanged( m_CharacterCreationIF.GetCharacterScale() );
        
        SetLabels();
        LayoutHandler();
    }
    
    //Randomize Facial Feature
    private function RandomizeFacialFeature():Void
    {
        m_FacialFeatures.RandomizePanel();
    }
    
    //Set labels
    private function SetLabels():Void
    {
        m_WindowTitle.text = LDBFormat.LDBGetText( "CharCreationGUI", "FacialTraits" );
        m_CharacterSizeSliderLabel.text = LDBFormat.LDBGetText( "CharCreationGUI", "CharacterSizeLabel" );
        
        
        m_RandomizeButton.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "Tooltip_RandomizeFacialFeature" ));
        
        m_CancelButton.m_Label.text = LDBFormat.LDBGetText( "GenericGUI", "Cancel" );
        m_AddCouponButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "AddCoupons" );
        m_ProceedButton.m_Label.text = LDBFormat.LDBGetText( "GenericGUI", "Proceed" );
    }
    
    //Layout Handler
    public function LayoutHandler():Void
    {
        m_NavigationBar._x  = 0;
        m_NavigationBar._y = Stage.height - m_NavigationBar._height + 2;
        m_NavigationBar._width = Stage.width + 2;
        m_CancelButton._x = 10;
        m_CancelButton._y = Stage.height - (m_NavigationBar._height / 2) - (m_CancelButton._height / 2) + 5;
        m_ProceedButton._y = m_CancelButton._y;
        m_ProceedButton._x = Stage.width - m_ProceedButton._width - 10;
        m_AddCouponButton._y = m_CancelButton._y;
        m_AddCouponButton._x = m_ProceedButton._x - m_AddCouponButton._width - 5;
        
        m_FacialFeaturesBackground._width = m_FacialFeatures._width + 20;
        m_FacialFeaturesBackground._height = m_FacialFeatures._height + 50;
        m_FacialFeaturesBackground._x = (Stage.width - m_FacialFeaturesBackground._width) / 2 - (Stage.width / 4) - 95;
        m_FacialFeaturesBackground._y = (Stage.height - m_FacialFeaturesBackground._height) / 2 - m_NavigationBar._height;
        
        CenterHorizontal(m_CharacterSizeSlider);
        m_CharacterSizeSlider._y = m_NavigationBar._y - m_CharacterSizeSlider._height - 10;
        //CenterHorizontal(m_CharacterSizeSliderLabel);
        m_CharacterSizeSliderLabel._y = m_CharacterSizeSlider._y - 3;
        m_CharacterSizeSliderLabel._x = m_CharacterSizeSlider._x - m_CharacterSizeSliderLabel._width -7;
        
        m_FacialFeatures._x = m_FacialFeaturesBackground._x + 12;
        m_FacialFeatures._y = m_FacialFeaturesBackground._y + 38;
        
        m_WindowTitle._width = m_FacialFeaturesBackground._width - 20;
        m_WindowTitle._x = m_FacialFeatures._x + 6;
        m_WindowTitle._y = m_FacialFeaturesBackground._y + 10;
        
        m_TopHorizontalDivider._x = m_FacialFeatures._x;
        m_TopHorizontalDivider._y = m_WindowTitle._y + m_WindowTitle._height + 2;
        
        m_RandomizeButton.disableFocus = true;
        m_RandomizeButton._x = m_FacialFeaturesBackground._x + m_FacialFeaturesBackground._width - m_RandomizeButton._width - 5;
        m_RandomizeButton._y = m_FacialFeaturesBackground._y + m_FacialFeaturesBackground._height + 5;
    }
    
    private function CenterHorizontal(component:MovieClip)
    {
        component._x = (Stage.width/2) - (component._width/2)
    }
    
    //Exit Plastic Surgeon
    private function ExitPlasticSurgeon():Void
    {
        this.SignalBack.Emit();
    }
    
    //Go To Payment
    private function GoToPayment():Void
    {
        this.SignalForward.Emit();
        
        m_RandomizeButton.disabled = true;
        m_ProceedButton.disabled = true;
        
        m_FacialFeatures.Disable(true);
        
        m_FacialFeatures._alpha = 50;
        m_FacialFeaturesBackground._alpha = 50;
    }
    
    //Cancel Payment
    public function CancelPayment():Void
    {
        m_RandomizeButton.disabled = false;
        UpdateProceedButton();
        
        m_FacialFeatures.Disable(false);
        
        m_FacialFeatures._alpha = 100;
        m_FacialFeaturesBackground._alpha = 100;
    }
    
    //Buy Coupon
    private function BuyCoupon():Void
    {
        this.SignalBuyCoupon.Emit();
    }
    
    //Update Proceed Button
    private function UpdateProceedButton():Void
    {
        m_ProceedButton.disabled = ( m_CharacterSizeSlider.value == m_InitialHeight && !m_CharacterCreationIF.HasMorphChanges() );
    }
    
    private function SlotCharacterScaleChanged( value:Number )
    {
        m_CharacterSizeSlider.value = value;
        UpdateProceedButton();
    }
    
    private function OnCharacterSizeSliderChanged()
    {
        m_CharacterCreationIF.SetCharacterScale( m_CharacterSizeSlider.value );
    }
    
    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        switch(Key.getCode())
        {
            case Key.ESCAPE:    ExitPlasticSurgeon();
                                break;

            case Key.ENTER:     if (!m_ProceedButton.disabled)
                                {
                                    GoToPayment();  
                                }
                                
                                break;
        }
    }
    
    //On Unload
    private function onUnload():Void
    {
        Key.removeListener(m_KeyListener);
    }
}
