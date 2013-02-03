import com.Utils.Signal;

intrinsic class com.GameInterface.SpellBase
{
        
    /// Associavite array of all the spells the player has. This object is supposed to be const, but that is not supported in actionscript.
    /// This list will be kept in sync by gamecode. You will get signals when the state of the list changes.
    /// Members are of type SpellData
    public static var m_SpellList:Object;

    /// Members are of type PassiveData
    public static var m_PassivesList:Object;
    
    /// Equip a passive ability in a given slot
    /// @param abilityPos:Number   The position on the bar.
    /// @param abilityId:Number   The ability to auto add.
    public static function EquipPassiveAbility( abilityPos:Number, abilityId:Number ) : Void;

    /// Unequip a passive ability in a given slot
    /// @param abilityPos:Number   The position on the bar.
    public static function UnequipPassiveAbility( abilityPos:Number) : Void;
    
    /// Moves a passive ability between two slots
    /// @param fromPos:Number   The slot to move it from.
    /// @param toPos:Number   The slot to move it to.
    public static function MovePassiveAbility( fromPos:Number, toPos:Number) : Void;
  
    /// Gets the passive ability equipped on a given slot
    /// @param abilityPos:Number   The slot number.
    public static function GetPassiveAbility(abilityPos:Number) : Number;
  
    /// Gets the passive ability equipped on a given slot
    /// @param abilityPos:Number   The slot number.
    public static function EnterPassiveMode() : Void;
  
    /// Gets the passive ability equipped on a given slot
    /// @param abilityPos:Number   The slot number.
    public static function ExitPassiveMode() : Void;
    
    /// Cancels a specific buff
    /// @param buffId:Number   The buffid.
    public static function CancelBuff(buffID:Number, casterID:Number) : Void;
    
    //Checks if a specific templateid is a tokenstate
    /// @param templateID:Number the templateid to check
    public static function IsTokenState(templateID:Number);
	
	//Checks wether a passive ability is equipped
    public static function IsPassiveEquipped(spellId:Number):Boolean;
    
    //Gets the dynamic spell description of a spell
    /// @param spellID:Number the spell id
    public static function GetSpellDescription(spellID:Number):String;

	//Get spelldata for a spell
	/// @param spellID:Number the spell id
	public static function GetSpellData(spellID:Number):com.GameInterface.SpellData;
    
	//Get static buffdata for a buff
	/// @param buffID:Number the buff id
	public static function GetBuffData(spellID:Number):com.GameInterface.Game.BuffData;
    
    //Gets the shortened dynamic spell description of a spell
    /// @param spellID:Number the spell id
    public static function GetSpellShortDescription(spellID:Number):String;
	
    //Gets the static description of a spell
    /// @param spellID:Number the spell id
    public static function GetSpellStaticDescription(spellID:Number):String;
    
    /// Signal sent when the spell list is updated from server. m_SpellList will now contain all your spells.
    public static var SignalSpellUpdate:Signal// -> OnSignalSpellUpdate()

    /// Signal sent when a new spell has been learned. m_SpellList will now contain the id.
    public static var SignalSpellLearned:Signal; // -> OnSignalSpellLearned( spellId:Number )

    /// Signal sent when a spell has been removed. m_SpellList will no longer contain the id.
    public static var SignalSpellForgotten:Signal; // -> OnSignalSpellForgotten( spellId:Number )

    /// Signal sent when the passives list is updated from server. m_PassivesList will now contain all your spells.
    public static var SignalPassiveUpdate:Signal; // -> OnSignalPassiveUpdate()

    /// Signal sent when a new spell has been learned. m_PassivesList will now contain the id.
    public static var SignalPassiveLearned:Signal; // -> OnSignalPassiveLearned( spellId:Number )

    /// Signal sent when a spell has been removed. m_PassivesList will no longer contain the id.
    public static var SignalPassiveForgotten:Signal; // -> OnSignalPassiveForgotten( spellId:Number )
  
    // Signal sent when a passive has been added to a slot
    public static var SignalPassiveAdded:Signal; // -> OnSignalPassiveAdded(itemPos:Number, name:String, icon:String, itemClass:Number, colorLine:Number)
    
    // Signal sent when a passive has been removed to a slot
    public static var SignalPassiveRemoved:Signal;// -> OnSignalPassiveRemoved(itemPos:Number)
    
    //Signal sent when a character receives his spellbook from the server
    public static var SignalSpellbookReceived:Signal;// ->SlotSpellbookReceived();
	
}
