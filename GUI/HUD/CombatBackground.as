/// All logic for resizing and stretching the CombatBackground


var FriendlyName = "Combat Background";

function ResizeHandler() : Void
{
	trace("CombatBackground:ResizeHandler - _clip: "+_clip)
	var visiblerect:flash.geom.Rectangle = Stage["visibleRect"];
/*	i_Background._x = visiblerect.x
	i_Background._y = visiblerect.x
	*/
	i_Background._width = visiblerect.width
}