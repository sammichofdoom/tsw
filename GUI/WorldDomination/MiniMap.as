//Imports
import com.Utils.GlobalSignal;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.Utils.Signal;
import com.GameInterface.ProjectUtils;
import GUI.WorldDomination.MiniMapReward;
import mx.utils.Delegate;

//Class
class GUI.WorldDomination.MiniMap extends MovieClip
{
    //Constants
    public static var MAP_STATE:Number = 0;
    public static var REWARDS_STATE:Number = 1;
    
    public static var MAP:String = LDBFormat.LDBGetText("WorldDominationGUI", "mapMiniMapButtonTitle");
    public static var REWARDS:String = LDBFormat.LDBGetText("WorldDominationGUI", "rewardsMiniMapButtonTitle");
    
    private static var EL_DORADO:String = LDBFormat.LDBGetText("WorldDominationGUI", "elDorado");
    private static var STONEHENGE:String = LDBFormat.LDBGetText("WorldDominationGUI", "stonehenge");
    private static var FUSANG_PROJECTS:String = LDBFormat.LDBGetText("WorldDominationGUI", "forbiddenCity");
    
    private static var MAP_BUTTONS_GAP:Number = 10;
    private static var SCROLL_WHEEL_SPEED:Number = 10;
    
    //Properties
    public var SignalStateChanged:Signal;
    
    private var m_Mask:MovieClip;
    private var m_MiniMapsContainer:MovieClip;
    private var m_ElDoradoMiniMap:MovieClip;
    private var m_StonehengeMiniMap:MovieClip;
    private var m_FusangProjectsMiniMap:MovieClip;
    
    private var m_ButtonBar:MovieClip;
    private var m_TabButtonArray:Array;

    private var m_Playfield:String;
    private var m_State:Number;
    
    private var m_RewardsScrollContainer:MovieClip;
    private var m_RewardsContainer:MovieClip;
    private var m_ElDoradoRewards:Array;
    private var m_StonehengeRewards:Array;
    private var m_FusangProjectsRewards:Array;
    
    private var m_ScrollBarContainer:MovieClip;
    private var m_ScrollTrack:MovieClip;
    private var m_ScrollBar:MovieClip;
    private var m_ScrollBarPosition:Number;
    
    private var m_PlayfieldArray:Array;
    
    //Constructor
    public function MiniMap()
    {
        super();
        
        SignalStateChanged = new Signal();
        
        Init();
    }
    
    //Initialize
    private function Init():Void
    {
        m_TabButtonArray = new Array();
        m_TabButtonArray.push({label: MAP});
        m_TabButtonArray.push({label: REWARDS});

        m_ButtonBar = attachMovie("ButtonBar", "m_ButtonBar", getNextHighestDepth());
        m_ButtonBar.tabChildren = false;
        m_ButtonBar.itemRenderer = "PvPTabButton";
        m_ButtonBar.direction = "horizontal";
        m_ButtonBar.spacing = -5;
        m_ButtonBar.autoSize = "center";
        m_ButtonBar.dataProvider = m_TabButtonArray;
        m_ButtonBar.selectedIndex = 0;
        m_ButtonBar._y = 3;
        m_ButtonBar.addEventListener("change", this, "SelectedTabBarEventHandler");
        
        var buttonBarLine:MovieClip = createEmptyMovieClip("buttonBarLine", getNextHighestDepth());
        buttonBarLine.lineStyle(1, 0x656565, 100, true, "noScale");
        buttonBarLine.moveTo(0, 0);
        buttonBarLine.lineTo(m_Mask._width, 0);
        buttonBarLine.endFill();
        buttonBarLine._y = m_ButtonBar._y + 27;

        m_PlayfieldArray = new Array();
        m_PlayfieldArray.push({map: m_MiniMapsContainer.m_ElDoradoMiniMap, playfieldName: EL_DORADO});
        m_PlayfieldArray.push({map: m_MiniMapsContainer.m_StonehengeMiniMap, playfieldName: STONEHENGE});
        m_PlayfieldArray.push({map: m_MiniMapsContainer.m_FusangProjectsMiniMap, playfieldName: FUSANG_PROJECTS});
        
        for (var i:Number = 0; i < m_PlayfieldArray.length; i++)
        {
            m_PlayfieldArray[i].map._visible = false;
        }
        
        /*
         *  The m_RewardsScrollContainer object, which is created and added to the stage in
         *  Flash Professional, seems to require a single mouse event to be assigned programatically
         *  so that it can also receive a mouse wheel event for scrolling.  This is super f0ked
         *  and doesn't make sense, ActionScript 2.
         * 
         */ 
        
        m_RewardsScrollContainer.onRollOver = function() { }
        
        CreateRewardsArrays();
        CreateRewardsContainer();
        CreateScrollBar();
    }
    
