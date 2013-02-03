//Imports
import com.GameInterface.FeatData;
import com.GameInterface.FeatInterface;
import com.GameInterface.SkillWheel.SkillTemplate;

//Class
class GUI.SkillHive.SkillHiveFeatHelper
{
    //Constants
    static var ABILITIY_ROW_TOTAL:Number = 7;

    //Deck Contains Feat
    public static function DeckContainsFeat(deck:SkillTemplate, featID:Number):Boolean
    {
        for (var i:Number = 0; i < ABILITIY_ROW_TOTAL; i++)
        {
            var featData:FeatData = FeatInterface.m_FeatList[deck.m_PassiveAbilities[i]];
                                
            if (featData.m_Id == featID)
            {
                return true;
            }
        }
        
        for (var i:Number = 0; i < ABILITIY_ROW_TOTAL; i++)
        {
            var featData:FeatData = FeatInterface.m_FeatList[deck.m_ActiveAbilities[i]];
            
            if (featData.m_Id == featID)
            {
                return true;
            }                       
        }
        
        return false;
    }
    
    //Deck Is Complete
    public static function DeckIsComplete(deck:SkillTemplate):Boolean
    {
        var numTrainedAbilities:Number = 0;

        if (deck.m_PassiveAbilities != undefined)
        {
            for (var i:Number = 0; i < ABILITIY_ROW_TOTAL; i++)
            {
                var featData:FeatData = FeatInterface.m_FeatList[deck.m_PassiveAbilities[i]];
                                    
                if (featData != undefined)
                {
                    if (featData.m_Trained)
                    {
                        numTrainedAbilities++;
                    }
                }
            }
        }
        
        if (deck.m_ActiveAbilities != undefined)
        {
            for (var i:Number = 0; i < ABILITIY_ROW_TOTAL; i++)
            {
                var featData:FeatData = FeatInterface.m_FeatList[deck.m_ActiveAbilities[i]];
                
                if (featData != undefined)
                {
                    if (featData.m_Trained)
                    {
                        numTrainedAbilities++;
                    }                        
                }
            }
        }
        
        return (numTrainedAbilities >= deck.m_ActiveAbilities.length + deck.m_PassiveAbilities.length) ? true : false;
    }
}