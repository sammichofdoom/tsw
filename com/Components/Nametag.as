import com.Utils.GlobalSignal;
import flash.filters.GlowFilter;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import flash.geom.Point;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.TeamInterface;
import com.GameInterface.Nametags;
import com.GameInterface.DistributedValue;
import com.Components.StatBar;
import com.Components.CastBar;
import com.Components.Resources;
import com.Utils.ID32;
import gfx.core.UIComponent;
import gfx.controls.Label;
import com.Utils.Signal;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;

class com.Components.Nametag extends UIComponent
{
    private var m_Name:Label;
    private var m_Title:MovieClip;
    private var m_Guild:MovieClip;
    private var m_DistanceToNPC:MovieClip;
    private var m_FactionRankIcon:MovieClip;
    private var m_HealthBar:MovieClip;
    private var m_CastBar:MovieClip;
    private var m_Resources:MovieClip;
    private var m_States:MovieClip;
    private var m_MonsterBand:MovieClip;
	private var m_LockedIcon:MovieClip;
    
    private var m_IsNPC:Boolean;
    private var m_IsSimpleDynel:Boolean;
    private var m_CheckDistance:Boolean;
    private var m_LeftAlignXCollapsed:Number; //X of aligned text/clips
    private var m_LeftAlignXExpanded:Number; //X of aligned text/clips
    private var m_MonsterBandPush:Number;
    private var m_IconTextPadding:Number;
    private var m_Distance:Number;
    private var m_IsTarget:Boolean;
    private var m_AggroStanding:Number;
    private var m_ForceAlive:Boolean;
    private var m_DetailedComponents:Array;
	private var m_IsLocked:Boolean;
    
    private var m_ComponentsLoaded:Boolean;
    private var m_ShowHealthBarCollapsed:Boolean;
    
    private var m_MaxScale:Number;
    private var m_MinScale:Number;
    private var m_TweenTime:Number;
	
	private var m_DistanceY:Number;

    private var GRADE_NORMAL:Number = 0;
    private var GRADE_SWARM:Number = 1;
    private var GRADE_ELITE:Number = 2;
	
	private var m_HealthBarWidth:Number
    
    private var m_Character:Character;
    private var m_Dynel:Dynel;
    private var m_DynelID:ID32;
    private var m_NametagCategory:Number;
    private var m_NametagColor:Number;
    private var m_NametagIconColor:Number;
	private var m_ClientCharacter:Character;
    private var m_RemoveOnDeselect;
    
    public var SignalRemoveNametag:Signal;
    
    public static var SHOW_HEALTHBAR_NONE = 0;
    public static var SHOW_HEALTHBAR_FRIENDS = 1;
    public static var SHOW_HEALTHBAR_ENEMIES = 2;
    public static var SHOW_HEALTHBAR_ALL = 3;

    public function Nametag()
    {
		
        super();
		m_IsLocked = false;
        m_IsNPC = true;
        m_IsSimpleDynel = false;
        m_CheckDistance = true;
        m_DetailedComponents = new Array();
        m_LeftAlignXCollapsed = 0;
        m_LeftAlignXExpanded = 0;
        m_IconTextPadding = 10;
        m_RemoveOnDeselect = false;
        SignalRemoveNametag = new Signal();
        m_NametagCategory = 0;
        m_NametagColor = 0;
        m_Distance = 0;
        m_IsTarget = false;
        m_AggroStanding = -1;
        m_ComponentsLoaded = false;
        m_ShowHealthBarCollapsed = false;
        m_TweenTime = 0.5;
        m_MonsterBandPush = 0;
		
		m_HealthBarWidth = 121;

        m_ClientCharacter = Character.GetClientCharacter();
        
        m_MaxScale = 140;
        m_MinScale = 60;
                
        m_ClientCharacter.SignalStatChanged.Connect(SlotClientCharacterStatChanged, this);
		_visible = false;
		_alpha = 0;
    }
    
