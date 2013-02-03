import com.GameInterface.SkillWheel.Cell;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.Game.Character;
import com.Utils.Signal;
import GUI.SkillHive.SkillHiveDrawHelper;
import flash.filters.GlowFilter;
import mx.utils.Delegate;

class GUI.SkillHive.CellClip extends MovieClip
{
    
    private var CELL_COLOR_RANGED:Number = 0x6f4040;
    private var CELL_COLOR_RANGED_PROGRESS:Number = 0xff5a5a;
    private var CELL_COLOR_RANGED_FULL:Number = 0xff8174;

    private var CELL_COLOR_MELEE:Number = 0x684a28;
    private var CELL_COLOR_MELEE_PROGRESS:Number = 0xd97d14;
    private var CELL_COLOR_MELEE_FULL:Number = 0xe08824;

    private var CELL_COLOR_MAGIC:Number = 0x2c5b8a;
    private var CELL_COLOR_MAGIC_PROGRESS:Number = 0x27abff;
    private var CELL_COLOR_MAGIC_FULL:Number = 0x71ceff;
    
    private var CELL_COLOR_MISC:Number = 0x385d31;
    private var CELL_COLOR_MISC_PROGRESS:Number = 0x6aff5b;
    private var CELL_COLOR_MISC_FULL:Number = 0x6aff5b;
	
    private var CELL_COLOR_AUXILLIARY:Number = 0x1a6673;
    private var CELL_COLOR_AUXILLIARY_PROGRESS:Number = 0x7eeced;
    private var CELL_COLOR_AUXILLIARY_FULL:Number = 0x7eeced;
    
    private var m_EmptyColor:Number;
    private var m_ProgressColor:Number;
    private var m_FullColor:Number;
    
    private var m_Cell:Cell;
    public var m_Angle:Number;
    public var m_Radius:Number;
    public var m_StartAngle:Number;
    
    //Draw variables
    public var m_Thickness:Number
    private var m_Selected:Boolean
    private var m_Hovered:Boolean
    
    public var SignalClick:Signal;
    public var SignalRollOver:Signal;
    public var SignalRollOut:Signal;
   
    private var m_CompletionClip:MovieClip;
    private var m_IntervalID:Number;
    
    var m_Glow:GlowFilter;
    
    public function CellClip()
    {
        super();
        
        m_CompletionClip = createEmptyMovieClip("m_Completion", getNextHighestDepth());
        
        SignalClick = new Signal();
        SignalRollOver = new Signal();
        SignalRollOut = new Signal();
        
        m_Thickness = 15;
        m_Selected = false;
        
        m_Glow = new GlowFilter(0xffffff, 80, 20, 20, 1, 1, false, false );
        
        //Replace for onRollOver & onRollOut event listeners to fix [TSW-102172]
        m_IntervalID = setInterval(Delegate.create(this, CheckMouseOver), 100);
    }
    
    //On Unload
    private function onUnload():Void
    {
        if (m_IntervalID)
        {
            clearInterval(m_IntervalID);
            m_IntervalID = null;
        }
    }
    
    function Draw()
    {
        /*_alpha = 100;
        if (IsLocked())
        {
            if (_parent._alpha >= 100)
            {
                //Set alpha only if  parent isnt hidden
                _alpha = 10;
            }
        }*/
        
        clear();
        var strokeWidth:Number = 0;
        if (m_Selected)
        {
            strokeWidth = 1;
        }
        SkillHiveDrawHelper.MakeArch( this, m_Radius, m_Angle, m_Thickness, m_StartAngle, m_EmptyColor, 100, strokeWidth, 0xFFFFFF,false);
        
        m_CompletionClip.clear();
        var completion:Number = m_Cell.m_Completion;
        if (completion != NaN && completion > 0 && completion != undefined && m_CompletionClip != undefined)
        {
			var color:Number = m_ProgressColor;
			if (completion >= 1)
			{
				color = m_FullColor;
			}
            SkillHiveDrawHelper.MakeArch( m_CompletionClip, m_Radius + 0.2, m_Angle * completion, m_Thickness - 0.2, m_StartAngle, color, 100, 0, 0x999999, false);
        }
    }
    