    //Create Rewards Arrays
    private function CreateRewardsArrays():Void
    {
        m_ElDoradoRewards = new Array();
        m_ElDoradoRewards.push({rewardType: MiniMapReward.BUFF, rewardID: 7167608});
        m_ElDoradoRewards.push({rewardType: MiniMapReward.TOKEN, rewardID: MiniMapReward.MAJOR_ANIMA_FRAGMENT}); //Replace with BuffID to support tooltips
        
        m_StonehengeRewards = new Array();
        m_StonehengeRewards.push({rewardType: MiniMapReward.BUFF, rewardID: 7171409});
        m_StonehengeRewards.push({rewardType: MiniMapReward.TOKEN, rewardID: MiniMapReward.MAJOR_ANIMA_FRAGMENT}); //Replace with BuffID to support tooltips
        
        m_FusangProjectsRewards = new Array();
        m_FusangProjectsRewards.push({rewardType: MiniMapReward.BUFF, rewardID: 7205220});
        m_FusangProjectsRewards.push({rewardType: MiniMapReward.BUFF, rewardID: 7205221});
        m_FusangProjectsRewards.push({rewardType: MiniMapReward.BUFF, rewardID: 7205222});
        m_FusangProjectsRewards.push({rewardType: MiniMapReward.BUFF, rewardID: 7205223});
        m_FusangProjectsRewards.push({rewardType: MiniMapReward.BUFF, rewardID: MiniMapReward.GetCouncilSupportBuffSpellID()});
        m_FusangProjectsRewards.push({rewardType: MiniMapReward.BUFF, rewardID: MiniMapReward.GetCustodianBuffSpellID()});
        m_FusangProjectsRewards.push({rewardType: MiniMapReward.TOKEN, rewardID: MiniMapReward.MINOR_ANIMA_FRAGMENT}); //Replace with BuffID to support tooltips
    }
    
    //Create Rewards Container
    private function CreateRewardsContainer():Void
    {
        m_RewardsContainer = createEmptyMovieClip("m_RewardsContainer", getNextHighestDepth());
        m_RewardsContainer._x = m_RewardsScrollContainer._x;
        m_RewardsContainer._y = m_RewardsScrollContainer._y;
    }
    
    //Create Scroll Bar
    private function CreateScrollBar():Void
    {
        var mouseListener:Object = new Object();
		mouseListener.onMouseWheel = Delegate.create(this, MouseWheelEventHandler);
		Mouse.addListener(mouseListener);
        
        m_ScrollBarContainer = createEmptyMovieClip("m_ScrollBarContainer", getNextHighestDepth());
        
        m_ScrollBarPosition = 0;
        
        m_ScrollTrack = m_ScrollBarContainer.attachMovie("ScrollTrack", "m_ScrollTrack", m_ScrollBarContainer.getNextHighestDepth());
        m_ScrollTrack._x = m_RewardsScrollContainer._x + m_RewardsScrollContainer._width - 12; 
        m_ScrollTrack._y = m_RewardsScrollContainer._y + 5;
        
        m_ScrollBar = m_ScrollBarContainer.attachMovie("ScrollBar", "m_ScrollBar", m_ScrollBarContainer.getNextHighestDepth());
        m_ScrollBar._x = m_RewardsScrollContainer._x + m_RewardsScrollContainer._width - 15; 
        m_ScrollBar._y = m_RewardsScrollContainer._y;
        m_ScrollBar._visible = false;

        m_ScrollBar.setScrollProperties(m_RewardsScrollContainer._height, 0, m_RewardsContainer._height - m_RewardsScrollContainer._height); 
        m_ScrollBar._height = m_RewardsScrollContainer._height;
        m_ScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
        m_ScrollBar.position = m_ScrollBarPosition;
        m_ScrollBar.trackMode = "scrollPage"
        m_ScrollBar.disableFocus = true;
    }
    
