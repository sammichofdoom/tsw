//Imports
import com.Utils.Colors;
import com.Utils.ID32;
import com.Utils.Format;
import GUI.PvPScoreboard.PvPScoreboardColors;
import GUI.PvPScoreboard.PvPScoreboardContent;

//Class
class GUI.PvPScoreboard.TableRow extends MovieClip
{
    //Constants
    public static var DRAGON_ICON_CLIP_NAME:String = "LogoDragon";
    public static var TEMPLARS_ICON_CLIP_NAME:String = "LogoTemplar";
    public static var ILLUMINATI_ICON_CLIP_NAME:String = "LogoIlluminati";
    
    private static var FACTION_HEADER_HEIGHT:Number = 35;
    
    //Properties
    private var m_TableRowHeader:MovieClip;
    private var m_Rank:MovieClip;
    private var m_PlayerName:MovieClip;
    private var m_Role:MovieClip;
    private var m_Damage:MovieClip;
    private var m_Healing:MovieClip;
    private var m_CrowdControl:MovieClip;
    private var m_DamageTaken:MovieClip;
    private var m_Kills:MovieClip;
    private var m_Death:MovieClip;
    private var m_DynamicPoints:MovieClip;
    private var m_Points:MovieClip;
    private var m_FieldsArray:Array;
    
    //Constructor
    public function TableRow()
    {
        super();
        
        m_FieldsArray = new Array(m_Rank, m_PlayerName, m_Role, m_Damage, m_Healing, m_CrowdControl, m_DamageTaken, m_Kills, m_Death, m_DynamicPoints, m_Points);
    }
    
    //Set Faction Header
    public function SetFactionHeader(faction:Number):Void
    {
        var backgroundColor:Number;
        var iconClipName:String;
        
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        backgroundColor = PvPScoreboardColors.DRAGON_BRIGHT_COLOR;
                                                                iconClipName = DRAGON_ICON_CLIP_NAME;
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionTemplar:       backgroundColor = PvPScoreboardColors.TEMPLARS_BRIGHT_COLOR;
                                                                iconClipName = TEMPLARS_ICON_CLIP_NAME;
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionIlluminati:    backgroundColor = PvPScoreboardColors.ILLUMINATI_BRIGHT_COLOR
                                                                iconClipName = ILLUMINATI_ICON_CLIP_NAME;
        }
        
        m_TableRowHeader = attachMovie("TableRowHeader", "m_TableRowHeader", getNextHighestDepth());
        m_TableRowHeader.SetupHeader(faction, iconClipName, backgroundColor);
    }
    
    //Set Row Colors
    public function SetRowColors(faction:Number, sortTarget:String, isPlayer:Boolean):Void
    {
        var playerColor:Number;
        var sortColor:Number;
        var factionColor:Number;
        
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        playerColor = PvPScoreboardColors.DRAGON_NEUTRAL_COLOR;
                                                                sortColor = PvPScoreboardColors.DRAGON_NEUTRAL_COLOR;
                                                                factionColor = PvPScoreboardColors.DRAGON_DARK_COLOR;
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionTemplar:       playerColor = PvPScoreboardColors.TEMPLARS_NEUTRAL_COLOR;
                                                                sortColor = PvPScoreboardColors.TEMPLARS_NEUTRAL_COLOR;
                                                                factionColor = PvPScoreboardColors.TEMPLARS_DARK_COLOR;
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionIlluminati:    playerColor = PvPScoreboardColors.ILLUMINATI_NEUTRAL_COLOR;
                                                                sortColor = PvPScoreboardColors.ILLUMINATI_NEUTRAL_COLOR;
                                                                factionColor = PvPScoreboardColors.ILLUMINATI_DARK_COLOR;
        }
        
        for (var i:Number = 0; i < m_FieldsArray.length; i++)
        {
            if (isPlayer)
            {
                Colors.ApplyColor(m_FieldsArray[i].m_Background, playerColor)
            }
            else
            {
                if (m_FieldsArray[i].name == sortTarget)
                {
                    Colors.ApplyColor(m_FieldsArray[i].m_Background, sortColor);
                }
                else
                {
                    Colors.ApplyColor(m_FieldsArray[i].m_Background, factionColor);
                }
            }
        }
    }
    
    //Set Rank Icon
    public function SetRankIcon(faction:Number):Void
    {
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        
        switch (faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        icon.SetInstance(PvPScoreboardContent.RDB_DRAGON_ICON);
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionTemplar:       icon.SetInstance(PvPScoreboardContent.RDB_TEMPLARS_ICON);
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionIlluminati:    icon.SetInstance(PvPScoreboardContent.RDB_ILLUMINATI_ICON);
        }
        
        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), m_Rank.m_IconContainer);
        
        m_Rank.m_IconContainer._xscale = m_Rank.m_IconContainer._yscale = m_Rank.m_Background._height - 6;
        m_Rank.m_IconContainer._x = m_Rank.m_Background._width / 2 - m_Rank.m_IconContainer._xscale / 2;
        m_Rank.m_IconContainer._y = 3;     
    }
    
    //Set Role Icon
    public function SetRoleIcon(role:Number):Void
    {
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        
        switch (role)
        {
            case _global.Enums.Class.e_Damage:  icon.SetInstance(7190654);
                                                break;
                                                
            case _global.Enums.Class.e_Tank:    icon.SetInstance(7190655);
                                                break;
                                                
            case _global.Enums.Class.e_Heal:    icon.SetInstance(7190657);
        }

        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), m_Role.m_IconContainer);
        
        m_Role.m_IconContainer._xscale = m_Role.m_IconContainer._yscale = m_Role.m_Background._height - 6;
        m_Role.m_IconContainer._x = m_Role.m_Background._width / 2 - m_Role.m_IconContainer._xscale / 2;
        m_Role.m_IconContainer._y = 3;
    }
}