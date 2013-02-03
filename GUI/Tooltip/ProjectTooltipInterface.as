import com.GameInterface.Utils;
import com.GameInterface.Tooltip.TooltipData;
import GUIFramework.SFClipLoader;
import GUI.Tooltip.TooltipPanel;
import com.GameInterface.GUIModuleIF;


import gfx.motion.Tween;
import mx.transitions.easing.*
import mx.utils.Delegate;


class GUI.Tooltip.ProjectTooltipInterface extends com.GameInterface.Tooltip.TooltipInterface
{
    public function ProjectTooltipInterface( orientation:Number, tooltipDataArray:Array )
    {
        super( orientation, tooltipDataArray );

        /// Make sure the tooltip is closed when we die.
        m_Destructor = new com.Utils.Destructor( null );
        m_Destructor.SignalDying.Connect( function ( tooltipContainer ) { tooltipContainer._parent.UnloadClip(); } );

        m_TooltipWidth              = 250;
        m_PanelSpacing              = 7;

        m_IsClosing = false;        
    }

    // Overloaded from TooltipInterface. Should remove all panels from the screen.
    public function Close()
    {
        m_Destructor.Clear();
        m_IsClosing = true;
        if ( m_TooltipContainer != undefined )
        {
            m_TooltipContainer._parent.UnloadClip();
            m_TooltipContainer = undefined;
        }
    }

    // Overloaded from TooltipInterface. Turn the tooltip into a normal floating window with a close button.
    public function MakeFloating()
    {
        if ( !m_IsFloating )
        {
            m_Destructor.Clear();
            m_IsFloating = true;
            if ( m_TooltipContainer != undefined )
            {
                DoMakeFloating();
            }
        }
    }

    // Overloaded from TooltipInterface. Should return false while the tooltip SWF is loading. Then true.
    public function IsDoneLoading() : Boolean { return m_TooltipContainer != undefined; }

    // Overloaded from TooltipInterface. Returns the number of panels being displayed (for compare mode).
    public function GetPanelCount() : Number
    {
        return m_TooltipArray.length;
    }

    // Overloaded from TooltipInterface. Returns the total size of the tooltip (including all panels, panel spacing) in pixels.
    public function GetSize() : flash.geom.Point
    {
        var size:flash.geom.Point = new flash.geom.Point(0,0);

        
        if ( m_Orientation == e_OrientationHorizontal )
        {
            size.x = (m_TooltipArray.length - 1) * m_PanelSpacing;
        }
        else
        {
            size.y = (m_TooltipArray.length - 1) * m_PanelSpacing;
        }

        for ( var i:Number = 0 ; i < m_TooltipArray.length ; ++i )
        {
            var panel:TooltipPanel = m_TooltipArray[i];
            var panelSize:flash.geom.Point = panel.GetSize();

            if ( m_Orientation == e_OrientationHorizontal )
            {
                if ( panelSize.y > size.y )
                {
                    size.y = panelSize.y;
                }
                size.x += panelSize.x;
            }
            else
            {
                if ( panelSize.x > size.x )
                {
                    size.x = panelSize.x;
                }
                size.y += panelSize.y;
            }                
        }
        
        return size;
    }

    // Overloaded from TooltipInterface. Returns the size of an individual panel. Not including any between-panel spacing.
    public function GetPanelSize( index:Number ) : flash.geom.Point
    {
        return m_TooltipArray[index].GetSize();
    }

    // Overloaded from TooltipInterface. Sets the top-left corner of the entire tooltip (including all panels).
    public function SetGlobalPosition( pos:flash.geom.Point ) : Void
    {
        m_TooltipContainer._x = pos.x;
        m_TooltipContainer._y = pos.y;
    }

    // Overloaded from TooltipInterface. Set the top-left corner of a single panel relative to the global position.
    private function SetPanelPosition( index:Number, pos:flash.geom.Point ) : Void
    {
        m_TooltipArray[index].SetPosition( pos );
    }

    /// This member is called by Tooltip.swf when it is done loading.
    /// Here we setup all the visuals.
    public function SetTooltipContainer( tooltipContainer:MovieClip ) : Void
    {
        if ( !m_IsClosing )
        {
            m_TooltipContainer = tooltipContainer;
            m_Destructor.Set( tooltipContainer );

            var compareMode:Boolean = m_TooltipDataArray.length > 1;
            for ( var i:Number = 0 ; i < m_TooltipDataArray.length ; ++i )
            {
                var panel:TooltipPanel = new TooltipPanel( tooltipContainer, m_TooltipDataArray[i], compareMode );
                panel.SignalSizeChanged.Connect( SlotPanelSizeChanged, this );
                m_TooltipArray.push( panel );
                //if ( m_IsFloating ) break;
            }

            tooltipContainer._alpha = 0;
            tooltipContainer.tweenTo( 0.7, {_alpha:100}, Strong.easeOut );

            SlotPanelSizeChanged();

            if ( m_IsFloating )
            {
                DoMakeFloating();
            }
        }
        else
        {
            tooltipContainer.removeMovieClip();
        }
    }
    
    private function SlotPanelSizeChanged() : Void
    {
        var size:flash.geom.Point = GetSize();
        if ( m_Orientation == e_OrientationHorizontal )
        {
            for ( var i:Number = 0 ; i < m_TooltipArray.length ; ++i )
            {
                m_TooltipArray[i]._height = size.y;
            }
        }
        UpdatePosition();
    }
    
    private function DoMakeFloating() : Void
    {
        if ( m_TooltipArray.length > 0 )
        {
            var mainPanel:TooltipPanel = m_TooltipArray[0];
			
            mainPanel.ShowCloseButton( true );
            mainPanel.SetCompareMode( false );
            mainPanel.ShowIcon( true );
            
            var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
            moduleIF.SignalDeactivated.Connect(Close, this);
            mainPanel.m_Clip.m_CloseButton.onRelease = Delegate.create( this, this.Close );
            mainPanel.m_Clip.m_Background.onPress   = function() { this._parent._parent.startDrag(); }
            mainPanel.m_Clip.m_Background.onRelease = function() { this._parent._parent.stopDrag();  }
            mainPanel.m_Clip.m_Background.onReleaseOutside = function() { this._parent._parent.stopDrag();  }
        }
        SFClipLoader.SetClipLayer( SFClipLoader.GetClipIndex( m_TooltipContainer._parent ), _global.Enums.ViewLayer.e_ViewLayerDialogs, 0 );
        UpdatePosition();
    }


    private var m_TooltipWidth:Number;
    private var m_TooltipContainer:MovieClip;
    private var m_Destructor:com.Utils.Destructor;
    private var m_IsClosing:Boolean;
}
