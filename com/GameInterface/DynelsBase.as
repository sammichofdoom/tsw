intrinsic class com.GameInterface.DynelsBase
{
    /// Use this call to ask for some values to be update each frame for the dynel defined by type and instance.
    /// You will get a object variable back that wuill have some fields filled depending on the enum you use.
    /// The object you get back will always be the same if you do multiple calls to this function.
    /// The object will have the wanted values filled already on return, ready to use.
    /// If the dynel is removed from the pf, you'll get DynelGone signal with the type and instance. Then you don't have to unregister.
    /// Use UnregisterProperty(...) when you no longer need the updates.
    /// Note that each property is refcounted so if you register the same dynel and enum from 2 different modules, you will also have to unregister both
    /// to make the update stop.
    ///
    ///  Enums and which members they will fill:
    ///  Property::e_ObjPos             /// Position.                                             Members:  PosX, PosY, PosZ
    ///  Property::e_ObjScreenPos       /// Screen pos of the object and distance to camera.      Members:  ObjScreenPosX, ObjScreenPosY
    ///  Property::e_MissionScreenPos   /// Screen pos of the mission selector and distance to camera.      Members:  MissionScreenPosX, MissionScreenPosY, CamDistance, m_PosBlocked
    ///
    /// @param type     [in]  The type of objects
    /// @param instance [in]  The objects instance
    /// @param enum     [in]  The property to ask for.
    /// @param          [out] Object 
    public static function RegisterProperty( type:Number, instance:Number, enum:Number ) : Object;

    /// Stop the update from the earlier registered dynel.
    ///
    /// @param type     [in]  The type of objects
    /// @param instance [in]  The objects instance
    /// @param enum     [in]  The property to stop updateing for.
    public static function UnregisterProperty( type:Number, instance:Number, enum:Number ) : Void;

    /// Target something in a slot. This is restricted to slots only to avoid macroing.
    /// The slot will end up as a hostile or friendly target all depending on it's carsgroup.
    ///
    /// @param slot     [in]  The slot to target.
    public static function SetTarget( slot:Number );
    
    ///Force refresh the buffs of a single slog
    /// @param slot     [in]  The slot to refresh buffs for.    
    public static function RefreshBuffs(slot:Number);

    /// Start trade with the given id.
    public static function Trade( id:com.Utils.ID32 );    
    
    /// Invite player to guild.
    public static function InviteToGuild( id:com.Utils.ID32 );    

    /// Promote a member of your guild.
    public static function PromoteGuildMember( id:com.Utils.ID32 );

    /// Demote a member of your guild
    public static function DemoteGuildMember( id:com.Utils.ID32 );
}
