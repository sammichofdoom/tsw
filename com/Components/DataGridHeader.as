import gfx.controls.Button;

class com.Components.DataGridHeader extends Button {
	
	private var _descending:Boolean = false;
	public var sortArrow:MovieClip;

	private function DataGridHeader()
	{
		super(); 
	}

	public function get descending():Boolean 
	{
		return _descending;
	}
	
	public function set descending(value:Boolean):Void
	{
		_descending = value;
		sortArrow._rotation = _descending ? 180 : 0;
	}
	
	public function get selected():Boolean
	{
		return _selected;
	}
	
	public function set selected(value:Boolean):Void
	{
		super.selected = value;
		sortArrow._visible = _selected;
		if (!_selected)
		{ 
			descending = false;
		}
	}
	
	private function configUI():Void
	{
		super.configUI();
		sortArrow._visible = false;
	}
	
	private function handleClick(mouseIndex:Number):Void
	{
		if (_selected)
		{
			descending = !_descending;
		} else
		{
			descending = false;
		}	
		
		var flags:Number = 0 | (_descending?Array.DESCENDING:0);
		dispatchEvent({type:"sort", field:data, flags:flags});
		super.handleClick(mouseIndex);
	}

}