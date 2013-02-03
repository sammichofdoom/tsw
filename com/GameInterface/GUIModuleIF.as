import flash.external.*;
import com.Utils.Signal;
import com.Utils.Archive;

class com.GameInterface.GUIModuleIF extends com.GameInterface.GUIModuleIFBase
{
//    private static var m_ClassName:String = "GUIModuleIF";

    public static function FindModuleIF( name:String ) : GUIModuleIF
    {
        if ( m_WatchedModules.hasOwnProperty( name ) )
        {
            return m_WatchedModules[ name ];
        }
        else
        {
            var module:GUIModuleIF = new GUIModuleIF( name );
            m_WatchedModules[ name ] = module;
            return module;
        }
    }

    private function GUIModuleIF( name:String )
    {
        super( name );
        SignalActivated     = new Signal();
        SignalDeactivated   = new Signal();
        SignalStatusChanged = new Signal();
    }
    // Called from C++ when any of the modules changes status. This will lookup
    // the module that changed and send the apropriate signals.
    
    public static function OnModuleStatusChanged( name:String, isActive:Boolean ) : Void
    {
        if ( m_WatchedModules.hasOwnProperty( name ) )
        {
            var monitor:GUIModuleIF = m_WatchedModules[name];
            if ( isActive )
            {
                monitor.SignalActivated.Emit( monitor );
            }
            else
            {
                monitor.SignalDeactivated.Emit( monitor );
            }
            monitor.SignalStatusChanged.Emit( monitor, isActive );
        }
    }
    public var SignalActivated:Signal;
    public var SignalDeactivated:Signal;
    public var SignalStatusChanged:Signal;
    
    private static var m_WatchedModules:Object = new Object();

    
}
