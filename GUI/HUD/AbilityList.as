/// Code for all the logic in the AbilityList
import flash.geom.Rectangle;
import mx.accessibility.ComboBaseAccImpl;
import mx.utils.Delegate;
import com.GameInterface.Spell;
import com.Utils.Colors;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.*;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import flash.geom.Point;
import gfx.managers.DragManager;
import com.Utils.DragObject;
import com.GameInterface.Utils;


var FriendlyName:String = "Ability List";
var m_Spells:Array;
var m_NumSpells:Number;
var m_AbilityHeight:Number = 58;
var m_AbilityWidth:Number = -244;
var m_AbilityListOpenDValue:DistributedValue;
var m_PassiveListOpenDValue:DistributedValue;
var s_ResolutionScaleMonitor:DistributedValue;

function onLoad()
{
    m_AbilityListOpenDValue = DistributedValue.Create( "AbilityListOpenStatus" );
    m_PassiveListOpenDValue = DistributedValue.Create( "PassivesListOpenStatus" );
    s_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    /// connect the signals
    Spell.SignalSpellUpdate.Connect( OnSignalSpellUpdate, this );
    m_AbilityListOpenDValue.SignalChanged.Connect( SlotAbilityListOpenValueChanged, this );
    m_PassiveListOpenDValue.SignalChanged.Connect( SlotPassiveListOpenValueChanged, this);
    s_ResolutionScaleMonitor.SignalChanged.Connect( SlotReslolutionValueChanged, this );

    gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "OnDragEnd" );
        
    i_List.i_AbilityButton.onRelease = Delegate.create(this, openAbilityList);
    i_List.i_PassivesButton.onRelease = Delegate.create(this, openPassiveList);

    if ( m_AbilityListOpenDValue.GetValue() )
    {
        i_List._visible = true;
        i_List.gotoAndStop("opened");
        PopulateMenu();
    }

    if( m_PassiveListOpenDValue.GetValue() )
    {
        i_List._visible = false;
    }
    
    Stage.addListener(this);

}

/// listener for stage resize
function onResize(visibleRect:Rectangle)
{
    if( m_AbilityListOpenDValue.GetValue() )
    {
        i_List._visible = true;
        PopulateMenu();
    }
}

/// Button click handler for opening and closing the AbilityList
///
function openAbilityList() : Void
{
    m_AbilityListOpenDValue.SetValue( !m_AbilityListOpenDValue.GetValue() );
    //trace("setting value to m_AbilityListOpenDValue.GetValue() " + m_AbilityListOpenDValue.GetValue() );
}

function openPassiveList(e:Object)
{
	m_PassiveListOpenDValue.SetValue( !m_PassiveListOpenDValue.GetValue() );
	m_AbilityListOpenDValue.SetValue( !m_AbilityListOpenDValue.GetValue() );
}

function SlotAbilityListOpenValueChanged( value:DistributedValue )
{
    var isOpen:Boolean  = Boolean( value.GetValue() );
    var wasOpen:Boolean = i_List._currentframe > 1;
		
    if ( isOpen != wasOpen )
    {
        if( isOpen ) 
        {
            i_List._visible = true;
            PopulateMenu();
			i_List.gotoAndPlay("open");
        }
        else 
        {
            i_List.gotoAndPlay("close");
        }	
    }
}

/// when the passive list is opened or closed, hide and show the Abilities tab
function SlotPassiveListOpenValueChanged( value:DistributedValue  ) : Void
{
	var isOpen:Boolean  = value.GetValue();
	i_List._visible = !isOpen;
}

/// On changes to the resolution, update this.
function SlotReslolutionValueChanged(value:DistributedValue) : Void
{
    if (m_AbilityListOpenDValue.GetValue())
    {
        CreateScrollbar();
    }
}
//// is it needed?
function OnSignalSpellUpdate()
{
    if ( m_ListOpenDValue.GetValue() )
    {
        PopulateMenu();
    }
}

/// Populate s the menu 
function PopulateMenu()
{
	CloseMenu();
	m_Spells = [];
	m_NumSpells = 0;
  
	var spellobj:Object = Spell.m_SpellList;
  
  /// for each spell, create a visual item and add it to an Array
	for(var prop in spellobj)
	{
		m_Spells.push( CreateSingleSpell(m_NumSpells,  spellobj[ prop]  ) );
		m_NumSpells++
	}

    CreateScrollbar()
    
    if (i_List.i_ListBackground._x > 0)
    {
        i_List.i_ListBackground._x = -224.3;
    }

    //trace("AbilityList: visibility is " + i_List._visible+"  i_List.i_ListBackground "+ i_List.i_ListBackground._x);
    
}



