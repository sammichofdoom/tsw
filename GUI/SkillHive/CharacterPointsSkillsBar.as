//Imports
import com.Utils.LDBFormat;
import com.Utils.Colors;
import flash.geom.Matrix;
import flash.geom.Rectangle;

//Class 
class GUI.SkillHive.CharacterPointsSkillsBar extends MovieClip
{
    //Constants
    private static var MAXIMUM_SLOTS:Number = 10;
    private static var MIN_SLOT_WIDTH:Number = 48;
    private static var MAX_BAR_WIDTH:Number = 986;
    private static var INCREASED_SLOT_WIDTH:Number = 10;
    private static var GAP:Number = 6;
    
    private static var MELEE_PURCHASED_LEFT_COLOR:Number    = 0xDD8A2B;
    private static var MELEE_PURCHASED_RIGHT_COLOR:Number   = 0xE29B4B;
    private static var MELEE_UNLOCKED_COLOR:Number          = 0x6F4C20;

    private static var RANGED_PURCHASED_LEFT_COLOR:Number   = 0xFF5A5A;
    private static var RANGED_PURCHASED_RIGHT_COLOR:Number  = 0xFF7373;
    private static var RANGED_UNLOCKED_COLOR:Number         = 0x803E3E;

    private static var MAGIC_PURCHASED_LEFT_COLOR:Number    = 0x31AFFF;
    private static var MAGIC_PURCHASED_RIGHT_COLOR:Number   = 0x50BBFF;
    private static var MAGIC_UNLOCKED_COLOR:Number          = 0x2C5b8A;

    private static var CHAKRAS_PURCHASED_LEFT_COLOR:Number  = 0xD05B89;
    private static var CHAKRAS_PURCHASED_RIGHT_COLOR:Number = 0xDC84A7;
    private static var CHAKRAS_UNLOCKED_COLOR:Number        = 0x7B4258;
	
    private static var AUXILLIARY_PURCHASED_LEFT_COLOR:Number  = 0x1a6673;
    private static var AUXILLIARY_PURCHASED_RIGHT_COLOR:Number = 0x7eeced;
    private static var AUXILLIARY_UNLOCKED_COLOR:Number        = 0x315762;

    
    //Properties
    private var m_Label:TextField;
    private var m_PurchasedBar:MovieClip;
    private var m_UnlockedBar:MovieClip;
    private var m_PurchasedTotal:Number;
    
    private var m_PurchasedLeftColor:Number;
    private var m_PurchasedRightColor:Number;
    private var m_UnlockedColor:Number;
	
	private var m_Levels:Number;
	private var m_MinSlotWidth:Number;
    
    //Constructor
    public function CharacterPointsSkillsBar()
    {
        super();
        
        m_PurchasedTotal = 0;
        
        m_PurchasedBar._width = 0;
        m_UnlockedBar._width = 0;
		
		m_Levels = MAXIMUM_SLOTS;
		m_MinSlotWidth = MIN_SLOT_WIDTH;
    }
    
    //Adjust Color
    private function AdjustColor():Void
    {
        
    /*
     *  The CharacterPointsSkillsBar MovieClip inside the SkillHive.fla is composed
     *  of 2 MovieClip objects:  "m_PurchasedBar" and "m_UnlockedBar".
     * 
     */
        Colors.ApplyColor(m_UnlockedBar, m_UnlockedColor);
        AdjustBarWidth(m_UnlockedBar, MAXIMUM_SLOTS);
        
        var matrixGradientBox:Matrix = new Matrix();
        matrixGradientBox.createGradientBox(m_UnlockedBar._width, m_UnlockedBar._height);
        
        m_PurchasedBar.lineStyle();
        m_PurchasedBar.beginGradientFill("linear", [m_PurchasedLeftColor, m_PurchasedRightColor], [100, 100], [0, 255], matrixGradientBox);
        m_PurchasedBar.lineTo(m_UnlockedBar._width, m_UnlockedBar._y)
        m_PurchasedBar.lineTo(m_UnlockedBar._width, m_UnlockedBar._height);
        m_PurchasedBar.lineTo(m_UnlockedBar._x, m_UnlockedBar._height);
        m_PurchasedBar.lineTo(m_UnlockedBar._x, m_UnlockedBar._y);
        m_PurchasedBar.endFill();
    }
    
