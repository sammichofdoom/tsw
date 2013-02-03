class com.Components.MultiColumnList.MCLBaseCellRenderer
{
	private var m_Parent:MovieClip;
	private var m_MovieClip:MovieClip
	private var m_Id:Number;
	
	public function MCLBaseCellRenderer(parent:MovieClip, id:Number)
	{
		m_Parent = parent;
		m_Id = id;
	}
	
	public function GetId() : Number
	{
		return m_Id;
	}
	
	public function SetPos(x:Number, y:Number)
	{
		
	}
	
	public function SetAlpha(alpha:Number )
	{
		if (m_MovieClip != undefined)
		{
			m_MovieClip._alpha = alpha;
		}
	}
	
	public function SetSize(width:Number, height:Number)
	{
		
	}
	
	public function GetDesiredWidth() : Number
	{
		return 0;
	}
	
	public function Remove()
	{
		if (m_MovieClip != undefined)
		{
			m_MovieClip.removeMovieClip();
		}
	}
}