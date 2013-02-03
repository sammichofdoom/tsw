import com.Utils.LDBFormat;
import com.GameInterface.LoreNode;
import com.GameInterface.Lore;
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import mx.utils.Delegate;
import com.GameInterface.DistributedValue;
import com.Utils.Signal;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import gfx.core.UIComponent;

class GUI.Achievement.AchievementItem extends UIComponent
{
    public static var TYPE_PROGRESS:Number = 1;
    public static var TYPE_CHILDREN:Number = 2;
    public static var TYPE_SINGLE:Number = 3;
    
    private var m_AchievementType:Number;
    private var m_Data:LoreNode;
    private var m_Title:TextField;
    private var m_DescriptionText:TextField;
    
    private var m_ChildWidth:Number = 150; // the max width of a child entry
    private var m_TextPos:Number;
    private var m_ItemHeight:Number;
    private var m_ItemWidth:Number 
    private var m_AchievementProgressText:TextField;
    private var m_AchievementProgressBar:MovieClip;
    private var m_AchievementProgressBarBackground:MovieClip;
    private var m_CompleteCheck:MovieClip;
    private var m_Frame:MovieClip;
    
    private var m_Background:MovieClip;
    private var m_Icon:MovieClip;
    private var m_ExpandButton:MovieClip;
    private var m_SubAchievementsClip:MovieClip;
    private var m_IsExpanded:Boolean;
    private var m_IsInitialized:Boolean = false;
    private var m_IsCompleted:Boolean;
    private var m_IsInProgress:Boolean;
    
    private var m_IsSelected:Boolean;
    
    public var SignalClicked:Signal;
    public var SignalSizeChanged:Signal;
    
    public function AchievementItem()
    {
        super();
        SignalClicked = new Signal;
        SignalSizeChanged = new Signal();
        m_IsExpanded = false;
        m_TextPos = 70;
        m_ItemHeight = m_Background._height;
        m_ItemWidth = m_Background._width;
        SetSelected(false);
    }
    
    public function configUI()
    {
        if (m_Data != undefined && !m_IsInitialized)
        {
            Init();
        }
    }
    
    public function SetData(data:LoreNode)
    {
        m_Data = data;
        if (!m_IsInitialized && initialized)
        {
            Init()
        }        
    }
    
