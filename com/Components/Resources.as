import com.Components.ResourceBase
import com.GameInterface.Log;
import com.GameInterface.Game.Character;
import com.GameInterface.Resource;
import com.Components.WeaponResources.ResourceDataObject;
import com.GameInterface.Inventory;
import com.Utils.ID32;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Utils.LDBFormat;
import gfx.motion.Tween;
import mx.transitions.easing.*;
import flash.geom.Point;

import gfx.core.UIComponent;

class com.Components.Resources extends UIComponent
{
    
    private var LEFT:String = "left";
    private var RIGHT:String = "right";
    private var NONE:String = "label";
    
    private var m_WeaponInventory:Inventory;

    private var m_RightResource:ResourceBase
    private var m_LeftResource:ResourceBase;
    private var m_Character:Character;
    private var m_ClientCharacter:Character;
    private var m_CharacterId:ID32;
    private var m_LeftPos:Number;
    private var m_RightPos:Number;
    private var m_MaxCounter:Number;
    private var m_MinCounter:Number;
    private var m_Resources:Array;
    private var m_Scale:Number;

    private var m_IsPlayerCharacter:Boolean;
    
    private var m_HideWhenEmpty:Boolean;
	
	private var m_Tooltip:TooltipInterface
	private var m_CurrentTooltipClip:MovieClip;
    
    public function Resources()
    {
        super();
        m_LeftPos = 0;
        m_RightPos = 157;
        m_MaxCounter = 5;
        m_MinCounter = 0;
        m_Scale = 90;
        m_HideWhenEmpty = false;
        
        Tween.init();
        
        /// get the onventory and listen to weapons
        m_RightResource = null;
        m_LeftResource = null;
        
        m_Resources = [];

        m_Resources[0]    = null;
        m_Resources[_global.Enums.ResourceType.e_BloodResourceType]    = new ResourceDataObject( "Blood", _global.Enums.WeaponTypeFlag.e_WeaponType_Death,  _global.Enums.ResourceType.e_BloodResourceType, 1007, false, false );
        m_Resources[_global.Enums.ResourceType.e_ChaosResourceType]    = new ResourceDataObject( "Chaos", _global.Enums.WeaponTypeFlag.e_WeaponType_Jinx,  _global.Enums.ResourceType.e_ChaosResourceType, 1008 , false, false );
        m_Resources[_global.Enums.ResourceType.e_ElementalResourceType]= new ResourceDataObject( "Elemental",_global.Enums.WeaponTypeFlag.e_WeaponType_Fire,  _global.Enums.ResourceType.e_ElementalResourceType, 1009 , false, false );
        m_Resources[_global.Enums.ResourceType.e_CutResourceType]      = new ResourceDataObject( "Blade", _global.Enums.WeaponTypeFlag.e_WeaponType_Sword,  _global.Enums.ResourceType.e_CutResourceType, 1004 , false, false );
        m_Resources[_global.Enums.ResourceType.e_StrikeResourceType]   = new ResourceDataObject( "Fist", _global.Enums.WeaponTypeFlag.e_WeaponType_Fist,  _global.Enums.ResourceType.e_StrikeResourceType, 1006 , false, false );
        m_Resources[_global.Enums.ResourceType.e_SlamResourceType]     = new ResourceDataObject( "Hammer", _global.Enums.WeaponTypeFlag.e_WeaponType_Club,  _global.Enums.ResourceType.e_SlamResourceType, 1005 , false, false );
        m_Resources[_global.Enums.ResourceType.e_ClipResourceType]     = new ResourceDataObject( "AssaultRifle", _global.Enums.WeaponTypeFlag.e_WeaponType_AssaultRifle,  _global.Enums.ResourceType.e_ClipResourceType, 1002 , true, true );
        m_Resources[_global.Enums.ResourceType.e_BulletResourceType]   = new ResourceDataObject( "Pistol", _global.Enums.WeaponTypeFlag.e_WeaponType_Handgun, _global.Enums.ResourceType.e_BulletResourceType, 1003 , true, true );
        m_Resources[_global.Enums.ResourceType.e_ShellResourceType]    = new ResourceDataObject( "Shotgun", _global.Enums.WeaponTypeFlag.e_WeaponType_Shotgun, _global.Enums.ResourceType.e_ShellResourceType, 1001 , true, true );
        
        m_IsPlayerCharacter = false;
    }
    
    
    public function SetHideWhenEmpty(hide:Boolean)
    {
        m_HideWhenEmpty = hide;
    }
    
