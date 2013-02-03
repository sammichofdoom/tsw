var m_MouseCursor:TextField;
var m_ScreenWidth:Number = 0;
var m_ScreenHeight:Number = 0;
var m_r:Number = 0;
var m_g:Number = 0;
var m_b:Number = 0;
var m_xPercentage:Number = 0;
var m_yPercentage:Number = 0;

function onLoad()
{
	createTextField("m_MouseCursor", getNextHighestDepth(), 100, 100, 100, 50);
	m_MouseCursor.border = true;
	m_MouseCursor.borderColor = 0xFFFFFF;
	var my_fmt:TextFormat = new TextFormat();
	my_fmt.color = 0xFFFFFF;
	my_fmt.size = 360;
	my_fmt.font = "_Times";
	m_MouseCursor.setTextFormat(my_fmt);
	m_MouseCursor.text = "0.0";
	
	var visibleRect:Object = Stage["visibleRect"];
	m_ScreenWidth = visibleRect.width;
	m_ScreenHeight = visibleRect.height;	
}

function onEnterFrame()
{
	m_xPercentage = _root._xmouse/m_ScreenWidth;
	m_yPercentage = _root._ymouse/m_ScreenHeight;
	m_r = m_xPercentage * 256;
	m_g = m_yPercentage * 256;
	m_b = ((m_xPercentage + m_yPercentage) / 2) * 256;
	m_MouseCursor.text = _root._xmouse + "." + _root._ymouse;
	m_MouseCursor.textColor = (m_r<<16 | m_g<<8 | m_b);
}

function onRelease()
{
}
