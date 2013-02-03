//Imports
import flash.filters.BevelFilter;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import mx.utils.Delegate;
import flash.filters.DropShadowFilter;
import com.Components.ItemSlot;
import com.GameInterface.Quests;
import com.GameInterface.Quest;
import com.GameInterface.Log;
import com.Utils.Draw;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.Utils.Signal;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Components.ItemComponent;
import com.Components.WindowComponentContent;
import gfx.controls.Button;
import gfx.motion.Tween;
import mx.transitions.easing.*;

//Class
class GUI.Mission.MissionRewardWindow extends WindowComponentContent
{
    private var m_Height:Number;
    private var m_Width:Number;
    
    //Properties
    public var SignalClose:Signal;
    
    private var m_Character:Character;
    private var m_Faction:Number 
	private var m_Inventory:Inventory;
    private var m_Mission:Quest;
    private var m_ContentY:Number;
    private var m_RewardSize:Number = 32;
	public  var m_QuestID:Number;
	public  var m_MainQuestID:Number;

    private var m_InnerPadding:Number = 5
 //   private var m_ScrollableSections:Array;
    
    private var m_DescriptionBackground:MovieClip;
    private var m_RewardBackground:MovieClip;
    private var m_RewardArray:Array;
    private var m_OptionalRewardArray:Array;
    private var m_OptionalSelectedIcon:MovieClip;
    private var m_Notifier:MovieClip;
    private var m_XPReward:MovieClip;
    
    private var m_CollectButton:Button
    
    private var m_FactionLogo:MovieClip;
    
    private var m_From:TextField;
    private var m_To:TextField;
    private var m_Subject:TextField;
    private var m_FromText:TextField;
    private var m_ToText:TextField;
    private var m_SubjectText:TextField;
    private var m_MissionDescription:TextField;
    private var m_RewardHeader:TextField;
    private var m_OptionalRewardHeader:TextField;

    //Constructor
	public function MissionRewardWindow()
	{
        super()
        SignalClose = new Signal();

        m_Character = Character.GetClientCharacter();
        m_Faction   = m_Character.GetStat( _global.Enums.Stat.e_PlayerFaction );

        m_FactionLogo = attachMovie( GetFactionLogo( m_Faction ), "m_FactionLogo", getNextHighestDepth());
        m_FactionLogo._xscale = 42;
        m_FactionLogo._yscale = 42;
        m_FactionLogo._x = 10;
        m_FactionLogo._y = 10;
        
        m_ContentY = m_FactionLogo._height + m_FactionLogo._y + m_InnerPadding
        
        m_DescriptionBackground._y = m_ContentY + m_InnerPadding;
        m_MissionDescription._y = m_ContentY + (2 * m_InnerPadding);
        
        m_RewardBackground._y = m_ContentY + m_InnerPadding;
        m_XPReward._y = m_MissionDescription._y 

        m_MissionDescription.autoSize = "left";
        m_RewardHeader.autoSize = "left";
        m_OptionalRewardHeader.autoSize = "left";
        m_From.autoSize = "left";
        m_To.autoSize = "left";
        m_Subject.autoSize = "left";
        
        Tween.init();
   
        if (m_Mission == null)
        {
            Log.Error("MissionReward", "No completed mission found with id:" + m_QuestID + ", Maybe the mission was deleted");
        }
	}
    
    public function configUI()
    {
        m_CollectButton.addEventListener("click", this, "CollectRewardsHandler");
        m_CollectButton.label = LDBFormat.LDBGetText("Quests", "RewardCollect");
        m_CollectButton.disableFocus = true;
    }
    