    private function Init()
    {
        m_IsCompleted = !m_Data.m_Locked;
        if (!m_IsCompleted)
        {
            Lore.SignalTagAdded.Connect(SlotTagAdded, this);
        }
        
        if (Lore.HasCounter(m_Data.m_Id))
        {
            m_AchievementType = TYPE_PROGRESS;
            Lore.SignalCounterUpdated.Connect(UpdateProgressBar, this);
        }
        else if (m_Data.m_Children.length > 0)
        {
            m_AchievementType = TYPE_CHILDREN;
        }
        else
        {
            m_AchievementType = TYPE_SINGLE;
        }
        
        m_IsInitialized = true;
        Draw();
        
        var focus:Number = DistributedValue.GetDValue("achievement_window_focus");
        
        if (focus == m_Data.m_Id)
        {
            SetSelected(true);
        }
        else if (TYPE_CHILDREN)
        {
            for (var i:Number = 0; i < m_Data.m_Children.length; i++)
            {
                if (focus == m_Data.m_Children[i].m_Id)
                {
                    SetSelected(true);
                    Expand(true);
                    break;
                }
            }
        }
        Layout();
    }

    
    private function Draw()
    {
        m_Title.text = m_Data.m_Name;
        m_DescriptionText.text = com.GameInterface.Lore.GetTagText( m_Data.m_Id ); // may be blank
        
        var achievementIcon:MovieClip = m_Icon.createEmptyMovieClip("achievementIcon", m_Icon.getNextHighestDepth());
        
        if (m_Data.m_Icon > 0)
        {
            LoadImage(achievementIcon, m_Data.m_Icon);
        }
        
        if (m_Data.m_IsNew)
        {
            AddNotification()
            if (m_AchievementType != TYPE_CHILDREN)
            {
                if (m_Icon.m_NewNotification != undefined)
                {
                    m_Icon.m_NewNotification.tweenTo(10, { _alpha:20 }, None.easeNone);
                    m_Icon.m_NewNotification.m_Id = m_Data.m_Id;
                    m_Icon.m_NewNotification.onTweenComplete = function()
                    {
                        Lore.MarkAsOld( this.m_Id );
                        GUI.Achievement.AchievementWindow.SignalTagRead.Emit(this.m_Id);
                        
                        this.removeMovieClip();
                        this = undefined;
                    }
                }
                
                
            }
        }
        
        if (m_IsCompleted)
        {
            this._alpha = 100;
            com.Utils.Colors.Tint(m_Icon, 0x000000, 0);
            com.Utils.Colors.Tint(m_Background, 0x000000, 0);
            m_CompleteCheck = attachMovie("checkmark", "m_CompleteCheck", getNextHighestDepth());
            m_CompleteCheck._y = 5;
        }
        else
        {
            this._alpha = 80;
            com.Utils.Colors.Tint(m_Icon, 0x000000, 70);
            com.Utils.Colors.Tint(m_Background, 0x20201e, 100);
        }

        if (m_AchievementType == TYPE_PROGRESS)
        {
            var hasCounter:Boolean = Lore.HasCounter(m_Data.m_Id);
            m_AchievementProgressText._visible = true;
            m_AchievementProgressBar._visible = true;
            m_AchievementProgressBarBackground._visible = true;
            
            UpdateProgressBar();
            var target:Number = Lore.GetCounterTargetValue(m_Data.m_Id);
            var current:Number = Lore.GetCounterCurrentValue(m_Data.m_Id);
            
            if (current < target && current > 0)
            {
                m_IsInProgress = true;
                SetAchievementInProgress();
            }
        }
        else
        {
            m_AchievementProgressText._visible = false;
            m_AchievementProgressBar._visible = false;
            m_AchievementProgressBarBackground._visible = false;
        }
        
        if (m_AchievementType == TYPE_CHILDREN)
        {
            if (m_ExpandButton != undefined)
            {
                m_ExpandButton.removeMovieClip();
                m_ExpandButton = undefined;
            }
            m_ExpandButton = this.attachMovie("ExpandButton", "m_ExpandButton", this.getNextHighestDepth());
            m_ExpandButton._x = m_TextPos + (m_ExpandButton._width * 0.5);
            m_ExpandButton._y = m_DescriptionText._y + m_DescriptionText._height + 5;
            m_ExpandButton.onRelease = Delegate.create( this, ExpandHandler);
            
            if (m_Data.m_Locked)
            {
                var isInProgress:Boolean = false;
                for (var i:Number = 0; i < m_Data.m_Children.length; i++)
                {
                    var node:LoreNode = m_Data.m_Children[i];
                    {
                        if (!node.m_Locked)
                        {
                            m_IsInProgress = true;
                            SetAchievementInProgress()
                        }
                    }
                }
            }
        }
    }
    
    private function Layout()
    {
        var height:Number = m_Background._height;
       
        m_Background._width = m_ItemWidth;
        m_Frame._width = m_ItemWidth;
        var contentWidth = m_ItemWidth - m_TextPos - 10;
        m_Title._width = contentWidth;
        m_DescriptionText._width = contentWidth
        
        if (m_AchievementType == TYPE_PROGRESS)
        {
            UpdateProgressBar()
        }
        
        if (m_IsExpanded)
        {
            m_ItemHeight = RepositionSubAchievements();
        }
        else
        {
            m_ItemHeight = m_Background._height;
        }
        
        if (m_CompleteCheck != undefined)
        {
            m_CompleteCheck._x = m_ItemWidth - 25;
        }
        
        // notify parent if we change size
        if (height > m_Background._height)
        {
            SignalSizeChanged.Emit( m_Data.m_Id, GUI.Achievement.AchievementsPanelView.ACHIEVEMENT_CONTRACTED);
        }
        else if(height < m_Background._height)
        {
            SignalSizeChanged.Emit(  m_Data.m_Id, GUI.Achievement.AchievementsPanelView.ACHIEVEMENT_EXPANDED);
        }
    }
    
