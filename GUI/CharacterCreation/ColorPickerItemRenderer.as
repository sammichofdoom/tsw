import gfx.controls.ListItemRenderer;

class GUI.CharacterCreation.ColorPickerItemRenderer extends ListItemRenderer
{
	
	public var m_ColorPicker:MovieClip;
	
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
		
		var newColor:Color = new Color(m_ColorPicker);
		newColor.setRGB(data._color);
	}
}