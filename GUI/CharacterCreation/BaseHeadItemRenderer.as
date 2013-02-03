import gfx.controls.ListItemRenderer;
import gfx.controls.UILoader;

class GUI.CharacterCreation.BaseHeadItemRenderer extends ListItemRenderer
{
	
	public var m_ImageLoader:UILoader;

	private function BaseHeadItemRenderer()
	{
		super();
	}
	
	public function setData(data:Object):Void 
	{
		if (data == undefined)
		{
        	this._visible = false;
        	return;
      	}
      	
		this.data = data;
      	this._visible = true; 
		this.data = data;

        if ( initialized )
        {
            m_ImageLoader.source = data.m_SnapshotImage;
        }
	}
    private function configUI()
    {
        if ( data != undefined )
        {
            m_ImageLoader.source = data.m_SnapshotImage;
        }
    }
}