//Imports
import gfx.utils.Delegate;
import GUI.CharacterSheet.StatPage;
import GUI.CharacterSheet.GearManagerComponent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import com.Components.ItemSlot;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Game.Camera;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.MathLib.Vector3;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Lore;
import com.GameInterface.LoreBase;
import com.GameInterface.LoreNode;
import com.GameInterface.SkillsBase;
import com.GameInterface.DistributedValue;
import com.Utils.DragObject;
import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.Utils.Archive;


var s_ResolutionScale = DistributedValue.Create( "GUIResolutionScale" );

var LEFT_GROUP_X:Number;
var LEFT_GROUP_Y:Number;
var PANEL_PADDING:Number;
var SCALE:Number;
var LEFT_MENU_HEIGHT:Number;

var LEFT_MENU_NONE:Number = 0;
var LEFT_MENU_CHARACTERSTATS:Number = 1;
var LEFT_MENU_FACTIONRANK:Number = 2;
var LEFT_MENU_GEARMANAGER:Number = 3;
var LEFT_MENU_DRESSINGROOM:Number = 4;

var NAMEBOX_HEIGHT:Number;

var m_WeaponSlots:Array;
var m_Faction:Number; 
var m_TweenSpeed:Number = 0.2;

//View Panels
var m_ActivePanel:MovieClip;
var m_CharacterStatistics:MovieClip;
var m_FactionRank:MovieClip;
var m_DressingRoom:MovieClip;
var m_GearManager:MovieClip;
var m_EquipmentSlots:MovieClip;
var m_NameBox:MovieClip;
var m_LeftMenu:MovieClip;
var m_LeftMenuLine:MovieClip;

var m_FadeLine:MovieClip;

var m_Inventory:Inventory;
var m_ItemSlots:Object;
var m_Character:Character;

var m_GlowFilter:GlowFilter;

var m_LeftMenuSelectedIndex:Number;
var m_LeftMenuSelectedIndexLoaded:Number;
var m_Initialized:Boolean;

function onLoad():Void
{
    LEFT_MENU_HEIGHT = m_LeftMenu._height;
    NAMEBOX_HEIGHT = m_NameBox._height - 20;
    PANEL_PADDING = 10;
    SCALE = 1;
    
    m_DressingRoom._visible = false;
    m_GearManager._visible = false;
    m_CharacterStatistics._visible = false;
    m_FactionRank._visible = false;

    m_NameBox._alpha = 0;
    
    m_Character = Character.GetClientCharacter();
    m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
    m_Faction = m_Character.GetStat( _global.Enums.Stat.e_PlayerFaction );
    
    Stage.addListener( this );

    m_Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharID().GetInstance()));
    m_Inventory.SignalItemAdded.Connect( SlotItemAdded, this);
    m_Inventory.SignalItemAdded.Connect( SlotItemLoaded, this);
    m_Inventory.SignalItemMoved.Connect( SlotItemMoved, this);
    m_Inventory.SignalItemRemoved.Connect( SlotItemRemoved, this);
    m_Inventory.SignalItemChanged.Connect( SlotItemChanged, this);
    m_Inventory.SignalItemStatChanged.Connect( SlotItemStatChanged, this);
    
    m_ItemSlots = new Object;
    
    /*
     * Timeline movie clips are added at very low negative depths, while programatically added 
     * movieclips are added at zero-indexed, assending depths.  This caused problems with m_FadeLine
     * always appearing above Character Sheet popup windows.
     * 
     * The depth of -16,384 is the lowest depth for AS2.  This Depth is below all popup windows.
     * 
     */

    m_FadeLine = createEmptyMovieClip("m_FadedLines", -16384); 
    
    gfx.managers.DragManager.instance.addEventListener( "dragBegin", this, "onDragBegin" );
    gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );
    
    m_GlowFilter = new GlowFilter();
    m_GlowFilter.alpha = 1;
    m_GlowFilter.color = 0x222222;
    m_GlowFilter.blurX = 1;
    m_GlowFilter.blurY = 1;
    m_GlowFilter.inner = false;
    m_GlowFilter.strength = 15;

    SetTalismanPanel();
    SetWeaponBox();
    SetNameBox();
    CreateMenu();
    
    SetMaxEquippedWeapons(m_Character.GetStat(_global.Enums.Stat.e_MaxEquippedWeapons));
    
    Lore.SignalTagAdded.Connect(SlotTagAdded, this);

    for ( var i:Number = 0 ; i < m_Inventory.GetMaxItems(); ++i )
        {
        if (m_ItemSlots[i] != undefined && m_Inventory.GetItemAt(i) != undefined)
        {
            m_ItemSlots[i].SetData(m_Inventory.GetItemAt(i));
            m_ItemSlots[i].GetSlotMC().m_Watermark._visible = false;
        }
    }
    
    m_LeftMenuSelectedIndex = LEFT_MENU_NONE;
    m_LeftMenuSelectedIndexLoaded = LEFT_MENU_NONE;
    
    UpdateNumWeapons();
    
    ResizeHandler();
}

function onUnload():Void
{
    if (m_Character)
    {
        m_Character.SignalStatChanged.Connect(SlotStatChanged, this);
    }
    
    Stage.removeListener( this );
    
    gfx.managers.DragManager.instance.removeEventListener( "dragBegin", this, "onDragBegin" );
    gfx.managers.DragManager.instance.removeEventListener( "dragEnd", this, "onDragEnd" );
    
    Lore.SignalTagAdded.Disconnect(SlotTagAdded, this);
}

function SlotTagAdded(tagId:Number, characterId:ID32)
{
    if (!characterId.Equal(Character.GetClientCharID()))
    {
        return;
    }
    if (Lore.GetTagType(tagId) != _global.Enums.LoreNodeType.e_FactionTitle && Lore.GetTagType(tagId) != _global.Enums.LoreNodeType.e_Title)
    {
        return;
    }
    UpdateTitleDropdownContents();
}

function RemoveFocus()
{
    Selection.setFocus(null);
}

function ResizeHandler( h, w ,x, y )
{    
    LEFT_GROUP_X = Stage.width/2 - 100;
    LEFT_GROUP_Y = Stage.height / 2 - 30;
    
    m_EquipmentSlots._x = Stage.width / 2 + 80;
    m_EquipmentSlots._y = Stage.height/2 - 70
    m_EquipmentSlots._alpha = 0;
    
    m_NameBox._x = LEFT_GROUP_X - m_NameBox._width - 30;
    m_NameBox._y = LEFT_GROUP_Y;
    
    InitializePositions();
}