    public function SetDynelID(dynelID:ID32)
    {
        //Connect to the character
        m_DynelID = dynelID;
        m_Dynel = Dynel.GetDynel(dynelID);
            
        if (m_Dynel != undefined)
        {
            m_Dynel.SignalStatChanged.Connect(SlotDynelStatChanged, this);
			m_Dynel.SignalLockedToTarget.Connect(SlotLockedToTarget, this);
            
            m_IsSimpleDynel = dynelID.GetType() != _global.Enums.TypeID.e_Type_GC_Character;
            
            if (!m_IsSimpleDynel)
            {
                m_Character = Character.GetCharacter(dynelID);
                var aggroStanding = com.GameInterface.Nametags.GetAggroStanding(dynelID);
                m_AggroStanding = aggroStanding;
            }
            
            UpdateNametagCategory();
            
            m_IsNPC = !m_IsSimpleDynel && m_Character.IsNPC();
                        
            m_CheckDistance = m_IsNPC || m_IsSimpleDynel;
            if (!m_IsSimpleDynel)
            {
                m_Character.SignalCharacterDied.Connect(SlotCharacterDied, this);
                m_Character.SignalCharacterAlive.Connect(SlotCharacterAlive, this);
            }
            
            //Add healthbar if it should be shown
            var showDefaultHealthBar:Number = DistributedValue.GetDValue("ShowNametagHealthBarDefault", 0)
            m_ShowHealthBarCollapsed = (showDefaultHealthBar == SHOW_HEALTHBAR_FRIENDS && m_Dynel.IsFriend() && !m_Dynel.IsEnemy()) || (showDefaultHealthBar == SHOW_HEALTHBAR_ENEMIES && m_Dynel.IsEnemy()) || (showDefaultHealthBar == SHOW_HEALTHBAR_ALL);
            if (m_ShowHealthBarCollapsed)
            {
                if (!m_IsSimpleDynel || m_Dynel.GetStat(_global.Enums.Stat.e_Life) > 0)
                {
                    //Health
                    if (m_HealthBar == undefined)
                    {
                        AddHealthBar();
                        m_HealthBar._y = m_Name._y + 30;
                        m_HealthBar._x = m_LeftAlignXCollapsed;
                        m_HealthBar._alpha = 100;
                    }
                }
            }
            if (DistributedValue.GetDValue("ShowNametagIcon", false))
            {
                if (m_IsNPC)
				{
					var iconName:String = "";
					if (!m_IsSimpleDynel)
					{
						var isMerchant:Boolean = m_Character.IsMerchant();
						var isBanker:Boolean = m_Character.IsBanker();
						
						if (isMerchant)
						{
							iconName = "VendorIcon"
						}
						else if (isBanker)
						{
							iconName = "TradepostIcon"
						}
						else
						{
                        
							var encounterType:Number = m_Character.GetStat(_global.Enums.Stat.e_EncounterType);
							var gradeType:Number = m_Character.GetStat( _global.Enums.Stat.e_GradeType );
							var isBoss:Boolean = m_Character.IsBoss();
							var isLieutenant = m_Character.IsQuestTarget()
							var isGroup:Boolean =  (encounterType == _global.Enums.EncounterType.e_EncounterType_Group);
							var isRaid:Boolean = (encounterType == _global.Enums.EncounterType.e_EncounterType_Raid);
							var isSwarm:Boolean = (gradeType == GRADE_SWARM);
							var isElite:Boolean = (gradeType == GRADE_ELITE);
							var isRare:Boolean = m_Character.IsRare();
							var isDungeon:Boolean = (encounterType == 2); // no enum for this, just a number
							/// Bosses
							if (isBoss)
							{
								if (isElite)
								{
									iconName = (isRare) ? "MT_EliteRareBoss" : "MT_EliteBoss";
								}
								else if (isSwarm)
								{
									iconName = (isRare) ? "MT_RareSwarmBoss" : "MT_SwarmBoss";
								}
								else if (isDungeon)
								{
									iconName = "MT_DungeonBoss";
								}
								else
								{
									iconName = (isRare) ? "MT_RareBoss" : "MT_Boss";
								}
							}
							else if (isLieutenant)
							{
								if (isSwarm)
								{
									iconName = "MT_SwarmLieutenant";
								}
								else if (isElite)
								{
									iconName = "MT_EliteLieutenant"    
								}
								else
								{
									iconName = "MT_Lieutenant";    
								}
							}
							else if (isGroup)
							{
								if (isElite)
								{
									iconName = "MT_EliteGroup";
								}
								else if (isSwarm)
								{
									iconName = "MT_SwarmGroup";
								}
								else
								{
									iconName = "MT_NormalGroup";
								}
							}
							else
							{
								if (isElite)
								{
									iconName = "MT_Elite";
								}
								else if (isSwarm)
								{
									iconName = "MT_Swarm";
								}
								else
								{
									iconName = "MT_Normal";
								}
							}
						}  
					}
					if (iconName != "")
					{
						m_MonsterBand = attachMovie(iconName, "m_MonsterBand", getNextHighestDepth());
                        UpdateNametagMonsterbandColor()
                        m_MonsterBand._Y = 4;
                        m_MonsterBand._xscale = 40;
                        m_MonsterBand._yscale = 40;
                        m_MonsterBandPush = m_MonsterBand._width + 2;
                        m_Name._x += m_MonsterBandPush;
					}
				}
                else
                {
					UpdateFactionRankIcon();
                }
            }
            
            UpdateName();
			
			if (m_IsNPC || m_IsSimpleDynel)
			{
				SlotLockedToTarget(m_Dynel.GetLockedTo());
			}
        }
		Update();
    }
	
