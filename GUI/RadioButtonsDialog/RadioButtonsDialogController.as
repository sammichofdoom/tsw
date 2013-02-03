//Imports
import com.Utils.LDBFormat;
import gfx.controls.Button;
import com.Utils.Signal;
import com.GameInterface.RadioButtonsDialog;
import gfx.core.UIComponent;

//Class
class GUI.RadioButtonsDialog.RadioButtonsDialogController extends UIComponent
{
    private static var ACCEPT:String = LDBFormat.LDBGetText("GenericGUI","Accept");
    private static var CANCEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
    private static var RADIO_GROUP:String = "RadioGroup";

    private var m_RadioButtonInterface:RadioButtonsDialog;
    
    private var m_Title:TextField;
    private var m_OnlyOneMissionText:TextField;
    private var m_CheckBoxContainer:MovieClip;
    private var m_OKButton:MovieClip;
    private var m_CancelButton:MovieClip;
    private var m_RadioButtonsContainer:MovieClip;
    private var m_RadioButtons:Array;
    private var m_SelectedValue:Number;
    
    private var m_RadioButtonX:Number = 20;
    private var m_RadioButtonY:Number = 10;
    
    private var m_Radio

    function RadioButtonsDialogController()
    {
        m_RadioButtons = new Array();
    }
        
    private function configUI()
    {
        super.configUI();
        m_OKButton.label = ACCEPT;
        m_CancelButton.label = CANCEL;
        m_OKButton.addEventListener("click", this, "ResponseButtonEventHandler");
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_RadioButtonsContainer._visible = true;
        m_OnlyOneMissionText._visible = false;
        
        Layout();
        
    }
    
    public function AddOption( value:Number, label:String ):Void
    {
        var clip:MovieClip = m_RadioButtonsContainer;
        var radioButton:MovieClip = clip.attachMovie("RadioButton", "radioButton_"+label, clip.getNextHighestDepth());
        radioButton.group = RADIO_GROUP;
        radioButton.textField.autoSize = "left";
        radioButton.label = label;
        radioButton.data = value;
        radioButton.addEventListener("click", this, "OnRadioToggle");
        radioButton._x = m_RadioButtonX;
        radioButton._y = m_RadioButtonY;
        m_RadioButtonY += 25;
        
        if (m_SelectedValue == undefined)
        {
            radioButton.selected = true;
            m_SelectedValue = radioButton.data;
        }
        
        m_RadioButtons.push(radioButton);
        Layout();
    }
    
    public function Layout() : Void
    {
        if ( m_RadioButtons.length == 1 )
        {
            m_OnlyOneMissionText.text = m_RadioButtons[0].label;
            m_OnlyOneMissionText._visible = true;
            m_RadioButtonsContainer._visible = false;
        }
        else 
        {
            m_OnlyOneMissionText._visible = false;
            m_RadioButtonsContainer._visible = true;
        }
        UpdatePosition();
        
        _parent.layout();
        
    }
    
    private function UpdatePosition() : Void
    {
        m_RadioButtonsContainer.m_RadioButtonsBackground._height = (m_RadioButtons.length +1) * 22;
        m_Title._height = m_Title.textHeight + 10;
        m_OnlyOneMissionText._height = m_OnlyOneMissionText.textHeight + 10;
        m_RadioButtonsContainer._y = m_Title._y + m_Title._height +10;
        m_OnlyOneMissionText._y = m_Title._y + m_Title._height +30;
        
        var buttonsY:Number = Math.max( m_RadioButtonsContainer._y + m_RadioButtonsContainer._height, m_OnlyOneMissionText._y + m_OnlyOneMissionText._height +5);
        
        m_OKButton._y = m_CancelButton._y = buttonsY + 15;
    }
    
    public function GetSelectedData():Number
    {
        return m_SelectedValue;
    }
    
    public function SetTitle( label:String ) : Void
    {
        m_Title.htmlText = label;
    }
    
    public function SetInterface(rbInterface:RadioButtonsDialog):Void
    {
        m_RadioButtonInterface = rbInterface;
    }
    
    private function OnRadioToggle(event:Object):Void 
    {
        m_SelectedValue = event.target.data;
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        m_OKButton.removeEventListener("click", this, "ResponseButtonEventHandler");
        m_CancelButton.removeEventListener("click", this, "ResponseButtonEventHandler");
        
        var buttonIdx:Number = _global.Enums.StandardButtonID.e_ButtonIDCancel;
        
        if (event.target == m_OKButton)
        {
            buttonIdx = _global.Enums.StandardButtonID.e_ButtonIDAccept;
        }

        //Dispatch Selected in a Signal
        if (m_RadioButtonInterface != undefined)
        {
            m_RadioButtonInterface.Respond(buttonIdx, m_SelectedValue);
        }
        
        m_RadioButtonInterface.Close();
    }
    

}
