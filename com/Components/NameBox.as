//import com.GameInterface.Game.Team;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.GroupElement;
import gfx.motion.Tween; 
import mx.transitions.easing.*;

dynamic class com.Components.NameBox extends MovieClip
{
    //var m_Slot:Number;
    var m_Dynel:Dynel; // Reference to the slot.
    var m_GroupElement:GroupElement; // Reference to the slot.
    var m_NameXOrgPos:Number; // Used for placing the star and for moving the text back to org pos.
    var i_Star:MovieClip;
    private var m_UseUpperCase:Boolean;
    
    private var i_NameField:TextField;
    
    function Init()
    {
        //trace('CommonLib.NameBox:Init()')
        m_NameXOrgPos = i_NameField._x;
		i_NameField.autoSize = "left";
        m_UseUpperCase = false;
    }
    
    
    //Setting a character for this namebox (For client character and targets)
    function SetDynel(dynel:Dynel)
    {
        m_Dynel = dynel;
        _visible = (dynel != undefined) ? true : false;
		
		var sameDimension:Boolean = true;
		if (dynel != undefined)
		{
			if (m_Dynel.GetStat(_global.Enums.Stat.e_Dimension) != Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_Dimension))
			{
				sameDimension = false;
			}
		}
		
        // Set name if field exist.
        if( dynel != undefined && i_NameField )
        {
            i_NameField.text = (sameDimension ? "" : "* ") + m_Dynel.GetName();  
            if (m_UseUpperCase)
            {
                i_NameField.text = i_NameField.text.toUpperCase();
            }
			i_NameField._width = i_NameField.textWidth + 5;
            com.GameInterface.Utils.TruncateText(i_NameField);
        }
    }
    
    //Setting the group element for this namebox (For teammembers)
    function SetGroupElement(groupElement:GroupElement)
    {
        if (m_GroupElement != undefined)
        {
            m_GroupElement.SignalCharacterEnteredClient.Disconnect(SlotCharacterEntered, this);
            m_GroupElement.SignalCharacterExitedClient.Disconnect(SlotCharacterExited, this);
        }
        m_GroupElement = groupElement;
        _visible = (m_GroupElement != undefined) ? true : false;
        if (m_GroupElement == undefined)
        {
            return;
        }
		
		var sameDimension:Boolean = true;
		if (m_GroupElement != undefined)
		{
			if (m_GroupElement.m_Dimension != Character.GetClientCharacter().GetStat(_global.Enums.Stat.e_Dimension))
			{
				sameDimension = false;
			}
		}
		
        // Set name if field exist.
        if( i_NameField )
        {
            i_NameField.text = (sameDimension ? "" : "* ") + m_GroupElement.m_Name;
            if (m_UseUpperCase)
            {
                i_NameField.text = i_NameField.text.toUpperCase();
            }
			i_NameField._width = i_NameField.textWidth + 5;
            com.GameInterface.Utils.TruncateText(i_NameField);
        }
        SetOnClient(m_GroupElement.m_OnClient);
        
        m_GroupElement.SignalCharacterEnteredClient.Connect(SlotCharacterEntered, this);
        m_GroupElement.SignalCharacterExitedClient.Connect(SlotCharacterExited, this);
        
        //TeamInterface.SignalNewTeamLeader.Connect( SlotNewTeamLeader, this );
    }
    
    function SlotCharacterEntered()
    {
        SetOnClient(true);
    }
    
    function SlotCharacterExited()
    {
        SetOnClient(false);
    }

    // If the dynel is gone, but still in team, we grey out the name.
    function SetOnClient( onClient:Boolean )
    {
      // Change color if name exist.
      if( i_NameField )
      {
        i_NameField.textColor = onClient ? 0xFFFFFF : 0x999999;
      }
    }
    function SetMaxWidth(maxWidth:Number)
    {
        i_NameField.autoSize = "none";
        i_NameField._width = maxWidth;
        com.GameInterface.Utils.TruncateText(i_NameField);
    }
    
    public function UseUpperCase(useUpperCase:Boolean)
    {
        m_UseUpperCase = useUpperCase;
        
    }
}
