import com.GameInterface.Utils;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.Utils.LDBFormat;

class com.GameInterface.Tooltip.Tooltip
{
  public static function SlotHyperLinkClicked( target:String )
  {
    var lowercaseStr:String = target.toLowerCase();

    var tagStart:Number = lowercaseStr.indexOf("spellref://");
    if(tagStart >= 0)
    {
      var featID:Number = 0;
      var spellIDStart = tagStart + 11;
      var spellIDEnd = lowercaseStr.indexOf(":", spellIDStart);
      //Meaning we have a feat required
      if(spellIDEnd != -1)
      {
        var featIDEnd = lowercaseStr.indexOf("/", spellIDEnd+1);
        var substrFeatIDLength = featIDEnd - (spellIDEnd + 1);
        var featIDStr:String = lowercaseStr.substr((spellIDEnd + 1), substrFeatIDLength);
        featID = Number(featIDStr);
      }
      else
      {
        spellIDEnd = lowercaseStr.indexOf("/", spellIDStart);
      }
      
      var substrSpellIDLength = spellIDEnd - spellIDStart;
      var spellIDStr:String = lowercaseStr.substr(spellIDStart, substrSpellIDLength);
      var spellID = Number(spellIDStr);
      var tooltipData = TooltipDataProvider.GetSpellTooltip(spellID, featID);
      
      TooltipManager.GetInstance().ShowTooltip( null, TooltipInterface.e_OrientationHorizontal, 0, tooltipData ).MakeFloating();
      return;
    }
		
    tagStart = lowercaseStr.indexOf("comboref://");
    if(tagStart >= 0)
    {
      var substrLength = lowercaseStr.indexOf("/", tagStart + 11) - (tagStart + 11);
      var comboIDStr:String = lowercaseStr.substr(tagStart + 11, substrLength);
      var comboID = Number(comboIDStr);
			
      var tooltipData:TooltipData = TooltipDataProvider.GetComboTooltip(comboID);
			
      TooltipManager.GetInstance().ShowTooltip( null, TooltipInterface.e_OrientationHorizontal, 0, tooltipData ).MakeFloating();
    }
    
    tagStart = lowercaseStr.indexOf("ldbref://");
    if(tagStart >= 0)
    {
        var substrLength = target.length - (tagStart + 9);
        var ldbRefStr:String = target.substr(tagStart + 9, substrLength);
        var category:String = ldbRefStr.substr(0, ldbRefStr.indexOf(":"));
        var instance:String = ldbRefStr.substr(ldbRefStr.indexOf(":") + 1, ldbRefStr.length);

        var tooltipData:TooltipData = new TooltipData();
        tooltipData.m_Descriptions.push(LDBFormat.LDBGetText(category, instance));
        tooltipData.m_MaxWidth = 180;
        TooltipManager.GetInstance().ShowTooltip( null, TooltipInterface.e_OrientationHorizontal, 0, tooltipData ).MakeFloating();

    }
  }
}
