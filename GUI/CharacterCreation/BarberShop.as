//Imports
import com.Components.FCButton;
import com.GameInterface.Game.Character;
import com.GameInterface.Tooltip.*;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.core.UIComponent;
import mx.transitions.easing.*;
import mx.utils.Delegate;

//Class
dynamic class GUI.CharacterCreation.BarberShop extends UIComponent
{
    //Properties
    public var SignalBack:com.Utils.Signal;
    public var SignalForward:com.Utils.Signal;
    public var SignalBuyCoupon:com.Utils.Signal;
    
    private var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;

	private var m_HairMakeUp:MovieClip;
	private var m_HairStyleBackground:MovieClip;
	private var m_FacialFeatureBackground:MovieClip;
	private var m_RandomizeHairButton:FCButton;
	private var m_RandomizeFacialFeatureButton:MovieClip;
	
	private var m_CancelButton:MovieClip;
	private var m_AddCouponButton:MovieClip;
	private var m_ProceedButton:MovieClip;
	private var m_NavigationBar:MovieClip;
	
	private var m_Gender:Number;
	
	private var m_MonologSoundCoolDown:Boolean;	
	private var m_TimeCounter:Number;
    
    private var m_KeyListener:Object;
	
    //Constructor
    public function BarberShop()
    {
		m_MonologSoundCoolDown = false;
        SignalBack = new com.Utils.Signal;
        SignalForward = new com.Utils.Signal;
		SignalBuyCoupon = new com.Utils.Signal;
		
		m_Gender = m_CharacterCreationIF.GetGender();
        
        m_KeyListener = new Object();
        m_KeyListener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(m_KeyListener);
    }

    //Config UI
	private function configUI():Void
    {
		m_HairMakeUp.SetCharacterCreationIF( m_CharacterCreationIF );
		m_HairMakeUp.SignalBoxHeightChanged.Connect(LayoutHandler, this);
        m_HairMakeUp.SignalSetSurgeryData.Connect(UpdateProceedButton, this);
		
		m_CancelButton.m_BackwardArrow._alpha = 100;
		m_ProceedButton.m_ForwardArrow._alpha = 100;
        m_ProceedButton.disabled = true;
		
		m_FacialFeatureBackground = m_HairStyleBackground.duplicateMovieClip("m_HairStyleBackgroundCopy", m_HairStyleBackground.getDepth() + 1);
		m_RandomizeFacialFeatureButton = m_RandomizeHairButton.duplicateMovieClip("randomizeMakeupFeaturesButton", m_RandomizeHairButton.getDepth() + 1 );
		
		m_RandomizeHairButton.addEventListener("click", this, "RandomizeHairStyle");
		m_RandomizeFacialFeatureButton.addEventListener("click", this, "RandomizeFacialFeature");
		m_CancelButton.SignalButtonSelected.Connect(ExitBarberShop, this);
		m_AddCouponButton.SignalButtonSelected.Connect(BuyCoupon, this);
		m_ProceedButton.SignalButtonSelected.Connect(GoToPayment, this);
		
		m_HairMakeUp.m_HairStyleScrollingList.addEventListener("change", this, "PlayMonologSound");
		
		SetLabels();
		LayoutHandler();
    }
	
    //Play Monolog Sound
	private function PlayMonologSound():Void
	{
		var hitNumber = random( 100 );
		if ( hitNumber < 20 && m_MonologSoundCoolDown == false && m_TimeCounter == undefined )
		{	
			var character:Character = Character.GetClientCharacter();
			character.AddEffectPackage( "sound_fx_package_barber_shop_VO_during_cut.xml" );
			m_MonologSoundCoolDown = true;
			m_TimeCounter =  _global.setTimeout( this, 'DeactivateMonologSoundCoolDown', 7000 );
		}
	}
	
    //Deactivate Monolog Sound Cool Down
	private function DeactivateMonologSoundCoolDown():Void
	{
		_global.clearTimeout( m_TimeCounter );
		m_MonologSoundCoolDown = false;
		m_TimeCounter = undefined;
	}
	
    //Update Proceed Button
    private function UpdateProceedButton():Void
    {
        m_ProceedButton.disabled = !m_CharacterCreationIF.HasMorphChanges();
    }
    
    //Randomize Hair Style
	private function RandomizeHairStyle():Void
	{
		m_HairMakeUp.RandomizePanel();
	}
	
    //Randomize Facial Feature
	private function RandomizeFacialFeature():Void
	{
		m_HairMakeUp.OnRandomizeMakeupGlamour();
		m_HairMakeUp.OnRandomizeMakeupGlamourColor();
	}
	
    //Set Labels
	private function SetLabels():Void
	{
		m_RandomizeHairButton.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "RandomizeHairStyle" ));
		m_RandomizeFacialFeatureButton.SetTooltipText(LDBFormat.LDBGetText( "CharCreationGUI", "RandomizeFacialFeature" ));
		
		m_CancelButton.m_Label.text = LDBFormat.LDBGetText( "GenericGUI", "Cancel" );
		m_AddCouponButton.m_Label.text = LDBFormat.LDBGetText( "CharCreationGUI", "AddCoupons" );
		m_ProceedButton.m_Label.text = LDBFormat.LDBGetText( "GenericGUI", "Proceed" );
	}
	
    //Layout Handler
	public function LayoutHandler():Void
	{
		var yOffset:Number = 45;
		var leftSideX:Number = (Stage.width - m_HairMakeUp.m_EyebrowSlider._width) / 2 - ( Stage.width / 4) - 105;
		var rightSideX:Number = (Stage.width - m_HairMakeUp.m_EyebrowSlider._width) / 2 + ( Stage.width / 4) + 95;
		var rightSideHeight:Number;
		var leftSideHeight:Number;
		var leftSideY:Number;
		var rightSideY:Number;
		
		m_HairMakeUp.m_BeardMustacheHorizontalDivider._visible = false;
		
		m_NavigationBar._x  = 0;
		m_NavigationBar._y = Stage.height - m_NavigationBar._height + 2;
		m_NavigationBar._width = Stage.width + 2;
		m_CancelButton._x = 10;
		m_CancelButton._y = Stage.height - (m_NavigationBar._height / 2) - (m_CancelButton._height / 2) + 5;
		m_ProceedButton._y = m_CancelButton._y;
		m_ProceedButton._x = Stage.width - m_ProceedButton._width - 10;
		m_AddCouponButton._y = m_CancelButton._y;
		m_AddCouponButton._x = m_ProceedButton._x - m_AddCouponButton._width - 5;
		
		m_HairStyleBackground._x = leftSideX - 10;
		m_HairStyleBackground._width = m_HairMakeUp.m_EyebrowSlider._width + 30;
		
		m_FacialFeatureBackground._x = rightSideX - 10;
		m_FacialFeatureBackground._width = m_HairStyleBackground._width;
		
		var leftSideControllers:Array = [
											m_HairMakeUp.m_HairStyleTitle,
											m_HairMakeUp.m_HairStyleScrollingList,
											m_HairMakeUp.m_HairStyleBackground,
											m_HairMakeUp.m_HairColorList,
											m_HairMakeUp.m_HairstyleHorizontalDivider,
											
											m_HairMakeUp.m_FacialHairTitle,
											m_HairMakeUp.m_FacialHairColorList,
											m_HairMakeUp.m_UseHairColorCheckbox,
											m_HairMakeUp.m_UseHairColorCheckBoxBg,
											m_HairMakeUp.m_FacialHairHorizontalDivider,
											
											m_HairMakeUp.m_EyebrowTitle,
											m_HairMakeUp.m_EyebrowSlider,
											m_HairMakeUp.m_EyeBrowHorizontalDivider,
											
											m_HairMakeUp.m_BeardMustacheTitle,
											m_HairMakeUp.m_BeardMustacheScrollingList,
											m_HairMakeUp.m_BeardMustacheBackground
										]
		
		for (var i:Number = 0; i < leftSideControllers.length; i++)
		{
			leftSideControllers[i]._x = leftSideX;
		}
		
		var rightSideControllers:Array = [
											m_HairMakeUp.m_MakeupGlamourTitle,
											m_HairMakeUp.m_MakeupGlamourScrollingList,
											m_HairMakeUp.m_MakeupGlamourBackground,
											m_HairMakeUp.m_MakeupGlamourColorList
										]
		
		for (var i:Number = 0; i < rightSideControllers.length; i++)
		{
			rightSideControllers[i]._x = rightSideX;
		}
		
		rightSideHeight =	m_HairMakeUp.m_MakeupGlamourTitle._height
							+ m_HairMakeUp.m_MakeupGlamourBackground._height
							+ m_HairMakeUp.m_MakeupGlamourColorList._height
							+ 25;
		
		rightSideY = ( Stage.height - rightSideHeight) / 2 - yOffset;
		
		if ( m_Gender == _global.Enums.BreedSex.e_Sex_Female )
		{
			leftSideHeight =	m_HairMakeUp.m_HairStyleTitle._height
								+ m_HairMakeUp.m_HairStyleBackground._height
								+ m_HairMakeUp.m_HairColorList._height
								+ m_HairMakeUp.m_HairstyleHorizontalDivider._height
								+ m_HairMakeUp.m_FacialHairTitle._height
								+ m_HairMakeUp.m_FacialHairColorList._height
								+ m_HairMakeUp.m_UseHairColorCheckBoxBg._height
								+ m_HairMakeUp.m_FacialHairHorizontalDivider._height
								+ m_HairMakeUp.m_EyebrowTitle._height
								+ m_HairMakeUp.m_EyebrowSlider._height
								+ m_HairMakeUp.m_EyeBrowHorizontalDivider._height
								+ 30;
			
			leftSideY = ( Stage.height - leftSideHeight) / 2 - yOffset;
			
			m_HairMakeUp.m_HairStyleTitle._y = leftSideY + 10;
			m_HairMakeUp.m_HairStyleScrollingList._y = m_HairMakeUp.m_HairStyleTitle._y + m_HairMakeUp.m_HairStyleTitle._height;
			m_HairMakeUp.m_HairStyleScrollingList._height = 200;
			m_HairMakeUp.m_HairStyleBackground._height = m_HairMakeUp.m_HairStyleScrollingList._height;
			m_HairMakeUp.m_HairStyleBackground._y = m_HairMakeUp.m_HairStyleScrollingList._y;
			m_HairMakeUp.m_HairColorList._y = m_HairMakeUp.m_HairStyleBackground._y + m_HairMakeUp.m_HairStyleBackground._height + 4;
			m_HairMakeUp.m_HairstyleHorizontalDivider._y = m_HairMakeUp.m_HairColorList._y + m_HairMakeUp.m_HairColorList._height + 2;
			
			m_HairMakeUp.m_FacialHairTitle._y = m_HairMakeUp.m_HairstyleHorizontalDivider._y + m_HairMakeUp.m_HairstyleHorizontalDivider._height + 2;
			m_HairMakeUp.m_FacialHairColorList._y = m_HairMakeUp.m_FacialHairTitle._y + m_HairMakeUp.m_FacialHairTitle._height;
			m_HairMakeUp.m_UseHairColorCheckbox._y = m_HairMakeUp.m_FacialHairColorList._y + m_HairMakeUp.m_FacialHairColorList._height + 2;
			m_HairMakeUp.m_UseHairColorCheckBoxBg._y = m_HairMakeUp.m_UseHairColorCheckbox._y - 1;
			m_HairMakeUp.m_FacialHairHorizontalDivider._y = m_HairMakeUp.m_UseHairColorCheckBoxBg._y + m_HairMakeUp.m_UseHairColorCheckBoxBg._height + 2;
			
			m_HairMakeUp.m_EyebrowTitle._y = m_HairMakeUp.m_FacialHairHorizontalDivider._y + m_HairMakeUp.m_FacialHairHorizontalDivider._height + 2;
			m_HairMakeUp.m_EyebrowSlider._y = m_HairMakeUp.m_EyebrowTitle._y + m_HairMakeUp.m_EyebrowTitle._height + 2;
			
			m_HairMakeUp.m_EyeBrowHorizontalDivider._visible = false;
			
			m_HairMakeUp.m_BeardMustacheTitle._visible = false;
			m_HairMakeUp.m_BeardMustacheScrollingList._visible = false;
			m_HairMakeUp.m_BeardMustacheBackground._visible = false;
		}
		else 
		{
			m_HairMakeUp.m_EyeBrowHorizontalDivider._visible = true;
			m_HairMakeUp.m_BeardMustacheTitle._visible = true;
			m_HairMakeUp.m_BeardMustacheScrollingList._visible = true;
			m_HairMakeUp.m_BeardMustacheBackground._visible = true;
			
			leftSideHeight =	m_HairMakeUp.m_HairStyleTitle._height
								+ m_HairMakeUp.m_HairStyleBackground._height
								+ m_HairMakeUp.m_HairColorList._height
								+ m_HairMakeUp.m_HairstyleHorizontalDivider._height
								+ m_HairMakeUp.m_FacialHairTitle._height
								+ m_HairMakeUp.m_FacialHairColorList._height
								+ m_HairMakeUp.m_UseHairColorCheckBoxBg._height
								+ m_HairMakeUp.m_FacialHairHorizontalDivider._height
								+ m_HairMakeUp.m_EyebrowTitle._height
								+ m_HairMakeUp.m_EyebrowSlider._height
								+ m_HairMakeUp.m_EyeBrowHorizontalDivider._height
								+ m_HairMakeUp.m_BeardMustacheTitle._height
								+ m_HairMakeUp.m_BeardMustacheBackground._height
								+ 40;
			
			leftSideY = ( Stage.height - leftSideHeight) / 2 - yOffset;
			
			m_HairMakeUp.m_HairStyleTitle._y = leftSideY + 10;
			m_HairMakeUp.m_HairStyleScrollingList._y = m_HairMakeUp.m_HairStyleTitle._y + m_HairMakeUp.m_HairStyleTitle._height;
			m_HairMakeUp.m_HairStyleScrollingList._height = 200;
			m_HairMakeUp.m_HairStyleBackground._height = m_HairMakeUp.m_HairStyleScrollingList._height;
			m_HairMakeUp.m_HairStyleBackground._y = m_HairMakeUp.m_HairStyleScrollingList._y;
			m_HairMakeUp.m_HairColorList._y = m_HairMakeUp.m_HairStyleBackground._y + m_HairMakeUp.m_HairStyleBackground._height + 4;
			m_HairMakeUp.m_HairstyleHorizontalDivider._y = m_HairMakeUp.m_HairColorList._y + m_HairMakeUp.m_HairColorList._height + 2;
			
			m_HairMakeUp.m_FacialHairTitle._y = m_HairMakeUp.m_HairstyleHorizontalDivider._y + m_HairMakeUp.m_HairstyleHorizontalDivider._height + 2;
			m_HairMakeUp.m_FacialHairColorList._y = m_HairMakeUp.m_FacialHairTitle._y + m_HairMakeUp.m_FacialHairTitle._height;
			m_HairMakeUp.m_UseHairColorCheckbox._y = m_HairMakeUp.m_FacialHairColorList._y + m_HairMakeUp.m_FacialHairColorList._height + 2;
			m_HairMakeUp.m_UseHairColorCheckBoxBg._y = m_HairMakeUp.m_UseHairColorCheckbox._y - 1;
			m_HairMakeUp.m_FacialHairHorizontalDivider._y = m_HairMakeUp.m_UseHairColorCheckBoxBg._y + m_HairMakeUp.m_UseHairColorCheckBoxBg._height + 2;
			
			m_HairMakeUp.m_EyebrowTitle._y = m_HairMakeUp.m_FacialHairHorizontalDivider._y + m_HairMakeUp.m_FacialHairHorizontalDivider._height + 2;
			m_HairMakeUp.m_EyebrowSlider._y = m_HairMakeUp.m_EyebrowTitle._y + m_HairMakeUp.m_EyebrowTitle._height + 2;
			
			m_HairMakeUp.m_EyeBrowHorizontalDivider._y = m_HairMakeUp.m_EyebrowSlider._y + m_HairMakeUp.m_EyebrowSlider._height + 2;
			m_HairMakeUp.m_BeardMustacheTitle._y = m_HairMakeUp.m_EyeBrowHorizontalDivider._y + m_HairMakeUp.m_EyeBrowHorizontalDivider._height + 2;
			m_HairMakeUp.m_BeardMustacheScrollingList._y = m_HairMakeUp.m_BeardMustacheTitle._y + m_HairMakeUp.m_BeardMustacheTitle._height;
			m_HairMakeUp.m_BeardMustacheScrollingList._height = 200;
			m_HairMakeUp.m_BeardMustacheBackground._y = m_HairMakeUp.m_BeardMustacheScrollingList._y;
			m_HairMakeUp.m_BeardMustacheBackground._height = m_HairMakeUp.m_BeardMustacheScrollingList._height;
			
			m_HairStyleBackground._height = leftSideHeight;
		}
		
		m_HairMakeUp.m_MakeupGlamourScrollingList._height = m_HairMakeUp.GetFacialFeatureMakeUpHeight();
		m_HairMakeUp.m_MakeupGlamourBackground._height = m_HairMakeUp.m_MakeupGlamourScrollingList._height;
		
		m_HairMakeUp.m_MakeupGlamourTitle._y = rightSideY + 10;
		m_HairMakeUp.m_MakeupGlamourScrollingList._y = m_HairMakeUp.m_MakeupGlamourTitle._y + m_HairMakeUp.m_MakeupGlamourTitle._height;
		m_HairMakeUp.m_MakeupGlamourBackground._y = m_HairMakeUp.m_MakeupGlamourScrollingList._y;
		m_HairMakeUp.m_MakeupGlamourColorList._y = m_HairMakeUp.m_MakeupGlamourScrollingList._y + m_HairMakeUp.m_MakeupGlamourScrollingList._height + 5;
		
		m_HairStyleBackground._height = leftSideHeight;
		m_HairStyleBackground._y = leftSideY;
		m_FacialFeatureBackground._height = rightSideHeight;
		m_FacialFeatureBackground._y = rightSideY;
		
		m_RandomizeHairButton._x = m_HairStyleBackground._x + m_HairStyleBackground._width - m_RandomizeHairButton._width - 5;
		m_RandomizeHairButton._y = m_HairStyleBackground._y + m_HairStyleBackground._height + 5;
		
		m_RandomizeFacialFeatureButton._x = m_FacialFeatureBackground._x + 5;
		m_RandomizeFacialFeatureButton._y = m_FacialFeatureBackground._y + m_FacialFeatureBackground._height + 5;
	}
	
    //Exit Barber Shop
	private function ExitBarberShop():Void
	{
		this.SignalBack.Emit();
	}
	
    //Go To Payment
	private function GoToPayment():Void
	{
		this.SignalForward.Emit();
		
		m_RandomizeHairButton.disabled = true;
		m_RandomizeFacialFeatureButton.disabled = true;
		m_ProceedButton.disabled = true;
		
		m_HairMakeUp.Disable(true);
		
		m_HairMakeUp._alpha = 50;
		m_HairStyleBackground._alpha = 50;
		m_FacialFeatureBackground._alpha = 50; 
	}
	
    //Cancel Payment
	public function CancelPayment():Void
	{
		m_RandomizeHairButton.disabled = false;
		m_RandomizeFacialFeatureButton.disabled = false;
		UpdateProceedButton();
		
		m_HairMakeUp.Disable(false);
		
		m_HairMakeUp._alpha = 100;
		m_HairStyleBackground._alpha = 100;
		m_FacialFeatureBackground._alpha = 100;
	}
	
    //Buy Coupon
	private function BuyCoupon():Void
	{
		this.SignalBuyCoupon.Emit();
	}

    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        switch(Key.getCode())
        {
            case Key.ESCAPE:    ExitBarberShop();
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