import flash.display.BitmapData;
import com.Utils.Signal;
import com.PatcherInterface.Patcher;

class GUI.Patcher.BannerItem
{
    public var m_Path:String;
    public var m_DisplayTime:Number;
    public var m_Data:MovieClip;
    public var m_TargetUrl:String;
    public var m_IsLoaded:Boolean;
    public var m_Index:Number;
    
    public var SignalLoaded:Signal;
    
    public function BannerItem(index:Number, commonTarget:MovieClip, path:String, targetURL:String,displayTime:Number )
    {
        m_Index = index;
        m_Path = path;
        m_DisplayTime = displayTime * 1000, // convert to ms
        m_TargetUrl = targetURL
        
        m_IsLoaded = false;
        
        SignalLoaded = new Signal();
        var target:MovieClip = commonTarget.createEmptyMovieClip("banner_" + index, commonTarget.getNextHighestDepth());
        
        var loader:MovieClipLoader = new MovieClipLoader();
        loader.addListener( this );
        loader.loadClip( m_Path, target);
    }
    
    private function onLoadComplete(mc:MovieClip)
    {

        m_Data = mc;
        m_Data._alpha = 0;
        m_IsLoaded = true;
        SignalLoaded.Emit(m_Index);
    }
    
    private function onLoadError(mc:MovieClip, errorCode:String)
    {
        trace("Banner failed to load --- "+errorCode);
    }
}