    private function CheckMouseOver()
    {
        if ( _visible && _parent._visible && hitTest(_root._xmouse, _root._ymouse, true) )
        {
            if (!m_Hovered)
            {
                onRollOverClip();
            }
        }
        else
        {
            if (m_Hovered || m_Selected)
            {
                onRollOutClip();
            }
        }
    }
    
    public function onPress()
    {
        SignalClick.Emit(this)
    }
    
    public function onRollOverClip()
    {
        SignalRollOver.Emit(this);
    }
    
    public function onRollOutClip()
    {
        SignalRollOut.Emit(this);
    }
    
    public function onDragOut()
    {
        SignalRollOut.Emit(this);
    }
    
    public function SetCell(cell:Cell)
    {
        m_Cell = cell;       
        UpdateColors();
    }
    
    public function GetCell():Cell
    {
        return m_Cell;
    }
        
    private function IsLocked():Boolean
    {
        var feat:FeatData = FeatInterface.m_FeatList[m_Cell.m_Abilities[0]];
		if (feat != undefined && feat.m_CanTrain || feat.m_Trained)
		{
            return false;
        }
        return true;
    }
    
    public function SetSelected(selected:Boolean)
    {
        if (selected != m_Selected)
        {
            m_Selected = selected;
            UpdateDrawState();
            if (m_Selected)
            {
                m_Thickness = 22;
            }
            else
            {
                m_Thickness = 15;
            }
            
        }
    }
    
    public function IsSelected()
    {
        return m_Selected;
    }
    
    public function SetHovered(hovered:Boolean)
    {
        if (hovered != m_Hovered)
        {
            m_Hovered = hovered;
            UpdateDrawState();
        }
            
        Draw();
    }
    
    private function UpdateDrawState()
    {
        if (m_Hovered || m_Selected)
        {
            m_Thickness = 22;
            
            this.filters = [ m_Glow ];
        }
        else
        {
            m_Thickness = 15;
            this.filters = [ ];
        }
        Draw();        
    }
    
    function UpdateColors()
    {
        if (m_Cell.m_ClusterId < 100)
        {
            m_EmptyColor = CELL_COLOR_MELEE;
            m_ProgressColor = CELL_COLOR_MELEE_PROGRESS;
            m_FullColor = CELL_COLOR_MELEE_FULL;
        }
        else if (m_Cell.m_ClusterId  < 200)
        {
            m_EmptyColor = CELL_COLOR_MAGIC;
            m_ProgressColor = CELL_COLOR_MAGIC_PROGRESS;
            m_FullColor = CELL_COLOR_MAGIC_FULL;
        }
        else if (m_Cell.m_ClusterId  < 300)
        {
            m_EmptyColor = CELL_COLOR_RANGED;
            m_ProgressColor = CELL_COLOR_RANGED_PROGRESS;
            m_FullColor = CELL_COLOR_RANGED_FULL;
        }
        else if (m_Cell.m_ClusterId  >= 2000 && m_Cell.m_ClusterId < 2100)
        {
            m_EmptyColor = CELL_COLOR_MISC;
            m_ProgressColor = CELL_COLOR_MISC_PROGRESS;
            m_FullColor = CELL_COLOR_MISC_FULL;
        }
		else if(m_Cell.m_ClusterId  >= 2100 && m_Cell.m_ClusterId < 2399)
        {
            m_EmptyColor = CELL_COLOR_AUXILLIARY;
            m_ProgressColor = CELL_COLOR_AUXILLIARY_PROGRESS;
            m_FullColor = CELL_COLOR_AUXILLIARY_FULL;
        }
    }
    
    public function GetID()
    {
        return m_Cell.m_Id;
    }
    
    public function GetParentClusterID()
    {
        return m_Cell.m_ClusterId;
    }
}