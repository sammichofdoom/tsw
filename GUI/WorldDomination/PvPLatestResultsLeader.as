//Class
class GUI.WorldDomination.PvPLatestResultsLeader extends MovieClip
{
    //Properties
    private var m_DragonIcon:MovieClip;
    private var m_TemplarsIcon:MovieClip;
    private var m_IlluminatiIcon:MovieClip;
    private var m_FactionIconsArray:Array;
    
    //Constructor
    public function PvPLatestResultsLeader()
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
    }

   /**
    *  This function uses the Faction global enum to reveal one of the faction icons while hiding the others.
    *  
    *  @param   faction:Number
    *           1:  _global.Enums.Factions.e_FactionDragon
    *           2:  _global.Enums.Factions.e_FactionTemplar
    *           3:  _global.Enums.Factions.e_FactionIlluminati
    **/
   
    //Set Leader
    public function SetLeader(faction:Number):Void
    {
        for (var i:Number = 0; i < m_FactionIconsArray.length; i++)
        {
            m_FactionIconsArray[i]._visible = (i + 1 == faction) ? true : false;
        }
    }
}