/// method that creates the scrollbar 
/// this fires upon changes to the resolution and the screen size
function CreateScrollbar()
{
    var visibleRect:Object = Stage["visibleRect"];
    var abilityListHeight:Number = m_NumSpells * m_AbilityHeight;
    
    /// Scrollbar if needed
    if ( visibleRect.height < abilityListHeight )
    {
        RemoveScrollBar();

        var scale:Number = DistributedValue.GetDValue("GUIResolutionScale");
        
        var scrollbar:MovieClip = this.attachMovie("ScrollBar", "i_ScrollBar", this.getNextHighestDepth() );
        scrollbar._y = 0;
        scrollbar._x = 5; 

        scrollbar.setScrollProperties(m_AbilityHeight, 0, (m_NumSpells - Math.ceil(visibleRect.height / m_AbilityHeight))); 
        scrollbar._height = visibleRect.height / scale;
        scrollbar.addEventListener("scroll", this, "OnScrollbarUpdate");
        scrollbar.position = 0;
        scrollbar.trackMode = "scrollPage"
        scrollbar.trackScrollPageSize = 4;
    }
}

/// when interacting with the scrollbar
function OnScrollbarUpdate(event:Object)
{
    /// update the position of the abilities
    var pos:Number = event.target.position
    i_List.i_ListBackground._y = -(pos*m_AbilityHeight)
}

/// Creates a new icon from the spell object by attaching the icon button and then load the correct icon graphics onto it
/// @param i:Number index in the m_SpellArray where the spellobject is retrieved
/// @return mainClip:MovieClip - the newly created clip
function CreateSingleSpell(i:Number, spellObj:com.GameInterface.SpellData) : MovieClip 
{
	var iconColor:Number = Colors.GetColor( spellObj.m_ColorLine );

    // attach
    var mainClip:MovieClip = i_List.i_ListBackground.attachMovie("ListItem" , spellObj.m_Id,  i_List.i_ListBackground.getNextHighestDepth() );
	mainClip.i_Label.textField.text= spellObj.m_Name;
    var iconClip:MovieClip = mainClip["i_SimpleAbility"];
    iconClip.spell = spellObj;

    // color
    var iconTransform:Transform = new Transform( iconClip["i_AbilityBase"]["i_Background"] );
    var iconColorTransform:ColorTransform = new ColorTransform();
    iconColorTransform.rgb = iconColor;
    iconTransform.colorTransform = iconColorTransform;

    /// stop mouseover cycle
    iconClip["i_AbilityBase"]["i_AbilityMouseOverGlow"].gotoAndStop(1);
    
    iconClip["m_HitPos"] = new Point();
    iconClip["m_WasHit"] = false;
    iconClip["m_Tooltip"] = undefined;
    iconClip.trackAsMenu = true;

    iconClip.onPress = function()
    {
        if ( this.m_Tooltip != undefined && Key.isDown( Key.SHIFT ) )
        {
            this.m_Tooltip.MakeFloating();
        }
        else
        {
            this.m_WasHit = true;
            this.m_HitPos.x = _root._xmouse;
            this.m_HitPos.y = _root._ymouse
        }
    }

    iconClip.onMouseUp = function()
    {
        this.m_WasHit = false;
    }
    
    iconClip.onMouseMove = function()
    {
        if ( Mouse["IsMouseOver"](this) )
        {
            if ( this.m_Tooltip == undefined )
            {
              //  trace( "Open tooltip: " + _root.getNextHighestDepth() + ", " + _level0.tooltip.getNextHighestDepth() );
                var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( spellObj.m_Id );
                this.m_Tooltip = TooltipManager.GetInstance().ShowTooltip( this, TooltipInterface.e_OrientationHorizontal, -1, tooltipData );
            }
            this["i_AbilityBase"]["i_AbilityMouseOverGlow"].gotoAndPlay(1);
        }
        else if ( this.m_Tooltip != undefined )
        {
           // trace( "Close tooltip" );
            if ( !this.m_Tooltip.IsFloating() )
            {
                this.m_Tooltip.Close();
            }
            this.m_Tooltip = undefined;
        }
        else
        {
            this["i_AbilityBase"]["i_AbilityMouseOverGlow"].gotoAndStop(1);
        }
        
        var mousePos:Point = new Point( _root._xmouse, _root._ymouse );
        if ( this.m_WasHit && Point.distance( this.m_HitPos, mousePos ) > 3 )
        {
            var dragClip:MovieClip = SetupDragClip( this );
            dragClip.hitTestDisable = true;

            var dragData:DragObject = new DragObject();
            dragData.type = "spell";
            dragData.id = spellObj.m_Id;

            gfx.managers.DragManager.instance.startDrag( this, dragClip, dragData, dragData, this, true );
            gfx.managers.DragManager.instance.removeTarget = true;
                        
            this._alpha = 30; // Dim the dragged item down. Will be put back by OnDragEnd().
            this.m_WasHit = false;
        }
    }
    
    var moviecliploader:MovieClipLoader = new MovieClipLoader();
    moviecliploader.addListener( this );
    moviecliploader.loadClip( Utils.CreateResourceString(spellObj.m_Icon), iconClip["i_AbilityBase"]["i_Content"] );

    // Set position and scale. TODO: Change the registration point in the fla background so we don't have to do the below calculations.
    var w = iconClip["i_AbilityBase"]["i_Background"]._width - 4; // 2 pix borders
    var h = iconClip["i_AbilityBase"]["i_Background"]._height - 4; // 2 pix borders
    iconClip["i_AbilityBase"]["i_Content"]._x = -w/2;
    iconClip["i_AbilityBase"]["i_Content"]._y = -h/2;
    iconClip["i_AbilityBase"]["i_Content"]._xscale = w;
    iconClip["i_AbilityBase"]["i_Content"]._yscale = h;

    /// position
    mainClip._y =  ( m_AbilityHeight * i) - 2;

    return mainClip;
}

