import com.GameInterface.MathLib.Vector3;
import com.GameInterface.Game.Character;
import com.GameInterface.AccountManagement;
import com.Utils.LDBFormat;
import GUI.CharacterCreation.CameraController;
import mx.utils.Delegate;
import flash.geom.Point;
import com.GameInterface.Utils;
import com.Components.WinComp;
import com.GameInterface.Game.Camera;
import com.GameInterface.DistributedValue;

var m_HitArea:MovieClip;

var m_WasHit:Boolean;
var m_HitPos:Point;
var m_LastPos:Point;

var m_FactionSelector:GUI.CharacterCreation.FactionSelector;
var m_BodyEditor:GUI.CharacterCreation.CharacterEditor;
var m_NameEditor:GUI.CharacterCreation.NameEditor;
var m_BarberShop:GUI.CharacterCreation.BarberShop;
var m_PlasticSurgeon:GUI.CharacterCreation.PlasticSurgeon;

var e_ModeFactionSelection:Number = 0;
var e_ModeBody:Number = 1;
var e_ModeNaming:Number = 2;
var e_ModeBarberShop:Number = 3;
var e_ModePlasticSurgeon:Number = 4;
var e_ModeCount:Number = 5;

var m_CharacterCreationIF:com.GameInterface.CharacterCreation.CharacterCreation;
var m_CameraController:CameraController;
var m_CurrentFaction:Number = -1;
var m_CurrentCharRotation:Number = 0;
var m_CurrentCharPosition:Vector3 = new Vector3(0,0,0);
var m_LastFrameTime:Number;
var m_IsSurgery:Boolean = false;
var m_CharacterEditMode:Number = 0;

// surgery
var m_SurgeryCameraYaw:Number = undefined;
var m_SurgeryCameraPitch:Number = undefined;
var m_SurgeryCameraDistance:Number = 0.6;
var m_SurgeryCameraDistanceMin:Number = 0.5;
var m_SurgeryCameraDistanceMax:Number = 1.1;
var m_SurgeryCameraHeightOffset:Number = 0.0;
var m_SurgeryCameraForwardOffset:Number = 0.0;
var m_SurgeryCameraMinMaxModifier:Number = 0.75;

var m_CurrentDialog:WinComp;

var m_ItemShopMonitor:DistributedValue;

function ResizeHandler( h, w ,x, y )
{
	if ( m_FactionSelector != undefined )
	{
		m_FactionSelector._x =  Stage["visibleRect"].x; 
		m_FactionSelector._y = Stage["visibleRect"].y;
		m_FactionSelector.LayoutHandler();
	}
	
	if ( m_BodyEditor != undefined )
	{
		m_BodyEditor._x =  Stage["visibleRect"].x; 
		m_BodyEditor._y = Stage["visibleRect"].y;
		m_BodyEditor.LayoutHandler();
	}
	
	if ( m_NameEditor != undefined )
	{
		m_NameEditor._x =  Stage["visibleRect"].x; 
		m_NameEditor._y = Stage["visibleRect"].y;
		m_NameEditor.LayoutHandler();
	}
	
	if ( m_BarberShop != undefined )
	{
		m_BarberShop._x =  Stage["visibleRect"].x; 
		m_BarberShop._y = Stage["visibleRect"].y;
		m_BarberShop.LayoutHandler();
	}
	
	if ( m_PlasticSurgeon != undefined )
	{
		m_PlasticSurgeon._x =  Stage["visibleRect"].x; 
		m_PlasticSurgeon._y = Stage["visibleRect"].y;
		m_PlasticSurgeon.LayoutHandler();
	}
	
	if (m_CurrentDialog != undefined)
	{
		m_CurrentDialog._x = (Stage.width - m_CurrentDialog._width) / 2 + 15;
		m_CurrentDialog._y = (Stage.height - m_CurrentDialog._height) / 2 + 15;
	}
}	

var m_FactionCharacterPositions:Object = {};

