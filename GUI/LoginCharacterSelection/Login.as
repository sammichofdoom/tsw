//Imports
import com.GameInterface.AccountManagement;
import com.GameInterface.DistributedValue;
import com.GameInterface.Utils;
import com.GameInterface.ProjectUtils;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import com.Utils.Colors;
import flash.geom.Rectangle;
import gfx.core.UIComponent;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import GUIFramework.SFClipLoader
import com.Utils.ID32;

//Class
dynamic class GUI.LoginCharacterSelection.Login extends UIComponent
{
    //Constants
    private static var NAVIGATION_BAR_GAP:Number = 10;
    private static var TEXT_INPUT_DEFAULT_STROKE_COLOR:Number = 0x666666;
    private static var TEXT_INPUT_HIGHLIGHT_STROKE_COLOR:Number = 0x0795C3;
    
    //Properties
	public var visibleRect:flash.geom.Rectangle;
	
	private var m_Background:MovieClip;
	private var m_BackgroundCharacters:MovieClip;
    private var m_BackgroundTitle:MovieClip;
	private var m_NavigationBar:MovieClip;
	private var m_QuitButton:MovieClip;
	private var m_SettingsButton:MovieClip;
	private var m_AccountButton:MovieClip;
    private var m_CreditsButton:MovieClip;
	private var m_UsernameInput:MovieClip;
	private var m_PasswordInput:MovieClip;
	private var m_LoginButton:MovieClip;
	private var m_KeyListener:Object;
	private var bgUrl:String;
	private var w:Number;
	private var h:Number;
	
    //Constructor
    public function Login()
    {
		Stage.scaleMode = "noScale"
		visibleRect = Stage["visibleRect"];
		
        m_KeyListener = new Object();
		
        m_KeyListener.onKeyUp = Delegate.create(this, KeyListenerEventHandler); 
    }
    
    //Key Listener Event Handler
    private function KeyListenerEventHandler():Void
    {
		switch(Key.getCode())
		{
			case Key.ENTER:     if (Selection.getFocus() == m_PasswordInput.textField || Selection.getFocus() == m_UsernameInput.textField)
								{
									Selection.setFocus(null);
									LoginToCharacterSelection();
								}
								
								break;
			
			case Key.TAB:       if (Selection.getFocus() == m_PasswordInput.textField)
								{
									m_UsernameInput.focused = true;
								}
								else if (Selection.getFocus() == m_UsernameInput.textField)
								{
									m_PasswordInput.focused = true;
								}
		}        
		
		CheckInputFields();
    }
    
    //On Load
    private function configUI():Void
    {
        Key.addListener(m_KeyListener);
        
        CheckInputFields();
       
        m_QuitButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Quit");
        m_QuitButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
		m_SettingsButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_CharacterSelectView_Settings");
        m_SettingsButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
		m_AccountButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "AccountManager");
        m_AccountButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
        m_CreditsButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "CreditsAllCaps");
        m_CreditsButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
		m_UsernameInput.m_HolderText.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Username");
        m_UsernameInput.addEventListener("focusIn", this, "TextFieldFocusEventHandler");
        m_UsernameInput.addEventListener("focusOut", this, "TextFieldFocusEventHandler");

        m_PasswordInput.m_HolderText.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Password");
        m_PasswordInput.addEventListener("focusIn", this, "TextFieldFocusEventHandler");
        m_PasswordInput.addEventListener("focusOut", this, "TextFieldFocusEventHandler");
        
		m_LoginButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_Login_Login");
        m_LoginButton.m_ForwardArrow._alpha = 50;
        m_LoginButton.SignalButtonSelected.Connect(SlotButtonSelected, this);

        var userName:String = DistributedValue.GetDValue("Login_UserName", "");
        
        if (userName.length > 0)
        {
            m_UsernameInput.text = userName;
            m_UsernameInput.focused = true;
        }
        
		LayoutHandler();
    }
    
    //On Unload
    private function onUnload():Void
    {
		Key.removeListener(m_KeyListener);
    }

    //Check Input Fields
    private function CheckInputFields():Void
    {
        if (m_UsernameInput.textField.text == "" || m_PasswordInput.textField.text == "")
        {
            m_LoginButton.disabled = true;
            m_LoginButton.m_ForwardArrow._alpha = 50;
        }
        else
        {
            m_LoginButton.disabled = false;
            m_LoginButton.m_ForwardArrow._alpha = 100;
        }
    }
    
    //Slot Button Selected
    public function SlotButtonSelected(target:Object):Void
    {
        Utils.PlayFeedbackSoundEnum(_global.Enums.SoundID.e_SoundButtonClicked);
        
        switch (target)
        {
            case m_QuitButton:      AccountManagement.GetInstance().QuitGame();
                                    break;
                                    
            case m_SettingsButton:  DistributedValue.SetDValue("mainmenu_window", true);
                                    break;
                                    
            case m_AccountButton:   AccountManagement.GetInstance().ShowAccountPage();
                                    break;
                                    
            case m_CreditsButton:   //SFClipLoader.LoadClip( "MediaPlayer.swf", "MediaPlayer", false, _global.Enums.ViewLayer.e_ViewLayerSplashScreenTop, 1, [{ Image: new ID32( _global.Enums.RDBID.e_RDB_FlashFile, 7740079 ) }] );
                                    DistributedValue.SetDValue("credits_window", true);
                                    break;
                                    
            case m_LoginButton:     LoginToCharacterSelection();
                                    break;
        }
    }
    
    //Login To Character Selection
    private function LoginToCharacterSelection():Void
    {
        AccountManagement.GetInstance().LoginAccount(m_UsernameInput.text, m_PasswordInput.text);
    }
    
    //Text Field Focus Event Handler
	private function TextFieldFocusEventHandler(event:Object):Void
	{
		Selection.setSelection(0, event.target.text.length);
        
        switch (event.type)
        {
            case "focusIn":     Colors.ApplyColor(event.target.m_Stroke, TEXT_INPUT_HIGHLIGHT_STROKE_COLOR);
                                event.target.m_HolderText._visible = false;
                                break;
                                    
            case "focusOut":    Colors.ApplyColor(event.target.m_Stroke, TEXT_INPUT_DEFAULT_STROKE_COLOR);
                                event.target.m_HolderText._visible = (event.target.textField.text == "") ? true : false;
        }
	}
	
    //Layout Handler
	public function LayoutHandler():Void
	{		
        SetupBackground();
        
		w = Stage.width;
		h = Stage.height;
		
		m_Background._x = 0;
		m_Background._y = 0;
		m_Background._width = w;
		m_Background._height = h;
		
		m_NavigationBar._x = 0;
		m_NavigationBar._y = Stage.height - m_NavigationBar._height;
		m_NavigationBar._width = w + 2;

		m_QuitButton._x = NAVIGATION_BAR_GAP;
		VerticallyCenterButton(m_QuitButton);
        
		m_SettingsButton._x = m_QuitButton._x + m_QuitButton.m_Background._width + NAVIGATION_BAR_GAP;
		VerticallyCenterButton(m_SettingsButton);
        
		m_AccountButton._x = m_SettingsButton._x + m_SettingsButton.m_Background._width + NAVIGATION_BAR_GAP;
        VerticallyCenterButton(m_AccountButton);
        
        m_CreditsButton._x = m_AccountButton._x + m_AccountButton.m_Background._width + NAVIGATION_BAR_GAP;
        VerticallyCenterButton(m_CreditsButton);
        
		m_LoginButton._x = w - m_LoginButton.m_Background._width - NAVIGATION_BAR_GAP;
        VerticallyCenterButton(m_LoginButton);

		m_PasswordInput._x = m_LoginButton._x - m_PasswordInput._width - NAVIGATION_BAR_GAP;
        VerticallyCenterTextField(m_PasswordInput);

		m_UsernameInput._x = m_PasswordInput._x - m_UsernameInput._width - NAVIGATION_BAR_GAP;
        VerticallyCenterTextField(m_UsernameInput);
        
        if (m_ShowFacebookPrompt && !m_FacebookPrompt)
        {
            ShowFacebookPrompt();
        }
	}
    
    //Setup Background
    private function SetupBackground():Void
	{
        var stageRect:Rectangle = Stage["visibleRect"];
        var scale:Number = m_BackgroundCharacters._xscale = m_BackgroundCharacters._yscale = 100;
        
        if (m_BackgroundCharacters._height > stageRect.height)
        {
            scale = m_BackgroundCharacters._xscale = m_BackgroundCharacters._yscale = stageRect.height / m_BackgroundCharacters._height * 100;
            m_BackgroundTitle._xscale = m_BackgroundTitle._yscale = scale;
        }
        
        m_BackgroundCharacters._x = -60 * scale / 100;
        m_BackgroundCharacters._y = stageRect.height + 100 * scale / 100;
        

        var leftGuide:Number = 760 * scale / 100
        
        m_BackgroundTitle._x = stageRect.width - (stageRect.width - leftGuide) / 2;
        m_BackgroundTitle._y = stageRect.height / 2 - m_NavigationBar._height;
        
        AnimateBackground();
	}
    
    //Animate Background
    private function AnimateBackground():Void
    {
        var distance:Number = 30;
        
        m_BackgroundCharacters._y -= distance;
        m_BackgroundTitle._y -= distance;
        
        m_BackgroundCharacters._alpha = m_BackgroundTitle._alpha = 0;
        
        m_BackgroundCharacters.tweenTo(5, {_alpha: 100, _y: m_BackgroundCharacters._y + distance}, Strong.easeOut);
        m_BackgroundTitle.tweenTo(5, {_alpha: 100, _y: m_BackgroundTitle._y + distance}, Strong.easeOut);
    }
    
    //Vertically Center Button
    private function VerticallyCenterButton(target:MovieClip):Void
    {
        target._y = m_NavigationBar._y + (m_NavigationBar._height / 2) - (target.m_Background._height / 2);
    }
    
    //Vertically Center Text Field
    private function VerticallyCenterTextField(target:MovieClip):Void
    {
        target._y = m_NavigationBar._y + (m_NavigationBar._height / 2) - (target.m_Stroke._height / 2) + 2;
    }
}
