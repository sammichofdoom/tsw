import com.Utils.Signal;
import com.GameInterface.LoreNode;
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;

import com.GameInterface.ACGItem;
import com.GameInterface.Tooltip.*;

class com.GameInterface.Lore extends com.GameInterface.LoreBase
{
	private static var s_LoreCache:Object = new Object();
	private static var s_FilteredLoreCache:Object = new Object();
	
	private static function GetCachedNode(node:LoreNode, factionFilter:Boolean)
	{
		if (factionFilter)
		{
			if (s_FilteredLoreCache.hasOwnProperty(node.m_Id.toString()))
			{
				return s_FilteredLoreCache[node.m_Id.toString()];
			}
			else
			{
				RecursiveLoadNode(node, factionFilter);
				s_FilteredLoreCache[node.m_Id.toString()] = node;
				return node;
			}
		}
		else
		{
			if (s_LoreCache.hasOwnProperty(node.m_Id.toString()))
			{
				return s_LoreCache[node.m_Id.toString()];
			}
			else
			{
				RecursiveLoadNode(node, factionFilter);
				s_LoreCache[node.m_Id.toString()] = node;
				return node;
			}
		}
	}
	
	public static function ClearCache() : Void
	{
		s_LoreCache = new Object();
		s_FilteredLoreCache = new Object();
	}
	
	public static function GetLoreTree() : LoreNode
	{
        var rootNode:LoreNode = new LoreNode();
        rootNode.m_Id = GetHeaderNodeId(_global.Enums.LoreNodeType.e_HeaderLore);
		return GetCachedNode(rootNode, false);
	}

	public static function GetAchievementTree(factionFilter:Boolean) : LoreNode
	{
		if (factionFilter == undefined)
		{
			factionFilter = true;
		}
		
        var rootNode:LoreNode = new LoreNode();
        rootNode.m_Id = GetHeaderNodeId(_global.Enums.LoreNodeType.e_HeaderAchievement);
		return GetCachedNode(rootNode, factionFilter);
	}

	public static function GetTitleTree(factionFilter:Boolean) : LoreNode
	{
		if (factionFilter == undefined)
		{
			factionFilter = false;
		}
        var rootNode:LoreNode = new LoreNode();
        rootNode.m_Id = GetHeaderNodeId(_global.Enums.LoreNodeType.e_HeaderTitle);
		return GetCachedNode(rootNode, factionFilter);
	}

	public static function GetTutorialTree() : LoreNode
	{
        var rootNode:LoreNode = new LoreNode();
        rootNode.m_Id = GetHeaderNodeId(_global.Enums.LoreNodeType.e_HeaderTutorial);
		return GetCachedNode(rootNode, false);
	}

	public static function RecursiveLoadNode(node:LoreNode, factionFilter:Boolean) : Void
	{
		if (node == undefined || node.m_Id == undefined)
		{
			return;
		}
		if (factionFilter == undefined)
		{
			factionFilter = true;
		}

        node.m_Type = GetTagType(node.m_Id);
		node.m_Locked = IsLocked(node.m_Id);
        node.m_Icon = GetIcon(node.m_Id);
        node.m_IsNew = IsNew(node.m_Id);

        if (node.m_Icon == 0 && node.m_Parent != undefined)
        {
            node.m_Icon = node.m_Parent.m_Icon;
        }
		
        var childArray:Array = GetTagChildrenIdArray(node.m_Id, 0);
        
		if (node.m_Type != _global.Enums.LoreNodeType.e_Lore || childArray.length != 0)
		{
			node.m_Name = GetTagName(node.m_Id);
		}

		if (node.m_Type == _global.Enums.LoreNodeType.e_Achievement ||
            node.m_Type == _global.Enums.LoreNodeType.e_Tutorial ||
		   (node.m_Type == _global.Enums.LoreNodeType.e_Lore && childArray.length == 0))
		{
			node.m_HasCount = (node.m_Locked ? 0 : 1);
			node.m_TargetCount = 1;
		}
		else
		{
			node.m_HasCount = 0;
			node.m_TargetCount = 0;
		}

		node.m_Children = new Array();
		for (var i:Number = 0; i<childArray.length; i++)
		{
			if (factionFilter && !HasPlayerFaction(childArray[i]))
			{
				continue;
			}
			var childNode:LoreNode = new LoreNode();
			childNode.m_Id = childArray[i];
			childNode.m_Parent = node;
			RecursiveLoadNode(childNode, factionFilter);
            node.m_IsNew = Boolean( node.m_IsNew | childNode.m_IsNew ); 
			node.m_HasCount += childNode.m_HasCount;
			node.m_TargetCount += childNode.m_TargetCount;
			node.m_Children.push(childNode);
		}
        
        node.m_IsInProgress = ((node.m_HasCount > 0 &&
                                node.m_HasCount < node.m_TargetCount) ||
                               (HasCounter(node.m_Id) &&
                                GetCounterCurrentValue(node.m_Id) > 0 &&
                                GetCounterCurrentValue(node.m_Id) < GetCounterTargetValue(node.m_Id)));
	}
    
