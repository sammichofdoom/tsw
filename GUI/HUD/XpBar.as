import com.GameInterface.DistributedValue;
import com.GameInterface.Utils;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.Signal;
import flash.filters.DropShadowFilter;
import mx.transitions.easing.*;
import flash.geom.Point;
import com.GameInterface.Log;
import com.Utils.LDBFormat;

var m_ResolutionScaleMonitor:DistributedValue;
var m_Character:Character;
var m_TotalFrames:Number;
var m_ScreenWidth:Number = 0;
var m_CurrentXPBar:MovieClip;
var m_NumSegments:Number = 3;
//var m_Padding:Number = 2;
var m_LastXP:Number;
var m_Format:TextFormat;
var m_XPText:TextField;
var m_Shadow:DropShadowFilter
var m_FIFOOverwriteThreshold:Number = 30; // the percentage of a tween that must be completed if we want to create a new fifo object, if not reached, we update the text of the fifo instead.
var m_UID:Number = 0; /// if multiple instances of  the xp FIFO, use and increment this to create unique instances

var m_TDB_XP:String = LDBFormat.LDBGetText("MiscGUI", "xp")+":";
var m_TDB_SP:String = LDBFormat.LDBGetText("CharacterSkillsGUI", "SP") + ":"; 
var m_TDB_AP:String = LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsAbbreviation") + ":"; 

function onLoad()
{
    Log.Info2("XpBar", "onLoad()");

    m_Format = new TextFormat;
    m_Format.font = "_StandardFont";
    m_Format.size = 10;
    m_Format.color = 0xFFFFFF;
    
    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( SlotResolutionChange, this );
        
    SlotClientCharacterAlive();
    CharacterBase.SignalClientCharacterAlive.Connect(SlotClientCharacterAlive, this);
    
    m_Shadow = new DropShadowFilter( 1, 35, 0x000000, 0.7, 1, 2, 2, 3, false, false, false );
    
    m_XPText = this.createTextField("xpinfo", this.getNextHighestDepth(), 0, -5, 0, 0);
    m_XPText.autoSize = "left";
    m_XPText.selectable = false;
    m_XPText.setNewTextFormat( m_Format );
    m_XPText.filters = [ m_Shadow ];
    m_XPText._visible = true;
   
    m_TotalFrames = m_XPBarSegment_0._totalframes;
    
    m_Background.onRollOver = function()
    {
        m_XPText.text = m_TDB_XP + " " + GetXP() + "/" + GetNextLevelXP()+"  "  +m_TDB_AP +" " + GetAP() + "  " + + m_TDB_SP + " " + GetSP();
        var mouseX:Number = (this._xmouse * (m_ScreenWidth / 100));
        var xpNumberWidth:Number = m_XPText._width + 10;
        
                Log.Info2("XpBar", "m_XPText._width "+m_XPText._width+" mouseX "+mouseX);
                
        if ( (mouseX + xpNumberWidth) > m_ScreenWidth  )
        {
            m_XPText._x = mouseX - xpNumberWidth;
        }
        else
        {
           m_XPText._x =  mouseX + 5
        }

        m_XPText._visible = true;
    }
    
    m_Background.onRollOut = function()
    {
      //  Log.Info2("XpBar", "out");
        m_XPText._visible = false;
    }
    
    m_Background.onReleaseOutside = function()
    {
        m_XPText._visible = false;
    }
    
    Layout();
    
    
    UpdateXPBar( m_LastXP,false );       
}

function SlotClientCharacterAlive()
{
    m_Character = Character.GetClientCharacter();
    m_LastXP = GetXP();
    
    if (m_Character != undefined)
    {
      //  m_Character.SignalTokenAmountChanged.Connect( SlotTokenAmountChanged, this );
        m_Character.SignalStatChanged.Connect( SlotStatChanged, this );
    }
}

function GetNextLevelXP() : Number
{
	if(m_Character != null)
    {
		var xpLevelRatio = com.GameInterface.Utils.GetGameTweak("XPLevelRatio");
        var xp:Number = m_Character.GetStat( Enums.Stat.e_XP, 2 );
		return xp - (xp % xpLevelRatio) + xpLevelRatio;
    }
    return 0;
}

