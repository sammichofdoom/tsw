import com.GameInterface.Game.Camera;
import com.Utils.Colors;
import flash.filters.DropShadowFilter;
import com.Utils.LDBFormat;

var m_CompassClip:MovieClip;
var m_Marker:MovieClip;

var m_HighAlpha:Number = 30;
var m_LowAlpha:Number = 15;
var m_Alphas:Array;
var oldAngle:Number = 0;
var m_NumLines:Number = 25; /// the number of lines on screen, the highter density the harder
var m_LineDistance:Number = 8; /// whole number only, the distance nbetween the lines
var m_BasePosConstant:Number; /// a constant that will be used to find the position
//var m_LineHeight:Number = 20; /// well, the height of the lines
var m_CompassWidth:Number; // the widt of the movieclip, used to calculate the position of compass labels (N, E, S, W)
var m_CompassHeight:Number; // the height of the compass, used to calculate the height of the compass lines
var m_CompassFragment:Number; // 
var m_DegreeFragment:Number;
var m_MarkerColor:Number = Colors.e_ColorWhite;
var m_Format:TextFormat;
var m_Shadow:DropShadowFilter;

var m_North:MovieClip;
var m_South:MovieClip;
var m_East:MovieClip;
var m_West:MovieClip;

var m_NorthBasePos:Number;
var m_SouthBasePos:Number; 
var m_EastBasePos:Number;
var m_WestBasePos:Number;

var m_TDB_North:String = LDBFormat.LDBGetText("GenericGUI", "Compass_AbbreviationNorth");
var m_TDB_South:String = LDBFormat.LDBGetText("GenericGUI", "Compass_AbbreviationSouth");
var m_TDB_East:String = LDBFormat.LDBGetText("GenericGUI", "Compass_AbbreviationEast");
var m_TDB_West:String = LDBFormat.LDBGetText("GenericGUI", "Compass_AbbreviationWest");

function onLoad()
{
    Camera.RequestCameraPosRotUpdates( true );

    
    // get the size of the clip
    m_CompassWidth = this._width;
    m_CompassHeight = this._height;
    
    m_CompassFragment = m_CompassWidth / Math.PI
    m_DegreeFragment = m_CompassWidth / 120;

    m_NorthBasePos = 60;
    m_EastBasePos = 150;
    m_SouthBasePos = 240;
    m_WestBasePos = 330;

    
    /// holder for the lines
    m_CompassClip = this.createEmptyMovieClip("i_CompassClip", this.getNextHighestDepth());
    m_Marker = this.createEmptyMovieClip("i_Marker", this.getNextHighestDepth());
    m_Marker.lineStyle(2, m_MarkerColor);
    m_Marker.moveTo(m_CompassWidth / 2, 0);
    m_Marker.lineTo(m_CompassWidth / 2, m_CompassHeight);
    // Dropshadow
    m_Shadow = new DropShadowFilter( 1, 35, 0x000000, 0.7, 1, 2, 2, 3, false, false, false );

    // Headline style
    m_Format = new TextFormat;
    m_Format.font = "_StandardFont";
    m_Format.size = 15;
    m_Format.color = 0xFFFFFF;
	m_Format.bold = true;
    
    m_North = CreateDirectionClip("i_North", m_TDB_North)
    m_South = CreateDirectionClip("i_South", m_TDB_South);
    m_East = CreateDirectionClip("i_East", m_TDB_East);
    m_West = CreateDirectionClip("i_West", m_TDB_West);
    
    m_Alphas = [m_HighAlpha, m_LowAlpha];
    
    m_BasePosConstant = m_NumLines * m_LineDistance;
    
    this.onEnterFrame = getCompassFrame;
}

function CreateDirectionClip(name:String, txt:String) : MovieClip
{
    var clip:MovieClip = this.createEmptyMovieClip(name, this.getNextHighestDepth());
    var textField:TextField = clip.createTextField("i_Text", clip.getNextHighestDepth(), 0, 0, 0, 20);
    textField.autoSize = "center";
    textField.selectable = false;
    textField.setNewTextFormat(m_Format);
    textField.filters = [ m_Shadow ];
    textField.text = txt;
//    clip._visible = false;
    return clip;
}

function PositionLabels(clip:MovieClip, pos:Number, posBase:Number)
{
    var calcDegrees:Number = ((posBase + pos) % 360); /// some degrees

    if (calcDegrees < 120)
    {
        if (calcDegrees < 10)
        {
            clip._alpha = ( ( calcDegrees * 10 ) % 100 );
        }
        else if(calcDegrees > 110)
        {
            clip._alpha =  ( 100 - ( ( calcDegrees - 110 ) ) * 10);
        }
        else
        {
            clip._alpha = 100;
        }
        clip._x = calcDegrees * m_DegreeFragment
    }
    else if(clip._alpha > 0)
    {
        clip._alpha = 0;
    }
}

// updates the rotation of the compass to a frame (number) between 0 and 360 
function getCompassFrame()
{
    if (oldAngle != Camera.m_AngleY)
    {
        m_CompassClip.clear();
        oldAngle = Camera.m_AngleY;
        var degrees:Number = ((Math.round(( oldAngle * 180)  / Math.PI) + 360) % 360);

        var newPosBase:Number = (m_CompassFragment * oldAngle);
        

        PositionLabels(m_North, degrees, m_NorthBasePos );
        PositionLabels(m_South, degrees, m_SouthBasePos );
        PositionLabels(m_East, degrees, m_EastBasePos );
        PositionLabels(m_West, degrees, m_WestBasePos );

        for (var i:Number = 0; i < m_NumLines; i++ )
        {
            var basePos:Number = degrees + (m_LineDistance * i);
            var drawStop:Number = (basePos%m_BasePosConstant);

            m_CompassClip.lineStyle(1, Colors.e_ColorCompassLines, m_Alphas[ i%2 ] );
            m_CompassClip.moveTo(drawStop, 0)
            m_CompassClip.lineTo(drawStop, m_CompassHeight);
        }
    }
}