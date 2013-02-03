//Imports
import com.GameInterface.GearData;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import gfx.motion.Tween; 
import gfx.core.UIComponent;
import mx.transitions.easing.*;
import gfx.utils.Delegate;
import com.GameInterface.Inventory;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;
import com.GameInterface.GearManager;
import com.GameInterface.GearDataAbility;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;
import com.Components.ItemComponent;


//Class
class GUI.CharacterSheet.GearManagerComponent extends UIComponent
{
    //Constants
    private static var DRAG_PADDING:Number = 40;
    private static var ANIMATION_DURATION:Number = 0.2;
    
    private static var ACTION_CREATE:Number = 0;
    private static var ACTION_OVERWRITE:Number = 1;
    private static var ACTION_RENAME:Number = 2;
    private static var ACTION_DELETE:Number = 3;
    private static var ACTION_LOAD:Number = 4;
    private static var ACTION_IMPORT:Number = 5;
    
    private static var MAX_VISIBLE_BUILD_SLOTS:Number = 8;
    private static var TOOLTIP_PADDING:Number = 4;
    private static var ZOOM_SPEED:Number = 0.4;

    private static var ACTIVE_SHORTCUTBAR_COUNT:Number = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount;
    private static var ACTIVE_SHORTCUTBAR_FIRSTSLOT:Number = _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarFirstSlot;
    private static var PASSIVE_SHORTCUTBAR_COUNT:Number = _global.Enums.PassiveAbilityShortcutSlots.e_PassiveShortcutBarSlotCount;
    private static var PASSIVE_SHORTCUTBAR_FIRSTSLOT:Number = _global.Enums.PassiveAbilityShortcutSlots.e_PassiveShortcutBarFirstSlot;
    
    private static var VIEW_ICON_TOOLTIP:String = LDBFormat.LDBGetText("GenericGUI", "GearManager_ViewGearTooltip");
    private static var CLOSEVIEW_ICON_TOOLTIP:String = LDBFormat.LDBGetText("GenericGUI", "GearManager_CloseViewGearTooltip");
    private static var RENAME_BUILD_TOOLTIP:String = LDBFormat.LDBGetText("GenericGUI", "GearManager_EditGearTooltip");
    private static var DELETE_BUILD_TOOLTIP:String = LDBFormat.LDBGetText("GenericGUI", "GearManager_DeleteGearTooltip");
    private static var SHARE_ICON_TOOLTIP:String = LDBFormat.LDBGetText("GenericGUI", "GearManager_ShareGearTooltip");
    private static var WEAPONS_TITLE:String = LDBFormat.LDBGetText("GenericGUI", "GearManagementWeaponsTitle");
    private static var TALISMANS_TITLE:String = LDBFormat.LDBGetText("GenericGUI", "GearManagementTalismansTitle");
    private static var PASSIVE_TITLE:String = LDBFormat.LDBGetText("GenericGUI", "GearManagementPassiveAbilitiesTitle");
    private static var ACTIVE_TITLE:String = LDBFormat.LDBGetText("GenericGUI", "GearManagementActiveAbilitiesTitle");
    
    //Properties
    public var m_CloseButton:MovieClip;
    
    private var m_TopDividerLine:MovieClip;
    private var m_Background:MovieClip;
    private var m_Title:TextField;
    private var m_ViewPanel:MovieClip
    private var m_MainContent:MovieClip;
    private var m_This:MovieClip;
    
    private var m_CurrentPanel:MovieClip;
    private var m_Target:Object;
    private var m_CurrentCallback:Function;
    private var m_OldPanel:MovieClip;
    private var m_Tooltip:TooltipInterface = undefined;
    
    private var m_Builds:Array;
    private var m_SelectedIndex:Number = -1;
    private var m_IsConfimationPanelOpen:Boolean;
    private var m_ErrorPanel:MovieClip;

    private var m_Validator:MovieClip;
    private var m_ValidatorText:TextField;
    
    private var m_Action:Number;
    private var m_DoListen:Boolean;
        
    private var m_SaveInfoText:TextField;
    
    private var m_Width:Number;
    private var m_Height:Number;
    
    private var m_ConfirmPanel:MovieClip;
    private var m_UserInput:Boolean;
    private var m_UserInputUnlimitedChars:Boolean;
    private var m_CheckInterval:Number;
    private var m_PositiveLabel:String;
    private var m_CharacterHasBuild:Boolean;
    
    //Gear Manager Component
    public function GearManagerComponent() 
    {
        super();

        m_This = this;
        m_Width = m_This._width;
        m_Height = m_This._height;

        
        m_ViewPanel._visible = false;
        m_MainContent.m_ContentOverlay._visible = false;
        
        m_Target = { panel:m_MainContent };
        
        m_IsConfimationPanelOpen = false;
    }
    
    //On Mouse Down
    private function onMouseDown():Void
    {
        if (m_Target.panel != m_MainContent)
        {
            return;
        }

        if (m_SelectedIndex > -1 && !m_IsConfimationPanelOpen)
        {
            if  (
                    (m_MainContent._xmouse < m_MainContent.m_Content._x || m_MainContent._xmouse > m_MainContent.m_Content._x + m_MainContent.m_Content._width)         || 
                    (m_MainContent._ymouse < m_MainContent.m_Content._y || m_MainContent._ymouse > m_MainContent.m_Content._y + m_MainContent.m_Content._height + 30)
                )
            {
                var item = m_MainContent.m_Content.renderers[m_SelectedIndex];
                item.selected = false;
                SetSelectedIndex( -1);
                
                if (m_MainContent.m_Content.hitTestDisable)
                {
                    m_MainContent.m_Content.hitTestDisable = false;
                }
            }
        }
    }