    //Update Rewards
    private function UpdateRewards():Void
    {
        m_RewardsContainer.removeMovieClip();
        m_RewardsContainer = null;
        
        CreateRewardsContainer();
        
        var rewards:Array;

        switch (m_Playfield)
        {
            case EL_DORADO:         rewards = m_ElDoradoRewards;
                                    break;
                            
            case STONEHENGE:        rewards = m_StonehengeRewards;
                                    break;
                                
            case FUSANG_PROJECTS:   rewards = m_FusangProjectsRewards;
        }
        
        for (var i:Number = 0; i < rewards.length; i++)
        {
            var reward:MovieClip = m_RewardsContainer.attachMovie("MiniMapReward", "MiniMapReward_" + i, m_RewardsContainer.getNextHighestDepth());
            reward._x = 15;
            reward._y = reward._height * i;
            reward.SetReward(rewards[i].rewardType, rewards[i].rewardID);
        }
                                    
        UpdateScrollBar();
    }
    
    //Selected Tab Bar Event Handler
    private function SelectedTabBarEventHandler(event:Object):Void
    {
        switch (event.index)
        {
            case MAP_STATE:         state = MAP_STATE;
                                    break;
                        
            case REWARDS_STATE:     state = REWARDS_STATE;
        }
        
        Selection.setFocus(null);
    }
    
    //Update Scroll Bar
    private function UpdateScrollBar():Void
    {
        ProjectUtils.SetMovieClipMask(m_RewardsContainer, null, m_RewardsScrollContainer._height, m_RewardsScrollContainer._width);
        
        if (m_RewardsContainer._height - 2 > m_RewardsScrollContainer._height)
        {
            m_ScrollBar._visible = true;
            m_ScrollBar.setScrollProperties(m_RewardsContainer._height, 0, m_RewardsContainer._height - m_RewardsScrollContainer._height - 2);
            m_ScrollBar.position = m_ScrollBarPosition;
        }
        else
        {
            m_ScrollBar._visible = false;
            
            m_ScrollBar.position = 0;
        }
    }
    
    //On Scroll Bar Update
    private function OnScrollbarUpdate(event:Object):Void
    {
        var target:MovieClip = event.target;
        var pos:Number = event.target.position;
        
        m_RewardsContainer._y = m_RewardsScrollContainer._y - pos;
        
        Selection.setFocus(null);
    }
    
    //Mouse Wheel Event handler
    private function MouseWheelEventHandler(delta:Number):Void
    {
        if (m_RewardsScrollContainer.hitTest(_root._xmouse, _root._ymouse, true) && m_ScrollBar._visible)
        {
            var newPos:Number = m_ScrollBar.position + -(delta * SCROLL_WHEEL_SPEED);
            var event:Object = {target: m_ScrollBar};
            
            m_ScrollBar.position = Math.min(Math.max(0.0, newPos), m_ScrollBar.maxPosition);
            
            OnScrollbarUpdate(event);
        }
    }
    
    //Set Playfield
    public function set playfield(playfieldName:String):Void
    {
        for (var i:Number = 0; i < m_PlayfieldArray.length; i++)
        {
            if (m_PlayfieldArray[i].playfieldName == playfieldName)
            {
                m_PlayfieldArray[i].map._visible = true;
            }
            else
            {
                m_PlayfieldArray[i].map._visible = false;
            }
        }
        
        if (m_Playfield != playfieldName)
        {
            m_Playfield = playfieldName;
            
            UpdateRewards();
        }
    }
    
    //Get Playfield
    public function get playfield():String
    {
        return m_Playfield;
    }
    
    //Set State
    public function set state(state:Number):Void
    {
        if (state == MAP_STATE)
        {
            m_ButtonBar.selectedIndex = MAP_STATE;
            
            m_RewardsScrollContainer._visible = false;            
            m_RewardsContainer._visible = false;
            m_ScrollBarContainer._visible = false;
        }

        if (state == REWARDS_STATE)
        {
            m_ButtonBar.selectedIndex = REWARDS_STATE;
            
            m_RewardsScrollContainer._visible = true;            
            m_RewardsContainer._visible = true;
            m_ScrollBarContainer._visible = true;
        }
        
        m_State = state;
        
        SignalStateChanged.Emit(state);
    }
    
    //Get State
    public function get state():Number
    {
        return m_State;
    }
}