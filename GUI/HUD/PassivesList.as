import com.GameInterface.DistributedValue;
import com.GameInterface.Spell;
import com.GameInterface.SpellData;
import com.GameInterface.Tooltip.*;
import mx.utils.Delegate;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import flash.geom.Point;
import com.Utils.Colors;
import com.Utils.DragObject;
import com.GameInterface.Utils;

var m_AbilityListOpenDValue:DistributedValue;
//var m_PassiveListOpenDValue:DistributedValue;

var m_Spells:Array;
var m_NumSpells:Number;
var m_ItemHeight:Number = 58;
var m_ItemWidth:Number = -244;
_root.tabChildren = false;

//
// INIT
//
function onLoad()
{
	m_AbilityListOpenDValue = DistributedValue.Create( "AbilityListOpenStatus" );
    
	Spell.SignalPassiveUpdate.Connect( null,OnSignalPassiveUpdate, this );
	m_PassiveListOpenDValue.SignalChanged.Connect( null, SlotPassivesListOpenValueChanged, this );
	m_AbilityListOpenDValue.SignalChanged.Connect( null, onAbilityListOpenValueChanged, this ); 
	    
	gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "OnDragEnd" );
    
    i_List.i_AbilityButton.onRelease = Delegate.create(this, openAbilityTab);
    i_List.i_PassivesButton.onRelease = Delegate.create(this, openPassivesTab);
    

	if ( m_PassiveListOpenDValue.GetValue() )
	{
        i_List._visible = true;
        i_List.gotoAndStop("opened");
        PopulateMenu();
	}

	
    if(m_AbilityListOpenDValue.GetValue() )
	{
		i_List._visible = false;
	}

}

/// call whatever when clicking teh passives tab
function openPassivesTab()
{
	m_PassiveListOpenDValue.SetValue( !m_PassiveListOpenDValue.GetValue() );
}

/// opens teh abilitybar, just swapping the existing values and let the signals move everything
function openAbilityTab()
{
//	m_PassiveListOpenDValue.SetValue( !m_PassiveListOpenDValue.GetValue() );
	m_AbilityListOpenDValue.SetValue( !m_AbilityListOpenDValue.GetValue() );
}


/// Fires when the abilitymenu is closed
function CloseMenu( ) : Void
{
	/// loop and remove the spells we have pending
	for( var i = 0; i < m_NumSpells; i++)
    {
        if (MovieClip( m_Spells[ i ]))
        {
            MovieClip( m_Spells[ i ]).removeMovieClip();
        }
    }
    m_CurrentAbility = 0;
}


