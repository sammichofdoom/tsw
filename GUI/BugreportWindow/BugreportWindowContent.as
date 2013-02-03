//Imports
import mx.utils.Delegate;
import com.GameInterface.DistributedValue;
import com.GameInterface.UtilsBase
import gfx.controls.Button;
import gfx.controls.CheckBox;
import gfx.controls.TextArea;
import gfx.controls.TextInput;
import gfx.controls.DropdownMenu;
import gfx.core.UIComponent;
import com.Utils.LDBFormat;
import com.Components.WindowComponentContent;

//Class
class GUI.BugreportWindow.BugreportWindowContent extends WindowComponentContent
{
	//Constants
    private static var TITLE_HOLDER_TEXT:String = LDBFormat.LDBGetText("GenericGUI", "BugReportTitleTextInputHolder");
    private static var COMMENTS_HOLDER_TEXT:String = LDBFormat.LDBGetText("GenericGUI", "BugReportCommentsTextInputHolder");
    private static var CATEGORY_HOLDER_TEXT:String = ("*" + LDBFormat.LDBGetText("GenericGUI", "SelectCategory"));
    private static var EMAIL_HOLDER_TEXT:String = LDBFormat.LDBGetText("GenericGUI", "EmailAddressTextInputHolder");
    private static var MISSION:String = LDBFormat.LDBGetText("GenericGUI", "Mission");
    private static var AUDIO:String = LDBFormat.LDBGetText("GenericGUI", "Audio");
    private static var VISUAL:String = LDBFormat.LDBGetText("GenericGUI", "Visual");
    private static var CHARACTER_CREATION:String = LDBFormat.LDBGetText("GenericGUI", "CharacterCreation");
    private static var WORLD_DESIGN:String = LDBFormat.LDBGetText("GenericGUI", "WorldDesign");
    private static var ITEMS:String = LDBFormat.LDBGetText("GenericGUI", "Items");
    private static var NPC:String = LDBFormat.LDBGetText("GenericGUI", "NPC");
    private static var COMBAT:String = LDBFormat.LDBGetText("GenericGUI", "Combat");
    private static var CONTROLS:String = LDBFormat.LDBGetText("GenericGUI", "Controls");
    private static var CAMERA:String = LDBFormat.LDBGetText("GenericGUI", "Camera");
    private static var TECHNICAL:String = LDBFormat.LDBGetText("GenericGUI", "Technical");
    private static var EXPLOIT:String = LDBFormat.LDBGetText("GenericGUI", "Exploit");
    private static var GUI_STRING:String = LDBFormat.LDBGetText("GenericGUI", "GUI");
    private static var TEXT_DIALOGS:String = LDBFormat.LDBGetText("GenericGUI", "TextDialogs");
    private static var CINEMATICS:String = LDBFormat.LDBGetText("GenericGUI", "Cinematics");
    private static var OTHER:String = LDBFormat.LDBGetText("GenericGUI", "Other");
    private static var HOLDER_TEXT_COLOR:Number = 0x222222;
    private static var INPUT_TEXT_COLOR:Number = 0xFFFFFF;
	
	//Variables
	private var m_TitleLabel:TextField;
	private var m_TitleTextInput:TextInput;
	private var m_CommentsLabel:TextField;
	private var m_CommentsTextArea:TextArea;
	private var m_CategoryDropMenu:DropdownMenu;
	private var m_ScreenshotCheckBox:CheckBox;
	private var m_NPCCheckBox:CheckBox;
	private var m_PlayerCheckBox:CheckBox;
	private var m_EmailLabel:TextField;
	private var m_EmailTextInput:TextInput;
	private var m_MandatoryFieldsLabel:TextField;
	private var m_SubmitButton:Button;
	private var m_CancelButton:Button;
	private var m_InputFieldsArray:Array;
	private var m_DictionaryHolderText:Object;
	private var m_KeyListener:Object;
	
	//Constructor
	public function BugreportWindowContent()
	{
		super();
	}
	