    public function SetWidth(width:Number)
    {
        m_ItemWidth = width;
        Layout();
    }
    

    
    private function SlotTagAdded(tagId:Number, character:ID32)
    {
        if (character.Equal(Character.GetClientCharID()))
        {
            var isParentUpdated:Boolean = false;
            if (tagId == m_Data.m_Id)
            {
                m_Data.m_Locked = false;
                Layout();
                isParentUpdated = true;
            }
            else 
            {
                for (var i:Number = 0; i < m_Data.m_Children.length; i++)
                {
                    var node:LoreNode = m_Data.m_Children[i];
                    if (tagId == node.m_Id)
                    {
                        node.m_Locked = false;
                        isParentUpdated = true;
                        
                        if (m_IsExpanded)
                        {
                            var achievement:MovieClip = m_SubAchievementsClip["achievement_" + node.m_Id];
                            if (achievement != undefined)
                            {
                                var xPos = achievement._x;
                                var yPos = achievement._y;
                                achievement.removeMovieClip();
                                achievement = m_SubAchievementsClip.attachMovie("AchievementNoImageEnabled", "achievement_" + node.m_Id, m_SubAchievementsClip.getNextHighestDepth());    
                                achievement._x = xPos;
                                achievement._y = yPos;
                                achievement.m_Text.text = node.m_Name;
                                achievement.m_Text._height = achievement.m_Text.textHeight + 5;
                                if (node.m_IsNew)
                                {
                                    AddChildNotification(node,achievement )
                                }
                            }
                        }
                        
                        break;
                    }
                }
            }
            
            if (isParentUpdated)
            {
                m_IsInProgress = true;
                if (Lore.IsLocked(m_Data.m_Id))
                {
                    SetAchievementInProgress();
                }
                else
                {
                    SetAchievementCompleted();
                }
                AddNotification();
            }
        }
    }
    
    private function SetAchievementCompleted()
    {
        m_IsCompleted = true;
        if (this["m_InProgress"] != undefined)
        {
            this["m_InProgress"].removeMovieClip()
            this["m_InProgress"] = undefined;
        }
        this._alpha = 100;
        com.Utils.Colors.Tint(m_Icon, 0x000000, 0);
        com.Utils.Colors.Tint(m_Background, 0x000000, 0);
        m_CompleteCheck = attachMovie("checkmark", "m_CompleteCheck", getNextHighestDepth());
        m_CompleteCheck._y = 5;
        m_CompleteCheck._x = m_ItemWidth - 25
    }
    
    private function SetAchievementInProgress()
    {
        m_IsInProgress = true;
        if (this["m_InProgress"] == undefined)
        {
            var inProgress:MovieClip = attachMovie("_Icon_Modifier_InProgress", "m_InProgress", getNextHighestDepth());
            inProgress._x = m_Icon._x + m_Icon._width - 17;
            inProgress._y = m_Icon._y + m_Icon._height - 17
            com.Utils.Colors.Tint(m_Icon, 0x000000, 0);
        }
    }
    
    private function AddNotification()
    {
        if (m_Icon.m_NewNotification == undefined)
        {
            var notification:MovieClip = m_Icon.attachMovie( "NewNotification", "m_NewNotification", m_Icon.getNextHighestDepth());
            notification._y = -3;
            notification._x = 43;
        }
    }