    // inserting data from the controller, sets the static y values (the one that will not change on layout)
    public function SetData(rewardObject:Object)
    {
        m_RewardArray = rewardObject.m_Rewards;
        m_OptionalRewardArray = rewardObject.m_OptionalRewards;
        m_QuestID   = rewardObject.m_QuestTaskID;
        m_Mission   = GetMissionObject(m_QuestID);
        
        m_From.text = LDBFormat.LDBGetText("Gamecode", "From")+":";
        m_To.text = LDBFormat.LDBGetText("GenericGUI", "To")+":";
        m_Subject.text = LDBFormat.LDBGetText("Gamecode", "Subject")+":";
        m_FromText.text = com.Utils.Faction.GetHQ( m_Faction );
        m_ToText.text = m_Character.GetName();
        m_SubjectText.text = m_Mission.m_MissionName;
        
        m_MissionDescription.text = Quests.GetSolvedTextForQuest(m_MainQuestID, m_QuestID);
        m_XPReward.textField.text = (rewardObject.m_Xp ? ""+rewardObject.m_Xp : "0");
 
         if (m_RewardArray.length > 0)
        {
            m_RewardHeader.text = LDBFormat.LDBGetText("Quests", "RevardProvided");
            m_RewardHeader._y = m_XPReward._y + m_XPReward._height + m_InnerPadding;
            AddRewards(m_RewardArray, "Reward", false);
        }
        else
        {
            m_RewardHeader._visible = false;
        }
        
        if (m_OptionalRewardArray.length > 0)
        {
            m_OptionalRewardHeader.text = LDBFormat.LDBGetText("Quests", "RewardChoose1");
            if (m_RewardArray.length > 0)
            {
                m_OptionalRewardHeader._y = this["m_Reward" + (m_RewardArray.length - 1)]._y + m_RewardSize + m_InnerPadding;
            }
            else
            {
                m_OptionalRewardHeader._y = m_XPReward._y + m_XPReward._height + m_InnerPadding;
            }
            AddRewards(m_OptionalRewardArray, "OptionalReward", true);
        }
        else
        {
            m_OptionalRewardHeader._visible = false;
        }
        
        Layout();
        SignalSizeChanged.Emit();
        
    }
    
    //Layout Rewards Grid
    private function AddRewards(awardsArray:Array, instanceName:String, selectable:Boolean):Void
    {
        for (var i:Number = 0; i < awardsArray.length; i++)
        {
            var rewardSlot:MovieClip = attachMovie("IconSlot", "m_" + instanceName + i, getNextHighestDepth());
            rewardSlot._height = rewardSlot._width = m_RewardSize; // (displayScrollbar == true) ? 105 : 117;
            
            var itemSlot = new ItemSlot(undefined, i, rewardSlot);
            itemSlot.SetData(awardsArray[i]);
            
            var iconBackground:MovieClip = itemSlot.GetIcon();

            iconBackground.index = i;
            iconBackground.ref = this;
            
            if (selectable)
            {
                if (i == 0)
                {
                    ItemComponent(iconBackground).SetThrottle(true);
                   // ItemComponent(iconBackground).SetOuterBorderColor(0xFFFFFF);
                    m_OptionalSelectedIcon = iconBackground;
                    
                   // SetNotifier(iconBackground)
                }
                
                iconBackground.onRelease = OptionalRewardsClickHandler;
                iconBackground.onRollOut = OptionalRewardsOutHandler;
                iconBackground.onRollOver = OptionalRewardsOverHandler;
            }
        }
    }
    
    
    /// repositions after a resize
    private function Layout()
    {
        //Draw Lines
        clear();
        lineStyle(1, 0xFFFFFF, 40)
        moveTo(0, Math.round( m_ContentY ));
        lineTo(m_Width, Math.round( m_ContentY ));
        
        m_FromText._width       = m_Width - m_FromText._x;
        m_ToText._width         = m_Width - m_ToText._x;
        m_SubjectText._width    = m_Width - m_SubjectText._x;
        
        m_DescriptionBackground._width  = m_Width - m_RewardBackground._width - 5;
        m_MissionDescription._width     = m_DescriptionBackground._width - (2*m_InnerPadding);
        
        m_XPReward._x = m_RewardBackground._x + m_InnerPadding;
        
        m_RewardBackground._x   = m_DescriptionBackground._x + m_DescriptionBackground._width + 10;
        m_RewardHeader._x       = m_RewardBackground._x + m_InnerPadding;
        
        var rewardsX:Number = m_RewardHeader._x;
        var rewardsY:Number = m_RewardHeader._y + m_RewardHeader._height + m_InnerPadding;
        var numRewardsPerLine:Number = Math.floor((m_RewardBackground._width - (2 * m_InnerPadding)) / (m_RewardSize + m_InnerPadding));
        
        /// iterate the Rewards and place them
        for ( var i:Number = 0; i < m_RewardArray.length; i++)
        {
            var rewardSlot:MovieClip = this["m_Reward" + i]
            if (rewardSlot != undefined)
            {
                var lineNo:Number = Math.floor(i / numRewardsPerLine);
     
                rewardSlot._y = rewardsY + ((m_RewardSize + 11) * lineNo);
                rewardSlot._x = rewardsX + ((i - (numRewardsPerLine * lineNo)) * (m_RewardSize + 10)) ;
            }
        }
        
        m_OptionalRewardHeader._y = rewardSlot._y + m_RewardSize + 10;
        m_OptionalRewardHeader._x = m_RewardHeader._x
        
        var rewardsY:Number = m_OptionalRewardHeader._y + m_OptionalRewardHeader._height + m_InnerPadding;
        
        /// iterate the Optional rewards
        for ( var i:Number = 0; i < m_OptionalRewardArray.length; i++)
        {
            var rewardSlot:MovieClip = this["m_OptionalReward" + i]
            if (rewardSlot != undefined)
            {
                var lineNo:Number = Math.floor(i / numRewardsPerLine);
     
                rewardSlot._y = rewardsY + ((m_RewardSize + 11) * lineNo);
                rewardSlot._x = rewardsX + ((i - (numRewardsPerLine * lineNo)) * (m_RewardSize + 10)) ;
            }
        }
        var rewardsHeight:Number        = rewardSlot._y - m_RewardBackground._y + (2 * m_InnerPadding) + m_RewardSize;
        var descriptionHeight:Number    = m_MissionDescription._height + (2 * m_InnerPadding);
        var height                      = Math.max( m_Height - 120, Math.max(rewardsHeight, descriptionHeight));
        
        m_RewardBackground._height      = height;
        m_DescriptionBackground._height = height;
  
        m_CollectButton._x = m_Width - m_CollectButton._width;
        m_CollectButton._y = m_RewardBackground._y + height + 13;
    }
    
