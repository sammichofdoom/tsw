import mx.utils.Delegate;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import com.GameInterface.AccountManagement;
import GUI.LoginCharacterSelection.CharacterSelection;
import GUI.LoginCharacterSelection.LoginDialog;
import GUI.LoginCharacterSelection.RenameCharacterDialog;
import com.Utils.LDBFormat;

var m_LoginWindow:GUI.LoginCharacterSelection.Login;
var m_CharacterSelection:CharacterSelection;

var e_ModeLogin:Number = 0;
var e_ModeCharacterSelection:Number = 1;
var e_ModeCharacterRename:Number = 2;

var m_CurrentMode:Number = -1;

var m_Dialog:LoginDialog;
var m_RenameCharacterDialog:RenameCharacterDialog;

function onLoad():Void
{
    AccountManagement.GetInstance().SignalLoginStateChanged.Connect(SlotLoginStateChanged, this);
    AccountManagement.GetInstance().SignalCharacterNeedsNewName.Connect(SlotCharacterNeedsNewName, this);
    SlotLoginStateChanged( AccountManagement.GetInstance().GetLoginState() );
}

function onUnload()
{
}

function ResizeHandler( h, w ,x, y )
{
	if ( m_LoginWindow != undefined )
	{
		m_LoginWindow._x =  Stage["visibleRect"].x; 
		m_LoginWindow._y = Stage["visibleRect"].y;
		m_LoginWindow.LayoutHandler();
	}
	
	if ( m_CharacterSelection != undefined )
	{
		m_CharacterSelection._x =  Stage["visibleRect"].x; 
		m_CharacterSelection._y = Stage["visibleRect"].y;
		m_CharacterSelection.LayoutHandler();
	}
}	

function SlotLoginStateChanged( state:Number )
{
    if ( m_CurrentMode == e_ModeCharacterRename && state != _global.Enums.LoginState.e_LoginStateLoggedOut )
    {
        return;
    }

    if ( state == _global.Enums.LoginState.e_LoginStateLoggedOut )
    {
        SetMode( e_ModeLogin );
    }
    else
    {
        SetMode( e_ModeCharacterSelection );
    }
    
    switch( state )
    {
      case _global.Enums.LoginState.e_LoginStateLoggedOut:
          RemoveRenameDialog();
          HideLoginStatus();
          break;
      case _global.Enums.LoginState.e_LoginStateConnectingToUniverse:
          LoginStatusChanged( LDBFormat.LDBGetText("LoginProblems", "LoginProblem_ConnectUM"), _global.Enums.LoginDialogStatusType.e_Status, 0 );
          break;
      case _global.Enums.LoginState.e_LoginStateWaitingForUniverseAuthentication:
          LoginStatusChanged( LDBFormat.LDBGetText("LoginProblems", "LoginProblem_LoggingIntoUM"), _global.Enums.LoginDialogStatusType.e_Status, 0 );
          break;
      case _global.Enums.LoginState.e_LoginStateConnectingToTerritory:
          LoginStatusChanged( LDBFormat.LDBGetText("LoginProblems", "LoginProblem_ConnectingToTM"), _global.Enums.LoginDialogStatusType.e_Status, 0 );
          break;
      case _global.Enums.LoginState.e_LoginStateWaitingForTerritoryAuthentication:
          LoginStatusChanged( LDBFormat.LDBGetText("LoginProblems", "LoginProblems:LoginProblem_LoggingIntoTM"), _global.Enums.LoginDialogStatusType.e_Status, 0 );
          break;
      case _global.Enums.LoginState.e_LoginStateWaitingToEnterGame:
          LoginStatusChanged( LDBFormat.LDBGetText("Launcher", "GetCharList" ), _global.Enums.LoginDialogStatusType.e_StatusNoTimer, 0 );
          break;
      case _global.Enums.LoginState.e_LoginStateWaitingForGameServerConnection:
          if ( m_CharacterSelection != undefined || m_CharacterSelection.GetMode() == CharacterSelection.e_ModeCharacterSelection )
          {
              LoginStatusChanged( LDBFormat.LDBGetText("Launcher", "Launcher_CharacterSelectView_LoggingInCharacter"), _global.Enums.LoginDialogStatusType.e_Status, 0 );
          }
          else
          {
              LoginStatusChanged( LDBFormat.LDBGetText("Launcher", "Launcher_LoggingInto_Gameserver"), _global.Enums.LoginDialogStatusType.e_Status, 0 );
          }
          break;
      case _global.Enums.LoginState.e_LoginStateWaitingForFullUpdate:
          break;
      case _global.Enums.LoginState.e_LoginStateWaitingToSendInPlay:
          break;
      case _global.Enums.LoginState.e_LoginStateWaitingToReceiveInPlay:
          break;
      case _global.Enums.LoginState.e_LoginStateInPlay:
          HideLoginStatus();
          break;
      case _global.Enums.LoginState.e_LoginStateLocalTeleport:
          break;
      case _global.Enums.LoginState.e_LoginStateDeepTeleport:
          break;
      case _global.Enums.LoginState.e_LoginStateWaitingForLogout:
          break;
        
    }
}