function GetAP() : Number
{
    if(m_Character != null)
    {
        return m_Character.GetTokens( 1 );
    }
    return 0;
}

function GetXP() : Number
{
    if(m_Character != null)
    {
        return m_Character.GetStat( Enums.Stat.e_XP, 2 );
    }
    return 0;
}

function GetSP() : Number
{
    if(m_Character != null)
    {
        return m_Character.GetTokens( 2 );
    }
    return 0;
}

function SlotResolutionChange()
{
    var xp = GetXP();

    Layout();
    UpdateXPBar( xp,false );
}

function SlotStatChanged(p_Stat:Number)
{
    if( p_Stat == Enums.Stat.e_XP )
    {
        var oldXP:Number = m_LastXP;
        var newXP:Number = GetXP();
        
        Log.Info2("XpBar", "SlotStatChanged(XP, " + newXP + ")");

        UpdateXPBar( newXP, true );
      
        if (newXP > oldXP && oldXp != undefined)
        {
            Utils.PlayFeedbackSound("sfx/gui/gui_xp_get.wav");
        }
    }
}
/*
function SlotTokenAmountChanged(id:Number, newValue:Number, oldValue:Number)
{
    Log.Info2("XpBar", "SlotTokenAmountChanged(" + id + "," + newValue + ", " + oldValue + ")");

    /// TODO: create the enum for the token enum
    if(newValue > oldValue && ( id == 1 || id == 2) )
    {
        var pos:Point = m_Character.GetScreenPosition(_global.Enums.AttractorPlace.e_CameraAim);
        pos.x += Stage["visibleRect"].x;
        pos.y += Stage["visibleRect"].y;
		var pointsGet:MovieClip
		if(id == 1)
        {
			pointsGet = this.attachMovie("AnimaPointsGet", "pointget", this.getNextHighestDepth());
		}
		else if (id == 2)
		{
			pointsGet = this.attachMovie("SkillPointsGet", "pointget", this.getNextHighestDepth());
		}
        this.globalToLocal(pos);
        pointsGet._x = pos.x;
        pointsGet._y =  pos.y - 100;
        pointsGet._xscale = 50;
        pointsGet._yscale = 50;
        pointsGet.play();

        Utils.PlayFeedbackSound("sfx/gui/gui_skill_point_get.wav");
    }
}
*/
/// every time there is a change to the screen or there is an onload, Layout is called
function Layout()
{
    var visibleRect:Object = Stage["visibleRect"];
    var x:Number = visibleRect.x;
    var y:Number = visibleRect.y;
    m_ScreenWidth = visibleRect.width;
    var height:Number = visibleRect.height;

	var segmentWidth:Number = m_ScreenWidth / m_NumSegments
    m_Background._xscale = m_ScreenWidth;
    m_Background._x = 0;
    
	m_XPBarSegment_0._x = 0;
	m_XPBarSegment_0._xscale = segmentWidth;
	m_Handle_0._x = segmentWidth - 2;
	
	m_XPBarSegment_1._x = segmentWidth;
	m_XPBarSegment_1._xscale = segmentWidth;
	m_Handle_1._x = (segmentWidth * 2) - 2;
	
	m_XPBarSegment_2._x = (segmentWidth * 2);
	m_XPBarSegment_2._xscale = segmentWidth;
	m_Handle_2._x = m_ScreenWidth - 5;
    //i_XPHook._x = m_XPBar.i_Bar.getBounds(this).xMax;
   // i_XPHook._y = m_XPBar._y;
    
    
}

