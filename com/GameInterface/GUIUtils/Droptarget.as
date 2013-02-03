/// @file com.GameInterface.GuiUtils.Droptargets.as
/// @class Droptargets
/// @author Bård Ingebricson

/// when changing, recompile AbilityBar and AbilityList

/// Controls the Ability Hive and passes keypresses on to listening classes
class com.GameInterface.GUIUtils.Droptarget
{
	public static function IsTargetSlot( droptarget:String, p_prefix:Number ) : Boolean
	{
		var splits:Array = String( droptarget ).split( "/" );
		var slotspot:Number = p_prefix + 1;
		
	//	trace("DropTarget:IsTargetSlot splits[ p_prefix ]: "+splits[ slotspot ] +" splits.length: "+splits.length)
		
		if(splits.length > slotspot )
		{
			var slots:Array = String(splits[ slotspot ]).split(  "_" );
			return ( String( slots[ 0 ] ) == "slot" ) ? true : false;
		}
		return false;
	}
	
	public static function GetSlotId( droptarget:String, p_prefix:Number ) : Number
	{
		var slotspot:Number = p_prefix + 1;

		var splits:Array = String( droptarget ).split( "/" );
	//	trace("DropTargetGetSlotId splits[ p_prefix ]: "+splits[ slotspot ] +" length = "+splits.length+" droptarget = "+droptarget);
		var slots:Array = String(splits[ slotspot ]).split( "_" );
		return Number( slots[1] );

	}

}