	public function UpdateFactionRankIcon()
	{
		if (!m_IsSimpleDynel)
		{
			if (m_Character.GetStat(_global.Enums.Stat.e_GmLevel) & _global.Enums.GMFlags.e_ShowGMTag || m_Character.GetStat( _global.Enums.Stat.e_RankTag ) == 0)
			{
				if (m_FactionRankIcon != undefined)
				{
					m_FactionRankIcon.removeMovieClip();
					m_FactionRankIcon = undefined;	
				}
			}
			else
			{
				m_FactionRankIcon = this.createEmptyMovieClip("icon", this.getNextHighestDepth() );
				var factionRankContent:MovieClip = m_FactionRankIcon.createEmptyMovieClip("icon", m_FactionRankIcon.getNextHighestDepth() );
				var currentTag:LoreNode = Lore.GetDataNodeById(m_Character.GetStat( _global.Enums.Stat.e_RankTag ));
				var iconSource = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + currentTag.m_Icon;
				var imageLoaderListener:Object = new Object;
				imageLoaderListener.onLoadInit = function(target:MovieClip)
				{
					target._height = 25;
					target._width = 25;
					target._parent._xscale = 100;
					target._parent._yscale = 100;
				}
				
				var iconLoader:MovieClipLoader = new MovieClipLoader();
				iconLoader.addListener(imageLoaderListener);
				iconLoader.loadClip(iconSource, factionRankContent);
				m_FactionRankIcon._y = 0;
			}
		}
		
		if (m_FactionRankIcon != undefined)
		{
			m_LeftAlignXExpanded = 35 + m_IconTextPadding;
			m_LeftAlignXCollapsed = 15 + m_IconTextPadding;
			
			m_Name._x = m_LeftAlignXCollapsed;
		}
	}
    
    public function UpdateNametagMonsterbandColor()
    {
        if (m_MonsterBand != undefined && m_IsNPC)
		{
			if (m_NametagCategory == _global.Enums.NametagCategory.e_NameTagCategory_FriendlyNPC || m_NametagCategory == _global.Enums.NametagCategory.e_NameTagCategory_FriendlyPlayer)
			{
				Colors.ApplyColor(m_MonsterBand,m_NametagColor);
			}
			else
			{
				Colors.ApplyColor(m_MonsterBand, Colors.GetNametagIconColor(m_Dynel.GetStat(_global.Enums.Stat.e_Band) - m_ClientCharacter.GetStat(_global.Enums.Stat.e_PowerRank)));
			}
        }
    }
    
    public function GetDynelID()
    {
        return m_DynelID;
    }
    
    public function GetDistance():Number
    {
        return m_Distance;
    }
    
    public function IsTarget():Boolean
    {
        return  m_IsTarget;
    }
    
    public function configUI()
    {
        super.configUI();
        m_ComponentsLoaded = true;
    }
    
    public function Compare( otherTag:Nametag) : Number
    {
        return otherTag.GetDistance() - m_Distance;
    }
    
    function onEnterFrame()
    {
        Update();
    }
    
