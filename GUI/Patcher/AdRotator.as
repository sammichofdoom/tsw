import com.Utils.Signal;
import gfx.core.UIComponent;
import com.PatcherInterface.Patcher;
import GUI.Patcher.BannerItem;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;

class GUI.Patcher.AdRotator extends UIComponent
{
    var m_BannerList:Array;
    var m_MovieClipLoader:MovieClipLoader;
    var m_LoaderTarget:MovieClip;
    var m_CurrentIndex:Number;
    
    public function AdRotator()
    {
        super();
        m_CurrentIndex = -1;
    }

    private function configUI()
    {
        var numBanners:Number = Patcher.GetBannerCount();
        m_BannerList = [];
        if (numBanners > 0)
        {
            for (var i:Number = 0; i < numBanners; i++ )
            {
                m_BannerList.push( new BannerItem(i, this, Patcher.GetBannerPath( i ), Patcher.GetBannerTargetURL( i ),Patcher.GetBannerDisplayTime(i ) ) );
            }
            m_BannerList[0].SignalLoaded.Connect( SlotShowBanner, this);
        }
      
        m_LoaderTarget.onRelease = Delegate.create(this, OpenBannerAd)
        
        Patcher.SignalBannerNodeAdded.Connect( SlotBannerNodeAdded, this  )
    }
    
    private function OpenBannerAd()
    {
        if (m_BannerList[m_CurrentIndex].m_TargetUrl != undefined)
        {
            Patcher.ShowExternalURL( m_BannerList[m_CurrentIndex].m_TargetUrl );
        }
    }
    
    private function SlotShowBanner()
    {
        if (m_CurrentIndex >= 0)
        {
            var banner:MovieClip = m_BannerList[m_CurrentIndex].m_Data;
            banner.tweenTo( 1, { _alpha: 0 }, None.easeNone);
        }
        
        m_CurrentIndex = (m_CurrentIndex == m_BannerList.length-1) ? 0 : m_CurrentIndex + 1; 

        if (m_BannerList[m_CurrentIndex].m_IsLoaded)
        {
            var newBanner:MovieClip = m_BannerList[m_CurrentIndex].m_Data;
            newBanner.tweenEnd();

            newBanner.tweenTo(1, { _alpha:100 }, None.easeNone);
            _global.setTimeout( Delegate.create(this, SlotShowBanner), m_BannerList[m_CurrentIndex].m_DisplayTime);
        }
        else
        {
            m_CurrentIndex -= 2; // go back to one lower than where we started (will rerun the current ad if there is only one loaded)
            SlotShowBanner();
        }
    }
    
    private function SlotBannerNodeAdded( imagePath:String, targetURL:String, displayTime:Number )
    {
        m_BannerList.push( new BannerItem(m_BannerList.length, m_LoaderTarget, imagePath, targetURL, displayTime ) );
        if (m_BannerList.length == 1)
        {
            m_BannerList[0].SignalLoaded.Connect( SlotShowBanner, this);
        }
    }
}