    // returns the size (chipping off some here and there for fitting)
    public function GetSize() :Point
    {
        var size:Point = new Point(m_RewardBackground._x +m_RewardBackground._width,  _height + 12);
        return size;
    }
    
    // the parent sets initial size
    public function SetSize(width:Number, height:Number)
    {
        m_Width = width;
        m_Height = height;
        
        Layout();
        SignalSizeChanged.Emit();
    }
    
    //Optional Rewards Click Handler
    private function OptionalRewardsClickHandler():Void
    {
        var selected:MovieClip = this["ref"].m_OptionalSelectedIcon;
        if (this == selected)
        {
            return;
        }
		
		if (selected != undefined)
		{
        //   this["ref"].m_Notifier.removeMovieClip();
		//	this["ref"].m_Notifier = undefined;

            selected.SetThrottle( false );
           // selected.SetOuterBorderColor(0x999999);
		}
        
		this["ref"].m_OptionalSelectedIcon = this;
       this["SetThrottle"](true);
       // this["ref"].SetNotifier( this );
       // this["Glow"](true);
       // this["SetOuterBorderColor"](0xFFFFFF);
    }
    
    //Optional Rewards Out Handler
    private function OptionalRewardsOutHandler():Void
    {
        if (this != this["ref"].m_OptionalSelectedIcon)
        {
            this["Glow"]( false );
        }
    }
    
    //Optional Rewards Over Handler
    private function OptionalRewardsOverHandler():Void
    {
        this["Glow"]( true );
    }
    //Get Faction Logo
    private function GetFactionLogo(faction:Number):String
    {
        var factionLogo:String;
        
        switch(faction)
        {
            case _global.Enums.Factions.e_FactionDragon:        factionLogo = "LogoDragon";
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionIlluminati:    factionLogo = "LogoIlluminati";
                                                                break;
                                                                
            case _global.Enums.Factions.e_FactionTemplar:      
                
            default:                                            factionLogo = "LogoTemplar";
        }
        
        return factionLogo;        
    }

   
    /// returns the Mission object from the taskl id of this mission
    /// @param id:Number - the currenttask id 
    /// @return quests - or null if there is no quest with this id
    function GetMissionObject(id:Number):Quest
    {
		m_MainQuestID = Quests.GetMainQuestIDByQuestID(id);
        var completedQuests:Array = Quests.GetAllCompletedQuests();
        for (var i:Number = 0; i < completedQuests.length; i++ )
        {
			if (completedQuests[i].m_ID == m_MainQuestID)
			{
                return completedQuests[i];
            }
        }

		var activeQuests:Array = Quests.GetAllActiveQuests();
        for (var i:Number = 0; i < activeQuests.length; i++ )
        {
			if (activeQuests[i].m_ID == m_MainQuestID)
			{
                return activeQuests[i];
            }
        }
        
        return null;
    }
    //Collect Rewards
    private function CollectRewardsHandler(event:Object):Void
    {
        Quests.AcceptQuestReward(m_QuestID, m_OptionalSelectedIcon.index);
        Close();
    }
    
