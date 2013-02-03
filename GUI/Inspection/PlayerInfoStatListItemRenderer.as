import gfx.controls.ListItemRenderer;
import com.GameInterface.Utils;
import com.Utils.ID32;
import com.Utils.LDBFormat;

class GUI.Inspection.PlayerInfoStatListItemRenderer extends ListItemRenderer
{
    private var m_Label:TextField;
    private var m_Data:TextField;
	private var m_IsConfigured:Boolean;
    
	public function PlayerInfoStatListItemRenderer()
    {
        super();

        m_IsConfigured = false;
    }
	private function configUI()
	{
		super.configUI();
        m_IsConfigured = true;
        UpdateVisuals();
	}
		
	public function setData(playerData:Object)
	{
        super.setData( playerData );

        if ( m_IsConfigured )
        {
            UpdateVisuals();
        }
    }

    private function UpdateVisuals()
    {
        if (data == undefined)
		{
			_visible = false;
			return;
		}
        else
		{
			_visible = true;
			
			m_Label.text = data.m_LabelText;
			m_Data.text = data.m_DataText;
		}
    }
}