    //Config UI
    public function configUI():Void
    {
        super.configUI();
        
        GearManager.SignalGearManagerDataUpdated.Connect(SlotGearManagerDataUpdated, this)
        GearManager.SignalGearManagerError.Connect(SlotGearManagerError, this);
        
        m_Title.text = LDBFormat.LDBGetText("GenericGUI", "GearManagement");
        
        m_MainContent.m_NewUpdateButton.addEventListener("click", this, "SaveBuildHandler");
        m_MainContent.m_NewUpdateButton.disabled = true;
        m_MainContent.m_NewUpdateButton.label = LDBFormat.LDBGetText("GenericGUI", "Save");
        
        m_MainContent.m_LoadButton.addEventListener("click", this, "LoadBuildHandler");
        m_MainContent.m_LoadButton.disabled = true;
        m_MainContent.m_LoadButton.label = LDBFormat.LDBGetText("GenericGUI", "Load");
        
        m_MainContent.m_ImportButton.addEventListener("click", this, "ImportBuild");
        m_MainContent.m_ImportButton.label = LDBFormat.LDBGetText("GenericGUI", "Import");

        m_ViewPanel.m_DeleteButton2.addEventListener("click", this, "DeleteBuild");

        m_ViewPanel.m_LoadButton.addEventListener("click", this, "LoadBuildHandler");
        m_ViewPanel.m_LoadButton.label = LDBFormat.LDBGetText("GenericGUI", "Load");
        
        m_ViewPanel.m_RenameButton.addEventListener("click", this, "RenameBuild");

        m_ViewPanel.m_ShareButton.addEventListener("click", this, "ShareBuildHandler");
        
        m_ViewPanel.m_ViewButtonClose.SetTooltipText(CLOSEVIEW_ICON_TOOLTIP);
        m_ViewPanel.m_RenameButton.SetTooltipText(RENAME_BUILD_TOOLTIP);
        m_ViewPanel.m_DeleteButton2.SetTooltipText(DELETE_BUILD_TOOLTIP);
        m_ViewPanel.m_ShareButton.SetTooltipText(SHARE_ICON_TOOLTIP);
        
        m_ViewPanel.m_ViewButtonClose.addEventListener("click", this, "CancelViewBuild");
        
        m_ViewPanel.m_GearIcons.m_WeaponsTitleTextField.text = WEAPONS_TITLE;
        m_ViewPanel.m_GearIcons.m_ChakrasTitleTextField.text = TALISMANS_TITLE;
        m_ViewPanel.m_GearIcons.m_PassiveAbilitiesTitleTextField.text = PASSIVE_TITLE;
        m_ViewPanel.m_GearIcons.m_ActiveAbilitiesTitleTextField.text = ACTIVE_TITLE;
        
        m_MainContent.m_Content.columnWidth = m_MainContent.m_Content._width - 15;
                
        m_MainContent.m_Content.addEventListener("itemClick", this, "ListItemsClickHandler");
        m_MainContent.m_Content.addEventListener("itemRollOut", this, "ListItemsRollOutHandler");
        m_MainContent.m_Content.addEventListener("itemRollOver", this, "ListItemsRollOverHandler");
        m_MainContent.m_Content.addEventListener("focusIn", this, "ListItemsManualUpdate");
        m_MainContent.m_Content.addEventListener("focusOut", this, "ListItemsManualUpdate");
        m_MainContent.m_Content.addEventListener("itemDoubleClick", this, "ListItemsDoubleClickHandler");
        
        m_CheckInterval = setInterval(Delegate.create(this, CheckScrollBarComponentInitialized), 20);
        
        SetAction(ACTION_CREATE);
        SlotGearManagerDataUpdated();
        
        SetSelectedIndex(-1);
    }

    private function onUnload()
    {
        GearManager.SignalGearManagerDataUpdated.Disconnect(SlotGearManagerDataUpdated, this)
        GearManager.SignalGearManagerError.Disconnect(SlotGearManagerError, this);

        super.onUnload();
    }
    
    //Check Scroll Bar Component Initialized
    private function CheckScrollBarComponentInitialized():Void
    {
        if  (m_MainContent.m_Content.scrollBar)
        {
            m_MainContent.m_Content.scrollBar.addEventListener("scroll", this, "ListItemsScrollHandler");
            clearInterval(m_CheckInterval);
            m_CheckInterval = undefined;
        }
    }
    
    //Slot Gear Manager Data Updated
    private function SlotGearManagerDataUpdated():Void
    {
        m_Builds = GearManager.GetBuildList();
        m_Builds.sort();
        
        var totalBuilds:Number = m_Builds.length;

        for (var i:Number = 0; i < MaximumBuildSlots() - totalBuilds; i++)
        {
            m_Builds.push(undefined);
        }

        m_MainContent.m_Content.dataProvider = m_Builds;
        m_MainContent.m_Content.rowCount = MAX_VISIBLE_BUILD_SLOTS;
        m_MainContent.m_Content.selectedIndex = m_SelectedIndex;
        m_MainContent.m_ContentOverlay._visible = false;
        
        _global.setTimeout(Delegate.create(this, ListItemsManualUpdate), 400);
        
        m_MainContent.m_ContentOverlay._x = m_MainContent.m_Content.columnWidth - m_MainContent.m_ContentOverlay._width - 5 + m_MainContent.m_Content._x;
        
        m_MainContent.m_ContentOverlay.m_ViewIcon.onRollOver = Delegate.create(this, SlotRollContentOverlayViewIcon);
        m_MainContent.m_ContentOverlay.m_ViewIcon.onRelease = Delegate.create(this, SlotClickContentOverlayViewIcon);
        m_MainContent.m_ContentOverlay.m_ViewIcon.onRollOut = Delegate.create(this, SlotRollOutIcon);
        
        m_MainContent.m_ContentOverlay.m_RenameIcon.onRollOver = Delegate.create(this, SlotRollContentOverlayRenameIcon);
        m_MainContent.m_ContentOverlay.m_RenameIcon.onRelease = Delegate.create(this, SlotClickContentOverlayRenameIcon); 
        m_MainContent.m_ContentOverlay.m_RenameIcon.onRollOut = Delegate.create(this, SlotRollOutIcon);
        
        m_MainContent.m_ContentOverlay.m_DeleteIcon.onRollOver = Delegate.create(this, SlotRollContentOverlayDeleteIcon);
        m_MainContent.m_ContentOverlay.m_DeleteIcon.onRelease = Delegate.create(this, SlotClickContentOverlayDeleteIcon);
        m_MainContent.m_ContentOverlay.m_DeleteIcon.onRollOut = Delegate.create(this, SlotRollOutIcon);
                
        m_MainContent.m_ContentOverlay.m_ShareIcon.onRollOver = Delegate.create(this, SlotRollContentOverlayShareIcon);
        m_MainContent.m_ContentOverlay.m_ShareIcon.onRelease = Delegate.create(this, SlotClickContentOverlayShareIcon);
        m_MainContent.m_ContentOverlay.m_ShareIcon.onRollOut = Delegate.create(this, SlotRollOutIcon);
        
        SetMainContentButtonState();
    }
    