	//Configure UI
	private function configUI():Void
	{
		super.configUI();
		
		m_DictionaryHolderText = new Object();
		m_DictionaryHolderText[m_TitleTextInput] = TITLE_HOLDER_TEXT;
		m_DictionaryHolderText[m_CommentsTextArea] = COMMENTS_HOLDER_TEXT;
		m_DictionaryHolderText[m_EmailTextInput] = EMAIL_HOLDER_TEXT;
		
		m_TitleLabel.text = ("*" + LDBFormat.LDBGetText("GenericGUI", "Title"));
		m_TitleTextInput.textField.textColor = HOLDER_TEXT_COLOR;
		m_TitleTextInput.text = TITLE_HOLDER_TEXT;
		
		m_CommentsLabel.text = ("*" + LDBFormat.LDBGetText("GenericGUI", "Comments"));
		m_CommentsTextArea.textField.textColor = HOLDER_TEXT_COLOR;
		m_CommentsTextArea.text = COMMENTS_HOLDER_TEXT;
		
		var categoryDropDownData:Array = new Array	(
													CATEGORY_HOLDER_TEXT,
													MISSION,
													AUDIO,
													VISUAL,
													CHARACTER_CREATION,
													WORLD_DESIGN,
													ITEMS,
													NPC,
													COMBAT,
													CONTROLS,
													CAMERA,
													TECHNICAL,
													EXPLOIT,
													GUI_STRING,
													TEXT_DIALOGS,
													CINEMATICS,
													OTHER
													);
														
		m_CategoryDropMenu.dataProvider = categoryDropDownData;
		m_CategoryDropMenu.rowCount = categoryDropDownData.length;
		m_CategoryDropMenu.dropdown = "ScrollingListGray";
		m_CategoryDropMenu.itemRenderer = "ListItemRendererGray";

		m_ScreenshotCheckBox.label = LDBFormat.LDBGetText("GenericGUI", "AttachScreenshot");
		m_ScreenshotCheckBox.autoSize = "left";
		
		m_NPCCheckBox.label = LDBFormat.LDBGetText("GenericGUI", "IncludeDumpedNPCStats");
		m_NPCCheckBox.autoSize = "left";
		
		m_PlayerCheckBox.label = LDBFormat.LDBGetText("GenericGUI", "IncludeDumpedPlayerStats");
		m_PlayerCheckBox.autoSize = "left";
		
		m_EmailLabel.text = LDBFormat.LDBGetText("GenericGUI", "EmailAddress");
		
		var savedEmailAddress:String = DistributedValue.GetDValue("Bugreport_Emailaddress");

		if (savedEmailAddress == undefined || savedEmailAddress == "")
		{
			m_EmailTextInput.textField.textColor = HOLDER_TEXT_COLOR;
			m_EmailTextInput.text = EMAIL_HOLDER_TEXT;
		}
		else 
		{
			m_EmailTextInput.textField.textColor = INPUT_TEXT_COLOR;
			m_EmailTextInput.text = savedEmailAddress;
		}
		
		m_MandatoryFieldsLabel.text = LDBFormat.LDBGetText("GenericGUI", "MandatoryFields");
		
		m_SubmitButton.disabled = true;
		m_SubmitButton.label = LDBFormat.LDBGetText("GenericGUI", "SendReport");
		m_CancelButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
		
		m_KeyListener = new Object();
		m_KeyListener.onKeyDown = Delegate.create(this, KeyListenerEventHandler);
		Key.addListener(m_KeyListener);
				
		m_InputFieldsArray = new Array(m_TitleTextInput, m_CommentsTextArea, m_EmailTextInput);
		
		for (var index in m_InputFieldsArray)
		{
			m_InputFieldsArray[index].addEventListener("focusIn", this, "FocusInEventHandler");
			m_InputFieldsArray[index].addEventListener("focusOut", this, "FocusOutEventHandler");
		}
		
		m_CategoryDropMenu.addEventListener("select", this, "SelectEventHandler");
		
		m_SubmitButton.addEventListener("click", this, "SendReportEventHandler")
		m_CancelButton.addEventListener("click", this, "CancelEventHandler")
	}
	
	//Key Listener Event Handler
	private function KeyListenerEventHandler(evt:Object):Void
	{
		if	(Key.getCode() == Key.TAB)
		{
			for (var i:Number = 0; i < m_InputFieldsArray.length; i++)
			{
				if (eval(Selection.getFocus()) == m_InputFieldsArray[i].textField) 
				{
					Selection.setFocus(m_InputFieldsArray[(i == m_InputFieldsArray.length - 1) ? 0 : i + 1]);
					return;
				}
			}
		}
	}
	
	//Focus In Event Handler
	private function FocusInEventHandler(evt:Object):Void
	{
		if (evt.target.text == m_DictionaryHolderText[evt.target]) 
		{
			evt.target.text = "";
			evt.target.textField.textColor = INPUT_TEXT_COLOR;
		}
		
		toggleSendReportButton();
	}
	
	//Focus Out Event Handler
	private function FocusOutEventHandler(evt:Object):Void
	{
		if (evt.target.text == "") 
		{
			evt.target.text = m_DictionaryHolderText[evt.target];
			evt.target.textField.textColor = HOLDER_TEXT_COLOR;
		}
	}
	
	//Select Event Handler
	private function SelectEventHandler(evt:Object):Void
	{
		toggleSendReportButton();
	}
	
	//Toggle Send Report Button
	private function toggleSendReportButton():Void
	{
		if (m_TitleTextInput.text != TITLE_HOLDER_TEXT && m_CommentsTextArea.text != COMMENTS_HOLDER_TEXT && m_CategoryDropMenu.selectedIndex != m_CategoryDropMenu.dataProvider.indexOf(CATEGORY_HOLDER_TEXT)) 
		{
			m_SubmitButton.disabled = false;
			m_SubmitButton.gotoAndStop("over");
		}
		else
		{
			m_SubmitButton.disabled = true;
		}
	}
	
	//Send Report Event Handler
	private function SendReportEventHandler():Void
	{
		com.GameInterface.ProjectUtils.SendBugreport	(
														m_TitleTextInput.text,
														m_CommentsTextArea.text,
														m_CategoryDropMenu.selectedItem.toString(),
														m_ScreenshotCheckBox.selected,
														m_NPCCheckBox.selected,
														m_PlayerCheckBox.selected,
														m_EmailTextInput.text == EMAIL_HOLDER_TEXT ? null : m_EmailTextInput.text
														);
	}

	//Cancel Event Handler
	public function CancelEventHandler():Void
	{
		Key.removeListener(m_KeyListener);
		com.GameInterface.ProjectUtils.CloseBugreport();
	}	
}