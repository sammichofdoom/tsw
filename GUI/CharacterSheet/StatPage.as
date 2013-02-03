import com.Utils.LDBFormat;
import flash.geom.Rectangle;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import gfx.utils.Delegate;
import mx.transitions.easing.*;

class GUI.CharacterSheet.StatPage extends UIComponent
{    
    private static var BACKGROUND_WIDTH:Number = 255;
    
    private var m_TDB_Offense:String;
    private var m_TDB_Defense:String;
    private var m_TDB_Healing:String;
    private var m_ScrollInterval:Number;
    private var m_StatPages:Object;
    private var m_Header:TextField;
    private var m_StatPage:MovieClip;
    private var m_ScrollBar:MovieClip;
    private var m_CloseButton:MovieClip;
    private var m_StatPageVisibleHeight:Number;
    public var m_StatPagePanelBackground:MovieClip;
    private var m_StatItems:Array;
    private var m_Weapons:Array;
    
    public function StatPage() 
    {
        super();
    }
    
    private function configUI():Void
    {
        m_StatPageVisibleHeight = m_StatPagePanelBackground._height;
        
        m_TDB_Offense = LDBFormat.LDBGetText("GenericGUI", "OffensiveStats");
        m_TDB_Defense = LDBFormat.LDBGetText("GenericGUI", "DefensiveStats");
        m_TDB_Healing = LDBFormat.LDBGetText("GenericGUI", "HealingStats");
        
        m_ScrollInterval = 5;
        
        m_Header.text = LDBFormat.LDBGetText("GenericGUI", "CharacterStats"); 
        InitializeLabels();
        
        m_StatPagePanelBackground.onPress = function() { };
        m_StatItems = new Array();
        
        m_Weapons = new Array();   
    }
    
    public function SetWeapons(weapons:Array)
    {
        if (m_Weapons != weapons)
        {
            m_Weapons = weapons;
            Layout();
        }
    }
    
    private function Layout()
    {
        
        if (this["mask"])
        {
            this["mask"].removeMovieClip();
            
            if (m_StatPage)
            {
                m_StatPage.setMask(null);
            }
        }
        
        if (m_ScrollBar)
        {
            m_ScrollBar.removeMovieClip();
            m_ScrollBar = undefined;
        }
        
        RemoveStatPage();
        m_StatPage = this.createEmptyMovieClip("statpage", this.getNextHighestDepth());
        m_StatPage._x = 10;
        m_StatPage._y = 10;
        
        CreateStatCluster( m_TDB_Offense );
        CreateStatCluster( m_TDB_Defense );
        CreateStatCluster( m_TDB_Healing );
        
        if (m_StatPage._height > m_StatPageVisibleHeight)
        {
            var mask:MovieClip = com.GameInterface.ProjectUtils.SetMovieClipMask(m_StatPage,m_StatPage._parent, m_StatPageVisibleHeight - 45, m_StatPagePanelBackground._width);
            mask._y = 35;
            mask._x = 0;
            
            m_ScrollBar = this.attachMovie("ScrollBar", "i_ScrollBar", this.getNextHighestDepth());
            m_ScrollBar._y = 30;
            m_ScrollBar._x = m_StatPagePanelBackground._width - m_ScrollBar._width - 12; 
            
            var maxScroll:Number = Math.ceil((m_StatPage._height - m_StatPageVisibleHeight)/m_ScrollInterval) + 8;//Math.ceil(m_StatPage._height - (m_StatPage._height - m_StatPageVisibleHeight));
            m_ScrollBar.setScrollProperties( m_StatPageVisibleHeight, 0, maxScroll, m_ScrollInterval); 
            m_ScrollBar._height =  mask._height + 6;
            m_ScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
            m_ScrollBar.position = 0; 
            m_ScrollBar.trackMode = "scrollPage"
            m_ScrollBar.trackScrollPageSize = m_StatPageVisibleHeight;
            m_ScrollBar.disableFocus = true;
    
            Mouse.addListener( this );
        }
        else
        {
            // removes the mouselistener if we do not need it
            // there is no way of knowing if there is a listener, so we attempt to remove it even if it does not exist
            Mouse.removeListener( this );
        }
        
        m_StatPagePanelBackground._width = BACKGROUND_WIDTH;
        m_CloseButton._x = m_StatPagePanelBackground._width - 7 - m_CloseButton._width;
    }

    function OnScrollbarUpdate(event:Object) : Void
    {
        var target:MovieClip = event.target;
        var pos:Number = event.target.position;
            
        m_StatPage._y = -(pos * m_ScrollInterval) + 10;
        
        Selection.setFocus( null );
    }
    
    private function onMouseWheel( delta:Number )
    {
        if (this.hitTest(_root._xmouse, _root._ymouse))
        {
            var newPos:Number = m_ScrollBar.position + -(delta* m_ScrollInterval);
            var event:Object = { target : m_ScrollBar };
            
            m_ScrollBar.position = Math.min(Math.max(0.0, newPos), m_ScrollBar.maxPosition);
            
            OnScrollbarUpdate(event);
        }
    }
    
    
    private function RemoveStatPage():Void
    {
        if (m_StatPage)
        {
            for (var i:Number = 0; i < m_StatItems.length; ++i )
            {
                if (m_StatItems[i])
                {
                    m_StatItems[i].ClearSignals();
                    m_StatItems[i].removeMovieClip();
                    m_StatItems[i] = undefined;
                }
            }
            m_StatItems = new Array();
            
            m_StatPage.removeMovieClip();
            m_StatPage = undefined;
        }
    }
    