function LoginStatusChanged(message:String, messageType:Number, timeout:Number)
{
    if ( m_CurrentMode == e_ModeCharacterRename )
    {
        return;
    }
    if (m_Dialog == undefined)
    {
        m_Dialog = attachMovie("LoginDialog", "m_LoginDialog", getNextHighestDepth());
        m_Dialog.SignalCancelLogin.Connect( SlotCancelLogin, this );
    }
    
    m_Dialog.SetText(message);
    
    switch(messageType)
    {
        case _global.Enums.LoginDialogStatusType.e_Queue:
            m_Dialog.SetButtonText(LDBFormat.LDBGetText("GenericGUI", "Cancel"));
            m_Dialog.SetTimeout(timeout, 0);
            break;
        case _global.Enums.LoginDialogStatusType.e_Status:
            m_Dialog.SetButtonText(LDBFormat.LDBGetText("GenericGUI", "Cancel"));
            m_Dialog.SetTimeout(300, 10);
            break;
        case _global.Enums.LoginDialogStatusType.e_StatusNoTimer:
            m_Dialog.SetButtonText(LDBFormat.LDBGetText("GenericGUI", "Cancel"));
            m_Dialog.SetTimeout(0, 0);
            break;
        case _global.Enums.LoginDialogStatusType.e_Error:
            m_Dialog.SetButtonText(LDBFormat.LDBGetText("GenericGUI", "Ok"));
            m_Dialog.SetTimeout(0, 0);
            break;
        case _global.Enums.LoginDialogStatusType.e_AccountError:
            m_Dialog.SetButtonText(LDBFormat.LDBGetText("GenericGUI", "Ok"));
            m_Dialog.SetTimeout(0, 0);
            break;
        default:
            break;
    }
}

function HideLoginStatus()
{
    if (m_Dialog != undefined)
    {
        m_Dialog.SignalCancelLogin.Disconnect( SlotCancelLogin );
        m_Dialog.removeMovieClip();
        m_Dialog = undefined;
    }
}

function SlotCancelLogin()
{
    AccountManagement.GetInstance().CancelLogin();
}

function SetMode( mode:Number )
{
    if ( mode != m_CurrentMode )
    {
        m_CurrentMode = mode;
        if ( mode == e_ModeLogin )
        {
			if ( m_CharacterSelection )
			{
				m_CharacterSelection.removeMovieClip();
                m_CharacterSelection = undefined;
			}
			if ( !m_LoginWindow )
			{
				m_LoginWindow = attachMovie( "LoginWindow", "m_LoginWindowClip", getNextHighestDepth() );
			}
        }
        else if ( mode == e_ModeCharacterSelection )
        {
            if ( m_CharacterSelection == undefined )
            {
                m_CharacterSelection = attachMovie( "CharacterSelection", "m_CharacterSelectionClip", getNextHighestDepth() );
            }
            m_CharacterSelection._visible = false;
            if ( m_CharacterSelection.IsCharacterListReceived() )
            {
                SlotCharacterListReceived();
            }
            else
            {
                m_CharacterSelection.SignalCharacterListReceived.Connect( SlotCharacterListReceived, this );
            }
        }
    }
}

function SlotCharacterListReceived()
{
    HideLoginStatus();

    if ( m_CharacterSelection )
    {
        m_CharacterSelection._visible = true;
    }
    if ( m_CurrentMode != e_ModeLogin && m_LoginWindow )
    {
        m_LoginWindow.removeMovieClip();
        m_LoginWindow = undefined;
    }
}

function SlotCharacterNeedsNewName( charInstance:Number, reason:Number, requestedName:String )
{
    RemoveRenameDialog();
    var desc:String;
    switch (reason)
    {
      case _global.Enums.CharacterRenameReason.REASON_RENAME_NAME_OK:
      {
          desc = LDBFormat.LDBGetText( "Gamecode", "CharacterRenamed" );
          desc = LDBFormat.Printf( desc, requestedName );
          break;
      }
      case _global.Enums.CharacterRenameReason.REASON_RENAME_NAME_USED:
      {
          desc = LDBFormat.LDBGetText( "CharCreationGUI", "CharCreateDialog_NameInUse" );
          desc = LDBFormat.Printf( desc, requestedName );
          break;
      }
      case _global.Enums.CharacterRenameReason.REASON_RENAME_NAME_INVALID:
      {
          desc = LDBFormat.LDBGetText( "CharCreationGUI", "CharCreateDialog_NameNotValid" );
          desc = LDBFormat.Printf( desc, requestedName );
          break;
      }
      default:
      {
          desc = LDBFormat.LDBGetText( "BlockedStatus", reason );
          break;
      }
    }
    if ( reason != _global.Enums.CharacterRenameReason.REASON_RENAME_NAME_OK )
    {
        m_RenameCharacterDialog = attachMovie("DialogRenameCharacter", "m_RenameCharacterDialogClip", getNextHighestDepth());
        m_RenameCharacterDialog.SetDescription( desc );
        m_RenameCharacterDialog.SetCharInstance( charInstance );
        m_RenameCharacterDialog.SignalSelected.Connect( SlotRenameCharDlg, this );
        
        SetMode( e_ModeCharacterRename );
        HideLoginStatus();
    }
    else
    {
        SetMode( e_ModeCharacterSelection );
    }
}

function SlotRenameCharDlg( charInstance:Number, newName:String ) : Void
{
    RemoveRenameDialog();
    AccountManagement.GetInstance().RenameCharacter( charInstance, newName );
    SetMode( e_ModeCharacterSelection );
}

function RemoveRenameDialog():Void
{
    if ( m_RenameCharacterDialog != undefined )
    {
        m_RenameCharacterDialog.SignalSelected.Disconnect( SlotRenameCharDlg );
        m_RenameCharacterDialog.removeMovieClip();
        m_RenameCharacterDialog = undefined;
    }
}
