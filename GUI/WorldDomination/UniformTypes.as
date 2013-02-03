//Imports
import com.Utils.GlobalSignal;
import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.Utils.Format;
import com.Utils.Signal;
import mx.utils.Delegate;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Spell;
import com.GameInterface.Tooltip.TooltipInterface;

//Class
class GUI.WorldDomination.UniformTypes extends MovieClip
{
    //Constants
    public static var PVP_MODE:String = "PvPMode";
    public static var FVF_MODE:String = "FvFMode";
    
    public static var HIGH_POWERED_WEAPONRY:String = LDBFormat.LDBGetText("WorldDominationGUI", "highPoweredWeaponry");
    public static var REINFORCED_ARMOR:String = LDBFormat.LDBGetText("WorldDominationGUI", "reinforcedArmor");
    public static var INTEGRATED_ANIMA_CONDUITS:String = LDBFormat.LDBGetText("WorldDominationGUI", "integratedAnimaConduits");
    
    private static var PVP_UNIFORM_TYPES_TITLE:String = LDBFormat.LDBGetText("WorldDominationGUI", "PvPUniformTypesTitle");
    private static var FVF_UNIFORM_TYPES_TITLE:String = LDBFormat.LDBGetText("WorldDominationGUI", "FvFUniformTypesTitle");
    
    private static var FVF_RADIO_GROUP:String = "FVFRadioGroup";
    
    private static var TOTAL_BUFFS:Number = 3;
    private static var BUFF_SCALE:Number = 50;
    
    //Properties
    public var SignalControlSelectionChanged:Signal;
    
    public var m_HighPoweredWeaponryCheckBox:MovieClip;
    public var m_ReinforcedArmorCheckBox:MovieClip;
    public var m_IntegratedAnimaConduitsCheckBox:MovieClip;
    
    public var m_HighPoweredWeaponryRadioButton:MovieClip;
    public var m_ReinforcedArmorRadioButton:MovieClip;
    public var m_IntegratedAnimaConduitsRadioButton:MovieClip;
    
    private var m_UniformTypesTitle:TextField;
    private var m_UniformTypesBackground:MovieClip;
    
    private var m_PvPContainer:MovieClip;
    private var m_FvFContainer:MovieClip;
    
    private var m_HighPoweredWeaponryBuff:MovieClip;
    private var m_ReinforcedArmorBuff:MovieClip;
    private var m_IntegratedAnimaConduitsBuff:MovieClip;
    
    private var m_ControlsArray:Array;
    private var m_SelectionArray:Array;
    
    private var m_Mode:String;
    private var m_IsDisabled:Boolean;
    
    //Constructor
    public function UniformTypes()
    {
        super();
        
        SignalControlSelectionChanged = new Signal();
        
        Init();
    }
    
