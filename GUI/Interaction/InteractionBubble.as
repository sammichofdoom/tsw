import flash.geom.Point;
import gfx.core.UIComponent
import com.GameInterface.Game.Dynel;
import com.Utils.LDBFormat;
import com.GameInterface.ProjectUtils;

class GUI.Interaction.InteractionBubble extends UIComponent 
{
	private var m_Dynel:Dynel;
	private var m_InteractionType:Number;
	
	private var m_Background:MovieClip;
	private var m_Text:TextField;
	
	public function InteractionBubble()
	{
		super();
	}
	
	public function configUI()
	{
		super.configUI();
		
		m_InteractionType = ProjectUtils.GetInteractionType(m_Dynel.GetID());
		
		m_Text.autoSize = "left";
		m_Text.selectable = false;
		UpdateText();
	}
	
	private function UpdateText()
	{
		var name:String = m_Dynel.GetName();
		var text:String = "";
		switch(m_InteractionType)
		{
			case _global.Enums.InteractionType.e_InteractionType_Use:
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Use"), name);
				break;
			case _global.Enums.InteractionType.e_InteractionType_Climb:
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Climb"), name);
				break;
			case _global.Enums.InteractionType.e_InteractionType_Examine:
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Examine"), name);
				break;
			case _global.Enums.InteractionType.e_InteractionType_Shop:
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Shop"));
				break;
			case _global.Enums.InteractionType.e_InteractionType_Tradepost:
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Tradepost"));
				break;
			case _global.Enums.InteractionType.e_InteractionType_Talk:
				text += LDBFormat.Printf(LDBFormat.LDBGetText("MiscGUI", "Interaction_Talk"), name);
				break;
			default:
				break;
		}
		text += " (<variable name='hotkey:ActionInteract'/ >)";
		m_Text.text = text;
		
		m_Background._width = m_Text.textWidth + 10;
	}
	
	public function onEnterFrame()
	{
		if (m_Dynel != undefined)
		{
			var position:Point = m_Dynel.GetScreenPosition();
			var distance:Number = m_Dynel.GetCameraDistance();
			if (position.x >= 0 && position.x <= Stage.width && position.y >= 0 && position.y <= Stage.height)
			{
				_x = Math.min(position.x, Stage.width - _width);
				_y = position.y;
				_z = distance;
			}
			else
			{
				if (position.x < 0)
				{
					_x = 0;
				}
				else if (position.x > Stage.width)
				{
					_x = Stage.width - _width
				}
				if (position.y < 50)
				{
					_y = 50;
				}
				else if (position.y > Stage.height - 40)
				{
					_y = Stage.height - _height - 40;
				}
				_z = 0;
			}
		}
	}
	
	public function GetDynel() : Dynel
	{
		return m_Dynel;
	}
}
