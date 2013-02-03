import com.Utils.Signal;
import flash.geom.ColorTransform;
import flash.geom.Transform;
import com.Utils.Colors;

dynamic class GUI.SkillHive.SkillhiveEquipPopup extends MovieClip
{
    //Constants
	private static var m_NumButtons:Number = 7;
	
    //Variables
	public var SignalEquipButtonRollOver;
	public var SignalEquipButtonRollOut;
	public var SignalEquipButtonPressed;
	
	private var m_HoveredButtonIdx;
    private var m_ColorArray:Array;
	
    private var m_Stroke:MovieClip;
    
    //Constructor
	public function SkillhiveEquipPopup()
	{
		SignalEquipButtonRollOver = new Signal();
		SignalEquipButtonRollOut = new Signal();
		SignalEquipButtonPressed = new Signal();
        
		m_HoveredButtonIdx = -1;
	}
    
    //On Press
    private function onPress():Void
    {
    }
    
    //Roll Out
	private function RollOut(buttonId):Void
	{
        if (m_ColorArray[buttonId] != undefined)
        {
            Colors.ApplyColor( this["button_" + buttonId], m_ColorArray[buttonId]);
        }
        else
        {
            Colors.ApplyColor( this["button_" + buttonId], 0x666666);
        }
        
		SignalEquipButtonRollOut.Emit(buttonId);
	}
	
    //Roll Over
	private function RollOver(buttonId):Void
	{
        Colors.ApplyColor( this["button_" + buttonId], 0xEEEEEE);
		
		SignalEquipButtonRollOver.Emit(buttonId);
	}
	
    //On Mouse Move
	private function onMouseMove():Void
	{
		for (var i:Number = 0; i < m_NumButtons; i++)
		{
			var buttonMc:MovieClip = this["button_" + i];
            
			if (buttonMc != undefined)
			{
				if (buttonMc.hitTest(_root._xmouse, _root._ymouse))
				{
					if (m_HoveredButtonIdx == i)
					{
						return;
					}
					else if (m_HoveredButtonIdx != -1)
					{
						RollOut(m_HoveredButtonIdx);
					}
                    
					RollOver(i);
					m_HoveredButtonIdx = i;
					
                    return;
				}
			}
		}
        
		if (m_HoveredButtonIdx != -1)
		{
			RollOut(m_HoveredButtonIdx);
			m_HoveredButtonIdx = -1;
		}
	}
	
    //On Mouse Up
	private function onMouseUp()
	{
        if (m_HoveredButtonIdx != -1)
        {
            SignalEquipButtonPressed.Emit(m_HoveredButtonIdx);
        }
	}
    
    //Set Colors
    public function SetColors(colorArray:Array):Void
    {
        m_ColorArray = colorArray;
        
        for (var i:Number = 0; i < m_ColorArray.length; i++)
        {
            if (m_ColorArray[i] != undefined)
            {
                Colors.ApplyColor( this["button_" + i], m_ColorArray[i]);
            }
        }
    }
    
    //Set Stroke Position
    public function SetStrokePosition(itemPosition:Number):Void
    {
        if (itemPosition < 0 || itemPosition == undefined)
        {
            m_Stroke._visible = false;
        }
        else
        {
            m_Stroke._visible = true;
            m_Stroke._x = this["button_" + itemPosition]._x - 5;
        }
    }
}