    //Initialize
    private function Init():Void
    {
        //PvP Check Boxes
        m_PvPContainer = m_UniformTypesBackground.createEmptyMovieClip("m_PvPContainer", m_UniformTypesBackground.getNextHighestDepth());
        m_PvPContainer._visible = false;
        
        m_HighPoweredWeaponryCheckBox = m_PvPContainer.attachMovie("PvPCheckBox", "m_HighPoweredWeaponryCheckBox", m_PvPContainer.getNextHighestDepth());
        m_HighPoweredWeaponryCheckBox.textField.autoSize = "left";
        m_HighPoweredWeaponryCheckBox.label = HIGH_POWERED_WEAPONRY;
        m_HighPoweredWeaponryCheckBox.selected = true;
        
        m_ReinforcedArmorCheckBox = m_PvPContainer.attachMovie("PvPCheckBox", "m_ReinforcedArmorCheckBox", m_PvPContainer.getNextHighestDepth());
        m_ReinforcedArmorCheckBox.textField.autoSize = "left";
        m_ReinforcedArmorCheckBox.label = REINFORCED_ARMOR;
        m_ReinforcedArmorCheckBox.selected = true;
        
        m_IntegratedAnimaConduitsCheckBox = m_PvPContainer.attachMovie("PvPCheckBox", "m_IntegratedAnimaConduitsCheckBox", m_PvPContainer.getNextHighestDepth());
        m_IntegratedAnimaConduitsCheckBox.textField.autoSize = "left";
        m_IntegratedAnimaConduitsCheckBox.label = INTEGRATED_ANIMA_CONDUITS;
        m_IntegratedAnimaConduitsCheckBox.selected = true;
        
        m_FvFContainer = m_UniformTypesBackground.createEmptyMovieClip("m_FvFContainer", m_UniformTypesBackground.getNextHighestDepth());
        m_FvFContainer._visible = false;
        
        //FvF Radio Buttons
        m_HighPoweredWeaponryRadioButton = m_FvFContainer.attachMovie("PvPRadioButton", "m_HighPoweredWeaponryRadioButton", m_FvFContainer.getNextHighestDepth());
        m_HighPoweredWeaponryRadioButton.group = FVF_RADIO_GROUP;
        m_HighPoweredWeaponryRadioButton.textField.autoSize = "left";
        m_HighPoweredWeaponryRadioButton.label = HIGH_POWERED_WEAPONRY;
        m_HighPoweredWeaponryRadioButton.selected = true;
        
        m_ReinforcedArmorRadioButton = m_FvFContainer.attachMovie("PvPRadioButton", "m_ReinforcedArmorRadioButton", m_FvFContainer.getNextHighestDepth());
        m_ReinforcedArmorRadioButton.group = FVF_RADIO_GROUP
        m_ReinforcedArmorRadioButton.textField.autoSize = "left";
        m_ReinforcedArmorRadioButton.label = REINFORCED_ARMOR;
        
        m_IntegratedAnimaConduitsRadioButton = m_FvFContainer.attachMovie("PvPRadioButton", "m_IntegratedAnimaConduitsRadioButton", m_FvFContainer.getNextHighestDepth());
        m_IntegratedAnimaConduitsRadioButton.group = FVF_RADIO_GROUP
        m_IntegratedAnimaConduitsRadioButton.textField.autoSize = "left";
        m_IntegratedAnimaConduitsRadioButton.label = INTEGRATED_ANIMA_CONDUITS;
        
        //Buffs
        m_HighPoweredWeaponryBuff = m_UniformTypesBackground.attachMovie("BuffComponent", "m_HighPoweredWeaponryBuff", m_UniformTypesBackground.getNextHighestDepth());
        m_HighPoweredWeaponryBuff.SetBuffData(Spell.GetBuffData(7142469));
        m_HighPoweredWeaponryBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        
        m_ReinforcedArmorBuff = m_UniformTypesBackground.attachMovie("BuffComponent", "m_ReinforcedArmorBuff", m_UniformTypesBackground.getNextHighestDepth());
        m_ReinforcedArmorBuff.SetBuffData(Spell.GetBuffData(7148879));
        m_ReinforcedArmorBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        
        m_IntegratedAnimaConduitsBuff = m_UniformTypesBackground.attachMovie("BuffComponent", "m_IntegratedAnimaConduitsBuff", m_UniformTypesBackground.getNextHighestDepth());
        m_IntegratedAnimaConduitsBuff.SetBuffData(Spell.GetBuffData(7148899));
        m_IntegratedAnimaConduitsBuff.SetTooltipOrientation(TooltipInterface.e_OrientationHorizontal);
        
        //Remove Focus Array
        m_ControlsArray = new Array (
                                    m_HighPoweredWeaponryCheckBox,
                                    m_ReinforcedArmorCheckBox,
                                    m_IntegratedAnimaConduitsCheckBox,
                                    m_HighPoweredWeaponryRadioButton,
                                    m_ReinforcedArmorRadioButton,
                                    m_IntegratedAnimaConduitsRadioButton
                                    );
                                                
        for (var i:Number = 0; i < m_ControlsArray.length; i++)
        {
            m_ControlsArray[i].addEventListener("click", this, "ControlsClickEventHandler");
        }
        
        Layout();
    }
    
    //Controls Click Event Handler
    private function ControlsClickEventHandler():Void
    {
        m_SelectionArray = new Array();
        
        for (var i:Number = 0; i < m_ControlsArray.length; i++)
        {
            m_SelectionArray.push((m_ControlsArray[i].selected) ? true : false);
        }
        
        SignalControlSelectionChanged.Emit(m_SelectionArray);
        
        Selection.setFocus(null);
    }
    
    //Buff Load Complete Handler
    private function BuffLoadCompleteHandler(target:MovieClip):Void
    {
        target._alpha = (m_IsDisabled) ? 50 : 100;
    }
    