    public function Close()
    {
        SignalClose.Emit(m_QuestID);
    }
    
    public function GetID()
    {
        return m_QuestID;
    }
    

/* 
        //XP
        var xpClip:MovieClip = content.createEmptyMovieClip("i_XpClip", content.getNextHighestDepth());
                
        var xpIcon:MovieClip = xpClip.attachMovie("_Icon_XP", "i_XPIcon",  xpClip.getNextHighestDepth());
        xpIcon._x = 10;
        xpIcon._y = 10;

        var xpTextField:TextField = xpClip.createTextField("i_XPTextField", xpClip.getNextHighestDepth(), 0, 0, 0, 0);
        xpTextField.selectable = false;
        xpTextField.setNewTextFormat( m_HeadlineFormat );
        xpTextField.autoSize = "left"
        xpTextField.text = "";
        xpTextField.text = (m_Mission.m_Xp ? String( m_Mission.m_Xp ) : "0");
        xpTextField._y = 10;
        xpTextField._x = xpIcon._x + xpIcon._width + 10;

  /*      //Scrollbar
        if (content._height > SECTION_HEIGHT - SCROLL_MASK_OFFSET * 2)
        {
            DrawScrollableSection(content, REWARDS_WIDTH, REWARDS_WIDTH);
        }
       
    }
    


    //Draw Scrollable Section
    private function DrawScrollableSection(targetSection:MovieClip, maskWidth:Number, scrollBarX:Number):Void
    {
        var scrollMask:MovieClip = com.GameInterface.ProjectUtils.SetMovieClipMask(targetSection, null, SECTION_HEIGHT - SCROLL_MASK_OFFSET * 2, maskWidth, false);
        scrollMask._y = targetSection._y + SCROLL_MASK_OFFSET;
        
        var scrollbar:MovieClip = targetSection._parent.attachMovie("ScrollBar", "i_ScrollBar", targetSection._parent.getNextHighestDepth());
        scrollbar._x = scrollBarX - scrollbar._width - 6;
        scrollbar._y = targetSection._y + 1;
                
        scrollbar.setScrollProperties(SECTION_HEIGHT, 0, targetSection._height - SECTION_HEIGHT + SCROLL_MASK_OFFSET + 12); 
        scrollbar._height = SECTION_HEIGHT - 3;
        scrollbar.addEventListener("scroll", this, "OnScrollbarUpdate");
        scrollbar.position = 0;
        scrollbar.trackMode = "scrollPage"
        scrollbar.trackScrollPageSize = 2;
        scrollbar.disableFocus = true;
        scrollbar.clipToScroll = targetSection;

        if (!m_ScrollableSections)
        {
            m_ScrollableSections = new Array();
        }
        
        targetSection._parent.scrollbar = scrollbar;
        m_ScrollableSections.push(targetSection._parent);
        
        Mouse.addListener(this);
    }
    
    //On Scroll Bar Update
    function OnScrollbarUpdate(event:Object):Void
    {
        var target:MovieClip = event.target
        var pos:Number = event.target.position
        event.target.clipToScroll._y = -(pos)
        Selection.setFocus(null);
    }

    //On Mouse Wheel
    private function onMouseWheel(delta:Number):Void
    {
        for (var i:Number = 0; i < m_ScrollableSections.length; i++)
        {
            if ( Mouse["IsMouseOver"]( m_ScrollableSections[i] ) )
            {
                var newPos:Number = m_ScrollableSections[i]["scrollbar"].position + -(delta * SCROLL_SPEED);
                m_ScrollableSections[i]["scrollbar"].position = Math.min(Math.max(0.0, newPos), m_ScrollableSections[i]["scrollbar"].maxPosition);
                break;
            }
        }
    }
    */
}