///  Updates the distributet value that is used to create 
function SlotPassivesListOpenValueChanged( value:DistributedValue )
{
	var isOpen:Boolean  = value.GetValue();
	var wasOpen:Boolean = i_List._currentframe > 1;
 
	if (m_PassiveListOpenDValue.GetValue())
	{
		Spell.EnterPassiveMode();
	}
	else
	{
		Spell.ExitPassiveMode();        
	}

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


/// triggers when the abilitylist gets opened or closed (can only have one open at the time)
function onAbilityListOpenValueChanged( value:DistributedValue  ) : Void
{
	var isOpen:Boolean  = value.GetValue();
	i_List._visible = !isOpen;
}

function OnSignalPassiveUpdate()
{
	if ( m_ListOpenDValue.GetValue() )
	{
		PopulateMenu();
	}
}

/// Populate s the menu 
function PopulateMenu() : Void
{
	CloseMenu();
	m_Spells = [];
	var i:Number = 0;
	var spellobj:Object = Spell.m_PassivesList;
	for(var prop in spellobj)
	{
		m_Spells.push( CreateSingleSpell(i,  spellobj[ prop]  ) );
		i++
	}
	m_NumSpells = i;
}


/// Creates a new icon from the spell object by attaching the icon button and then load the correct icon graphics onto it
/// @param i:Number index in the m_SpellArray where the spellobject is retrieved
/// @return mainClip:MovieClip - the newly created clip
function CreateSingleSpell(i:Number, spellObj:SpellData) : MovieClip 
{		
  	var iconColor:Number = Colors.GetColor( spellObj.m_ColorLine );
		
    // attach
    var mainClip:MovieClip = i_List["i_ListBackground"].attachMovie("ListItem" , spellObj.m_Id,  i_List["i_ListBackground"].getNextHighestDepth() );
    mainClip["i_Label"].textField.text = spellObj.m_Name;
		
    var iconClip:MovieClip = mainClip["i_Icon"];
    iconClip.spell = spellObj;

    // color
    var iconTransform:Transform = new Transform( iconClip.i_IconBackground);
    var iconColorTransform:ColorTransform = new ColorTransform();
    iconColorTransform.rgb = iconColor;
    iconTransform.colorTransform = iconColorTransform;
		
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
			this.m_HitPos.y = _root._ymouse;
        }
    }
		
    iconClip.onMouseUp = function()
    {
			this.m_WasHit = false;
    }
    
    iconClip.onMouseMove = function()
    {
        if (  Mouse["IsMouseOver"](this) )
        {
            if ( this.m_Tooltip == undefined )
            {
                var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( spellObj.m_Id );
                this.m_Tooltip = TooltipManager.GetInstance().ShowTooltip( this, TooltipInterface.e_OrientationHorizontal, -1, tooltipData );
            }
        }
        else if ( this.m_Tooltip != undefined )
        {
            if ( !this.m_Tooltip.IsFloating() )
            {
                this.m_Tooltip.Close();
            }
            this.m_Tooltip = undefined;
        }
			
        var mousePos:Point = new Point( _root._xmouse, _root._ymouse );
        if ( this.m_WasHit && Point.distance( this.m_HitPos, mousePos ) > 3 )
        {
            var dragClip:MovieClip = SetupDragClip( this );
            dragClip.hitTestDisable = true;

            var dragData:DragObject = new DragObject();
            dragData.type = "passive";
            dragData.id = spellObj.m_Id;

            gfx.managers.DragManager.instance.startDrag( this, dragClip, dragData, dragData, this, true );
            gfx.managers.DragManager.instance.removeTarget = true;

            this._alpha = 30; // Dim the dragged item down. Will be put back by OnDragEnd().
            this.m_WasHit = false;
        }
    }

    var moviecliploader:MovieClipLoader = new MovieClipLoader();
    moviecliploader.addListener( this );
    moviecliploader.loadClip( Utils.CreateResourceString(spellObj.m_Icon), iconClip.i_Container );

    // Set position and scale. TODO: Change the registration point in the fla background so we don't have to do the below calculations.
    var w = iconClip.i_IconBackground._width - 4; // 2 pix borders
    var h = iconClip.i_IconBackground._height - 4; // 2 pix borders
    iconClip.i_Container._x = -w/2;
    iconClip.i_Container._y = -h/2;
    iconClip.i_Container._xscale = w;
    iconClip.i_Container._yscale = h;
		
    /// position
    mainClip._y =  ( m_ItemHeight * i) - 2;

    return mainClip;
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

	/// Find color
	var iconColor:Number = com.Utils.Colors.GetColor( clipObj.m_ColorLine )
	
	/// set the colors
	var iconTransform:Transform = new Transform( dragClip.i_IconBackground );
	var iconColorTransform:ColorTransform = new ColorTransform()
	iconColorTransform.rgb = iconColor;
	iconTransform.colorTransform = iconColorTransform;
	
	/// load the icon on to the newly created icon background
    var moviecliploader:MovieClipLoader = new MovieClipLoader();
    moviecliploader.addListener( this );
    moviecliploader.loadClip( Utils.CreateResourceString(clipObj.m_Icon), dragClip.i_Container );

    // Set position and scale. TODO: Change the registration point in the fla background so we don't have to do the below calculations.
    var w = dragClip.i_IconBackground._width - 4; // 2 pix borders
    var h = dragClip.i_IconBackground._height - 4; // 2 pix borders
    dragClip.i_Container._x = -w/2;
    dragClip.i_Container._y = -h/2;
    dragClip.i_Container._xscale = w;
    dragClip.i_Container._yscale = h;

	return dragClip;
}
	
function OnDragEnd( event:Object )
{
    if ( event.data.type == "passive" )
    {
        for ( var i in m_Spells )
        {
            if ( m_Spells[i].i_Icon.spell.m_Id == event.data.id )
            {
							m_Spells[i].i_Icon._alpha = 100;
            }
        }
    }
}