    //Layout
    private function Layout():Void
    {
        m_HighPoweredWeaponryCheckBox._x = m_HighPoweredWeaponryRadioButton._x = 10;
        m_HighPoweredWeaponryCheckBox._y = 10;
        m_HighPoweredWeaponryRadioButton._y = 11;
        m_HighPoweredWeaponryBuff._xscale = m_HighPoweredWeaponryBuff._yscale = BUFF_SCALE;
        m_HighPoweredWeaponryBuff._y = m_HighPoweredWeaponryCheckBox._y - 2;
        m_HighPoweredWeaponryBuff._x = m_UniformTypesBackground._width - m_HighPoweredWeaponryBuff._width - 10;
        
        m_ReinforcedArmorCheckBox._x = m_ReinforcedArmorRadioButton._x = 10;
        m_ReinforcedArmorCheckBox._y = 39;
        m_ReinforcedArmorRadioButton._y = 40;
        m_ReinforcedArmorBuff._xscale = m_ReinforcedArmorBuff._yscale = BUFF_SCALE;
        m_ReinforcedArmorBuff._y = m_ReinforcedArmorCheckBox._y - 2;
        m_ReinforcedArmorBuff._x = m_UniformTypesBackground._width - m_ReinforcedArmorBuff._width - 10;
        
        m_IntegratedAnimaConduitsCheckBox._x = m_IntegratedAnimaConduitsRadioButton._x = 10;
        m_IntegratedAnimaConduitsCheckBox._y = 68;
        m_IntegratedAnimaConduitsRadioButton._y = 69;
        m_IntegratedAnimaConduitsBuff._xscale = m_IntegratedAnimaConduitsBuff._yscale = BUFF_SCALE;
        m_IntegratedAnimaConduitsBuff._y = m_IntegratedAnimaConduitsCheckBox._y - 2;
        m_IntegratedAnimaConduitsBuff._x = m_UniformTypesBackground._width - m_IntegratedAnimaConduitsBuff._width - 10;
    }
    
    public function SetValidRadioButtonUniforms(value:Number):Void
    {
        if (value > 0)
        {
            m_HighPoweredWeaponryRadioButton.disabled = !(value & _global.Enums.Class.e_Damage);
            m_ReinforcedArmorRadioButton.disabled = !(value & _global.Enums.Class.e_Tank);
            m_IntegratedAnimaConduitsRadioButton.disabled = !( value & _global.Enums.Class.e_Heal);
            
            if (m_HighPoweredWeaponryRadioButton.disabled)
            {
                m_HighPoweredWeaponryRadioButton.selected = false;
                m_ReinforcedArmorRadioButton.selected = !m_ReinforcedArmorRadioButton.disabled;
                if (m_ReinforcedArmorRadioButton.disabled)
                {
                    m_IntegratedAnimaConduitsRadioButton.selected = !m_IntegratedAnimaConduitsRadioButton.disabled;
                }
            }
            else 
            {
                m_HighPoweredWeaponryRadioButton.selected = true;
            }
        }
        else
        {
            m_HighPoweredWeaponryRadioButton.disabled = false;
            m_ReinforcedArmorRadioButton.disabled = false;
            m_IntegratedAnimaConduitsRadioButton.disabled = false;
        }
    }
    
    //Set Mode
    public function set mode(value:String):Void
    {
        if (value == PVP_MODE)
        {
            m_UniformTypesTitle.text = PVP_UNIFORM_TYPES_TITLE;
            m_PvPContainer._visible = true;
            m_FvFContainer._visible = false;
        }
        
        if (value == FVF_MODE)
        {
            m_UniformTypesTitle.text = FVF_UNIFORM_TYPES_TITLE;
            m_PvPContainer._visible = false;
            m_FvFContainer._visible = true;
        }
        
        m_Mode = value;
    }
    
    //Get Mode
    public function get mode():String
    {
        return m_Mode;
    }
    
    //Set Disabled
    public function set disabled(value:Boolean):Void
    {
        m_UniformTypesTitle._alpha = (value) ? 50 : 100;
        m_PvPContainer._alpha = (value) ? 50 : 100;
        m_FvFContainer._alpha = (value) ? 50 : 100;
        
        m_HighPoweredWeaponryBuff._alpha = (value) ? 50 : 100;
        m_ReinforcedArmorBuff._alpha = (value) ? 50 : 100;
        m_IntegratedAnimaConduitsBuff._alpha = (value) ? 50 : 100;

        for (var i:Number = 0; i < m_ControlsArray.length; i++)
        {
            m_ControlsArray[i].disabled = value;
        }
        
        m_IsDisabled = value;
    }
    
    //Get Disabled
    public function get disabled():Boolean
    {
        return m_IsDisabled;
    }
    
    //Set Selection
    public function set selection(value:Array):Void
    {
        for (var i:Number = 0; i < m_ControlsArray.length; i++)
        {
            m_ControlsArray[i].selected = value[i];
        }
        
        m_SelectionArray = value;
    }
    
    //Get Selection
    public function get selection():Array
    {
        return m_SelectionArray;
    }
}