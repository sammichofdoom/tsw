import com.GameInterface.Tooltip.*;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import com.GameInterface.FeatData;
import com.Utils.LDBFormat;

dynamic class GUI.SkillHive.SkillhiveCellTooltip extends MovieClip
{    
    private var m_CellName:TextField;
    private var m_Tooltip:TooltipInterface = undefined;
    
    private var m_NumAbilities = 7;
    private var m_HoveredAbilityIdx = -1;
    
    public var SignalAbilityPressed:Signal;

    function SkillhiveCellTooltip()
    {
        super();
        SignalAbilityPressed = new Signal;
    }
	function SetName(name:String)
	{
        m_CellName.text = name;
	}
	
	function SetAbility(feat:FeatData, index:Number, isInTemplate:Boolean)
	{
        var symbolName:String = "";
        var templateSymbolName:String = "";
        var costColor:Number = 0x999999
        if (feat.m_Trained)
        {
            templateSymbolName ="TemplateAbilityTrained";
            //symbolName = "TickIcon";
        }
        else if(!feat.m_CanTrain)
        {
            templateSymbolName ="TemplateAbilityUnavailable";
            costColor = 0xFF2222;
            symbolName = "LockIcon";
        }
        else
        {
            templateSymbolName ="TemplateAbilityAvailable";
            costColor = 0x22FF22;
        }

        
		var abilityMC:MovieClip = this["m_Ability_" + index];
		abilityMC.m_Name.text = feat.m_Name;
		abilityMC.m_Cost.text = feat.m_Cost + " " +  LDBFormat.LDBGetText("SkillhiveGUI", "AnimaPointsAbbreviation");
		abilityMC.m_Cost.textColor = costColor;
        
        abilityMC.m_Id = index;
        abilityMC.m_Feat = feat;
        abilityMC.m_Ref = this;
        abilityMC.m_Background._alpha = 0;
        		
		//No filters yet
		if (filterName != "")
		{
			//var filterMc:MovieClip = this["m_Filter_" + index];
			//filterMc.attachMovie(filterName, "m_Filter", filterMc.getNextHighestDepth());
		}
		if (symbolName != "")
		{	
			var symbolMc:MovieClip = abilityMC["m_Symbol"];
			symbolMc.attachMovie(symbolName, "m_Symbol", symbolMc.getNextHighestDepth());
			symbolMc._xscale = 30;
			symbolMc._yscale = 30;
            abilityMC.m_Cost._x -= symbolMc._width;
		}
        
        if (isInTemplate)
        {
            abilityMC.m_Template.attachMovie(templateSymbolName, "m_Template", abilityMC.m_Template.getNextHighestDepth(),{_xscale:50,_yscale:50});
        }
        
	}
    
    function SetCover(cover:Boolean, index:Number)
    {
        var coverMC:MovieClip = this["m_Cover_" + index];
        
        if (!cover)
        {
            coverMC._visible = false;
        }
        else
        {
            coverMC._visible = true;
            coverMC._alpha = 60;
        }
    }
     
    private function CloseTooltip() : Void
    {
        if ( m_Tooltip != undefined )
        {
            m_Tooltip.Close();   
            m_Tooltip = undefined;
        }
    }
    
    private function RollOverAbility(abilityClip:MovieClip)
    {
        if (m_Tooltip != undefined)
        {
            CloseTooltip();
        }
        //Do not show tooltip if there is no data
        if (abilityClip.m_Feat.m_Spell == undefined || abilityClip.m_Feat.m_Spell == 0)
        {
            return;
        }
        
        abilityClip.m_Background.tweenTo(0.2, { _alpha: 100}, Regular.easeOut );
        
        var tooltipData:TooltipData = TooltipDataProvider.GetSpellTooltip( abilityClip.m_Feat.m_Spell );
        var delay:Number = DistributedValue.GetDValue( "HoverInfoShowDelayShortcutBar" );
        m_Tooltip = TooltipManager.GetInstance().ShowTooltip( abilityClip, TooltipInterface.e_OrientationVertical, delay, tooltipData );
    }
    
    private function RollOutAbility(abilityIndex:Number)
    {
        var abilityMc:MovieClip = this["m_Ability_" + abilityIndex];
        if (abilityMc != undefined)
        {
            abilityMc.m_Background.tweenTo(0.2, { _alpha: 0}, Regular.easeOut );
        }
        CloseTooltip();
    }
    
    function onMouseMove()
	{
		for (var i:Number = 0; i < m_NumAbilities; i++)
		{
			var abilityMc:MovieClip = this["m_Ability_" + i];
			if (abilityMc != undefined)
			{
				if (abilityMc.hitTest(_root._xmouse, _root._ymouse))
				{
					if (m_HoveredAbilityIdx == i)
					{
						return;
					}
					else if (m_HoveredAbilityIdx != -1)
					{
			            RollOutAbility(m_HoveredAbilityIdx);
					}
					RollOverAbility(abilityMc);
					m_HoveredAbilityIdx = i;
					return;
				}
			}
		}
		if (m_HoveredAbilityIdx != -1)
		{
            RollOutAbility(m_HoveredAbilityIdx);    
			m_HoveredAbilityIdx = -1;	
		}
	}
    
    function onMouseDown()
    {
        for (var i:Number = 0; i < m_NumAbilities; i++)
		{
			var abilityMc:MovieClip = this["m_Ability_" + i];
			if (abilityMc != undefined)
			{
				if (abilityMc.hitTest(_root._xmouse, _root._ymouse))
				{
                    abilityMc.m_Ref.SignalAbilityPressed.Emit(abilityMc.m_Id);
                }
            }
        }
    }
}