    //Adjust Bar Width
    private function AdjustBarWidth(target:MovieClip, value:Number):Void
    {
     
    /*
     *  The width of the Purchased Bar or Unlocked Bar within the Skills Bar is set to align at the center
     *  of the 6 pixel gap between each Sub Skills slot, 3 pixels more than the width of each Sub Skill slot.
     * 
     */
        
        if (value != 0)
        {
            target._width = Math.min((value * m_MinSlotWidth) + ((value - 1) * value / 2) * INCREASED_SLOT_WIDTH + ((value - 1) * GAP) + 3, MAX_BAR_WIDTH);
        }
        else
        {
            target._width = 0;
        }
    }
    
    //Set Category
    public function SetCategory(value:String):Void
    {    
        switch (value)
        {
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "MeleeCategoryTitle"):      m_PurchasedLeftColor = MELEE_PURCHASED_LEFT_COLOR;
                                                                                        m_PurchasedRightColor = MELEE_PURCHASED_RIGHT_COLOR;
                                                                                        m_UnlockedColor = MELEE_UNLOCKED_COLOR;
                                                                                                                                                                                                                                                                        
                                                                                        break;
                                                                                    
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "RangedCategoryTitle"):     m_PurchasedLeftColor = RANGED_PURCHASED_LEFT_COLOR;
                                                                                        m_PurchasedRightColor = RANGED_PURCHASED_RIGHT_COLOR;
                                                                                        m_UnlockedColor = RANGED_UNLOCKED_COLOR;
                                                                                                                                                                                                                                                                        
                                                                                        break;
                                                                                    
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "MagicCategoryTitle"):      m_PurchasedLeftColor = MAGIC_PURCHASED_LEFT_COLOR;
                                                                                        m_PurchasedRightColor = MAGIC_PURCHASED_RIGHT_COLOR;
                                                                                        m_UnlockedColor = MAGIC_UNLOCKED_COLOR;
                                                                                                                                                                                                                                                                        
                                                                                        break;
                                                                                    
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "ChakrasCategoryTitle"):    m_PurchasedLeftColor = CHAKRAS_PURCHASED_LEFT_COLOR;
                                                                                        m_PurchasedRightColor = CHAKRAS_PURCHASED_RIGHT_COLOR;
                                                                                        m_UnlockedColor = CHAKRAS_UNLOCKED_COLOR;
																						
																						break;
																						
            case LDBFormat.LDBGetText("CharacterSkillsGUI", "AuxilliaryCategoryTitle"): m_PurchasedLeftColor = AUXILLIARY_PURCHASED_LEFT_COLOR;
                                                                                        m_PurchasedRightColor = AUXILLIARY_PURCHASED_RIGHT_COLOR;
                                                                                        m_UnlockedColor = AUXILLIARY_UNLOCKED_COLOR;
																						
																						break;
        }
        
        AdjustColor();
    }
	
	public function SetLevels(levels:Number):Void
	{
		m_Levels = levels;
		
		var paddingTotal:Number = (m_Levels - 1) * GAP;
		var totalWidth = MAX_BAR_WIDTH - paddingTotal;
		var baseWidth:Number = totalWidth / m_Levels;
		var startDiff:Number = (m_Levels - 1) * 10 / 2;
		m_MinSlotWidth = baseWidth - startDiff;
        AdjustBarWidth(m_UnlockedBar, m_Levels);
        AdjustBarWidth(m_PurchasedBar, m_PurchasedTotal);
	}

    //Set Label
    public function SetLabel(value:String):Void
    {
        m_Label.text = value;
    }
    
    //Set Label Alpha
    public function SetLabelAlpha(value:Number):Void
    {
        m_Label._alpha = value;
    }

    //Set Purchased Total
    public function SetPurchasedTotal(value:Number):Void
    {
        m_PurchasedTotal = Math.round(Math.min(Math.max(0, value), MAXIMUM_SLOTS));

        AdjustBarWidth(m_PurchasedBar, m_PurchasedTotal);           
    }
}