    function Update()
    {
		m_Distance = m_Dynel.GetCameraDistance();
		_z = m_Distance;
        if (m_Dynel != undefined && (!m_IsNPC || m_AggroStanding >= 0))
        {
            var shouldShow:Boolean = (!m_CheckDistance || m_Distance < 25 || m_IsTarget) && m_Dynel.IsRendered();


            if ( shouldShow )
            {
                var targetAlpha = m_IsLocked ? 50 : 100;
                if ( _alpha != targetAlpha )
                {
                    _alpha = Math.min(targetAlpha, _alpha + 5);
                }
            }
            else
            {
                if ( _alpha > 0 )
                {
                    _alpha = Math.max(0, _alpha - 5);
                }
                else
                {
                    return;
                }
            }
            
            var scale:Number = Math.max(m_MinScale, ((1 - (Math.max(m_Distance - 5, 0) / 35)) * m_MaxScale));
            
            _xscale = scale;
            _yscale = scale;
            
            var screenPos:Point = m_Dynel.GetNametagPosition();
            
            var correctWidth:Number = m_Name._width + m_IconTextPadding;
            var correctHeight:Number = m_Name._height + m_IconTextPadding;
            if (m_FactionRankIcon != undefined)
            {
                correctWidth += m_FactionRankIcon._width;
                correctHeight += m_FactionRankIcon._height;
            }
            
            correctWidth *= (scale / 100);
            correctHeight *= (scale / 100);
            
            var newX:Number = screenPos.x - (121/ 2);
            var newY:Number = screenPos.y - (correctHeight / 2);
            if (newX > 0 && newX < Stage.width && newY > 0 && newY < Stage.height)
            {
                _visible = true;
                _x = newX;
                _y = newY;
            }
            else
            {
                _visible = false;
            }
                       
            if ( m_DistanceToNPC != undefined )
            {
                var distance:String = LDBFormat.LDBGetText("MiscGUI", "NameTag_DistanceTitle") + " " + com.Utils.Format.Printf( "%.1f", Math.round(m_Dynel.GetDistanceToPlayer()*10)/10 );
                Label(m_DistanceToNPC).text = distance;
            }            
        }
    }
                
    function SlotClientCharacterStatChanged(statId:Number)
    {
        if (statId == _global.Enums.Stat.e_PowerRank)
        {
            UpdateNametagMonsterbandColor();
        }
    }
	
	function SlotLockedToTarget(targetID:ID32)
	{
		if (targetID == undefined || targetID.IsNull() || targetID.Equal(m_ClientCharacter.GetID()) || targetID.Equal(TeamInterface.GetClientTeamID()) || targetID.Equal(TeamInterface.GetClientRaidID()))
		{
			m_IsLocked = false;
			m_Name._alpha = 100;
			if (m_HealthBar != undefined)
			{
				m_HealthBar._alpha = 100;
			}
			/*if (m_LockedIcon != undefined)
			{
				m_LockedIcon.removeMovieClip();
				m_LockedIcon = undefined
			}*/
		}
		else
		{
			m_IsLocked = true;
			m_Name._alpha = 40;
			if (m_HealthBar != undefined)
			{
				m_HealthBar._alpha = 40;
			}
			/*if (m_LockedIcon == undefined && m_MonsterBand != undefined)
			{
				m_LockedIcon = attachMovie("LockIcon", "m_LockIcon", getNextHighestDepth());
				m_LockedIcon._xscale = 70;
				m_LockedIcon._yscale = 70
				m_LockedIcon._x = m_MonsterBand._x - 5;
				m_LockedIcon._y = m_MonsterBand._y + 7;
				
			}*/
		}
	}
    
    function SlotDynelStatChanged(statID:Number)
    {
        switch(statID)
        {
            case _global.Enums.Stat.e_GmLevel:
            case _global.Enums.Stat.e_PlayerFaction:
            case _global.Enums.Stat.e_Side:
            case _global.Enums.Stat.e_CarsGroup:
            case _global.Enums.Stat.e_RankTag:
                {
					UpdateFactionRankIcon();
                    UpdateNametagCategory();
                    UpdateName();
					SetAsTarget(m_IsTarget);
                }
                break;
            default:
                break;
        }
    }
    
    function SlotCharacterDied()
    {
        UpdateNametagCategory();
        UpdateName();
    }
    
    function SlotCharacterAlive()
    {
        UpdateNametagCategory();
        //Need to force alive as IsDead will still return false, as we are still in limbo state
        m_ForceAlive = true;
        UpdateName();
        m_ForceAlive = false;
    }
    
