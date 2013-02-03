
class com.GameInterface.GUIUtils.FlashEnums
{
		/// color names
		public static var e_ColorBlack:Number = 0x000000;
		public static var e_ColorYellow:Number = 0xFFF666;
		public static var e_ColorGray:Number = 0xAAAAAA;
		public static var e_ColorRed:Number = 0xa40001; 
		public static var e_ColorDarkBlue:Number = 0x023A8E;
		public static var e_ColorBlue:Number = 0x00415E;
    public static var e_ColorLightBlue:Number = 0x0E93E7;
		public static var e_ColorGreen:Number = 0x1FBB00;
		public static var e_ColorLightGreen:Number = 0x00FF12;
		public static var e_ColorOrange :Number = 0xFF9900;
		public static var e_ColorLightRed:Number = 0xFD0001;
		public static var e_ColorCyan:Number = 0x00FCFF;
		public static var e_ColorMagenta:Number = 0xF600FF;
		public static var e_ColorCharcoal:Number = 0x333333;
		public static var e_ColorGray50:Number = 0xCCCCCC;
				
		/// named resources
		public static var e_ColorCastbar:Number = e_ColorCyan;
		public static var e_ColorDisabledAbility:Number = e_ColorBlack;
		
		/// icons, abilities
		public static var e_ColorIconUtility:Number = e_ColorOrange;
		public static var e_ColorIconHostile:Number = e_ColorRed;
		public static var e_ColorIconBuff:Number = e_ColorLightBlue;
		public static var e_ColorIconHeal:Number = e_ColorGreen;
		public static var e_ColorIconDefault:Number = e_ColorRed;	
 		public static var e_ColorIconPassives:Number = e_ColorDarkBlue;   

		/// buff debuffs and states conditions
		public static var e_ColorBuff:Number = e_ColorDarkBlue;
		public static var e_ColorDebuff:Number = e_ColorLightRed;
		public static var e_ColorStates:Number = e_ColorCyan;
		
		/// token colors
		public static var e_ColorDefaultToken:Number = e_ColorGray50;
		
		/// Health bars
		public static var e_ColorHealthCritical:Number = e_ColorLightRed;
		public static var e_ColorHealthNormal:Number = e_ColorLightGreen;
		public static var e_ColorAnimaCritical:Number = e_ColorLightRed;
		public static var e_ColorAnimaNormal:Number = e_ColorYellow;
		
		/// scrollbar uints
		public static var e_ColorUintScrollbarBackground:Number = e_ColorCharcoal;
		public static var e_ColorUintScrollbarBorder:Number = e_ColorGray50;
		public static var e_ColorUintScrollbarHandler:Number = e_ColorGray50;
	
		/// Strings
		public static var e_DirectionRight:String = "right";	
		public static var e_DirectionLeft:String = "left";	
		
		/// events
		public static var e_EventTimerComplete:String = "timercomplete";	
		public static var e_EventClick:String = "click";	
		
		/// Magic 
		public static var e_MillisecondOutput:Number = 0;
		public static var e_SecondOutput :Number = 1;
		public static var e_MinuteOutput:Number =  2;
		
		/// Stage default sizes
		 public static var e_StageHeight:Number = 1024;
		 public static var e_StageWidth:Number = 1280;
		
		/// type checking
		public static var e_FlashtypeClass:String = "object";	
		public static var e_FlashtypeObject:String = "object";	
		public static var e_FlashtypeMovieclip:String = "movieclip"

	  public static function GetColor( p_colorline:Number) : Number
    {
      switch( p_colorline )
      {
        case 1:
          return e_ColorIconHostile;

        case 2:
          return e_ColorIconUtility;

        case 3:
          return e_ColorIconBuff;

        case 4:
          return e_ColorIconHeal;

        case 5:
          return e_ColorIconPassives;
        
        default:
          return e_ColorIconDefault;
      }
    }
	
	

}
