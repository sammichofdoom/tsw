import com.Utils.Colors;
import com.GameInterface.Log;

class GUI.HUD.AbilityBase extends MovieClip
{
    public static var ABILITY:Number = 0;
    public static var PASSIVE:Number = 1;
   
    public static var FLAG_OUT_OF_RANGE:Number = 0x1;
    public static var FLAG_NO_RESOURCE:Number = 0x2;
    public static var FLAG_DISABLED:Number = 0x8;
    public static var FLAG_CHANNELING:Number = 0x10;
    public static var FLAG_MAX_MOMENTUM:Number = 0x20; 
    
    // vars
   // public var m_ColorNum:Number = undefined;
    private var m_ColorObject:Object;
    public var m_Type:Number = ABILITY;
    private var m_IsEnabled:Boolean;
    private var m_Flags:Number;
    private var m_PrevState:Number;
    public var m_AuxilliaryFrame:MovieClip;
    public var m_EliteFrame:MovieClip;
    private var m_OuterLine:MovieClip;
    private var m_InnerLine:MovieClip;
    private var m_CooldownLine:MovieClip;
    private var m_BackgroundOverlay:MovieClip;
    private var m_BackgroundGradient:MovieClip;
    private var m_Gloss:MovieClip;
    public var m_Background:MovieClip;
    private var m_Content:MovieClip;
    private var m_Moviecliploader:MovieClipLoader;

    //private var m_SlotId:Number = -1;
    private var m_SpellId:Number;
    
    
    public function AbilityBase()
    {
        Clear();
        m_Moviecliploader = new MovieClipLoader();
    }
    
    public function Clear():Void
    {
        m_Flags = 0;
        m_SpellId = 0;
        m_IsEnabled = true;
        
        var content:MovieClip = this.m_Content.m_Content;
        
        if (content)
        {
            m_Moviecliploader.unloadClip(content);
            this.m_Content.m_Content = undefined;
        }
    }
    
    public function createChildren() : Void
    {
    }
    
    public function SetColor(colorLine:Number)
    {
        m_ColorObject = Colors.GetColorlineColors( colorLine );
        SetBackgroundColor(true);
    }
    
    public function SetSpellType( spellType )
    {
        if (spellType == _global.Enums.SpellItemType.eEliteActiveAbility || spellType == _global.Enums.SpellItemType.eElitePassiveAbility)
        {
            m_EliteFrame._visible = true;
        }
        else
        {
            m_EliteFrame._visible = false;
        }
    }
    
    public function SetSpellId(spellId:Number):Void
    {
        m_SpellId = spellId;
    }
    
    public function GetSpellId():Number
    {
        return m_SpellId;
    }
    
    /// loads an icon defined by the path into the content frame of the MovieClip
    /// @param path:String - Path to the icon that is to be loaded
    /// @return Void
    public function SetIcon(path:String) : Void
    {
        var content:MovieClip = this.m_Content.m_Content;
        
        if (!content)
        {
            content = m_Content.createEmptyMovieClip("m_Content", m_Content.getNextHighestDepth());
        }
        
        var isLoaded:Boolean = m_Moviecliploader.loadClip( path, content );
        
        content._x = 1;
        content._y = 1;
        content._xscale = m_Background._width-(content._x*2);
        content._yscale = m_Background._height-(content._y*2);
    }
    
    public function SetBackgroundColor(show:Boolean)
    {
        m_Background._visible = show
        if (show)
        {
            Colors.ApplyColor( m_Background.background, m_ColorObject.background );
            Colors.ApplyColor( m_Background.highlight, m_ColorObject.highlight );
        }
    }
        

    public function MergeFlags( flags:Number )
    {
        ReplaceFlags( m_Flags | flags );
    }

    private function ReplaceFlags( flags:Number )
    {
        if ( flags != m_Flags )
        {
            m_Flags = flags;
            UpdateVisuals();
        }
    }
    
    public function ClearFlags( flags:Number )
    {
        ReplaceFlags( m_Flags & ~flags );
    }

    public function HasFlags( flags:Number ) : Boolean
    {
        return (m_Flags & flags) != 0;
    }
    
    /// overloaded
    private function UpdateVisuals()
    {
        // stop it here;
    }
    
    public function GetIcon():MovieClip
    {
        return m_Content;
    }
    
    public function SetType(type:Number)
    {
        m_Type = type;
    }

    public function IsEnabled() : Boolean
    {
        return m_IsEnabled;
    }
}
