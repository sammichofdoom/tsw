import com.Utils.ID32;
    
intrinsic class com.GameInterface.Tooltip.TooltipDataProvider
{
    static function GetFeatTooltip( featID:Number, propertiesOnly:Boolean ) : com.GameInterface.Tooltip.TooltipData;
    static function GetSpellTooltip( spellID:Number, featID:Number ) : com.GameInterface.Tooltip.TooltipData;
    static function GetBuffTooltip( spellID:Number, characterID:com.Utils.ID32 ) : com.GameInterface.Tooltip.TooltipData;
    static function GetPassiveTooltip( passiveSlot:Number ) : com.GameInterface.Tooltip.TooltipData;
    static function GetComboTooltip( comboID:Number ) : com.GameInterface.Tooltip.TooltipData;
    static function GetInventoryItemTooltip( inventoryID:com.Utils.ID32, itemPos:Number, compareInventoryID:ID32, comparePos:Number ) : com.GameInterface.Tooltip.TooltipData;
    static function GetInventoryItemTooltipCompareInventoryItem( inventoryID:com.Utils.ID32, itemPos:Number, compareInventoryID:ID32, comparePos:Number ) : com.GameInterface.Tooltip.TooltipData;
    static function GetInventoryItemTooltipCompareACGItem( inventoryID:com.Utils.ID32, itemPos:Number,compareAcgItem:com.GameInterface.ACGItem ) : com.GameInterface.Tooltip.TooltipData;
    static function GetACGItemTooltip( acgItem:com.GameInterface.ACGItem ) : com.GameInterface.Tooltip.TooltipData;
    static function GetShortcutbarTooltip( shortcuPos:Number ) : com.GameInterface.Tooltip.TooltipData;
}
