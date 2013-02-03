import com.Utils.LDBFormat;
import com.GameInterface.LoreNode;
import com.GameInterface.Lore;
import com.GameInterface.LoreBase;
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import com.Utils.Signal;
import GUI.Achievement.ViewPanelBase;
import gfx.motion.Tween; 
import mx.transitions.easing.*;
import mx.utils.Delegate;

class GUI.Achievement.AchievementsPanelView extends ViewPanelBase
{
    public static var ACHIEVEMENT_EXPANDED:Number = 0;
    public static var ACHIEVEMENT_CONTRACTED:Number = 1;
    
    private var m_IsLeafNode:Boolean;
    private var m_Data:LoreNode;
    private var m_SelectedAchievement:MovieClip;
    private var m_TDB_LoreEntryLocked:String;
    private var m_DrawProgressMeters:Boolean;
    private var m_ProgressBackground:MovieClip;
    
    
    public var SignalClicked:Signal;
    
    public function AchievementsPanelView()
    {
        super();
        m_TDB_LoreEntryLocked = LDBFormat.LDBGetText( "GenericGUI", "LoreEntryLocked" );
        SignalClicked = new Signal;
        m_DrawProgressMeters = false;
        m_HasAchievementEntries = false;
        m_ContentY = 3;
    }
    
    public function SetData(data:LoreNode)
    {
        super.SetData( data );
        if (initialized)
        {
            init();
        }
    }
    
    private function configUI()
    {
        if (m_Data != undefined)
        {
            SetMedia();
            init();
        }
    }
    
    private function init()
    {
        Lore.SignalTagAdded.Connect(SlotTagAdded, this);
        
        if (!m_HasMedia)
        {
            m_ContentY = 3;
        }
        if (m_Data.m_Type == _global.Enums.LoreNodeType.e_AchievementCategory)
        {
            DrawAchievementsEntries();
        }
        
     //   m_IsInitialized = true;
    }
    

    
    public function GetYPos(id:Number)
    {
        if (Lore.IsValidId(id))
        {
            var focusId:Number = id;
            if (Lore.GetTagType(id) == _global.Enums.LoreNodeType.e_SubAchievement)
            {
                focusId = Lore.GetDataNodeById(id).m_Parent.m_Id;
            }
            if (m_Content["achievement_" + focusId] != undefined)
            {
                return m_Content["achievement_" + focusId]._y + m_Content["achievement_" + focusId]._height*2/3;
            }
        }
        return 0;
    }
    
    public function SetSize(width:Number, height:Number)
    {
       // m_Width = width;
       // m_Height = height;
        super.SetSize(width, height);


    }
    
    private function DrawAchievementsEntries()
    {
        if (m_Content != undefined)
        {
            m_Content.removeMovieClip();
        }
        
        m_Content = this.createEmptyMovieClip("m_Content", this.getNextHighestDepth());
        m_Content._y = m_ContentY;
        
        m_DrawProgressMeters = true;
        var ypos:Number = 0;
        for (var i:Number = 0; i < m_Data.m_Children.length; i++ )
        {
            
            var loreNode:LoreNode = m_Data.m_Children[i];
            if (loreNode.m_Type != _global.Enums.LoreNodeType.e_AchievementCategory)
            {
                var name:String = "achievement_" + MovieClip(this).UID();
                var achievement:MovieClip = m_Content.attachMovie("AchievementItem", name, m_Content.getNextHighestDepth() );
                m_Content["achievement_" + loreNode.m_Id] = achievement;
                achievement.SetData(loreNode);
                achievement.SetWidth( m_Width );
                achievement._y = ypos;
                ypos += achievement._height + 5;
                achievement.SignalClicked.Connect( SlotAchievementClicked, this);
                achievement.SignalSizeChanged.Connect( SlotAchievementSizeChanged, this);
                m_DrawProgressMeters = false;
                m_HasAchievementEntries = true;
            }
        }
        
        if (m_DrawProgressMeters)
        {
            DrawProgressMeters();
        }
    }
    
    private function SlotTagAdded(tagId:Number, character:ID32)
    {
        if (character.Equal(Character.GetClientCharID()) && m_DrawProgressMeters)
        {
            UpdateProgressMeters();
        }
    }
    
    private function SlotAchievementSizeChanged(id:Number, action:Number)
    {
        UpdateWindowContentSize(id, true);
    }
    
    private function SlotAchievementClicked(id:Number, action:Number, snap:Boolean)
    {
        if (m_SelectedAchievement != undefined)
        {
            m_SelectedAchievement.SetSelected(false);
        }
        m_SelectedAchievement = m_Content["achievement_" + id]
        
        if (action == ACHIEVEMENT_EXPANDED)
        {
            m_SelectedAchievement.SetSelected(true);
        }
        else if (action == ACHIEVEMENT_CONTRACTED)
        {
            m_SelectedAchievement.SetSelected(false);
        }
        
        UpdateWindowContentSize(id, snap);

        if (snap)
        {
            EmitSignalClicked();
        }
    }
    
    private function UpdateWindowContentSize(id:Number, snap:Boolean)
    {
        var ypos:Number = 0;
        var doMove:Boolean = false;

        for (var i:Number = 0; i < m_Data.m_Children.length; i++ )
        {
            var loreNode:LoreNode = m_Data.m_Children[i];

            if (doMove)
            {
                var achievement = m_Content["achievement_" + loreNode.m_Id];
                if (snap)
                {
                    achievement._y = ypos;
                }
                else
                {
                    achievement.tweenTo(0.3, { _y: ypos }, None.easeNone );
                    if (i == m_Data.m_Children.length - 1 )
                    {
                        achievement.onTweenComplete = Delegate.create(this, EmitSignalClicked);
                    }
                }
                ypos += achievement._height+5;
            }
            else if (loreNode.m_Id == id)
            {
                var selectedAchievement:MovieClip = m_Content["achievement_" + id];
                doMove = true;
                ypos = selectedAchievement._y + selectedAchievement.GetHeight() + 5;
            }
        }
    }
    
    private function EmitSignalClicked()
    {
        SignalClicked.Emit( );
    }
}