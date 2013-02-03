import GUIFramework.SFClipLoaderBase;

var g_FocusListener:Object = new Object();
var g_HasFocus:Boolean = false;

g_FocusListener.onSetFocus = function( oldFocus, newFocus )
{
    var clearFocus:Boolean = false;

//    trace( com.Utils.Format.Printf( "Focus changed from %s to %s (%s, %s)", oldFocus, newFocus, newFocus.tabEnabled, newFocus.tabChildren ) );

    var isTabEnabled:Boolean = false;

    for ( var tmp = newFocus ; tmp ; tmp = tmp._parent )
    {
        if ( tmp.tabEnabled )
        {
            isTabEnabled = true;
            break;
        }
    }
    // Only allow TextField's with input enabled and other movie-clips with tabEnabled == true to take focus.
    var allowFocus:Boolean = newFocus != null && ( isTabEnabled || (newFocus instanceof TextField && newFocus.type == "input") );
    
    if ( newFocus != null && !allowFocus )
    {
        newFocus = null;
        clearFocus = true;
    }
    
    var hadFocus:Boolean = g_HasFocus;
    g_HasFocus = newFocus != null;
  
    if ( hadFocus != g_HasFocus )
    {
        SFClipLoaderBase.FlashKeyboardFocusChanged( g_HasFocus );
    }
    if ( clearFocus )
    {
        setTimeout( ClearKeyboardFocus, 10 );
    }
}

////////////////////////////////////////////////////////////////////////////////
/// If the object currently having focus gets deleted, no focus change event
/// will be sent. To avoid having the game believe that a deleted element have
/// keyboard focus forever, we poll Selection.getFocus() two times per second
/// to check if the keyboard focus has changed without anybody telling us.
///
/// \author Kurt Skauen
////////////////////////////////////////////////////////////////////////////////

  
function RefreshKeyboardFocus()
{
  var hasFocus:Boolean = Selection.getFocus() != null;
  
  if ( hasFocus != g_HasFocus )
  {
//    trace( com.Utils.Format.Printf( "Focus changed from %s to %s without sending an event!", g_HasFocus, hasFocus ) );
    g_HasFocus = hasFocus;
    SFClipLoaderBase.FlashKeyboardFocusChanged( g_HasFocus );
  }
  
}

Selection.addListener( g_FocusListener );
setInterval( RefreshKeyboardFocus, 500 );

function ClearKeyboardFocus()
{
  Selection.setFocus( null );
}