function onLoad():Void
{
	m_ItemShopMonitor = DistributedValue.Create("itemshop_window");
}

function LoadArgumentsReceived(args:Array)
{
	m_CharacterEditMode = args[0];
	
	var clientChar:Character = Character.GetClientCharacter();

    m_IsSurgery = m_CharacterEditMode != undefined && m_CharacterEditMode != 0;
    
    m_LastFrameTime = getTimer() / 1000;
    
    m_HitPos = new Point(0,0);
    m_LastPos = new Point(0,0);
    m_WasHit = false;
		
    m_HitArea._x = 0;
    m_HitArea._y = 0;
    m_HitArea._width = Stage.width;
    m_HitArea._height = Stage.height;
    m_HitArea.onPress          = Delegate.create( this, OnPress );
    m_HitArea.onRelease        = Delegate.create( this, OnRelease );
    m_HitArea.onReleaseOutside = Delegate.create( this, OnRelease );
    m_HitArea.onMouseMove      = Delegate.create( this, OnMouseMove );
	
	var radius:Number = 5;

	m_CharacterCreationIF = new com.GameInterface.CharacterCreation.CharacterCreation( m_IsSurgery/*, 4445240, _global.Enums.BreedSex.e_Sex_Female, _global.Enums.Factions.e_FactionTemplar*/ );

    m_CharacterCreationIF.SetGender( _global.Enums.BreedSex.e_Sex_Female );

    if ( !m_IsSurgery )
    {
        m_FactionCharacterPositions[_global.Enums.Factions.e_FactionIlluminati] = m_CharacterCreationIF.GetFactionCharacterLocation( _global.Enums.Factions.e_FactionIlluminati );
        m_FactionCharacterPositions[_global.Enums.Factions.e_FactionDragon]     = m_CharacterCreationIF.GetFactionCharacterLocation( _global.Enums.Factions.e_FactionDragon );
        m_FactionCharacterPositions[_global.Enums.Factions.e_FactionTemplar]    = m_CharacterCreationIF.GetFactionCharacterLocation( _global.Enums.Factions.e_FactionTemplar );
    }
    else
    {
        m_FactionCharacterPositions[_global.Enums.Factions.e_FactionIlluminati] = clientChar.GetPosition(_global.Enums.AttractorPlace.e_Ground);
        m_FactionCharacterPositions[_global.Enums.Factions.e_FactionDragon]     = clientChar.GetPosition(_global.Enums.AttractorPlace.e_Ground);
        m_FactionCharacterPositions[_global.Enums.Factions.e_FactionTemplar]    = clientChar.GetPosition(_global.Enums.AttractorPlace.e_Ground);
    }
    
    var cameraPos:Vector3 = new Vector3(0,0,0);

    for ( i in m_FactionCharacterPositions )
    {
        cameraPos = Vector3.Add( cameraPos, m_FactionCharacterPositions[i] );
    }
    cameraPos.x /= 3;
    cameraPos.y /= 3;
    cameraPos.z /= 3;

    m_CurrentCharPosition = m_FactionCharacterPositions[_global.Enums.Factions.e_FactionTemplar];
    m_CurrentCharRotation = m_CharacterCreationIF.GetFactionCharacterRotation( _global.Enums.Factions.e_FactionTemplar );
    
    var character:Character = m_CharacterCreationIF.GetCharacter();
    
    m_CameraController = new CameraController( CameraController.e_ModeBody );
    m_CameraController.SetCameraPosition( cameraPos );
    m_CameraController.SetZoomMode( CameraController.e_ModeBody, 0 );
	Mouse.addListener(this);
	
	m_FactionSelector._x =  Stage["visibleRect"].x; 
	m_FactionSelector._y = Stage["visibleRect"].y;

	var state:Number = e_ModeFactionSelection;
	if (m_CharacterEditMode == _global.Enums.CharacterEditMode.e_CharacterEditMode_BarberShop)
	{
		state = e_ModeBarberShop;
	}
	else if(m_CharacterEditMode == _global.Enums.CharacterEditMode.e_CharacterEditMode_PlasticSurgery)
	{
		state = e_ModePlasticSurgeon;
	}
    SetState( state );
	
	//SetState(m_IsSurgery ? e_ModePlasticSurgeon : e_ModeFactionSelection);
    
    m_CharacterCreationIF.SignalNameSuggestionReceived.Connect( SlotNickNameSuggestionReceived, this );
    m_CharacterCreationIF.SignalCreateCharacterSucceded.Connect( SlotCreateCharacterSucceded, this );
    m_CharacterCreationIF.SignalCreateCharacterFailed.Connect( SlotCreateCharacterFailed, this );

    AccountManagement.GetInstance().SignalLoginStateChanged.Connect(SlotLoginStateChanged, this);
    SlotLoginStateChanged( AccountManagement.GetInstance().GetLoginState() );
}

