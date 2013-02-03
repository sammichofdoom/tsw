//Imports
import com.Utils.LDBFormat;
import com.Utils.Colors;

//Class 
class GUI.SkillHive.CharacterPointsSubSkillsBar extends MovieClip
{
    //Constants
    private static var MAXIMUM_SLOTS:Number = 10;
    
    private static var MELEE_PURCHASED_COLOR:Number     = 0xD47100;
    private static var MELEE_UNLOCKED_COLOR:Number      = 0x584937;
    
    private static var RANGED_PURCHASED_COLOR:Number    = 0xD04848;
    private static var RANGED_UNLOCKED_COLOR:Number     = 0x634444;
    
    private static var MAGIC_PURCHASED_COLOR:Number     = 0x2A92D4;
    private static var MAGIC_UNLOCKED_COLOR:Number      = 0x37516D;
    
    private static var CHAKRAS_PURCHASED_COLOR:Number   = 0xBA4874;
    private static var CHAKRAS_UNLOCKED_COLOR:Number    = 0x633F53;
	
    private static var AUXILLIARY_PURCHASED_COLOR:Number   = 0x7eeced;
    private static var AUXILLIARY_UNLOCKED_COLOR:Number    = 0x1a6673;
    
    //Properties
    private var m_Category:String;
    private var m_PurchasedTotal:Number;
    
    private var m_PurchasedColor:Number;
    private var m_UnlockedColor:Number;
	
	private var m_Levels:Number;
	
	private var m_Slots:Array;
    
    //Constructor
    public function CharacterPointsSubSkillsBar()
    {
        super();
        
        m_PurchasedTotal = 0;
		
		m_Levels = MAXIMUM_SLOTS;
		m_Slots = new Array();
    }
    
    //Update
    public function Update():Void
    {
		
		CreateSlots();
        for (var purchased:Number = 0; purchased < m_PurchasedTotal; purchased++)
        {
            AdjustSlot(purchased, m_PurchasedColor);
        }
        
        for (var unlocked:Number = m_PurchasedTotal; unlocked < m_Levels; unlocked++)
        {
            AdjustSlot(unlocked, m_UnlockedColor);
        }
    }
	
	private function CreateSlots()
	{
		for (var i:Number = 0; i < m_Slots.length; i++)
		{
			m_Slots[i].removeMovieClip();
		}
		m_Slots = new Array();
		
		var padding:Number = 6;
		
		var paddingTotal:Number = (m_Levels - 1) * padding;
		var totalWidth = 984 - paddingTotal;
		
		var baseWidth:Number = totalWidth / m_Levels;
		var startDiff:Number = (m_Levels - 1) * 10 / 2;
		var x:Number = 0;
		for (var i:Number = 0; i < m_Levels; i++)
		{
			var slot:MovieClip = this.attachMovie("CharacterPointsSubSkillsSlot", "m_Slot" + i, this.getNextHighestDepth() );
			slot._x = x 
			slot._y = 3;
			slot._width = baseWidth  - startDiff + 10 * i;
			x += slot._width + padding;
			m_Slots.push(slot);
		}
		
		
	}
    
    //Adjust Slot
    private function AdjustSlot(index:Number, color:Number):Void
    {
        
    /*
     *  The CharacterPointsSubSkillsBar MovieClip inside the SkillHive.fla is
     *  composed of 10 MovieClip objects named from "m_Slot0" to "m_Slot9"
     * 
     */
        
        Colors.ApplyColor(this["m_Slot" + index], color);
    }
    
    //Set Category
    public function SetCategory(value:String):Void
    {
        switch (value)
        {
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "MeleeCategoryTitle"):      m_PurchasedColor = MELEE_PURCHASED_COLOR;
                                                                                        m_UnlockedColor = MELEE_UNLOCKED_COLOR;
                                                                                                                                                                                                                                                                        
                                                                                        break;
                                                                                    
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "RangedCategoryTitle"):     m_PurchasedColor = RANGED_PURCHASED_COLOR;
                                                                                        m_UnlockedColor = RANGED_UNLOCKED_COLOR;
                                                                                                                                                                                                                                                                        
                                                                                        break;
                                                                                    
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "MagicCategoryTitle"):      m_PurchasedColor = MAGIC_PURCHASED_COLOR;
                                                                                        m_UnlockedColor = MAGIC_UNLOCKED_COLOR;
                                                                                                                                                                                                                                                                        
                                                                                        break;
                                                                                    
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "ChakrasCategoryTitle"):    m_PurchasedColor = CHAKRAS_PURCHASED_COLOR;
                                                                                        m_UnlockedColor = CHAKRAS_UNLOCKED_COLOR;
                                                                                                                                                                                                                                                                        
                                                                                        break;
                                                                                    
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "AuxilliaryCategoryTitle"): m_PurchasedColor = AUXILLIARY_PURCHASED_COLOR;
                                                                                        m_UnlockedColor = AUXILLIARY_UNLOCKED_COLOR;
																						
																						break;
            }
    }
	
	public function SetLevels(levels:Number) : Void
	{
		m_Levels = levels;
	}

    //Set Purchased Total
    public function SetPurchasedTotal(value:Number):Void
    {
        m_PurchasedTotal = Math.round(Math.min(Math.max(0, value), m_Levels));
    }
}