    private function AddChildNotification(dataNode:LoreNode, target:MovieClip)
    {
        dataNode.m_IsNew = false;
        var notification:MovieClip = target.attachMovie( "NewNotification", "m_NewNotification", target.getNextHighestDepth());
        notification._xscale = 80;
        notification._yscale = 80;
        notification._y = 2;
        notification._x = -2;
        notification.tweenTo(5, { _alpha:20 }, None.easeNone);
        notification.onTweenComplete = function()
        {
            this.removeMovieClip();
            this = undefined;
            Lore.MarkAsOld( dataNode.m_Id );
            GUI.Achievement.AchievementWindow.SignalTagRead.Emit(dataNode.m_Id);
        }
        
    }
    
    private function UpdateProgressBar()
    {
        var target:Number = Lore.GetCounterTargetValue(m_Data.m_Id);
        var current:Number = Lore.GetCounterCurrentValue(m_Data.m_Id);
        if (current > target) { current = target; }
        
        var progressWidth:Number = m_ItemWidth - m_TextPos - 10;
        m_AchievementProgressBarBackground._width = progressWidth
        m_AchievementProgressText._x = ((progressWidth - m_AchievementProgressText._width) * 0.5) + m_TextPos;
        
        m_AchievementProgressText.text = current + "/" + target;
        m_AchievementProgressBar._width = (progressWidth - 8)*(current / target);
    }
    
    private function LoadImage(container:MovieClip, mediaId:Number)
    {
		var path = com.Utils.Format.Printf( "rdb:%.0f:%.0f", _global.Enums.RDBID.e_RDB_FlashFile, mediaId );
        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        movieClipLoader.addListener( this );
		var isLoaded = movieClipLoader.loadClip( path, container );
    }
    
    private function onLoadInit( target:MovieClip )
    {
        target._height = 50;
        target._width = 50;
    }
    
 
    private function onLoadError(target:MovieClip, errorcode:String, httpStatus:Number)
    {
        trace("AchievementItem:onLoadError( " + errorcode+", httpStatus = "+httpStatus);
    }

    public function SetSelected(selected:Boolean) : Void
    {
        m_IsSelected = selected;
        m_Frame._visible = selected;
    }
    
    public function GetHeight():Number
    {
        return m_ItemHeight;
    }
    
    private function Contract(snap:Boolean)
    {
        m_ItemHeight -= m_SubAchievementsClip._height;
        m_Background.tweenTo(0.3, { _height: m_ItemHeight }, None.easeNone);
        m_Frame.tweenTo(0.3, { _height: m_ItemHeight }, None.easeNone);
        m_ExpandButton.tweenTo(0.3, { _y:m_ItemHeight - 10, _rotation:0 }, None.easeNone);
        m_SubAchievementsClip.tweenTo( 0.2, { _alpha:0, _yscale:0 }, None.easeNone);
        m_SubAchievementsClip.onTweenComplete = function()
        {
           this._visible = false;
        }
        
        SignalClicked.Emit( m_Data.m_Id, GUI.Achievement.AchievementsPanelView.ACHIEVEMENT_CONTRACTED, false );
        m_IsExpanded = false;
    }
    