function onUnload()
{
	Selection.setFocus( null );
}

function OnPress()
{
	m_HitPos.x = _root._xmouse;
	m_HitPos.y = _root._ymouse;
    m_LastPos.x = m_HitPos.x;
    m_LastPos.y = m_HitPos.y;
	m_WasHit = true;
}
   
function OnRelease()
{
	m_WasHit = false;
}

function OnMouseMove()
{
	if ( m_WasHit )
	{
        var deltaX = m_LastPos.x - _root._xmouse;
        var deltaY = m_LastPos.y - _root._ymouse;
		
		if ( Math.abs(deltaX) > Math.abs(deltaY) ) { deltaY = 0; }
		else { deltaX = 0; }
		
		switch(m_CurrentMode)
		{
			case e_ModeBody:
				RotateCharacter( deltaX * 0.01 );
				PanCamera( deltaY );
				break;
			case e_ModeBarberShop:
			case e_ModePlasticSurgeon:
				m_SurgeryCameraYaw = m_SurgeryCameraYaw -= (deltaX * 0.005);
				m_SurgeryCameraPitch = m_SurgeryCameraPitch -= (deltaY * 0.005);
				switch(m_CurrentMode)
				{
					case e_ModeBarberShop:
						m_SurgeryCameraPitch = Math.min(Math.PI/2-0.45, m_SurgeryCameraPitch);
						m_SurgeryCameraPitch = Math.max( -0.5, m_SurgeryCameraPitch);
                        break;
					case e_ModePlasticSurgeon:
						m_SurgeryCameraPitch = Math.min(Math.PI - m_SurgeryCameraMinMaxModifier, m_SurgeryCameraPitch);
						m_SurgeryCameraPitch = Math.max(m_SurgeryCameraMinMaxModifier, m_SurgeryCameraPitch);
						m_SurgeryCameraYaw = Math.min(Math.PI - m_SurgeryCameraMinMaxModifier, m_SurgeryCameraYaw);
						m_SurgeryCameraYaw = Math.max(m_SurgeryCameraMinMaxModifier, m_SurgeryCameraYaw);
                        break;
				}
				PositionSurgeryCamera();
				break;
		}

		
		m_LastPos.x = _root._xmouse;
		m_LastPos.y = _root._ymouse;
	}
} 

