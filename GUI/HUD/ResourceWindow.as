import com.GameInterface.Log;
import com.GameInterface.Game.Character;
import com.GameInterface.Resource;
import com.GameInterface.Inventory;

var LEFT:String = "left";
var RIGHT:String = "right";
var NONE:String = "label";

var m_WeaponInventory:Inventory;


var m_RightResource:Object
var m_LeftResource:Object;
var m_Character:Character;
var m_CharacterId:ID32;
var m_LeftPos:Number = 0;
var m_RightPos:Number = 157;
var m_MaxCounter:Number = 5;
var m_MinCounter:Number = 0;
var m_Resources:Array;
var m_Scale:Number = 90;

var m_IsPlayerCharacter:Boolean

/// called from the onload method. 
/// one call for the lifetime of this clip
function Init()
{
    Log.Info2("ResourceWindow", "ResourceWindow Init()");
    
    /// get the onventory and listen to weapons
    m_RightResource = null;
    m_LeftResource = null;
    
    m_Resources = [];
    
    /// static mapping of all resources
    m_Resources[0]                                                  = { name:"Undefined" };
    m_Resources[_global.Enums.ResourceType.e_BloodResourceType]     = { name:"Blood",           counter:0, direction:undefined, directional:false,  type: 331776,   mc: null, resource: _global.Enums.ResourceType.e_BloodResourceType};
    m_Resources[_global.Enums.ResourceType.e_ChaosResourceType]     = { name:"Chaos",           counter:1, direction:undefined, directional:false,  type: 274432,   mc: null, resource: _global.Enums.ResourceType.e_ChaosResourceType };
    m_Resources[_global.Enums.ResourceType.e_ElementalResourceType] = { name:"Elemental",       counter:0, direction:undefined, directional:false,  type: 397312,   mc: null, resource: _global.Enums.ResourceType.e_ElementalResourceType };
    m_Resources[_global.Enums.ResourceType.e_CutResourceType]       = { name:"Blade",           counter:0, direction:undefined, directional:false,  type: 262177,   mc: null, resource: _global.Enums.ResourceType.e_CutResourceType };
    m_Resources[_global.Enums.ResourceType.e_StrikeResourceType]    = { name:"Fist",            counter:0, direction:undefined, directional:false,  type: 262161,   mc: null, resource: _global.Enums.ResourceType.e_StrikeResourceType };
    m_Resources[_global.Enums.ResourceType.e_SlamResourceType]      = { name:"Hammer",          counter:0, direction:undefined, directional:false,  type: 524291,   mc: null, resource: _global.Enums.ResourceType.e_SlamResourceType };
    m_Resources[_global.Enums.ResourceType.e_ClipResourceType]      = { name:"AssaultRifle",    counter:2, direction:undefined, directional:true,   type: 524608,   mc: null, resource: _global.Enums.ResourceType.e_ClipResourceType };
    m_Resources[_global.Enums.ResourceType.e_BulletResourceType]    = { name:"Pistol",          counter:0, direction:undefined, directional:true,   type: 262336,   mc: null, resource: _global.Enums.ResourceType.e_BulletResourceType };
    m_Resources[_global.Enums.ResourceType.e_ShellResourceType]     = { name:"Shotgun",         counter:0, direction:undefined, directional:true,   type: 1088,     mc: null, resource: _global.Enums.ResourceType.e_ShellResourceType };
	
	m_IsPlayerCharacter = false;
}

