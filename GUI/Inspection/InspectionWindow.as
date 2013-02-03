import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.LoreBase;
import com.GameInterface.Utils;
import com.Components.ItemSlot;
import com.Utils.ID32;
import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.Utils.Faction;
import mx.utils.Delegate;
import gfx.controls.Button;
import gfx.controls.ScrollingList;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;
import com.Components.WindowComponentContent;

class GUI.Inspection.InspectionWindow extends WindowComponentContent
{
    public var SignalClose:Signal;
    public var SignalUpdateHeight:Signal;
    private var m_InspectionInventory:Inventory;
    
    private var m_InspectionItemSlots:Array;
    private var m_InspectionCharacter:Character;
    
    
    private var m_CharacterInfo:MovieClip;
    
    private var m_StatInfoList:ScrollingList;
    private var m_StatsBgBox:MovieClip;
	
    private var m_ChakrasTitle:TextField;
    private var m_IconChakra_1:MovieClip;
    private var m_IconChakra_2:MovieClip;
    private var m_IconChakra_3:MovieClip;
    private var m_IconChakra_4:MovieClip;
    private var m_IconChakra_5:MovieClip;
    private var m_IconChakra_6:MovieClip;
    private var m_IconChakra_7:MovieClip;
    
    private var m_WeaponsTitle:TextField;
    private var m_IconWeapon_1:MovieClip;
    private var m_IconWeapon_2:MovieClip;
	private var m_AuxiliarlyWeaponTitle:TextField;
	private var m_IconAuxiliaryWeapon:MovieClip;
    
    private var m_ClothesTitle:TextField;
    private var m_ClothingIconHeadgear1:MovieClip;
    private var m_ClothingIconHeadgear2:MovieClip;
    private var m_ClothingIconHats:MovieClip;
    private var m_ClothingIconNeck:MovieClip;
    private var m_ClothingIconChest:MovieClip;
    private var m_ClothingIconBack:MovieClip;
    private var m_ClothingIconHands:MovieClip;
    private var m_ClothingIconLeg:MovieClip;
    private var m_ClothingIconFeet:MovieClip;
    private var m_ClothingIconMultislot:MovieClip;
    
    private var m_PreviewAllButton:Button;
    
    private var m_StatInfoListData:Array;
	
	//public var m_ContentHeight:Number;
    
    //private var m_ClotingSlotPositions:Array;
    //private var m_ClothingLabels:Array;
    
    private var m_Initialized:Boolean;
    
    function InspectionWindow()
    {
        super();
        m_Initialized = false;
        SignalClose = new Signal();
        SignalUpdateHeight = new Signal();
        m_InspectionItemSlots = [];
        
        //m_ClothingLabels = [];
        
        //m_Background.onPress = Delegate.create(this, SlotStartDragWindow);
        //m_Background.onMouseUp = Delegate.create(this, SlotStopDragWindow);
        
        /*m_ClotingSlotPositions = [  _global.Enums.ItemEquipLocation.e_Wear_Feet,
                                    _global.Enums.ItemEquipLocation.e_Wear_Legs,
                                    _global.Enums.ItemEquipLocation.e_Wear_Chest,
                                    _global.Enums.ItemEquipLocation.e_Wear_Back,
                                    _global.Enums.ItemEquipLocation.e_Wear_Hands,
                                    _global.Enums.ItemEquipLocation.e_Wear_Neck,
                                    _global.Enums.ItemEquipLocation.e_Wear_Hat,
                                    _global.Enums.ItemEquipLocation.e_Wear_Face,
                                    _global.Enums.ItemEquipLocation.e_Necklace,
                                    _global.Enums.ItemEquipLocation.e_Wear_FullOutfit ]; */       
    }
    
    function configUI()
    {
		super.configUI();
        m_Initialized = true;
        
        SetLabels();
        
        m_PreviewAllButton.addEventListener("click", this, "PreviewAll");
        
        if (m_InspectionCharacter != undefined)
        {
            UpdateData();
        }
		
    }
    
    private function SetLabels()
    {
        m_WeaponsTitle.text = LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Weapons");
        m_AuxiliarlyWeaponTitle.text = LDBFormat.LDBGetText("GenericGUI", "Auxilliary");
        m_ChakrasTitle.text = LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Talismans");
        m_ClothesTitle.text = LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Clothes");
        m_PreviewAllButton.label = LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_PreviewAll");        
    }
    