function InitializePositions()
{
    m_Initialized = false;
    
    
    m_NameBox.tweenTo(m_TweenSpeed, { _x: LEFT_GROUP_X - m_NameBox._width - 8, _y: LEFT_GROUP_Y, _alpha: 100 }, Strong.EaseOut);
    m_NameBox.onTweenComplete = function()
    {
        if (m_LeftMenuSelectedIndexLoaded != LEFT_MENU_NONE)
        {
            OpenSelectedMenu();
        }
        m_Initialized = true;
        this.onTweenComplete = undefined;
    }
    m_NameBox._xscale = m_NameBox._yscale = 100 * SCALE;
    
    m_EquipmentSlots.tweenTo(m_TweenSpeed, { _x: Stage.width/2 + 90, _y: Stage.height / 2 - 80, _alpha: 100 }, Strong.EaseOut);
    m_EquipmentSlots.onTweenComplete = function() { DrawFadeLines(); };
    m_EquipmentSlots._xscale = m_EquipmentSlots._yscale = 100 * SCALE;
    
    m_LeftMenu._y = LEFT_GROUP_Y + NAMEBOX_HEIGHT + PANEL_PADDING + 3;
    m_LeftMenu._x = LEFT_GROUP_X - m_LeftMenu._width - 5;
    
    m_LeftMenu.tweenFrom(m_TweenSpeed, {_y: LEFT_GROUP_Y + NAMEBOX_HEIGHT, alpha: 0 }, Strong.easeOut );
    
    m_CharacterStatistics._x = m_LeftMenu._x - m_CharacterStatistics.m_StatPagePanelBackground._width - PANEL_PADDING;
    m_FactionRank._x = m_LeftMenu._x - m_FactionRank._width - PANEL_PADDING;
    
    
    m_LeftMenuLine._y = LEFT_GROUP_Y;
    m_LeftMenuLine._x = LEFT_GROUP_X;
    m_LeftMenuLine._height = 150;
}


function OnModuleActivated(archive:Archive)
{
    m_LeftMenuSelectedIndexLoaded = archive.FindEntry("SelectedLeftMenuIndex", LEFT_MENU_NONE);
    if (m_Initialized)
    {
        OpenSelectedMenu();
    }
}

    
function OnModuleDeactivated()
{
    var archive:Archive = new Archive();
     
    archive.AddEntry("SelectedLeftMenuIndex", m_LeftMenuSelectedIndex);
    
    return archive;
}

function OpenSelectedMenu()
{
        switch(m_LeftMenuSelectedIndexLoaded)
    {
        case LEFT_MENU_CHARACTERSTATS:
            OpenCharacterStatistics();
            break;
        case LEFT_MENU_FACTIONRANK:
            OpenFactionRank();
            break;
        case LEFT_MENU_GEARMANAGER:
            OpenGearManager();
            break;
        case LEFT_MENU_DRESSINGROOM:
            OpenDressingRoom();
            break;
    }
}

function DrawFadeLines()
{
    m_FadedLines.clear();
    var headFrom:Point = new Point(m_EquipmentSlots._x + m_EquipmentSlots.icon_chakra_7._x, m_EquipmentSlots._y + m_EquipmentSlots.icon_chakra_7._y + m_EquipmentSlots.icon_chakra_7.m_Stroke._height/2 + 5);
    var headTo:Point = new Point(m_EquipmentSlots._x - 65,  m_EquipmentSlots._y + 106);
        
    var majorFrom:Point = new Point(m_EquipmentSlots._x + m_EquipmentSlots.icon_chakra_4._x - 1, m_EquipmentSlots._y + m_EquipmentSlots.icon_chakra_4._y + m_EquipmentSlots.icon_chakra_4.m_Stroke._height/2);
    var majorTo:Point = new Point(m_EquipmentSlots._x - 50,  m_EquipmentSlots._y + m_EquipmentSlots.icon_chakra_4._y + m_EquipmentSlots.icon_chakra_4._height/2 + 6);
        
    var minorFrom:Point = new Point(m_EquipmentSlots._x + m_EquipmentSlots.icon_chakra_1._x - 1, m_EquipmentSlots._y + m_EquipmentSlots.icon_chakra_1._y + m_EquipmentSlots.icon_chakra_1.m_Stroke._height/2);
    var minorTo:Point = new Point(m_EquipmentSlots._x - 40, m_EquipmentSlots._y + m_EquipmentSlots.icon_chakra_1._y + 10 );
        
    var weaponFrom:Point = new Point(m_EquipmentSlots._x + m_EquipmentSlots.icon_firstweapon._x - 1 , m_EquipmentSlots._y + m_EquipmentSlots.icon_firstweapon._y + m_EquipmentSlots.icon_firstweapon.m_Stroke._height/2);
    var weaponTo:Point = new Point(m_EquipmentSlots._x - 80,  m_EquipmentSlots._y + m_EquipmentSlots.icon_firstweapon._y - 30 );
        
    var leftMenuFrom:Point = new Point(m_LeftMenuLine._x + m_LeftMenuLine._width, LEFT_GROUP_Y + 80);
    var leftMenuTo:Point = new Point(m_LeftMenuLine._x + 50, LEFT_GROUP_Y + 80);
        
    DrawFadedLines(weaponFrom, weaponTo, 70, 185);
    DrawFadedLines(headFrom, headTo, 70, 185);
    DrawFadedLines(majorFrom, majorTo, 70, 185);
    DrawFadedLines(minorFrom, minorTo, 70, 285);
    DrawFadedLines(leftMenuFrom, leftMenuTo, 70, 285);
}