function SetCharacter(character:Character) : Void
{    
    Log.Info2("ResourceWindow", "SetCharacter( " + character + " :Character)");
    SetResourcesVisibility( character != undefined );
    ClearResource( RIGHT );
    ClearResource( LEFT );
    
    if (m_Character != undefined)
    {
        Resource.SignalResourceChanged.Disconnect(SlotResourceUpdated, this);
    }

    m_Character = character;
    if (m_Character != undefined)
    {
        Resource.SignalResourceChanged.Connect( SlotResourceUpdated, this );
        m_CharacterId = m_Character.GetID();
    }
    else
    {
        m_CharacterId = undefined;
    }
	
    var clientCharacterID:ID32 = Character.GetClientCharID();
	m_IsPlayerCharacter = clientCharacterID.Equal(m_CharacterId);
	
	//Set the weapon inventory no matter what to the client inventory (as we need it in both cases)
	m_WeaponInventory = new Inventory( new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, clientCharacterID.GetInstance()));
	
    if (m_Character != undefined && m_IsPlayerCharacter)
    {

		m_WeaponInventory.SignalItemAdded.Connect( SlotWeaponAdded, this);
		m_WeaponInventory.SignalItemChanged.Connect( SlotWeaponChanged, this);        
		m_WeaponInventory.SignalItemRemoved.Connect( SlotWeaponRemoved, this);
		
		var firstWeapon:Object = m_WeaponInventory.m_Items[_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot];
		var secondaryWeapon:Object = m_WeaponInventory.m_Items[_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot];

		if (firstWeapon != undefined)
		{
			SlotWeaponAdded(m_WeaponInventory.m_InventoryID, _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot);
		}
		if (secondaryWeapon != undefined)
		{
			SlotWeaponAdded(m_WeaponInventory.m_InventoryID, _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot);
		}
	}
	for (var i:Number = 0; i < m_Resources.length;i++)
	{
		var resourceAmount:Number = Resource.GetResourceAmount(i, m_CharacterId);
		if (resourceAmount > 0)
		{
			SlotResourceUpdated(i, resourceAmount, m_CharacterId);
		}
	}
}

/// map the weapon type to the correct weapon
/// @param weaponType:Number, the m_Type property of the inventoryItem contained in the equipped inventory
/// @return Number - the resource mapped to this weapon or 0 on erroe, the 0 will be catched later if this error occur
function GetResource(weaponType:Number) : Number
{
    for (var i:Number = 1; i < m_Resources.length; i++)
    {
        if (weaponType == m_Resources[i].type)
        {
            return i;
        }
    }
    Log.Error("ResourceWindow", "GetResource: No resource mapped to a weapon with ID: " + weaponType + " Aborting");
    return 0;
}

function SetResourcesVisibility( isCharacterPresent:Boolean ) : Void
{
    i_Resource._visible = isCharacterPresent;
}

function AddResource(resource:Number, direction:String)
{
    Log.Info2("ResourceWindow", "AddResource("+resource+":Number, "+direction+":String)");
    var xPos:Number = m_LeftPos;

    var resourceObject = m_Resources[ resource ];
    
    if (resorce == 0 || resource > m_Resources.length -1)
    {
        Log.Error("ResourceWindow", "AddResource was called with wrong resourceID: " + resource + " Aborting");
        return; /// sometimes it seems we receive 0 as resource, that is an error and we abort
    }
    if (direction == RIGHT)
    {
        xPos = m_RightPos; 
        m_RightResource = m_Resources[ resource ];
        if (m_RightResource.resource != resource)
        {
            ClearResource(RIGHT);
        }
    }
    else if (direction == LEFT)
    {
        m_LeftResource = m_Resources[ resource ];
        if (m_LeftResource.resource != resource)
        {
            ClearResource(LEFT);
        }
    }
    resourceObject.counter = Resource.GetResourceAmount( resource, m_CharacterId );
    resourceObject.direction = direction;
    
    resourceObject.mc = this.attachMovie("Player_Resource_" + resourceObject.name, resourceObject.name, this.getNextHighestDepth(), { _x:xPos , _xscale: m_Scale, _yscale: m_Scale} );

    Layout();
}


/// updates the resources on stage with their counters
function Layout()
{
    Log.Info2("ResourceWindow", "Layout()");
    if (m_RightResource != null)
    {
        var labelPrefix:String = NONE;
        if (m_RightResource.directional)
        {
            var labelPrefix = (m_RightResource.counter == m_MaxCounter || m_RightResource.counter == m_MinCounter) ? NONE : m_RightResource.direction;
        }
        MovieClip(m_RightResource.mc).gotoAndStop( labelPrefix + "_" + m_RightResource.counter );
    }

    if (m_LeftResource != null)
    {
        var labelPrefix:String = NONE;
        if (m_LeftResource.directional)
        {
            var labelPrefix = (m_LeftResource.counter == m_MaxCounter || m_LeftResource.counter == m_MinCounter) ? NONE : m_LeftResource.direction;
        }
        MovieClip(m_LeftResource.mc).gotoAndStop( labelPrefix + "_" + m_LeftResource.counter );
    }
}

/// removes the resource indicator from stage without modifying the resource object
/// @param resourceSide:String  - The side (left or right)
function ClearResource( resourceSide:String ) : Void
{
    Log.Info2("ResourceWindow", "ClearResource(" + resourceSide + " :String )");
	
    if (resourceSide == LEFT && m_LeftResource != null)
    {
        MovieClip( m_LeftResource.mc ).removeMovieClip();
        m_LeftResource = null;
    }
    else if (resourceSide == RIGHT && m_RightResource != null)
    {
        MovieClip( m_RightResource.mc ).removeMovieClip();
        m_RightResource = null;
    }
}

