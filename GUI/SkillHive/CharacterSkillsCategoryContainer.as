//Imports
import com.GameInterface.CharacterPointData;
import com.Utils.Signal;
import com.GameInterface.ProjectFeatInterface;
import com.Utils.LDBFormat;
import mx.utils.Delegate;

//Class 
class GUI.SkillHive.CharacterSkillsCategoryContainer extends MovieClip
{
    //Properties
    private var m_InvisibleButton:MovieClip;
    private var m_Label:TextField;
    private var m_Category:String;
    private var m_Skills:Array;
    private var m_NumAnimating:Number;
    private var m_InitialHeight:Number;
    
    public var SignalStartAnimation:Signal;
    public var SignalStopAnimation:Signal;
    
    //Constructor
    public function CharacterSkillsCategoryContainer()
    {
        super();
        
        m_Skills = new Array();
        
        m_NumAnimating = 0;
        m_InitialHeight = _height;
        
        m_InvisibleButton.onRelease = Delegate.create(this, InvisibleButtonClickHandler);
        
        SignalStartAnimation = new Signal();
        SignalStopAnimation = new Signal();
    }
    
    //On Load
    public function onLoad():Void
    {
        
    }

    //On Enter Frame
    public function onEnterFrame():Void
    {
        if (m_NumAnimating > 0)
        {
            var newY:Number = m_InitialHeight;
            
            for (var i:Number = 0; i < m_Skills.length; i++)
            {
                m_Skills[i]._y = newY;
                newY += m_Skills[i].GetBackgroundHeight();
            }
        }
    }
    
    //Add Skills
    public function AddSkills(skills:Array):Void
    {
        for (var i:Number = 0; i < skills.length; i++)
        {
            var itemContainer = attachMovie("CharacterSkillsItemContainer", "m_SkillsContainer_" + super.UID(), getNextHighestDepth())
            itemContainer._y = _height;
            itemContainer.SignalStartAnimation.Connect(SlotStartAnimation, this);
            itemContainer.SignalStopAnimation.Connect(SlotStopAnimation, this);
            itemContainer.m_Index = i;
            itemContainer.SetCategory(m_Category);
            
            itemContainer.onLoad = function()
            {
                var itemData:CharacterPointData = new CharacterPointData;
                itemData.m_Name = LDBFormat.LDBGetText("CharacterSkillsGUI", skills[this.m_Index]).toUpperCase();
                itemData.m_Id = skills[this.m_Index];
                itemData.m_Level = ProjectFeatInterface.GetHighestLearnedSkillLevel(skills[this.m_Index]);
                
                this.SetData(itemData);
            }

            m_Skills.push(itemContainer);
        }
    }
    
    //Invisible Button Click Handler
    private function InvisibleButtonClickHandler():Void
    {
        
    /*
     *  If all skills within the CharacterSkillsItemContainer are either collapsed or expanded they will all animate to
     *  their opposite.  However, if one or more are already expanded the remaining that are collapsed will also expand.
     * 
     */
        
        var collapsedArray:Array = new Array();
        var expandedArray:Array = new Array();
        
        for (var i:Number = 0; i < m_Skills.length; i++)
        {
            if (m_Skills[i].m_IsCollapsed)
            {
                collapsedArray.push(m_Skills[i]);
            }
            else
            {
                expandedArray.push(m_Skills[i]);
            }
        }
        
        if (collapsedArray.length == 0 || expandedArray.length == 0)
        {
            for (i = 0; i < m_Skills.length; i++)
            {
                m_Skills[i].BackgroundClickHandler();
            }
        }
        else
        {
            for (i = 0; i < collapsedArray.length; i++)
            {
                collapsedArray[i].BackgroundClickHandler();
            }
        }
    }
	
    //Get Background Height
    public function GetBackgroundHeight():Number
    {
        var totalHeight:Number = 0;
        
        for (var i:Number = 0; i < m_Skills.length; i++)
        {
            totalHeight += m_Skills[i].GetBackgroundHeight();
        }
        
        return totalHeight + m_InitialHeight;
    }
    
    //Slot Start Function
    public function SlotStartAnimation():Void
    {
        if (m_NumAnimating == 0)
        {
            SignalStartAnimation.Emit();
        }
        
        m_NumAnimating++;
    }
    
    //Slot Stop Function
    public function SlotStopAnimation():Void
    {
        m_NumAnimating--;
        
        if (m_NumAnimating == 0)
        {
            SignalStopAnimation.Emit();
        }
    }
	
    //Update Character Skill Points
	public function UpdateCharacterSkillPoints(newAmount:Number):Void
	{
        for (var i:Number = 0; i < m_Skills.length; i++)
        {
            m_Skills[i].UpdateCharacterSkillPoints(newAmount);
        }
	}
    
    //Set Label
    public function SetLabel(value:String):Void
    {
        m_Label.text = value.toUpperCase();
        m_Category = value;
        
        m_InvisibleButton._x = m_Label._x;
        m_InvisibleButton._y = m_Label._y;
        m_InvisibleButton._height = m_Label._height;
        m_InvisibleButton._width = m_Label.textWidth + 5;
    }
}