function PositionSurgeryCamera()
{
	var character:Character = m_CharacterCreationIF.GetCharacter();
	if ( character != undefined)
	{
		var targetHeadPos:Vector3 = character.GetPosition( _global.Enums.AttractorPlace.e_Audio_Voice );
		
		var rotation:Number = character.GetRotation();
		targetHeadPos.x -= m_SurgeryCameraForwardOffset * Math.sin(rotation);
		targetHeadPos.z -= m_SurgeryCameraForwardOffset * Math.cos(rotation);
		targetHeadPos.y += m_SurgeryCameraHeightOffset;
		
		if (m_SurgeryCameraPitch == undefined || m_SurgeryCameraPitch == NaN ||
		      m_SurgeryCameraYaw == undefined ||   m_SurgeryCameraYaw == NaN)
		{
			if (m_CurrentMode == e_ModeBarberShop)
			{
				m_SurgeryCameraPitch = 0.40;
				m_SurgeryCameraYaw = (Math.PI - rotation) + Math.PI + 0.65;
			}
			else
			{
				m_SurgeryCameraPitch = Math.PI/2;
				m_SurgeryCameraYaw = Math.PI/2;
			}
		}
		
		var cameraPos:Vector3;
		var up:Vector3;
		if (m_CurrentMode == e_ModeBarberShop)
		{
			cameraPos = new Vector3(targetHeadPos.x + m_SurgeryCameraDistance * Math.cos(m_SurgeryCameraPitch) * Math.sin(m_SurgeryCameraYaw),
									targetHeadPos.y + m_SurgeryCameraDistance * Math.sin(m_SurgeryCameraPitch),
									targetHeadPos.z + m_SurgeryCameraDistance * Math.cos(m_SurgeryCameraPitch) * Math.cos(m_SurgeryCameraYaw));
            up = new Vector3(0,1,0);
		}
		else
		{
			cameraPos = new Vector3(targetHeadPos.x -
			                        m_SurgeryCameraDistance * Math.cos(m_SurgeryCameraYaw) * Math.cos(rotation) -
									m_SurgeryCameraDistance * Math.cos(m_SurgeryCameraPitch) * Math.sin(rotation),
			
									targetHeadPos.y + m_SurgeryCameraDistance * Math.sin(m_SurgeryCameraYaw) * Math.sin(m_SurgeryCameraPitch),
									
									targetHeadPos.z -
									m_SurgeryCameraDistance * Math.cos(m_SurgeryCameraYaw) * Math.sin(rotation) +
									m_SurgeryCameraDistance * Math.cos(m_SurgeryCameraPitch) * Math.cos(rotation));	
									
			up = new Vector3(Math.sin(rotation),0,-Math.cos(rotation));
		}
		
		Camera.PlaceCamera( cameraPos.x, cameraPos.y, cameraPos.z, targetHeadPos.x, targetHeadPos.y, targetHeadPos.z, up.x, up.y, up.z );
		Camera.SetFOV( 60 * 2 * Math.PI / 360 /*fov*/ );
	}
}

function onMouseWheel(delta:Number)
{
	if (Mouse["IsMouseOver"](m_HitArea))
	{
		switch(m_CurrentMode)
		{
			case e_ModeBody:
				m_CameraController.MouseWheel( delta );
				break;
			case e_ModeBarberShop:
			case e_ModePlasticSurgeon:
				m_SurgeryCameraDistance -= delta * 0.05;
				m_SurgeryCameraDistance = Math.max(m_SurgeryCameraDistanceMin, Math.min(m_SurgeryCameraDistanceMax, m_SurgeryCameraDistance));
				PositionSurgeryCamera();
				break;
		}
	}
}

function onEnterFrame()
{
	if (m_CurrentMode == e_ModeBody)
	{
		var curTime:Number = getTimer() / 1000;
		var deltaTime = curTime - m_LastFrameTime;
		m_LastFrameTime = curTime;

		var character:Character = m_CharacterCreationIF.GetCharacter();
		if ( character )
		{
			character.SetRotation( m_CurrentCharRotation );
			character.SetPosition( m_CurrentCharPosition );
			m_CameraController.UpdateTargetPositions( character );
			m_CameraController.FrameProcess();
		}
	}
	else if (m_CurrentMode == e_ModeBarberShop || m_CurrentMode == e_ModePlasticSurgeon)
	{
		PositionSurgeryCamera();
	}
}

