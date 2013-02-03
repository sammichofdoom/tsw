//Imports
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.Utils.Signal;
import com.Utils.SignalGroup;
import flash.external.*;
import flash.geom.Rectangle;
import mx.transitions.easing.*;

//Class
class com.Utils.HUDController
{
    //Constants
    public static var s_ResolutionScaleMonitor = DistributedValue.Create("GUIResolutionScale");
    public static var s_HUDScaleMonitor = DistributedValue.Create("GUIScaleHUD");
    
    //Properties
    private static var s_RegisteredModules:Object = new Object;

    //Constructor
    public function HUDController()
    {
        Stage.addListener(this);

        UpdateResolutionScale();
        s_ResolutionScaleMonitor.SignalChanged.Connect(Layout);
        s_HUDScaleMonitor.SignalChanged.Connect(Layout);
    }

    //Register Module
    public static function RegisterModule(name:String, movie:MovieClip):Void
    {
        s_RegisteredModules[name] = movie;
        
        if (movie.hasOwnProperty("SizeChanged"))
        {
            movie.SizeChanged.Connect(Layout);
        }
        
        Layout();
    }

    //Get Hide Position 2
    public static function GetHidePosition2(realPos:Rectangle):Rectangle
    {
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];

        var distToCenterX = realPos.x + realPos.width * 0.5 - visibleRect.width * 0.5;
        var distToCenterY = realPos.y + realPos.height * 0.5 - visibleRect.height * 0.5;