/// @param resourceType:Number    The resource type (1-9).
/// @param resourceAmount:Number  The new resource amount.
/// @param targetID:ID32          The target
function SlotResourceUpdated(resourceType:Number, resourceAmount:Number, targetID:ID32)
{
    Log.Info2("ResourceWindow", "SlotResourceUpdated(" + resourceType + " :Number, " + resourceAmount + " :Number, " + targetID + " :ID32) m_CharacterId = " + m_CharacterId);
    if (targetID.Equal( m_CharacterId) && resourceType > 0 && ((m_IsPlayerCharacter && IsSelfWeaponResource(resourceType)) || (!m_IsPlayerCharacter && !IsSelfWeaponResource(resourceType))))
    {
        if (IsResourceVisible(resourceType))
        {
            m_Resources[ resourceType ].counter =  resourceAmount
            Layout();
        }
        else
        {
            //Should depend on the position of the weapon of the triggerer (player)
            var direction:String;
            var isWeapon:Boolean = false;
            
			var firstWeapon:Object = m_WeaponInventory.m_Items[_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot];
            var secondaryWeapon:Object = m_WeaponInventory.m_Items[_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot];
            
			if (firstWeapon != undefined)
            {
                if (GetResource(firstWeapon.m_Type) == resourceType)
                {
                    direction = LEFT;
					isWeapon = true;
                }
            }
            else if(secondaryWeapon != undefined)
            {
                if (GetResource(secondaryWeapon.m_Type) == resourceType)
                {
                    direction == RIGHT;
					isWeapon = true;
                }
            }
            
			if (isWeapon)
			{
            	m_Resources[ resourceType ].counter =  resourceAmount;
            	AddResource(resourceType, direction);
			}
        }
    }
}
/// checks to see if there is a resource indicator on stage for this resource allready
/// @param resource:Number - the resource to check
/// @return Boolean - if resource is on stage or not
function IsResourceVisible(resource:Number) : Boolean
{
    Log.Info2("ResourceWindow", "IsResourceVisible( resource = " + resource + ")");
    return (m_RightResource.resource == resource || m_LeftResource.resource == resource );
}
  
  /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
  /// @param itemPos [in]  Where the item was removed from.
  /// @param moved   [in]  True if the item moved to some other inventory.
function SlotWeaponRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
{
    Log.Info2("ResourceWindow", "SlotWeaponRemoved( inventoryID = " + inventoryID + ", itemPos = " + itemPos + ", moved(optional) "+moved+" )");
    var direction:String = ( itemPos == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ) ? LEFT : RIGHT;
    ClearResource( direction );
}

/// This will be called both when you get an item and if an item is moved from a different inventory to this.
/// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
/// @param itemPos [in]  The position for this new item.
function SlotWeaponAdded(inventoryID:com.Utils.ID32, itemPos:Number)
{
    Log.Info2("ResourceWindow", "SlotWeaponAdded(inventoryID=  " + inventoryID + ", itemPos  = " + itemPos + ")");
    
    var weapon:Object = m_WeaponInventory.m_Items[ itemPos ];
    if (weapon != undefined)
    {
        var direction:String = ( itemPos == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ) ? LEFT : RIGHT;
        var resource:Number = GetResource( weapon.m_Type );
		ClearResource( direction );
        //Not all resources should be shown on yourself
        if (IsSelfWeaponResource(resource))
        {
            AddResource( resource, direction);
        }
    }
}

function SlotWeaponChanged(inventoryID:com.Utils.ID32, itemPos:Number)
{
    Log.Info2("ResourceWindow", "SlotWeaponChanged(inventoryID=  " + inventoryID + ", itemPos  = " + itemPos + ")");
    var direction:String = ( itemPos == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ) ? LEFT : RIGHT;
    ClearResource( direction );
    SlotWeaponAdded(inventoryID, itemPos);
}

function IsSelfWeaponResource(resource:Number)
{
    switch(resource)
    {
        case _global.Enums.ResourceType.e_ClipResourceType:
        case _global.Enums.ResourceType.e_BulletResourceType:
        case _global.Enums.ResourceType.e_ShellResourceType:
        return false;
        default:
        return true;
    }
    return true;
}