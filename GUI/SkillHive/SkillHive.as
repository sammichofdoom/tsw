//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.DialogIF;
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.GearManager;
import com.GameInterface.Log;
import com.GameInterface.LoreBase;
import com.GameInterface.ProjectFeatInterface;
import com.GameInterface.ProjectSpell;
import com.GameInterface.SkillWheel.Cell;
import com.GameInterface.SkillWheel.Cluster;
import com.GameInterface.SkillWheel.SkillTemplate;
import com.GameInterface.SkillWheel.SkillWheel;
import com.GameInterface.Spell;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Utils;
import com.Utils.Archive;
import com.Utils.Colors;
import com.Utils.DragObject;
import com.Utils.LDBFormat;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import gfx.controls.Label;
import GUI.HUD.AbilityBase;
import GUI.SkillHive.CellClip;
import GUI.SkillHive.ClusterClip;
import GUI.SkillHive.SkillHiveDrawHelper;
import GUI.SkillHive.SkillhiveEquipPopup;
import GUI.SkillHive.SkillHiveFeatHelper;
import GUI.SkillHive.SkillhivePowerInventory;
import GUI.SkillHive.SkillHiveSignals;
import flash.geom.Point;
import mx.transitions.easing.*;
import mx.utils.Delegate;

//Constants
var TEMPLATE:Number = 0;
var CELL:Number = 1;

var WHEELINDEX_MAIN:Number = 0;
var WHEELINDEX_AUXILLIARY:Number = 1;
var WHEELINDEX_BEASTIARY:Number = 2;

var WHEEL_PADDING:Number = 600;

var INNER_RADIUS:Number = 180;
var INNER_RADIUS_BACKGROUND = 150;

var PANE_HEADER_OFFSET:Number = 33;
var PANE_CLOSE_WIDTH:Number = 30;

var SCROLL_INTERVAL:Number = 10;
var PANEL_TWEEN_SPEED:Number = 0.3;

var ACTIVE_SHORTCUT_FIRST_SLOT:Number = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
var PASSIVE_SHORTCUT_FIRST_SLOT:Number = _global.Enums.PassiveAbilityShortcutSlots.e_PassiveShortcutBarFirstSlot;


//Properties
var m_SelectedAbilityWheel:MovieClip;
var m_SelectedAbilityWheelIndex:Number;
var m_AbilityWheels:Array;
var m_AbilityWheelButtons:Array;

var m_AbilityWheelSelector:MovieClip;
var m_UpdateOnAdvancedChanged:Boolean = true;

var m_RingBackground:MovieClip;
var m_TemplateFilter:MovieClip;
var m_IsWidescreen:Boolean = false;
var m_Character:Character;
var m_ActiveDialog:DialogIF;
var m_ShowTemplateAbilities:Boolean;

var m_IsDraggingAbility:Boolean = false;
var m_TrainedAbilities:Number = 0;

var m_CellAbilities:Array = new Array();
var m_CellAbilitiesHeight:Number = 0;
var m_DefaultCellAbilityHeight:Number = 0;
var m_SelectedCellPowers:Object;
var m_SelectedCellAbilityClip:MovieClip;
var m_CurrentEquipPanel:MovieClip;
var m_CurrentEquipPopupHolder:MovieClip;
var m_CurrentEquipPopupMenu:SkillhiveEquipPopup;
var m_SelectedFeat:FeatData;
var m_DetailedText:MovieClip;

var m_BreadcrumbContent:MovieClip;
var m_BreadcrumbLabelArray:Array;

var m_PanelScale:Number = 100;
var i_Cell:MovieClip; //created in .fla
var m_VisibleSheet:MovieClip = i_Cell;
var m_DefaultSkillhiveBackgroundWidth:Number;

var m_SelectedTemplate:SkillTemplate;
var m_TemplateFilterArray:Array;

var m_SidePanesArray:Array;
var m_PaneLayoutArray:Array = [];
var m_Mask:MovieClip;
var m_PanelOpenWidths:Array = [300, 335]

var m_x:Number;
var m_Y:Number;

var m_NumOpen:Number;
var m_IsPowerInventoryOpen:Boolean;

var m_PassiveBarVisible:Boolean;
var m_ActiveBarVisible:Boolean;

var m_CharacterSkillPointGUIMonitor:DistributedValue;
var m_AdvancedTooltipMonitor:DistributedValue;
var m_ShowAdvancedTooltips:Boolean;
var m_HyperLinkClicked:Boolean;
var m_LastClickedCellAbility:Number;
var m_PowerInventory:SkillhivePowerInventory;

Mouse.addListener(this);


