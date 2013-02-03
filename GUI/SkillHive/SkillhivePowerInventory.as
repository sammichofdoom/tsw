import com.Components.FeatList.MCLItemFeat;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import flash.geom.Point;
import GUI.SkillHive.CharacterSkillPointPanel;
import GUI.SkillHive.PowerInventoryHeader;
import GUI.SkillHive.PowerInventorySearch;
import gfx.controls.ScrollingList;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.SkillWheel.Cell;
import com.GameInterface.SkillWheel.Cluster;
import mx.utils.Delegate;
import com.Utils.LDBFormat;
import com.GameInterface.Game.Character;
import com.GameInterface.SpellData;
import com.GameInterface.Spell;
import com.GameInterface.Tooltip.TooltipUtils;
import gfx.core.UIComponent;
import com.GameInterface.Game.Shortcut;
import GUI.SkillHive.SkillHiveSignals;
import com.Utils.DragObject;
import GUI.HUD.AbilityBase;
import com.GameInterface.Utils;


dynamic class GUI.SkillHive.SkillhivePowerInventory extends UIComponent
{ 
    private static var HEADER_NAME = 0;
    private static var HEADER_CATEGORY = 1;
    private static var HEADER_TYPE = 2;
    private static var HEADER_SUBTYPE = 3;
    private static var HEADER_EFFECT = 4;
    private static var HEADER_COST = 5;
    
    private var m_MovieClip:MovieClip;
	
	private var m_PowerInventory_Filters:MovieClip;
	private var m_SearchResultNum:MovieClip;
	private var m_Text:TextField;
	private var m_HeaderBackground:MovieClip;
	private var m_Navigator:MovieClip;
	
	private var m_FeatList:MultiColumnListView;
        
    private var m_FilteredFeatsText:Array;
    private var m_FilteredFeats:Array;
    private var m_AvailableWeapons:Array;
    private var m_Search:PowerInventorySearch;
    
    private var m_ShouldUpdateSearch:Boolean;
    private var m_AutoUpdate:Boolean;
    private var m_CurrentSortedHeader:PowerInventoryHeader;
	
	private var m_CurrentFeatMouseDown:Number;
	private var m_CurrentFeatHitPos:Point;
    
    function SkillhivePowerInventory()
    {
		super();
		
		m_CurrentFeatMouseDown = -1;
		
        m_FilteredFeatsText = [];
        m_FilteredFeats = [];
        m_Search = new PowerInventorySearch();
        
        m_ShouldUpdateSearch = true;
        m_AutoUpdate = false;
    }
	
	function configUI()
	{
		super.configUI();
		
		m_Text.text = LDBFormat.LDBGetText("GenericGUI", "SkillHive_PowerInventory")
		
		var checkBoxSpace = 20;
		
        m_PowerInventory_Filters.m_AllCheckBox.autoSize =
        m_PowerInventory_Filters.m_PurchasedCheckBox.autoSize =
        m_PowerInventory_Filters.m_AvailableCheckBox.autoSize =
        m_PowerInventory_Filters.m_LockedCheckBox.autoSize =
        m_PowerInventory_Filters.m_BookmarkedCheckBox.autoSize = "left";
								
        m_PowerInventory_Filters.m_AllCheckBox.label = LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_SearchOption_All");
        m_PowerInventory_Filters.m_PurchasedCheckBox.label = LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_SearchOption_Purchased");
        m_PowerInventory_Filters.m_AvailableCheckBox.label = LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_SearchOption_Available");
        m_PowerInventory_Filters.m_LockedCheckBox.label = LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_SearchOption_Locked");
        m_PowerInventory_Filters.m_BookmarkedCheckBox.label = LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_SearchOption_Bookmarked");
        
        m_PowerInventory_Filters.m_PurchasedCheckBox._x = m_PowerInventory_Filters.m_AllCheckBox._x + m_PowerInventory_Filters.m_AllCheckBox._width + checkBoxSpace;
        m_PowerInventory_Filters.m_AvailableCheckBox._x = m_PowerInventory_Filters.m_PurchasedCheckBox._x + m_PowerInventory_Filters.m_PurchasedCheckBox._width + checkBoxSpace;
        m_PowerInventory_Filters.m_LockedCheckBox._x = m_PowerInventory_Filters.m_AvailableCheckBox._x + m_PowerInventory_Filters.m_AvailableCheckBox._width + checkBoxSpace;
        m_PowerInventory_Filters.m_BookmarkedCheckBox._x = m_PowerInventory_Filters.m_LockedCheckBox._x + m_PowerInventory_Filters.m_LockedCheckBox._width + checkBoxSpace;
		
        var categoryArray:Array = [ LDBFormat.LDBGetText("Gamecode", "AllCaps"), LDBFormat.LDBGetText("Gamecode", "Active"),  LDBFormat.LDBGetText("Gamecode", "Passive"),  
					LDBFormat.LDBGetText("Gamecode", "ActiveElite"),  LDBFormat.LDBGetText("Gamecode", "PassiveElite"), LDBFormat.LDBGetText("Gamecode", "ActiveAuxilliary"), 
					LDBFormat.LDBGetText("Gamecode", "PassiveAuxilliary") ];
        m_AvailableWeapons = [  _global.Enums.WeaponTypeFlag.e_WeaponType_Melee,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Ranged,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Magic,
								_global.Enums.WeaponTypeFlag.e_WeaponType_Misc,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Fist,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Club,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Sword,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_AssaultRifle,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Shotgun,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Handgun,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Jinx,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Death,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Fire,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_Launcher,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_ChainSaw,
                                _global.Enums.WeaponTypeFlag.e_WeaponType_QuantumWeapon
								];

        var weaponArray:Array = [];
        weaponArray.push(LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_SearchOption_All"));
        for (var i:Number = 0; i < m_AvailableWeapons.length; i++)
        {
            weaponArray.push(LDBFormat.LDBGetText("WeaponTypeGUI", m_AvailableWeapons[i]));
        }
        m_PowerInventory_Filters.m_CategoryDropdown.dataProvider = categoryArray;
        m_PowerInventory_Filters.m_CategoryDropdown.rowCount = categoryArray.length;
        m_PowerInventory_Filters.m_TypeDropdown.dataProvider = weaponArray;
        m_PowerInventory_Filters.m_TypeDropdown.rowCount = weaponArray.length;
		
		var textFormat:TextFormat = new TextFormat();
		textFormat.font = "_StandardFont";
		textFormat.size = 13;
		var maxWidth:Number = m_PowerInventory_Filters.m_TypeDropdown._width;
		for (var i:Number = 0; i < weaponArray.length; i++)
		{
			var weaponWidth:Number = textFormat.getTextExtent(weaponArray[i]).width;
			if (weaponWidth > maxWidth)
			{
				maxWidth = weaponWidth;
			}
		}
		
		m_PowerInventory_Filters.m_TypeDropdown.dropdownWidth = maxWidth;
        m_PowerInventory_Filters.m_CategoryDropdown.addEventListener("change", this, "SlotCategorySelected");
        m_PowerInventory_Filters.m_TypeDropdown.addEventListener("change", this, "SlotWeaponTypeSelected");
        
        m_PowerInventory_Filters.m_AllCheckBox.addEventListener("select", this, "SlotAllSelected");
        m_PowerInventory_Filters.m_PurchasedCheckBox.addEventListener("select", this, "SlotPurchasedSelected");
        m_PowerInventory_Filters.m_AvailableCheckBox.addEventListener("select", this, "SlotAvailableSelected");
        m_PowerInventory_Filters.m_LockedCheckBox.addEventListener("select", this, "SlotLockedSelected");
        
        m_PowerInventory_Filters.m_SearchBox.SetDefaultText(LDBFormat.LDBGetText("GenericGUI", "SearchText"));
        m_PowerInventory_Filters.m_SearchBox.addEventListener("search", this, "SlotSearchText");
		
        m_Navigator.m_SearchResultNext.disableFocus = true;
        m_Navigator.m_SearchResultPrev.disableFocus = true;
        
        m_Navigator.m_SearchResultPrev.addEventListener("click", this, "SlotPrevResult");
        m_Navigator.m_SearchResultNext.addEventListener("click", this, "SlotNextResult");
        m_Navigator.m_SearchResultShowing.autoSize = "center";
		
		m_PowerInventory_Filters.m_AllCheckBox.selected = true;
		
		m_FeatList.SetItemRenderer("FeatRenderer");
		m_FeatList.SetHeaderSpacing(3);
		m_FeatList.SetShowBottomLine(false);
		m_FeatList.SignalItemClicked.Connect(SlotFeatClicked, this);
		m_FeatList.SignalItemMouseDown.Connect(SlotFeatMouseDown, this);
		m_FeatList.SetLineStyle(1, 0xFFFFFF);
		
		m_FeatList.AddColumn(MCLItemFeat.FEAT_COLUMN_ICON_WITH_SYMBOL, "", 50, ColumnData.COLUMN_NON_RESIZEABLE | ColumnData.COLUMN_NOT_SORTABLE | ColumnData.COLUMN_HIDE_LABEL);
		m_FeatList.AddColumn(MCLItemFeat.FEAT_COLUMN_NAME, 		LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_Header_Name"), 	150, 0);
		m_FeatList.AddColumn(MCLItemFeat.FEAT_COLUMN_CATEGORY,	LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_Header_Category"), 80, 0);
		m_FeatList.AddColumn(MCLItemFeat.FEAT_COLUMN_TYPE,		LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_Header_Type"), 	150, 0);
		m_FeatList.AddColumn(MCLItemFeat.FEAT_COLUMN_SUBTYPE,	LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_Header_Subtype"), 	95, 0);
		m_FeatList.AddColumn(MCLItemFeat.FEAT_COLUMN_EFFECT,	LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_Header_Effect"), 	90, 0);
		m_FeatList.AddColumn(MCLItemFeat.FEAT_COLUMN_COST,		LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_Header_Cost"), 	70, ColumnData.COLUMN_NON_RESIZEABLE);
		
		m_FeatList.SetSize(m_HeaderBackground._width - 3, 700);
	}
	
	function SlotFeatMouseDown(itemIndex:Number, buttonIndex:Number)
	{
		if (buttonIndex == 1)
		{
			m_CurrentFeatMouseDown = itemIndex;
			m_CurrentFeatHitPos = new Point(_root._xmouse, _root._ymouse);
		}
	}
	
	function onMouseMove()
	{
		if (m_CurrentFeatMouseDown >= 0)
		{
			var featData:FeatData = m_FeatList.GetItems()[m_CurrentFeatMouseDown].m_FeatData
			var mousePos:Point = new Point( _root._xmouse, _root._ymouse );
			if (featData.m_Trained && Point.distance( m_CurrentFeatHitPos, mousePos ) > 10)
            {
				var dragData:DragObject = new DragObject();
                //dragData.SignalDragHandled.Connect(SlotDragHandled, this);
                if (featData.m_SpellType == _global.Enums.SpellItemType.eMagicSpell || featData.m_SpellType == _global.Enums.SpellItemType.eEliteActiveAbility  )
                {
                    dragData.type = "skillhive_active";
                    
                }
                else
                {
                    dragData.type = "skillhive_passive";                 
                }
                dragData.ability = featData.m_Spell;
                var dragClip  = AbilityBase(attachMovie( "Ability", "drag_clip", getNextHighestDepth(), { _x: _xmouse, _y: _ymouse} ));
                dragClip.SetColor( featData.m_ColorLine );
                dragClip.SetIcon( Utils.CreateResourceString(featData.m_IconID) );
                dragClip.SetSpellType( featData.m_SpellType );
				
                gfx.managers.DragManager.instance.startDrag( this, dragClip, dragData, dragData, null, false );
                gfx.managers.DragManager.instance.removeTarget = true;
				
				gfx.managers.DragManager.instance.dragOffsetY = -dragClip._width / 2;
				gfx.managers.DragManager.instance.dragOffsetX = -dragClip._width / 2;
                
                dragClip.topmostLevel = true;
                m_CurrentFeatMouseDown = -1;
			}
		}
	}
	
	function onMouseUp()
	{
		m_CurrentFeatMouseDown = -1;
	}
	
	function SlotFeatClicked(itemIndex:Number, buttonIndex:Number)
	{
		var featData:FeatData = m_FeatList.GetItems()[itemIndex].m_FeatData;
		if (featData != undefined)
		{
			if (buttonIndex == 1)
			{
				SkillHiveSignals.SignalSelectAbility.Emit(featData.m_ClusterIndex, featData.m_CellIndex, featData.m_AbilityIndex);
			}
			if (buttonIndex == 2)
			{
				if (Spell.IsPassiveSpell(featData.m_Spell))
				{
					var nextFreeSlot:Number = Spell.GetNextFreePassiveSlot();
					if (nextFreeSlot >= 0)
					{
						Spell.EquipPassiveAbility( nextFreeSlot, featData.m_Spell);
					}
				}
				else if(Spell.IsActiveSpell(featData.m_Spell))
				{
					Shortcut.AddSpell(-1 , featData.m_Spell);
				}
			}
		}
	}
	
    function UpdateVisibility(visible:Boolean)
    {
        m_FeatList._visible = visible;
    }
    
    function SetSize(width:Number, height:Number)
    {
		m_HeaderBackground._width = width - 100;
		m_Navigator._x = m_HeaderBackground._x + m_HeaderBackground._width - m_Navigator._width - 5;
        m_FeatList.SetSize(width - 100, height - 220);
		UpdateNavigator();
    }
        
    function SlotSearchText(event:Object)
    {
        m_Search.SetSearchText(event.searchText);
        UpdateSearch();
    }
    
    function UpdateFilterFromText()
    {
        m_FilteredFeatsText = [];
        
        for (var prop in FeatInterface.m_FeatList)
        {
            if (m_Search.CompareText(FeatInterface.m_FeatList[prop]))
            {
                m_FilteredFeatsText.push(FeatInterface.m_FeatList[prop]);
            }
        }
    }
    
    function UpdateSearch()
    {
        if (m_ShouldUpdateSearch)
        {
            UpdateFilterFromText();
            UpdateFilterFromControls();
            UpdateResult();
        }
    }
    
    function UpdateFilterFromControls()
    {
        m_FilteredFeats = [];
        for (var i:Number = 0; i < m_FilteredFeatsText.length; i++)
        {
            if (m_Search.CompareControls(m_FilteredFeatsText[i]))
            {
                m_FilteredFeats.push(m_FilteredFeatsText[i]);
            }
        }
    }
    
    function UpdateResult()
    {
        m_SearchResultNum.text = LDBFormat.Printf( LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_AbilitiesFound"), m_FilteredFeats.length);
        m_SearchResultNum.autoSize = "left";
		
		m_FeatList.RemoveAllItems();
		var resultArray:Array = new Array();
		
		for (var i:Number = 0; i < m_FilteredFeats.length; i++)
		{
			var featItem:MCLItemFeat = new MCLItemFeat(m_FilteredFeats[i]);
			resultArray.push(featItem);
		}
		m_FeatList.AddItems(resultArray);
		m_FeatList.SetScrollPosition(0);
		UpdateNavigator();
    }
     
	function UpdateNavigator()
	{
		if (m_FilteredFeats.length > 0)
        {
            m_Navigator.m_SearchResultShowing.text = LDBFormat.Printf( LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_AbilityRange"), (m_FeatList.GetScrollPosition() +1) + "-" + Math.min((m_FeatList.GetScrollPosition() + m_FeatList.GetRowCount()), m_FeatList.GetItems().length), m_FeatList.GetItems().length);   
        }
        else
        {
            m_Navigator.m_SearchResultShowing.text = LDBFormat.Printf( LDBFormat.LDBGetText("SkillhiveGUI", "PowerInventory_AbilityRange"), 0, 0);
        }
	}
    
    function SlotAllSelected(event:Object)
    {
        if (!m_AutoUpdate)
        {
            m_ShouldUpdateSearch = false;
            m_PowerInventory_Filters.m_PurchasedCheckBox.selected = event.selected;
            m_PowerInventory_Filters.m_AvailableCheckBox.selected = event.selected;
            m_PowerInventory_Filters.m_LockedCheckBox.selected = event.selected;
            m_ShouldUpdateSearch = true;
            UpdateSearch();
        }
        Selection.setFocus(null);
    }
    
    function SlotPurchasedSelected(event:Object)
    {
        m_Search.SetPurchased(event.selected);
        CheckUpdateAll();
        UpdateSearch();
        Selection.setFocus(null);
    }
    
    function SlotAvailableSelected(event:Object)
    {
        m_Search.SetAvailable(event.selected);
        CheckUpdateAll();
        UpdateSearch();
        Selection.setFocus(null);
    }
    
    function SlotLockedSelected(event:Object)
    {
        m_Search.SetLocked(event.selected);
        CheckUpdateAll();
        UpdateSearch();
        Selection.setFocus(null);
    }
    
    function CheckUpdateAll()
    {
        if( !m_PowerInventory_Filters.m_PurchasedCheckBox.selected
         && !m_PowerInventory_Filters.m_AvailableCheckBox.selected
         && !m_PowerInventory_Filters.m_LockedCheckBox.selected)
         {
             m_AutoUpdate = true;
             m_PowerInventory_Filters.m_AllCheckBox.selected = false;
             m_AutoUpdate = false;
         }
    }
    

    function SlotCategorySelected(event:Object)
    {
        m_Search.SetCategory(m_PowerInventory_Filters.m_CategoryDropdown.selectedIndex);
        UpdateSearch();
        
        Selection.setFocus(null);
    }

    function SlotWeaponTypeSelected(event:Object)
    {
        var type:Number = m_PowerInventory_Filters.m_TypeDropdown.selectedIndex;
        var weaponType:Number = -1;
		//As spells no longer has melee/ranged/magic flag, we do special cases for those (add flags for the respective weapons
        if (type > 3)
		{
            weaponType = m_AvailableWeapons[type-1];
		}
		else if (type > 0)
        {
			weaponType = m_AvailableWeapons[type-1]
			//Special case for melee/magic/ranged
            switch(weaponType)
			{
				case _global.Enums.WeaponTypeFlag.e_WeaponType_Melee:
					weaponType = _global.Enums.WeaponTypeFlag.e_WeaponType_Fist | _global.Enums.WeaponTypeFlag.e_WeaponType_Club | _global.Enums.WeaponTypeFlag.e_WeaponType_Sword;
					break;
				case _global.Enums.WeaponTypeFlag.e_WeaponType_Ranged:
					weaponType = _global.Enums.WeaponTypeFlag.e_WeaponType_AssaultRifle | _global.Enums.WeaponTypeFlag.e_WeaponType_Shotgun | _global.Enums.WeaponTypeFlag.e_WeaponType_Handgun;
					break;
				case _global.Enums.WeaponTypeFlag.e_WeaponType_Magic:
					weaponType = _global.Enums.WeaponTypeFlag.e_WeaponType_Jinx | _global.Enums.WeaponTypeFlag.e_WeaponType_Death | _global.Enums.WeaponTypeFlag.e_WeaponType_Fire;
					break;
				
			}
        }
		
        m_Search.SetWeaponFlag(weaponType);
        UpdateSearch();
        Selection.setFocus(null);
    }
    
    function SlotPrevResult()
    {
        m_FeatList.SetScrollPosition(Math.max(0, m_FeatList.GetScrollPosition() - m_FeatList.GetRowCount()));
		UpdateNavigator();
    }
    
    function SlotNextResult()
    {
		m_FeatList.SetScrollPosition(Math.max(0, Math.min(m_FeatList.GetItems().length - m_FeatList.GetRowCount(), m_FeatList.GetScrollPosition() + m_FeatList.GetRowCount())));
		UpdateNavigator();
    }
}