//Update Position
function UpdatePosition():Void
{
//    var camDist:Number = m_Character.GetCameraDistance();
    var camDist:Number =  Camera.GetZoom();
    var pos:Point = m_Character.GetScreenPosition(128);

    
    var scaleAt1Meter = 3;

    var minScale = 0.7;
    var maxScale = Math.min( 1.7, 1.45 * Stage.width / 1024 );
    var scale:Number = (camDist > 0) ? Math.min( maxScale, scaleAt1Meter / camDist ) : maxScale;

    pos.y -= 15 + 45 * scale;

    scale = Math.max( minScale, scale );
    
    if ( pos.x < 0 ) // Camera to close to make a projection
    {
        pos.x = Stage.width * 0.5;
        pos.y = Stage.height * 0.9;
    }
        
    _xscale = scale * 100;
    _yscale = scale * 100;
        
    var newPosX:Number = pos.x - Stage.width * scale * 0.5;
    var newPosY:Number = pos.y - Stage.height * scale * 0.5;
    var wasCapped:Boolean = false;

    var viewportLeft = 20;
    var viewportRight = Stage.width - 20;
    var viewportBottom = Stage.height - 100 * s_ResolutionScale.GetValue();
    
    if ( m_ActivePanel && newPosX < viewportLeft - m_ActivePanel._x * scale )
    {
        newPosX = viewportLeft - m_ActivePanel._x * scale;
        wasCapped = true;
    }
    else if ( newPosX > viewportRight - (m_EquipmentSlots._x + m_EquipmentSlots._width) * scale )
    {
        newPosX = viewportRight - (m_EquipmentSlots._x + m_EquipmentSlots._width) * scale;
        wasCapped = true;
    }
        
    if ( newPosY > viewportBottom - (m_EquipmentSlots._y + m_EquipmentSlots._height) * scale )
    {
        newPosY = viewportBottom - (m_EquipmentSlots._y + m_EquipmentSlots._height) * scale;
        wasCapped = true;
    }
        
    _x = newPosX;
    _y = newPosY;
        
    m_FadeLine._visible = !wasCapped;
}

function onEnterFrame():Void
{
    UpdatePosition();
}


//Slot Delete Item
function SlotDeleteItem(itemSlot:ItemSlot):Void
{
    var isGM:Boolean = m_Character.GetStat(_global.Enums.Stat.e_GmLevel) != 0;
    var isInCombat:Boolean = m_Character.IsInCombat();
    
    if ((itemSlot.GetData().m_Deleteable || isGM) && !isInCombat)
    {
        var dialogText:String = LDBFormat.Printf(LDBFormat.LDBGetText("Gamecode", "ConfirmDeleteItem"), itemSlot.GetData().m_Name);
        var dialogIF = new com.GameInterface.DialogIF( dialogText, Enums.StandardButtons.e_ButtonsYesNo, "DeleteItem" );
        dialogIF.SignalSelectedAS.Connect( SlotDeleteItemDialog, this );
        dialogIF.Go( itemSlot.GetSlotID() ); // <-  the slotid is userdata.
    }
}

//Slot Delete Item Dialog
function SlotDeleteItemDialog(buttonID:Number, itemSlotID:Number):Void
{
    if (buttonID == _global.Enums.StandardButtonID.e_ButtonIDYes)
    {
        m_Inventory.DeleteItem(itemSlotID);
    }
}

//Create Fade Matrix
function CreateFadeMatrix(from:Point, to:Point):Matrix
{
    var matrix:Matrix = new Matrix();
    var dist:Point = new Point(to.x - from.x, to.y - from.y);
    var angle:Number = Math.atan2(dist.y, dist.x);
    var length:Number = Math.sqrt(dist.x * dist.x + dist.y * dist.y);
    
    var min:Number = Math.min(Math.abs(dist.x), Math.abs(dist.y));
    var mmax:Number = Math.sqrt(length * length + min * min);
    var rmax:Number = (mmax - length);
    
    matrix.createGradientBox(mmax, mmax, angle, Math.min(from.x, to.x) - rmax, Math.min(from.y, to.y) - rmax); 
    return matrix;
}

//Draw Faded Lines
function DrawFadedLines(from:Point, to:Point, fadeStart:Number, fadeEnd:Number):Void
{
    var matrix:Matrix = CreateFadeMatrix(from,to);
    m_FadeLine.lineStyle(0.5);
    m_FadeLine.lineGradientStyle("linear", [0xFFFFFF, 0xFFFFFF], [70,0], [fadeStart,fadeEnd], matrix)
    m_FadeLine.moveTo(from.x, from.y);
    m_FadeLine.lineTo(to.x, to.y);
    
    m_FadeLine._xscale = m_FadeLine._yscale = 100 * SCALE;
    
    m_FadeLine._alpha = 0;
    m_FadeLine.tweenTo(m_TweenSpeed, {_alpha: 100}, Strong.easeOut );
}


//Set Name Box
function SetNameBox():Void
{
    var currentTag:LoreNode = Lore.GetCurrentFactionRankNode();
    
    m_NameBox.m_TitleDropdown.disableFocus = true;
    
    m_NameBox.m_FactionRankIcon.source = "rdb:" + _global.Enums.RDBID.e_RDB_FlashFile + ":" + currentTag.m_Icon;
    m_NameBox.m_FactionRankIcon._x = m_NameBox.m_CharacterName._x + m_NameBox.m_CharacterName._width + 4;
    m_NameBox.m_FactionRankIcon._y = -6;
    
    m_NameBox.m_CharacterName.text = m_Character.GetFirstName() + " " + '"' + m_Character.GetName() + '"' + " " + m_Character.GetLastName();
    
    m_NameBox.m_TitleDropdown.autoSize = "right";
    m_NameBox.m_TitleDropdown.dropdownWidth = 180;
    
    UpdateTitleDropdownContents();
    
    m_NameBox.m_TitleDropdown.rowCount = 13;
    UpdateDropdownScrollingListOffset();
    m_NameBox.m_TitleDropdown.addEventListener("change", this, "TitleSelected");
}

function RemoveFocusOnDropdown()
{
    RemoveFocus();
}

function UpdateTitleDropdownContents() : Void
{
    var array:Array = Lore.GetTitleArray();
    var tag:Number = m_Character.GetStat(_global.Enums.Stat.e_SelectedTag);
    m_NameBox.m_TitleDropdown.dataProvider = array;
    for ( var i:Number = 0; i < array.length; ++i )
    {
        if (array[i].id == tag)
        {
            m_NameBox.m_TitleDropdown.selectedIndex = i;
            break;
        }
    }
}