    public static function GetTitleArray() : Array
    {
        var array:Array = new Array();
        RecursiveFillTitleArray(GetTitleTree(), array);
        array.sortOn("label");
        var nullTitle:String = LDBFormat.LDBGetText("MiscGUI", "NullTitle");
        array.unshift( { label:nullTitle, id:0 } );
        return array;
    }
    private static function RecursiveFillTitleArray(node:LoreNode, array:Array)
    {
        if (node.m_Children.length == 0)
        {
            if (!IsLocked(node.m_Id) && (node.m_Type == _global.Enums.LoreNodeType.e_Title || node.m_Type == _global.Enums.LoreNodeType.e_FactionTitle))
            {
                array.push( { label:node.m_Name, id:node.m_Id } );
            }
        }
        else
        {
            for (var i:Number = 0; i < node.m_Children.length; i++)
            {
                RecursiveFillTitleArray(node.m_Children[i], array);
            }
        }
    }
    
    public static function GetFactionRankArray(factionFilter:Boolean) : Array
    {
        var array:Array = new Array();
        RecursiveFillFactionTitleArray(GetTitleTree(factionFilter), array);
        return array;
    }
    private static function RecursiveFillFactionTitleArray(node:LoreNode, array:Array)
    {
        if (node.m_Children.length == 0)
        {
            if (node.m_Type == _global.Enums.LoreNodeType.e_FactionTitle)
            {
                array.push( { label:node.m_Name, id:node.m_Id } );
            }
        }
        else
        {
            for (var i:Number = 0; i < node.m_Children.length; i++)
            {
                RecursiveFillFactionTitleArray(node.m_Children[i], array);
            }
        }
    }
    
    /// @param node:LoreNode - the node to inspect
    /// @return Boolean, is it a leaf node or not
    public static function IsLeafNode(node:LoreNode) : Boolean
    {
        if (node.m_Children.length == 0 ||
            GetTagType(node.m_Id) == _global.Enums.LoreNodeType.e_Tutorial ||
            GetTagType(node.m_Id) == _global.Enums.LoreNodeType.e_TutorialTip ||
            GetTagType(node.m_Id) == _global.Enums.LoreNodeType.e_Title ||
            GetTagType(node.m_Id) == _global.Enums.LoreNodeType.e_FactionTitle ||
            GetTagType(node.m_Id) == _global.Enums.LoreNodeType.e_Achievement ||
            GetTagType(node.m_Id) == _global.Enums.LoreNodeType.e_SubAchievement)
        {
            return true;
        }
        
        return false;
    }
    public static function GetFirstNonLeafNode(node:LoreNode) : LoreNode
    {
        while (Lore.IsLeafNode(node))
        {
            node = node.m_Parent;
        }
        return node;
    }
    
    /// iterates the LoreNode Object and its children returning the 
    /// LoreNode specified by ID
    /// @param id:Number - the id of the object to look for
    /// @param data:Array - the list of objects and children to search
    public static function GetDataNodeById(id:Number) : LoreNode
    {
        var data:LoreNode;
        var category:Number = GetTagCategory(id);
        if (category == _global.Enums.LoreNodeType.e_Achievement)
        {
            data = GetAchievementTree();
        }
        else if (category == _global.Enums.LoreNodeType.e_Lore)
        {
            data = GetLoreTree();
        }
        else if (category == _global.Enums.LoreNodeType.e_Tutorial)
        {
            data = GetTutorialTree();
        }
        else if (category == _global.Enums.LoreNodeType.e_Title || category == _global.Enums.LoreNodeType.e_FactionTitle)
        {
            data = GetTitleTree();
        }
        
        return RecursiveFindNode(id, data);
    }
    
    private static function RecursiveFindNode(id:Number, haystack:LoreNode) : LoreNode
    {
        if (id == haystack.m_Id)
        {
            return haystack;
        }
        for (var i:Number = 0; i < haystack.m_Children.length; i++ )
        {
            var needle:LoreNode = RecursiveFindNode(id, haystack.m_Children[i]);
            if (needle != null)
            {
                return needle;
            }
        }
        return null;
    }
    
