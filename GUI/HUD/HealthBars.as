import com.GameInterface.Game.Team;
import com.GameInterface.Game.Dynels;
import com.GameInterface.Game.DynelSlot;
import com.GameInterface.GUIUtils.StringUtils;
import com.GameInterface.Game.Character;

stop();

var m_Slot:Number;
var m_DynelSlot:DynelSlot; // Reference to the slot.
var m_CurrentHealth:Number;
var m_MaxHealth:Number;
var m_Target:Number;
var m_NameXOrgPos:Number; // Used for placing the star and for moving the text back to org pos.

function Init()
{
  m_Target = 0;
  i_HealthBar.stop();
  m_NameXOrgPos = i_NpcTxt._x;
}

// Set the slot this healthbar represent.
function SetSlot( p_Slot:Number )
{
  m_Slot = p_Slot;
  m_DynelSlot = Dynels.Slots[m_Slot];

  Dynels.SlotChanged.Connect( onSlotChanged, this );
  m_DynelSlot.StatUpdated.Connect( onStatUpdated, this );
  m_DynelSlot.DynelOnClient.Connect( onDynelOnClient, this );

  // If this is a teammember, then we will listen for leader changes.
  if( p_Slot >= Enums.DynelSlot.e_Slot_Team0 )
  {
    Team.SignalNewTeamLeader.Connect( SlotNewTeamLeader, this );
  }

  onSlotChanged( m_Slot, m_DynelSlot.Exists() );

  // Make it update on load.
  if( m_DynelSlot.Exists() )
  {
    var char:Character = Character.GetClientCharacter();
    var health = char.GetStat( Enums.Stat.e_Health, 2 /* full? */ );
    var barrier = char.GetStat( Enums.Stat.e_BarrierHealthPool, 2 /* full? */ );
    UpdateHealth( health, barrier );
    var life = char.GetStat( Enums.Stat.e_Life, 2 /* full? */ );
    SetMaxHealth( life );
  }
}

// If the dynel is gone, but still in team, we grey out the name.
function onDynelOnClient( p_OnClient:Boolean )
{
  // Change color if name exist.
  if( i_NpcTxt )
  {
    i_NpcTxt.textColor = p_OnClient ? 0xFFFFFF : 0x999999;
  }
}

/// when a slot is changed. Match the target to  a target enum and update as neccessary.
/// @param p_Slot:Number  - The slot enum as defined under DynelSlot in ASEnums
/// @param p_Exists:Booelan - True if the slot has a dynel.
function onSlotChanged( p_Slot:Number, p_Exists:Boolean )
{
  if( m_Slot == p_Slot)
  {
    // Note: We now know that the next max and current updates will be because of a change of the slot and so we should not have any effect on the bar.

    // This will make the bar update only when both max and current has been set, and then without any effect.
    m_CurrentHealth = undefined;
    m_MaxHealth = undefined;
  
// TEMP HACK FOR VISIILITY
    _alpha = (p_Exists) ? 100 : 0;

    // Set name if field exist.
    if( i_NpcTxt )
    {
      i_NpcTxt.text = m_DynelSlot.Name;
    }

    // If this is a teammember, update leader status.
    if( p_Slot >= Enums.DynelSlot.e_Slot_Team0 )
    {
      if( Dynels.IsTeamLeader( m_DynelSlot.m_Id ) )
      {
        AddStar();
      }
      else
      {
        RemoveStar();
      }
    }
  }
}


/// listens to a change in stats.
/// @param p_stat:Number  -  The type of stat, defined in the Stat  Enum
/// @param p_value:Number -  The value of the stat
function onStatUpdated( p_stat:Number, p_value:Number )
{
  {
    switch( p_stat )
    {
    case Enums.Stat.e_Health:
      var barrier = char.GetStat( Enums.Stat.e_BarrierHealthPool, 2 /* full? */ );
      UpdateHealth( p_value, barrier );
      break;
    case Enums.Stat.e_Life:
      SetMaxHealth( p_value );
      break;
    }
  }
}

/// Retrieves the maxhealt and creates a factor by dividing it with the number of frames in the active 
/// healthbar, if max health is 0 remove the healthbar, othervise set the max health text
/// @param p_maxhealth:String - the max health as a string
/// @return void
function SetMaxHealth( p_maxhealth:Number) : Void
{
  trace('SetMaxHealth(' + p_maxhealth + ')')
  if( p_maxhealth <= 0)
  {
    p_maxhealth = 0.01; 
  }

  m_MaxHealth = p_maxhealth;

  if( i_healthtxt.max_txt )
  {
    i_healthtxt.max_txt.text = StringUtils.NumberToString( m_MaxHealth );
  }

  UpdatePercent();

  // if the maxhealth signal got dispatched after the health update, update the health.
  
  trace('m_CurrentHealth=' + m_CurrentHealth)
  if( m_CurrentHealth )
  {
    var frame = Math.floor(i_HealthBar._totalframes*m_CurrentHealth/m_MaxHealth)
    i_HealthBar.gotoAndStop( frame )
  }
}

