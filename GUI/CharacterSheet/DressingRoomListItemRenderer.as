import gfx.controls.ListItemRenderer;

class GUI.CharacterSheet.DressingRoomListItemRenderer extends ListItemRenderer
{
    private var m_ItemLabel:TextField;
	private var m_IsEquippedMark:MovieClip;
	
	  private var m_IsConfigured:Boolean;
    
	public function DressingRoomListItemRenderer()
    {
        super();

        m_IsConfigured = false;
    }
	
	 private function configUI()
	{
		super.configUI();
		
        m_IsConfigured = true;
		m_IsEquippedMark._visible = false;
		
        UpdateVisuals();
	}
	
    public function setData( data:Object ) : Void
    {
		  super.setData(data);

        if ( m_IsConfigured )
        {
            UpdateVisuals();
        }
    }
	
	private function UpdateVisuals()
    {
		if (data != undefined)
        {
            if ( data.m_IsEquipped )
            {
				m_IsEquippedMark._visible = true;
            }
            else
            {
				m_IsEquippedMark._visible = false;
            }
            this._visible = true;
			
			m_ItemLabel.text = data.m_ItemName;
        }
        else
        {
            this._visible = false;
		}
	}
}