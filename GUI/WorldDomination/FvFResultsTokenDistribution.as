//Imports
import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.Utils.Format;
import com.GameInterface.Tooltip.*;

//Class
class GUI.WorldDomination.FvFResultsTokenDistribution extends MovieClip
{
    //Constants
    private static var FACTION_REWARDS_DISTRIBUTION:String = LDBFormat.LDBGetText("WorldDominationGUI", "factionRewardsDistribution");
    private static var REWARDS_DISTRIBUTION_TOOLTIP:String = LDBFormat.LDBGetText("WorldDominationGUI", "factionRewardsDistributionTooltip");
    
    public static var MINOR_ANIMA_FRAGMENT:Number = 7460078;
    
    //Properties
    private var m_TitleTextField:TextField;
    private var m_TimeTextField:TextField;
    
    //Constructor
    public function FvFResultsTokenDistribution()
    {
        super();
    }
    
    //On Load
    private function onLoad():Void
    {
        m_TitleTextField.text = FACTION_REWARDS_DISTRIBUTION;
        
        var m_Icon = createEmptyMovieClip("icon", getNextHighestDepth());
                            
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        icon.SetInstance(MINOR_ANIMA_FRAGMENT);

        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), m_Icon);
        
        TooltipUtils.AddTextTooltip( this, REWARDS_DISTRIBUTION_TOOLTIP, 250, TooltipInterface.e_OrientationHorizontal, true, false); 
        
        m_Icon._x = 6;
        m_Icon._y = 9;
        m_Icon._xscale = m_Icon._yscale = 40;
    }
    
    //Update Label
    public function UpdateLabel(remainingTime:String):Void
    {
        m_TitleTextField.text = FACTION_REWARDS_DISTRIBUTION + "\n" +remainingTime;
    }
}