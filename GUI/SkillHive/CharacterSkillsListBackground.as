//Imports
import com.Utils.Colors;

//Class
class GUI.SkillHive.CharacterSkillsListBackground extends MovieClip
{
    //Constants
    private var LINE_COLOR:Number = 0x4E4E4E;
    
    //Properties
    private var m_VerticalLines:MovieClip;
    private var m_VerticalLinesArray:Array;
    
    //Constructor
    public function CharacterSkillsListBackground()
    {
        super();
        
        m_VerticalLinesArray = new Array();
        m_VerticalLinesArray.push(
                                    m_VerticalLines.m_Line1,
                                    m_VerticalLines.m_Line2,
                                    m_VerticalLines.m_Line3,
                                    m_VerticalLines.m_Line4,
                                    m_VerticalLines.m_Line5,
                                    m_VerticalLines.m_Line6,
                                    m_VerticalLines.m_Line7,
                                    m_VerticalLines.m_Line8,
                                    m_VerticalLines.m_Line9,
                                    m_VerticalLines.m_Line10
                                );
                                
        for (var i:Number = 0; i < m_VerticalLinesArray.length; i++)
        {
            Colors.ApplyColor(m_VerticalLinesArray[i], LINE_COLOR);
        }
    }
}