function SetState( mode:Number )
{
    if ( m_CurrentPanel )
    {
        m_IsPanelFading
        m_CurrentPanel.tweenTo( 1, { _alpha:0 }, Strong.easeIn );
        m_CurrentPanel.onTweenComplete = function() { this.removeMovieClip(); }      
        m_CurrentPanel = undefined;
    }
    switch( mode )
    {
      case e_ModeFactionSelection:
          m_FactionSelector = this.attachMovie( "FactionSelector", "CC_Panel" + UID(), this.getNextHighestDepth(), { m_CharacterCreationIF:m_CharacterCreationIF } );
          m_CurrentPanel = m_FactionSelector;
          m_FactionSelector.SignalFactionSelected.Connect( SlotFactionSelected, this );
          m_FactionSelector._x =  Stage["visibleRect"].x; 
          m_FactionSelector._y = Stage["visibleRect"].y;

          break;
          
      case e_ModeBody:
          m_BodyEditor = this.attachMovie( "CharacterEditor", "CC_Panel" + UID(), this.getNextHighestDepth(), { m_CharacterCreationIF:m_CharacterCreationIF, m_CameraController:m_CameraController } );
          m_CurrentPanel = m_BodyEditor;
          m_CurrentPanel.SignalBack.Connect( SlotBackward, this );
          m_CurrentPanel.SignalForward.Connect( SlotForward, this );
          
          m_BodyEditor._x = Stage["visibleRect"].x;
          m_BodyEditor._y = Stage["visibleRect"].y;
          break;
		  
      case e_ModeNaming:
          m_NameEditor = this.attachMovie( "NameEditor", "CC_Panel" + UID(), this.getNextHighestDepth(), { m_CharacterCreationIF:m_CharacterCreationIF, m_CameraController:m_CameraController } );
          m_CurrentPanel = m_NameEditor;
          m_CurrentPanel.SignalBack.Connect( SlotBackward, this );
          m_CurrentPanel.SignalForward.Connect( SlotForward, this );
          
          m_NameEditor._x = Stage["visibleRect"].x;
          m_NameEditor._y = Stage["visibleRect"].y;

          m_CharacterCreationIF.RequestNameSuggestion( _global.Enums.BreedName.e_Name_Nick );
          break;
		  
	  case e_ModeBarberShop:
          m_BarberShop = this.attachMovie( "BarberShop", "CC_Panel" + UID(), this.getNextHighestDepth(), { m_CharacterCreationIF:m_CharacterCreationIF, m_CameraController:m_CameraController } );
          m_CurrentPanel = m_BarberShop;
          m_CurrentPanel.SignalBack.Connect( SlotBackward, this );
          m_CurrentPanel.SignalForward.Connect( SlotForward, this );
          m_CurrentPanel.SignalBuyCoupon.Connect( SlotBuyCoupon, this );
          
          m_BarberShop._x = Stage["visibleRect"].x;
          m_BarberShop._y = Stage["visibleRect"].y;
		  
          break;
		  
	  case e_ModePlasticSurgeon:
          m_PlasticSurgeon = this.attachMovie( "PlasticSurgeon", "CC_Panel" + UID(), this.getNextHighestDepth(), { m_CharacterCreationIF:m_CharacterCreationIF, m_CameraController:m_CameraController } );
          m_CurrentPanel = m_PlasticSurgeon;
          m_CurrentPanel.SignalBack.Connect( SlotBackward, this );
          m_CurrentPanel.SignalForward.Connect( SlotForward, this );
          m_CurrentPanel.SignalBuyCoupon.Connect( SlotBuyCoupon, this );
          
          m_PlasticSurgeon._x = Stage["visibleRect"].x;
          m_PlasticSurgeon._y = Stage["visibleRect"].y;
		  
          break;
    }
	
    if ( m_CurrentPanel )
    {
        m_CurrentPanel._alpha = 0;
        m_CurrentPanel.tweenTo( 0.8, { _alpha:100 }, Strong.easeOut );
    }    
    m_CurrentMode = mode;
}