    public function SetCharacter(character:Character) : Void
    {
        m_ClientCharacter = Character.GetClientCharacter();
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
            m_ClientCharacter.SignalToggleCombat.Connect( SlotToggleCombat, this);
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
       // if (m_Character != undefined && m_IsPlayerCharacter)
        //{
            m_WeaponInventory.SignalItemAdded.Connect( SlotWeaponAdded, this);
            m_WeaponInventory.SignalItemChanged.Connect( SlotWeaponChanged, this);        
            m_WeaponInventory.SignalItemRemoved.Connect( SlotWeaponRemoved, this);
            
            var firstWeapon:Object = m_WeaponInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot);
            var secondaryWeapon:Object = m_WeaponInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot);

            if (firstWeapon != undefined)
            {
                SlotWeaponAdded(m_WeaponInventory.m_InventoryID, _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot);
            }
            if (secondaryWeapon != undefined)
            {
                SlotWeaponAdded(m_WeaponInventory.m_InventoryID, _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot);
            }
        //}
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
    function GetResourceType(weaponType:Number) : Number
    {
        for (var i:Number = 1; i < m_Resources.length; i++)
        {
            if ((weaponType & m_Resources[i].m_WeaponType) != 0)
            { 
                return i;
            }
        }
        Log.Error("Resources", "GetResourceType: No resource mapped to a weapon with ID: " + weaponType + " Aborting");
        return 0;
    }
    
    function GetResource(resourceType) : ResourceBase
    {
        if (m_RightResource != null)
        {
            if (m_RightResource.GetResource() == resourceType)
            {
                return m_RightResource;
            }
        }
        
        if (m_LeftResource != null)
        {
            if (m_LeftResource.GetResource() == resourceType)
            {
                return m_LeftResource;
            }
        }
        return null;
    }

    function SetResourcesVisibility( isCharacterPresent:Boolean ) : Void
    {
        //_visible = isCharacterPresent;
    }

    function AddResource(resourceType:Number) : ResourceBase
    {
        Log.Info2("Resources", "AddResource(" + resourceType + ")");
        
        if (resourceType == 0 || resourceType > m_Resources.length -1)
        {
            Log.Error("Resources", "AddResource was called with wrong resourceID: " + resourceType + " Aborting");
            return; /// sometimes it seems we receive 0 as resource, that is an error and we abort
        }
        
        var xPos:Number = m_LeftPos;
        var resourceName:String = m_Resources[ resourceType ].m_Name;
        var direction:String = GetDirection(resourceType)
        
        if (direction == RIGHT)
        {
            xPos = m_RightPos; 
            ClearResource(RIGHT);
        }
        else if (direction == LEFT)
        {
            ClearResource(LEFT);
        }
        else 
        {
           return 
        }
		
		if (m_Resources[resourceType].m_BuildsOnTarget || m_IsPlayerCharacter)
		{
			var resourceObject:ResourceBase = ResourceBase( attachMovie("Player_Resource_" + resourceName, resourceName, getNextHighestDepth() ));
			resourceObject.SetScale(m_Scale);
			resourceObject.SetPosition(xPos, 0);
			resourceObject.SetData( m_Resources[ resourceType ] );
			resourceObject.SetAmount( Resource.GetResourceAmount( resourceType, m_CharacterId ), true );
			resourceObject.ToggleCombat( m_ClientCharacter.IsInCombat() );
			resourceObject.onPress = function() { };
			if (direction == RIGHT)
			{
				m_RightResource = resourceObject;
			}
			else         
			{
				m_LeftResource = resourceObject;
			}
		}
    }
	
	private function onMouseMove()
	{
		var topMost:Object = Mouse.getTopMostEntity(false);
		var hitSomething:Boolean = false
		if (topMost != undefined)
		{
			if (topMost != m_CurrentTooltipClip)
			{
				if (topMost == m_RightResource)
				{
					hitSomething = true;
					ShowTooltip(m_RightResource);
				}
				else if (topMost == m_LeftResource)
				{
					hitSomething = true;
					ShowTooltip(m_LeftResource);
				}
			}
			else
			{
				hitSomething = true;
			}
		}
		if (!hitSomething && m_Tooltip != undefined)
		{
			CloseTooltip();
		}
	}
	
	private function GetResourceColor(resourceType:Number)
	{
		switch(resourceType)
		{
			case _global.Enums.ResourceType.e_BloodResourceType:
				return "#567EE8";
			case _global.Enums.ResourceType.e_ChaosResourceType:
				return "#18A1B0";
			case _global.Enums.ResourceType.e_ElementalResourceType:
				return "#1CA7F5";
			case _global.Enums.ResourceType.e_CutResourceType:
				return "#E888B6";
			case _global.Enums.ResourceType.e_StrikeResourceType:
				return "#990099";
			case _global.Enums.ResourceType.e_SlamResourceType:
				return "#FF0000";
			case _global.Enums.ResourceType.e_ClipResourceType:
				return "#FFF66C";
			case _global.Enums.ResourceType.e_BulletResourceType:
				return "#FF0000";
			case _global.Enums.ResourceType.e_ShellResourceType:
				return "#FF9900";
		}
		return "#FFFFFF";
	}
	
	private function ShowTooltip(resource:MovieClip)
	{
		var tooltipData:TooltipData = new TooltipData();
				
		var weaponType:String = LDBFormat.LDBGetText("CharacterSkillsGUI", resource.GetTooltipId() );
		tooltipData.m_Descriptions.push(LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "ResourceTooltip"), GetResourceColor(resource.GetResource()), weaponType, weaponType));
		tooltipData.m_Padding = 4;
		tooltipData.m_MaxWidth = _parent._width;
		m_CurrentTooltipClip = resource;
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip( undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData );
		m_Tooltip.SignalLayout.Connect(SlotTooltipLayout, this);
	}
	
	private function SlotTooltipLayout()
	{
		var posThis:Point = new Point(0, 0);
		this.localToGlobal(posThis);
		var posParent:Point = new Point(0, 0);
		_parent.localToGlobal(posParent);
		
		var pos:Point = new Point(posParent.x, posThis.y - m_Tooltip.GetSize().y - 5);
		m_Tooltip.SetGlobalPosition(pos);
	}
	
	private function CloseTooltip()
	{
		m_CurrentTooltipClip = undefined;
		m_Tooltip.Close();
		m_Tooltip = undefined;
	}

    /// removes the resource indicator from stage without modifying the resource object
    /// @param resourceSide:String  - The side (left or right)
    function ClearResource( resourceSide:String ) : Void
    {
        Log.Info2("Resources", "ClearResource(" + resourceSide + " :String )");
        if (resourceSide == LEFT && m_LeftResource != null)
        {
            m_LeftResource.removeMovieClip();
            m_LeftResource = null;
        }
        else if (resourceSide == RIGHT && m_RightResource != null)
        {
            m_RightResource.removeMovieClip();
            m_RightResource = null;
        }
    }
    
    function HideResource(resourceSide:String) : Void
    {
        Log.Info2("Resources", "HideResource(" + resourceSide + " :String )");
        if (resourceSide == LEFT && m_LeftResource != null)
        {
            m_LeftResource.m_IsTweening = true;
            m_LeftResource["tweenTo"](0.3, { _alpha:0 }, None.easeNone);
            m_LeftResource["onTweenComplete"] = undefined;
        }
        else if (resourceSide == RIGHT && m_RightResource != null)
        {
            m_RightResource.m_IsTweening = true;
            m_RightResource["tweenTo"](0.3, { _alpha:0 }, None.easeNone);
            m_RightResource["onTweenComplete"] = undefined;
        }
    }
    
    function SlotToggleCombat(isInCombat) : Void
    {
        if (m_LeftResource != null)
        {
            m_LeftResource.ToggleCombat( isInCombat );
        }
        
        if (m_RightResource != null)
        {
            m_RightResource.ToggleCombat( isInCombat );
        }
    }

    /// @param resourceType:Number    The resource type (1-9).
    /// @param resourceAmount:Number  The new resource amount.
    /// @param targetID:ID32          The target
    function SlotResourceUpdated(resourceType:Number, resourceAmount:Number, targetID:ID32)
    {
        if (resourceType == 0 || !targetID.Equal( m_CharacterId ))
        {
            return;
        }
        Log.Info2("Resources", "SlotResourceUpdated(" + resourceType + ", " + resourceAmount + ", " + targetID + ", " + m_CharacterId);
        var resourceObject:ResourceDataObject =  m_Resources[ resourceType ];
        var resource:ResourceBase = GetResource(resourceType);

        if (m_HideWhenEmpty && resourceAmount == 0)
        {
            HideResource( GetDirection(resourceType) );
        }
        else if (resourceType > 0 && ((m_IsPlayerCharacter && !resourceObject.m_BuildsOnTarget) || (!m_IsPlayerCharacter && resourceObject.m_BuildsOnTarget)))
        {
            if ( resource == null )
            {
                //Should depend on the position of the weapon of the triggerer (player)
                AddResource(resourceType)
            }
            else
            {
                if (resource.m_IsTweening)
                {
                    resource["tweenEnd"](false);
                    resource._alpha = 100;
                }
                resource.SetAmount( resourceAmount, false );
            }
        }
    }
    
    function GetDirection(resourceType:Number):String
    {
        var firstWeapon:Object = m_WeaponInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot);
        var secondaryWeapon:Object = m_WeaponInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot);
        
        if (firstWeapon != undefined)
        {
            if (GetResourceType( firstWeapon.m_Type ) == resourceType)
            {
                return LEFT;
            }
        }
        
        /// nothing found, check the other weapon
        if(secondaryWeapon != undefined ) 
        {
            if (GetResourceType(secondaryWeapon.m_Type) == resourceType)
            {
                return RIGHT;
            }
        }
        return "";
    }
    
    /// checks to see if there is a resource indicator on stage for this resource allready
    /// @param resource:Number - the resource to check
    /// @return Boolean - if resource is on stage or not
    function IsResourceVisible(resource:Number) : Boolean
    {
        Log.Info2("Resources", "IsResourceVisible( resource = " + resource + ")");
        
        return ( GetResource(resource) != null);
    }
      
      /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
      /// @param itemPos [in]  Where the item was removed from.
      /// @param moved   [in]  True if the item moved to some other inventory.
    function SlotWeaponRemoved(inventoryID:com.Utils.ID32, itemPos:Number, moved:Boolean )
    {
        Log.Info2("Resources", "SlotWeaponRemoved( inventoryID = " + inventoryID + ", itemPos = " + itemPos + ", moved(optional) " + moved + " )");
        var direction:String = ( itemPos == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ) ? LEFT : RIGHT;
        ClearResource( direction );
    }

    /// This will be called both when you get an item and if an item is moved from a different inventory to this.
    /// @param inventoryID:com.Utils.ID32 [] identity of the inventory sending the signal
    /// @param itemPos [in]  The position for this new item.
    function SlotWeaponAdded(inventoryID:com.Utils.ID32, itemPos:Number)
    {
        Log.Info2("Resources", "SlotWeaponAdded(inventoryID=  " + inventoryID + ", itemPos  = " + itemPos + ")");
        
        var weapon:Object = m_WeaponInventory.GetItemAt( itemPos );
        if (weapon != undefined)
        {
            var resourceType:Number = GetResourceType( weapon.m_Type ); 
            //Not all resources should be shown on yourself
            if (IsSelfWeaponResource(resourceType))
            {
                AddResource( resourceType );
            }
            else
            {
                var direction:String = ( itemPos == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ) ? LEFT : RIGHT;
                ClearResource( direction );
            }
        }
    }

    function SlotWeaponChanged(inventoryID:com.Utils.ID32, itemPos:Number)
    {
        Log.Info2("Resources", "SlotWeaponChanged(inventoryID=  " + inventoryID + ", itemPos  = " + itemPos + ")");

        var direction:String = ( itemPos == _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot ) ? RIGHT : LEFT;
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
}