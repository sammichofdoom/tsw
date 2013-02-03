

intrinsic class GUIFramework.SFClipLoaderBase
{
    /// Tell the C++ code that a clip has been loaded.
    /// This function should only be useed by GUIFramework.swf.
    
	public static function ClipLoaded( name:String, succeded:Boolean ) : Void;
    
    /// Tell the C++ code that a clip has been unloaded.
    /// This function should only be useed by GUIFramework.swf.

    public static function ClipUnloaded( name:String ) : Void;
    
    /// Tell the C++ code wether there currently is a movie clip that needs focus or not.
    /// This function should only be useed by GUIFramework.swf.

	public static function FlashKeyboardFocusChanged( needFocus:Boolean ) : Void;
}