    //Get Gear index from the click height
    private function GetContentIndexAt(x:Number, y:Number):Number
    {
        return m_MainContent.m_Content.scrollBar.position + Math.floor( (y - m_MainContent.m_Content._y) / m_MainContent.m_Content.renderers[0]._height);
    }
    
    //Slot Click Content Overlay View Icon
    private function SlotClickContentOverlayViewIcon(scope:MovieClip):Void
    {
        if (m_MainContent.m_ContentOverlay.m_ViewIcon.hitTest(_root._xmouse, _root._ymouse))
        {
            SetSelectedIndex(GetContentIndexAt(m_MainContent._xmouse, m_MainContent._ymouse));
            SetAction(ACTION_OVERWRITE);
            ViewBuildHandler();
        }
    }
    
    //Slot Click Content Overlay Rename Icon
    private function SlotClickContentOverlayRenameIcon(scope:MovieClip):Void
    {
        if (m_MainContent.m_ContentOverlay.m_RenameIcon.hitTest(_root._xmouse, _root._ymouse))
        {
            SetSelectedIndex(GetContentIndexAt(m_MainContent._xmouse, m_MainContent._ymouse));
            SetAction(ACTION_RENAME);
            UpdateBuildHandler();
        }
    }
    
    //Slot Click Content Overlay Delete Icon
    private function SlotClickContentOverlayDeleteIcon(scope:MovieClip):Void
    {
        if (m_MainContent.m_ContentOverlay.m_DeleteIcon.hitTest(_root._xmouse, _root._ymouse))
        {
            SetSelectedIndex(GetContentIndexAt(m_MainContent._xmouse, m_MainContent._ymouse));
            SetAction(ACTION_DELETE);
            UpdateBuildHandler();
        }
    }
    
    //Slot Click Content Overlay Share Icon
    private function SlotClickContentOverlayShareIcon(scope:MovieClip):Void
    {
        if (m_MainContent.m_ContentOverlay.m_ShareIcon.hitTest(_root._xmouse, _root._ymouse))
        {
            SetSelectedIndex(GetContentIndexAt(m_MainContent._xmouse, m_MainContent._ymouse));
            GearManager.ShareBuild(m_Builds[m_SelectedIndex]);
        }
    }
    
    private function SlotRollContentOverlayViewIcon()
    {
        SlotRollOutIcon();
        CreateTooltip(VIEW_ICON_TOOLTIP);
    }

    private function SlotRollContentOverlayRenameIcon()
    {
        SlotRollOutIcon();
        CreateTooltip(RENAME_BUILD_TOOLTIP);
    }
    
    private function SlotRollContentOverlayDeleteIcon()
    {
        SlotRollOutIcon();
        CreateTooltip(DELETE_BUILD_TOOLTIP);
    }

    private function SlotRollContentOverlayShareIcon()
    {
        SlotRollOutIcon();
        CreateTooltip(SHARE_ICON_TOOLTIP);
    }

    //Create Tooltip
    private function CreateTooltip(label:String):Void
    {
        var tooltipData:TooltipData = new TooltipData();
        tooltipData.AddAttribute("", label);
        tooltipData.m_Padding = TOOLTIP_PADDING;
        tooltipData.m_MaxWidth = 100;
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
    }
    
    //Slot Roll Out Icon
    private function SlotRollOutIcon():Void
    {
        if (m_Tooltip != undefined)
        {
            m_Tooltip.Close();
            m_Tooltip = undefined;
        }
    }

    //Get Width
    public function GetWidth():Number
    {
        return m_Width;
    }
    
    //Get Height
    public function GetHeight():Number
    {
        return m_Height;
    }
    
    //Open
    public function Open(anchor:Point):Void
    {
        this._visible = true;
        this._alpha = 100;
        this._x = anchor.x;
        this._y = anchor.y;
        this._height = 1;
        this._width = 1;
        
        var expandedX:Number = anchor.x - m_Width;
        m_This.tweenTo(ZOOM_SPEED, { _x:expandedX, _width:m_Width, _height:m_Height}, None.easeNone);
        m_This.onTweenComplete = undefined;
    }
    
    //Close
    public function Close(anchor:Point):Void
    {
        SlotRollOutIcon();
        
        if (m_IsConfimationPanelOpen)
        {
            SetButtonDisabledState(false);
            
            CloseConfirmationPanel();
        }
        
        if (m_ErrorPanel != undefined)
        {
            CloseErrorPanel();
        }
    }
    
    //Set Action
    private function SetAction(newAction:Number):Void
    {
        m_Action = newAction;
    }
    
    //Set Selected Index
    private function SetSelectedIndex(newIndex:Number):Void
    {
        if (isNaN(newIndex))
        {
            newIndex = -1;
        }
        
        m_SelectedIndex = newIndex;
        
        SetMainContentButtonState();
    }
    
    //Open Panel
    private function OpenPanel(panel:MovieClip, callBack:Function):Void
    {
        m_OldPanel = m_Target.panel;
        
        m_Target = { panel:panel, callBack:callBack};

        var targetScale:Number = (m_Target.panel != m_MainContent) ? 120 : 80;
        
        m_OldPanel.tweenTo(ANIMATION_DURATION, { _xscale:targetScale, _yscale:targetScale, _alpha:0 }, None.easeNone);
        m_OldPanel.onTweenComplete = Delegate.create(this, OpenPanelDone);
        
        if ( panel == m_MainContent)
        {
            m_TopDividerLine.tweenTo(ANIMATION_DURATION, { _alpha:100 }, None.easeNone);
        }
    }
    
    //Open Panel Done
    private function OpenPanelDone():Void
    {
        m_OldPanel._visible = false;
        var panel:MovieClip = m_Target.panel;

        panel._xscale = panel._yscale = (m_Target.panel == m_MainContent) ? 120 : 80;
        panel._visible = true;
        panel._alpha = 0;

        panel.tweenTo(ANIMATION_DURATION, { _xscale:100, _yscale:100, _alpha:100 }, None.easeNone);
        panel.onTweenComplete = Delegate.create(this, OpenPanelCallback);
    }
    
    //Open Panel Call Back
    private function OpenPanelCallback():Void
    {
        var panel:MovieClip = m_Target.panel;
        
        if (m_Target.callBack)
        {
            m_Target.callBack.apply(this);
        }
        
        Selection.setFocus(null);
    }
    
