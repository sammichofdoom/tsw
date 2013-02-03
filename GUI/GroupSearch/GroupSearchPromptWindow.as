//Imports
import com.Components.FCButton;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import gfx.controls.Button;
import gfx.core.UIComponent;
import mx.utils.Delegate;

//Class
class GUI.GroupSearch.GroupSearchPromptWindow extends UIComponent
{
    //Constants
    public static var MODE_SELECT_ROLE:String = "modeSelectRole";
    public static var MODE_CONFIRM_LEAVE:String = "modeConfirmLeave";
    
    private static var CONTENT_PERSISTENCE:String = "contentPersistence";
    
    private static var SELECT_ROLE_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "selectRoleMessage");
    private static var CONFIRM_LEAVE_PROMPT_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "confirmLeaveMessage");
    private static var TANK_BUTTON_LABEL:String = LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonLabel");
    private static var TANK_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "tankButtonTooltip");
    private static var DPS_BUTTON_LABEL:String = LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonLabel");
    private static var DPS_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "DPSButtonTooltip");
    private static var HEALER_BUTTON_LABEL:String = LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonLabel");
    private static var HEALER_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("GroupSearchGUI", "HealerButtonTooltip");
    private static var OK_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Ok");
    private static var CANCEL_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
    
    //Properties
    public var SignalPromptResponse:Signal;
    
    private var m_Background:MovieClip;
    private var m_SelectRoleMessage:TextField;
    private var m_ConfirmLeaveMessage:TextField;
    private var m_ToggleButtonArray:Array;
    private var m_TankButton:FCButton;
    private var m_TankLabel:TextField;
    private var m_DPSButton:FCButton;
    private var m_DPSLabel:TextField;
    private var m_HealerButton:FCButton;
    private var m_HealerLabel:TextField;
    
    private var m_OKButton:Button;
    private var m_CancelButton:Button;
    private var m_KeyListener:TextField;
    private var m_Mode:String;
    
    //Constructor
    public function GroupSearchPromptWindow()
    {
        super();
        
        SignalPromptResponse = new Signal;
        
        var keylistener:Object = new Object();
        keylistener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(keylistener);
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        _visible = false;
        m_KeyListener._visible = false;
        
        m_SelectRoleMessage.text = SELECT_ROLE_PROMPT_MESSAGE;
        
        m_ToggleButtonArray = new Array(m_TankButton, m_DPSButton, m_HealerButton);
        
        for (var i:Number = 0; i < m_ToggleButtonArray.length; i++)
        {
            m_ToggleButtonArray[i].toggle = true;
            m_ToggleButtonArray[i].disableFocus = true;
            m_ToggleButtonArray[i].selected = false;
            m_ToggleButtonArray[i].addEventListener("click", this, "ToggleRoleButtonClickEventHandler");
        }
        
        m_TankButton.SetTooltipText(TANK_BUTTON_TOOLTIP);
        m_DPSButton.SetTooltipText(DPS_BUTTON_TOOLTIP);
        m_HealerButton.SetTooltipText(HEALER_BUTTON_TOOLTIP);
        
        m_TankLabel.text = TANK_BUTTON_LABEL;
        m_DPSLabel.text = DPS_BUTTON_LABEL;
        m_HealerLabel.text = HEALER_BUTTON_LABEL;
        
        m_OKButton.label = OK_LABEL;
        m_OKButton.disableFocus = true;
        m_OKButton.disabled = true;
        m_OKButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_CancelButton.label = CANCEL_LABEL;
        m_CancelButton.disableFocus = true;
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        _x = _parent._width / 2 - _width / 2;
        _y = _parent._height / 2 - _height / 2;        
    }
    
    //Show Prompt
    public function ShowPrompt(mode:String, playField:String, difficulty:String):Void
    {  
        if (_visible && m_Mode == mode)
        {
            return;
        }
        
        m_Mode = mode;
        
        m_SelectRoleMessage._visible =      (m_Mode == MODE_SELECT_ROLE) ? true : false;
        m_TankButton._visible =             (m_Mode == MODE_SELECT_ROLE) ? true : false;
        m_TankLabel._visible =              (m_Mode == MODE_SELECT_ROLE) ? true : false;
        m_DPSButton._visible =              (m_Mode == MODE_SELECT_ROLE) ? true : false;
        m_DPSLabel._visible =               (m_Mode == MODE_SELECT_ROLE) ? true : false;
        m_HealerButton._visible =           (m_Mode == MODE_SELECT_ROLE) ? true : false;
        m_HealerLabel._visible =            (m_Mode == MODE_SELECT_ROLE) ? true : false;
        
        m_ConfirmLeaveMessage._visible =    (m_Mode == MODE_CONFIRM_LEAVE) ? true : false;
        
        if (m_Mode == MODE_SELECT_ROLE)
        {
            if (m_TankButton.selected || m_DPSButton.selected || m_HealerButton.selected)
            {
                m_OKButton.disabled = false;
            }
        }
        
        if (m_Mode == MODE_CONFIRM_LEAVE)
        {
            m_ConfirmLeaveMessage.htmlText = LDBFormat.Printf(CONFIRM_LEAVE_PROMPT_MESSAGE, playField, difficulty);
            m_OKButton.disabled = false;
        }
        
        swapDepths(_parent.getNextHighestDepth());        
        _visible = true;
        Selection.setFocus(m_KeyListener);
    }
    
    //Toggle Role Button Click Event Handler
    private function ToggleRoleButtonClickEventHandler(event:Object):Void
    {
        Selection.setFocus(m_KeyListener);
        
        for (var i:Number = 0; i < m_ToggleButtonArray.length; i++)
        {
            if (m_ToggleButtonArray[i].selected)
            {
                m_OKButton.disabled = false;
                
                return;
            }
        }
        
        m_OKButton.disabled = true;
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        if (m_Mode == MODE_SELECT_ROLE)
        {
            var selectedRolesArray:Array = new Array();
            
            if (m_TankButton.selected) selectedRolesArray.push(_global.Enums.Class.e_Tank);
            if (m_DPSButton.selected) selectedRolesArray.push(_global.Enums.Class.e_Damage);
            if (m_HealerButton.selected) selectedRolesArray.push(_global.Enums.Class.e_Heal);
            
            if (event.target == m_OKButton)
            {
                
                SignalPromptResponse.Emit(m_Mode, selectedRolesArray, true);
            }
            else
            {
                SignalPromptResponse.Emit(m_Mode, selectedRolesArray, false)
            }
        }
        
        if (m_Mode == MODE_CONFIRM_LEAVE)
        {
            if (event.target == m_OKButton)
            {
                SignalPromptResponse.Emit(m_Mode, undefined, true);
            }
            else
            {
                SignalPromptResponse.Emit(m_Mode, undefined, false);
            }
        }
        
        m_OKButton.disabled = true;
        _visible = false;
        Selection.setFocus(null);
    }
    
    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        if (Selection.getFocus() == m_KeyListener)
        {
            switch(Key.getCode())
            {
                case Key.ESCAPE:    ResponseButtonEventHandler({target: m_CancelButton});
                                    break;

                case Key.ENTER:     if (!m_OKButton.disabled)
                                    {
                                        ResponseButtonEventHandler( { target: m_OKButton } );  
                                    }
                                    break;
            }
        }
    }
    
    //Set Role Persistence
    public function SetRolePersistence(selectedRoles:Array):Void
    {
        if (selectedRoles == undefined)
        {
            return;
        }
        
        for (var i:Number = 0; i < selectedRoles.length; i++)
        {
            switch (selectedRoles[i])
            {
                case _global.Enums.Class.e_Tank:    m_TankButton.selected = true;
                                                    break;
                                                    
                case _global.Enums.Class.e_Damage:  m_DPSButton.selected = true;
                                                    break;
                                                    
                case _global.Enums.Class.e_Heal:    m_HealerButton.selected = true;                                
            }
        }
    }
}