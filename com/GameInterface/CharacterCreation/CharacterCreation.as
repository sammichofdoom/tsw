import com.GameInterface.MathLib.Vector3;

intrinsic class com.GameInterface.CharacterCreation.CharacterCreation
{
    public function CharacterCreation( isSurgery:Boolean /*initialMonsterData:Number, initialGender:Number, initialFaction:Number*/ );
    public function GetCharacter() : com.GameInterface.Game.Character;
    public function RequestNameSuggestion( whichName:Number ) : Void;
    public function SetMonsterData( monsterDataID:Number ) : Void;

    public function SetGender( gender:Number ) : Void;
    public function GetGender() : Number;

    public function GetBaseHeadCount() : Number;
    public function SetBaseHead( index:Number ) : Void;
    public function GetBaseHead() : Number;

    public function GetHairStyleIndexes() : Array;
    public function SetHairStyleIndex( index:Number ) : Void;
    public function GetHairStyleIndex() : Number;

    public function GetEyebrowCount() : Number;
    public function SetEyebrow( index:Number ) : Void;
    public function GetEyebrow() : Number;

    public function GetBeardCount() : Number;
    public function SetBeard( index:Number ) : Void;
    public function GetBeard() : Number;
    
    public function GetMakeupCount() : Number;
    public function SetMakeup( index:Number ) : Void;
    public function GetMakeup() : Number;

    public function GetMakeupColorIndexes() : Array;
    public function SetMakeupColorIndex( index:Number ) : Void;
    public function GetMakeupColorIndex() : Number;
    public function GetMakeupColorValue( index:Number ) : Number;

    public function GetSkinColorIndexes() : Array;
    public function SetSkinColorIndex( index:Number ) : Void;
    public function GetSkinColorIndex() : Number;
    public function GetSkinColorValue( index:Number ) : Number;

    public function GetFacialHairColorIndexes() : Array;
    public function SetFacialHairColorIndex( index:Number ) : Void;
    public function GetFacialHairColorIndex() : Number;
    public function GetFacialHairColorValue( index:Number ) : Number;

    public function GetHairColorIndexes() : Array;
    public function SetHairColorIndex( index:Number ) : Void;
    public function GetHairColorIndex() : Number;
    public function GetHairColorValue( index:Number ) : Number;

    public function GetEyeColorIndexes() : Array;
    public function SetEyeColorIndex( index:Number ) : Void;
    public function GetEyeColorIndex() : Number;
    public function GetEyeColorValue( index:Number ) : Number;

    public function GetFacialFeatureCount( feature:Number ) : Number;
    public function SetFacialFeature( feature:Number, index:Number ) : Void;
    public function GetFacialFeature( feature:Number ) : Number;

    public function SetRandomFacialPreset() : Void;
    
    public function SetCharacterScale( scale:Number ) : Void;
    public function GetCharacterScale() : Number;
    public function GetCharacterMinScale() : Number;
    public function GetCharacterMaxScale() : Number;
    
    public function SetFaction( faction:Number ) : Void;
    public function GetFaction() : Number;

    public function PreloadLooksPackage( packageID:Number, configuration:Number ) : Void;
    
    public function GetMorphVectorCount( vectorName:String ) : Number;
    public function SetMorphValue( name:String, value:Number ) : Void;
    public function GetMorphValue( name:String ) : Number;

    public function GetClothCount( location:Number ) : Number;
    public function GetClothName( location:Number, index:Number ) : String;
    public function GetClothIcon( location:Number, index:Number ) : Number;
    public function WearCloth( location:Number, index:Number ) : Void;
    public function GetClothSelection( location:Number ) : Number;
    public function UnWearCloth( location:Number ) : Void;
    public function CanClothSlotBeEmpty( location:Number ) : Boolean;
    public function SetLooksPackage( packageID:Number, configuration:Number ) : Void;
    public function RemoveLooksPackage( packageID:Number ) : Void;
    

    public function GetFactionCharacterLocation( faction:Number ) : Vector3;
    public function GetFactionCharacterRotation( faction:Number ) : Number;
    static public function FilterCharacterName( source:String ) : String;
    public function CreateCharacter( nickName:String, firstName:String, lastName:String ) : Void;
    public function SetSurgeryData( paymentTokenId:Number ) : Void;
    public function ResetSurgeryData() : Void;
    public function ExitCharacterCreation() : Void;
    public function HasMorphChanges() : Boolean;

    public var SignalGenderChanged:com.Utils.Signal;
    public var SignalBaseHeadChanged:com.Utils.Signal;
    public var SignalHairStyleChanged:com.Utils.Signal;
    public var SignalEyebrowChanged:com.Utils.Signal;
    public var SignalBeardChanged:com.Utils.Signal;
    public var SignalMakeupChanged:com.Utils.Signal;
    public var SignalMakeupColorChanged:com.Utils.Signal;
    public var SignalSkinColorChanged:com.Utils.Signal;
    public var SignalHairColorChanged:com.Utils.Signal;
    public var SignalFacialHairColorChanged:com.Utils.Signal;
    public var SignalEyeColorChanged:com.Utils.Signal;
    public var SignalFacialFeatureChanged:com.Utils.Signal;  // SlotFacialFeatureChanged( feature:Number, index:Number )
    public var SignalCharacterScaleChanged:com.Utils.Signal; // SlotCharacterScaleChanged( scale:Number )
    public var SignalClothingChanged:com.Utils.Signal;       // SlotClothingChanged( location:Number, index:Number )

    
    public var SignalCreateCharacterSucceded:com.Utils.Signal;
    public var SignalCreateCharacterFailed:com.Utils.Signal;
    public var SignalNameSuggestionReceived:com.Utils.Signal;

}