    //Revert Panel
    private function RevertPanel():Void
    {
        OpenPanel(m_OldPanel);
    }
    
    //Cancel View Build
    private function CancelViewBuild():Void
    {
        OpenPanel(m_MainContent);
    }
    
    //Share Build Handler
    private function ShareBuildHandler():Void
    {
        if (m_SelectedIndex > -1 && m_SelectedIndex < m_Builds.length)
        {
            GearManager.ShareBuild(m_Builds[m_SelectedIndex]);
        }
    }

    //Verify Build Name
    private function VerifyBuildName():Void
    {
        /*
         * updates when a change to the Buildname is registered, shows the verification symbol and 
         * enables or disables the save button
         * 
         */
        
        var text:String = m_ValidatorText.text;
        var isValid:Boolean = true;
        
        if (text == LDBFormat.LDBGetText("GenericGUI", "EnterName") || text.length < 1)
        {
            isValid = false;
        }
        else
        {
            for (var i:Number = 0; i < m_Builds.length; i++)
            {
                if (m_Builds[i] == text)
                {
                    isValid = false;
                    break;
                }
            }
        }
        
        if (isValid)
        {
            m_Validator.gotoAndStop("accept");
            
            m_ConfirmPanel.m_PositiveButton.disabled = false;
        }
        else
        {
            m_Validator.gotoAndStop("alert");
            
            m_ConfirmPanel.m_PositiveButton.disabled = true;
        }
    }
    
    //View Build Handler
    private function ViewBuildHandler():Void
    {
        /*
         * Triggered when the viewbutton is clicked (the eye)
         * Opens the view panel, gets the build and writes content to the m_ViewPanel
         * 
         */
        
        OpenPanel(m_ViewPanel);
        m_TopDividerLine.tweenTo(ANIMATION_DURATION, { _alpha:0 }, None.easeNone);
    
        m_ViewPanel.textField.text = m_Builds[m_SelectedIndex];
        SetAction(ACTION_RENAME);
        
        PopulateGearIcons(m_ViewPanel,GearManager.GetBuild(m_Builds[m_SelectedIndex]));
    }
    
    private function PopulateGearIcons(panel:MovieClip, build:GearData)
    {
        CleanPanel(panel, build);

        var powerSlot:MovieClip;
        var inventoryItem:com.GameInterface.InventoryItem;
        var auxiliaryWeapon:com.GameInterface.InventoryItem;
        var weaponsArray:Array = new Array();
        var chakrasArray:Array = new Array();
        
        for (var i:Number = 0; i < build.m_ItemArray.length; i++)
        {
            inventoryItem = build.m_ItemArray[i].m_InventoryItem;
            if (inventoryItem.m_ItemType == _global.Enums.ItemType.e_ItemType_Weapon)
            {
                if (inventoryItem.m_DefaultPosition == _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot)
                {
                    auxiliaryWeapon = inventoryItem;
                }
                else
                {
                    weaponsArray.push(inventoryItem);
                }
            }
            
            if (inventoryItem.m_ItemType == _global.Enums.ItemType.e_ItemType_Chakra)
            {
                chakrasArray.push(inventoryItem);
            }
        }

        for (var i:Number = 0; i < weaponsArray.length; i++)
        {
            powerSlot = panel.m_GearIcons["weapon_" + i];
            
            PopulateWeaponChakraSlot(powerSlot, weaponsArray[i]);
        }    
        
        if (auxiliaryWeapon != undefined)
        {
            powerSlot = panel.m_GearIcons["weapon_2"];
            PopulateWeaponChakraSlot(powerSlot, auxiliaryWeapon);
        }
        
           for (var i:Number = 0; i < chakrasArray.length; i++)
        {
            var index = 0;
            
            switch(chakrasArray[i].m_Placement)
            {
                case 33554432:      index = 6;
                                    break;
                                
                case 67108864:      index = 5;
                                    break;
                                    
                case 134217728:     index = 4;
                                    break;
                                    
                case 268435456:     index = 3;
                                    break;
                                    
                case 536870912:     index = 2;
                                    break;
                                    
                case 1073741824:    index = 1;
                                    break;
                                    
                case -2147483648:   index = 0;
                                    break;
            }
            
            powerSlot = panel.m_GearIcons["chakra_" + index];
            
            PopulateWeaponChakraSlot(powerSlot, chakrasArray[i]);
        }

        for (var i:Number = 0; i < build.m_AbilityArray.length; i++)
        {
            var pos:Number = build.m_AbilityArray[i].m_Position;
            var spellData:com.GameInterface.SpellData = build.m_AbilityArray[i].m_SpellData;
            
            var ability:MovieClip;

            if (pos <= ACTIVE_SHORTCUTBAR_COUNT + ACTIVE_SHORTCUTBAR_FIRSTSLOT)
            {
                ability = panel.m_GearIcons["active_" + (pos - ACTIVE_SHORTCUTBAR_FIRSTSLOT)];
            }
            else if (pos <= PASSIVE_SHORTCUTBAR_COUNT + PASSIVE_SHORTCUTBAR_FIRSTSLOT)
            {
                ability = panel.m_GearIcons["passive_" + (pos - PASSIVE_SHORTCUTBAR_FIRSTSLOT)];
            }
            
            ability.pos = pos;
            ability.ref = this;
            ability.spellId = spellData.m_Id
            
            ability.onRollOver = function()
            {
                var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip(this["spellId"]);
                var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelayShortcutBar");
                this["ref"].m_Tooltip = TooltipManager.GetInstance().ShowTooltip(this, TooltipInterface.e_OrientationVertical, delay, tooltipData);
            }
            
            ability.onRollOut = ability.onDragOut = function()
            {
                if (this["ref"].m_Tooltip != undefined)
                {
                    this["ref"].m_Tooltip.Close();
                }
            }

            var moviecliploader:MovieClipLoader = new MovieClipLoader();

            ability.m_Content._x = 1;
            ability.m_Content._y = 1;
            ability.m_Content._xscale = ability.m_Background._width - (ability.m_Content._x * 2);
            ability.m_Content._yscale = ability.m_Background._height - (ability.m_Content._y * 2);
            
            var colorObject:Object = Colors.GetColorlineColors(spellData.m_ColorLine);
            Colors.ApplyColor(ability.m_Background.highlight, colorObject.highlight); 
            Colors.ApplyColor(ability.m_Background.background, colorObject.background);            
            
            var isLoaded:Boolean = moviecliploader.loadClip("rdb:" + spellData.m_Icon, ability.m_Content);
            
            if (spellData.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility || spellData.m_SpellType == _global.Enums.SpellItemType.eElitePassiveAbility)
            {
                ability.m_EliteFrame._visible = true;
            }
            else
            {
                ability.m_EliteFrame._visible = false;
            }
        }
    }

