//Imports
import com.Utils.ID32;
import com.GameInterface.Utils;
import com.GameInterface.Game.BuffData;
import com.GameInterface.Tooltip.*;
import com.GameInterface.DistributedValue;

//Class
class GUI.WorldDomination.TokenComponent extends MovieClip
{
    //Properties
    private var m_IconLoader:MovieClipLoader;
    private var m_BuffData:BuffData;
    private var m_CharacterID:ID32;
	private var m_Tooltip:TooltipInterface;
    private var m_TooltipOrientation:Number;
    private var m_Icon:MovieClip;

    //Constructor
    public function BuffComponent()
    {
        super();
        		
		var loaderListener:Object = new Object();
		m_IconLoader = new MovieClipLoader();
		m_IconLoader.addListener(loaderListener);
        
        m_TooltipOrientation = TooltipInterface.e_OrientationVertical;
    }
    
    //Set Character ID
    public function SetCharacterID(characterID:ID32):Void
    {
        m_CharacterID = characterID;
    }
    
    //Set Tooltip Orientation
    public function SetTooltipOrientation(value:Number):Void
    {
        m_TooltipOrientation = value;
    }
    
    //Get Buff Data
    public function GetBuffData():BuffData
    {
        return m_BuffData;
    }
    
    //Set Buff Data
    public function SetBuffData(buffData:BuffData):Void
    {
        m_BuffData = buffData;
        
        SetIcon(m_BuffData.m_Icon);
    }
    
    //Set Icon
    public function SetIcon(icon:ID32):Void
    {
		//Default Icon
		var loadString:String = "rdb:1000624:7645315";
        
        if (icon.GetType() != 0 && icon.GetInstance() != 0)
        {
			loadString = Utils.CreateResourceString(icon) 
		}
		
        m_IconLoader.loadClip(loadString, m_Icon);
    }
    
    //Get Icon
    public function GetIcon(): MovieClip
    {
        return m_Icon;
    }
    
    //Make Tooltip
	private function MakeTooltip(buffID:Number):Void
	{
		var tooltipData:TooltipData = TooltipDataProvider.GetBuffTooltip(m_BuffData.m_BuffId, m_CharacterID);
		var delay:Number = DistributedValue.GetDValue( "HoverInfoShowDelayShortcutBar" );
        
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip(this, m_TooltipOrientation, delay, tooltipData);
	}
	
    //Make Tooltip Floading
	private function MakeTooltipFloating():Void
	{
		m_Tooltip.MakeFloating();
	}
    
    //Remove
    public function Remove():Void
    {
        CloseTooltip();
        UnloadIcon();
        
        this.removeMovieClip();
    }

    //Close Tooltip
	function CloseTooltip():Void
	{
		if (m_Tooltip != undefined)
		{
			if (!m_Tooltip.IsFloating())
			{
				m_Tooltip.Close();
			}
            
			m_Tooltip = undefined;
		}
	}
    
    //Unload Icon
	public function UnloadIcon():Void
	{
		m_IconLoader.unloadClip(m_Icon);
	}
    
    //On Mouse Press
    private function onMousePress(mouseButtonID:Number)
    {
        if (mouseButtonID == 1 &&  Key.isDown(Key.SHIFT))
        {
            MakeTooltipFloating();
        }
    }
    
    //On Roll Over
    private function onRollOver()
    {
        MakeTooltip(this.GetBuffData().m_BuffId);
    }
    
    //On Roll Out
    function onRollOut()
    {
        CloseTooltip();
    }    
}