function RemoveScrollBar()
{
  if (i_ScrollBar)
  {
    i_ScrollBar.removeMovieClip();
  }
}

/// Fires when the abilitymenu is closed
function CloseMenu( ) : Void
{
    RemoveScrollBar();
  
	for( var i = 0; i < m_NumSpells; i++)
	{
        if (m_Spells[ i ])
        {
            MovieClip( m_Spells[ i ]).removeMovieClip();
        }
	}
}

/// Creates the icon that will be dragged when equipping an ability
/// @param clip:MovieClip - the clip to duplicate and
/// @return MovieClip - a new movieclip identical to the icon selected for dragging
function SetupDragClip( clip:MovieClip ) : MovieClip
{
	var clipObj:com.GameInterface.SpellData = clip.spell;

	// create and color the icon background
    var dragClip:MovieClip = clip.duplicateMovieClip( "drag-icon-" + clipObj.m_Id, _parent.getNextHighestDepth() );
    dragClip.swapDepths( _root.getNextHighestDepth() );
    dragClip.topmostLevel = true;

	/// Find color
	var iconColor:Number = Colors.GetColor( clipObj.m_ColorLine )

	/// set the colors
	var iconTransform:Transform = new Transform( dragClip["i_AbilityBase"]["i_Background"] );
	var iconColorTransform:ColorTransform = new ColorTransform()
	iconColorTransform.rgb = iconColor;
	iconTransform.colorTransform = iconColorTransform;
	
	/// load the icon on to the newly created icon background
	var moviecliploader:MovieClipLoader = new MovieClipLoader();
	moviecliploader.addListener( this );
	moviecliploader.loadClip( Utils.CreateResourceString(clipObj.m_Icon), dragClip["i_AbilityBase"]["i_Content"]);

	// Set position and scale. TODO: Change the registration point in the fla background so we don't have to do the below calculations.
	var w = dragClip["i_AbilityBase"]["i_Background"]._width - 4; // 2 pix borders
	var h = dragClip["i_AbilityBase"]["i_Background"]._height - 4; // 2 pix borders
	dragClip["i_AbilityBase"]["i_Content"]._x = -w/2;
	dragClip["i_AbilityBase"]["i_Content"]._y = -h/2;
	dragClip["i_AbilityBase"]["i_Content"]._xscale = w;
	dragClip["i_AbilityBase"]["i_Content"]._yscale = h;

	return dragClip;
}

// when dragging is finished and the icon is dropped, evaluate the drop
function OnDragEnd( event:Object )
{
	if ( event.data.type == "spell" )
	{
		for ( var i in m_Spells )
		{
			if ( m_Spells[i]["i_SimpleAbility"].spell.m_Id == event.data.id )
			{
				m_Spells[i]["i_SimpleAbility"]._alpha = 100;
			}
		}
	}
}

function onUnload()
{
    /// disconnect all signals
    m_SignalGroup.DisconnectAll();    
}

