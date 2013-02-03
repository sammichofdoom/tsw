import gfx.controls.ListItemRenderer;

class GUI.CharacterSheet.NextRankRequirementItemRenderer extends ListItemRenderer
{
	private var m_Background:MovieClip;
    private var m_RequirementLabel:TextField;
	private var m_RequirementData:MovieClip;
	
	private var m_IsConfigured:Boolean;
	public var m_RequirementDone:Boolean;
    
	public function NextRankRequirementItemRenderer()
    {
        super();
        m_IsConfigured = false;
    }
	
	private function configUI()
	{
		super.configUI();
        m_IsConfigured = true;
        UpdateLayout();
	}
	
    public function setData( data:Object ) : Void
    {
		
		super.setData(data);
        if ( m_IsConfigured )
        {
            UpdateLayout();
        }
    }
	
	private function UpdateLayout()
    {
		if (data != undefined)
        {
			this._visible = true;
			
			m_RequirementLabel.htmlText = data.label;
			m_RequirementData.htmlText = data.data;
			m_RequirementDone = data.completed;
			m_RequirementData.m_Overline._width = m_RequirementData.textField.textWidth + 4;
			m_RequirementData.m_Overline._visible = false;
			
            if ( m_RequirementDone )
            {
				m_RequirementData.disabled = true;
				m_RequirementData.m_Overline._visible = true;
            }
            else
            {
				m_RequirementData.disabled = false;
				m_RequirementData.m_Overline._visible = false;
            }
        }
        else
        {
            this._visible = false;
		}
	}
}