

var m_TextLoaded:Boolean = false;
var m_IntervalID:Number;

//this.onEnterFrame=function()
function UpdateText()
{
    if(m_TextLoaded)
    {
        var scrollspeed:Number = 1;
        
//This is not working in game for some reason
/*
        if( Key.isDown(Key.DOWN) )
        {
             scrollspeed = 10;
        }
*/
        myText._y -= scrollspeed;
    }
}

function TextLoadedEventHandler(success:Boolean):Void
{
     if (success)
     {
          myText.htmlText = this.credits;
          m_TextLoaded = true;
     }
}

function onLoad()
{
    var visibleRect = Stage["visibleRect"];
    var xscale:Number = (visibleRect.width/this._width) * 100;
    var yscale:Number = (visibleRect.height/1200) * 100;
    
    _xscale = _yscale = Math.max(xscale,yscale);

    if(xscale > yscale)
    {
        _y = visibleRect.height / 2 - (1200) / 2;
    }
    else
    {
        _x = visibleRect.width / 2 - (this._width) / 2;
    }
    
    m_IntervalID = setInterval(this, "UpdateText", 25);
    
    var myData:LoadVars = new LoadVars();
    myData.onLoad = TextLoadedEventHandler;
    myData.load("credits.txt");
    
    myText._height = 500000;
}

function onUnload()
{
    if (m_IntervalID)
    {
        clearInterval(m_IntervalID);
        m_IntervalID = null;
    }
}