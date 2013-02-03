//Imports
import com.GameInterface.AccountManagement;
import com.GameInterface.CharacterData;
import com.GameInterface.DistributedValue;
import com.GameInterface.Browser.Facebook;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.core.UIComponent;
import gfx.controls.ScrollingList;
import flash.geom.Rectangle;
import flash.geom.Point;
import mx.events.EventDispatcher;
import com.GameInterface.Utils;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import GUI.LoginCharacterSelection.ServerListItemRenderer;
import GUI.LoginCharacterSelection.CharacterListItemRenderer;
import GUI.LoginCharacterSelection.DeleteCharacterDialog;

//Class
dynamic class GUI.LoginCharacterSelection.CharacterSelection extends UIComponent
{
    //Constants
    public static var e_ModeCharSelect = 0;
    public static var e_ModeCreateChar = 1;
    
    private static var NAVIGATION_BAR_GAP:Number = 10;
    
    //Properties
	private var m_Background:MovieClip;
	private var m_ScreenTitle:MovieClip;
    private var m_CharacterListWindow:MovieClip;
	private var m_CharacterList:MovieClip;
	private var m_ServerList:MovieClip;    
    
	private var m_LogoutButton:MovieClip;
	private var m_SettingsButton:MovieClip;
	private var m_AccountButton:MovieClip;
	private var m_NextButton:MovieClip;
	private var m_NavigationBar:MovieClip;
	private var m_DeleteCharacterDialog:MovieClip;
	
	private var m_KeyListener:Object;

    private var m_CharacterListReceived:Boolean;

    private var m_Mode:Number;    
    private var m_SelectedServerId:Number;
    private var m_SelectedCharacterId:Number;
    
    private var m_FacebookPrompt:MovieClip;

    private var m_IsHit:Boolean;
    private var m_HitPos:Point;
    
    private var w:Number;
	private var h:Number;
    
    public var SignalCharacterListReceived:Signal;

    //Constructor
    public function CharacterSelection()
    {
        m_HitPos = new Point();
        m_WasHit = false;
        
        m_CharacterListReceived = false;
        
        m_ServerList._alpha = 0;
		
        SignalCharacterListReceived = new Signal();
        
        m_Mode = -1;
        
        m_SelectedServerId = 0;
        m_SelectedCharacterId = 0

		m_KeyListener = new Object();
		m_KeyListener.onKeyUp = Delegate.create(this, KeyListenerEventHandler);
    }
    
    //Key Listener Event Handler
    private function KeyListenerEventHandler():Void
    {
        switch(Key.getCode())
        {
            case Key.ENTER:         if (!m_DeleteCharacterDialog._visible)
                                    {
                                        NextButtonEventHandler();
                                    }
        }
    }


    private function OnBackgroundMouseDown()
    {
        m_WasHit = true;
        m_HitPos.x = _root._xmouse;
        m_HitPos.y = _root._ymouse;
    }
    
    private function OnBackgroundMouseUp()
    {
        m_WasHit = false;
    }

    private function OnBackgroundMouseMove()
    {
        if ( m_WasHit )
        {
            var delta:Number = _root._xmouse - m_HitPos.x;

            AccountManagement.GetInstance().RotateCharacter( -delta * 0.01 );
            m_HitPos.x = _root._xmouse;
            m_HitPos.y = _root._ymouse;
        }
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        Key.addListener(m_KeyListener);
        
        m_ScreenTitle.text = LDBFormat.LDBGetText("Launcher", "SelectYourCharacter");

        m_CharacterList.m_Title.htmlText = LDBFormat.LDBGetText("Launcher", "Characters");

		m_ServerList.m_Title.htmlText = LDBFormat.LDBGetText("Launcher", "Launcher_CharacterSelectView_ChooseServer");
        
        m_LogoutButton.m_BackwardArrow._alpha = 100;
		m_LogoutButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Logout");
        m_LogoutButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
		m_SettingsButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_CharacterSelectView_Settings");
		m_SettingsButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
        m_AccountButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "AccountManager");
        m_AccountButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
        m_NextButton.m_ForwardArrow._alpha = 100;       
		m_NextButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_EULA_Next");
        m_NextButton.SignalButtonSelected.Connect(SlotButtonSelected, this);
        
        SetMode(e_ModeCharSelect);

		m_ServerList.m_ServerSelectionScrollingList.itemRenderer = "ServerListItemRenderer";
        m_ServerList.m_ServerSelectionScrollingList.addEventListener("change", this, "SlotSelectServer");
		 m_ServerList.m_ServerSelectionScrollingList.addEventListener("itemDoubleClick", this, "NextButtonEventHandler");
        
		m_CharacterList.m_CharacterSelectionScrollingList.itemRenderer = "CharacterListItemRenderer";
        m_CharacterList.m_CharacterSelectionScrollingList.addEventListener("change", this, "SlotSelectCharacter");
        m_CharacterList.m_CharacterSelectionScrollingList.addEventListener("itemDoubleClick", this, "SlotSelectCharacterPlay");
        m_CharacterList.m_DeleteButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "DeleteButtonLabel");

        m_Background.onPress = Delegate.create(this, OnBackgroundMouseDown );
        m_Background.onMouseUp = Delegate.create(this, OnBackgroundMouseUp );
        m_Background.onMouseMove = Delegate.create(this, OnBackgroundMouseMove );
        
        SlotUpdateDimensions();

        if (AccountManagement.GetInstance().m_Characters != undefined && AccountManagement.GetInstance().m_Characters.length > 0)
        {
            SlotUpdateCharacters();
        }

        AccountManagement.GetInstance().SignalDimensionDataUpdate.Connect(SlotUpdateDimensions, this);
        AccountManagement.GetInstance().SignalCharacterDataUpdate.Connect(SlotUpdateCharacters, this);

        Facebook.SignalReceivedFriendsList.Connect(SlotUpdateDimensions, this);
        
		LayoutHandler();
    }
    
    //Create Facebook List
    public function CreateFacebookList(instanceName:String):Void
    {
        attachMovie("FacebookFriendsList", instanceName, getNextHighestDepth());
    }

    //On Unload
    private function onUnload():Void
    {
		Key.removeListener(m_KeyListener);
    }

    //Slot Button Selected
    public function SlotButtonSelected(target:Object):Void
    {
        Utils.PlayFeedbackSoundEnum(_global.Enums.SoundID.e_SoundButtonClicked);
        
        switch (target)
        {
            case m_LogoutButton:    AccountManagement.GetInstance().LogoutAccount();
                                    break;
                                    
            case m_SettingsButton:  DistributedValue.SetDValue("mainmenu_window", true);
                                    break;
                                    
            case m_AccountButton:   AccountManagement.GetInstance().ShowAccountPage();
                                    break;
                                    
            case m_NextButton:      NextButtonEventHandler();
        }
    }
    
    //Next Button Event Handler
	private function NextButtonEventHandler():Void
	{
        if (m_SelectedServerId != 0)
        {
            if (m_Mode == e_ModeCreateChar)
            {
                AccountManagement.GetInstance().CreateCharacter(m_SelectedServerId);
            }
            else if (m_SelectedCharacterId != 0)
            {
                AccountManagement.GetInstance().EnterGame(m_SelectedCharacterId, m_SelectedServerId);
            }
        }		
	}
    
    //Is Character List Received
    public function IsCharacterListReceived():Boolean
    {
        return m_CharacterListReceived;
    }
    
    //Slot Update Dimensions
    private function SlotUpdateDimensions():Void
    {
        if (AccountManagement.GetInstance().m_Dimensions != undefined)
        {
            var dimensions:Array = AccountManagement.GetInstance().m_Dimensions;
            
            m_ServerList.m_ServerSelectionScrollingList.dataProvider = dimensions;
            
            if (m_SelectedServerId == 0 && dimensions.length > 0)
            {
                m_SelectedServerId = dimensions[0].m_Id;
            }
            
            m_CharacterList.m_CharacterSelectionScrollingList.invalidateData();
        }
    }
    
    //Slot Update Characters
    private function SlotUpdateCharacters():Void
    {
        var charsLeft:Number = 0;
        var selectedCharID:Number = m_SelectedCharacterId;

        if (selectedCharID == 0)
        {
            selectedCharID = DistributedValue.GetDValue("LastPlayedCharacter", 0);
        }
        
        m_SelectedCharacterId = 0;

        var characterArray:Array = new Array;
        
        if (AccountManagement.GetInstance().m_Characters != undefined)
        {
            m_CharacterListReceived = true;
            
            SignalCharacterListReceived.Emit();
            
            // Make a copy of the array so we can insert the "Create Character" entry without messing up the list in 'AccountManagement'.
            var origCharArray:Array = AccountManagement.GetInstance().m_Characters;
            
            for ( var i:Number = 0 ; i < origCharArray.length ; ++i )
            {
                characterArray.push(origCharArray[i]);
            }
            
            charsLeft = AccountManagement.GetInstance().GetMaxCharSlots() - origCharArray.length;            
        }

        if (charsLeft > 0)
        {
            var createCharacterData:CharacterData = new CharacterData();
            createCharacterData.m_CreateCharacter = true;
            createCharacterData.m_Name = LDBFormat.LDBGetText("Launcher", "CreateCharacter");
            createCharacterData.m_Location = LDBFormat.Printf(LDBFormat.LDBGetText("Launcher", "CharacterSlotsLeft"), charsLeft);
                
            characterArray.push(createCharacterData);
        }
            
        m_CharacterList.m_CharacterSelectionScrollingList.dataProvider = characterArray;

        var found:Boolean = false;
            
        for (var i:Number = 0 ; i < m_CharacterList.m_CharacterSelectionScrollingList.dataProvider.length ; ++i)
        {
            if (m_CharacterList.m_CharacterSelectionScrollingList.dataProvider[i].m_Id == selectedCharID)
            {
                m_CharacterList.m_CharacterSelectionScrollingList.selectedIndex = i;
                found = true;
                break;
            }
        }
            
        if (!found)
        {
            m_CharacterList.m_CharacterSelectionScrollingList.selectedIndex = 0;
        }
            
        UpdateSelectedCharacter(m_CharacterList.m_CharacterSelectionScrollingList.selectedIndex);
        
        Selection.setFocus(m_CharacterList.m_CharacterSelectionScrollingList);
        
        Facebook.SignalAskToSignUp.Connect(SlotAskSignUpFacebook, this);
    }

    //Open Confirm Delete Dialog
    private function OpenConfirmDeleteDialog():Void
    {
        m_CharacterList.m_CharacterSelectionScrollingList.disabled = true;
        if (m_DeleteCharacterDialog == undefined)
        {		
            m_DeleteCharacterDialog = attachMovie("DeleteCharacterDialog", "deleteCharacterDialog", getNextHighestDepth());
            m_DeleteCharacterDialog._y = (Stage.height / 2) - (m_DeleteCharacterDialog._height / 2);
            
            m_DeleteCharacterDialog.SignalCancelDeleteCharacter.Connect(CloseDeleteCharacterDialog, this);
            m_DeleteCharacterDialog.SignalConfirmDeleteCharacter.Connect(DeleteCharacter, this);
        }
    }
    
    //Center Confirm Delete Dialog
    private function CenterConfirmDeleteDialog():Void
    {
        if (m_DeleteCharacterDialog != undefined)
        {
            
        }
    }
	
    //Close Delete Character Dialog
	private function CloseDeleteCharacterDialog():Void
	{
		m_CharacterList.m_CharacterSelectionScrollingList.disabled = false;
        if (m_DeleteCharacterDialog != undefined)
        {
            m_DeleteCharacterDialog.removeMovieClip();
            m_DeleteCharacterDialog = undefined;		
        }
        
        Selection.setFocus(m_CharacterList.m_CharacterSelectionScrollingList);
	}
	
    //Delete Character
	private function DeleteCharacter(password:String):Void
	{
		AccountManagement.GetInstance().DeleteCharacter(m_SelectedCharacterId, password);
		CloseDeleteCharacterDialog();
	}
	
    //Slot Select Server
    private function SlotSelectServer(event:Object):Void
    {
        var dimensions:Array = AccountManagement.GetInstance().m_Dimensions;
        
        if (event.index < dimensions.length)
        {
            m_SelectedServerId = dimensions[event.index].m_Id;
        }
    }

    //Slot Select Character Play
	private function SlotSelectCharacterPlay(event:Object):Void
	{
		SlotSelectCharacter(event);
		NextButtonEventHandler();
	}
	
    //Slot Select Character
    private function SlotSelectCharacter(event:Object):Void
    {
        UpdateSelectedCharacter(event.index);
    }

    //Update Selected Character
    private function UpdateSelectedCharacter(index:Number):Void
    {
        if (index != -1 && index < m_CharacterList.m_CharacterSelectionScrollingList.dataProvider.length)
        {
            var characterData:CharacterData = m_CharacterList.m_CharacterSelectionScrollingList.dataProvider[index];

            if ( !characterData.m_CreateCharacter )
            {
                SetMode(e_ModeCharSelect);
                if ( m_SelectedCharacterId != characterData.m_Id )
                {
                    m_SelectedCharacterId = characterData.m_Id;
                    m_SelectedServerId = characterData.m_DimensionId; 
                    AccountManagement.GetInstance().SelectCharacter(m_SelectedCharacterId);
                }
            }
            else if( GetMode() != e_ModeCreateChar ) //Do not set mode if already in createChar mode, as it will reset the selected dimension
            {
                SetMode(e_ModeCreateChar);
                m_SelectedCharacterId = 0;
                var dimensions:Array = AccountManagement.GetInstance().m_Dimensions;
            
                if (dimensions.length > 0)
                {
                    m_SelectedServerId = dimensions[0].m_Id;
                }
                AccountManagement.GetInstance().SelectCharacter(0);
            }
        }
    }
    
    //Set Mode
    private function SetMode(mode:Number):Void
    {
        if (mode != m_Mode)
        {
            m_Mode = mode;
            
            switch(mode)
            {
                case e_ModeCharSelect:      m_ServerList.tweenTo(1, { _alpha: 0 }, Strong.easeOut);
                                            m_ScreenTitle.text = LDBFormat.LDBGetText("Launcher", "SelectYourCharacter");
                                            m_NextButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_EULA_Next");
                                            m_CharacterList.m_DeleteButton.disabled = false;
                                            m_CharacterList.m_DeleteButton.onRelease = Delegate.create(this, OpenConfirmDeleteDialog);
                                            Selection.setFocus(m_ServerList.m_ServerSelectionScrollingList);
                                            break;
                                        
                case e_ModeCreateChar:      m_ServerList.tweenTo(1, { _alpha: 100 }, Strong.easeOut);
                                            CloseDeleteCharacterDialog();
                                            m_CharacterList.m_DeleteButton.disabled = true;
                                            m_CharacterList.m_DeleteButton.onRelease = null;
                                            m_ScreenTitle.text = LDBFormat.LDBGetText("Launcher", "SelectYourDimension");
                                            m_NextButton.m_Label.text = LDBFormat.LDBGetText("Launcher", "Launcher_EULA_Create");
                                            Selection.setFocus(m_ServerList.m_ServerSelectionScrollingList);
                                            m_ServerList.m_ServerSelectionScrollingList.selectedIndex = 0;
            }
        }
    }

    //Get Mode
    public function GetMode():Number
    {
        return m_Mode;
    }
    
    //Layout Handler
	public function LayoutHandler():Void
	{      
        w = Stage.width;
        h = Stage.height;
    
		m_CharacterList._x = w / 2 - (m_CharacterList._width + 150);
        m_CharacterList._y = h / 2 - m_CharacterList._height / 2;
		
		m_ServerList._x = w / 2 + 174;
		m_ServerList._y = m_CharacterList._y;
        
        m_FacebookList._x = -500;
        m_FacebookList._y = -500;
		
        m_ScreenTitle._x = w / 2 - m_ScreenTitle._width / 2;
		m_ScreenTitle._y = 20;
		
		m_NavigationBar._x = 0;
		m_NavigationBar._y = h - m_NavigationBar._height;
		m_NavigationBar._width = w + 10;
        
		m_LogoutButton._x = NAVIGATION_BAR_GAP;
		VerticallyCenterButton(m_LogoutButton);
        
		m_SettingsButton._x = m_LogoutButton._x + m_LogoutButton.m_Background._width + NAVIGATION_BAR_GAP;
		VerticallyCenterButton(m_SettingsButton);
        
		m_AccountButton._x = m_SettingsButton._x + m_SettingsButton.m_Background._width + NAVIGATION_BAR_GAP;
        VerticallyCenterButton(m_AccountButton);
        
		m_NextButton._x = w - m_NextButton.m_Background._width - NAVIGATION_BAR_GAP;
        VerticallyCenterButton(m_NextButton);
        
        if (m_DeleteCharacterDialog != undefined)
        {
            m_DeleteCharacterDialog.LayoutHandler();
        }
        m_Background._x = 0;
        m_Background._y = 0;
        m_Background._width = Stage.width;
        m_Background._height = Stage.height;        
	}
    
    //Vertically Center Button
    private function VerticallyCenterButton(target:MovieClip):Void
    {
        target._y = m_NavigationBar._y + (m_NavigationBar._height / 2) - (target.m_Background._height / 2);
    }
    
    private function SlotAskSignUpFacebook():Void
    {
        m_CharacterList.m_CharacterSelectionScrollingList.disabled = true;
        m_ServerList.m_ServerSelectionScrollingList.disabled = true;
        m_NextButton.disabled = true;
        
        ShowFacebookPrompt();
        
        Selection.setFocus(null);            
    }
    
    //Show Facebook Prompt
    private function ShowFacebookPrompt():Void
    {
        m_FacebookPrompt = attachMovie("DialogLoginWithFacebook", "m_FacebookPrompt", getNextHighestDepth());
        m_FacebookPrompt._x = w / 2 - m_FacebookPrompt._width / 2;
        m_FacebookPrompt._y = h / 2 - m_FacebookPrompt._height / 2;
        
        m_UsernameInput.disabled = m_PasswordInput.disabled = true;
        
        m_FacebookPrompt.SignalLoginSelected.Connect(SlotFacebookPromptSelection, this);
    }
    
    //Slot Facebook Prompt Selection
    private function SlotFacebookPromptSelection(loginSelected:Boolean):Void
    {
        m_FacebookPrompt.removeMovieClip();
        m_FacebookPrompt = null;

        if (loginSelected)
        {
            DistributedValue.SetDValue("facebook_browser", true);
        }
        
        m_CharacterList.m_CharacterSelectionScrollingList.disabled = false;
        m_ServerList.m_ServerSelectionScrollingList.disabled = false;
        m_NextButton.disabled = false;
        
        m_ServerList.m_ServerSelectionScrollingList.selectedIndex = 0;
    }
}