import gfx.core.UIComponent;
import gfx.controls.Button;
import mx.utils.Delegate;

class com.Components.SearchBox extends UIComponent {
	
// Constants:
// Public Properties:	
// Private Properties:	
	private var m_DefaultText:String;
    private var m_IsDefaultText:Boolean;
	private var m_SearchOnInput:Boolean;
// UI Elements:
	private var m_SearchButton:MovieClip;
	private var m_SearchText:TextField;
    private var m_Background:MovieClip;
    


// Initialization:
	public function SearchBox() 
    { 
        super();
        m_DefaultText = "";
        m_IsDefaultText = true;
        var keylistener:Object = new Object();
        keylistener.onKeyDown = Delegate.create(this, SlotKeyDown);
        Key.addListener(keylistener);
        
        var focusListener:Object = new Object();
        focusListener.onSetFocus = Delegate.create(this, SlotTextFieldFocus);
        Selection.addListener(focusListener);
		m_SearchOnInput = false;
		m_SearchText.onChanged = Delegate.create(this, SlotTextChanged);
		m_SearchText.multiline = false;
    }
    
    function SlotTextFieldFocus(oldFocus, newFocus)
    {
        if (newFocus == m_SearchText)
        {
            Selection.setSelection(0, m_SearchText.text.length);
        }
		else if (oldFocus == m_SearchText)
		{
			if (m_SearchText.text.length == 0)
			{
				m_SearchText.text = m_DefaultText;
				m_IsDefaultText = true;
			}
			else
			{
				m_IsDefaultText = false;
			}
		}
    }
	
	function SlotTextChanged(textfield_txt:TextField)
	{
		if (m_SearchOnInput)
		{
			dispatchEventAndSound( { type:"search", searchText:GetSearchText()} );
		}
	}
	
	function SetShowSearchButton(showButton:Boolean)
	{
		m_SearchButton._visible = showButton;
		m_SearchButton.visible = showButton;
	}
	
	function SetSearchOnInput(search:Boolean)
	{
		m_SearchOnInput = search;
	}
    
    function SetWidth(width:Number)
    {
        if (m_Background != undefined)
        {
            m_Background._width = width;
        }
        m_SearchText._width = width - m_SearchText._x;
    }

	
	// Private Methods:
	private function configUI():Void 
    {
		super.configUI();
        m_SearchButton.addEventListener("click", this, "SlotClick");
	}
    
    public function SetDefaultText(text:String)
    {
        m_DefaultText = text;
        m_SearchText.text = m_DefaultText;
        m_IsDefaultText = true;
    }
    
    public function GetSearchText():String
    {
		if (m_IsDefaultText)
		{
			return "";
		}
		else
		{
			return m_SearchText.text;
		}
    }
    
    private function SlotClick()
    {
        dispatchEventAndSound({type:"search", searchText:GetSearchText()});
    }
    
    private function SlotKeyDown()
    {
		if (Selection.getFocus() == m_SearchText)
		{
			if (m_SearchText.text.length > 0)
			{
				m_IsDefaultText = false;
			}
			if (Key.getCode() == Key.ENTER)
			{
				dispatchEventAndSound( { type:"search", searchText:GetSearchText() } );
				Selection.setFocus(null);
			}
			else if (Key.getCode() == Key.ESCAPE)
			{
				Selection.setFocus(null);
			}
		}
    }
    
}