//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.*;
import com.Utils.LDBFormat;
import com.Utils.ID32;
import gfx.controls.Button;
import gfx.controls.ScrollingList;
import gfx.controls.DropdownMenu;
import gfx.core.UIComponent;
import gfx.motion.Tween; 
import gfx.utils.Delegate;
import flash.geom.Point;
import flash.geom.Rectangle;
import mx.transitions.easing.*;

//Class
class GUI.CharacterSheet.DressingRoomComponent extends UIComponent
{
    //Constants
    private var ZOOM_SPEED:Number = 0.4;
    
    //Properties
    public var m_CloseButton:MovieClip;
    
    private var m_Background:MovieClip;
	private var m_Header:TextField;
    private var m_LocationDropdown:DropdownMenu;
    private var m_ItemList:ScrollingList;
    private var m_WardrobeInventory:Inventory;
    private var m_EquippedInventory:Inventory;
    private var m_WearButton:Button;
    private var m_RandomizeButton:Button;
    private var m_CurrentLocation:Number;
    
    private var m_Width:Number;
    private var m_Height:Number

    private var m_LocationLabels:Object;
    
    //Constructor
    public function DressingRoomComponent() 
    {
        super();

        m_LocationLabels = new Object();
        
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_FullOutfit] = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Hat]        = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Face]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Neck]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Back]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Chest]      = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Hands]      = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Belt]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Legs]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Wear_Feet]       = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Ring_1]          = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Ring_2]          = undefined;
        m_LocationLabels[_global.Enums.ItemEquipLocation.e_Necklace]        = undefined;

        for (var i in m_LocationLabels)
        {
            m_LocationLabels[i] = LDBFormat.LDBGetText("WearLocations", Number(i));
        }
        
        m_CurrentLocation = _global.Enums.ItemEquipLocation.e_Wear_Back;
        
		m_Header.text = LDBFormat.LDBGetText("GenericGUI", "DressingRoom");
    }
    
    //Config UI
    public function configUI():Void
    {
        super.configUI();
        
		m_LocationDropdown.disableFocus = true;
		
        var clientCharacterID:ID32 = Character.GetClientCharID();
        
        m_WardrobeInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, clientCharacterID.GetInstance()));
        m_EquippedInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, clientCharacterID.GetInstance()));
        
        m_WardrobeInventory.SignalItemAdded.Connect(Update, this);
        m_WardrobeInventory.SignalItemLoaded.Connect(Update, this);
        m_WardrobeInventory.SignalItemChanged.Connect(Update, this);
        
        m_EquippedInventory.SignalItemAdded.Connect(Update, this);
        m_EquippedInventory.SignalItemLoaded.Connect(Update, this);
        m_EquippedInventory.SignalItemChanged.Connect(Update, this);
        
        m_Width  = _width;
        m_Height = _height;
        
        m_ItemList.addEventListener("focusIn", this, "RemoveFocus");
        m_ItemList.addEventListener("change", this, "OnItemSelected");
        m_ItemList.addEventListener("itemDoubleClick", this, "OnItemDoubleClicked");
        m_LocationDropdown.addEventListener("change", this, "OnLocationSelected");
        m_WearButton.addEventListener("click", this, "OnWearButton");
        m_WearButton.addEventListener("press", this, "OnWearButtonPress");
        m_RandomizeButton.addEventListener("click", this, "OnRandomizeButton");

        Update();
    }
    
    //Can Location Be Unequipped
    private function CanLocationBeUnequipped(location:Number):Boolean
    {
        return location != _global.Enums.ItemEquipLocation.e_Wear_Chest && location != _global.Enums.ItemEquipLocation.e_Wear_Legs;
    }
    
    //Remove Focus
    private function RemoveFocus():Void
    {
        Selection.setFocus(null);
    }
    
    //Set Labels
    private function SetLabels():Void
    {
        m_WearButton.label = LDBFormat.LDBGetText("GenericGUI", "Wear");
    }
    
    //Update
    private function Update():Void
    {
        UpdateItemList();
        UpdateLocationList();
        SetWearButtonLabel();
    }

    //Add Item
    private function AddItem(inventoryID:ID32, invItem:InventoryItem, invPos:Number, isEquipped:Boolean, doSort:Boolean):Void
    {
        if (invItem && ( (invItem.m_Placement & (1 << m_CurrentLocation)) != 0 || 
                         (invItem.m_Placement == _global.Enums.ItemEquipLocation.e_Wear_FullOutfit && invItem.m_Placement == m_CurrentLocation) ))
        {
            var listItem:Object = new Object;
            
            listItem.m_ItemName = invItem.m_Name;
            listItem.m_InventoryID = inventoryID;
            listItem.m_InventoryPos = invPos;
            listItem.m_IsEquipped = isEquipped;
            
            m_ItemList.dataProvider.push(listItem);
            
            if (doSort)
            {
                m_ItemList.dataProvider.sortOn("m_ItemName");
                m_ItemList.invalidateData();
            }
        }
    }

    //Update Location List
    private function UpdateLocationList():Void
    {
        var usedLocationsArray:Object = new Object();
        // Flag all locations used by items in the wardrobe.
        for (var i:Number = 0 ; i < m_WardrobeInventory.GetMaxItems() ; ++i)
        {
            if (m_WardrobeInventory.GetItemAt(i) != undefined)
            {
                usedLocationsArray[m_WardrobeInventory.GetItemAt(i).m_DefaultPosition] = true;
            }
        }
        
        // Flag locations from currently eqquipped items.
        for (i in m_LocationLabels)
        //for (var i:Number = 0 ; i < m_EquippedInventory.GetMaxItems() ; ++i)
        {
            if (m_EquippedInventory.GetItemAt(i))
            {
                var location:Number = Number(i);
                usedLocationsArray[location] = true;
            }
        }
        
        // Build a list of locations that are actually occupied by items (m_WardrobeInventory + m_EquippedInventory).
        var locationList:Array = [];
        
        for (i in m_LocationLabels)
        {
            var location:Number = Number(i);
            
            if(usedLocationsArray[location])
            {
                var locationItem:Object = new Object();
                
                locationItem.label = m_LocationLabels[i];
                
                locationItem.m_Location = location;
                locationList.push(locationItem);
            }
        }
        
        locationList.sortOn("label");
        
        // Check if the new list is different from the one already in the dropdown.
        var listChanged = false;
        
        if (locationList.length == m_LocationDropdown.dataProvider.length)
        {
            for (var i:Number = 0 ; i < locationList.length ; ++i)
            {
                if (locationList[i].m_Location != m_LocationDropdown.dataProvider[i].m_Location)
                {
                    listChanged = true;
                    break;
                }
            }
        }
        else
        {
            listChanged = true;
        }
        
        // Since swapping the list will reset selection we only do it if the list actually changed.
        if (listChanged)
        {
            var oldSelection:Number = m_CurrentLocation;
            
            m_LocationDropdown.dataProvider = locationList;
			m_LocationDropdown.rowCount = m_LocationDropdown.dataProvider.length;
            m_LocationDropdown.invalidateData();
            
            // Update m_CurrentLocation if not set already, or set selection back to the old m_CurrentLocation if it had been set.
            for (var i:Number = 0 ; i < m_LocationDropdown.dataProvider.length ; ++i)
            {
                if (m_LocationDropdown.dataProvider[i] && m_LocationDropdown.dataProvider[i].m_Location == oldSelection)
                {
                    m_LocationDropdown.selectedIndex = i;
                    break;
                }
            }
        }
    }

    //Update Item List
    private function UpdateItemList():Void
    {
        m_ItemList.dataProvider = [];
        
        for (var i:Number = 0 ; i < m_WardrobeInventory.GetMaxItems(); ++i)
        {
			if (m_WardrobeInventory.GetItemAt(i) != undefined)
			{
				AddItem(m_WardrobeInventory.m_InventoryID, m_WardrobeInventory.GetItemAt(i), i, false, false);
			}
        }
        
        AddItem(m_EquippedInventory.m_InventoryID, m_EquippedInventory.GetItemAt(m_CurrentLocation), m_CurrentLocation, true, false);
		
        m_ItemList.dataProvider.sortOn("m_ItemName");
        m_ItemList.invalidateData();
    }

    //On Location Selected
    private function OnLocationSelected(event:Object):Void
    {
        if ( m_LocationDropdown.selectedItem.m_Location != m_CurrentLocation)
        {
            m_CurrentLocation = m_LocationDropdown.selectedItem.m_Location;
            UpdateItemList();
            if (m_ItemList.selectedIndex && m_ItemList.dataProvider[m_ItemList.selectedIndex] == undefined)
            {
                m_ItemList.selectedIndex = 0; 
            }
            else
            {
                OnItemSelected();
            }
        }
        
        RemoveFocus();
    }

    //On Item Selected
    private function OnItemSelected(event:Object):Void
    {
		SetWearButtonLabel();
        //m_WearButton.enabled = event.index != -1 && (CanLocationBeUnequipped(m_CurrentLocation) || !m_ItemList.dataProvider[event.index].m_IsEquipped);
		OnPreview();
    }

    //On Item Double Clicked
    private function OnItemDoubleClicked(event:Object):Void
    {
        OnWearButton();
    } 
	
    //Set Wear Button Label
	private function SetWearButtonLabel(event:Object):Void
    {
		var item = m_ItemList.dataProvider[m_ItemList.selectedIndex];
		
        if (item.m_IsEquipped)
        {
			m_WearButton.label = LDBFormat.LDBGetText("GenericGUI", "Unwear");
			m_WearButton.disabled = !CanLocationBeUnequipped(item.m_InventoryPos);
        }
        else            
        {
			m_WearButton.label = LDBFormat.LDBGetText("GenericGUI", "Wear");
			m_WearButton.disabled = false;
        }
    }
    
    //On Preview
    private function OnPreview():Void
    {
        var index:Number = (m_ItemList.selectedIndex)? m_ItemList.selectedIndex : 0;
        var item = m_ItemList.dataProvider[index];
        
        if (item != undefined)
        {
            if (!item.m_IsEquipped)
            {
                m_WardrobeInventory.PreviewItem(item.m_InventoryPos);
            }
            else
            {
                m_EquippedInventory.PreviewItem(item.m_InventoryPos);
            }
        }
    }

    //On Wear Button Press
    private function OnWearButtonPress():Void
    {
        var character:Character = Character.GetClientCharacter();
        
        if (character != undefined)
        {
            character.AddEffectPackage("sound_fxpackage_GUI_item_equip_clothing.xml");
        }
    }
	
    //On Wear Button
    private function OnWearButton():Void
    {        
        var item = m_ItemList.dataProvider[m_ItemList.selectedIndex];

        if (item.m_IsEquipped)
        {
            if (CanLocationBeUnequipped(item.m_InventoryPos))
            {
                m_WardrobeInventory.AddItem(item.m_InventoryID, item.m_InventoryPos, _global.Enums.ItemEquipLocation.e_Wear_DefaultLocation);
            }
        }
        else            
        {
            m_EquippedInventory.AddItem(item.m_InventoryID, item.m_InventoryPos, _global.Enums.ItemEquipLocation.e_Wear_DefaultLocation);
        }
    }
	
    //On Wear All Button
	private function OnWearAllButton():Void
    {        
        var item = m_ItemList.dataProvider[m_ItemList.selectedIndex];

        if (item.m_IsEquipped)
        {
            if (CanLocationBeUnequipped(item.m_InventoryPos))
            {
                m_WardrobeInventory.AddItem(item.m_InventoryID, item.m_InventoryPos, _global.Enums.ItemEquipLocation.e_Wear_DefaultLocation);
            }
        }
        else            
        {
            m_EquippedInventory.AddItem(item.m_InventoryID, item.m_InventoryPos, _global.Enums.ItemEquipLocation.e_Wear_DefaultLocation);
        }
    }
	
    //On Randomize Button
    private function OnRandomizeButton():Void
    {
        for (var i = 0 ; i < 10 ; ++i)
        {
            var newIndex = Math.floor(Math.random() * m_ItemList.dataProvider.length);
            if (newIndex != m_ItemList.selectedIndex)
            {
                m_ItemList.selectedIndex = newIndex;
				
                break;
            }
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
        
        MovieClip(this).tweenTo(ZOOM_SPEED, {_x:expandedX, _width:m_Width, _height:m_Height}, None.easeNone);
        MovieClip(this).onTweenComplete = undefined;
    }
    
    //Close
    public function Close(anchor:Point):Void
    {
        this._visible = true;
        this._alpha = 100;
        
        var collapsedX:Number = anchor.x;
        var collapsedY:Number = anchor.y;
        
        MovieClip(this).tweenTo(ZOOM_SPEED, {_x:collapsedX, _y:collapsedY, _width:1, _height:1 }, None.easeNone);
        MovieClip(this).onTweenComplete = function()
        {
            this._visible = false;
        }
    }
}