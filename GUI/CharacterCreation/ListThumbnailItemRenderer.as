import gfx.controls.ListItemRenderer;
import gfx.controls.UILoader;

class GUI.CharacterCreation.ListThumbnailItemRenderer extends ListItemRenderer
{
	
	public var m_ImageLoader:UILoader;

	private function ListThumbnailItemRenderer()
	{
		super();
	}
	
	public function setData(data:Object):Void 
	{
        super.setData( data );
        if ( initialized )
        {
            UpdateControls();
        }
	}
    private function configUI()
    {
        super.configUI();
        if ( data )
        {
            UpdateControls();
        }
    }

    private function UpdateControls()
    {
        if ( data )
        {
            _visible = true;
            if ( data.m_IconID != 0 )
            {
				
                m_ImageLoader.source = com.Utils.Format.Printf( "rdb:%.0f:%.0f", 1000624, data.m_IconID );
            }
            else
            {
                //m_ImageLoader.source = "CharacterCreation/RemoveOutfit.png";
                m_ImageLoader.source = "CharacterCreation/RemoveOutfit.swf";
				
            }
        }
        else
        {
            _visible = false;
            m_ImageLoader.source = "";
        }            
    }
}