    private function Close()
    {
        SignalClose.Emit( m_InspectionCharacter.GetID() );
    }
    
    public function SetCharacter(characterID:ID32)
    {
        m_InspectionCharacter = Character.GetCharacter(characterID);
        if (m_InspectionCharacter != undefined)
        {
            m_InspectionInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, characterID.GetInstance()));
            
            InitializeChakras();
            InitializeWeapons();
            InitializeClothes();
        }
    }
    
    private function PreviewAll()
    {
        var previewOK:Boolean = m_InspectionInventory.PreviewCharacter(m_InspectionCharacter.GetID());
        m_PreviewAllButton.disabled = !previewOK;
    }
    
    private function UpdateData()
    {
        m_StatInfoListData = [
                                { m_LabelText: LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Faction"), m_DataText: Faction.GetName(m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction )) },
                                { m_LabelText: LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_FactionRank"), m_DataText: LoreBase.GetTagName(m_InspectionCharacter.GetStat( _global.Enums.Stat.e_RankTag )) }
                            ];
        
        if (m_InspectionCharacter.GetGuildName().length != 0)
        {
            m_StatInfoListData.push( { m_LabelText: LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Cabal"), m_DataText: m_InspectionCharacter.GetGuildName() } );
        }
		
		if (m_InspectionCharacter.GetDimensionName().length != 0)
        {
            m_StatInfoListData.push( { m_LabelText: LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_Dimension"), m_DataText: m_InspectionCharacter.GetDimensionName() } );
        }
		
        //Get Faction Icon
        if ( m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction ) == _global.Enums.Factions.e_FactionIlluminati )
        {
            m_CharacterInfo.m_FactionIconLoader.attachMovie( "LogoIlluminati", "inspectedplayerFactionLogo", m_CharacterInfo.m_FactionIconLoader.getNextHighestDepth() );
        }
        else if ( m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction ) == _global.Enums.Factions.e_FactionTemplar )
        {
            m_CharacterInfo.m_FactionIconLoader.attachMovie( "LogoTemplar", "inspectedplayerFactionLogo", m_CharacterInfo.m_FactionIconLoader.getNextHighestDepth() )
        }
        else if ( m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction ) == _global.Enums.Factions.e_FactionDragon )
        {
            m_CharacterInfo.m_FactionIconLoader.attachMovie( "LogoDragon", "inspectedplayerFactionLogo", m_CharacterInfo.m_FactionIconLoader.getNextHighestDepth() )
        }
        
        //Get Character Name
        var name:String = m_InspectionCharacter.GetFirstName();
        var nickName = m_InspectionCharacter.GetName();
        if (nickName.length != 0)
        {
            if (name.length != 0) { name += " "; }
            name += "\"" + nickName + "\"";
        }
        var lastName = m_InspectionCharacter.GetLastName();
        if (lastName.length != 0)
        {
            if (name.length != 0) { name += " "; }
            name += lastName;
        }
        m_CharacterInfo.m_Name.htmlText = name;
        
        //Get Character basic info
        m_CharacterInfo.m_BasicInfo.htmlText = m_InspectionCharacter.GetTitle();
        
        // Get Character info/stat (scrollingList)
        m_StatInfoList.dataProvider = m_StatInfoListData;
        
		for (var i:Number = 0; i < m_InspectionInventory.GetMaxItems(); i++)
		{
			if (m_InspectionInventory.GetItemAt(i) != undefined )
            {
                if (m_InspectionItemSlots[i] != undefined)
                {
                    m_InspectionItemSlots[i].SetData(m_InspectionInventory.GetItemAt(i));
                }
            }
		}
		UpdateLayout();
    }
    
    private function InitializeChakras()
    {
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_7, m_IconChakra_7);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_6, m_IconChakra_6);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_5, m_IconChakra_5);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_4, m_IconChakra_4);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_3, m_IconChakra_3);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_2, m_IconChakra_2);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Chakra_1, m_IconChakra_1);
    }
    
    private function InitializeWeapons()
    {
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot, m_IconWeapon_1);
        InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot, m_IconWeapon_2);
		InitializeSlot(_global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot, m_IconAuxiliaryWeapon);
    }
    
    private function InitializeSlot(itemPos:Number, icon:MovieClip):Void
    {
        m_InspectionItemSlots[ itemPos ] = new ItemSlot(m_InspectionInventory.m_InventoryID, itemPos, icon);
    }    
	
    private function InitializeClothes()
    {
        m_ClothingIconHeadgear1._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face) != undefined ? 100 : 30;
        m_ClothingIconHeadgear2._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Necklace) != undefined ? 100 : 30;
        m_ClothingIconHats._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat) != undefined ? 100 : 30;
        m_ClothingIconNeck._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck) != undefined ? 100 : 30;
        m_ClothingIconChest._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest) != undefined ? 100 : 30;
        m_ClothingIconBack._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back) != undefined ? 100 : 30;
        m_ClothingIconHands._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands) != undefined ? 100 : 30;
        m_ClothingIconLeg._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs) != undefined ? 100 : 30;
        m_ClothingIconFeet._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet) != undefined ? 100 : 30;
        m_ClothingIconMultislot._alpha = m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit) != undefined ? 100 : 30;
        
        var tooltipWidth:Number = 100;
        var tooltipOrientation = TooltipInterface.e_OrientationVertical;
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconHeadgear1, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Face).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Necklace) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconHeadgear2, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Necklace).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconHats, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hat).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconNeck, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Neck).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconChest, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Chest).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconBack, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Back).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconHands, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Hands).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconLeg, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Legs).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconFeet, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Feet).m_Name , tooltipWidth, tooltipOrientation, false);
        }
        if (m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit) != undefined)
        {
            TooltipUtils.AddTextTooltip(m_ClothingIconMultislot, m_InspectionInventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_FullOutfit).m_Name , tooltipWidth, tooltipOrientation, false);
        }
    }
    
	public function UpdateLayout()
	{
		var paddingSpace:Number = 6;
		
		m_CharacterInfo.m_BasicInfo._y = m_CharacterInfo.m_Name._y + m_CharacterInfo.m_Name.textHeight;
		
		m_StatsBgBox._height = (m_StatInfoListData.length * 38) + (paddingSpace * 2);
		
		m_WeaponsTitle._y = m_AuxiliarlyWeaponTitle._y = m_StatsBgBox._y + m_StatsBgBox._height + paddingSpace;
		m_IconWeapon_1._y = m_IconWeapon_2._y = m_IconAuxiliaryWeapon._y = m_WeaponsTitle._y + m_WeaponsTitle._height;
		
		m_ChakrasTitle._y = m_IconWeapon_1._y + m_IconWeapon_1._height + paddingSpace;
		m_IconChakra_7._y =
		m_IconChakra_6._y =
		m_IconChakra_5._y =
		m_IconChakra_4._y =
		m_IconChakra_3._y =
		m_IconChakra_2._y =
		m_IconChakra_1._y = m_ChakrasTitle._y + m_ChakrasTitle._height;
		
		m_ClothesTitle._y = m_IconChakra_1._y + m_IconChakra_1._height + paddingSpace;
		m_ClothingIconHeadgear1._y =
		m_ClothingIconHeadgear2._y =
		m_ClothingIconHats._y =
		m_ClothingIconNeck._y =
		m_ClothingIconChest._y =
		m_ClothingIconBack._y =
		m_ClothingIconHands._y =
		m_ClothingIconLeg._y =
		m_ClothingIconFeet._y =
		m_ClothingIconMultislot._y = m_ClothesTitle._y + m_ClothesTitle._height;
		
		m_PreviewAllButton._y = m_ClothingIconMultislot._y + m_ClothingIconMultislot._height + (paddingSpace * 3);
		
		SignalSizeChanged.Emit();
	}
	
    private function SlotStartDragWindow()
    {
        this.startDrag();
    }
    
    private function SlotStopDragWindow()
    {
        this.stopDrag();
    }
    
    /*private function IsClothingSlot(position:Number)
    {
        for (var i:Number = 0; i < m_ClotingSlotPositions.length; i++)
        {
            if (m_ClotingSlotPositions[i] == position)
            {
                return true;
            }
        }
        return false;
    }*/
}