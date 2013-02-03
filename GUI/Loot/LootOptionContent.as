//Imports
import com.Utils.Signal;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
import gfx.controls.Button;
import gfx.controls.DropdownMenu;
import gfx.controls.TextArea;
import com.GameInterface.NeedGreed;
import gfx.controls.CheckBox;
import com.GameInterface.DistributedValue;
import gfx.core.UIComponent;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import com.Components.WindowComponentContent;

//Class
class GUI.Loot.LootOptionContent extends WindowComponentContent
{
    //Properties
    public var SignalCloseLootOptionWindow:com.Utils.Signal;
    
    private var m_LootTypeHeader:TextField;
    private var m_LootTypeLabel:TextField;
    private var m_LootTypeDropdown:DropdownMenu;
    private var m_NeedGreedCheckbox:CheckBox;
    private var m_ThresholdDropdown:DropdownMenu;
    private var m_LootTypeDescriptionHeader:MovieClip;
    private var m_LootDescriptionText:TextArea;
    private var m_ApplyButton:Button;
    private var m_CanChangeLootOptions:Boolean;
    private var m_Initialized:Boolean;    
    private var m_CanClientUpdateOptions:Boolean;
    
    //Constructor
    function LootOptionContent()
    {
        super();
        
        m_Initialized = false;
        m_CanClientUpdateOptions = true;
        
        SignalCloseLootOptionWindow = new Signal;
    }
    
    //Config UI
    private function configUI():Void
    {
        m_Initialized = true;
        
        m_LootTypeDropdown.disableFocus = true;
        m_ThresholdDropdown.disableFocus = true;
        m_NeedGreedCheckbox.disableFocus = true;
        
        NeedGreed.SignalCanChangeLootOptionsChanged.Connect(SlotCanChangeLootOptionsChanged, this);
        NeedGreed.SignalLootModeChanged.Connect(SlotLootModeChanged, this);
        NeedGreed.SignalLootThresholdChanged.Connect(SlotLootThresholdChanged, this);
        NeedGreed.SignalNeedGreedChanged.Connect(SlotNeedGreedChanged, this);
        
        SetLabels();
        UpdateData();
        
        m_LootTypeDropdown.addEventListener("change", this, "RemoveFocus");
        m_LootTypeDropdown.addEventListener("change", this, "UpdateLootDescription");
        m_ThresholdDropdown.addEventListener("change", this, "RemoveFocus");
        m_ApplyButton.addEventListener("click", this, "ApplyLootOptions");
        m_NeedGreedCheckbox.addEventListener("select", this, "NeedGreedToggleHandler");
        
        SlotCanChangeLootOptionsChanged(NeedGreed.GetCanChangeLootOptions());
        SlotLootModeChanged(NeedGreed.GetLootMode());
        SlotLootThresholdChanged(NeedGreed.GetLootThreshold());
        SlotNeedGreedChanged(NeedGreed.GetNeedGreed());
        
        SignalCloseLootOptionWindow.Connect(SlotCloseLootOptionWindow, this);
    }
    
    //Slot Close Loot Option Window
    private function SlotCloseLootOptionWindow():Void
    {
        DistributedValue.Create( "loot_options_window" ).SetValue(false);
    }
    
    //Slot Loot Mode Changed
    private function SlotLootModeChanged(newLootMode:Number):Void
    {
        m_LootTypeDropdown.selectedIndex = newLootMode >= 0 ? newLootMode : 0;
    }
    
    //Slot Loot Threshold Changed
    private function SlotLootThresholdChanged(newLootThreshold:Number):Void
    {
        for (var i:Number = 0; i < m_ThresholdDropdown.dataProvider.length; i++)
        {
            if (m_ThresholdDropdown.dataProvider[i].data == newLootThreshold)
            {
                m_ThresholdDropdown.selectedIndex = i;
                break;
            }
        }
    }
    
    //Slot Need Greed Changed
    private function SlotNeedGreedChanged(needGreed:Boolean):Void
    {
        m_NeedGreedCheckbox.selected = needGreed;
    }
    
    //Update Loot Description
    private function UpdateLootDescription():Void
    {
        m_LootDescriptionText.text = m_LootTypeDropdown.dataProvider[m_LootTypeDropdown.selectedIndex].data;
        
        DisableOptions();
    }
    