function SlotLoginStateChanged( state:Number )
{
    if ( state < _global.Enums.LoginState.e_LoginStateWaitingForGameServerConnection )
    {
        UnloadClip();
    }
}

function SlotBuyCoupon()
{
	DistributedValue.SetDValue("itemshop_window", !DistributedValue.GetDValue("itemshop_window"));
}

function SlotBackward()
{
    Utils.PlayFeedbackSoundEnum(_global.Enums.SoundID.e_SoundButtonClicked);
	if ( m_IsSurgery )
    {
        m_CharacterCreationIF.ResetSurgeryData();
        UnloadClip();
    }
	else if ( m_CurrentMode > 0 )
    {
        SetState( m_CurrentMode - 1 );
    }
}

function SlotForward()
{
    Utils.PlayFeedbackSoundEnum(_global.Enums.SoundID.e_SoundButtonClicked);
	if (m_IsSurgery)
	{
		m_CurrentDialog = this.attachMovie("WindowComponent", "m_ChoosePaymentDialog", getNextHighestDepth());
		m_CurrentDialog.SetContent("ChoosePaymentDialog");
        m_CurrentDialog.SetPadding(15);
        m_CurrentDialog.ShowCloseButton(false);
        m_CurrentDialog.ShowStroke(true);
        m_CurrentDialog.ShowFooter(true);
        m_CurrentDialog.ShowResizeButton(false);
		
		m_CurrentDialog.SignalContentLoaded.Connect(SlotChoosePaymentDialogLoaded, this);
		
		m_CurrentDialog._x = (Stage.width - m_CurrentDialog._width) / 2 + 15;
		m_CurrentDialog._y = (Stage.height - m_CurrentDialog._height) / 2 + 15;
	}
	else
	{
		if ( m_CurrentMode < e_ModeCount - 1 && m_CurrentMode != e_ModeNaming )
		{
			SetState( m_CurrentMode + 1 );
		}
		else
		{
			var characterFirstName:String = m_NameEditor.GetFirstName();
			var characterNickName:String = m_NameEditor.GetNickName();
			var characterLastName:String = m_NameEditor.GetLastName();
			
			if ( characterFirstName.length > 0 && characterNickName.length > 0 && characterLastName.length > 0)
			{
				m_CharacterCreationIF.CreateCharacter( characterNickName, characterFirstName, characterLastName );
			}
			else
			{
				var dialogIF = new com.GameInterface.DialogIF( LDBFormat.LDBGetText( "CharCreationGUI", "NameEditor_MissingNameDialog" ), Enums.StandardButtons.e_ButtonsOk );
				dialogIF.SetIgnoreHideModule( true );
				dialogIF.Go();
			}
		}
	}
}

function SlotChoosePaymentDialogLoaded()
{
	var token:Number = _global.Enums.Token.e_Coupon_Barbershop;
	var cost:Number = com.GameInterface.Utils.GetGameTweak("CharacterCustomization_Barbershop_Price");
	
	if (m_CharacterEditMode == _global.Enums.CharacterEditMode.e_CharacterEditMode_PlasticSurgery)
	{
		token = _global.Enums.Token.e_Coupon_PlasticSurgery
		cost = com.GameInterface.Utils.GetGameTweak("CharacterCustomization_PlasticSurgeon_Price");
	}
	
	m_CurrentDialog.GetContent().SetCost(cost);
	m_CurrentDialog.GetContent().SetToken(token);
	

	var clientChar:Character = Character.GetClientCharacter();
	if (clientChar != undefined)
	{
		m_CurrentDialog.GetContent().SetPlayerCash(clientChar.GetTokens(_global.Enums.Token.e_Cash));
		m_CurrentDialog.GetContent().SetPlayerTokens(clientChar.GetTokens(token));
	}
	
	m_CurrentDialog.GetContent().SignalConfirmPayment.Connect(SlotConfirmPayment, this);
	m_CurrentDialog.GetContent().SignalCancelPayment.Connect(SlotCancelPayment, this);
		
}