    public static function GetTagCategory(tagId:Number) : Number
    {
        var loreNodeType:Number = GetTagType(tagId);
        switch(loreNodeType)
        {
            case _global.Enums.LoreNodeType.e_Achievement:
            case _global.Enums.LoreNodeType.e_AchievementCategory:
            case _global.Enums.LoreNodeType.e_SubAchievement:
            case _global.Enums.LoreNodeType.e_HeaderAchievement:
                return _global.Enums.LoreNodeType.e_Achievement;
            case _global.Enums.LoreNodeType.e_Tutorial:
            case _global.Enums.LoreNodeType.e_TutorialCategory:
            case _global.Enums.LoreNodeType.e_TutorialTip:
            case _global.Enums.LoreNodeType.e_HeaderTutorial:
                return _global.Enums.LoreNodeType.e_Tutorial;
            case _global.Enums.LoreNodeType.e_Lore:
            case _global.Enums.LoreNodeType.e_HeaderLore:
                return _global.Enums.LoreNodeType.e_Lore;
            case _global.Enums.LoreNodeType.e_Title:
            case _global.Enums.LoreNodeType.e_FactionTitle:
            case _global.Enums.LoreNodeType.e_HeaderTitle:
                return _global.Enums.LoreNodeType.e_Title;
        }
        return -1
    }
    
    public static function GetRewardItemNameArray(id:Number) : Array
    {
        var rewardNameArray:Array = new Array();
        
        var rewardIdArray:Array = GetRewardIdArray(id, _global.Enums.LoreRewardType.e_Item);
        for (var i:Number = 0; i < rewardIdArray.length; i++)
        {
            var item = new ACGItem();
            item.m_TemplateID0 = rewardIdArray[i];
            item.m_TemplateID1 = 0;
            item.m_TemplateID2 = 0;
            item.m_Level = -1;
            item.m_DecryptionKey0 = [ 0 ];
            item.m_DecryptionKey1 = [ 0 ];
            item.m_DecryptionKey2 = [ 0 ];
            var tooltipData:TooltipData = TooltipDataProvider.GetACGItemTooltip(item);
            
            rewardNameArray.push( tooltipData.m_Title );
        }
        
        return rewardNameArray;
    }
    
    public static function GetDepth(id:Number) : Number
    {
        var node:LoreNode = GetDataNodeById(id);
        var depth:Number = 0;
        while (node.m_Parent != undefined)
        {
            node = node.m_Parent;
            depth++;
        }
        return depth;
    }
    
    public static function ShouldShowGetAnimation(tagId:Number) : Boolean
    {
        if (IsValidId(tagId))
        {
            var loreNodeType:Number = GetTagType(tagId);
            switch(loreNodeType)
            {
                case _global.Enums.LoreNodeType.e_Achievement:
                case _global.Enums.LoreNodeType.e_SubAchievement:
                case _global.Enums.LoreNodeType.e_Lore:
                    // achievements and lore should be shown if the tag is visible (with inherited invisibility)
                    // we check this by seeing if GUI can find the tag at all (we don't see invisible tags)
                    return (Lore.GetDataNodeById(tagId) != null);
                    
                case _global.Enums.LoreNodeType.e_Tutorial:
                case _global.Enums.LoreNodeType.e_TutorialTip:
                    // tips and tutorials should only show up if the user wants them
                    return DistributedValue.GetDValue("ShowTutorialPopups", true);
                    return true;
                    
                case _global.Enums.LoreNodeType.e_Title:
                    // TITLE!  ..we have no get effects for these (yet?)
                    return false;
                case _global.Enums.LoreNodeType.e_FactionTitle:
                    /// faction ranks
                    return true;
            }
        }
        return false;
    }
	
	public static function GetCurrentFactionRankNode() : LoreNode
	{
		var currentTag:LoreNode = undefined;
        var factionRankArray:Array = GetFactionRankArray(true);
		
        for (var i:Number = 0; i < factionRankArray.length; i++)
        {
            var node:LoreNode = GetDataNodeById(factionRankArray[i].id);
            if (!node.m_Locked)
            {
                // we have this tag. let's assume it's our highest rank until we find a higher one
                currentTag = node;
            }
            else if (currentTag != undefined)
            {   
				// we don't have this tag, but we did find one we have. this must be the next one
                break;
            }
        }
		return currentTag;
	}
	
	public static function GetNextFactionRankNode() : LoreNode
	{
		var currentTag:LoreNode = undefined;
        var nextTag:LoreNode = undefined;
        var factionRankArray:Array = GetFactionRankArray(true);
		
        for (var i:Number = 0; i < factionRankArray.length; i++)
        {
            var node:LoreNode = GetDataNodeById(factionRankArray[i].id);
            if (!node.m_Locked)
            {
                // we have this tag. let's assume it's our highest rank until we find a higher one
                currentTag = node;
            }
            else if (currentTag != undefined)
            {
                // we don't have this tag, but we did find one we have. this must be the next one
                nextTag = node;
                break;
            }
        }
		return nextTag;
	}
}