function onLoad()
{    
    //var width:Number = Stage["visibleRect"].width;
    //Initializing the character and getting properties (No argument means clientcharacter
    m_Character = Character.GetClientCharacter();
    
    //Chat block
    DistributedValue.SetDValue("chat_group_windows_force_off", true);
    m_CharacterSkillPointGUIMonitor = DistributedValue.Create("character_points_gui");
    m_CharacterSkillPointGUIMonitor.SignalChanged.Connect( SlotToggleCharacterSkillPointGUI, this );
    
    m_AdvancedTooltipMonitor = DistributedValue.Create("ShowAdvancedTooltips");
    m_AdvancedTooltipMonitor.SignalChanged.Connect( ToggleAdvancedTooltips, this );
    
    m_DefaultSkillhiveBackgroundWidth = i_SkillhiveBackground._width;
    m_TemplateFilterArray = [];
    
    i_SkillhiveBackground.m_InfoPane.m_TotalAnimaPoints.m_TotalAnimaPointsText.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillHive_TotalAnimaPoints");
    i_SkillhiveBackground.m_InfoPane.m_TotalAbilities.m_TotalAbilitiesText.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillHive_TotalAbilities");
    
    TooltipUtils.AddTextTooltip(i_SkillhiveBackground.m_InfoPane.m_TotalAnimaPoints, LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsHowToEarn"), 130, TooltipInterface.e_OrientationVertical, true);
    
    i_Cell.i_CellMessage.autoSize = "center";
    i_Cell.i_CellMessage.text = LDBFormat.LDBGetText("SkillhiveGUI", "SkillHive_NoAbilityCellsSelected");
    
    i_Close.disableFocus = true;
    i_Close.onRelease = Delegate.create(this, CloseSkillHive);
    i_Help.onRelease = Delegate.create(this, SlotSkillHiveHelp);
    
    i_Cell.onMouseDown = Delegate.create(this, SlotCellMouseDown);
    i_Cell.onMouseUp = Delegate.create(this, SlotCellMouseUp);

    var newY:Number = PANE_HEADER_OFFSET;
    for (var i:Number = 0; i < 7; i++)
    {
        var name:String = "i_CellAbility_" + i;

        m_CellAbilities[i] = i_Cell.i_CellContent.attachMovie("AbilityClip", name, i_Cell.i_CellContent.getNextHighestDepth() );
        m_CellAbilities[i].m_CellID = i;
        m_CellAbilities[i]._y = newY;
        m_CellAbilities[i]._x = 0;
        newY += m_CellAbilities[i]._height;
        m_CellAbilities[i].m_DesiredHeight = m_CellAbilities[i]._height;
        m_CellAbilities[i].m_SP.m_SkillPointsLabel.text = LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsAbbreviation");
        m_CellAbilities[i].i_AbilitySelectedCellBorder._visible = false;
                
        m_CellAbilities[i].i_Background.onMousePress = m_CellAbilities[i].i_Cover.onMousePress = m_CellAbilities[i].m_Icon.onMousePress = SlotCellAbilityPress;
        m_CellAbilities[i].m_ExpandButton.onMouseRelease = m_CellAbilities[i].i_Background.onMouseRelease = m_CellAbilities[i].i_Cover.onMouseRelease = m_CellAbilities[i].m_Icon.onMouseRelease = SlotCellAbilityRelease;
        m_CellAbilities[i].i_Text.onMouseRelease = m_CellAbilities[i].i_DetailedText.onMouseRelease = SlotAbilityTextRelease;
        
        m_CellAbilities[i].onMouseUp = function()
        {
            this.m_WasHit = false;
        }
        
        m_CellAbilities[i].onMouseMove = function()
        {
            var mousePos:Point = new Point( _root._xmouse, _root._ymouse );
            if ( this.m_WasHit && Point.distance( this.m_HitPos, mousePos ) > 10  )
            {
                var feat:FeatData = this.m_Feat;
                if (feat.m_Trained && !DragObject.GetCurrentDragObject())
                {
                    var dragData:DragObject = new DragObject();
                    dragData.SignalDragHandled.Connect(SlotDragHandled, this);
                    var abilityType:String = "Ability";
                    if (feat.m_SpellType == _global.Enums.SpellItemType.eMagicSpell || feat.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility || feat.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
                    {
                        dragData.type = "skillhive_active";
                        
                    }
                    else
                    {
                        dragData.type = "skillhive_passive";
                        abilityType = "Passive"
                    }
                    dragData.ability = feat.m_Spell;
                    
                    var dragClip  = AbilityBase(this.attachMovie( abilityType, "drag_clip", this.getNextHighestDepth(), { m_ColorNum: feat.m_ColorLine, _x: this._xmouse, _y: this._ymouse} ));
                    dragClip.SetColor( feat.m_ColorLine ); 
                    dragClip.SetIcon( Utils.CreateResourceString(feat.m_IconID) );
                    dragClip.SetSpellType( feat.m_SpellType );
                    
                    gfx.managers.DragManager.instance.startDrag( this, dragClip, dragData, dragData, null, false );
                    gfx.managers.DragManager.instance.removeTarget = true;
                    
                    gfx.managers.DragManager.instance.dragOffsetY = -dragClip._width / 2;
                    gfx.managers.DragManager.instance.dragOffsetX = -dragClip._width / 2;
                    
                    dragClip.topmostLevel = true;
                    m_IsDraggingAbility = true;
                }
                this.m_WasHit = false;
            }
        }
    }
    
    m_BreadcrumbContent = createEmptyMovieClip("i_BreadcrumbContent", getNextHighestDepth());
    m_BreadcrumbLabelArray = [];
    
    m_BreadcrumbContent.swapDepths(m_CharacterSkillPointPanel);
    m_CharacterSkillPointPanel.swapDepths(i_Close);
    
    m_DefaultCellAbilityHeight = i_Cell.i_CellContent.i_CellAbility_0._height;
    
    m_ShowTemplateAbilities = false;
    if (i_Cell.m_ToggleDeckAbilities)
    {
        i_Cell.m_ToggleDeckAbilities.disableFocus = true;
        i_Cell.m_ToggleDeckAbilities.addEventListener( "select", this, "SlotToggleTemplateAbilities" );
        i_Cell.m_ToggleDeckAbilities.autoSize = "Left";
        i_Cell.m_ToggleDeckAbilities.label = LDBFormat.LDBGetText("SkillhiveGUI", "ShowDeckAbilities")
    }
    
    m_ShowAdvancedTooltips = m_AdvancedTooltipMonitor.GetValue();
    if (i_Cell.m_ShowAdvancedTooltips)
    {
        i_Cell.m_ShowAdvancedTooltips.disableFocus = true;
        i_Cell.m_ShowAdvancedTooltips.addEventListener( "select", this, "SlotUpdateAdvancedTooltips" );
        i_Cell.m_ShowAdvancedTooltips.autoSize = "Left";
        i_Cell.m_ShowAdvancedTooltips.label = LDBFormat.LDBGetText("MainGUI", "MainMenu_Options_ShowAdvancedTooltips");
        i_Cell.m_ShowAdvancedTooltips.selected = m_AdvancedTooltipMonitor.GetValue();
    }
    
    // Create the background clip.
    m_RingBackground = i_SkillhiveBackground.createEmptyMovieClip( "i_RingBackground", i_SkillhiveBackground.getNextHighestDepth() );
    m_TemplateFilter = m_RingBackground.createEmptyMovieClip( "i_TemplateFilter", m_RingBackground.getNextHighestDepth() );
    m_AbilityWheelSelector = i_SkillhiveBackground.m_AbilityWheelSelector;
    
    m_RingBackground.swapDepths(m_AbilityWheelSelector);
    
    m_AbilityWheelSelector.m_SelectorContainer.m_NextButton.disableFocus = true;
    m_AbilityWheelSelector.m_SelectorContainer.m_PreviousButton.disableFocus = true;
    
    m_AbilityWheelSelector.m_SelectorContainer.m_NextButton.addEventListener("click", this, "SlotNextAbilityWheel");
    m_AbilityWheelSelector.m_SelectorContainer.m_PreviousButton.addEventListener("click", this, "SlotPreviousAbilityWheel");
    
    m_AbilityWheelSelector.m_WheelName.autoSize = "center";

    m_AbilityWheels = [];
    m_AbilityWheelButtons = [];
    var mainWheel = CreateMainSkillWheel();
    m_AbilityWheels.push(mainWheel);
    
    var auxilliaryWheel = CreateAuxilliaryWheel();
    auxilliaryWheel._alpha = 0;
    m_AbilityWheels.push(auxilliaryWheel);
        
    SetSelectedAbilityWheel(WHEELINDEX_MAIN, true);
    
    for (var i:Number = 0; i < m_AbilityWheels.length; i++)
    {
        m_AbilityWheels[i]._x = WHEEL_PADDING * i;
        m_AbilityWheels[i].SetCharacter(m_Character);
        m_AbilityWheels[i].SetWheelBackground(m_RingBackground);
        m_AbilityWheels[i].SetTemplateFilterClip(m_TemplateFilter);
        
        m_AbilityWheels[i].SignalCellSelected.Connect(SlotCellSelected, this);
        m_AbilityWheels[i].SignalAnimateWheel.Connect(SlotWheelAnimated, this);
        m_AbilityWheels[i].SignalCellAbilitySelected.Connect(SlotCellAbilitySelected, this);
        m_AbilityWheels[i].InitializeWheel();
        
        var wheelButton = m_AbilityWheelSelector.m_SelectorContainer.attachMovie(m_AbilityWheels[i].GetButtonName(), "m_WheelButton_" + i, m_AbilityWheelSelector.m_SelectorContainer.getNextHighestDepth());
        wheelButton.addEventListener("click", this, "SlotAbilityWheelButton");
        wheelButton.disableFocus = true;
        wheelButton.m_Index = i;
        m_AbilityWheelButtons.push(wheelButton);
    }
    
    var startX:Number = m_AbilityWheelSelector.m_SelectorContainer.m_PreviousButton._x + m_AbilityWheelSelector.m_SelectorContainer.m_PreviousButton._width + 15;
    for (var i:Number = 0; i < m_AbilityWheelButtons.length; i++)
    {
        startX += m_AbilityWheelButtons[i]._width / 2
        m_AbilityWheelButtons[i]._x = startX;
        m_AbilityWheelButtons[i]._y = m_AbilityWheelButtons[i]._height / 2 + 7;
        startX += m_AbilityWheelButtons[i]._width / 2 + 15;
    }
    m_AbilityWheelSelector.m_SelectorContainer.m_NextButton._x = startX
    m_AbilityWheelSelector.m_SelectorContainer._x = -m_AbilityWheelSelector.m_SelectorContainer._width / 2
    
    m_SelectedAbilityWheel.DrawBackground();
    m_SelectedAbilityWheel.DrawTemplates();
    
    ToggleAbilityWheelButtonsSizes();
    
    m_RingBackground.onPress = function(){ };
    i_SkillhiveBackground.i_Background.onMouseRelease = i_SkillhiveBackground.m_InfoPane.onMouseRelease = SlotZoomOut;
    
    UpdateTotalSkillpoints();
    UpdateHiveCompletion();
    UpdateBreadcrumbPath();
    
    // side panes
    SetAspectRatio();
    SetupSidePanes();
    
    CreateScrollbar( i_Cell, "OnCellScrollbarUpdate");
    
    Layout();
    
    m_PassiveBarVisible = true;
    m_ActiveBarVisible = true;
    
    m_HyperLinkClicked = false;
    m_LastClickedCellAbility = getTimer();
    
    i_AbilityBars.i_PassiveAbilityBar.SignalToggleVisibility.Connect(SlotToggleVisibilityPassiveBar, this);
    i_AbilityBars.i_ActiveAbilityBar.SignalToggleVisibility.Connect(SlotToggleVisibilityActiveBar, this);
    i_AbilityBars.i_PassiveAbilityBar.i_Text.text = LDBFormat.LDBGetText("SkillhiveGUI", "EquippedPassives");
    i_AbilityBars.i_ActiveAbilityBar.i_Text.text = LDBFormat.LDBGetText("SkillhiveGUI", "EquippedActives");
    i_Templates.SignalTemplateSelected.Connect(SlotTemplateSelected, this);
    i_Templates.SetFaction(m_Character.GetStat(_global.Enums.Stat.e_PlayerFaction));
    
    Spell.EnterPassiveMode();
    
    SlotToggleVisibilityPassiveBar(true);
    SlotToggleVisibilityActiveBar(true);
        
    SetupPowerInventory(false);
    UpdateBackgroundAndBarPositions(true);
    
    gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "SlotDragBegin" );
    
    SkillHiveSignals.SignalSelectAbility.Connect(SlotAbilitySelected, this);
    SkillHiveSignals.SignalBuyAbility.Connect(SlotBuyAbility, this);
    SkillHiveSignals.SignalEquipAbilityInFirstFreeSlot.Connect(EquipAbilityInFirstFreeSlot, this);
        
    FeatInterface.SignalFeatTrained.Connect(SlotFeatTrained, this);
    FeatInterface.SignalFeatsUntrained.Connect(SlotFeatUntrained, this);
    
    m_Character.SignalTokenAmountChanged.Connect(SlotTokenChanged, this);
    m_Character.SignalBuffAdded.Connect(SlotUpdateCellPanelTimer, this);
    m_Character.SignalInvisibleBuffAdded.Connect(SlotUpdateCellPanelTimer, this);
    m_Character.SignalBuffRemoved.Connect(SlotUpdateCellPanelTimer, this);
    
    Shortcut.SignalShortcutAdded.Connect(SlotUpdateEquipPanel, this);
    Shortcut.SignalShortcutRemoved.Connect(SlotUpdateEquipPanel, this);
    Spell.SignalPassiveAdded.Connect(SlotUpdateEquipPanel, this);
    Spell.SignalPassiveRemoved.Connect(SlotUpdateEquipPanel, this);
    
    
    m_CharacterSkillPointPanel.IsOpen = false; 

    if (DistributedValue.GetDValue("DisplayAuxiliaryNotification"))
    {
        DistributedValue.SetDValue("DisplayAuxiliaryNotification", false);
        
        _global.setTimeout(Delegate.create(this, SwitchToAxuiliary), 200);
    }
    else if (DistributedValue.GetDValue("character_points_gui", false))
    {
        AnimateCharacterSkillPointPanel(true, true);
    }
    else
    {
        DistributedValue.SetDValue("anima_wheel_gui", true);
    }
    
    if (m_CharacterSkillPointGUIMonitor.GetValue())
    {
        SlotToggleCharacterSkillPointGUI();
    }
    else
    {
        LoreBase.OpenTagOnce(5197);
    }
    
}


function SwitchToAxuiliary():Void
{
    SetSelectedAbilityWheel(WHEELINDEX_AUXILLIARY, true);
}

function SlotAbilityWheelButton(event:Object)
{
    event.target.attachMovie("WheelButtonClickAnimation", m_Animation, event.target.getNextHighestDepth());
    SetSelectedAbilityWheel(event.target.m_Index);
}

function SlotNextAbilityWheel()
{
    var nextIndex:Number = (m_SelectedAbilityWheelIndex + 1) % m_AbilityWheels.length;
    SetSelectedAbilityWheel(nextIndex, false, true);
}

function SlotPreviousAbilityWheel()
{
    var previousIndex:Number = m_SelectedAbilityWheelIndex - 1
    if (previousIndex < 0)
    {
        previousIndex = m_AbilityWheels.length - 1;
    }
    SetSelectedAbilityWheel(previousIndex, false, false);
}

function ToggleNoCellSelectedMessage(visible:Boolean):Void
{
    i_Cell.i_CellMessage._visible = visible;
    i_Cell.i_CellContent._visible = !visible;
    i_Cell.i_ScrollBar._visible = !visible;
}

function SetSelectedAbilityWheel(wheelIndex:Number, snapAnimation:Boolean, animateLeft:Boolean )
{    
    if (wheelIndex != m_SelectedAbilityWheelIndex && wheelIndex < m_AbilityWheels.length)
    {
        if (m_AbilityWheels[wheelIndex].GetSelectedCell() != undefined)
        {
            SlotCellSelected(m_AbilityWheels[wheelIndex].GetSelectedCell());
        }
        else
        {
            ToggleNoCellSelectedMessage(true);
        }

        var currentX:Number = i_SkillhiveBackground.i_Background._width / 2;
        var snap:Boolean = snapAnimation;
        if (snap == undefined)
        {
            snap = m_SelectedAbilityWheel == undefined;
        }
        var goingLeft:Boolean = animateLeft;
        if (goingLeft == undefined)
        {
            goingLeft = (m_SelectedAbilityWheelIndex == undefined) || (wheelIndex > m_SelectedAbilityWheelIndex);
        }
        for (var i:Number = 0; i < m_AbilityWheels.length; i++)
        {
            var wheelX:Number = currentX + (i - wheelIndex) * WHEEL_PADDING
            
            if (snap)
            {
                m_AbilityWheels[i]._x = wheelX;
                m_AbilityWheels[i]._visible = (wheelIndex == i);
                m_AbilityWheels[i]._alpha = (i == wheelIndex )? 100 : 0;
            }
            else
            {
                if (m_SelectedAbilityWheelIndex == i)
                {
                    
                    m_AbilityWheels[i]._visible = true;
                    var x:Number = currentX +  WHEEL_PADDING
                    if (goingLeft)
                    {
                        x = currentX - WHEEL_PADDING;
                    }
                    m_AbilityWheels[i].tweenTo(0.5, { _alpha:0, _x:x }, Regular.easeOut);
                    m_AbilityWheels[i].onTweenComplete = function()
                    {
                        UpdateAbilityWheelVisibility();
                    }
                }
                else if (wheelIndex == i)
                {
                    m_AbilityWheels[i]._visible = true;
                    if (goingLeft)
                    {
                        m_AbilityWheels[i]._x = currentX + WHEEL_PADDING;
                    }
                    else
                    {
                        m_AbilityWheels[i]._x = currentX - WHEEL_PADDING;
                    }
                    m_AbilityWheels[i].tweenTo(0.5, { _alpha:100, _x:wheelX }, Regular.easeOut);
                    
                }
                else
                {
                    m_AbilityWheels[i]._x = wheelX;
                }
            }
        }
        
        if ( m_SelectedAbilityWheel != undefined )
        {        
            m_SelectedAbilityWheel.ClearTemplateFilterClips();
        }
        m_SelectedAbilityWheel = m_AbilityWheels[wheelIndex];
        m_SelectedAbilityWheelIndex = wheelIndex;
        
        m_AbilityWheelSelector.m_WheelName.text = m_SelectedAbilityWheel.GetName();
        
        ToggleAbilityWheelButtonsSizes();
        
        m_SelectedAbilityWheel.DrawBackground();
        m_SelectedAbilityWheel.DrawTemplates();
        
        UpdateTotalSkillpoints();
        UpdateHiveCompletion();
        UpdateBreadcrumbPath();
    }
}

function ToggleAbilityWheelButtonsSizes():Void
{
    for (var i:Number = 0; i < m_AbilityWheelButtons.length; i++)
    {
        m_AbilityWheelButtons[i]._xscale = m_AbilityWheelButtons[i]._yscale = i == m_SelectedAbilityWheelIndex ? 150 : 100;
    }
}

function UpdateAbilityWheelVisibility()
{
    for (var i:Number = 0; i < m_AbilityWheels.length; i++ )
    {
        if (i != m_SelectedAbilityWheelIndex)
        {
            m_AbilityWheels[i]._visible = false;
        }
    }
}
function ShowAbilityWheels(show:Boolean)
{
    for (var i:Number = 0; i < m_AbilityWheels.length; i++ )
    {
        m_AbilityWheels[i]._visible = show;
    }
}

function CreateMainSkillWheel()
{
    var mainSkillWheel = i_SkillhiveBackground.attachMovie("AbilityWheel", "m_MainSkillWheel", i_SkillhiveBackground.getNextHighestDepth());
    
    //Make the clustersetup
    var clusters:Array = [ new Cluster(1),
                           new Cluster(101), 
                           new Cluster(201), 
                           new Cluster(11), 
                           new Cluster(12), 
                           new Cluster(13), 
                           new Cluster(111), 
                           new Cluster(112), 
                           new Cluster(113), 
                           new Cluster(211), 
                           new Cluster(212), 
                           new Cluster(213),
                           new Cluster(2001),
                           new Cluster(2002),
                           new Cluster(2003) ]
                           
    clusters[0].m_Clusters =  [11, 12, 13];
    clusters[1].m_Clusters =  [111, 112, 113];
    clusters[2].m_Clusters =  [211, 212, 213];

    clusters[3].SetDependency(1, [1, 2]);
    clusters[4].SetDependency(1, [3, 4]);
    clusters[5].SetDependency(1, [5, 6]);
    clusters[6].SetDependency(101, [1, 2]);
    clusters[7].SetDependency(101, [3, 4]);
    clusters[8].SetDependency(101, [5, 6]);
    clusters[9].SetDependency(201, [1, 2]);
    clusters[10].SetDependency(201, [3, 4]);
    clusters[11].SetDependency(201, [5, 6]);
    
    mainSkillWheel.SetClusters(clusters);
    mainSkillWheel.SetWheelRadius(INNER_RADIUS, INNER_RADIUS_BACKGROUND);
    mainSkillWheel.SetName(LDBFormat.LDBGetText("SkillhiveGUI", "MainWheelName"));
    mainSkillWheel.SetShortName(LDBFormat.LDBGetText("SkillhiveGUI", "MainClusterName"));
    mainSkillWheel.SetButtonName("MainWheelButton");
    mainSkillWheel.SetClusterDistance(75)
    
    // This list holds the starting point for all the data, the 3 basecluster visual definitions.
    var startClusterList:Object = 
              {  melee:  { clusterId:1,     startAngle:5.5, angle:109, radius:INNER_RADIUS  },
                 magic:  { clusterId:101,   startAngle:125.5, angle:109, radius:INNER_RADIUS },
                 ranged: { clusterId:201,   startAngle:245.5, angle:109, radius:INNER_RADIUS },
                 meleemisc: { clusterId:2001,   startAngle:357.5, angle:5, radius:INNER_RADIUS + mainSkillWheel.GetClusterDistance() },
                 magicmisc: { clusterId:2002,   startAngle:117.5, angle:5, radius:INNER_RADIUS + mainSkillWheel.GetClusterDistance() },
                 rangedmisc: { clusterId:2003,   startAngle:237.5, angle:5, radius:INNER_RADIUS + mainSkillWheel.GetClusterDistance() }
              }
    
    mainSkillWheel.SetStartClusters(startClusterList);

    return mainSkillWheel;
}

function CreateAuxilliaryWheel()
{
    var auxilliaryWheel = i_SkillhiveBackground.attachMovie("AbilityWheel", "m_AuxilliarySkillWheel", i_SkillhiveBackground.getNextHighestDepth());
    
    //Make the clustersetup (3 fake clusters at the inner ring, melee, magic and ranged) with clusters layed out from there
    var clusters:Array = [  new Cluster(2300), 
                            new Cluster(2200), 
                            new Cluster(2100), 
                            new Cluster(2101), 
                            new Cluster(2102), 
                            new Cluster(2103), 
                            new Cluster(2201), 
                            new Cluster(2202), 
                            new Cluster(2203),
                            new Cluster(2301), 
                            new Cluster(2302), 
                            new Cluster(2303)]
    
    clusters[0].m_OverrideLocked = false;
    clusters[1].m_OverrideLocked = false;
    clusters[2].m_OverrideLocked = false;
    clusters[3].m_OverrideLocked = false;
    clusters[4].m_OverrideLocked = true;
    clusters[5].m_OverrideLocked = true;
    clusters[6].m_OverrideLocked = false;
    clusters[7].m_OverrideLocked = true;
    clusters[8].m_OverrideLocked = true;
    clusters[9].m_OverrideLocked = false;
    clusters[10].m_OverrideLocked = true;
    clusters[11].m_OverrideLocked = true;
    
    clusters[0].m_Clusters = [2302, 2301, 2303];
    clusters[1].m_Clusters = [2202, 2201, 2203];
    clusters[2].m_Clusters = [2102, 2101, 2103];
        
    auxilliaryWheel.SetClusters(clusters);
    auxilliaryWheel.SetWheelRadius(INNER_RADIUS, INNER_RADIUS_BACKGROUND);
    auxilliaryWheel.SetName(LDBFormat.LDBGetText("SkillhiveGUI", "AuxilliaryWheelName"));
    auxilliaryWheel.SetShortName(LDBFormat.LDBGetText("SkillhiveGUI", "AuxilliaryClusterName"));
    auxilliaryWheel.SetButtonName("AuxilliaryWheelButton");
    auxilliaryWheel.SetClusterDistance(75);
    
    // This list holds the starting point for all the data, the 3 basecluster visual definitions.
    var startClusterList:Object = 
              { melee:  { clusterId:2300, startAngle:2.5, angle:115, radius:INNER_RADIUS },
                magic:  { clusterId:2200, startAngle:122.5, angle:115, radius:INNER_RADIUS },
                ranged:  { clusterId:2100, startAngle:242.5, angle:115, radius:INNER_RADIUS}
              }
              
    auxilliaryWheel.SetStartClusters(startClusterList);
    //auxilliaryWheel.SetDrawShadow(false);

    return auxilliaryWheel;    
}

function GetAbilityWheelContainingCluster(clusterIndex:Number)
{
    for (var i:Number = 0; i < m_AbilityWheels.length; i++)
    {
        if (m_AbilityWheels[i].HasCluster(clusterIndex))
        {
            return i;
        }
    }
    return -1;
}

function onUnload()
{
    gfx.managers.DragManager.instance.removeEventListener( "dragBegin", this, "SlotDragBegin" );
    
    SkillHiveSignals.SignalSelectAbility.Disconnect(SlotAbilitySelected, this);
    SkillHiveSignals.SignalBuyAbility.Disconnect(SlotBuyAbility, this);
    SkillHiveSignals.SignalEquipAbilityInFirstFreeSlot.Disconnect(EquipAbilityInFirstFreeSlot,this);
    
    FeatInterface.SignalFeatTrained.Disconnect(SlotFeatTrained, this);
    FeatInterface.SignalFeatsUntrained.Disconnect(SlotFeatUntrained, this);
    
    m_Character.SignalTokenAmountChanged.Disconnect(SlotTokenChanged, this);
    m_Character.SignalBuffAdded.Disconnect(SlotUpdateCellPanelTimer, this);
    m_Character.SignalInvisibleBuffAdded.Disconnect(SlotUpdateCellPanelTimer, this);
    m_Character.SignalBuffRemoved.Disconnect(SlotUpdateCellPanelTimer, this);
    
    Shortcut.SignalShortcutAdded.Disconnect(SlotUpdateEquipPanel, this);
    Shortcut.SignalShortcutRemoved.Disconnect(SlotUpdateEquipPanel, this);
    Spell.SignalPassiveAdded.Disconnect(SlotUpdateEquipPanel, this);
    Spell.SignalPassiveRemoved.Disconnect(SlotUpdateEquipPanel, this);
    
    DistributedValue.SetDValue("chat_group_windows_force_off", false);
    DistributedValue.SetDValue("character_points_gui", false);
    DistributedValue.SetDValue("anima_wheel_gui", false);
        
    delete m_PowerInventory;
    
    if (m_ActiveDialog != undefined)
    {
        m_ActiveDialog.Close();
    }
}

function CloseSkillHive()
{
    if (m_Character != undefined) { m_Character.AddEffectPackage( "sound_fxpackage_GUI_click_tiny.xml" ); }
    Spell.ExitPassiveMode();
    DistributedValue.SetDValue("skillhive_window", false);
    DistributedValue.SetDValue("anima_wheel_gui", false);    
}

function SlotSkillHiveHelp(event:Object):Void
{
    if (DistributedValue.GetDValue("character_points_gui", false))
    {
        LoreBase.OpenTag(5138); // skill points help node
    }
    else
    {
        LoreBase.OpenTag(5137); // ability wheel help node
    }
}

///Calls when module is unloaded, and should return an archive with stored values
function OnModuleDeactivated()
{
    var archive:Archive = new Archive();
    archive.ReplaceEntry("_selectedWheel", m_SelectedAbilityWheelIndex);
    
    var selectedCell:Number = 0;
    var selectedCluster:Number = 0;
    
    if (m_SelectedAbilityWheel.GetSelectedCellClip() != undefined)
    {
        selectedCluster = m_SelectedAbilityWheel.GetSelectedCellClip().GetParentClusterID();
        selectedCell = m_SelectedAbilityWheel.GetSelectedCellClip().GetID();
    }
    
    archive.ReplaceEntry("_selectedCluster", selectedCluster);
    archive.ReplaceEntry("_selectedCell", selectedCell);
    archive.ReplaceEntry("_template_open", m_SidePanesArray[TEMPLATE].isOpen);
    archive.ReplaceEntry("_cell_open", m_SidePanesArray[CELL].isOpen);
    archive.ReplaceEntry("_selected_tab_index", i_Templates.GetTabIndex());
    archive.ReplaceEntry("_selected_template", i_Templates.GetSelectedTemplateIndex());
    archive.ReplaceEntry("_show_deck_abilities", m_ShowTemplateAbilities);
    archive.ReplaceEntry("_skill_points", m_Character.GetTokens(2));
    
    return archive;
}

///Calls when module is loaded
///@param config [in] stored values about the module
function OnModuleActivated(config:Archive)
{
    var selectedWheel:Number = Number(config.FindEntry("_selectedWheel"));
    if (selectedWheel == undefined)
    {
        selectedWheel = WHEELINDEX_MAIN
    }
    SetSelectedAbilityWheel(selectedWheel, true);
    
    var selectedCluster = Number(config.FindEntry("_selectedCluster"));
    var selectedCell = Number(config.FindEntry("_selectedCell"));
    
    if (selectedCluster != 0 && selectedCluster != undefined && selectedCluster != NaN && 
        selectedCell != undefined && selectedCell != NaN)
    {
        m_SelectedAbilityWheel.SetSelectedCellFromIndex(selectedCluster, selectedCell);
    }
    else
    {
        m_SelectedAbilityWheel.SetSelectedCellFromIndex(1, 1);
    }
    
    var templatesOpen:Boolean = Boolean(config.FindEntry("_template_open"));
    if (templatesOpen != undefined && templatesOpen != m_SidePanesArray[TEMPLATE].isOpen)
    {
        SlotSwitchSheet(TEMPLATE, false);
    }
    
    var cellOpen:Boolean = Boolean(config.FindEntry("_cell_open"));
    if (cellOpen != undefined && cellOpen != m_SidePanesArray[CELL].isOpen)
    {
        SlotSwitchSheet(CELL, false);
    }
    
    var selectedTabIndex:Number = Number(config.FindEntry("_selected_tab_index"));
    if (selectedTabIndex != undefined)
    {
        i_Templates.SetTabIndex(selectedTabIndex);
    }
    else
    {
        i_Templates.SetTabIndex(0);
    }
    
    var selectedTemplate:Number = Number(config.FindEntry("_selected_template"));
    if (selectedTemplate > 0)
    {
        i_Templates.SetSelectedTemplate(selectedTemplate);
    }
    var showDeckAbilities:Boolean = Boolean(config.FindEntry("_show_deck_abilities"));
    if (showDeckAbilities != undefined)
    {
        i_Cell.m_ToggleDeckAbilities.selected = showDeckAbilities;
        m_ShowTemplateAbilities = showDeckAbilities;
    }
    
    
    var pulsateButton:Boolean = (m_Character.GetTokens(2) > config.FindEntry("_skill_points")) ? true : false;
    SetupSkillPointsPanel(pulsateButton);
}
/** LAYOUT FUNCTIONALITY **/

function ResizeHandler( w, h ,x, y )
{
    _x = Stage["visibleRect"].x;
    _y = Stage["visibleRect"].y;
    if (m_IsPowerInventoryOpen)
    {
        m_PowerInventory.SetSize(Stage.width - m_PowerInventory._x, Stage.height);
    }
    Layout();

}

function SetAspectRatio()
{
    var width:Number = Stage["visibleRect"].width;
    var height:Number = Stage["visibleRect"].height;
    
    if (width / height > 1.7)
    {
        m_IsWidescreen = true;
        m_PanelScale = (width / 1600) * 100;
    }
    else
    {
        m_IsWidescreen = false;
        m_PanelScale = (width / 1280) * 100;
    }
}

function Layout()
{   
    var width:Number = Stage["visibleRect"].width;
    var height:Number = Stage["visibleRect"].height;
 
    SetAspectRatio();
   
    var ringScale = height / 850 * 100;
    
//    Log.Info2("SkillHive", " someSizes " + someSizes+" i_SkillhiveBackground._width "+i_SkillhiveBackground._width+" GetLeftSideWidth() "+GetLeftSideWidth()+" width "+width);
    /// @TODO this calculation needs to be amended for some resolutions
    i_SkillhiveBackground._x = ( (width + GetLeftSideWidth()) / 2) - (m_DefaultSkillhiveBackgroundWidth / 2);
    i_SkillhiveBackground._y = 0;
    i_SkillhiveBackground.i_Background._height = height;
    
    for (var i:Number = 0; i < m_AbilityWheels.length; i++)
    {
        m_AbilityWheels[i]._xscale = ringScale;
        m_AbilityWheels[i]._yscale = ringScale;
        m_AbilityWheels[i]._y = ( i_SkillhiveBackground.i_Background._height / 2 );
    }

    m_SelectedAbilityWheel._x = ( i_SkillhiveBackground.i_Background._width / 2 );
    m_RingBackground._x = m_SelectedAbilityWheel._x;
    m_RingBackground._y = m_SelectedAbilityWheel._y;
    m_RingBackground._xscale = ringScale;
    m_RingBackground._yscale = ringScale;
    
    m_AbilityWheelSelector._x  = m_SelectedAbilityWheel._x;
    m_AbilityWheelSelector._y  = 30;
    
    i_SkillhiveBackground.m_InfoPane._x = m_SelectedAbilityWheel._x;
    i_SkillhiveBackground.m_InfoPane._y = m_SelectedAbilityWheel._y;
    
    i_SkillhiveBackground.i_CircleFirstShade._x = m_SelectedAbilityWheel._x;
    i_SkillhiveBackground.i_CircleFirstShade._y = m_SelectedAbilityWheel._y;
    
    i_SkillhiveBackground.m_InfoPane._xscale = ringScale;
    i_SkillhiveBackground.m_InfoPane._yscale = ringScale;
    
    
    /// the sidepanes
    i_Cell.i_Tab.i_ExpandableTab.i_TabClip.i_TabClipBackground._height = height - 25;
    i_Cell.i_Tab.i_TabFrameLines._height = height - 25;
    i_Cell.i_Background._height = height;
    i_Cell.i_CellMessage._y = i_Cell.i_Background._height / 2 - i_Cell.i_CellMessage._height / 2;

    UpdateScrollBar( CELL );
    
    i_Templates.i_Tab.i_ExpandableTab.i_TabClip.i_TabClipBackground._height = height - 25;
    i_Templates.i_Tab.i_TabFrameLines._height = height - 25;
    i_Templates.i_Background._height = height 
    
    m_PowerInventory.m_Background._height = height;
    m_PowerInventory.m_PowerInventoryPaneButton.m_Background._height = height;
    
    m_HoneyCombBottomLeft._x = 0;
    m_HoneyCombBottomLeft._y = height - m_HoneyCombBottomLeft._height;
    m_HoneyCombBottomLeft._alpha = 30;
    
    m_HoneyCombTopRight._x = width - m_HoneyCombTopRight._width;
    m_HoneyCombTopRight._y = 0;
    m_HoneyCombTopRight._alpha = 30;    
    
    m_CharacterSkillPointPanel.SetSize(width, height);
       m_CharacterSkillPointPanel._x = 0; // ((Stage["visibleRect"].width - m_CharacterSkillPointPanel._width) * 0.5) + (2 * PANE_CLOSE_WIDTH) // Stage["visibleRect"].x + 
    
    if (m_CharacterSkillPointPanel.IsOpen)
    {
        m_CharacterSkillPointPanel._y = 0;
        i_Close._x = width - 27;
    }
    else
    {
        m_CharacterSkillPointPanel._y = -m_CharacterSkillPointPanel.m_Background._height;
        i_Close._x = width - 60;
    }
    
    i_Help._x = i_Close._x - 27; 
    
    var barScale = m_PanelScale * 0.90;
    if (!m_IsWidescreen)
    {
        barScale = width / 1600  * 100
    }
    i_AbilityBars._xscale = barScale;
    i_AbilityBars._yscale = barScale;
    i_AbilityBars._y = height - i_AbilityBars._height;
        
    i_SkillhiveBackground.i_Background.onPress = function(){}
}

function GetLeftSideWidth():Number
{
    var width:Number = 0;

    for (var i:Number = 0; i < m_SidePanesArray.length; i++)
    {
        if (m_SidePanesArray[i].isOpen)
        {
            width += m_PanelOpenWidths[i];
        }
        else
        {
            width += PANE_CLOSE_WIDTH;
        }
    }
    return width;
}

function SlotDragHandled()
{
    m_IsDraggingAbility = false;
}

function SlotCellSelected(cell:Cell)
{
    ToggleNoCellSelectedMessage(false);
    
    if (!IsPaneOpen(CELL))
    {
        SlotSwitchSheet(CELL, false);
    }
    
    m_SelectedAbilityWheel.DrawBackground();
    FillAbilityClips(cell);
}

function SlotCellAbilitySelected(abilityIndex:Number)
{
    SelectCellAbility(abilityIndex, false);
}

function SlotWheelAnimated()
{    
    UpdateHiveCompletion();
    UpdateBreadcrumbPath();
}

function SlotZoomOut(buttonIdx:Number)
{
    if (buttonIdx == 2)
    {
        m_SelectedAbilityWheel.ZoomOut();
    }
}

function SlotAbilitySelected(clusterIndex:Number, cellIndex:Number, abilityIndex:Number )
{
    var abilityWheelWithAbility:Number = GetAbilityWheelContainingCluster(clusterIndex);
    if (abilityWheelWithAbility < 0)
    {
        return;
    }
    if (abilityWheelWithAbility != m_SelectedAbilityWheelIndex)
    {
        SetSelectedAbilityWheel(abilityWheelWithAbility, false);
    }
    
    var cell:CellClip = m_SelectedAbilityWheel.GetCellClip(clusterIndex, cellIndex + 1);
    if (cell != undefined)
    {
        //Select the hovered cell and the pressed ability
        m_SelectedAbilityWheel.SelectCell(cell);
    }
    SelectCellAbility(abilityIndex, false);
    //Centering the scrollbar on the selected cell
    i_Cell.i_ScrollBar.position = (m_SelectedCellAbilityClip != undefined)? (Math.floor(m_SelectedCellAbilityClip.m_CellID/6 * i_Cell.i_ScrollBar.maxPosition)) : 0;
}

/// Refreshes and redraws the entire skillwheel
function RefreshSkillWheel()
{
    FillAbilityClips(m_SelectedAbilityWheel.GetSelectedCell());
    m_SelectedAbilityWheel.CalculateCompletion();
    m_SelectedAbilityWheel.Redraw();
    //Redrawing the tempalates
    m_SelectedAbilityWheel.DrawBackground();
    m_SelectedAbilityWheel.DrawTemplates();
    UpdateTotalSkillpoints();
    UpdateHiveCompletion();
}

function SlotFeatUntrained()
{
    RefreshSkillWheel();
}

function SlotFeatTrained(featID:Number)
{
    if (m_Character.GetStat(_global.Enums.Stat.e_GmLevel) == 0)
    {
        var feat:FeatData = FeatInterface.m_FeatList[featID];
        if (feat != undefined && !feat.m_AutoTrain)
        {
            var aquiredClip:MovieClip = this.attachMovie("AquiredAbilityClip", "i_AquiredAbilityClip", this.getNextHighestDepth() );
            
            //Find the "center" of the skillhive in this's coordinates
            var centerPos:Point = new Point( 0, 0 );
            m_SelectedAbilityWheel.localToGlobal(centerPos);
            this.globalToLocal(centerPos);
            aquiredClip._x = (centerPos.x) - aquiredClip._width / 2;
            aquiredClip._y = (centerPos.y) - aquiredClip._height / 2;

            aquiredClip.i_MainText.text = LDBFormat.LDBGetText("SkillhiveGUI", "AbilityPurchased");
            aquiredClip.i_AbilityText.text = "\"" + feat.m_Name + "\"";
            
            var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( feat.m_Spell, 0 );
            var desc:String = "";
            for (var i:Number = 0; i < tooltipData.m_Descriptions.length; i++)
            {
                if (tooltipData.m_Descriptions[i] != undefined)
                {
                    desc += tooltipData.m_Descriptions[i];
                }
            }
            aquiredClip.i_DescriptionText.htmlText = Utils.SetupHtmlHyperLinks( desc, "_root.skillhive.SlotHyperLinkClicked", true );
            
            
            aquiredClip.i_OkButton.onRelease = function()
            {
                this._parent.removeMovieClip();
            }
            //Utils.PlayFeedbackSound("sfx/gui/gui_skill_wheel_buy_power.wav")
        }
    }
    
    RefreshSkillWheel();
    m_PowerInventory.UpdateSearch();

    var decks:Array = SkillWheel.m_FactionSkillTemplates[m_Character.GetStat(_global.Enums.Stat.e_PlayerFaction)];

    for (var i:Number = 0; i < decks.length; i++)
    {
        if (SkillHiveFeatHelper.DeckContainsFeat(decks[i], featID))
        {
            if (SkillHiveFeatHelper.DeckIsComplete(decks[i]))
            {
                var deckName:String = LDBFormat.LDBGetText("SkillhiveGUI", decks[i].m_Id);
                var rewardMessage:String = LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", "DeckCompletedFifo"), deckName);
                var claimMessage:String = LDBFormat.LDBGetText("SkillhiveGUI", DeckClaimFifo);
                
                com.GameInterface.Chat.SignalShowFIFOMessage.Emit(rewardMessage, 0);
                com.GameInterface.Chat.SignalShowFIFOMessage.Emit(claimMessage, 0)
            }
        }
    }
}


/** PASSIVE / ACTIVE BAR FUNCTIONALITY **/

function ShowPassiveBar()
{
    if (!m_PassiveBarVisible)
    {
        SlotToggleVisibilityPassiveBar();
    }
}

function ShowActiveBar()
{
    if (!m_ActiveBarVisible)
    {
        SlotToggleVisibilityActiveBar();
    }
}

function SlotDragBegin( event:Object )
{
    if (event.data.type == "skillhive_active")
    {
        ShowActiveBar();  
        i_AbilityBars.i_ActiveAbilityBar.ToggleHighlightTopFrame(true);
    }
    else if (event.data.type == "skillhive_passive")
    {
        ShowPassiveBar();  
        i_AbilityBars.i_PassiveAbilityBar.ToggleHighlightTopFrame(true);
    }
}

function SlotToggleVisibilityPassiveBar( snap:Boolean )
{
    m_PassiveBarVisible = !m_PassiveBarVisible;
    
    var newY:Number = 0;
    if (!m_PassiveBarVisible)
    {
        newY += (i_AbilityBars.i_PassiveAbilityBar._height - i_AbilityBars.i_PassiveAbilityBar.GetTopFrameHeight());
    }
    if (snap)
    {
        i_AbilityBars.i_PassiveAbilityBar._y = newY;
    }
    else
    {
        i_AbilityBars.i_PassiveAbilityBar.tweenTo( 0.5, { _y:newY }, Regular.easeOut );
        i_AbilityBars.i_PassiveAbilityBar.onTweenComplete = function(){};
    }
    Log.Info2("SkillHive", "newY: " + newY + ", topframe get height: " + i_AbilityBars.i_PassiveAbilityBar.GetTopFrameHeight() + ", m_PassiveBarVisible: " + m_PassiveBarVisible+", height: "+i_AbilityBars.i_PassiveAbilityBar._height+", ypos: "+i_AbilityBars.i_PassiveAbilityBar._y);
}

function SlotToggleVisibilityActiveBar( snap:Boolean )
{
    m_ActiveBarVisible = !m_ActiveBarVisible;

    var newY:Number = 0;

    if (!m_ActiveBarVisible)
    {
        newY += (i_AbilityBars.i_ActiveAbilityBar._height - i_AbilityBars.i_ActiveAbilityBar.GetTopFrameHeight());
    }
    
    if (snap)
    {
        i_AbilityBars.i_ActiveAbilityBar._y = newY;
    }
    else
    {
        i_AbilityBars.i_ActiveAbilityBar.tweenTo( 0.5, { _y:newY }, Regular.easeOut );
        i_AbilityBars.i_ActiveAbilityBar.onTweenComplete = function(){};
    }
}

/** SCROLLBAR FUNCTIONALITY **/

function CreateScrollbar(clip:MovieClip, callback:String)
{
    Log.Info2("SkillHive", "CreateScrollbar( " + clip + ", " + callback + " ) index = "+clip.index+" width = "+m_PanelOpenWidths[ clip.index ] );
    var visibleRect:Object = Stage["visibleRect"];
    var stageHeight:Number = 900; // why??
    if (visibleRect != undefined)
    {
        stageHeight = visibleRect.height;
    }
    
    var scrollBackground:MovieClip = clip.attachMovie("TabScrollBarBackground", "i_ScrollBackground", clip.getNextHighestDepth() );
    scrollBackground._x = 288; // m_PanelOpenWidths[ clip.index ] - 12 //m__PaneOpenWidth;
    scrollBackground._y = PANE_HEADER_OFFSET;
    scrollBackground._height = stageHeight;
    
    var scrollbar:MovieClip = clip.attachMovie("ScrollBar", "i_ScrollBar", clip.getNextHighestDepth() );
    scrollbar._y = (PANE_HEADER_OFFSET - scrollbar.upArrow._height);
    scrollbar._x = 290; // - m_PanelOpenWidths[ clip.index ] - 10;
    
    scrollbar.setScrollProperties(1, 0, 0); 
    scrollbar._height = (stageHeight - PANE_HEADER_OFFSET + (2 * scrollbar.upArrow._height));
    scrollbar.addEventListener("scroll", this, callback);
    scrollbar.position = 1;
    scrollbar.trackMode = "scrollPage";
    scrollbar.trackScrollPageSize = 4;
    scrollbar.disableFocus = true;
}


function UpdateScrollBar(id:Number)
{
    Log.Info2("SkillHive", " UpdateScrollBar("+id+")");
    
    var paneObject:Object = m_SidePanesArray[id];
    var pane:MovieClip = paneObject.mc;
    var height:Number = Stage["visibleRect"].height;
    var endScroll:Number = 0;
    var maxScroll:Number = 0;
    if (id == CELL)
    {
        pane.i_ScrollBar._height = (height - PANE_HEADER_OFFSET + (2 * i_Cell.i_ScrollBar.upArrow._height));
        pane.i_ScrollBar._y = (PANE_HEADER_OFFSET - i_Cell.i_ScrollBar.upArrow._height);
        if ( (m_CellAbilitiesHeight > height) && paneObject.isOpen )
        {
            endScroll = m_CellAbilitiesHeight - height;
            maxScroll = Math.ceil(endScroll / SCROLL_INTERVAL);
            pane.i_ScrollBackground._visible = true;
        }
        else
        {
            pane.i_CellContent._y = 0
            pane.i_ScrollBar.position  = 0;
            pane.i_ScrollBackground._visible = false;
        }
    }
    pane.i_ScrollBar.setScrollProperties(SCROLL_INTERVAL, 0, maxScroll);
}

function RemoveScrollBar()
{
    if (i_Cell.i_ScrollBar)
    {
        i_Cell.i_ScrollBar.removeMovieClip();
    }
}

function onMouseWheel(delta:Number)
{
    var scroll:Number = delta * 2;
    i_Cell.i_ScrollBar.position = i_Cell.i_ScrollBar.position - scroll;
}

/// when interacting with the scrollbar
function OnCellScrollbarUpdate(event:Object)
{
    /// update the position of the abilities
    var pos:Number = event.target.position;
    i_Cell.i_CellContent._y = -(pos * SCROLL_INTERVAL);
    Selection.setFocus(null);
}


function SlotCellAbilityPress(buttonIndex:Number)
{
    CellAbilityPress(this, buttonIndex);
}

function SlotCellMouseDown()
{
    for (var i:Number = 0; i < m_CellAbilities.length; i++)
    {
        if (m_CellAbilities[i].i_Text.hitTest(_root._xmouse, _root._ymouse))
        {
            CellAbilityPress(m_CellAbilities[i].i_Text, 1);
        }
        else if (m_CellAbilities[i].i_DetailedText.hitTest(_root._xmouse, _root._ymouse))
        {
            CellAbilityPress(m_CellAbilities[i].i_DetailedText, 1);
        }
    }
    
}
function SlotCellMouseUp()
{
    if (!m_HyperLinkClicked && (m_CurrentEquipPopupHolder == undefined || !m_CurrentEquipPopupHolder.hitTest(_root._xmouse, _root._ymouse)))
    {
        for (var i:Number = 0; i < m_CellAbilities.length; i++)
        {
            if (m_CellAbilities[i].i_Text.hitTest(_root._xmouse, _root._ymouse))
            {
                CellAbilityRelease(m_CellAbilities[i].i_Text, 1);
            }
            else if (m_CellAbilities[i].i_DetailedText.hitTest(_root._xmouse, _root._ymouse))
            {
                CellAbilityRelease(m_CellAbilities[i].i_DetailedText, 1);
            }
        }
    }
    m_HyperLinkClicked = false;
}

function SlotHyperLinkClicked(target:String)
{
    com.GameInterface.Tooltip.Tooltip.SlotHyperLinkClicked(target);
    m_HyperLinkClicked = true;
}


function CellAbilityPress(target, buttonIndex)
{
    if (buttonIndex == 1 && m_SidePanesArray[CELL].isOpen && !m_IsDraggingAbility)
    {
        target._parent.m_HitPos = new Point(_root._xmouse, _root._ymouse);
        target._parent.m_WasHit = true;
    }
}

function SlotCellAbilityRelease(buttonIndex:Number)
{
    CellAbilityRelease(this, buttonIndex);
}

function SlotAbilityTextRelease(buttonIndex:Number)
{
    if (buttonIndex == 2)
    {
        CellAbilityRelease(this, buttonIndex);
    }
}

function CellAbilityRelease(target, buttonIndex:Number)
{
    if (buttonIndex == 1 && !m_IsDraggingAbility)
    {
        SelectCellAbility(target._parent.m_CellID, true);
    } 
    else if (buttonIndex == 2)
    {
        EquipAbilityInFirstFreeSlot(target._parent.m_Feat.m_Spell, target._parent.m_Feat.m_SpellType);
    }
}

function EquipAbilityInFirstFreeSlot(spellId:Number, spellType:Number)
{
    if (IsPassiveAbility(spellType))
    {
        var nextFreeSlot:Number = Spell.GetNextFreePassiveSlot();
        if (spellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
        {
            nextFreeSlot = 7;
        }
        if (nextFreeSlot >= 0)
        {
            Spell.EquipPassiveAbility( nextFreeSlot, spellId);
        }
    }
    else if(IsActiveAbility(spellType))
    {
        var slot:Number = -1;
        if (spellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
        {
            slot = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot + 7;
        }
        Shortcut.AddSpell( slot, spellId);
    }
}

function SlotUpdateCellPanelTimer()
{
    _global.setTimeout( Delegate.create(this, SlotUpdateCellPanel), 200);
}

function SlotUpdateCellPanel()
{
    FillAbilityClips(m_SelectedAbilityWheel.GetSelectedCell());
}

/// Called when an ability has been selected. This function will expand/close 
/// the selected ability, and interpolate the other abilities
///@param abilityIdx [in] the index of the ability pressed in the cell ( 0 -> NumAbilities)
///@param toggle [in] will deselect an ability if it is already open
function SelectCellAbility(abilityIdx:Number, toggle:Boolean)
{
    if (getTimer() - m_LastClickedCellAbility > 100)
    {
        m_LastClickedCellAbility = getTimer();
        var cellAbilityClip:MovieClip = GetCellAbilityClip(abilityIdx);
        
        if (m_SelectedCellAbilityClip == cellAbilityClip)
        {
            if (!toggle)
            {
                return;
            }
            DeselectAbility(cellAbilityClip, false);
        }
        else
        {        
            if (m_SelectedCellAbilityClip != undefined)
            {
               DeselectAbility(m_SelectedCellAbilityClip, false);
            }
            SelectAbility(cellAbilityClip, false);
        }
        
        InterpolateAbilities(false);
    }
}

/// Interpolates/tweens all abilities to the correct position
function InterpolateAbilities(snap:Boolean)
{
    var newY:Number = PANE_HEADER_OFFSET;
    for (var i:Number = 0; i < m_CellAbilities.length; i++)
    {
        if (newY != m_CellAbilities[i]._y)
        {
            if (snap)
            {
                m_CellAbilities[i]._y = newY;
            }
            else
            {
                m_CellAbilities[i].tweenTo(0.4, { _y:newY }, Regular.easeOut);
            }
        }

        newY += m_CellAbilities[i].m_DesiredHeight;
    } 
    
    m_CellAbilitiesHeight = newY;
    
    UpdateScrollBar(CELL);
}

function SelectAbility(abilityClip:MovieClip, snap:Boolean)
{
    //Update selected attributes
    m_SelectedCellAbilityClip = abilityClip;
    m_SelectedFeat = abilityClip.m_Feat;
    
    // Must set backgroundscale to 100 in case we are in the middle of a tween down. This to be
    // able to calculate the abilityClip._height correctly before and after adding the extended text
    var oldYScale:Number = abilityClip.i_Background._yscale;
    
    abilityClip.i_Background._yscale = 100;
    abilityClip.i_Cover._yscale = 100;
    abilityClip.i_AbilitySelectedCellBorder._yscale = 100;
    var oldHeight:Number = abilityClip._height;
    
    //Make the detailed text, and start tweening in new text and out old text
    if ( m_SelectedFeat != undefined && m_SelectedFeat.m_Spell != 0)
    {
        abilityClip.i_DetailedText.i_Name.text = abilityClip.m_Feat.m_Name;
        abilityClip.i_DetailedText.i_Type.text = TooltipUtils.GetSpellTypeName(abilityClip.m_Feat.m_SpellType, ProjectSpell.GetSpellAttackType(abilityClip.m_Feat.m_Spell));
        
        
        if (abilityClip.i_DetailedText.m_TemplateClip != undefined)
        {
            abilityClip.i_DetailedText.m_TemplateClip.removeMovieClip();
        }
        if (IsFeatInTemplate(m_SelectedFeat.m_Id))
        {
            var templateClipName:String = GetTemplateClipName(m_SelectedFeat);
            var templateClip:MovieClip = abilityClip.i_DetailedText.attachMovie(templateClipName, "m_TemplateClip", abilityClip.i_DetailedText.getNextHighestDepth());
            templateClip._y = 5;
            abilityClip.i_DetailedText.i_Name._x = templateClip._width;
        }
        else
        {
            abilityClip.i_DetailedText.i_Name._x = 0;
        }
        
        CreateDetailedTextClip( abilityClip.i_DetailedText.i_DetailedContent, m_SelectedFeat.m_Spell, m_SelectedFeat.m_SpellType );
        
        if (snap)
        {
            abilityClip.i_Text._visible = false;
            abilityClip.i_DetailedText._visible = true;
            abilityClip.i_Text._alpha = 0;
            abilityClip.i_DetailedText._alpha = 100;
        }
        else
        {
            abilityClip.i_DetailedText._visible  = true;
            abilityClip.i_DetailedText.tweenTo(0.4, { _alpha:100 }, Regular.easeOut);
            abilityClip.i_DetailedText.onTweenComplete = undefined;
            
            abilityClip.i_Text.tweenTo(0.2, { _alpha:0 }, Regular.easeOut);
            abilityClip.i_Text.onTweenComplete = function()
            {
                this._visible = false;
            }
        }
    }
    
    //Updating the desired size
    var factor:Number           = (abilityClip._height + 45) / oldHeight;
    abilityClip.m_DesiredHeight = (abilityClip.i_Background._height * factor);
        
    //Setting the backgroundscale back to its original value to get a smooth transition
    abilityClip.i_Background._yscale                = oldYScale;
    abilityClip.i_Cover._yscale                     = oldYScale;
    abilityClip.i_AbilitySelectedCellBorder._yscale = oldYScale;
    
    //Tween the movieclip
    if (snap)
    {
        abilityClip.i_Background._yscale = 100 * factor;
        abilityClip.i_Cover._yscale = 100 * factor;
    }
    else
    {
        abilityClip.i_Background.tweenTo( 0.4, { _yscale:100 * factor }, Regular.easeOut);
        abilityClip.i_Cover.tweenTo( 0.4, { _yscale:100 * factor }, Regular.easeOut);
    }
    abilityClip.i_Divider._visible = false;

    //Hide the ability cost, as that will show the cost in the buy menu
    abilityClip.i_AbilitySelectedCellBorder._visible = true;
    abilityClip.i_AbilitySelectedCellBorder._alpha = 0;
    if (snap)
    {
        abilityClip.i_AbilitySelectedCellBorder._yscale = 100 * factor;
        abilityClip.i_AbilitySelectedCellBorder._alpha = 100;
        
        abilityClip.m_ExpandButton._rotation = -180
        abilityClip.m_ExpandButton._y = abilityClip.m_DesiredHeight - 45;
    }
    else
    {
        abilityClip.i_AbilitySelectedCellBorder.tweenTo( 0.4, { _yscale:100 * factor, _alpha:100 }, Regular.easeOut );
        abilityClip.m_ExpandButton.tweenTo(0.4, { _rotation:-180, _y:abilityClip.m_DesiredHeight - 45 }, Regular.easeOut);
    }
    abilityClip.i_AbilitySelectedCellBorder.onTweenComplete = undefined;
    
    var tweenCompleteFunction = function()
    {
        if (m_SelectedFeat.m_Trained || m_SelectedFeat.m_CanTrain )
        {   
            //Place it directly under the button that was pressed
            var p:Point = new Point(80, abilityClip._height - 35);
            abilityClip.localToGlobal(p);
            i_Cell.i_CellContent.globalToLocal(p);
            
            m_CurrentEquipPanel = i_Cell.i_CellContent.attachMovie("EquipPanel", "i_EquipPanel", i_Cell.i_CellContent.getNextHighestDepth(), { _x: p.x, _y: p.y } );
            m_CurrentEquipPanel.SetData(m_Character, m_SelectedFeat.m_Cost);
            
            m_CurrentEquipPanel.SetShouldUnequip(m_SelectedFeat.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility || m_SelectedFeat.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility);
            m_CurrentEquipPanel.SignalBuyPressed.Connect(BuyAbility, this);
            m_CurrentEquipPanel.SignalRefundPressed.Connect(RefundAbility, this);
            m_CurrentEquipPanel.SignalEquipPressed.Connect(EquipAbility, this);
            m_CurrentEquipPanel.SignalUnEquipPressed.Connect(UnEquipAbility, this);
            
            if (m_SelectedFeat.m_CanTrain)
            {
                abilityClip.m_SP._visible = false;
                UpdateAbilityCostButton(m_CurrentEquipPanel.m_SP, m_SelectedFeat.m_Cost, false);
            }
            m_CurrentEquipPanel.Update(m_SelectedFeat.m_Trained, (m_SelectedFeat.m_Refundable && ProjectFeatInterface.CanRefund()), m_SelectedFeat.m_Spell);
                
            
        }
        
        abilityClip.i_Background.onTweenComplete = undefined;
    }
    
    if (snap)
    {
        tweenCompleteFunction();
    }
    else
    {
        /// tween the selected line around
        abilityClip.i_Background["ref"] = this;
        abilityClip.i_Background.onTweenComplete = tweenCompleteFunction;
    }
}

function DeselectAbility(abilityClip:MovieClip, snap:Boolean)
{
    if (m_DetailedText != undefined)
    {
        m_DetailedText.removeMovieClip();   
        m_DetailedText = undefined;
    }
    abilityClip.m_SP._visible = true;
    
    if (abilityClip.m_Feat != undefined)
    {
        if (snap)
        {
            abilityClip.i_Text._visible = true;
            abilityClip.i_DetailedText._visible = false;
            abilityClip.i_Text._alpha = 100;
            abilityClip.i_DetailedText._alpha = 0;
        }
        else
        {
            abilityClip.i_Text._visible = true;
            abilityClip.i_Text.tweenTo(0.4, { _alpha:100 }, Regular.easeOut);
            abilityClip.i_Text.onTweenComplete = undefined
            
            abilityClip.i_DetailedText.tweenTo(0.2, { _alpha:0 }, Regular.easeOut);
            abilityClip.i_DetailedText.onTweenComplete = function()
            {
                this._visible = false;
            }
        }

    }
    if (snap)
    {
        abilityClip.i_Cover._yscale = 100;
        
        abilityClip.m_ExpandButton._rotation = 0;
        abilityClip.m_ExpandButton._y = 110;
        abilityClip.i_Background._yscale = 100;
        abilityClip.i_Background._alpha = 0;
        abilityClip.i_Divider._visible = true;
        
    }
    else
    {
        abilityClip.i_Cover.tweenTo( 0.4, { _yscale:100 }, Regular.easeOut);
        
        abilityClip.m_ExpandButton.tweenTo(0.4, { _rotation:0, _y:110 }, Regular.easeOut);
        
        abilityClip.i_Background.tweenTo( 0.4, { _yscale:100, _alpha:0 }, Regular.easeOut);
        abilityClip.i_Background.onTweenComplete = function()
        {
            abilityClip.i_Divider._visible = true;
            this.onTweenComplete = undefined;
        }
        
    }

    if ( abilityClip.i_AbilitySelectedCellBorder._visible )
    {
        if (snap)
        {
            abilityClip.i_AbilitySelectedCellBorder._yscale = 100;
            abilityClip.i_AbilitySelectedCellBorder._alpha = 0;
            abilityClip.i_AbilitySelectedCellBorder._visible = false;
        }
        else
        {
            abilityClip.i_AbilitySelectedCellBorder.tweenTo(  0.4, { _yscale:100, _alpha:0 }, Regular.easeOut )
            abilityClip.i_AbilitySelectedCellBorder.onTweenComplete = function()
            {
                this._visible = false;
            }
        }
    }
     
    abilityClip.m_DesiredHeight = m_DefaultCellAbilityHeight;
    
    if (m_CurrentEquipPanel != undefined)
    {
        m_CurrentEquipPanel.removeMovieClip();
        m_CurrentEquipPanel = undefined;
    }
    m_SelectedCellAbilityClip = undefined;
}

function CreateDetailedTextClip(parent:MovieClip, spellId:Number, spellType:Number)
{
    m_DetailedText = parent.createEmptyMovieClip("i_DetailedTextClip", parent.getNextHighestDepth());
    
    //To be able to get the advanced tooltip even if its turned off.
    var advanced:Boolean = m_AdvancedTooltipMonitor.GetValue();    
    if (!advanced)
    {
        m_UpdateOnAdvancedChanged = false;
        m_AdvancedTooltipMonitor.SetValue(true);
    }
    
    var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( spellId, 0 );
    
    if (!advanced)
    {
        m_AdvancedTooltipMonitor.SetValue(false);
        m_UpdateOnAdvancedChanged = true;
    }
    
    var y:Number = 0;
    if (spellType == _global.Enums.SpellItemType.eMagicSpell || spellType == _global.Enums.SpellItemType.eEliteActiveAbility || spellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
    {
        var pushY:Boolean = false;
        var xPos:Number = 0.0;
        if (tooltipData.m_CastTime != undefined)
        {
            m_DetailedText.attachMovie("CastTimeIcon", "i_CastTimeIcon", m_DetailedText.getNextHighestDepth(), { _y:y , _x:xPos } )
            xPos += m_DetailedText.i_CastTimeIcon._width;
            m_DetailedText.attachMovie("CastTimerTextLabel", "i_CastTimeText", m_DetailedText.getNextHighestDepth(), { _y:y, _x:xPos } )
            m_DetailedText.i_CastTimeText.autoSize = true;
            if (tooltipData.m_CastTime > 0)
            {
                m_DetailedText.i_CastTimeText.text = com.Utils.Format.Printf( "%.1f", tooltipData.m_CastTime);
            }
            else
            {
                m_DetailedText.i_CastTimeText.text = LDBFormat.LDBGetText("ItemInfoGUI", "Instant");
            }
            var width = m_DetailedText.i_CastTimeText.textField.getTextFormat().getTextExtent(m_DetailedText.i_CastTimeText.text).textFieldWidth;
            xPos += width
            pushY = true;
        }
        if(tooltipData.m_RecastTime != undefined)
        {
            m_DetailedText.attachMovie("RecastTimeIcon", "i_RecastTimeIcon", m_DetailedText.getNextHighestDepth(), { _y:y, _x:xPos } )
            xPos += m_DetailedText.i_RecastTimeIcon._width;
            m_DetailedText.attachMovie("CastTimerTextLabel", "i_RecastTimeText", m_DetailedText.getNextHighestDepth(), { _y:y, _x:xPos } )
            m_DetailedText.i_RecastTimeText.autoSize = true;
            if (tooltipData.m_RecastTime > 0)
            {
                m_DetailedText.i_RecastTimeText.text = com.Utils.Format.Printf( "%.1f", tooltipData.m_RecastTime);
            }
            else
            {
                m_DetailedText.i_RecastTimeText.text = LDBFormat.LDBGetText("ItemInfoGUI", "Instant");
            }
            pushY = true;
        }
        if (pushY)
        {
            y += 20;
        }
    }
    
    var descLabelView = m_DetailedText.attachMovie( "DetailedDescriptionTextLabel", "i_Description", m_DetailedText.getNextHighestDepth(), { _y:y } );
    descLabelView._width = 256;
    descLabelView.autoSize = "left";
    descLabelView.textField.html = true;

    if ( tooltipData.m_Descriptions != undefined && tooltipData.m_Descriptions.length > 0 )
    {
        var description:String;
        for (var i:Number = 0; i < tooltipData.m_Descriptions.length; i++)
        {
            if (tooltipData.m_Descriptions[i] == "<hr>")
            {
                var divider:MovieClip = m_DetailedText.attachMovie("DetailedTextDivider", "i_Divider_"+i, m_DetailedText.getNextHighestDepth(), { _y:y, _alpha:50 } );
                y += divider._height+5;
            }
            else
            {
                var descLabelView = m_DetailedText.attachMovie( "DetailedDescriptionTextLabel", "i_Description", m_DetailedText.getNextHighestDepth(), { _y:y } );
                descLabelView._width = 256;
                descLabelView.autoSize = "left";
                descLabelView.textField.html = true;
                
                descLabelView.htmlText = Utils.SetupHtmlHyperLinks( tooltipData.m_Descriptions[i], "_root.skillhive.SlotHyperLinkClicked", true );
                descLabelView._height = descLabelView.textField.textHeight + 5;
                y += descLabelView._height;
            }
        }
    }
    
    if (tooltipData.m_WeaponTypeRequirement != undefined && tooltipData.m_WeaponTypeRequirement != 0)
    {
        var requirementLabel = m_DetailedText.attachMovie( "DetailedDescriptionTextLabel", "i_Description", m_DetailedText.getNextHighestDepth(), { _y:y } );
        requirementLabel._width = 256;
        requirementLabel.autoSize = "left";
        requirementLabel.htmlText = "<font color='#CCCCCC'>" +  TooltipUtils.GetWeaponRequirementString(tooltipData.m_WeaponTypeRequirement) +"</font>";
        requirementLabel._height = requirementLabel.textField.textHeight + 5;
        y += requirementLabel._height;
    }
    
}

/** FUNCTIONALITY FOR ABILITY BUTTONS **/

function SlotBuyAbility(featID:Number)
{
    m_Character.AddEffectPackage( "sound_fxpackage_GUI_purchase_power.xml" );
    TrainFeat(featID);
}

function BuyAbility()
{
    
    m_Character.AddEffectPackage( "sound_fxpackage_GUI_purchase_power.xml" );
    TrainFeat(m_SelectedCellAbilityClip.m_Feat.m_Id);
}

function TrainFeat(featID:Number)
{
    if (FeatInterface.TrainFeat(featID))
    {
        if (m_CurrentEquipPanel != undefined)
        {
            m_CurrentEquipPanel.Update(true, ProjectFeatInterface.CanRefund(), m_SelectedFeat.m_Spell);
        }
        FeatInterface.m_FeatList[featID].m_Refundable = true;
    }
}

function RefundAbility()
{
    var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("SkillhiveGUI", "RefundAbilityQuestion"), m_SelectedCellAbilityClip.m_Feat.m_Name);
    m_ActiveDialog = new DialogIF( dialogText, Enums.StandardButtons.e_ButtonsYesNo, "RefundAbility" );
    m_ActiveDialog.SignalSelectedAS.Connect( SlotRefundAbility, this );
    m_ActiveDialog.Go(m_SelectedCellAbilityClip.m_Feat.m_Id); // <- the featid is userdata.
}

function SlotRefundAbility(buttonID:Number, featID:Number )
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        if (FeatInterface.RefundFeat(featID))
        {
            m_CurrentEquipPanel.Update(false, false, FeatInterface.m_FeatList[featID].m_Spell);
            FeatInterface.m_FeatList[featID].m_Refundable = false;
        }
    }
    m_ActiveDialog = undefined;
}


function UnEquipAbility()
{
    if (IsPassiveAbility(m_SelectedFeat.m_SpellType))
    {
        i_AbilityBars.i_PassiveAbilityBar.UnEquipPassive(m_SelectedFeat.m_Spell);
    }
    else
    {
        i_AbilityBars.i_ActiveAbilityBar.UnEquipActive(m_SelectedFeat.m_Spell);
    }
}

function EquipAbility()
{
    if (m_CurrentEquipPopupHolder != undefined)
    {
        RemoveEquipPopup();
    }
    else
    {
        if (m_SelectedFeat.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
        {
            i_AbilityBars.i_ActiveAbilityBar.EquipActive(7, m_SelectedFeat.m_Spell);
            ShowActiveBar();
        }
        else if (m_SelectedFeat.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
        {
            i_AbilityBars.i_PassiveAbilityBar.EquipPassive(7, m_SelectedFeat.m_Spell);
            ShowPassiveBar();
        }
        else
        {
            m_CurrentEquipPopupHolder = i_Cell.i_CellContent.createEmptyMovieClip( "m_CurrentEquipPopupMenu", i_Cell.i_CellContent.getNextHighestDepth() );
            m_CurrentEquipPopupMenu = SkillhiveEquipPopup(m_CurrentEquipPopupHolder.attachMovie("EquipPopup", "m_Popup", m_CurrentEquipPopupHolder.getNextHighestDepth()));
            
            m_SelectedCellAbilityClip.i_Background.onRelease = null;
            
            //Place it directly under the button that was pressed
            var p:Point = new Point(0, -m_CurrentEquipPanel.m_FirstButton._height - 10);
            m_CurrentEquipPanel.m_FirstButton.localToGlobal(p);
            i_Cell.i_CellContent.globalToLocal(p);
            
            m_CurrentEquipPopupHolder._x = p.x;
            m_CurrentEquipPopupHolder._y = p.y;
            m_CurrentEquipPopupHolder._xscale = 70;
            m_CurrentEquipPopupHolder._yscale = 70;
            
            m_CurrentEquipPopupHolder.onMouseUp = function()
            {
                if (!m_CurrentEquipPanel.m_FirstButton.hitTest(_root._xmouse, _root._ymouse) && !m_CurrentEquipPopupMenu.hitTest(_root._xmouse, _root._ymouse))
                {
                    RemoveEquipPopup();
                }
            }
            m_CurrentEquipPopupMenu.SignalEquipButtonRollOver.Connect( SlotEquipButtonRollOver, this);
            m_CurrentEquipPopupMenu.SignalEquipButtonRollOut.Connect( SlotEquipButtonRollOut, this);
            m_CurrentEquipPopupMenu.SignalEquipButtonPressed.Connect( SlotEquipButtonPressed, this);
            
            var strokeIndex:Number = 0;
            
            if (IsPassiveAbility(m_SelectedFeat.m_SpellType))
            {
                m_CurrentEquipPopupMenu.SetColors(i_AbilityBars.i_PassiveAbilityBar.GetAbilityColors());
                strokeIndex -= PASSIVE_SHORTCUT_FIRST_SLOT;
                ShowPassiveBar();
            }
            else if (IsActiveAbility(m_SelectedFeat.m_SpellType))
            {
                m_CurrentEquipPopupMenu.SetColors(i_AbilityBars.i_ActiveAbilityBar.GetAbilityColors());
                strokeIndex -= ACTIVE_SHORTCUT_FIRST_SLOT;
                ShowActiveBar();
            }
            
            var abilitiesArray:Array = GearManager.GetCurrentCharacterBuild().m_AbilityArray;
            var selectedSpellDataID:Number = Spell.GetSpellData(m_SelectedCellAbilityClip.m_Feat.m_Spell).m_Id;

            for (var i:Number = 0; i < abilitiesArray.length; i++)
            {
                if (selectedSpellDataID == abilitiesArray[i].m_SpellData.m_Id)
                {
                    strokeIndex += abilitiesArray[i].m_Position;        
                }
            }        
            
            m_CurrentEquipPopupMenu.SetStrokePosition(strokeIndex);
        }
    }
}

function SlotEquipButtonRollOver(buttonId:Number)
{
    if (IsPassiveAbility(m_SelectedFeat.m_SpellType))
    {
        i_AbilityBars.i_PassiveAbilityBar.HighlightSlot(buttonId);
    }
    else if (IsActiveAbility(m_SelectedFeat.m_SpellType))
    {
        i_AbilityBars.i_ActiveAbilityBar.HighlightSlot(buttonId);
    }
}

function SlotEquipButtonRollOut(buttonId:Number)
{
    if (IsPassiveAbility(m_SelectedFeat.m_SpellType))
    {
        i_AbilityBars.i_PassiveAbilityBar.StopHighlightSlot(buttonId);
    }
    else if (IsActiveAbility(m_SelectedFeat.m_SpellType))
    {
        i_AbilityBars.i_ActiveAbilityBar.StopHighlightSlot(buttonId);
    }
}

function SlotEquipButtonPressed(buttonId:Number)
{
    if (IsPassiveAbility(m_SelectedFeat.m_SpellType))
    {
        i_AbilityBars.i_PassiveAbilityBar.EquipPassive(buttonId, m_SelectedFeat.m_Spell);
    }
    else (IsActiveAbility(m_SelectedFeat.m_SpellType))
    {
        i_AbilityBars.i_ActiveAbilityBar.EquipActive(buttonId, m_SelectedFeat.m_Spell);
    }

    SlotEquipButtonRollOut(buttonId);
    RemoveEquipPopup();
}

function RemoveEquipPopup()
{
    _global.setTimeout(Delegate.create(this, SlotRemoveEquipPopup), 10);
}

function SlotRemoveEquipPopup()
{
    if (m_CurrentEquipPopupHolder != undefined)
    {
        m_CurrentEquipPopupHolder.removeMovieClip();
    }
    m_CurrentEquipPopupHolder = undefined;
    m_CurrentEquipPopupMenu = undefined;
}

function UpdateBreadcrumbPath()
{
    for (var i:Number = 0; i < m_BreadcrumbLabelArray.length; i++)
    {
        if (m_BreadcrumbLabelArray[i].IsInteractable())
        {
            m_BreadcrumbLabelArray[i].SignalLabelPressed.Disconnect(SlotBreadcrumbLabelPressed, this)
        }
        m_BreadcrumbLabelArray[i].removeMovieClip();
    }
    
    
    m_BreadcrumbLabelArray = m_SelectedAbilityWheel.GetBreadcrumbArray(m_BreadcrumbContent);
    
    for (var i:Number = 0; i < m_BreadcrumbLabelArray.length; i++)
    {
        if (m_BreadcrumbLabelArray[i].IsInteractable())
        {
            m_BreadcrumbLabelArray[i].SignalLabelPressed.Connect(SlotBreadcrumbLabelPressed, this);
        }
    }
    
    var mainLabel = m_BreadcrumbContent.attachMovie("BreadcrumbLabel", "", m_BreadcrumbContent.getNextHighestDepth());
    if (m_BreadcrumbLabelArray.length > 0)
    {
        var mainSplitLabel = m_BreadcrumbContent.attachMovie("BreadcrumbLabel", "", m_BreadcrumbContent.getNextHighestDepth());
        mainSplitLabel.text = " / ";
        mainSplitLabel.autoSize = "center";
        m_BreadcrumbLabelArray.push(mainSplitLabel);
    }
    mainLabel.text = m_SelectedAbilityWheel.GetShortName();
    mainLabel.autoSize = "center";
    mainLabel.SetLinkedMovieClip(undefined);
    mainLabel.SignalLabelPressed.Connect(SlotBreadcrumbLabelPressed, this);
    m_BreadcrumbLabelArray.push(mainLabel);
    
    //Spread them on enterframe, as the width of the labels isnt set before after loading
    mainLabel.onEnterFrame = function()
    {
        var x:Number = 0;
        for (var i:Number = 0; i < m_BreadcrumbLabelArray.length; i++)
        {
            m_BreadcrumbLabelArray[i]._x = x
            x += m_BreadcrumbLabelArray[i]._width;
        }
        m_BreadcrumbContent._x = i_Help._x - m_BreadcrumbContent._width - 10;
        this.onEnterFrame = null;
    }
    
    m_BreadcrumbContent._x = i_Help._x - m_BreadcrumbContent._width - 10;
    m_BreadcrumbContent._y = i_Help._y;
}

function SlotBreadcrumbLabelPressed(selectedCluster:MovieClip)
{   
    m_SelectedAbilityWheel.ZoomToCluster(selectedCluster);
}


function FillAbilityClips(cell:Cell)
{
    i_Cell.i_Tab.i_Text.text = cell.m_Name;

    // Show all abilities.
    m_SelectedCellPowers = cell.m_Abilities;
    UpdateAbilityClips();

}

function UpdateAbilityClips()
{
    DeselectAbility(m_SelectedCellAbilityClip, true);
    
    if (m_SelectedCellPowers != undefined)
    {
        for( var i=0; i!=m_SelectedCellPowers.length; i++ )
        {
            var cellAbilityClip:MovieClip = GetCellAbilityClip(i);

            SetupCellAbility(cellAbilityClip, m_SelectedCellPowers[i]);
        }
    }
    
    InterpolateAbilities(true);
    UpdateScrollBar(CELL);
}


function SetupCellAbility(abilityClip:MovieClip, featID:Number)
{
    Log.Info1("SkillHive", "SetupCellAbility()");
            
    var feat:FeatData = FeatInterface.m_FeatList[featID];
    
    //Use this when we actually have feats
    if (feat != undefined)
    {
        abilityClip.i_Text._alpha = 100;
        abilityClip.i_DetailedText._alpha = 0;
        abilityClip.i_Text.i_Name.text = feat.m_Name;
        abilityClip.i_Text.i_Type.text = TooltipUtils.GetSpellTypeName(feat.m_SpellType, ProjectSpell.GetSpellAttackType(feat.m_Spell));
        var description:String = "";
        if (m_ShowAdvancedTooltips)
        {
            description = Spell.GetSpellShortDescription(feat.m_Spell);
        }
        else
        {
            description = Spell.GetSpellStaticDescription(feat.m_Spell);
        }
        abilityClip.i_Text.i_Description.htmlText = Utils.SetupHtmlHyperLinks(description , "_root.skillhive.SlotHyperLinkClicked", true );

        abilityClip.m_Feat = feat;
        
        if (abilityClip.i_Text.m_TemplateClip != undefined)
        {
            abilityClip.i_Text.m_TemplateClip.removeMovieClip();
        }
        if (IsFeatInTemplate(feat.m_Id))
        {
            var templateClipName:String = GetTemplateClipName(feat);
            var templateClip:MovieClip = abilityClip.i_Text.attachMovie(templateClipName, "m_TemplateClip", abilityClip.i_Text.getNextHighestDepth());
            templateClip._y = 5;
            abilityClip.i_Text.i_Name._x = templateClip._width;
        }
        else
        {
            abilityClip.i_Text.i_Name._x = 0;
        }
        
        var weaponRequirement:Number = ProjectSpell.GetWeaponRequirement(feat.m_Spell);
        if (abilityClip.i_WeaponTypeContent.i_WeaponRequirement != undefined)
        {
            abilityClip.i_WeaponTypeContent.i_WeaponRequirement.removeMovieClip();
        }
        if (weaponRequirement > 0 && TooltipUtils.CreateWeaponRequirementsIcon(abilityClip.i_WeaponTypeContent, weaponRequirement, {_xscale:23,_yscale:23,_x:1,_y:1}))
        {
            abilityClip.i_WeaponTypeContent._visible = true;
        }
        else
        {
            abilityClip.i_WeaponTypeContent._visible = false;
        }
        
        var loadListener:Object = new Object();

        loadListener.onLoadError = function(targetMC, errorCode)
        {
            Log.Error("SkillHive", "Failed to load icon for ability " + iconString + " TargetMC: " + targetMC + " ErrorCode:" + errorCode);
        }
        
        //Added some more checks to try to track down the missing icons in SkillHive.
        loadListener.onLoadComplete = function(listenerObject, targetMC)
        {
            Log.Info1("SkillHive", "onLoadComplete() " + iconString + " TargetMC: " + targetMC);
        }                
        loadListener.onLoadInit = function(targetMC)
        {
            Log.Info1("SkillHive", "onLoadInit() TargetMC: " + targetMC);
        } 
        loadListener.onLoadProgress = function(targetMC, loadedBytes, totalBytes)
        {
            Log.Info1("SkillHive", "onLoadProgress() TargetMC: " + targetMC + " LoadedBytes: " + loadedBytes + " TotalBytes:" + totalBytes);
        }              
        loadListener.onLoadStart = function(targetMC, loadedBytes, totalBytes)
        {
            Log.Info1("SkillHive", "onLoadStart() TargetMC: " + targetMC);
        }       
        
        var moviecliploader:MovieClipLoader = new MovieClipLoader();
        moviecliploader.addListener(loadListener);
        
        var iconString:String = Utils.CreateResourceString(abilityClip.m_Feat.m_IconID);
        moviecliploader.loadClip( iconString, abilityClip.m_Icon.m_Content);
        
        abilityClip.m_Icon.m_Content._x = 2;
        abilityClip.m_Icon.m_Content._y = 2;
        abilityClip.m_Icon.m_Content._xscale = abilityClip.m_Icon.m_Background._width - 4;
        abilityClip.m_Icon.m_Content._yscale = abilityClip.m_Icon.m_Background._height - 4;
        
        var iconColor = (color) ? color : Colors.GetColorlineColors( feat.m_ColorLine );
        Colors.ApplyColor( abilityClip.m_Icon.m_Background.highlight, iconColor.highlight);
        Colors.ApplyColor( abilityClip.m_Icon.m_Background.background, iconColor.background);
        
        if (feat.m_SpellType == _global.Enums.SpellItemType.eMagicSpell  )
        {
            abilityClip.m_Icon.m_Lines._visible = false;
            abilityClip.m_Icon.m_EliteFrame._visible = false;
        }
        else if (feat.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility)
        {
            abilityClip.m_Icon.m_Lines._visible = false;
            abilityClip.m_Icon.m_EliteFrame._visible = true;
        }
        else if (feat.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility)
        {
            abilityClip.m_Icon.m_Lines._visible = true;
            abilityClip.m_Icon.m_EliteFrame._visible = true;
        }
        else if (feat.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility)
        {
            abilityClip.m_Icon.m_Lines._visible = true;
            abilityClip.m_Icon.m_EliteFrame._visible = false;
        }
        else if (feat.m_SpellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility)
        {
            abilityClip.m_Icon.m_Lines._visible = false;
            abilityClip.m_Icon.m_EliteFrame._visible = false;
        }
        else
        {
            abilityClip.m_Icon.m_Lines._visible = true;
            abilityClip.m_Icon.m_EliteFrame._visible = false;
        }
        
        if (abilityClip.i_Symbol != undefined)
        {
            abilityClip.i_Symbol.removeMovieClip();
        }
        
        
        //Add the symbol to the icon (ticked or locked)
        var symbolName = "";
        
        if (abilityClip.m_Feat.m_CanTrain || abilityClip.m_Feat.m_Trained)
        {
            var overrideColor:Number = undefined;

            if ( abilityClip.m_Feat.m_Trained )
            {
                symbolName = "TickIcon";
                overrideColor = 0xCCCCCC;
                abilityClip.i_Cover._visible = false;
            }
            else
            {
                abilityClip.i_Cover._visible = true;
                abilityClip.i_Cover.gotoAndStop("light");
            }
            abilityClip.m_Icon._alpha = 100;
            abilityClip.i_Text._alpha = 100
            abilityClip.i_DetailedText._alpha = 100;
            UpdateAbilityCostButton(abilityClip.m_SP, abilityClip.m_Feat.m_Cost, true, overrideColor);
        }
        else
        {
            abilityClip.i_Cover._visible = true;
            abilityClip.i_Cover.gotoAndStop("dark");
            symbolName = "LockIcon";
            
            abilityClip.m_Icon._alpha = 35;
            abilityClip.i_Text._alpha = 65;
            abilityClip.i_DetailedText._alpha = 65;
            
            UpdateAbilityCostButton(abilityClip.m_SP, abilityClip.m_Feat.m_Cost, false, 0xFF6040);
        }
        
        if (symbolName != "")
        {
            abilityClip.createEmptyMovieClip("i_Symbol", abilityClip.getNextHighestDepth());
            abilityClip.i_Symbol.attachMovie(symbolName, symbolName, abilityClip.i_Symbol.getNextHighestDepth() );
            abilityClip.i_Symbol._x = abilityClip.m_Icon._x + abilityClip.m_Icon._width - 7;
            abilityClip.i_Symbol._y = abilityClip.m_Icon._y + abilityClip.m_Icon._height - 7;
            abilityClip.i_Symbol._xscale = abilityClip.m_Icon._xscale / 2;
            abilityClip.i_Symbol._yscale = abilityClip.m_Icon._yscale / 2;
        }
        
        //Toggle background glow of the icon to show if it's equipped or not.
        abilityClip.m_Icon.filters = [];
        var abilitiesArray:Array = GearManager.GetCurrentCharacterBuild().m_AbilityArray;
        var spellDataID:Number = Spell.GetSpellData(abilityClip.m_Feat.m_Spell).m_Id;

        for (var i:Number = 0; i < abilitiesArray.length; i++)
        {
            var equippedAbilitySpellDataID:Number = abilitiesArray[i].m_SpellData.m_Id;
            
            if (equippedAbilitySpellDataID == spellDataID)
            {
                abilityClip.m_Icon.filters = [new GlowFilter(0xFFFFFF, 90, 8, 8, 2, 2, false, false)];
            }
        }
    }
    else
    {
        Log.Error("SkillHive", "Trying to add nonexistent feat: " + featID);    
    }
}


function UpdateAbilityCostButton(buttonClip:MovieClip, cost:Number, enableButton:Boolean, overrideTextColor:Number)
{
    buttonClip.m_SkillPointsText.text = cost;
    if (enableButton != undefined && enableButton == false)
    {
        
        buttonClip._alpha = 65;
    }
    else
    {
        buttonClip._alpha = 100;
    }
    if (overrideTextColor != undefined)
    {
        buttonClip.m_SkillPointsText.textColor = overrideTextColor;
        buttonClip.m_SkillPointsLabel.textColor = overrideTextColor;
    }
    else
    {
        if (cost <= m_Character.GetTokens(1))
        {
            buttonClip.m_SkillPointsText.textColor = 0x00FF33;
            buttonClip.m_SkillPointsLabel.textColor = 0x00FF33;
        }
        else
        {
            buttonClip.m_SkillPointsText.textColor = 0xFF6040;
            buttonClip.m_SkillPointsLabel.textColor = 0xFF6040;
        }
    }
}

function SetupPowerInventory(isOpen:Boolean)
{
    var visibleRect:Object = Stage["visibleRect"];
    m_IsPowerInventoryOpen = isOpen;
    m_PowerInventory.UpdateVisibility(isOpen);
    
    UpdatePowerInventoryPosition(true)
    m_PowerInventory.m_PowerInventoryPaneButton.m_Text.text = LDBFormat.LDBGetText("GenericGUI", "SkillHive_PowerInventory");
    m_PowerInventory.m_PowerInventoryPaneButton.onRelease = PowerInventoryClickHandler;
    
}

function PowerInventoryClickHandler()
{
    Log.Info2("SkillHive", "PowerInventoryClickHandler() ");
    m_IsPowerInventoryOpen = !m_IsPowerInventoryOpen;
    m_PowerInventory.UpdateVisibility(m_IsPowerInventoryOpen);
    UpdatePowerInventoryPosition(false);
}

function UpdatePowerInventoryPosition(snap:Boolean)
{
    var visibleRect:Object = Stage["visibleRect"];
    
    if (m_IsPowerInventoryOpen)
    {
        m_PowerInventory.m_PowerInventoryPaneButton.m_TabArrow._rotation = 180;
        newPos = GetLeftSideWidth();
    }
    else
    {   
        m_PowerInventory.m_PowerInventoryPaneButton.m_TabArrow._rotation = 0;
        newPos =  visibleRect.width - PANE_CLOSE_WIDTH;
    }
    if (!snap)
    {
        m_PowerInventory.tweenTo(PANEL_TWEEN_SPEED, { _x: newPos }, None.easeNone);
        if (m_IsPowerInventoryOpen)
        {
            m_PowerInventory.SetSize(Stage.width - newPos, Stage.height);
            m_PowerInventory.onTweenComplete = function()
            {
                ShowAbilityWheels(false);
            }
        }
        else
        {
            m_PowerInventory.onTweenComplete = undefined;
            ShowAbilityWheels(true);
        }
        
    }
    else
    {
        m_PowerInventory._x = newPos;
        if (m_IsPowerInventoryOpen)
        {
            m_PowerInventory.SetSize(Stage.width - m_PowerInventory._x, Stage.height);
            ShowAbilityWheels(false);
        }
        else
        {
            ShowAbilityWheels(true);
        }
    }
}

function SetupSkillPointsPanel(pulsateButton:Boolean):Void
{    
    m_CharacterSkillPointPanel.m_CharacterSkillPointButton.onRollOver = function()
    {
        this.gotoAndPlay("over");
    }

    m_CharacterSkillPointPanel.m_CharacterSkillPointButton.onRollOut = function()
    {
        this.gotoAndPlay("out");
    }
    
    m_CharacterSkillPointPanel.m_CharacterSkillPointButton.onRelease = Delegate.create(this, CharacterSkillPointButtonHandler);

    m_CharacterSkillPointPanel.AnimateButtonPulse(pulsateButton);
}

function SlotUpdateAdvancedTooltips()
{
    m_AdvancedTooltipMonitor.SetValue(i_Cell.m_ShowAdvancedTooltips.selected);
}

function ToggleAdvancedTooltips()
{
    m_ShowAdvancedTooltips = m_AdvancedTooltipMonitor.GetValue();
    if(m_UpdateOnAdvancedChanged)
    {
        UpdateAbilityClips();
    }
}

function SlotToggleCharacterSkillPointGUI()
{
     var open:Boolean = m_CharacterSkillPointGUIMonitor.GetValue();
     if (open)
     {
        LoreBase.OpenTagOnce(5198);
     }
     if (open && !m_CharacterSkillPointPanel.IsOpen)
     {
         AnimateCharacterSkillPointPanel(open, false);
     }
     else if (!open && m_CharacterSkillPointPanel.IsOpen)
     {
         CloseSkillHive();
     }
}

function CharacterSkillPointButtonHandler()
{
    AnimateCharacterSkillPointPanel(!m_CharacterSkillPointPanel.IsOpen, false);
}

function AnimateCharacterSkillPointPanel(open:Boolean, snap:Boolean):Void
{
    var gap:Number = 27;  
    var width:Number = Stage["visibleRect"].width;
    var newY:Number;
    var m_PowerWheelArray:Array = new Array(i_Templates, i_Cell, i_AbilityBars, i_SkillhiveBackground, m_PowerInventory);
    
    i_Close._visible = false;
    i_Help._visible = false;

    if (open)
    {
        newY = 0;
        
        i_Close._x = width - gap;
        i_Help._x = i_Close._x - gap;
        
        for (var i:Number = 0; i < m_PowerWheelArray.length; i++)
        {
            m_PowerWheelArray[i].tweenTo(0.4, { _alpha: 0 }, None.easeNone);
        }
    }  
    else
    {
        newY = -m_CharacterSkillPointPanel.m_Background._height;
        
        i_Close._x = width - 60;
        i_Help._x = i_Close._x - gap;
        
        for (var i:Number = 0; i < m_PowerWheelArray.length; i++)
        {
            m_PowerWheelArray[i].tweenTo(0.4, { _alpha: 100 }, None.easeNone);
        }
        
        UpdateBreadcrumbPath();
    } 
         
    m_CharacterSkillPointPanel.IsOpen = open;
    
    if (!snap)
    {
        m_CharacterSkillPointPanel.tweenTo(0.4, { _y: newY }, None.easeNone);
        
        m_CharacterSkillPointPanel.onTweenComplete = function ()
        {
            i_Close._visible = true;
            i_Help._visible = true;
        }
    }
    else
    {
        m_CharacterSkillPointPanel._y = newY;

        i_Close._x = width - gap;
        i_Help._x = i_Close._x - gap;
        
        i_Close._visible = true;
        i_Help._visible = true;
        
        for (var i:Number = 0; i < m_PowerWheelArray.length; i++)
        {
            m_PowerWheelArray[i]._alpha = 0;
        }
    }
    
    m_CharacterSkillPointPanel.AnimateButtonPulse(false);
    
    DistributedValue.SetDValue("character_points_gui", open);
    DistributedValue.SetDValue("anima_wheel_gui", !open);
}

function GetSidepaneWidth()
{
    return (m_SidePanesArray[CELL].mc._x + m_PanelOpenWidths[ CELL ]);
}

/**
 * LAYOUT OF THE TABS (the part you interact with at least)
 * mc:
 *  i_Tab // the tab
 *      i_ExpandableTab     // the bit with the name sideways
 *          i_TabClip       // tha actual clip that gets moved in and out
 *              i_Text      // the vertical textfield
 *              i_TabArrow  // the arrows used to open the pane (the open method is actually triggered on i_TabClip)
 *      i_Text              // the horizontal textfield
 *      i_TabArrow          // the arrows you click to collapse the pane
 * 
 * Sets up the sidepanes positions in their default setup ( do we need to change this to support saved state?)
 * 
 */
function SetupSidePanes() : Void
{
    // check for resolution, and close templates if not widescreen
    var isTemplateOpen:Boolean = (m_IsWidescreen ? true : false);
    m_SidePanesArray = [];
    m_SidePanesArray[TEMPLATE] =    {mc: i_Templates,   isOpen: false, isLocked: false, id:TEMPLATE, name:LDBFormat.LDBGetText("GenericGUI", "SkillHive_Templates") };
    m_SidePanesArray[CELL] =        {mc: i_Cell,        isOpen: false, isLocked: false, id:CELL,     name:LDBFormat.LDBGetText("GenericGUI", "Cells") };
    
    var sidePanesX:Number = -m_PanelOpenWidths[0];

    for (var i:Number = 0; i < m_SidePanesArray.length; i++ )
    {
        var paneObject:Object = m_SidePanesArray[i];
        var mc:MovieClip = paneObject.mc;
        mc["index"] = paneObject.id; // backreference as property in the movieclip
        mc.i_Tab.i_ExpandableTab.i_TabClip.i_Text.text = paneObject.name;
        mc.i_Tab.i_Text.text = paneObject.name;
        
        var openbutton:MovieClip =  mc.i_Tab.i_ExpandableTab.i_TabClip;
        var closebutton:MovieClip = mc.i_Tab.i_TabArrow;
        var tabClip:MovieClip = mc.i_Tab;
        
        // methods on the pane
        closebutton["id"] = i;
        openbutton["id"] = i;
        tabClip["id"] = i;
        
        openbutton.onMouseRelease = closebutton.onMouseRelease =  function()
        {
            SlotSwitchSheet( this["id"], false );
        }
        
        tabClip.onMousePress = function(buttonIdx:Number, clickCount:Number)
        {
            //If you doubleclick this, you close the sheet
            if (buttonIdx == 1)
            {
                SlotSwitchSheet( this["id"], false );
            }
        }
        
        tabClip.onPress = function() { }
        
        
        if (paneObject.isOpen)
        {
            Log.Info2("SkillHive", "paneObject open on creation");
            mc.i_Tab.i_ExpandableTab.gotoAndStop("closed"); // cause tab closed when pane open
            sidePanesX += m_PanelOpenWidths[ i ];
        }
        else
        {
            mc.i_Tab.i_ExpandableTab.gotoAndStop("opened");// cause tab opened when pane closed
            sidePanesX += PANE_CLOSE_WIDTH;
            HideClip( closebutton, true );
        }
        
        mc._x = sidePanesX;
       // }
        m_PaneLayoutArray.push( { isOpen: paneObject.isOpen, x: sidePanesX } );
    }
}

/**
 * Opens a pane
 * @param    obj:Object - object containing reference to the pane we open
 * @param    x:Number - the new xpos
 */
function OpenPane(obj:Object, x:Number, snap:Boolean)
{
    var pane:MovieClip = obj.mc;
    obj.isOpen = true;

    //open the tab
    if (snap)
    {
        pane.i_Tab.i_ExpandableTab.gotoAndStop("closed");
    }
    else
    {
        pane.i_Tab.i_ExpandableTab.gotoAndPlay("close");
    }
        
    
    if (pane.i_ScrollBar)
    {
        UpdateScrollBar(obj.id)
       // pane.i_ScrollBar._visible = true;   
       // pane.i_ScrollBackground._visible = true;
    }
    
    
    ShowClip( pane.i_Tab.i_TabArrow, snap ); 

    if (snap)
    {
        pane._x = x;
    }
    else
    {
        pane.tweenTo(PANEL_TWEEN_SPEED, { _x: x }, None.easeNone);
        pane.onTweenComplete = undefined;
    }
    
    //Open the active/passive bar when opening the cell
    if (obj.id == CELL)
    {
        /*if (snap)
        {
            pane.i_CellContent._alpha = 100;
        }
        else
        {
            pane.i_CellContent.tweenTo(0.2, { _alpha:100 }, None.easeNone);
        }*/
        
        if (!m_PassiveBarVisible)
        {
            SlotToggleVisibilityPassiveBar(snap);
        }
        if (!m_ActiveBarVisible)
        {
            SlotToggleVisibilityActiveBar(snap);
        }
    }
}

/**
 * If a pane kkeps its old state, but chenges position because other panes move.
 * @param    obj:Object - the object that wraps the pane
 * @param    x:Number - the position to tween to
 */
function MovePane(obj:Object, x:Number, snap:Boolean)
{
    var pane:MovieClip = obj.mc;
    if (snap)
    {
        pane._x = x;
    }
    else
    {
        pane.tweenTo(PANEL_TWEEN_SPEED, { _x: x }, None.easeNone);
        pane.onTweenComplete = undefined;
    }
}

/**
 * Closes a pane
 * @param    obj:Object - object containing reference to the pane we close
 * @param    x:Number - the new xpos
 */
function ClosePane(obj:Object, x:Number, snap:Boolean)
{
    var pane:MovieClip = obj.mc;
    obj.isOpen = false;
    
    //open the tab    
    if (snap)
    {
        pane.i_Tab.i_ExpandableTab.gotoAndStop("opened");
    }
    else
    {
        pane.i_Tab.i_ExpandableTab.gotoAndPlay("open");
    }
    
    if (pane.i_ScrollBar)
    {
        UpdateScrollBar(obj.id)
    }
    
    HideClip( pane.i_Tab.i_TabArrow, snap );
    
    if (snap)
    {
        pane._x = x;
    }
    else
    {
        pane.tweenTo(PANEL_TWEEN_SPEED, { _x: x }, None.easeNone);
        pane.onTweenComplete = undefined;
    }
    
    //Open the active/passive bar when opening the cell
    if (obj.id == CELL)
    {
        /*if (snap)
        {
            pane.i_CellContent._alpha = 0;
        }
        else
        {
            pane.i_CellContent.tweenTo(0.2, { _alpha:0 }, None.easeNone);
        }*/
        
        if (m_PassiveBarVisible)
        {
            SlotToggleVisibilityPassiveBar(snap);
        }
        if (m_ActiveBarVisible)
        {
            SlotToggleVisibilityActiveBar(snap);
        }
    }
}




/**
 * tweens a clip in, makes sure it is at 0 alpha and visible first
 * @param    clip:MovieClip - the clip to hide
 * @param snap:Boolean - flag indication if we are just moving the tab, thus not tweening the openstate 
 */
function ShowClip( clip:MovieClip, snap:Boolean ) : Void
{
    
    Log.Info2("SkillHive", "ShowClip( " + clip + ", " + snap + ")");
    clip._visible = true;
    clip._alpha = 0;
    clip.tweenEnd();
    if (snap)
    {
        clip._alpha = 100;
    }
    else
    {
        clip.tweenTo(PANEL_TWEEN_SPEED, { _alpha: 100 }, None.easeNone);
        clip.onTweenComplete = undefined;
    }
}

/**
 * Hides a clip by tweening out and then hiding
 * @param    clip:MovieClip - the button to hide
 * @param snap:Boolean - flag indication if we are just moving the tab, thus not tweening the openstate 
 */
function HideClip( clip:MovieClip, snap:Boolean ): Void
{
    Log.Info2("SkillHive", "HideClip( " + clip + ", " + snap + ")");
    if (snap)
    {
        clip._alpha = 0;
        clip._visible = false;
    }
    else
    {
        // set a tween on the top button
        clip.tweenTo(PANEL_TWEEN_SPEED, { _alpha: 0 }, None.easeNone);
        clip.onTweenComplete = function()
        {
            this._visible = false;
        }
    }
}

/// switches sheet on demend
function SlotSwitchSheet( id:Number, snap:Boolean )
{
    if (!IsPaneLocked(id))
    {
        Log.Info2("SkillHive", "SlotSwitchSheet( id = " + id + ",  snap = "+snap+" )");
        var isOpen:Boolean = !m_SidePanesArray[id].isOpen; /// store reversed open flag without modifying
        var numOpen:Number = (isOpen ? 1 : 0);
        var allowedPanes:Number = (m_IsWidescreen ? 2 : 1)
        var openArray:Array = [];
        var i:Number;
        var xPos:Number = -300;

        // check what panes we want to have open, from last to first as we would prefer 
        // to have the last panel open.
        for (var i:Number = m_SidePanesArray.length - 1; i >= 0 ; i-- )
        {
            var panelObj:Object = m_SidePanesArray[i];
            var openState:Boolean = ( panelObj.id == id ? isOpen : panelObj.isOpen );
            
            /// if we are closing the panel, or the current panel is closed or there are room for more panels
            if (panelObj.id == id)
            {
                openArray.push( {isOpen:openState, x:0});
            }
            else if (!openState ||  ( numOpen < allowedPanes))
            {
                numOpen += (openState ? 1 : 0);
                openArray.push({isOpen:openState, x:0});
            }
            else
            {
                openArray.push({isOpen:false, x:0});
            }
        }

        /// array from 2 -> 0 reversing to 0 -> 2
        openArray.reverse();
        /// positions
        for (var j:Number = 0; j < openArray.length; j++)
        {
            xPos += ( openArray[j].isOpen ? m_PanelOpenWidths[ j ] : PANE_CLOSE_WIDTH );
            openArray[j].x = xPos;
        }
        
        /// check towards old positions and execute
        for (var k:Number = 0; k < m_SidePanesArray.length; k++ )
        {
            // Closing
            if (m_PaneLayoutArray[k].isOpen && !openArray[k].isOpen)
            {
                ClosePane(m_SidePanesArray[k], openArray[k].x, snap)
            }
            // Opening
            else if (!m_PaneLayoutArray[k].isOpen && openArray[k].isOpen)
            {
                OpenPane(m_SidePanesArray[k], openArray[k].x, snap)
            }
            // Moving
            else if (m_PaneLayoutArray[k].x != openArray[k].x)
            {
                MovePane(m_SidePanesArray[k], openArray[k].x, snap)
            }
        }
        
        m_PaneLayoutArray = openArray;
        
        UpdateBackgroundAndBarPositions(snap);
    }
    
    if (m_IsPowerInventoryOpen)
    {
        UpdatePowerInventoryPosition(snap);
    }
}

function UpdateBackgroundAndBarPositions(snap:Boolean)
{
    var leftSideWidth:Number = GetLeftSideWidth();
    var tweenBackgroundTo:Number = ((Stage["visibleRect"].width + leftSideWidth) / 2) - (m_DefaultSkillhiveBackgroundWidth / 2) ; // - Stage["visibleRect"].x
    var tweenAbilityBarsTo:Number = ((Stage["visibleRect"].width + leftSideWidth) / 2) - (i_AbilityBars._width / 2);
    if (snap)
    {
        i_SkillhiveBackground._x = tweenBackgroundTo;
        i_AbilityBars._x = tweenAbilityBarsTo;
    }
    else
    {
        i_SkillhiveBackground.tweenTo(PANEL_TWEEN_SPEED, { _x: tweenBackgroundTo }, None.easeNone);
        i_AbilityBars.tweenTo(PANEL_TWEEN_SPEED, { _x:tweenAbilityBarsTo  }, None.easeNone);
    }
}


// sets a mask for the sidepane
function SetSidePaneMask(pane:MovieClip)
{
   /* if (m_Mask)
    {
        m_Mask.removeMovieClip();
    }

    var h:Number = pane._height;
    var w:Number = pane._width;

    m_Mask = this.createEmptyMovieClip("mask", this.getNextHighestDepth());
    m_Mask.beginFill(0xFF0000, 40);
    m_Mask.moveTo(0, 0);
    m_Mask.lineTo(w, 0);
    m_Mask.lineTo(w, h);
    m_Mask.lineTo(0, h);
    m_Mask.lineTo(0, 0);
    pane.setMask( m_Mask );
    */
}

function UpdateTotalSkillpoints()
{
    i_SkillhiveBackground.m_InfoPane.m_TotalAnimaPoints.m_TotalAnimaPoints.text = m_Character.GetTokens(1) + "/" + com.GameInterface.Utils.GetGameTweak("LevelTokensCap");
    var textColor:Number = 0xFF2222;
    if (m_Character.GetTokens(1) > 0)
    {
        textColor = 0x22FF22;
    }
    i_SkillhiveBackground.m_InfoPane.m_TotalAnimaPoints.m_TotalAnimaPoints.textColor = textColor
}

function UpdateHiveCompletion()
{
    i_SkillhiveBackground.m_InfoPane.m_TotalCompletion.m_TotalCompletionText.text = m_SelectedAbilityWheel.GetCompletionText();
    i_SkillhiveBackground.m_InfoPane.m_TotalCompletion.m_TotalCompletion.text = m_SelectedAbilityWheel.GetTotalCompletion();
    i_SkillhiveBackground.m_InfoPane.m_TotalAbilities.m_TotalAbilities.text = m_SelectedAbilityWheel.GetTotalAbilities();
}

function SlotTokenChanged(tokenID:Number, newAmount:Number, oldAmount:Number)
{
    SlotUpdateEquipPanel();
    UpdateTotalSkillpoints();
}

function SlotUpdateEquipPanel()
{
    if (m_CurrentEquipPanel != undefined)
    {
        m_CurrentEquipPanel.Update(m_SelectedFeat.m_Trained, (m_SelectedFeat.m_Refundable && ProjectFeatInterface.CanRefund()), m_SelectedFeat.m_Spell);
    }

    UpdateAbilityClips();
}

/** TEMPLATE FUNCTIONALITY**/
function IsFeatInTemplate(featID:Number)
{
    if (m_TemplateFilterArray != undefined)
    {
        for (var i = 0; i < m_TemplateFilterArray.length; i++)
        {
            if (m_TemplateFilterArray[i].ability == featID)
            {
                return true;
            }
        }
    }
    return false;
}

function GetTemplateClipName(featData:FeatData):String
{
    if (featData.m_Trained)
    {
        return "TemplateAbilityTrained";
    }
    else if (featData.m_CanTrain)
    {
        return "TemplateAbilityAvailable";
    }
    else
    {
        return "TemplateAbilityUnavailable";
    }
}


function SlotToggleTemplateAbilities(event:Object)
{
    m_ShowTemplateAbilities = event.selected;
    if (m_ShowTemplateAbilities)
    {
        m_TemplateFilter.tweenTo(0.5, { _alpha:100 }, Regular.easeOut);
    }
    else
    {
        m_TemplateFilter.tweenTo(0.5, { _alpha:0 }, Regular.easeOut);
    }
    Selection.setFocus(null);
}


function SlotTemplateSelected(template:SkillTemplate)
{
    i_Cell.m_ToggleDeckAbilities.disabled = template == undefined;
    i_Cell.m_ToggleDeckAbilities.selected = template != undefined;
    
    var shouldTweenOut:Boolean = m_TemplateFilterArray.length > 0;
    
    m_SelectedTemplate = template;
    m_TemplateFilterArray = [];
    if (template.m_ActiveAbilities != undefined)
    {
        for (var i:Number = 0; i < 7; i++)
        {
            var featData:FeatData = FeatInterface.m_FeatList[template.m_ActiveAbilities[i]];
            if (featData != undefined)
            {
                m_TemplateFilterArray.push( { cluster:featData.m_ClusterIndex, cell:featData.m_CellIndex, ability:featData.m_Id } );
            }
        }
    }
    if (template.m_PassiveAbilities != undefined)
    {
        for (var i:Number = 0; i < 7; i++)
        {
            var featData:FeatData = FeatInterface.m_FeatList[template.m_PassiveAbilities[i]];
            if (featData != undefined)
            {
                m_TemplateFilterArray.push( { cluster:featData.m_ClusterIndex, cell:featData.m_CellIndex, ability:featData.m_Id } );
            }
            
        }
    }
    
    for (var i:Number = 0; i < m_AbilityWheels.length; i++)
    {
        m_AbilityWheels[i].SetTemplateFilterArray(m_TemplateFilterArray);
    }
    
    if (!m_SelectedAbilityWheel.IsAnimating())
    {
        if (shouldTweenOut)
        {
            m_TemplateFilter.tweenTo(0.5, { _alpha:0 }, Regular.easeOut);
            m_TemplateFilter.onTweenComplete = ShowTemplates;
        }
        else
        {
            ShowTemplates();
        }
    }
}

function ShowTemplates()
{
    m_SelectedAbilityWheel.DrawBackground(m_RingBackground);
    m_SelectedAbilityWheel.DrawTemplates(m_TemplateFilter);
    
    m_TemplateFilter._alpha = 0;
    m_TemplateFilter.onTweenComplete = null;
    
    if (m_ShowTemplateAbilities)
    {
        m_TemplateFilter.tweenTo(0.5, { _alpha:100 }, Regular.easeOut);
    }
    
    UpdateAbilityClips();
}


/** HELPER FUNCTIONS **/

function RGB( r:Number, g:Number, b:Number ) : Number
{
  return (r<<16)+ (g<<8) + b;
}

function IsPaneOpen(paneID:Number):Boolean
{
    return m_SidePanesArray[paneID].isOpen;
}

function IsPaneLocked(paneID:Number):Boolean
{
    return m_SidePanesArray[paneID].isLocked;
}

function GetCellAbilityClip(cellIdx:Number)
{
    return i_Cell.i_CellContent["i_CellAbility_" + cellIdx];
}

function IsPassiveAbility(spellType:Number)
{
    return     spellType == _global.Enums.SpellItemType.eElitePassiveAbility || 
            spellType == _global.Enums.SpellItemType.eAuxilliaryPassiveAbility ||
            spellType == _global.Enums.SpellItemType.ePassiveAbility;
}

function IsActiveAbility(spellType:Number)
{
    return     spellType == _global.Enums.SpellItemType.eMagicSpell || 
            spellType == _global.Enums.SpellItemType.eEliteActiveAbility ||
            spellType == _global.Enums.SpellItemType.eAuxilliaryActiveAbility;    
}
