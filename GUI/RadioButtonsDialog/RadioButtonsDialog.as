//Imports
import com.Utils.LDBFormat;
import gfx.controls.Button;
import GUI.RadioButtonsDialog.RadioButtonsDialogController;
import com.GameInterface.RadioButtonsDialog;

var m_FormInitialized:Boolean = false;
var m_LoadArgs:Object;

function onLoad()
{
    //loadFakeData();
    
    var visibleRect = Stage["visibleRect"];
	_x = visibleRect.x;
	_y = visibleRect.y;
    m_Window.allowResize = true;
    m_Window._x = visibleRect.width / 2 - m_Window._width / 2;
    m_Window._y = visibleRect.height / 2 - m_Window._height / 2;
	m_Window.closeButton._visible = false;
    
    m_Window.SignalFormLoaded.Connect(SlotFormLoaded, this);
    
    // Hook up close button
    //m_Window.closeButton.addEventListener("click", this, "CloseWindowHandler");
}

function SlotFormLoaded()
{
    m_FormInitialized = true;
    if (m_LoadArgs != undefined)
    {
        InitializeForm();
    }
}

function InitializeForm()
{
    for (var i:Number = 0; i < m_LoadArgs.length; ++i )
    {
        if ( m_LoadArgs[i].hasOwnProperty("m_Option") && m_LoadArgs[i].hasOwnProperty("m_Label"))
        {        
            m_Window.form.AddOption(m_LoadArgs[i].m_Option, m_LoadArgs[i].m_Label);
        }
        else if ( m_LoadArgs[i].hasOwnProperty("m_Title") )
        {        
            m_Window.form.SetTitle(m_LoadArgs[i].m_Title)
        }
        else if ( m_LoadArgs[i].hasOwnProperty("m_Description") )
        {        
            m_Window.form.SetSubTitle(m_LoadArgs[i].m_Description);
        }
        else if ( m_LoadArgs[i].hasOwnProperty("m_OptionDescription") )
        {        
            m_Window.form.SetSelectionTitle(m_LoadArgs[i].m_OptionDescription);
        }
        else if (m_LoadArgs[i].hasOwnProperty("m_DialogInstance"))
        {
            m_Window.form.SetInterface(m_LoadArgs[i].m_DialogInstance);
        }
    }
}

function LoadArgumentsReceived ( args:Array ) : Void
{
    m_LoadArgs = args;
    if (m_FormInitialized)
    {
        InitializeForm();
    }
}
/*
function loadFakeData():Void
{
    m_Window.form.SetTitle("This is a fake text to test the popup <br> <br>I hope it works correctly  This is a fake text to test the popup This is a fake text to test the popup This is a fake text to test the popup This is a fake text to test the popup < br > This is a fake text to test the popup This is a fake text to test the popup This is a fake text to test the popup This is a fake text to test the popup < br > < br > This is a fake text to test the popup :P");
    
    m_Window.form.AddOption(0, "First Quest Name, This needs to be a bit longer than it is right now.");
    m_Window.form.AddOption(1, "Second Quest Name, This needs to be a bit longer than it is right now. ");
    //m_Window.form.AddOption(2, "Third Quest Name, This needs to be a bit longer than it is right now. Sure!");
   // m_Window.form.AddOption(4, "Third Quest Name, This needs to be a bit longer than it is right now. Sure!");
}
*/