    function UpdateAggro(aggro:Number)
    {
        m_AggroStanding = aggro;
        UpdateNametagCategory();
    }
    
    function UpdateNametagCategory()
    {
        if (m_Dynel != undefined)
        {
            m_NametagCategory = m_Dynel.GetNametagCategory();
            m_NametagColor = Colors.GetNametagColor(m_NametagCategory, m_AggroStanding);
            
            if (m_Name != undefined)
            {
                m_Name.textField.textColor = m_NametagColor;
            }
            
            if (m_FactionRankIcon != undefined && m_IsNPC)
            {
                Colors.ApplyColor(m_FactionRankIcon, m_NametagColor);
            }
        }
    }
    
    function UpdateName()
    {
        if (m_Dynel != undefined)
        {
            var name:String = "";
            var dynelName:String = LDBFormat.Translate(m_Dynel.GetName());
            
            if ( !m_IsNPC && DistributedValue.GetDValue("ShowNametagFullName", 0) )
            {
                dynelName = m_Character.GetFirstName() + " \"" + dynelName + "\" " + m_Character.GetLastName();
            }
            
            if (m_Dynel.IsDead() && !m_ForceAlive && m_IsNPC)
            {
                name = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "CorpseOfMonsterName"), dynelName);
            }
            else
            {
                name = dynelName;
            }
            var extent:Object = m_Name.textField.getTextFormat().getTextExtent(name);
            m_Name.textField.text = name;
            if (m_ComponentsLoaded)
            {
                m_Name.width = extent.width + 5;
            }
            else
            {
                m_Name._width = extent.width + 5;
            }
        }
    }
    
    public function SetRemoveOnDeselect(remove:Boolean)
    {
        m_RemoveOnDeselect = remove;
    }
    
    public function AddHealthBar()
    {
        m_HealthBar = attachMovie("HealthBar2", "health", getNextHighestDepth()); 
        m_HealthBar.SetShowText( false );
        //m_HealthBar.SetBarScale(100, 100, 40);
        m_HealthBar.Show();
        m_HealthBar.SetDynel(m_Character);
        m_HealthBar._alpha = 100;
        m_HealthBar._yscale = 40;
        m_HealthBar._xscale = 40;
		
		m_HealthBarWidth = m_HealthBar._width;
    }
    
    function SetAsTarget(target:Boolean)
    {
        m_IsTarget = target;
        
        if (target)
        {
            var maxX:Number = 0;
            if (m_FactionRankIcon != undefined)
            {
                m_FactionRankIcon.tweenTo(m_TweenTime, { _width:50, _height:50 }, Regular.easeOut);
            }
            
            MovieClip(m_Name).tweenTo(m_TweenTime, { _x:m_LeftAlignXExpanded + m_MonsterBandPush }, Regular.easeOut);
            
            if (m_HealthBar != undefined)
            {
                m_HealthBar.tweenTo(m_TweenTime, { _x:m_LeftAlignXExpanded }, Regular.easeOut);
            }
            
            var y:Number = 16;
            
            if ( !m_IsSimpleDynel && DistributedValue.GetDValue("ShowNametagTitle", false) )
            {
                //Title
				var tag:Number = m_Character.GetStat(_global.Enums.Stat.e_SelectedTag);
				if (tag > 0 && tag != undefined)
				{
					var title:String = Lore.GetTagName(tag);
					if (title != undefined && title != "")
					{
						if (m_Title == undefined)
						{
							m_Title = attachMovie("TitleLabel", "title", getNextHighestDepth());
							m_Title._alpha = 0;
							Label(m_Title).text = title;
							Label(m_Title).width = m_Name.width;
						}
						m_Title._x = m_LeftAlignXCollapsed;
						var extent:Object = m_Title.textField.getTextFormat().getTextExtent(title);
						m_Title.tweenTo( m_TweenTime,  {_x:m_LeftAlignXExpanded, _y: y, _alpha: 100, width:extent.width+10}, Regular.easeOut);
						m_Title.onTweenComplete = null;
						y += 11;
					}
				}
            }
            
            if ( !m_IsSimpleDynel && DistributedValue.GetDValue("ShowNametagGuild", false) )
            {
                //Guild name
                var guild:String = m_Character.GetGuildName();// .toUpperCase();
                if (guild != undefined && guild != "")
                {
                    guild = "<"+guild+">";
                    if (m_Guild == undefined)
                    {
                        m_Guild = attachMovie("GuildLabel", "guild", getNextHighestDepth());
                        m_Guild._alpha = 0;
                        Label(m_Guild).text = guild;
                        Label(m_Guild).width = m_Name.width;
                    }
                    m_Guild._x = m_LeftAlignXCollapsed;
                    var extent:Object = m_Guild.textField.getTextFormat().getTextExtent(guild);
                    m_Guild.tweenTo( m_TweenTime,  {_x:m_LeftAlignXExpanded, _y: y, _alpha: 100, width:extent.width+10}, Regular.easeOut);
                    m_Guild.onTweenComplete = null;
                    y += 5;
                }
            }            
            
            if ( !m_IsSimpleDynel && DistributedValue.GetDValue("ShowNametagDistance", false) )
            {
                //Distance to NPC
                var distance:String = LDBFormat.LDBGetText("MiscGUI", "NameTag_DistanceTitle") + " " + Math.round(m_Dynel.GetDistanceToPlayer()*10)/10;
                if (distance != undefined && distance != "")
                {
                    y += 6;
					m_DistanceY = y;
					if (m_DistanceToNPC == undefined)
					{
                        m_DistanceToNPC = attachMovie("DistanceLabel", "distanceNPC", getNextHighestDepth());
						m_DistanceToNPC._alpha = 0;
						Label(m_DistanceToNPC).text = distance;
						Label(m_DistanceToNPC).width = m_Name.width;
						m_DistanceToNPC.onEnterFrame = Delegate.create(this, StupidDistanceHack);
                    }
                    y += 3;
                }
            }

            //Do not show for dynels without health
            if (DistributedValue.GetDValue("ShowNametagHealth", false) && (!m_IsSimpleDynel || m_Dynel.GetStat(_global.Enums.Stat.e_Life) > 0))
            {
                y += 15;
                //Health
                if (m_HealthBar == undefined)
                {
                    AddHealthBar();
                }
                
                m_HealthBar._alpha = 100;
                m_HealthBar._y =  y;
                m_HealthBar._x = m_LeftAlignXExpanded;
                
                y += 10
            }
            
            if (!m_IsSimpleDynel)
            {
                if (DistributedValue.GetDValue("ShowNametagResources", false))
                {
				
					if (DistributedValue.GetDValue("ShowNametagStates", false))
					{
						//Resources
						if (m_States == undefined)
						{
							m_States = attachMovie("States", "states", getNextHighestDepth());
							m_States._alpha = 0;
							m_States._xscale = 0;
							m_States._yscale = 0;
							m_States.SetCharacter(m_Character);
						}
						
						m_States._x = m_LeftAlignXCollapsed;
						m_States.tweenTo( m_TweenTime,  { _x:m_LeftAlignXExpanded, _y: y, _alpha: 100, _xscale:35, _yscale:35 }, Regular.easeOut);
						m_States.onTweenComplete = null;
						y += 10
					}
                    //Resources
                    if (m_Resources == undefined)
                    {
                        m_Resources = attachMovie("Resources", "resources", getNextHighestDepth());
                        m_Resources._alpha = 0;
                        m_Resources._xscale = 0;
                        m_Resources._yscale = 0;
                        m_Resources.SetCharacter(m_Character);
                        m_Resources.SetHideWhenEmpty(true);
                    }
                    
                    m_Resources._x = m_LeftAlignXCollapsed;
                    m_Resources.tweenTo( m_TweenTime,  { _x:m_LeftAlignXExpanded, _y: y, _alpha: 100, _xscale:50, _yscale:50 }, Regular.easeOut);
                    m_Resources.onTweenComplete = null;
					
                }
                
                if (DistributedValue.GetDValue("ShowNametagCastbar", false))
                {
                    //CastBar
                    if (m_CastBar == undefined)
                    {
                        m_CastBar = attachMovie("CastBar", "castbar", getNextHighestDepth());
                        m_CastBar._alpha = 0;
                        m_CastBar._xscale = 0;
                        m_CastBar._yscale = 0;
                        m_CastBar.SetCharacter(m_Character);
                    }
                    
                    m_CastBar._x = m_LeftAlignXCollapsed;
                    m_CastBar.tweenTo( m_TweenTime,  {_x:m_LeftAlignXExpanded, _y: -10, _alpha: 100, _xscale:30, _yscale:50  }, Regular.easeOut);
                    m_CastBar.onTweenComplete = null;
                }
            }
        }
        else
        {
            if (m_RemoveOnDeselect)
            {
                SignalRemoveNametag.Emit(m_DynelID);
            }
            else
            {
                if (m_FactionRankIcon != undefined)
                {
                    m_FactionRankIcon.tweenTo(m_TweenTime/2, { _width:25, _height:25 }, Regular.easeOut);
                }
                MovieClip(m_Name).tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed + m_MonsterBandPush }, Regular.easeOut);                
                
                if (m_Title != undefined)
                {
                    MovieClip(m_Title).tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, width:m_Name.width,_alpha:0,_y: 5 }, Regular.easeOut);
                    MovieClip(m_Title).onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_Title = undefined;
                }
                if (m_Guild != undefined)
                {
                    MovieClip(m_Guild).tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, width:m_Name.width,_alpha:0,_y: 5 }, Regular.easeOut);
                    MovieClip(m_Guild).onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_Guild = undefined;
                }
                if (m_DistanceToNPC != undefined)
                {
                    MovieClip(m_DistanceToNPC).tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, width:m_Name.width,_alpha:0,_y: 5 }, Regular.easeOut);
                    MovieClip(m_DistanceToNPC).onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_DistanceToNPC = undefined;
                }
				
				if (m_Resources != undefined)
                {
                    m_Resources.tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, _xscale:0, _yscale:0, _alpha:0, _y: 5 }, Regular.easeOut);
                    m_Resources.onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_Resources = undefined;
                }
				
				if (m_States != undefined)
                {
                    m_States.tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, _xscale:0, _yscale:0, _alpha:0, _y: 5 }, Regular.easeOut);
                    m_States.onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_States = undefined;
                }
				
				
				if (m_CastBar != undefined)
                {
                    m_CastBar.tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, _xscale:0, _yscale:0, _alpha:0, _y: 5 }, Regular.easeOut);
                    m_CastBar.onTweenComplete = function()
                    {
                        this.removeMovieClip();
                    }
                    m_CastBar = undefined;
                }
				
                if (m_HealthBar != undefined )
                {
                    if (!m_ShowHealthBarCollapsed)
                    {
                        m_HealthBar.removeMovieClip();
                        m_HealthBar = undefined;
                    }
                    else
                    {
                        m_HealthBar.tweenTo(m_TweenTime, { _x:0, _y: m_Name._y + 31 }, Regular.easeOut);
                    }
                }
                for (var i:Number = 0; i < m_DetailedComponents.length; i++)
                {
                    if (m_DetailedComponents[i] != undefined)
                    {
                        m_DetailedComponents[i].tweenTo(m_TweenTime, { _x:m_LeftAlignXCollapsed, _y: 5, _alpha: 0, _xscale:0, _yscale:0 }, Regular.easeOut);
                        m_DetailedComponents[i].onTweenComplete = function()
                        {
                            this.removeMovieClip();
                        }
						m_DetailedComponents[i]	= undefined;
                    }
                }
                m_DetailedComponents = [];
            }
        }
    }
	
	function StupidDistanceHack()
	{
		if (m_DistanceToNPC != undefined && m_DistanceToNPC.initialized)
		{
			m_DistanceToNPC.onEnterFrame = null;
			var distance:String = LDBFormat.LDBGetText("MiscGUI", "NameTag_DistanceTitle") + " " + com.Utils.Format.Printf( "%.1f", Math.round(m_Dynel.GetDistanceToPlayer()*10)/10 );
			m_DistanceToNPC._x = m_LeftAlignXCollapsed;
			var extent:Object = m_DistanceToNPC.textField.getTextFormat().getTextExtent(distance);
			m_DistanceToNPC.tweenTo( m_TweenTime,  {_x:m_LeftAlignXExpanded, _y: m_DistanceY, _alpha: 100, width:extent.width+10}, Regular.easeOut);
			m_DistanceToNPC.onTweenComplete = null;
		}
	}
}