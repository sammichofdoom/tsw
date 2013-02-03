import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import mx.utils.Delegate;
import com.Components.WeaponResources.ResourceDataObject;

class com.Components.ResourceBase extends UIComponent
{
    public static var DIRECTION_LEFT:String = "left";
    public static var DIRECTION_RIGHT:String = "right";
    
    public static var DISPLAY_BAR:Number = 0;
    public static var DISPLAY_POINTS:Number = 1;
        
    public var m_IsTweening:Boolean;
    private var m_MaxAmount:Number;
    private var m_PreviousAmount:Number;
    private var m_Amount:Number;
    private var m_IsTargetResourceBuilder:Boolean;
    private var m_IsDirectional:Boolean;
    private var m_ResourceDisplayType:Number;
    private var m_Throttle:Boolean;
    private var m_IsInCombat:Boolean;
    
    private var m_ResourceData:ResourceDataObject;
    
    private var m_Icon:MovieClip;
    private var m_Background:MovieClip;
    
    public function ResourceBase()
    {
        super();
        m_Throttle = false;
        m_IsInCombat = false;
        m_IsTweening = false;
		m_MaxAmount = 5;
		m_PreviousAmount = 0;
		m_IsTargetResourceBuilder= false;
		m_IsDirectional= false;
		
    }
    
    private function configUI()
    {
        m_Icon._alpha = 40;
    }
    
    public function SetAmount(amount:Number, snap:Boolean)
    {
        m_Amount = amount;
        if (m_Icon != undefined)
        {
            m_Icon._alpha = (m_Amount == 0) ? 40 : 100;
        }

        Layout(snap);
    }
    
    public function SetScale(scale:Number)
    {
        _xscale = scale;
        _yscale = scale;
    }
    
    public function SetPosition( x:Number, y:Number)
    {
        _x = x;
        _y = y;
    }
    
    public function ToggleCombat( isInCombat:Boolean )
    {
        m_IsInCombat = isInCombat;
        SetThrottle(m_Throttle);
    }
    
    public function SetThrottle(throttle:Boolean)
    {
        // to be overridden
    }
    
    public function SetData(resourceData:ResourceDataObject)
    {
        m_ResourceData = resourceData
    }
        
    public function GetTooltipId():Number 
    {
        return m_ResourceData.m_TooltipId;
    }
    
    public function IsTargetResourceBuilder()
    {
        return m_ResourceData.m_BuildsOnTarget;
    }
    
    public function IsDirectional()
    {
        return m_ResourceData.m_IsDirectional;
    }
    
    public function GetResource() : Number
    {
        return m_ResourceData.m_ResourceType;
    }
    
    private function Layout(snap:Boolean)
    {
      // to be overridden
    }
}