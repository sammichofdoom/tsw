//Imports
import com.Utils.Colors;
import GUI.PvPScoreboard.TableRow;
import GUI.PvPScoreboard.Header;
import com.Utils.Faction;
import com.Utils.ID32;
import com.Utils.Format;
import GUI.PvPScoreboard.PvPScoreboardContent;

//Class
class GUI.PvPScoreboard.TableRowHeader extends MovieClip
{
    //Constants
    private static var DRAGON_FONT_SIZE:Number = 24;
    private static var TEMPLARS_FONT_SIZE:Number = 24;
    private static var ILLUMINATI_FONT_SIZE:Number = 26;
    
    private static var DRAGON_LABEL_Y:Number = 3;
    private static var TEMPLARS_LABEL_Y:Number = 5;
    private static var ILLUMINATI_LABEL_Y:Number = 1;
    
    private static var LABEL_COLOR:Number = 0xFFFFFF;
    private static var LABEL_X:Number = 47;
    
    //Properties
    private var m_FactionIconContainer:MovieClip;
    private var m_Label:TextField;
    private var m_Background:MovieClip;
    
    //Constructor
    public function TableRowHeader()
    {
        super();
    }
    
    //Setup Header
    public function SetupHeader(faction:Number, iconClipName:String, backgroundColor:Number):Void
    {
        m_FactionIconContainer = createEmptyMovieClip("m_FactionIconContainer", getNextHighestDepth());
        
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        
        m_Label = createTextField("m_Label", getNextHighestDepth(), LABEL_X, 0, 0, 0);
        m_Label.autoSize = "left";
        m_Label.textColor = LABEL_COLOR;
        
        var textFormat:TextFormat = m_Label.getTextFormat();
        
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        icon.SetInstance(PvPScoreboardContent.RDB_DRAGON_ICON);
                                                                m_Label._y = DRAGON_LABEL_Y;
                                                                textFormat.font = Header.DRAGON_FONT;
                                                                textFormat.size = DRAGON_FONT_SIZE;
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionTemplar:       icon.SetInstance(PvPScoreboardContent.RDB_TEMPLARS_ICON);
                                                                m_Label._y = TEMPLARS_LABEL_Y;
                                                                textFormat.font = Header.TEMPLARS_FONT;
                                                                textFormat.size = DRAGON_FONT_SIZE;
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionIlluminati:    icon.SetInstance(PvPScoreboardContent.RDB_ILLUMINATI_ICON);
                                                                m_Label._y = ILLUMINATI_LABEL_Y;
                                                                textFormat.font = Header.ILLUMINATI_FONT;
                                                                textFormat.size = DRAGON_FONT_SIZE;
        }
        
        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), m_FactionIconContainer);
        
        m_FactionIconContainer._xscale = m_FactionIconContainer._yscale = 25;
        m_FactionIconContainer._x = 12;
        m_FactionIconContainer._y = 6;
        
        m_Label.text = Faction.GetName(faction);
        m_Label.setTextFormat(textFormat);
        
        Colors.ApplyColor(m_Background, backgroundColor);
    }
}