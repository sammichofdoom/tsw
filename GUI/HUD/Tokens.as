import flash.geom.ColorTransform;
import flash.geom.Transform;

//[InspectableList("defaultColor")]
class GUI.HUD.Tokens extends MovieClip
{
	private static var m_NumTokens = 5;
	private var i_Background:MovieClip;
	private var i_Border:MovieClip;
    private var i_Icon:MovieClip;

	public function Tokens()
	{
		super.init();
	}
	
  // Set the current number of counters on this buff.
  // This will set correct alpha and number of items for.
  public function SetCount( count:Number )
  {
    for(var i = 0; i < m_NumTokens; i++ )
	  {
      this["token_" + i]._visible = ( i >= count ) ? false : true;
    }
    
    i_Background._alpha = 40 + (15 * count)  
    i_Border._visible = (count == m_NumTokens) ? true : false;
    i_Icon._alpha = (count == 0) ? 50 : 100;
  }
}