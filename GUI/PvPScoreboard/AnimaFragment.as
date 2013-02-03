//Imports
import com.Utils.ID32;
import com.Utils.Format;

//Class
class GUI.PvPScoreboard.AnimaFragment extends MovieClip
{
    //Constants
    public static var MAJOR_ANIMA_FRAGMENT:String = "majorAnimaFragment";
    public static var MINOR_ANIMA_FRAGMENT:String = "minorAnimaFragment";
    
    //Properties
    private var m_IconContainer:MovieClip;
    private var m_Label:TextField;

    //Constructor
    public function AnimaFragment()
    {
        super();
        
        m_Label.autoSize = "left";
    }
    
    //Set Reward
    public function SetReward(rewardType:String, rewardAmount:String):Void
    {
        m_IconContainer = createEmptyMovieClip("m_IconContainer", getNextHighestDepth());
        
        if (rewardType == MAJOR_ANIMA_FRAGMENT)
        {
            AttachAnimaFragmentIcon(7460077);
        }
        else
        {
            AttachAnimaFragmentIcon(7460078);
            m_Label._x -= 2;
        }
        
        m_Label.text = rewardAmount;
    }
    
    //Attach Anima Fragment Icon
    public function AttachAnimaFragmentIcon(RDBInstance:Number):Void
    {
        var icon:ID32 = new ID32();
        icon.SetType(1000624);
        icon.SetInstance(RDBInstance);

        var movieClipLoader:MovieClipLoader = new MovieClipLoader();
        movieClipLoader.loadClip(Format.Printf("rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance()), m_IconContainer);
        
        m_IconContainer._xscale = m_IconContainer._yscale = 28;
        m_IconContainer._y = 1;
    }
}