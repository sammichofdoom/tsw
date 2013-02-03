import com.Utils.Archive;

intrinsic class com.GameInterface.GUIModuleIFBase
{
    // Activate this module. This method simply set the "main" module variable
    // specified in Modules.xml to 'true'. Note that there might be
    // other criterias that will prevent the module from actually becoming
    // active. If so, the module will become active as soon as those criterias
    // are fullfilled.
    public function Open() : Void;

    // Deactivate this module. This method simply set the "main" module variable
    // specified in Modules.xml to 'false'.
    public function Close() : Void;

    // Returns 'true' if all criterias for this module is fullfilled, 'false' otherwice.
    public function IsActive() : Boolean;

    // Retrieve the name of the module.
    public function GetModuleName() : String;

    // Retrieve the name of the modules "main" controlling variable.
    public function GetVariableName() : String;

    // Store the content of an 'Archive' in the distributed variable specified by 'config_name'
    // in Modules.xml.
    public function StoreConfig( config:Archive ) : Void;
	
	public static function CloseFullscreenModule(): Void;

    // Retrieve the content of the 'Archive' stored in the distributed variable
    // specified by 'config_name' in Modules.xml.    
    public function LoadConfig() : Archive;
    
    private var m_Name:String;
    
}
