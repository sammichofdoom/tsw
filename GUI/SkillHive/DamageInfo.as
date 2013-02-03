
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import com.Utils.Colors;
import mx.transitions.easing.*;
/**
 * Draws a square around the stage when damage is inflicted on character and animates it out
 */
class GUI.SkillHive.DamageInfo
{
    private var m_DrawClip:MovieClip;
    private var m_PrevHealth:Number = 0;
    private var m_CharacterId:ID32; 
    
    public function DamageInfo(ref:MovieClip)
    {
        m_DrawClip = ref.createEmptyMovieClip("i_DamageInfo", ref.getNextHighestDepth());
    }
    
    /**
     * Sets the caharacter to current client cjharacter and assigns the ID membervariable
     * @param	character:Character - the player
     */
    public function SetCharacter( character:Character ) : Void
    {
        com.Utils.GlobalSignal.SignalDamageNumberInfo.Connect( SlotDamageInfo, this );
        m_CharacterId = character.GetID();
    }
    
    /**
     * Fires when a character takes damage
     */
    private function SlotDamageInfo( statID:Number,damage:Number,absorb:Number, attackResultType:Number, attackType:Number,  attackOffensiveLevel:Number, attackDefensiveLevel:Number, context:Number, targetID:ID32, iconID:ID32, iconColorLine:Number )
    {
          if (targetID.Equal( m_CharacterId))
        {
            // Only show if damage.
            switch( Number( attackResultType ) )
            {
                case _global.Enums.AttackResultType.e_AttackType_Hit:
                case _global.Enums.AttackResultType.e_AttackType_CriticalHit:
                    
                    DrawAttackFrame();
                    
                break;
            }
        }
    }
    
    /**
     * Draws an attack frame if there is noone active at the moment
     */
    private function DrawAttackFrame() : Void
    {
        if (m_DrawClip["isActive"])
        {
            return;
        }
        m_DrawClip._xscale = 100;
        m_DrawClip._xscale = 100;
        m_DrawClip._y = 0;
        m_DrawClip._x = 0;
        m_DrawClip._alpha = 100;
        
        var indents:Array = [0, 5, 10]; // the lines that constitutes the attack frame
        
        var visibleRect:Object = Stage["visibleRect"];
        
        var w:Number = visibleRect.width;
        var h:Number = visibleRect.height;
        
        for (var i:Number = 0; i < indents.length; i++ )
        {
            var indent:Number = indents[i];
            m_DrawClip.lineStyle(6-(i*2), Colors.e_ColorDamage);
            m_DrawClip.moveTo(indent, indent);
            m_DrawClip.lineTo(w-(indent*2), indent);
            m_DrawClip.lineTo(w-(indent*2), h-(indent*2));
            m_DrawClip.lineTo(indent, h-(indent*2));
            m_DrawClip.lineTo(indent, indent);
        }
        m_DrawClip["isActive"] = true
        m_DrawClip.tweenTo(0.7, { _height: h - 20, _width:w - 20, _y:10, _x:10, _alpha:0 }, None.easeNone);
        m_DrawClip.onTweenComplete = function()
        {
            this.clear();
            this["isActive"] = false;
        }
    }
}