    //Slot Can Change Loot Options Changed
    private function SlotCanChangeLootOptionsChanged(canChangeLootOptions:Boolean):Void
    {
        m_CanChangeLootOptions = canChangeLootOptions;
        m_NeedGreedCheckbox.disabled = !m_CanChangeLootOptions;
        m_LootTypeDropdown.disabled = !m_CanChangeLootOptions;
        m_ThresholdDropdown.disabled = !m_CanChangeLootOptions;
        m_ApplyButton.disabled = !m_CanChangeLootOptions;
        
        m_CanClientUpdateOptions = canChangeLootOptions;
    }
    
    //Remove Focus
    private function RemoveFocus():Void
    {
        Selection.setFocus(null);
    }
    
    //Need Greed Toggle Handler
    private function NeedGreedToggleHandler(n:Object):Void
    {
        if ( !n.target.selected )
        {
            m_ThresholdDropdown.disabled = true;
        }
        else m_ThresholdDropdown.disabled = !m_CanChangeLootOptions;
    }
    
    //Set Labels
    private function SetLabels():Void
    {
        m_LootTypeHeader.text = LDBFormat.LDBGetText("MiscGUI", "LootOptionWindow_LootTypeHeader");
        m_LootTypeLabel.text = LDBFormat.LDBGetText("MiscGUI", "LootOptionWindow_LootTypeLabel");
        m_NeedGreedCheckbox.label = LDBFormat.LDBGetText("MiscGUI", "LootControlWindow_NeedGreedCheckboxLabel");
        m_LootTypeDescriptionHeader.m_Title.text = LDBFormat.LDBGetText("MiscGUI", "LootOptionWindow_LootTypeDescriptionHeader");
        m_ApplyButton.label = LDBFormat.LDBGetText("GenericGUI", "Apply");
    }
    
    //Update Data
    private function UpdateData():Void
    {
        SetLootTypeDropdownData();
        SetThresholdDropdownData();
    }
    
    private function DisableOptions():Void
    {
        var isMasterLooter:Boolean = (m_LootTypeDropdown.selectedIndex == _global.Enums.GroupLootMode.e_LootModeMasterLooter);
        m_NeedGreedCheckbox.disabled = isMasterLooter || !m_CanClientUpdateOptions;
    }
    
    //Set Loot Type Dropdown Data
    private function SetLootTypeDropdownData():Void
    {
        var firstMode:Number = _global.Enums.GroupLootMode.e_FirstLootMode;
        var lastMode:Number = _global.Enums.GroupLootMode.e_LastLootMode;
        var lootOptionArray:Array = new Array();
        
        for (var mode:Number = firstMode; mode <= lastMode; mode++)
        {
            var object:Object = new Object();
            object.label = LDBFormat.LDBGetText("MiscGUI", "GroupLootMode_" + mode);
            object.data = LDBFormat.LDBGetText("MiscGUI", "GroupLootMode_Description_" + mode);
            lootOptionArray.push(object);
        }
        
        m_LootTypeDropdown.dataProvider = lootOptionArray;
        m_LootDescriptionText.text = lootOptionArray[NeedGreed.GetLootMode()].data;
    }
    
    //Set Threshold Dropdown Data
    private function SetThresholdDropdownData():Void
    {
        var firstLevel:Number = _global.Enums.ItemPowerLevel.e_Superior ;
        var lastLevel:Number = _global.Enums.ItemPowerLevel.e_LastPowerLevel;
        var powerLevelArray:Array = new Array();
        
        for (var level:Number = firstLevel; level <= lastLevel; level++)
        {
            var object:Object = new Object();
            object.label = LDBFormat.LDBGetText("MiscGUI", "PowerLevel_" + level);
            object.data = level;
            powerLevelArray.push(object);
        }
        
        m_ThresholdDropdown.dataProvider = powerLevelArray;
        
        var threshold:Number = NeedGreed.GetLootThreshold();
    }
    
    //Close Loot Option Window
    private function CloseLootOptionWindow():Void
    {
        this.SignalCloseLootOptionWindow.Emit();
    }
    
    //Apply Loot Options
    private function ApplyLootOptions():Void
    {
        NeedGreed.SetLootOptions(m_LootTypeDropdown.selectedIndex, m_NeedGreedCheckbox.selected, m_ThresholdDropdown.dataProvider[m_ThresholdDropdown.selectedIndex].data);
        this.SignalCloseLootOptionWindow.Emit();
    }
}
