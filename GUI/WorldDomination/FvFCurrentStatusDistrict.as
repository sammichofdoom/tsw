//Imports
import com.Utils.LDBFormat;
import GUI.WorldDomination.FvFStatus;

//Class
class GUI.WorldDomination.FvFCurrentStatusDistrict extends MovieClip
{
    //Properties
    private var m_UncontrolledIcon:MovieClip;
    private var m_IlluminatiIcon:MovieClip;
    private var m_DragonIcon:MovieClip;
    private var m_TemplarsIcon:MovieClip;
    private var m_DistrictName:TextField;
    private var m_FactionName:TextField;
    private var m_FactionsArray:Array;
    
    //Constructor
    public function FvFCurrentStatusDistrict()
    {
        super();
        
        Init();
    }
    
    //Init
    private function Init():Void
    {
        m_FactionsArray = new Array();
        m_FactionsArray.push({faction: m_UncontrolledIcon, name: FvFStatus.UNCONTROLLED, textColor: 0xCCCCCC});
        m_FactionsArray.push({faction: m_DragonIcon, name: FvFStatus.DRAGON, textColor: 0x61FD32});
        m_FactionsArray.push({faction: m_TemplarsIcon, name: FvFStatus.TEMPLARS, textColor: 0xFC8585});
        m_FactionsArray.push({faction: m_IlluminatiIcon, name: FvFStatus.ILLUMINATI, textColor: 0xA3EEFF});
        
        for (var i:Number = 0; i < m_FactionsArray.length; i++)
        {
            m_FactionsArray[i].faction._visible = false;
        }   
    }
    
   /**
    *   This function uses the Faction global enum to reveal one of the faction icons while hiding the others and to set the faction's name.
    *  
    *   @param  faction:Number
    *           0:  uncontrolled district
    *           1:  _global.Enums.Factions.e_FactionDragon
    *           2:  _global.Enums.Factions.e_FactionTemplar
    *           3:  _global.Enums.Factions.e_FactionIlluminati  
    **/
   
    //Set Faction
    public function SetFaction(faction:Number):Void
    {
        for (var i:Number = 0; i < m_FactionsArray.length; i++)
        {
            if (i == faction)
            {
                m_FactionsArray[i].faction._visible = true;
                m_FactionName.text = m_FactionsArray[i].name;
                m_FactionName.textColor = m_FactionsArray[i].textColor;
            }
            else
            {
                m_FactionsArray[i].faction._visible = false;
            }
        }
    }
    
   /**
    *   This function sets the district name.
    *  
    *   @param  name:String
    *           Sets the text property of the m_DistrictName TextField
    **/
       
    //Set District
    public function SetDistrict(name:String):Void
    {
        m_DistrictName.text = name;
    }
}