        if (Math.abs(distToCenterX) > Math.abs(distToCenterY))
        {
            if (distToCenterX > 0)
            {
                return new Rectangle(visibleRect.x + visibleRect.width + 20, realPos.y, realPos.width, realPos.height);
            }
            else
            {
                return new Rectangle(-(realPos.width + 20), realPos.y, realPos.width, realPos.height);
            }
        }
        else
        {
            if (distToCenterY > 0)
            {
                return new Rectangle(realPos.x, visibleRect.y + visibleRect.height + 20, realPos.width, realPos.height);
            }
            else
            {
                return new Rectangle(realPos.x, -(realPos.height + 20), realPos.width, realPos.height);
            }
        }
    }
    
    //Get Hide Position
    public static function GetHidePosition(realPos:Rectangle):Rectangle
    {
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];

        var distToCenterX = realPos.x + realPos.width * 0.5 - visibleRect.width * 0.5;
        var distToCenterY = realPos.y + realPos.height * 0.5 - visibleRect.height * 0.5;

        if (Math.abs(distToCenterX) > Math.abs(distToCenterY))
        {
            if (distToCenterX > 0)
            {
                return new Rectangle(realPos.x + 100, realPos.y, realPos.width, realPos.height);
            }
            else
            {
                return new Rectangle(realPos.x - 100, realPos.y, realPos.width, realPos.height);
            }
        }
        else
        {
            if (distToCenterY > 0)
            {
                return new Rectangle(realPos.x, realPos.y + 100, realPos.width, realPos.height);
            }
            else
            {
                return new Rectangle(realPos.x, realPos.y - 100, realPos.width, realPos.height);
            }
        }
    }
    
    //Deregister Module
    public static function DeregisterModule(name:String):Void
    {
        var movie:MovieClip = s_RegisteredModules[name];
        
        if (movie.hasOwnProperty("SizeChanged"))
        {
            movie.SizeChanged.Disconnect(null, Layout);
        }

        delete s_RegisteredModules[ name ];
        Layout();
    }

    //Get Module
    public static function GetModule(name:String):MovieClip
    {
        if (s_RegisteredModules.hasOwnProperty(name))
        {
            return s_RegisteredModules[name];
        }
        else
        {
            return null;
        }
    }

    //Update Resolution Scale
    private static function UpdateResolutionScale():Void
    {
        /*
         *  ResolutionScaleMonitor set values are based on what matches the
         *  concept the most in 1600x900 displays with a reference picture
         *  overlay.
         *
         */
        
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
        s_ResolutionScaleMonitor.SetValue(Math.max(Math.min(1600, visibleRect.width) / 1702, 0.80));
    }
    
    //On Resize
    private function onResize():Void
    {
        UpdateResolutionScale();
        Layout();
    }

    //Set Module Pos
    private static function SetModulePos(movie:MovieClip, x:Number, y:Number, hideOffsetX:Number, hideOffsetY:Number):Void
    {
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];

        movie._x = visibleRect.x + x;
        movie._y = visibleRect.y + y;
    }
    
    //Layout
    private static function Layout():Void
    {
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
        var dv:DistributedValue = new DistributedValue("GUIResolutionScale");
        var movie:MovieClip;
        var abilityBarTop:Number = 0;
        var xpBarHeight:Number = 0;
        var scale:Number = dv.GetValue();
		scale *= s_HUDScaleMonitor.GetValue() / 100;

        movie = GetModule("HUDBackground");
        if (movie != null)
        {
            var oldwidth:Number = movie._width;
            movie._width = visibleRect["width"]
            movie._height = movie._height * (movie._width/ oldwidth)

            SetModulePos    (
                            movie,
                            0,
                            visibleRect.height - movie._height,
                            0,
                            visibleRect.height - movie._height
                            );
        }

        movie = GetModule("AbilityBar");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            /*
             *  m_BaseWidth is a member of GUI.HUD.AbilityBar.as to serve as a 
             *  constant.  Without this constant, unintentional repositioning of
             *  the AbilityBar will occur:
             * 
             *  http://jira.funcom.com/browse/TSW-101595
             *
             */
            
            var baseWidth:Number = movie.m_BaseWidth * scale;
                
            SetModulePos    (
                            movie,
                            (visibleRect.width - baseWidth) * 0.5,
                            visibleRect.height - 79 * scale,
                            0,
                            movie._height + 2 * scale
                            );

            abilityBarTop = movie.getBounds(_root).yMin;
        }

        movie = GetModule("AAPassivesBar");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            var y:Number = visibleRect.height - 79 * scale;
            
            SetModulePos    (movie,
                            (visibleRect.width - movie._width) * 0.5 - 10 * scale,
                            y,
                            0,
                            movie._height - 41 * scale
                            );
            
            abilityBarTop = movie.getBounds(_root).yMin;
        }
        
        movie = GetModule("SprintBar");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            (visibleRect.width - movie._width) * 0.5, (abilityBarTop - visibleRect.y) - 75 * scale,
                            (visibleRect.width - movie._width) * 0.5, (abilityBarTop - visibleRect.y) - 75 * scale,
                            0, abilityBarTop - 55 * scale
                            );
        }

        movie = GetModule("AbilityList");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            visibleRect.width - 20 * scale, 0,
                            20 * scale,
                            0
                            );
        }

        movie = GetModule("PassivesList");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            visibleRect.width - 20 * scale,
                            0,
                            20 * scale,
                            0
                            );
        }

        movie = GetModule("PlayerInfo");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            (visibleRect.width - movie._width) * 0.5 - 400 * scale,
                            visibleRect.height - 85 * scale,
                            0,
                            movie._height - 73 * scale
                            );
        }
		
        movie = GetModule("TargetInfo");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            (visibleRect.width - movie._width) * 0.5 + 400 * scale,
                            visibleRect.height - 118 * scale,
                            0,
                            movie._height - 30 * scale
                            );
        }
        
        movie = GetModule("PlayerCastBar");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            (visibleRect.width - movie._width) * 0.5,
                            ((abilityBarTop - visibleRect.y) - (20 * scale)),
                            0,
                            abilityBarTop - 47 * scale
                            );
        }
        
        movie = GetModule("TargetCastBar");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            (visibleRect.width - movie._width) * 0.5 + 359 * scale,
                            visibleRect.height - 122 * scale,
                            0,
                            90 * scale
                            );
        }
        
        movie = GetModule("DodgeBar");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            (visibleRect.width - movie._width) * 0.5,
                            ((abilityBarTop -visibleRect.y)  - (55 * scale)),
                            0,
                            abilityBarTop - 47 * scale);
        }

        movie = GetModule("FIFO");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            (visibleRect.width / 2),
                            50,
                            0,
                            0
                            );
        }

        movie = GetModule("DamageInfo");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;

            SetModulePos    (
                            movie,
                            0,
                            0,
                            0,
                            0
                            );
        }

        movie = GetModule("FriendlyMenu");
        if (movie != null)
        {
            movie._yscale = movie._xscale = scale * 100;
            movie._x = visibleRect.x;
            movie._y = visibleRect.y;
        }

        movie = GetModule("HUDXPBar");
        if (movie != null)
        {
            SetModulePos    (
                            movie,
                            0,
                            (visibleRect.height - 8),
                            0,
                            0
                            );
        }
        
        movie = GetModule("MissionTracker");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            visibleRect.width - (60 * scale),
                            (visibleRect.height * 0.35),
                            0,
                            0
                            );
        }
        
        movie = GetModule("Compass");
        if (movie != null)
        {
            movie._xscale = 90;
            movie._yscale = 90;
            
            SetModulePos    (
                            movie,
                            (visibleRect.width - movie._width) * 0.5,
                            0,
                            0,
                            0
                            );
        }

        movie = GetModule("PvPMiniScoreView");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            (visibleRect.width - movie._width) * 0.5,
                            24,
                            0,
                            0
                            );
        }

        movie = GetModule("LatencyWindow");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            0,
                            60,
                            0,
                            0
                            );
        }
        
        movie = GetModule("AnimaWheelLink");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            visibleRect.width - 48 * scale,
                            visibleRect.height - 68 * scale,
                            0,
                            movie._height + 2 * scale
                            );
        }

        movie = GetModule("SignUpNotifications");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            11 * scale,
                            33 * scale,
                            0,
                            0
                            );
        }
        
        movie = GetModule("AchievementLoreWindow");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            0,
                            0,
                            0,
                            0
                            );
        }
        
        movie = GetModule("WalletController");
        if (movie != null)
        {
            movie._xscale = scale * 100;
            movie._yscale = scale * 100;
            
            SetModulePos    (
                            movie,
                            0,
                            0,
                            0,
                            0
                            );
        }   
	}
}