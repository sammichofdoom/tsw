import mx.data.encoders.Num;
//Imports

//Class
class GUI.WebBrowser.WebBrowserVolume extends MovieClip
{
    //Constants
    public static var LEVEL_MUTE:Number = 0;
    public static var LEVEL_LOW:Number = 1;
    public static var LEVEL_MEDIUM:Number = 2;
    public static var LEVEL_HIGH:Number = 3;
    
    //Properties
    private var m_Volume0:MovieClip;
    private var m_Volume1:MovieClip;
    private var m_Volume2:MovieClip;
    private var m_Volume3:MovieClip;
    
    private var m_VolumeLevel:Number;
    
    //Constructor
    public function WebBroswerVolume()
    {
        super();
        
        HideVolumeIcons();
    }
    
    //Hide Volume Icons
    private function HideVolumeIcons():Void
    {
        m_Volume0._visible = false;
        m_Volume1._visible = false;
        m_Volume2._visible = false;
        m_Volume3._visible = false;
    }
    
    //Set Volume Level
    public function set volumeLevel(value:Number):Void
    {
        HideVolumeIcons();
        
        switch (value)
        {
            case 0: m_Volume0._visible = true;
                    break;
                    
            case 1: m_Volume1._visible = true;
                    break;
                    
            case 2: m_Volume2._visible = true;
                    break;
                    
            case 3: m_Volume3._visible = true;
        }
        
        m_VolumeLevel = value;
    }
    
    //Get Volume Level
    public function get volumeLevel():Number
    {
        return m_VolumeLevel;
    }
}