    private function CreateStatCluster(stat:String)
    {
        var statObject:Object = m_StatPages[ stat ];
 
        var headerName:String = "Header_" + stat;
        var header:MovieClip = this[headerName];
        if (header == undefined)
        {
            header = m_StatPage.attachMovie("HeaderClip", headerName, m_StatPage.getNextHighestDepth());
            header["ref"] = this;
            header.m_Name = statObject.name;
            header._y = m_StatPage._height;
            header.onRelease = function()
            {
                this["ref"].m_StatPages[ this.m_Name ].isOpen = ! this["ref"].m_StatPages[ this.m_Name ].isOpen;
                this["ref"].Layout();
            }
            
            header.textField.htmlText = "<b>" + statObject.name + "</b>";
        }
        
        if (statObject.isOpen)
        {
            var stats:MovieClip = m_StatPage.createEmptyMovieClip("Stats_" + stat, m_StatPage.getNextHighestDepth());
            stats._y = header._y;
            header.arrow._rotation = (statObject.isOpen ? 90 : 0);
            header.arrow._x += 9;  
        
            ///Draw The stats
            for (var i:Number = 0; i < statObject.data.length; i++ )
            {
                var skill:Number = statObject.data[i];
                var statItemName:String = "statItem_" + skill;
                
                var statItem:MovieClip = stats.attachMovie("StatItem", statItemName, stats.getNextHighestDepth());
                statItem.SetSkill(skill);
                statItem.SetWeapons(m_Weapons);
                statItem._y = stats._height;
                
                m_StatItems.push(statItem);
            }
        }
    }

    private function InitializeLabels()
    {
        m_StatPages = new Object();
        
        var offsenseArray:Array = new Array();
        var defenseArray:Array = new Array();
        var healingArray:Array = new Array();

        m_StatPages[ m_TDB_Offense ] = new Object();
        m_StatPages[ m_TDB_Offense ].data = offsenseArray;
        m_StatPages[ m_TDB_Offense ].isOpen = false;
        m_StatPages[ m_TDB_Offense ].name = m_TDB_Offense
        
        m_StatPages[ m_TDB_Defense ] = new Object();
        m_StatPages[ m_TDB_Defense ].data = defenseArray;
        m_StatPages[ m_TDB_Defense ].isOpen = true;
        m_StatPages[ m_TDB_Defense ].name = m_TDB_Defense;
        
        m_StatPages[ m_TDB_Healing ] = new Object();
        m_StatPages[ m_TDB_Healing ].data = healingArray;
        m_StatPages[ m_TDB_Healing ].isOpen = false;
        m_StatPages[ m_TDB_Healing ].name = m_TDB_Healing;
        
        offsenseArray.push( _global.Enums.SkillType.e_Skill_CombatPower );
        offsenseArray.push( _global.Enums.SkillType.e_Skill_AttackRating );
        offsenseArray.push( _global.Enums.SkillType.e_Skill_WeaponPower );
        offsenseArray.push( _global.Enums.SkillType.e_Skill_CriticalRating);
        offsenseArray.push( _global.Enums.SkillType.e_Skill_CriticalChance );
        offsenseArray.push( _global.Enums.SkillType.e_Skill_CritPowerRating );
        offsenseArray.push( _global.Enums.SkillType.e_Skill_CritPower );
        offsenseArray.push( _global.Enums.SkillType.e_Skill_HitRating );
        offsenseArray.push( _global.Enums.SkillType.e_Skill_EnemyEvadeChance );
        offsenseArray.push( _global.Enums.SkillType.e_Skill_PenetrationRating );

        defenseArray.push( _global.Enums.SkillType.e_Skill_EvadeRating );
        defenseArray.push( _global.Enums.SkillType.e_Skill_EvadeChance );
        defenseArray.push( _global.Enums.SkillType.e_Skill_PhysicalMitigation )
        defenseArray.push( _global.Enums.SkillType.e_Skill_MagicalMitigation )
        defenseArray.push( _global.Enums.SkillType.e_Skill_DefenseRating );
        defenseArray.push( _global.Enums.SkillType.e_Skill_EnemyCritChance );
        defenseArray.push( _global.Enums.SkillType.e_Skill_BlockRating );

        healingArray.push( _global.Enums.SkillType.e_Skill_HealingPower );
        healingArray.push( _global.Enums.SkillType.e_Skill_HealingRating );
        healingArray.push( _global.Enums.SkillType.e_Skill_HealingWeaponPower )
        healingArray.push( _global.Enums.SkillType.e_Skill_HealingCriticalRating )
        healingArray.push( _global.Enums.SkillType.e_Skill_HealingCriticalChance );
        healingArray.push( _global.Enums.SkillType.e_Skill_HealingCritPowerRating );
        healingArray.push( _global.Enums.SkillType.e_Skill_HealingCritPower );
    }
}