    private function CleanPanel(panel:MovieClip, build:GearData):Void
    {
        var showPassives:Boolean = (build.m_SectionFlags & _global.Enums.GearManagerSections.e_Passives) != 0;
        var showActives:Boolean = (build.m_SectionFlags & _global.Enums.GearManagerSections.e_Actives) != 0;
        var showWeapons:Boolean = (build.m_SectionFlags & _global.Enums.GearManagerSections.e_Weapons) != 0;
        var showTalismans:Boolean = (build.m_SectionFlags & _global.Enums.GearManagerSections.e_Talismans) != 0;
        
        var x:Number = panel.m_GearIcons._x;
        var y:Number = panel.m_GearIcons._y;

        panel.m_GearIcons.swapDepths(panel.getNextHighestDepth());
        panel.m_GearIcons.removeMovieClip();
        panel.attachMovie("GearIcons", "m_GearIcons", panel.getNextHighestDepth());
        panel.m_GearIcons._x = x;
        panel.m_GearIcons._y = y;

        for (var i:Number = 0; i < _global.Enums.ActiveAbilityShortcutSlots.e_PrimaryShortcutBarSlotCount; i++)
        {
            if (i < 3)
            {
                var weapon:MovieClip = panel.m_GearIcons["weapon_" + i];

                weapon._alpha = (showWeapons)?100:30;
            }
            
            var chakra:MovieClip = panel.m_GearIcons["chakra_" + i];
            
            if (chakra != undefined)
            {
                chakra._alpha = (showTalismans)?100:30;
            }
            
            var ability:MovieClip = panel.m_GearIcons["active_" + i];
            var passive:MovieClip = panel.m_GearIcons["passive_" + i];
            
            if (showActives)
            {
                Colors.ApplyColor(ability.m_Background.background, Colors.e_ColorBlack); 
                Colors.ApplyColor(ability.m_Background.highlight, Colors.e_ColorBlack); 
                ability._alpha = 100;
            }
            else
            {
                Colors.ApplyColor(ability.m_Background.background, Colors.e_ColorBlack); 
                Colors.ApplyColor(ability.m_Background.highlight, Colors.e_ColorDarkGray);
                ability._alpha = 30;
            }
            
            if (showPassives)
            {
                Colors.ApplyColor(passive.m_Background.background, Colors.e_ColorBlack); 
                Colors.ApplyColor(passive.m_Background.highlight, Colors.e_ColorBlack); 
                passive._alpha = 100;
            }
            else
            {
                Colors.ApplyColor(passive.m_Background.background, Colors.e_ColorDarkGray); 
                Colors.ApplyColor(passive.m_Background.highlight, Colors.e_ColorGray);
                passive._alpha = 30;
            }
            
            ability.m_EliteFrame._visible = false;
            passive.m_EliteFrame._visible = false;
        }
    }
    
    //Populate Weapon Chakra SLot
    private function PopulateWeaponChakraSlot(powerSlot:MovieClip, inventoryItem:com.GameInterface.InventoryItem):Void
    {
        /*
         * For the main content page, overwrites if an item is selected, creates new if not.
         * @param    powerSlot:MovieClip - the specific chakra slot.
         * @param   inventoryItem:com.GameInterface.InventoryItem - the inventoryItem object.
         * @param    build:com.GameInterface.GearData - build data.
         * @param    index:Number - the index of the build's m_ItemArray.
         * 
         */
        
        powerSlot.ref = this;
        powerSlot.ACGItem = inventoryItem.m_ACGItem;
        
        powerSlot.onRollOver = function()
        {
            var tooltipData:TooltipData = TooltipDataProvider.GetACGItemTooltip(this["ACGItem"]);
            var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelayShortcutBar");
            
            this["ref"].m_Tooltip = TooltipManager.GetInstance().ShowTooltip(this, TooltipInterface.e_OrientationVertical, delay, tooltipData);
        }
        
        powerSlot.onRollOut = powerSlot.onDragOut = function()
        {
            if (this["ref"].m_Tooltip != undefined)
            {
                this["ref"].m_Tooltip.Close();
            }
        }
        
        var scaleSize:Number = powerSlot._height;
        var slotItem:ItemComponent = ItemComponent(powerSlot.attachMovie("Item", "m_Item", powerSlot.getNextHighestDepth()));
        slotItem.SetData(inventoryItem);
    }
    
    //Save Build Handler
    private function SaveBuildHandler(event:Object):Void
    {
        if (m_SelectedIndex <= m_Builds.length -1 && m_SelectedIndex > -1)
        {
            SetAction(ACTION_OVERWRITE);
        }
        else
        {
            SetAction(ACTION_CREATE);
        }
        
        UpdateBuildHandler();
    }

    //Set New Update Button Disabled State
    public function SetNewUpdateButtonDisabledState(disabled:Boolean):Void
    {
        m_CharacterHasBuild = !disabled;
        m_MainContent.m_NewUpdateButton.disabled = disabled;
    }
    
    //Set Button Disabled State
    private function SetButtonDisabledState(disabled:Boolean):Void
    {
        if (m_Target.panel == m_MainContent)
        {
            m_MainContent.m_NewUpdateButton.disabled = (m_CharacterHasBuild && (AvailableBuildSlots() - m_Builds.length != 0)) ? disabled : false;
            m_MainContent.m_ImportButton.disabled = disabled;
            m_MainContent.m_LoadButton.disabled = disabled;
            m_MainContent.m_Content.hitTestDisable = disabled;
        }
        else if (m_Target.panel == m_ViewPanel)
        {
            m_ViewPanel.m_ViewButtonClose.disabled = disabled;
            m_ViewPanel.m_RenameButton.disabled = disabled;
            m_ViewPanel.m_DeleteButton2.disabled = disabled;
            m_ViewPanel.m_ShareButton.disabled = disabled;
            m_ViewPanel.m_LoadButton.disabled = disabled;
        }
    }
    