function TitleSelected(event:Object) : Void
{
    var newTitle:Number = m_NameBox.m_TitleDropdown.dataProvider[ event.target.selectedIndex ].id;
    if (newTitle != m_Character.GetStat(_global.Enums.Stat.e_SelectedTag))
    {
        Lore.SetSelectedTag(newTitle);
    }
    UpdateDropdownScrollingListOffset();
}

function UpdateDropdownScrollingListOffset()
{
    m_NameBox.m_TitleDropdown.offsetX = -(m_NameBox.m_TitleDropdown.dropdownWidth - m_NameBox.m_TitleDropdown._width);
    RemoveFocus();
}

//Set Faction Name
function SetFactionName(playerFaction:Number):String
{
    var factionName:String;
    
    switch(playerFaction)
    {
        case _global.Enums.Factions.e_FactionDragon:        factionName = LDBFormat.LDBGetText( "FactionNames", "Dragon" );
                                                            break;
                                                            
        case _global.Enums.Factions.e_FactionIlluminati:    factionName = LDBFormat.LDBGetText( "FactionNames", "Illuminati" );
                                                            break
                                                            
        case _global.Enums.Factions.e_FactionTemplar:       factionName = LDBFormat.LDBGetText( "FactionNames", "Templars" );
    }
        
    return factionName;
}

//Create Menu
function CreateMenu():Void
{    
    m_LeftMenu.m_MenuButton1.label = LDBFormat.LDBGetText("GenericGUI", "CharacterStats");
    m_LeftMenu.m_MenuButton2.label = LDBFormat.LDBGetText("GenericGUI", "FactionRankHeader");
    m_LeftMenu.m_MenuButton3.label = LDBFormat.LDBGetText("GenericGUI", "GearManagement");
    m_LeftMenu.m_MenuButton4.label = LDBFormat.LDBGetText("GenericGUI", "DressingRoom");
    
    m_LeftMenu.m_MenuButton1.addEventListener("select", this, "ToggleCharacterStatistics");
    m_LeftMenu.m_MenuButton2.addEventListener("select", this, "ToggleFactionRank");
    m_LeftMenu.m_MenuButton3.addEventListener("select", this, "ToggleGearManager");
    m_LeftMenu.m_MenuButton4.addEventListener("select", this, "ToggleDressingRoom");
    
    if (com.GameInterface.PvPMinigame.PvPMinigame.InMatchPlayfield())
    {
        m_LeftMenu.m_MenuButton4.disabled = true;
    }
}

//Set Chakra Box
function SetTalismanPanel():Void
{
    m_EquipmentSlots.m_HeaderTalismanHead.text = LDBFormat.LDBGetText("GenericGUI", "HeadTalisman");
    m_EquipmentSlots.m_HeaderTalismanMajor.text = LDBFormat.LDBGetText("GenericGUI", "MajorTalismans");
    m_EquipmentSlots.m_HeaderTalismanMinor.text = LDBFormat.LDBGetText("GenericGUI", "MinorTalismans");
    
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_1, m_EquipmentSlots.icon_chakra_1)
    
    
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_2, m_EquipmentSlots.icon_chakra_2);
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_3, m_EquipmentSlots.icon_chakra_3);
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_4, m_EquipmentSlots.icon_chakra_4);
    
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_5, m_EquipmentSlots.icon_chakra_5);
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_6, m_EquipmentSlots.icon_chakra_6);
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_7, m_EquipmentSlots.icon_chakra_7);
    
    
    AddSimpleTooltips(_global.Enums.ItemEquipLocation.e_Chakra_1);
    AddSimpleTooltips(_global.Enums.ItemEquipLocation.e_Chakra_2);
    AddSimpleTooltips(_global.Enums.ItemEquipLocation.e_Chakra_3);
    AddSimpleTooltips(_global.Enums.ItemEquipLocation.e_Chakra_4);
    AddSimpleTooltips(_global.Enums.ItemEquipLocation.e_Chakra_5);
    AddSimpleTooltips(_global.Enums.ItemEquipLocation.e_Chakra_6);
    AddSimpleTooltips(_global.Enums.ItemEquipLocation.e_Chakra_7);
}

//Set Weapon Box
function SetWeaponBox():Void
{
    m_EquipmentSlots.m_Title.text = LDBFormat.LDBGetText("GenericGUI", "Weapons");
    m_EquipmentSlots.m_AuxilliaryTitle.text = LDBFormat.LDBGetText("GenericGUI", "Auxilliary");
    
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot, m_EquipmentSlots.icon_firstweapon);
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot, m_EquipmentSlots.icon_secondweapon);
    InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot, m_EquipmentSlots.icon_thirdweapon);
    
    m_WeaponSlots = [];
    
    m_WeaponSlots.push(m_ItemSlots[ _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ]);
    m_WeaponSlots.push(m_ItemSlots[ _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot ]);
    m_WeaponSlots.push(m_ItemSlots[ _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot ]);
}

function ToggleCharacterStatistics(e:Object)
{
    if ( e.target.selected )
    {
        OpenCharacterStatistics();
        m_LeftMenu.m_MenuButton1.disabled = true;
    }
    else
    {
        CloseCharacterStatistics();
        m_LeftMenu.m_MenuButton1.disabled = false;
    }
}

