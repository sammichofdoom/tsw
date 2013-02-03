class com.GameInterface.Tooltip.TooltipData
{

  public var m_Header:String;
  public var m_Title:String;
  public var m_IconName:String;
  public var m_SubTitle:String;
  public var m_ItemBindingDesc:String;
  public var m_MiscItemInfo:String;
  public var m_Descriptions:Array;
  public var m_IconID:com.Utils.ID32;
  public var m_Attributes:Array;
  public var m_CompareAttributes:Array;
  public var m_CurrentlyEquippedItems:Array;
  public var m_IsEquipped:Boolean;
  public var m_IsUnique:Boolean;
  public var m_Color:Number;
  public var m_CastTime:Number;
  public var m_RecastTime:Number;
  public var m_WeaponTypeRequirement:Number;
  public var m_ItemCriteriaType:Number;
  public var m_ItemCriteriaLevel:Number;
  public var m_ItemRank:String;
  public var m_WeaponType:Number;
  public var m_SpellType:Number;
  public var m_AttackType:Number;
  public var m_GMInfo:String;
  public var m_SellPrice:Number;
  public var m_PlayerSellPrice:Number;
  public var m_ItemSentTo:String;
  public var m_Durability:Number;
  public var m_MaxDurability:Number;
  public var m_EmptyPrefix:Boolean;
  public var m_EmptySuffix:Boolean;
  public var m_PrefixData:TooltipData;
  public var m_SuffixData:TooltipData;
  
  public var m_CenterHeader:Boolean = false;
  public var m_Padding:Number;
  public var m_MaxWidth:Number;
  
  public static var e_ModeNormal:Number=0;
  public static var e_ModeLabel:Number=1;
  public static var e_ModeSplitter:Number=2;
  
  public function TooltipData()
  {
    m_Attributes = new Array;
    m_CurrentlyEquippedItems = new Array;
    m_Descriptions = new Array;
	m_Padding = 10;
	m_MaxWidth = 0;
	m_IsEquipped = false;
  }
  
  public function AddDescription(desc:String)
  {
      m_Descriptions.push(desc);
  }
  public function AddAttribute( left:String, right:String )
  {
    var attribute:Object = new Object;
    attribute.m_Left = left;
    attribute.m_Right = right;
    attribute.m_Mode = e_ModeNormal;
    m_Attributes.push( attribute );
  }
  
  public function AddAttributeHeader( header:String )
  {
    var attribute:Object = new Object;
    attribute.m_Left  = header;
    attribute.m_Right = undefined;
    attribute.m_Mode = e_ModeLabel;
    m_Attributes.push( attribute );
  }
  public function AddAttributeSplitter()
  {
    var attribute:Object = new Object;
    attribute.m_Left  = undefined;
    attribute.m_Right = undefined;
    attribute.m_Mode = e_ModeSplitter;
    m_Attributes.push( attribute );
  }
}