    //Update Build Handler
    private function UpdateBuildHandler(event:Object):Void
    {
        SetButtonDisabledState(true);

        m_ConfirmPanel = m_This.attachMovie("ConfirmPanel", "m_ConfirmPanel", m_This.getNextHighestDepth());
        m_IsConfimationPanelOpen = true;
        
        m_ConfirmPanel.m_GearIcons.m_WeaponsTitleTextField.text = WEAPONS_TITLE;
        m_ConfirmPanel.m_GearIcons.m_ChakrasTitleTextField.text = TALISMANS_TITLE;
        m_ConfirmPanel.m_GearIcons.m_PassiveAbilitiesTitleTextField.text = PASSIVE_TITLE;
        m_ConfirmPanel.m_GearIcons.m_ActiveAbilitiesTitleTextField.text = ACTIVE_TITLE;
        
        m_UserInput = false;
        var showGearIcons:Boolean = true;
        
        if (m_Action == ACTION_RENAME)
        {
            m_ConfirmPanel.m_Headline.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "RenameBuild");
            m_ConfirmPanel.m_Body.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "RenameBuildBody");
            
            m_ConfirmPanel.m_InputTextField._visible = true;
            m_ConfirmPanel.m_InputTextField.m_NameText._text = m_Builds[m_SelectedIndex];
            
            PopulateGearIcons(m_ConfirmPanel,GearManager.GetBuild(m_Builds[m_SelectedIndex]));
            