function OpenCharacterStatistics()
{
    m_CharacterStatistics.m_CloseButton.addEventListener("click", this, "SetLeftMenuBasicState");
    if (m_LeftMenuSelectedIndex != LEFT_MENU_CHARACTERSTATS)
    {
        SkillsBase.UpdateAllSkills();
        
        var characterStatsHeight = m_CharacterStatistics.m_StatPagePanelBackground._height;
        
        m_CharacterStatistics._visible = true;
        m_CharacterStatistics._alpha = 0;
        m_TotalLeftHeight = LEFT_MENU_HEIGHT + NAMEBOX_HEIGHT + characterStatsHeight;
        
        m_LeftMenuLine.tweenTo(m_TweenSpeed, { _height: m_TotalLeftHeight, _y: (Stage.height / 2) -  (m_TotalLeftHeight / 2) - PANEL_PADDING }, Strong.easeOut);
        m_LeftMenu.tweenTo(m_TweenSpeed, { _y: (Stage.height/2) - (m_TotalLeftHeight/2) + (NAMEBOX_HEIGHT + PANEL_PADDING) }, Strong.easeOut);
        m_LeftMenu.onTweenComplete = function()
        {
            m_CharacterStatistics._y = m_LeftMenu._y;
            m_CharacterStatistics.tweenTo(m_TweenSpeed*2, { _alpha: 100 }, Strong.easeInOut);
            m_LeftMenu.m_MenuButton1.tweenTo(m_TweenSpeed, { _alpha: 0 }, Strong.easeOut);
            m_LeftMenu.m_MenuButton2.tweenTo(m_TweenSpeed, { _alpha: 100, _y: characterStatsHeight }, Strong.easeOut);
            m_LeftMenu.m_MenuButton3.tweenTo(m_TweenSpeed, { _alpha: 100, _y: characterStatsHeight + m_LeftMenu.m_MenuButton2._height }, Strong.easeOut);
            m_LeftMenu.m_MenuButton4.tweenTo(m_TweenSpeed, { _alpha: 100, _y: characterStatsHeight+ m_LeftMenu.m_MenuButton3._height * 2 }, Strong.easeOut);
            
            CloseFactionRank();
            CloseDressingRoom();
            CloseGearManager();
            
        }
        m_ActivePanel = m_CharacterStatistics;
        m_NameBox.tweenTo(m_TweenSpeed, { _y: (Stage.height / 2) -  (m_TotalLeftHeight / 2) - PANEL_PADDING }, Strong.easeOut);
        
        m_CharacterStatistics._x = LEFT_GROUP_X - m_CharacterStatistics.m_StatPagePanelBackground._width - PANEL_PADDING;
        
        m_CharacterStatistics.onTweenComplete = function()
        {
            m_LeftMenuSelectedIndex = LEFT_MENU_CHARACTERSTATS;
        }
    }
}

function CloseCharacterStatistics()
{
    m_LeftMenu.m_MenuButton1.selected = false;
    if( m_LeftMenuSelectedIndex == LEFT_MENU_CHARACTERSTATS)
    {
        m_CharacterStatistics.tweenTo(m_TweenSpeed, { _alpha: 0 }, Strong.easeOut);
        m_CharacterStatistics.onTweenComplete = function()
        {
            m_CharacterStatistics._visible = false;
            m_LeftMenuSelectedIndex = LEFT_MENU_NONE;
        }
    }
}

function ToggleFactionRank(e:Object)
{
    if ( e.target.selected )
    {
        OpenFactionRank();
        m_LeftMenu.m_MenuButton2.disabled = true;
        
    }
    else
    {
        CloseFactionRank();
        m_LeftMenu.m_MenuButton2.disabled = false;
    }
}

function OpenFactionRank()
{
    m_FactionRank.m_CloseButton.addEventListener("click", this, "SetLeftMenuBasicState");
    
    if (m_LeftMenuSelectedIndex != LEFT_MENU_FACTIONRANK)
    {
        m_FactionRank._visible = true;
        m_FactionRank._alpha = 0;
        m_TotalLeftHeight = LEFT_MENU_HEIGHT + NAMEBOX_HEIGHT + m_FactionRank._height;
        
        m_LeftMenuLine.tweenTo(m_TweenSpeed, { _height: m_TotalLeftHeight, _y: (Stage.height / 2) -  (m_TotalLeftHeight / 2) - PANEL_PADDING }, Strong.easeOut);
        m_LeftMenu.tweenTo(m_TweenSpeed, { _y: (Stage.height/2) - (m_TotalLeftHeight/2) + (NAMEBOX_HEIGHT + PANEL_PADDING) }, Strong.easeOut);
        m_LeftMenu.onTweenComplete = function()
        {
            m_FactionRank._y = m_LeftMenu._y + m_LeftMenu.m_MenuButton2._height;
            m_FactionRank.tweenTo(m_TweenSpeed*2, { _alpha: 100 }, Strong.easeInOut);
            m_LeftMenu.m_MenuButton1.tweenTo(m_TweenSpeed, { _alpha: 100 }, Strong.easeOut);
            m_LeftMenu.m_MenuButton2.tweenTo(m_TweenSpeed, { _alpha: 0, _y: m_FactionRank._height }, Strong.easeOut);
            m_LeftMenu.m_MenuButton3.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_FactionRank._height + m_LeftMenu.m_MenuButton2._height }, Strong.easeOut);
            m_LeftMenu.m_MenuButton4.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_FactionRank._height + m_LeftMenu.m_MenuButton3._height * 2 }, Strong.easeOut);
            
            CloseCharacterStatistics();
            CloseDressingRoom();
            CloseGearManager();
        }
        m_ActivePanel = m_FactionRank;
        m_NameBox.tweenTo(m_TweenSpeed, { _y: (Stage.height / 2) -  (m_TotalLeftHeight / 2) - PANEL_PADDING }, Strong.easeOut);
        
        m_FactionRank._x = LEFT_GROUP_X - m_FactionRank._width - PANEL_PADDING;
        
        m_FactionRank.onTweenComplete = function()
        {
            m_LeftMenuSelectedIndex = LEFT_MENU_FACTIONRANK;
        }
    }
}

function CloseFactionRank()
{
    m_LeftMenu.m_MenuButton2.selected = false;
    if( m_LeftMenuSelectedIndex == LEFT_MENU_FACTIONRANK )
    {
        m_FactionRank.tweenTo(m_TweenSpeed, { _alpha: 0 }, Strong.easeOut);
        m_FactionRank.onTweenComplete = function()
        {
            m_FactionRank._visible = false;
            m_LeftMenuSelectedIndex = LEFT_MENU_NONE;
        }
    }
}

function ToggleDressingRoom(e:Object)
{
    
    if ( e.target.selected )
    {
        OpenDressingRoom();
        m_LeftMenu.m_MenuButton4.disabled = true;
        
    }
    else
    {
        CloseDressingRoom();
        m_LeftMenu.m_MenuButton4.disabled = false;
    }
}

