import com.PatcherInterface.Patcher;
import gfx.controls.ProgressBar;

m_StatusText.html = true;
m_ProgressText.html = true;

function SlotUpdateStatusText( txt:String )
{
	m_StatusText.htmlText = txt;
}

function SlotProgressChanged( progr:Number, txt:String )
{
	m_ProgressText.htmlText = txt;
    var scale:Number = Math.round(progr * 100);
    m_ProgressBar.m_ActiveProgressBar._xscale = scale
    
}

Patcher.SignalStatusTextChanged.Connect( SlotUpdateStatusText, this );
Patcher.SignalProgressChanged.Connect( SlotProgressChanged, this );
