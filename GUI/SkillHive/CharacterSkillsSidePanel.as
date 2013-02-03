//Imports
import com.Utils.LDBFormat;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import mx.controls.NumericStepper;

//Class 
class GUI.SkillHive.CharacterSkillsSidePanel extends MovieClip
{
    //Constants
    private static var BORDER_LINE_WIDTH:Number = 5;
    
    //Properties
    private var m_BorderLine:MovieClip;
    private var m_Background:MovieClip;
    private var m_Text:MovieClip;
    private var m_DescriptiveText:TextField;
    private var m_Height:Number;
    private var m_Width:Number;
    private var m_SkillPointsString:String;
    private var m_TotalPointsSpentString:String;
    private var m_SPString:String;
    
    //Constructor
    public function CharacterSkillsSidePanel()
    {
        super();
        
        m_SkillPointsString = LDBFormat.LDBGetText("CharacterSkillsGUI", "SkillPoints") + ":";
        m_TotalPointsSpentString = LDBFormat.LDBGetText("CharacterSkillsGUI", "TotalPointsSpent") + ":";
        m_SPString = LDBFormat.LDBGetText("CharacterSkillsGUI", "SP");
        
        m_DescriptiveText.htmlText = LDBFormat.LDBGetText("CharacterSkillsGUI", "DescriptiveHTMLText");
        m_DescriptiveText.autoSize = "right";
    }

    //Position Text
    private function PositionText(scale:Number):Void
    {
        var spacer:Number = 20;
        
        m_Text._xscale = m_Text._yscale = scale;
        m_Text._x = -spacer;
        
        m_DescriptiveText._width = m_Width - spacer * 2;
        m_DescriptiveText._x = m_Text._x - m_DescriptiveText._width;

        m_Text._y = m_Height / 2 - m_Text._height / 2 - m_DescriptiveText._height / 2 - spacer;
        m_DescriptiveText._y = m_Text._y + m_Text._height + spacer * 2;
        
        m_Background._width = m_Width - BORDER_LINE_WIDTH;
        m_Background._height = m_Height;
        m_Background._x = -BORDER_LINE_WIDTH;
        m_Background._y = 0;
    }
    
    //Set Size
    public function SetSize(width:Number, height:Number):Void
    {
        m_Width = width;
        m_Height = height;
        m_BorderLine._height = height;
    }
    
    //Set Text
    public function SetText(pointsValue:Number, spentValue:Number):Void
    {
        var skillPointsValueText:TextField = m_Text.m_SkillPointsValue;
        var skillPointsLabelText:TextField = m_Text.m_SkillPointsLabel;
        var totalPoinstSpentText:TextField = m_Text.m_TotalPointsSpent;
        var totalPoinstSpentSPText:TextField = m_Text.m_TotalPointsSpentSP;
        
        var titleWhiteSpace:Number = 10;
        var subTitleWhiteSpace:Number = 8;

        skillPointsLabelText.autoSize = totalPoinstSpentText.autoSize = "right";
        skillPointsLabelText.wordWrap = totalPoinstSpentText.wordWrap = false;
        
        skillPointsValueText.text = pointsValue.toString() + "/" + com.GameInterface.Utils.GetGameTweak("SkillTokensCap");
        skillPointsLabelText.text = m_SkillPointsString;
        totalPoinstSpentSPText.text = m_SPString;
        totalPoinstSpentText.text = m_TotalPointsSpentString + " " + spentValue.toString();
        
        skillPointsLabelText._x = -skillPointsLabelText._width - skillPointsValueText.textWidth - titleWhiteSpace;
        totalPoinstSpentText._x = -totalPoinstSpentText._width - totalPoinstSpentSPText.textWidth - subTitleWhiteSpace;

        TooltipUtils.AddTextTooltip(m_Text, LDBFormat.LDBGetText("CharacterSkillsGUI", "SidePanelTooltipText"), 150, TooltipInterface.e_OrientationVertical, true);
    }
    
    //Set Text Scale
    public function SetTextScale(scale:Number):Void
    {
        PositionText(scale);
    }
}