            m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "RenameCAPS");
            
            m_UserInput = true;
            showGearIcons = false;
        }
        else if (m_Action == ACTION_CREATE)
        {
            m_ConfirmPanel.m_Headline.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "SaveBuild");
            m_ConfirmPanel.m_Body.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "SaveBuildBody");
            
            m_ConfirmPanel.m_InputTextField._visible = true;
            m_ConfirmPanel.m_InputTextField.m_NameText._visible = false;
            m_ConfirmPanel.m_InputTextField.m_NameText._text = LDBFormat.LDBGetText("GenericGUI", "EnterName");
            
            PopulateGearIcons(m_ConfirmPanel,GearManager.GetCurrentCharacterBuild());
            
            m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "Save");

            m_UserInput = true;
        }
        else if (m_Action == ACTION_IMPORT)
        {
            m_ConfirmPanel.m_Headline.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "ImportBuild");
            m_ConfirmPanel.m_Body.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "ImportBuildBody");
            
            m_ConfirmPanel.m_InputTextField._visible = true;
            m_ConfirmPanel.m_InputTextField.m_NameText._visible = false;
            m_ConfirmPanel.m_InputTextField.m_NameText._text = LDBFormat.LDBGetText("GenericGUI", "PasteBuild");
            
            m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "Import");

            m_UserInput = true;
            m_UserInputUnlimitedChars = true;
            showGearIcons = false;
        }
        else if (m_Action == ACTION_OVERWRITE)
        {
            m_ConfirmPanel.m_Headline.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "OverwriteBuild");
            m_ConfirmPanel.m_Body.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "OverwriteBuildBody");
            
            m_ConfirmPanel.m_InputTextField._visible = true;
            m_ConfirmPanel.m_InputTextField.m_NameText._text = m_Builds[m_SelectedIndex];
            
            PopulateGearIcons(m_ConfirmPanel, GearManager.GetCurrentCharacterBuild());
            
            m_PositiveLabel = LDBFormat.LDBGetText("CharStatSkillGUI", "Overwrite");
            
            m_UserInput = true;
        }
        else if (m_Action == ACTION_DELETE)
        {
            m_ConfirmPanel.m_Headline.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "DeleteBuild");
            m_ConfirmPanel.m_Body.autoSize = "center";
            m_ConfirmPanel.m_Body.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "ConfirmDeleteBuild") + "<br><br>" + m_Builds[m_SelectedIndex];
            
            PopulateGearIcons(m_ConfirmPanel,GearManager.GetBuild(m_Builds[m_SelectedIndex]));
            m_ConfirmPanel.m_InputTextField._visible = false;
            
            m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "Delete");
            showGearIcons = false;
        }
        else if (m_Action == ACTION_LOAD)
        {
            m_ConfirmPanel.m_Headline.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "LoadBuild");
            m_ConfirmPanel.m_Body.htmlText = LDBFormat.LDBGetText("CharStatSkillGUI", "LoadBuildBody");

            m_ConfirmPanel.m_InputTextField._visible = false;
            PopulateGearIcons(m_ConfirmPanel, GearManager.GetBuild(m_Builds[m_SelectedIndex]));
            
            m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "Load");
            showGearIcons = false;
        }

        m_ConfirmPanel._x = m_Width + 20;
        m_ConfirmPanel._y = -50;
        
        if (m_UserInput)
        {
            m_ValidatorText = m_ConfirmPanel.m_InputTextField.m_NameText.textField;

            if (m_Action != ACTION_OVERWRITE)
            {
                Key.addListener(this);
                
                m_Validator = m_ConfirmPanel.m_InputTextField.m_Validator;
                
                m_ValidatorText.onChanged = Delegate.create(this, VerifyBuildName);            
            }

            if (m_Action == ACTION_OVERWRITE)
            {
                m_ConfirmPanel.m_InputTextField.m_Validator.gotoAndStop("accept");
                m_ConfirmPanel.m_PositiveButton.disabled = false;
            }
        }
        
        if (!showGearIcons)
        {
            var iconsHeight:Number = m_ConfirmPanel.m_GearBackground._height;
            m_ConfirmPanel.m_PositiveButton._y -= iconsHeight;
            m_ConfirmPanel.m_NegativeButton._y -= iconsHeight;
            m_ConfirmPanel.m_Background._height -= iconsHeight;
            m_ConfirmPanel.m_ConfirmDropShadow._height -= iconsHeight;
            m_ConfirmPanel.m_GearBackground._visible = false;
            m_ConfirmPanel.m_GearIcons._visible = false;
            m_ConfirmPanel.m_GearCheckBoxes._visible = false;
        }

        m_CheckInterval = setInterval(CheckDialogComponentsInitialized, 20, this);
        
        m_ConfirmPanel.m_Background.onPress =  Delegate.create(this, ConfirmPanelMoveDragHandler);
        m_ConfirmPanel.m_Background.onRelease = m_ConfirmPanel.m_Background.onReleaseOutside = Delegate.create(this, ConfirmPanelMoveDragReleaseHandler);
    }
    
    //Check Dialog Components Initialized
    private function CheckDialogComponentsInitialized(scope:Object):Void
    {
        if  (
            scope.m_ConfirmPanel.m_InputTextField.m_NameText.initialized  &&
            scope.m_ConfirmPanel.m_NegativeButton.initialized             &&
            scope.m_ConfirmPanel.m_PositiveButton.initialized
            )
        {
            clearInterval(scope.m_CheckInterval);
            m_CheckInterval = undefined;
            
            if (scope.m_UserInput)
            {
                if (!scope.m_UserInputUnlimitedChars)
                {
                    scope.m_ConfirmPanel.m_InputTextField.m_NameText.maxChars = 30;
                }
                
                scope.m_UserInputUnlimitedChars = false;
                scope.m_ConfirmPanel.m_PositiveButton.disabled = true;
                
                Selection.setFocus(scope.m_ConfirmPanel.m_InputTextField.m_NameText.textField);
                Selection.setSelection(scope.m_ConfirmPanel.m_InputTextField.m_NameText.textField);
            }
            else
            {
                Selection.setFocus(null);
            }
            
            scope.m_ConfirmPanel.m_NegativeButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
            scope.m_ConfirmPanel.m_PositiveButton.label = scope.m_PositiveLabel;
            
            scope.m_ConfirmPanel.m_NegativeButton.addEventListener("click", scope, "NegativeButtonClickHandler");
            scope.m_ConfirmPanel.m_PositiveButton.addEventListener("click", scope, "PositiveButtonClickHandler");
        }
    }
    
    //On Key Up
    private function onKeyUp():Void
    {
        if (Key.getCode() == Key.ENTER)
        {
            if (m_IsConfimationPanelOpen)
            {
                PositiveButtonClickHandler();
            }
            
            Key.removeListener(this);
        }
        else if (Key.getCode() == Key.ESCAPE)
        {
            if (m_IsConfimationPanelOpen)
            {
                NegativeButtonClickHandler();
            }
            
            Key.removeListener(this);
        }
    }
    
    //Confirm Panel Move Drag Handler
    private function ConfirmPanelMoveDragHandler():Void
    {
        m_ConfirmPanel.startDrag();
    }
    
    //Confirm Panel Move Drag Release Handler
    private function ConfirmPanelMoveDragReleaseHandler():Void
    {
        m_ConfirmPanel.stopDrag();
    }
    
    //Error Panel Move Drag Handler
    private function m_ErrorPanelMoveDragHandler():Void
    {
        m_ErrorPanel.startDrag();
    }
    
    //Error Panel Move Drag Release Handler
    private function m_ErrorPanelMoveDragReleaseHandler():Void
    {
        m_ErrorPanel.stopDrag();
    }
    
    //Positive Button Click Handler
    private function PositiveButtonClickHandler(event:Object):Void
    {
        if (m_Action == ACTION_RENAME)
        {
            GearManager.RenameBuild(m_Builds[m_SelectedIndex], m_ValidatorText.text)
            
            if (m_Target.panel == m_ViewPanel)
            {
                m_ViewPanel.textField.text = m_ValidatorText.text
            }
        }
        else if (m_Action == ACTION_IMPORT)
        {
            GearManager.DecodeGearLink(String(m_ValidatorText.text));
        }
        else if (m_Action == ACTION_CREATE)
        {
            GearManager.CreateBuild(String(m_ValidatorText.text), GetGearSelectionFlags());
        }
        else if (m_Action == ACTION_OVERWRITE)
        {
            var oldBuildName:String = m_Builds[m_SelectedIndex];
            var newBuildName:String = String(m_ValidatorText.text);
            
            if (oldBuildName != newBuildName)
            {
                GearManager.RenameBuild(oldBuildName, newBuildName);
            }
            GearManager.CreateBuild(newBuildName, GetGearSelectionFlags());
        }
        else if (m_Action == ACTION_DELETE)
        {
            GearManager.DeleteBuild(m_Builds[m_SelectedIndex]);
            
            SetSelectedIndex(-1);
        }
        else if (m_Action == ACTION_LOAD)
        {
            GearManager.UseBuild(m_Builds[m_SelectedIndex]);
        }
        
        NegativeButtonClickHandler();
        SetSelectedIndex(-1);
        
        if (m_Target.panel._name != m_MainContent._name)
        {
            OpenPanel(m_MainContent);
        }
    }
    
    //Get the flags from the Checkboxes to select Gear sections
    private function GetGearSelectionFlags():Number
    {
        var flags:Number = 0;
        
        if (m_ConfirmPanel.m_GearCheckBoxes.m_ActivesCheckBox.selected)
        {
            flags |= _global.Enums.GearManagerSections.e_Actives;
        }
        if (m_ConfirmPanel.m_GearCheckBoxes.m_PassivesCheckBox.selected)
        {
            flags |= _global.Enums.GearManagerSections.e_Passives;
        }
        if (m_ConfirmPanel.m_GearCheckBoxes.m_WeaponsCheckBox.selected)
        {
            flags |= _global.Enums.GearManagerSections.e_Weapons;
        }
        if (m_ConfirmPanel.m_GearCheckBoxes.m_TalismansCheckBox.selected)
        {
            flags |= _global.Enums.GearManagerSections.e_Talismans;
        }
        
        return flags;
    }
    
    //Negative Button Click Handler
    private function NegativeButtonClickHandler(event:Object):Void
    {        
        CloseConfirmationPanel();
        SetButtonDisabledState(false);
        SlotGearManagerDataUpdated();
    }
    
    //Close Confirmation Panel
    private function CloseConfirmationPanel():Void
    {
        var bounds:Object = this["m_ConfirmPanel"].getBounds(this);
        var x:Number = bounds.xMin + ((bounds.xMax - bounds.xMin) * 0.1);
        
        m_IsConfimationPanelOpen = false;
        
        this["m_ConfirmPanel"].tweenTo(ANIMATION_DURATION, { _alpha:0, _xscale:80, _yscale:80, _x:x }, None.easeNone);
        this["m_ConfirmPanel"].onTweenComplete = function()
        {
            this.removeMovieClip();
        }
    }

    //Delete Build
    private function DeleteBuild():Void
    {
        SetAction(ACTION_DELETE);
        
        UpdateBuildHandler();
    }
    
    //Rename Build
    private function RenameBuild():Void
    {
        SetAction(ACTION_RENAME);
        
        UpdateBuildHandler();
    }
    
    //Import Build
    private function ImportBuild():Void
    {
        SetAction(ACTION_IMPORT);
        
        UpdateBuildHandler();
    }

    //Load Build Handler
    private function LoadBuildHandler(event:Object):Void
    {
        if (m_SelectedIndex > -1 && m_SelectedIndex < m_Builds.length)
        {
            SetAction(ACTION_LOAD);
            
            UpdateBuildHandler();
        }
    }
    
    //Slot Gear Manager Error
    private function SlotGearManagerError(errorCode:Number, message:String):Void
    {
        if (m_ErrorPanel == undefined)
        {
            m_ErrorPanel = attachMovie("GearManagerErrorConsole", "m_ErrorPanel", getNextHighestDepth());
            m_ErrorPanel.SetError(errorCode);
            m_ErrorPanel._x = m_Width + 20;
            m_ErrorPanel._y = -30;
            m_ErrorPanel.SignalClicked.Connect(CloseErrorPanel, this);
            
            m_ErrorPanel.m_Background.onPress =  Delegate.create(this, m_ErrorPanelMoveDragHandler);
            m_ErrorPanel.m_Background.onRelease = m_ErrorPanel.m_Background.onReleaseOutside = Delegate.create(this, m_ErrorPanelMoveDragReleaseHandler);
            
            SetButtonDisabledState(true);
        }
    }

    //Close Error Panel
    private function CloseErrorPanel():Void
    {
        if (m_ErrorPanel != undefined)
        {
            SetButtonDisabledState(false);
            m_ErrorPanel.SignalClicked.Disconnect();
            m_ErrorPanel.removeMovieClip();
            m_ErrorPanel = undefined;
        }
    }
    
    //List Items Manual Update
    private function ListItemsManualUpdate():Void
    {
        for (var i:Number = 0; i < MaximumBuildSlots(); i++)
        {
            var renderer:MovieClip = m_MainContent.m_Content.renderers[i - m_MainContent.m_Content.scrollBar.position];
            
            if (i < AvailableBuildSlots())
            { 
                if (renderer.data != undefined)
                {
                    renderer.disabled = false;
                    renderer._alpha = 100;
                }
                else
                {
                    renderer._alpha = 60;
                    renderer.label = LDBFormat.LDBGetText("GenericGUI", "GearManagement_Empty");
                }

                renderer.disabled = false;
            }
            else
            {
                renderer._alpha = 60;
                renderer.label = LDBFormat.LDBGetText("GenericGUI", "GearManagement_Locked");
                renderer.disabled = true;
            }
        }  
    }
    
    //Available Build Slots
    private function AvailableBuildSlots():Number
    {
        var defaultSlotsAmount:Number = com.GameInterface.Utils.GetGameTweak("FreeGearBuildSlots");
        var additionalSlotsAmount:Number = com.GameInterface.Game.Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_UnlockedGearBuildSlots);

        return defaultSlotsAmount + additionalSlotsAmount;
    }
    
    //Maximum Build Slots
    private function MaximumBuildSlots():Number
    {
        return com.GameInterface.Utils.GetGameTweak("MaxGearBuildSlots");
    }
    
    //List Items Roll Over Handler
    private function ListItemsRollOverHandler(event:Object):Void
    {
        if (event.item != undefined)
        {
            m_MainContent.m_ContentOverlay._visible = true;
            m_MainContent.m_ContentOverlay._y = event.renderer._y + 8;
        }
    }
    
    //List Items Roll Out Handler
    private function ListItemsRollOutHandler(event:Object):Void
    {
        if (event.item != undefined && !m_MainContent.m_ContentOverlay.hitTest(_root._xmouse, _root._ymouse))
        {
            m_MainContent.m_ContentOverlay._visible = false;
            SlotRollOutIcon();
        }
    }
    
    //List Items Double Click Handler
    private function ListItemsDoubleClickHandler(event:Object):Void
    {
        if (m_IsConfimationPanelOpen)
        {
            return;
        }
        
        SetSelectedIndex(event.index);
        
        Selection.setFocus(null);    
        
        if (event.index != undefined && m_Builds[event.index] != undefined) // valid index and available 
        {
            SetAction(ACTION_LOAD);
        }
        else
        {
            SetSelectedIndex(-1);
            SetAction(ACTION_CREATE);
        }
        
        UpdateBuildHandler();
    }
    
    //Set Main Content Button State
    private function SetMainContentButtonState():Void
    {
        var disabled:Boolean = (AvailableBuildSlots() - GearManager.GetBuildList().length == 0) ? true : false;
        
        if (m_SelectedIndex == -1)
        {
            m_MainContent.m_NewUpdateButton.label = LDBFormat.LDBGetText("GenericGUI", "GearManagementNew");
            m_MainContent.m_NewUpdateButton.disabled = disabled;
            m_MainContent.m_LoadButton.disabled = true;
        }
        else
        {
            m_MainContent.m_NewUpdateButton.label = LDBFormat.LDBGetText("GenericGUI", "GearManagementUpdate");
            m_MainContent.m_NewUpdateButton.disabled = false;
            m_MainContent.m_LoadButton.disabled = false;
        }
        
        m_MainContent.m_ImportButton.disabled = disabled;
    }
    
    //List Items Scroll Handler
    private function ListItemsScrollHandler(event:Object):Void
    {
        ListItemsManualUpdate();
        m_MainContent.m_ContentOverlay._visible = false;
    }
    
    //List Items Click Handler
    private function ListItemsClickHandler(event:Object):Void
    {
        /*
         * Checks if the ListItemRenderer is valid and has content, evaluates
         * wether the view or rename  buttons was clicked, sets the saveaction and calls methods
         * 
         */

        if (m_IsConfimationPanelOpen)
        {
            return;
        }
        
        if (event.index != undefined && m_Builds[event.index] != undefined) // valid index and available 
        {
            SetSelectedIndex(event.index);
            SetAction(ACTION_OVERWRITE);
        }
        else
        {
            SetSelectedIndex(-1);
            SetMainContentButtonState();
            SetAction(ACTION_CREATE);
        }
        
        SetMainContentButtonState();
        Selection.setFocus(null);
    }
}
