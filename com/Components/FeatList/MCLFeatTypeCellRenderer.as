import com.Components.MultiColumnList.MCLBaseCellRenderer;
import com.GameInterface.Tooltip.TooltipUtils;

class com.Components.FeatList.MCLFeatTypeCellRenderer extends MCLBaseCellRenderer
{	
	private var m_WeaponIcon:MovieClip;
	private var m_WeaponName:TextField;
	
	public function MCLFeatTypeCellRenderer(parent:MovieClip, id:Number, weaponName:String, weaponRequirement:Number)
	{
		super(parent, id);
		
		var style:TextFormat = new TextFormat;
		style.font = "_StandardFont";
		style.size = 15;
		style.color = 0xFFFFFF;
		style.leftMargin = 4;
				
		m_MovieClip = m_Parent.createEmptyMovieClip("m_Column_" +id,  m_Parent.getNextHighestDepth());
		m_MovieClip.hitTestDisable = true;
		
		m_WeaponIcon = m_MovieClip.attachMovie("WeaponTypeContent", "m_WeaponIcon", m_MovieClip.getNextHighestDepth());
		m_WeaponName = m_MovieClip.createTextField("m_WeaponName", m_MovieClip.getNextHighestDepth(), 0, 0, 0, 0);
		
		m_WeaponName.setNewTextFormat(style);
		m_WeaponName.selectable = false;
		m_WeaponName.text = weaponName;
		
		TooltipUtils.CreateWeaponRequirementsIcon(m_WeaponIcon, weaponRequirement, { _xscale:23, _yscale:23, _x:1, _y:1 } )
	}
	
	public function SetPos(x:Number, y:Number)
	{
		m_MovieClip._x = x;
		m_MovieClip._y = y;
	}
	
	public function SetSize(width:Number, height:Number)
	{
		var percentage:Number = (height - 25) / m_WeaponIcon._height;
		
		m_WeaponIcon._width *= percentage;
		m_WeaponIcon._height *= percentage;
		
		m_WeaponIcon._x = width - m_WeaponIcon._width - 4;
		m_WeaponIcon._y = ((height - m_WeaponIcon._height) / 2);
		
		m_WeaponName._x = 5
		m_WeaponName._y = (height - m_WeaponName.textHeight) / 2;
		m_WeaponName._height = m_WeaponName.textHeight + 3;
		m_WeaponName._width = m_WeaponIcon._x - m_WeaponName._x;
	}
	
	public function GetDesiredWidth() : Number
	{
		return m_MovieClip._width; 
	}
}