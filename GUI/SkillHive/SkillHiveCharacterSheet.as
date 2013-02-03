import com.GameInterface.DistributedValue;
import com.Info.CharacterSheet.CharacterStats;
import mx.utils.Delegate;
import com.Utils.ImageLoader;
import com.GameInterface.Log;

class GUI.SkillHive.SkillHiveCharacterSheet
{
    /// strings
    public var m_Name:String = "CharacterSheet";
    private var m_TDB_PaperDollName:String = "PAPERDOLL";
    private var m_TDB_StatPageName:String = "CHARACTER STATS";
    private var m_TDB_FactionPageName:String = "FACTION";
    private var m_TDB_GearManagementPageName:String = "GEAR MANAGEMENT";
    private var m_TDB_ReputationPageName:String = "REPUTATION";
    private var m_TDB_TotalSkillpoint:String = "TOTAL SKILLPOINTS: ";
    private var m_TDB_HiveCompletion:String = "% HIVE COMPLETION"
    /// control
    
    /// objects
    private var m_Pages:Array;
    
    // MovieClips
    private var i_Content:MovieClip;

    public var m_StatPage:MovieClip;
    
    public function SkillHiveCharacterSheet( characterSheet:MovieClip )
    {
       Log.Info2("SkillHiveCharacterSheet", characterSheet);
      // super.init();
    }
    
    /// layout
    
    public function init()
    {
/*
        Log.Info2("SkillHiveCharacterSheet", "Started an instance of the skillHiveCharactersheet");
        
        var characterstats:CharacterStats = new CharacterStats(  );
        m_StatPage = i_Content.createEmptyMovieClip(
        characterstats.CreateStatPage( m_StatPage );
        //m_StatPage = CreateStatPage();
        //i_CharacterStats.i_Slider.i_Title.text = m_TDB_StatPage;
        //trace("i_CharacterStats.i_Slider.i_Title " + i_CharacterStats.i_Slider.i_Title + " i_CharacterStats " + i_CharacterStats);
        //trace("m_StatPage = " + m_StatPage);
        

  */  
    }
    

    
    public function SlotCharacterLoaded(url:String, succeded:Boolean)
    {
        Log.Info2("SkillHiveCharacterSheet", "SlotCharacterLoaded(" + url + ", " + succeded + ") ");
        if (succeded)
        {
            var moviecliploader:MovieClipLoader = new MovieClipLoader();
            moviecliploader.loadClip(url, i_Content.i_PaperdollContainer); 
            
            i_Content.i_PaperdollContainer._xscale = 85;
            i_Content.i_PaperdollContainer._yscale = 85;
        }
    }
    

    
    function SetTotalSkillpoints(newSkillPoints:Number)
    {
        //this.i_TotalSkillpointsText.text = m_TDB_totalSkillpoint + Math.round(newSkillPoints);
    }
    
    function SetSkillHiveCompletion(newCompletion:Number)
    {
        //this.i_HiveCompletionText.text = Math.round(newCompletion) + m_TDB_HiveCompletion;
    }
    
    public function SetName(newName:String) :String
    {
        Log.Info2("SkillHive", "SetName(" + newName + ")");
        i_Content.i_CharacterName.text = newName;
        return "Bibbelabeluba";
    }
    
    function GetWidth()
    {
       // return this.i_CharacterSheetBackground._width;
    }
    
    /// temporary methods to make the statpage work
    function GetLeftMenuIndex( name:String ) : Number { return 0; }
    function UpdateMenuSize(fromIndex:Number, toY:Number, speed:Number) : Void {}
    
}