function ShowXPFIFO(xp:Number)
{
    var newXP:Number = xp - m_LastXP;
    if (newXP <= 0)
    {
        return;
    }
    
    var xpNum:MovieClip = this["i_XPNumber"];
    
    if (xpNum)
    {
        if (xpNum._alpha > (100 - m_FIFOOverwriteThreshold) )
        {
            xpNum["xp"] += newXP;
            xpNum.textField.text = "+" + xpNum["xp"] ;
            return;
        }
        else
        {
            m_UID++;
            xpNum._name = "i_XPNumber"+m_UID; 
        }
    }
    
    var xpFIFO:MovieClip = this.attachMovie("_Number", "i_XPNumber", this.getNextHighestDepth());
    xpFIFO["xp"] = newXP;
	xpFIFO.textField.autoSize = "right";
    xpFIFO.textField.text = "+" + newXP;
	
	var xpFIFOX:Number = m_CurrentXPBar.i_Bar.getBounds(this).xMax
	var maxXpFIFOX:Number = Stage["visibleRect"].width - xpFIFO._width;
	if (xpFIFOX < xpFIFO._width)
	{
		xpFIFOX = xpFIFO._width - 25; // 25 is the with of the xp text
	}
	else if (xpFIFOX > maxXpFIFOX)
	{
		xpFIFOX = maxXpFIFOX + 25; // 25 is the with of the xp text
	}
	
    xpFIFO._x = xpFIFOX; // m_CurrentXPBar.i_Bar.getBounds(this).xMax
    xpFIFO._y = m_CurrentXPBar._y;
    xpFIFO.tweenTo( 1.4, { _alpha:0, _xscale:120, _yscale:120, _y:m_CurrentXPBar._y -150 }, None.easeNone);
    xpFIFO.onTweenComplete = function()
    {
        this.removeMovieClip();
    }
}

function UpdateXPBar( xp:Number, showFIFO:Boolean )
{
    var xpLevelRatio = com.GameInterface.Utils.GetGameTweak("XPLevelRatio");
	var segmentRatio:Number = xp % (xpLevelRatio)
	var segmentsDone = ((xp - segmentRatio) / xpLevelRatio) % m_NumSegments
    var xpLevel:Number = (xp % xpLevelRatio) / xpLevelRatio
	var frame:Number = Math.floor( ( xpLevel ) * (m_TotalFrames));

	for (var i:Number = 0; i < m_NumSegments; i++ )
	{
		if (i <= segmentsDone)
		{
			var loopSegment:MovieClip = this["m_XPBarSegment_" + i];
			loopSegment._visible = true;
			loopSegment.gotoAndStop(m_TotalFrames);
			this["m_Handle_"+i].gotoAndStop( "active" );
		}
		else
		{
			var loopSegment:MovieClip = this["m_XPBarSegment_" + i];
			loopSegment._visible = false;
			this["m_Handle_"+i].gotoAndStop( "inactive" );
		}
	}
	
	m_CurrentXPBar = this["m_XPBarSegment_" + segmentsDone];
	/// get the segment to update
	//m_CurrentXPBar = SetAndReturnActiveSegment( Math.ceil(xpLevel * 3) );

    var oldPos = m_CurrentXPBar.i_Bar.getBounds( this );
    m_CurrentXPBar.gotoAndStop( (frame % 500) );
    
    if (showFIFO)
    {
        ShowXPFIFO( xp );
    }
    m_LastXP = xp;
    
    var newPos = m_CurrentXPBar.i_Bar.getBounds(this);
    m_XPBarHook._x = newPos.xMax;
     
    // Show effect if not too small chunk.
    var size = (oldPos.xMax - oldPos.xMin) - (newPos.xMax - newPos.xMin);

    if( size < -15 )
    {
        var y:Number = m_CurrentXPBar._y;
        var height:Number = m_CurrentXPBar._height
        var clip:MovieClip = createEmptyMovieClip( "Fade", getNextHighestDepth() );
        clip.beginFill(0xFFFFFF);
        clip.lineTo(size, 0);
        clip.lineTo(size, height);
        clip.lineTo(0, height);
        clip.lineTo(0, 0);
        
        clip._x = newPos.xMax
        clip._y = y

        clip.tweenTo( 1, { _alpha:0 }, None.easeNone);
        clip.onTweenComplete = function()
        {
            this.removeMovieClip();
        }
    }
}