function OpenDressingRoom()
{
    if (!com.GameInterface.PvPMinigame.PvPMinigame.InMatchPlayfield())
    {
        m_DressingRoom.m_CloseButton.addEventListener("click", this, "SetLeftMenuBasicState");
        if (!m_LeftMenuSelectedIndex != LEFT_MENU_DRESSINGROOM)
        {
            m_DressingRoom._visible = true;
            m_DressingRoom._alpha = 0;
            m_TotalLeftHeight = LEFT_MENU_HEIGHT + NAMEBOX_HEIGHT + m_DressingRoom._height;
            
            m_LeftMenuLine.tweenTo(m_TweenSpeed, { _height: m_TotalLeftHeight, _y: (Stage.height / 2) -  (m_TotalLeftHeight / 2) - PANEL_PADDING }, Strong.easeOut);
            m_LeftMenu.tweenTo(m_TweenSpeed, { _y: (Stage.height/2) - (m_TotalLeftHeight/2) + (NAMEBOX_HEIGHT + PANEL_PADDING) }, Strong.easeOut);
            m_LeftMenu.onTweenComplete = function()
            {
                m_DressingRoom._y = m_LeftMenu._y + m_LeftMenu.m_MenuButton1._height*3;
                m_DressingRoom.tweenTo(m_TweenSpeed*2, { _alpha: 100 }, Strong.easeInOut);
                m_LeftMenu.m_MenuButton1.tweenTo(m_TweenSpeed, { _alpha: 100 }, Strong.easeOut);
                m_LeftMenu.m_MenuButton2.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_LeftMenu.m_MenuButton1._height }, Strong.easeOut);
                m_LeftMenu.m_MenuButton3.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_LeftMenu.m_MenuButton1._height * 2 }, Strong.easeOut);
                m_LeftMenu.m_MenuButton4.tweenTo(m_TweenSpeed, { _alpha: 0, _y: m_LeftMenu.m_MenuButton1._height * 3 }, Strong.easeOut);
                
                CloseCharacterStatistics();
                CloseFactionRank();
                CloseGearManager();
            }
            m_ActivePanel = m_DressingRoom;
            m_NameBox.tweenTo(m_TweenSpeed, { _y: (Stage.height / 2) -  (m_TotalLeftHeight / 2) - PANEL_PADDING }, Strong.easeOut);
            
            m_DressingRoom._x = LEFT_GROUP_X - m_DressingRoom._width - PANEL_PADDING;
            
            m_DressingRoom.onTweenComplete = function()
            {
                m_LeftMenuSelectedIndex = LEFT_MENU_DRESSINGROOM;
            }
        }
    }
}

function CloseDressingRoom()
{
    m_LeftMenu.m_MenuButton4.selected = false;
    if( m_LeftMenuSelectedIndex == LEFT_MENU_DRESSINGROOM )
    {
        m_DressingRoom.tweenTo(m_TweenSpeed, { _alpha: 0 }, Strong.easeOut);
        m_DressingRoom.onTweenComplete = function()
        {
            m_DressingRoom._visible = false;
            m_LeftMenuSelectedIndex = LEFT_MENU_NONE;
        }
    }
}

function ToggleGearManager(e:Object)
{
    if ( e.target.selected )
    {
        OpenGearManager();
        m_LeftMenu.m_MenuButton3.disabled = true;
        
    }
    else
    {
        CloseGearManager();
        m_LeftMenu.m_MenuButton3.disabled = false;
    }
}

function OpenGearManager()
{
    m_GearManager.m_CloseButton.addEventListener("click", this, "SetLeftMenuBasicState");

    m_GearManager.SetNewUpdateButtonDisabledState(!CharacterHasBuild());
    
    if (m_LeftMenuSelectedIndex != LEFT_MENU_GEARMANAGER)
    {
        m_GearManager._visible = true;
        m_GearManager._alpha = 0;
        m_TotalLeftHeight = LEFT_MENU_HEIGHT + NAMEBOX_HEIGHT + m_GearManager._height;
        
        m_LeftMenuLine.tweenTo(m_TweenSpeed, { _height: m_TotalLeftHeight, _y: (Stage.height / 2) -  (m_TotalLeftHeight / 2) - PANEL_PADDING }, Strong.easeOut);
        m_LeftMenu.tweenTo(m_TweenSpeed, { _y: (Stage.height/2) - (m_TotalLeftHeight/2) + (NAMEBOX_HEIGHT + PANEL_PADDING) }, Strong.easeOut);
        m_LeftMenu.onTweenComplete = function()
        {
            m_GearManager._y = m_LeftMenu._y + m_LeftMenu.m_MenuButton3._height*2;
            m_GearManager.tweenTo(m_TweenSpeed*2, { _alpha: 100 }, Strong.easeInOut);
            m_LeftMenu.m_MenuButton1.tweenTo(m_TweenSpeed, { _alpha: 100 }, Strong.easeOut);
            m_LeftMenu.m_MenuButton2.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_LeftMenu.m_MenuButton3._height }, Strong.easeOut);
            m_LeftMenu.m_MenuButton3.tweenTo(m_TweenSpeed, { _alpha: 0, _y: m_LeftMenu.m_MenuButton3._height * 2 }, Strong.easeOut);
            m_LeftMenu.m_MenuButton4.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_GearManager._height + m_LeftMenu.m_MenuButton3._height * 2 }, Strong.easeOut);
            
            CloseCharacterStatistics();
            CloseFactionRank();
            CloseDressingRoom();
        }
        m_ActivePanel = m_GearManager;
        m_NameBox.tweenTo(m_TweenSpeed, { _y: (Stage.height / 2) -  (m_TotalLeftHeight / 2) - PANEL_PADDING }, Strong.easeOut);
        
        m_GearManager._x = LEFT_GROUP_X - m_GearManager._width - PANEL_PADDING;
        
        m_GearManager.onTweenComplete = function()
        {
            m_LeftMenuSelectedIndex = LEFT_MENU_GEARMANAGER;
        }
    }
}

function CloseGearManager()
{
    m_LeftMenu.m_MenuButton3.selected = false;
    if( m_LeftMenuSelectedIndex == LEFT_MENU_GEARMANAGER )
    {
        m_GearManager.Close();
        m_GearManager.tweenTo(m_TweenSpeed, { _alpha: 0 }, Strong.easeOut);
        m_GearManager.onTweenComplete = function()
        {
            m_GearManager._visible = false;
            m_LeftMenuSelectedIndex = LEFT_MENU_NONE;
        }
    }
}

