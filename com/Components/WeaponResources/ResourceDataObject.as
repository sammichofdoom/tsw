/*
*
* Interface for resource data
*/
 
class com.Components.WeaponResources.ResourceDataObject
{
    public var m_Name:String;
    public var m_WeaponType:Number;
    public var m_ResourceType:Number;
    public var m_TooltipId:Number;
    public var m_BuildsOnTarget:Boolean;
    public var m_IsDirectional:Boolean
    
    public function ResourceDataObject(name:String, weaponType:Number, resourceType:Number, tooltipId:Number, buildsOntarget:Boolean, isDirectional:Boolean)
    {
        m_Name = name;
        m_WeaponType = weaponType;
        m_ResourceType = resourceType
        m_TooltipId = tooltipId;
        m_BuildsOnTarget = buildsOntarget;
        m_IsDirectional = isDirectional;
    }
}
