import com.GameInterface.Game.Character;

var m_LatencyView:TextField;
var m_ClientFPSView:TextField;
var m_ServerFPSView:TextField;
var m_ServerFPSLabelView:TextField;


function onLoad() : Void
{
    com.GameInterface.ClientServerPerfTracker.SignalLatencyUpdated.Connect( SlotLatencyUpdated, this );
    com.GameInterface.ClientServerPerfTracker.SignalServerFramerateUpdated.Connect( SlotServerFramerateUpdated, this );
    com.GameInterface.ClientServerPerfTracker.SignalClientFramerateUpdated.Connect( SlotClientFramerateUpdated, this );
    SlotLatencyUpdated( com.GameInterface.ClientServerPerfTracker.GetLatency() );
    SlotClientFramerateUpdated( com.GameInterface.ClientServerPerfTracker.GetClientFramerate() );
    SlotServerFramerateUpdated( com.GameInterface.ClientServerPerfTracker.GetServerFramerate() );


    var clientChar:Character = Character.GetClientCharacter();
    clientChar.SignalStatChanged.Connect( SlotClientCharStatChanged, this );

    SlotClientCharStatChanged( _global.Enums.Stat.e_GmLevel );
}

function SetIsGM( isGM:Boolean ) : Void
{
    m_ServerFPSView._visible = isGM;
    m_ServerFPSLabelView._visible = isGM;
}
    
function SlotClientCharStatChanged( statID:Number ) : Void
{
    if ( statID == _global.Enums.Stat.e_GmLevel )
    {
        var clientChar:Character = Character.GetClientCharacter();
        SetIsGM( clientChar.GetStat( statID ) != 0 );
    }
}

function SlotLatencyUpdated( latency:Number ) : Void
{
    m_LatencyView.text = com.Utils.Format.Printf( "%.0fmS", latency * 1000 );
}

function SlotClientFramerateUpdated( fps:Number ) : Void
{
    m_ClientFPSView.text = com.Utils.Format.Printf( "%.2fFPS", fps );
}

function SlotServerFramerateUpdated( fps:Number ) : Void
{
    m_ServerFPSView.text = com.Utils.Format.Printf( "%.2fFPS", fps );
}