function SlotConfirmPayment(token:Number)
{
	m_CharacterCreationIF.SetSurgeryData(token);
	
	var character:Character = m_CharacterCreationIF.GetCharacter();

	if ( character != undefined )
	{
		if (m_CharacterEditMode == _global.Enums.CharacterEditMode.e_CharacterEditMode_BarberShop)
		{
			setTimeout(PlayAfterCutSound, 1000);
			character.AddEffectPackage("sound_fxpackage_GUI_haircut.xml");
		}
		else if(m_CharacterEditMode == _global.Enums.CharacterEditMode.e_CharacterEditMode_PlasticSurgery)
		{
			setTimeout(UnloadClip, 10);
			character.AddEffectPackage("sound_fxpackage_GUI_plastic_surgery.xml");
		}
	}
}

function PlayAfterCutSound()
{
	var character:Character = m_CharacterCreationIF.GetCharacter();
	
	if (character != undefined)
	{
		character.AddEffectPackage("sound_fx_package_barber_shop_VO_after_cut.xml");
	}
	
	UnloadClip();
}

function SlotCancelPayment()
{
	m_CurrentDialog.removeMovieClip();
	m_CurrentDialog = undefined;
	
	if ( m_CurrentMode == e_ModeBarberShop )
	{
		m_BarberShop.CancelPayment();
	}
	
	if (m_CurrentMode == e_ModePlasticSurgeon)
	{
		m_PlasticSurgeon.CancelPayment();
	}
}

function RotateCharacter( delta:Number )
{
    m_CurrentCharRotation += delta;
}

function PanCamera( delta:Number )
{
    m_CameraController.SetCameraHeight( m_CameraController.GetCameraHeight() - delta * 0.002 );
}

function SlotFactionSelected( faction:Number )
{
    var zoomTime = 0.5;
    
    if ( faction != m_CurrentFaction )
    {
        m_CharacterCreationIF.SetFaction( faction );
        var character:Character = m_CharacterCreationIF.GetCharacter();
        m_CurrentFaction = faction;
        m_CurrentCharRotation = m_CharacterCreationIF.GetFactionCharacterRotation( faction );
        m_CurrentCharPosition = m_CharacterCreationIF.GetFactionCharacterLocation( faction );

    }
    SetState( e_ModeBody );
}

function SlotNicknameSuggestionReceived( name:String, whichName:Number )
{
//    trace( "Nick name suggestion received: " + name + " (" + whichName + ")" );
    /*if ( whichName == _global.Enums.BreedName.e_Name_Nick )
    {
        m_NameEditor.m_NamingBox.m_NickNameInput.textField.text = name;
    }*/
}

function SlotCreateCharacterSucceded()
{
    UnloadClip();
}

function SlotCreateCharacterFailed( errorCode:Number )
{
    var messageToken:String;
    
    switch( errorCode )
    {
      case _global.Enums.CharCreateResult.e_CreateResultTimout:            messageToken = "CharCreateDialog_Timeout";           break;
      case _global.Enums.CharCreateResult.e_CreateResultNameInUse:         messageToken = "CharCreateDialog_NameInUse";         break;
      case _global.Enums.CharCreateResult.e_CreateResultNameInvalidLength: messageToken = "CharCreateDialog_NameInvalidLength"; break;
      case _global.Enums.CharCreateResult.e_CreateResultNameNotValid:      messageToken = "CharCreateDialog_NameNotValid";      break;
    }

    var message:String;
    
    if ( messageToken )
    {
        message = LDBFormat.LDBGetText( "CharCreationGUI", messageToken );
        message = LDBFormat.Printf( message, m_NameEditor.GetNickName() );
    }
    else
    {
        message = "Unknown error: " + errorCode;
    }
    var dialogIF = new com.GameInterface.DialogIF( message, Enums.StandardButtons.e_ButtonsOk );
    dialogIF.SetIgnoreHideModule( true );
    dialogIF.Go();
}
