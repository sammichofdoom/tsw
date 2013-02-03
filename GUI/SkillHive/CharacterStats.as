import GUI.SkillHive.StatPage
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import com.GameInterface.Skills;
import com.GameInterface.Log;
import com.Utils.ImageLoader;
import com.Utils.LDBFormat;

class GUI.SkillHive.CharacterStats extends StatPage
{
    /// objects
    private var m_StatPageItems:Array;
    private var m_LabelObject:Object = {};
    private var m_StatPagesObject:Object = { };
    
    
    // movieclips
    private var m_CharacterStatsPane:MovieClip;
    private var m_ContentClip:MovieClip;
    private var m_StatPage:MovieClip
    
    // control
    private var m_CurrentStatPageIndex:Number = 3;
    private var m_PanelTweenSpeed:Number = 0.4
    
    /// layoup
    private var m_StatPageItemHeight:Number = 19; //height of one stat in the statpage
    
    public function CharacterStats( characterStatsPane:MovieClip  )
    {
        m_CharacterStatsPane = characterStatsPane;
        m_ContentClip = m_CharacterStatsPane["i_Content"];
        
        m_StatPage = m_ContentClip.createEmptyMovieClip( "i_StatPage", m_ContentClip.getNextHighestDepth() );
        
        super.InitializeLabels(m_LabelObject, m_StatPagesObject);
        
        CreatePaperDoll();
        CreateStatPage();
        
    }
    
    public function SetCharacterName(name:String) : Void
    {
        m_ContentClip.i_CharacterName.text = name;
    }
    
    public function SetFactionName(playerFaction:Number):Void
    {
        var factionName:String;
        
        switch(playerFaction)
        {
            case _global.Enums.Factions.e_FactionDragon:        factionName = LDBFormat.LDBGetText( "FactionNames", "Dragon" );
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionIlluminati:    factionName = LDBFormat.LDBGetText( "FactionNames", "Illuminati" );
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionTemplar:       factionName = LDBFormat.LDBGetText( "FactionNames", "Templars" );
																break;
        }
            
        m_ContentClip.i_FactionName.text = factionName;
    }
    
    private function CreatePaperDoll() : Void
    {
        Log.Info2("CharacterStats", "CreatePaperDoll - characterID= "+characterID);
        var characterID:com.Utils.ID32 = com.GameInterface.Game.Character.GetClientCharID();
        ImageLoader.RequestRDBImage( characterID , this, "SlotCharacterLoaded"); 
    }
    
    /**
     * Attaches a dropdown to the m_StatPage MovieClip and draws the stats on it when requested
     */
    private function CreateStatPage() : Void
    {
        Log.Info2("CharacterStats", "CreateStatPage()");
        
        if (Stage["visibleRect"].height < 820)
        {
            m_StatPage._y = 480;
        }
        else
        {
            m_StatPage._y = 500;
        }
        
        m_StatPageItems = [ m_TDB_Offense, m_TDB_Defense, m_TDB_Healing ];

        var dropDown:MovieClip = m_StatPage.attachMovie("LightDropdownMenu", m_DropDownName, m_StatPage.getNextHighestDepth(), { dropdown:"ScrollingList", itemRenderer:"ListItemRenderer", _x:20, _y:40  } );
        dropDown.dataProvider = m_StatPageItems;
        dropDown.direction = "down";
        dropDown.rowCount = m_StatPageItems.length;
        dropDown.selectedIndex = m_CurrentStatPageIndex;
        dropDown.addEventListener("select", this, "OnDropdownSelection");
       
        UpdateStatPage( m_CurrentStatPageIndex );
    }
    
    public function SlotCharacterLoaded(url:String, succeded:Boolean)
    {
        Log.Info2("CharacterStats", "SlotCharacterLoaded(" + url + ", " + succeded + ") ");
        if (succeded)
        {
            var moviecliploader:MovieClipLoader = new MovieClipLoader();
            moviecliploader.loadClip(url, m_ContentClip.i_PaperdollContainer); 
            
            if (Stage["visibleRect"].height < 820)
            {
                m_ContentClip.i_PaperdollContainer._xscale = 75;
                m_ContentClip.i_PaperdollContainer._yscale = 75;
                m_ContentClip.i_PaperdollContainer._x = 40;
                m_ContentClip.i_PaperdollContainer._y = 115;
                m_ContentClip._y = -110;
            }
            else
            {
                m_ContentClip.i_PaperdollContainer._y = -30;
            }
        }
    }
    
    
      /// Updates the content of the stat page when a new page is selected
    /// @param index:Number - the index in the m_StatPageItems to load
    private function UpdateStatPage( index:Number ) 
    {
        m_CurrentStatPageIndex = index;
    //    m_PanelHeight = GetStatPageHeight( m_CurrentStatPageIndex );
    //    m_StatPage["height"] = m_PanelHeight; /// must store on object for scope issues

        /// setup the new page
        var currentPanelArray:Array = m_StatPagesObject[ m_StatPageItems[ index ] ];
        var newContent = m_StatPage.createEmptyMovieClip("temp", m_StatPage.getNextHighestDepth() );
        
        /// draw the stats in the new content       
        for ( var i:Number = 0; i < currentPanelArray.length; i++)
        {
            var statItem:MovieClip = newContent.attachMovie( "StatItem", "stat_" + i, newContent.getNextHighestDepth());
            statItem._y = 70 + ( i * m_StatPageItemHeight );
            statItem._x = 20;
            
            statItem.description.text = LDBFormat.LDBGetText("SkillTypeNames", currentPanelArray[i].skillID);
            statItem.stat.text =  Skills.GetSkill(currentPanelArray[i].skillID);
            currentPanelArray[i].textField = statItem.stat; /// add a backreference to the text to use for realtime updates
        }
      
        // if there is a panel open allready, remove it and add the newly created instead
        if ( m_StatPage.i_Content )
        {
            /// tween the old content out and delete it
            var oldContent:MovieClip = m_StatPage.i_Content;
            var oldHeight:Number = oldContent._height;
            oldContent.tweenTo( m_PanelTweenSpeed / 2, { _alpha:0 }, None.easeNone );
            oldContent.onTweenComplete = function()
            {
                this.removeMovieClip();
                //Remove the focus from the dropdown after tweening
                Selection.setFocus(null);
            }
        }

        newContent._name = "i_Content";
        newContent._alpha = 0;
        newContent.tweenTo(m_PanelTweenSpeed, { _alpha:100 }, None.easeNone );
        newContent.onTweenComplete = undefined;
    }

    /// updates the statpage wnhen a new item is selected from the dropdown
    /// @param event:Object - The Scaleform event object containing type and target
    private function OnDropdownSelection(event:Object)
    {
        var index:Number = event.target.selectedIndex;
         if (index != m_CurrentStatPageIndex)
        {
            UpdateStatPage( index );
            Selection.setFocus( null);
        }
      /*  else if(!event.target.isOpen)
        {
            Selection.setFocus( null);
        }
        */
    }
    
    /// when an update to a skill is received
    /// checks if the stat is visible and writes to it, if not it stores the updated skill
    /// @param updatedSkill:Number - the id of the skill to update
    private function SlotSkillUpdated(updatedSkill:Number)
    {
        var skill:Object = m_LabelObject[ updatedSkill ]
        if (skill.textField != null)
        {
            skill.textField.text = Skills.GetSkill( updatedSkill );
        }
    }
    
}