function SetLeftMenuBasicState()
{
    m_LeftMenu.m_MenuButton1.tweenTo(m_TweenSpeed, { _alpha: 100, _y: 0 }, Strong.easeOut);
    m_LeftMenu.m_MenuButton2.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_LeftMenu.m_MenuButton1._y + m_LeftMenu.m_MenuButton1._height }, Strong.easeOut);
    m_LeftMenu.m_MenuButton3.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_LeftMenu.m_MenuButton1._y + m_LeftMenu.m_MenuButton1._height*2 }, Strong.easeOut);
    m_LeftMenu.m_MenuButton4.tweenTo(m_TweenSpeed, { _alpha: 100, _y: m_LeftMenu.m_MenuButton1._y + m_LeftMenu.m_MenuButton1._height*3 }, Strong.easeOut);
    
    m_NameBox.tweenTo(m_TweenSpeed, {_x: LEFT_GROUP_X - m_NameBox._width - 8, _y: LEFT_GROUP_Y, _alpha: 100 }, Strong.EaseOut);
        
    m_LeftMenu._y = LEFT_GROUP_Y + NAMEBOX_HEIGHT + PANEL_PADDING + 3;
    m_LeftMenu._x = LEFT_GROUP_X - m_LeftMenu._width - 5;
    
    m_LeftMenuLine.tweenTo(m_TweenSpeed, { _height: 150, _y: LEFT_GROUP_Y }, Strong.easeOut);
    
    CloseCharacterStatistics();
    CloseFactionRank();
    CloseDressingRoom();
    CloseGearManager();
}

//Get Faction Logo
function GetFactionLogo(faction:Number):String
{
    var factionLogo:String;
    
    switch (faction)
    {
        case _global.Enums.Factions.e_FactionDragon:        factionLogo = "LogoDragon";
                                                            break;
            
        case _global.Enums.Factions.e_FactionIlluminati:    factionLogo = "LogoIlluminati";
                                                            break;
            
        case _global.Enums.Factions.e_FactionTemplar:       factionLogo = "LogoTemplar";
                                                            break;
    }
    
    return factionLogo;        
}

//Initialize Slot
function InitializeSlot(itemPos:Number, icon:MovieClip):Void
{
    m_ItemSlots[itemPos] = new ItemSlot(m_Inventory.m_InventoryID, itemPos, icon);
    m_ItemSlots[itemPos].SignalMouseDown.Connect(SlotMouseDownItem, this);
    m_ItemSlots[itemPos].SignalMouseUp.Connect(SlotMouseUpItem, this);
    m_ItemSlots[itemPos].SignalDelete.Connect(SlotDeleteItem, this);
    m_ItemSlots[itemPos].SignalStartDrag.Connect(SlotStartDragItem, this);
}

function SlotStartDragItem(itemSlot:ItemSlot, stackSize:Number)
{
    var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, itemSlot, stackSize);
    dragObject.SignalDroppedOnDesktop.Connect(SlotItemDroppedOnDesktop, this);
}

function SlotItemDroppedOnDesktop()
{
    var currentDragObject:DragObject = DragObject.GetCurrentDragObject();

    if (currentDragObject.type == "item")
    {
        SlotDeleteItem(m_ItemSlots[currentDragObject.inventory_slot]);
    }
}

function SlotMouseDownItem(itemSlot:ItemSlot, buttonIndex:Number, clickCount:Number)
{
    if (clickCount == 2 && buttonIndex == 1)
    {
        if (m_Character != undefined)
        {
            m_Character.AddEffectPackage( "sound_fxpackage_GUI_item_slot.xml" );
        }
        m_Inventory.UseItem(itemSlot.GetSlotID());
    }
}

function SlotMouseUpItem(itemSlot:ItemSlot, buttonIndex:Number)
{
    if (buttonIndex == 2 && !Key.isDown(Key.CONTROL))
    {
        if (m_Character != undefined)
        {
            m_Character.AddEffectPackage( "sound_fxpackage_GUI_item_slot.xml" );
        }
        m_Inventory.UseItem(itemSlot.GetSlotID());
    }
}

//On Drag End
function onDragEnd(event:Object):Void
{
    if ( event.data.type == "item" )
    {
        var dstID = GetMouseSlotID();
        
        if (dstID > 0)
        {
            switch (dstID)
            {
                //Weapon Slots
                case _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot:   // Continue
                case _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot:  // Continue
                case _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot:  m_Inventory.AddItem(event.data.inventory_id, event.data.inventory_slot, dstID);
                                                                                break;
                
                //Chakras Slots
                default:    if (!event.data.inventory_id.Equal(m_Inventory.m_InventoryID))
                            {
                                var inventory:Inventory = new Inventory(event.data.inventory_id);
                                inventory.UseItem(event.data.inventory_slot);
                            }
            }
            event.data.DragHandled();
            
        }
        //Handle drag if the gear manager was hit
        if (m_LeftMenuSelectedIndex == LEFT_MENU_GEARMANAGER && m_GearManager.hitTest(_root._xmouse, _root._ymouse, true))
        {
            event.data.DragHandled();
            
            var dialogText:String = LDBFormat.LDBGetText("GenericGUI", "CannotDragItemsToGearManager");
            var dialogIF = new com.GameInterface.DialogIF( dialogText, Enums.StandardButtons.e_ButtonsOk, "CannotDragToGearManager" );
            dialogIF.Go( ); 
        }
        UnHighLightAll();
    }
}

//On Drag Begin
function onDragBegin(event:Object):Void
{
    if ( event.data.type == "item" )
    {
        var inventory:Inventory = new Inventory(event.data.inventory_id);
        var item:InventoryItem = inventory.GetItemAt(event.data.inventory_slot);
        
        for (var i in m_ItemSlots)
        {
            var itemSlot:ItemSlot = m_ItemSlots[i];
            if ( i == item.m_DefaultPosition ||  item.m_DefaultPosition == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot && i == _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot)
            {
                HighLightSlot(itemSlot.GetSlotMC(), true);
            }
        }
    }
}

//Get Mouse Slot ID
function GetMouseSlotID():Number
{
    for (var i in m_ItemSlots)
    {
        var itemSlot:ItemSlot = m_ItemSlots[i];
        
        if ( itemSlot.HitTest( _root._xmouse, _root._ymouse))
        {
            return itemSlot.GetSlotID();
        }
    }
    
    return -1;
}