    private function Expand(snap:Boolean)
    {
        var numColumns:Number = Math.floor((m_Background._width - 15 - m_TextPos) / m_ChildWidth);
        var numRows:Number = Math.ceil( m_Data.m_Children.length / numColumns);

        if (m_Data.m_IsNew && m_SubAchievementsClip != undefined)
        {
            m_SubAchievementsClip.removeMovieClip();
            m_SubAchievementsClip = undefined
        }

        if (m_Icon.m_NewNotification != undefined)
        {
            m_Icon.m_NewNotification.tweenTo(5, { _alpha:20 }, None.easeNone)
            m_Icon.m_NewNotification.onTweenComplete = function()
            {
                this.removeMovieClip();
                this = undefined;
            }
        }
        
        if (m_SubAchievementsClip == undefined)
        {
            m_SubAchievementsClip = createEmptyMovieClip("m_SubAchievementsClip", getNextHighestDepth());
            for (var i:Number = 0; i < m_Data.m_Children.length; i++ )
            {
                var dataNode:LoreNode = m_Data.m_Children[i];
                var achievement:MovieClip;
                if (dataNode.m_Locked)
                {
                    achievement = m_SubAchievementsClip.attachMovie("AchievementNoImageDisabled", "achievement_" + dataNode.m_Id, m_SubAchievementsClip.getNextHighestDepth());    
                }
                else
                {
                    achievement = m_SubAchievementsClip.attachMovie("AchievementNoImageEnabled", "achievement_" + dataNode.m_Id, m_SubAchievementsClip.getNextHighestDepth());
                    // if this is a new acievement. Fade the notification out and mark as old
                    if (Lore.IsNew( dataNode.m_Id ))
                    {
                        AddChildNotification(dataNode, achievement)
                    }
                }
                
                achievement.m_Text.text = dataNode.m_Name;
                achievement.m_Text._height = achievement.m_Text.textHeight + 5;
            }
            
            
        }
        else
        {
            m_SubAchievementsClip._yscale = 100;
        }
        
        m_ItemHeight = RepositionSubAchievements( );
       //var newHeight:Number = m_DescriptionText._y + m_DescriptionText._height + m_SubAchievementsClip._height + 20;

        if (snap)
        {
            m_Background._height = m_ItemHeight;
            m_Frame._height = m_ItemHeight;
            
            if (m_ExpandButton != undefined)
            {
                m_ExpandButton._y = m_ItemHeight - 10;
                m_ExpandButton._rotation = 180;
            }
            m_SubAchievementsClip._visible = true;
        }
        else
        {
            m_Background.tweenTo(0.3, { _height:m_ItemHeight }, None.easeNone);
            m_Frame.tweenTo(0.3, { _height:m_ItemHeight }, None.easeNone);
            if (m_ExpandButton != undefined)
            {
                m_ExpandButton.tweenTo(0.3, { _y: m_ItemHeight - 10, _rotation:180}, None.easeNone)
            }
            m_SubAchievementsClip._visible = true;
            m_SubAchievementsClip._alpha = 0;
            m_SubAchievementsClip.tweenTo(0.5, { _alpha:100 }, None.easeNone);
            m_SubAchievementsClip.onTweenComplete = undefined;
        }
        m_IsExpanded = true;
        SignalClicked.Emit( m_Data.m_Id, GUI.Achievement.AchievementsPanelView.ACHIEVEMENT_EXPANDED, snap );
    }
    
    /// repositioned the sub achievements
    function RepositionSubAchievements() : Number
    {
        var newHeight:Number = 0;
        var ypos:Number = 0;
        var height:Number = 0;
        var column:Number = 0;
        var row:Number = 0;
        var rowMaxHeight:Number = 0;
        var numColumns:Number = Math.floor((m_Background._width - 15 - m_TextPos) / m_ChildWidth);
        
        for (var i:Number = 0; i < m_Data.m_Children.length; i++ )
        {
            var dataNode:LoreNode = m_Data.m_Children[i];
            var achievement:MovieClip = m_SubAchievementsClip["achievement_" + dataNode.m_Id];
            achievement._x = m_TextPos + column * (m_ChildWidth + 3);
            achievement._y = m_DescriptionText._y + m_DescriptionText._height + ypos;
            rowMaxHeight = Math.max(rowMaxHeight, achievement._height);
            column++;
            if (column == numColumns)
            {
                row++
                column = 0;
                ypos += rowMaxHeight;
                rowMaxHeight = achievement._height;
            }
        }
        
        newHeight = m_DescriptionText._y + m_DescriptionText._height + m_SubAchievementsClip._height + 15;
        if (m_IsExpanded)
        {
            m_Background._height = newHeight;
            m_Frame._height = newHeight;
            m_ExpandButton._y = m_Background._height - 10;
        }
        return newHeight;
    }
    
    private function ExpandHandler()
    {
        if ( m_IsExpanded )
        {
            Contract(false);
            
        }
        else
        {
            Expand(false);
            
        }
    }

}