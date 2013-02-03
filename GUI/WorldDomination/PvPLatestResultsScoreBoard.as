//Imports
import com.Utils.LDBFormat;
import GUI.WorldDomination.MiniMapReward;
import com.Components.BuffComponent;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Spell;
import com.GameInterface.Tooltip.TooltipInterface;

//Class
class GUI.WorldDomination.PvPLatestResultsScoreBoard extends MovieClip
{
    //Constants       
    private static var WIN:String = LDBFormat.LDBGetText("WorldDominationGUI", "win");
    private static var WINS:String = LDBFormat.LDBGetText("WorldDominationGUI", "wins");
    
    private static var BUFF_SCALE:Number = 50;
    private static var BUFF_GAP:Number = 5;
    private static var BUFF_VERTICAL_MODIFICATION:Number = 3;
    private static var BUFF_INITIAL_POSITION: Number = 155;
    
    //Properties
    private var m_IlluminatiIcon:MovieClip;
    private var m_DragonIcon:MovieClip;
    private var m_TemplarsIcon:MovieClip;
    private var m_ScoreBoardLabel:TextField;
    private var m_BuffsContainer:MovieClip;
    private var m_FactionIconsArray:Array;
    private var m_BuffClipsArray:Array;
    
    
    //Constructor
    public function PvPLatestResultsScoreBoard()
    {
        super();
        
        Init();
    }
    
    //Init
    private function Init():Void
    {
        m_FactionIconsArray = new Array(m_DragonIcon, m_TemplarsIcon, m_IlluminatiIcon);
        
        for (var i:Number = 0; i < m_FactionIconsArray.length; i++)
        {
            m_FactionIconsArray[i]._visible = false;
        }   
        m_BuffClipsArray = new Array();
    }
   
    //Set Faction
    public function SetFaction(faction:Number):Void
    {
        ClearBuffs();
        for (var i:Number = 0; i < m_FactionIconsArray.length; i++)
        {
            m_FactionIconsArray[i]._visible = (i + 1 == faction) ? true : false;
        }
    }

    //Set Wins
    public function SetWins(wins:Number):Void
    {
        m_ScoreBoardLabel._visible = true;
        m_BuffsContainer._visible = false;
        
        var winnings:String = (wins == 1) ? WIN : WINS;
        
        m_ScoreBoardLabel.text = wins + " " + winnings;
    }
    
    //Set Buffs
    public function SetBuffs(buffs:Array):Void
    {
        m_ScoreBoardLabel._visible = false;
        m_BuffsContainer._visible = true;
        
        ClearBuffs();
        
        for (var i:Number = 0; i < buffs.length; i++)
        {
            var buff:BuffComponent = BuffComponent(attachMovie("BuffComponent", "m_Buff_" + buffs[i], getNextHighestDepth()));
            buff.SetBuffData(Spell.GetBuffData(buffs[i]));
            buff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
            
            buff._xscale = buff._yscale = BUFF_SCALE;
            buff._x = BUFF_INITIAL_POSITION - (buff._width * i  + BUFF_GAP * i);
            buff._y -= BUFF_VERTICAL_MODIFICATION;
            
            m_BuffClipsArray.push(buff);
        }
    }
    
    private function ClearBuffs():Void
    {
        for (var i:Number = 0; i < m_BuffClipsArray.length; ++i )
        {
            var buff:BuffComponent = m_BuffClipsArray[i];
            if (buff)
            {
                buff.Remove();
            }
        }
        m_BuffClipsArray = new Array();
    }
    
}
