import com.Utils.Signal;
intrinsic class com.GameInterface.CraftingInterface
{
    public static function StartCrafting();
    public static function StartDisassembly();
    public static function EndCrafting();
    public static function CloseCrafting();
    public static function SetDisassemblySlot(slotID:Number);
    
    public static var SignalCraftingResultFeedback:Signal;  
}