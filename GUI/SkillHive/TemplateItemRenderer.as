//Imports
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.Lore;
import com.GameInterface.SkillWheel.SkillTemplate;
import gfx.controls.ListItemRenderer;
import GUI.SkillHive.SkillHiveFeatHelper;
import com.Utils.Colors;

//Class
class GUI.SkillHive.TemplateItemRenderer extends ListItemRenderer
{
    //Properties
    private var m_Box:MovieClip;

    //Variables
    private var m_IsConfigured:Boolean;
    
    //Constructor
	public function TemplateItemRenderer()
    {
        super();

        m_IsConfigured = false;
    }
	
    //Config UI
    private function configUI():Void
	{
		super.configUI();
		
        m_IsConfigured = true;

        m_Box._visible = false;
		
        Update();
	}
	
    //Set Data
    public function setData(data:Object):Void
    {
        super.setData(data);

        /*
         *  data:Object
         *  - m_Template:Array
         * 
         */
        
        if (m_IsConfigured)
        {
            Update();
        }
    }
	
    //Update
	private function Update():Void
    {
        if (data.m_Template != undefined)
        {
            m_Box._visible = (SkillHiveFeatHelper.DeckIsComplete(data.m_Template)) ? true : false;
            
            if (m_Box._visible)
            {
                Colors.ApplyColor(m_Box, (!Lore.IsLocked(data.m_Template.m_Achievement)) ? (selected) ? 0x333333 : 0x666666 : 0xFFFFFF);
            }
        }
	}
}