//Remove Simple Tooltips
function RemoveSimpleTooltips(itemPos:Number):Void
{
    var parent:MovieClip;

    switch( itemPos )
    {
        case _global.Enums.ItemEquipLocation.e_Chakra_1:    parent = m_EquipmentSlots.icon_chakra_1;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_2:    parent = m_EquipmentSlots.icon_chakra_2;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_3:    parent = m_EquipmentSlots.icon_chakra_3;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_4:    parent = m_EquipmentSlots.icon_chakra_4;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_5:    parent = m_EquipmentSlots.icon_chakra_5;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_6:    parent = m_EquipmentSlots.icon_chakra_6;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_7:    parent = m_EquipmentSlots.icon_chakra_7;
    }
    
    delete parent.onRollOver;
    delete parent.onPress;
}

//Add Simple Tooltips
function AddSimpleTooltips(itemPos:Number):Void
{
    var text:String;
    var parent:MovieClip;
    
    switch( itemPos )
    {
        case _global.Enums.ItemEquipLocation.e_Chakra_1:    text = LDBFormat.LDBGetText("GenericGUI", "BodyChakra_shorttext");
                                                            parent = m_EquipmentSlots.icon_chakra_1;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_2:    text = LDBFormat.LDBGetText("GenericGUI", "InstinctChakra_shorttext");
                                                            parent = m_EquipmentSlots.icon_chakra_2;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_3:    text = LDBFormat.LDBGetText("GenericGUI", "MightChakra_shorttext");
                                                            parent = m_EquipmentSlots.icon_chakra_3;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_4:    text = LDBFormat.LDBGetText("GenericGUI", "HeartChakra_shorttext");
                                                            parent = m_EquipmentSlots.icon_chakra_4;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_5:    text = LDBFormat.LDBGetText("GenericGUI", "CreationChakra_shorttext");
                                                            parent = m_EquipmentSlots.icon_chakra_5;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_6:    text = LDBFormat.LDBGetText("GenericGUI", "ProphecyChakra_shorttext");
                                                            parent = m_EquipmentSlots.icon_chakra_6;
                                                            break;
                                                            
        case _global.Enums.ItemEquipLocation.e_Chakra_7:    text = LDBFormat.LDBGetText("GenericGUI", "AstralChakra_shorttext");
                                                            parent = m_EquipmentSlots.icon_chakra_7;
    }
    
    if (m_Inventory.GetItemAt(itemPos) == undefined && parent != null)
    {
        TooltipUtils.AddTextTooltip( parent, " " + text, 160, TooltipInterface.e_OrientationHorizontal,  true);
    }
}

//Set Max Equipped Weapons
function SetMaxEquippedWeapons(maxWeapons:Number):Void
{
    for (var i:Number = 0; i < m_WeaponSlots.length; i++)
    {
        var alpha:Number = 100;
        
        if (i >= maxWeapons)
        {
            alpha = 20;
        }
        
        m_WeaponSlots[i].GetSlotMC()._alpha = alpha;
    }
}

//Slot Stat Changed
function SlotStatChanged(statID:Number):Void
{
    if (statID == _global.Enums.Stat.e_MaxEquippedWeapons) 
    {
        var newValue:Number = m_Character.GetStat(statID);
        SetMaxEquippedWeapons(newValue);
    }
}

//Slot Item Added
function SlotItemAdded(inventoryID:com.Utils.ID32, itemPos:Number):Void
{
    if (m_Inventory.GetItemAt(itemPos) != undefined)
    {
        RemoveSimpleTooltips(itemPos);
        m_ItemSlots[itemPos].SetData(m_Inventory.GetItemAt(itemPos));
        m_ItemSlots[itemPos].GetSlotMC().m_Watermark._visible = false;
        
        m_GearManager.SetNewUpdateButtonDisabledState(!CharacterHasBuild());
        
        UpdateNumWeapons();
    }
}

function SlotItemLoaded(inventoryID:com.Utils.ID32, itemPos:Number):Void
{
    SlotItemAdded(inventoryID, itemPos);
}

//Slot Item Moved
function SlotItemMoved(inventoryID:com.Utils.ID32, fromPos:Number, toPos:Number):Void
{
    m_ItemSlots[fromPos].SetData(m_Inventory.GetItemAt(fromPos));
    m_ItemSlots[toPos].SetData(m_Inventory.GetItemAt( toPos));
    m_ItemSlots[itemPos].GetSlotMC().m_Watermark._visible = false;
}

//Slot Item Removed
function SlotItemRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean):Void
{
    AddSimpleTooltips(itemPos);
    m_ItemSlots[itemPos].Clear();
    m_ItemSlots[itemPos].GetSlotMC().m_Watermark._visible = true;
    
    m_GearManager.SetNewUpdateButtonDisabledState(!CharacterHasBuild());
    
    UpdateNumWeapons();
}
 
//Slot Item Changed
function SlotItemChanged(inventoryID:com.Utils.ID32, itemPos:Number):Void
{
    m_ItemSlots[itemPos].SetData(m_Inventory.GetItemAt(itemPos));
    m_ItemSlots[itemPos].GetSlotMC().m_Watermark._visible = false;
}

function SlotItemStatChanged(inventoryID:com.Utils.ID32, itemPos:Number, stat:Number, newValue:Number )
{
    SlotItemChanged(inventoryID, itemPos);
}

function UpdateNumWeapons()
{
    var weaponArray:Array = new Array();
    if (m_Inventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot) != undefined)
    {
        weaponArray.push(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot)
    }
    if (m_Inventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot) != undefined)
    {
        weaponArray.push(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot)
    }
    if (m_Inventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot) != undefined)
    {
        weaponArray.push(_global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot)
    }
    m_CharacterStatistics.SetWeapons(weaponArray);
}

function HighLightSlot(slot:MovieClip, highlight:Boolean) : Void
{
    slot.filters = (highlight)?[m_GlowFilter]:[];
}

function UnHighLightAll() : Void
{
    for (var prop in m_ItemSlots)
    {
        HighLightSlot(m_ItemSlots[prop].GetSlotMC(), false)
    }
}

function CharacterHasBuild():Boolean
{
    for (var key:String in m_ItemSlots)
    {
        if (m_ItemSlots[key].HasItem())
        {
            return true;
        }
    }
    
    return false;
}