function UpdatePercent()
{
  if( i_healthtxt.i_Percent && m_MaxHealth )
  {
    i_healthtxt.i_Percent.text = Math.round(100*m_CurrentHealth/m_MaxHealth) + "%";
  }
}

/// Updates the health text and bar
/// @param p_health:String - the health as a string
/// @return void
function UpdateHealth(p_health:Number, p_barrier:Number) : Void
{
  if( m_MaxHealth )
  {
    var frame = Math.floor(i_HealthBar._totalframes*p_health/m_MaxHealth);
    m_Target = frame;

    // If we currently had no health, the just jump without any effect. Also if increasing health.
    if( m_CurrentHealth == undefined || i_HealthBar.i_Bar == undefined )
    {
      i_HealthBar.gotoAndStop( frame );
    }
    else if( p_health > m_CurrentHealth )
    {
      // TODO: DO THIS THING BETTER!
      onEnterFrame = function()
      {
        var dist = m_Target-i_HealthBar._currentframe;
        if( dist > 4 )
        {
          var frame = Math.floor( i_HealthBar._currentframe + (dist*0.3) );
        }
        else
        {
          frame = m_Target;
        }
        if( frame != i_HealthBar._currentframe )
        {
          i_HealthBar.gotoAndStop( frame );
        }
      }
    }
    else
    {
      var oldPos = i_HealthBar.i_Bar.getBounds(i_HealthBar);
      i_HealthBar.gotoAndStop( frame );
      if( i_HealthBar.i_Bar )
      {
        var newPos = i_HealthBar.i_Bar.getBounds(i_HealthBar);

        // Show effect if not too small chunk.
        var size = (oldPos.xMax-oldPos.xMin)-(newPos.xMax-newPos.xMin);
        if( size > 5 )
        {
          var clip = i_HealthBar.attachMovie( "s_fade", "fade", this.getNextHighestDepth() )
            
          clip.gotoAndStop( frame )
          clip._x = newPos.xMax
          clip._y = i_HealthBar.i_Bar._y 

          clip._xscale = size;
          clip._yscale = i_HealthBar.i_Bar._height

          clip.onEnterFrame = function()
          {
            if( this._alpha < 0 )
            {
              this.removeMovieClip();
            }
            this._alpha -= 4;
          }
        }
      }
    }
  }

  m_CurrentHealth = p_health;

  if( i_healthtxt.txt )
  {
    i_healthtxt.txt.text = StringUtils.NumberToString(Math.floor(m_CurrentHealth));
  }

  UpdatePercent();
}

function SlotNewTeamLeader( id:com.Utils.ID32 )
{
  if( m_DynelSlot.m_Id.Equal( id ) )
  {
    AddStar();
  }
  else
  {
    RemoveStar();
  }
}

// Add the star in front of the name. Used by teamgui to show leader.
function AddStar()
{
  if( !m_Star )
  {
    attachMovie( "_Star", "m_Star", getNextHighestDepth() );
    m_Star._alpha = 0;
    var starSize = i_NpcTxt._height;
    m_Star._xscale = starSize; // Scale it to fit the text size.
    m_Star._yscale = starSize;
    m_Star._x = m_NameXOrgPos;
    m_Star._y = i_NpcTxt._y;

    // Move the name then fade in the star.
    i_NpcTxt.tweenTo( 0.5, {_x:m_NameXOrgPos+starSize}, Back.easeOut );
    i_NpcTxt.onTweenComplete = function ()
		{
      // When done moving out, fade in star.
      m_Star.tweenTo( 0.5, {_alpha:100}, Back.easeOut );
      m_Star.onTweenComplete = undefined;
    }

  }
}

// Remove the teamleader star.
function RemoveStar()
{
  if( m_Star )
  {
    // Fade out star.
    m_Star.tweenTo( 0.5, {_alpha:0}, Back.easeOut );
    m_Star.onTweenComplete = function ()
		{
      // Remove it when done fading out.
      this.removeMovieClip();
      // Animate name back to it's org. pos.
      i_NpcTxt.tweenTo( 0.5, {_x:m_NameXOrgPos}, Back.easeOut );
      i_NpcTxt.onTweenComplete = undefined;
    }

  }
}

function ResizeHandler() : Void
{
}
