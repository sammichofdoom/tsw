import flash.geom.Point;
import gfx.controls.Label;
import mx.utils.Delegate;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;
import GUI.Tooltip.TooltipEntry;

class GUI.Tooltip.TooltipPanel
{
    private var m_Width:Number;
	private var m_Padding:Number;
    
    private var m_ShowIcon:Boolean;
    private var m_CompareMode:Boolean;
    private var m_CenterHeader:Boolean;
    private var m_CurrentlyEquipped:Boolean;
    
    private var m_TooltipEntries:Array;
    
    public var SignalSizeChanged:com.Utils.Signal;
	private var m_ResolutionScaleMonitor:DistributedValue;
	

    public var m_Clip:MovieClip;
    private var m_IconView:MovieClip;
    private var m_WeaponIconView:MovieClip;
    
    private var m_ContentSize:Point;
    
    
    public function TooltipPanel( parentClip:MovieClip, tooltipData:TooltipData, compareMode:Boolean )
    {
        SignalSizeChanged = new com.Utils.Signal;
        
		m_CurrentlyEquipped = false;
		
        m_TooltipEntries = new Array();        
        m_Width = 280;
		if (tooltipData.m_MaxWidth != undefined && tooltipData.m_MaxWidth > 0)
        {
            m_Width = tooltipData.m_MaxWidth;
        }
        m_Padding = 5;
        if (tooltipData.m_Padding != undefined)
        {
		    m_Padding = tooltipData.m_Padding;
        }
		
        //Create the main clip
        m_Clip = parentClip.attachMovie( "ToolTip", "", parentClip.getNextHighestDepth() );
        
        m_ContentSize = new Point();
	    
        //Initialize variables based on tooltipdata
        m_Clip.m_CloseButton._visible = false;
        m_ShowIcon = false;
        m_CompareMode  = compareMode;
        m_CenterHeader = tooltipData.m_CenterHeader;
		        
        //Show Stripes behind passive abilities
	    m_Clip.m_Stripes._visible = false;	
        if ( tooltipData.m_SpellType  == _global.Enums.SpellItemType.ePassiveAbility || tooltipData.m_SpellType  == _global.Enums.SpellItemType.eElitePassiveAbility )
        {
            m_Clip.m_Stripes._visible = true;
            m_Clip.m_Stripes._alpha = 70;
        }
        else 
        {
            m_Clip.m_Stripes._visible = false;
        }
        
		if ( tooltipData.m_IsEquipped &&  m_CompareMode == true )
		{
			m_CurrentlyEquipped = true;
            AddPadding( -7 );
            var equipped:String = "<font size='10' color='#b19f79'><localized category= ItemInforelatedtext token=CurrentlyEquipped></font>"
			AddTextField(equipped, false );
			AddPadding( 5 );
			AddDivider();
			AddPadding( 5 );
		}
		
		if ( tooltipData.m_Header != undefined )
		{
            var header:String = "<font size='16' color='#FFFFFF'>" + tooltipData.m_Header + "</font>"
			AddTextField(header, false );
            if (m_CenterHeader)
            {
                m_TooltipEntries[m_TooltipEntries.length - 1].m_ContentLeft.autoSize = "center";
            }
            AddPadding( -5 );
		}
		var titleIndex:Number = -1;
		if ( tooltipData.m_Title != undefined )
		{
			var title:String = "<font size='15' color='#" + tooltipData.m_Color.toString(16) + "'>" + tooltipData.m_Title + "</font>"
			AddTextField(title, true );
            titleIndex = m_TooltipEntries.length - 1;
		}
        
        if ( tooltipData.m_IconID != undefined && !tooltipData.m_IconID.IsNull )
        {
            m_IconView = CreateIcon( tooltipData.m_IconID );
            m_IconView._visible = false;
            
            if (titleIndex != -1)
            {
                m_TooltipEntries[m_TooltipEntries.length - 1].SetRightContent(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, m_IconView);
            }
            else
            {
                var tooltipEntry:TooltipEntry = new TooltipEntry(undefined, undefined);
                tooltipEntry.SetRightContent(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, m_IconView);
                m_TooltipEntries.push(tooltipEntry);
            }
        }
        //TODO: WEAPONSICON m_IconView
        var weaponIconsView:MovieClip;
        if ( tooltipData.m_WeaponType != undefined && tooltipData.m_WeaponType != 0 && m_IconView == undefined)
        {
            weaponIconsView = CreateWeaponsIcon(tooltipData.m_WeaponType);
        }
		
		if  ( tooltipData.m_WeaponTypeRequirement != undefined && tooltipData.m_WeaponTypeRequirement != 0 )
        {
            weaponIconsView = CreateWeaponRequirementIcon(tooltipData.m_WeaponTypeRequirement);
        }
		
		if ( tooltipData.m_IconName != undefined )
        {
            weaponIconsView = CreateIconFromName( tooltipData.m_IconName );
        }
        
        if (weaponIconsView != undefined)
        {
            if (titleIndex != -1)
            {
                m_TooltipEntries[titleIndex].SetRightContent(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, weaponIconsView);
            }
            else
            {
                var tooltipEntry:TooltipEntry = new TooltipEntry(undefined, undefined);
                tooltipEntry.SetRightContent(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, weaponIconsView);
                m_TooltipEntries.push(tooltipEntry);
            }
        }
		var hasAddedRank:Boolean = false;
        
		if (tooltipData.m_SubTitle != undefined)
		{
            var subTitle:String = "<font size='11' color='#FFFFFF'>" + tooltipData.m_SubTitle + "</font>"
            AddPadding( -4 );
            AddTextField(subTitle, false );
		}
        else if ( tooltipData.m_AttackType != undefined || tooltipData.m_SpellType != undefined )
        {
            var attackType:String = "<font size='11' color='#FFFFFF'>" +  TooltipUtils.GetSpellTypeName(tooltipData.m_SpellType, tooltipData.m_AttackType) + "</font>";
            AddPadding( -4 );
            AddTextField(attackType, false );
        }
        else if ( tooltipData.m_WeaponType != undefined && tooltipData.m_WeaponType != 0 )
        {
            var weaponType:String = "<font size='11' color='#FFFFFF'>" +  LDBFormat.LDBGetText("ItemTypeGUI", tooltipData.m_WeaponType);
			if (tooltipData.m_ItemRank != undefined && tooltipData.m_ItemRank.length > 0)
			{
				weaponType += " (" + LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "QualityLevelAcronym"), tooltipData.m_ItemRank) +")";
				hasAddedRank = true;
			}
			weaponType += "</font>"
            AddPadding( -4 );
            AddTextField(weaponType, false );
        }
        
		if (!hasAddedRank && tooltipData.m_ItemRank != undefined && tooltipData.m_ItemRank > 0)
		{
            AddPadding( -4 );
            var itemRank:String = "<font size='11' color='#AAAAAA'>" + LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "QualityLevel"), tooltipData.m_ItemRank) + "</font>";
			AddTextField(itemRank, false );
		}
        if ( tooltipData.m_ItemBindingDesc != undefined && tooltipData.m_ItemBindingDesc != "")
        {
            AddPadding( -4 );
            var itemBinding:String = "<font size='11' color='#AAAAAA'>" + tooltipData.m_ItemBindingDesc + "</font>";
			AddTextField(itemBinding, false );
        }
        if (tooltipData.m_IsUnique)
        {
            var uniqueText:String = "<font size='11' color='#AAAAAA'><localized category=ItemInforelatedtext token=UniqueItem></font>";
            var uniqueView:TextField = CreateTextField(m_Clip, uniqueText, false);
            
            m_TooltipEntries[m_TooltipEntries.length - 1].SetRightContent(TooltipEntry.TOOLTIPENTRY_TYPE_TEXTFIELD, uniqueView);
        }
        
        if ((tooltipData.m_CastTime != undefined || tooltipData.m_RecastTime != undefined) && (tooltipData.m_SpellType != _global.Enums.SpellItemType.ePassiveAbility && tooltipData.m_SpellType != _global.Enums.SpellItemType.eElitePassiveAbility))
        {
            AddPadding( 5 );
            var castTimeView:MovieClip = CreateCastTimeView(tooltipData.m_CastTime, tooltipData.m_RecastTime);
            m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, castTimeView));
        }
        
        AddPadding( 5 );
        AddDivider();
        AddPadding( 5 );
        var descriptionNeedDivider:Boolean = false;
        if (tooltipData.m_Attributes != undefined && tooltipData.m_Attributes.length > 0)
        {
            for ( var i = 0 ; i < tooltipData.m_Attributes.length ; ++i )
            {
                var attribute:Object = tooltipData.m_Attributes[i];
                
                switch( attribute.m_Mode )
                {
                    case TooltipData.e_ModeNormal:
                        AddTextField("<font size='11' color='#ffffff'>" + attribute.m_Right + "</font>", false);
                        descriptionNeedDivider = true;
                        break;
                    case TooltipData.e_ModeSplitter:
                        AddPadding(5);
                        AddDivider();
                        descriptionNeedDivider = false;
                        
                    break;
                }
            }
        }
        
        if (descriptionNeedDivider)
        {
            AddDivider();
            AddPadding(5);
        }
        
        if ( tooltipData.m_Descriptions.length > 0 )
        {
            
            for (var i:Number = 0; i < tooltipData.m_Descriptions.length; i++)
            {
                if (tooltipData.m_Descriptions[i].length > 0)
                {
                    if (tooltipData.m_Descriptions[i] == "<hr>")
                    {
                        AddDivider();
                    }
                    else
                    {
                        AddPadding(5);
						var desc:String = tooltipData.m_Descriptions[i];
                        AddTextField("<font size='11' color='#ffffff'>" + Utils.SetupHtmlHyperLinks( desc, "_global.com.GameInterface.Tooltip.Tooltip.SlotHyperLinkClicked", true ) + "</font>");
                        if (i != tooltipData.m_Descriptions.length -1)
                        {
                            AddPadding(5);
                        }
                    }
                }
            }
        }
        
        AddPadding(5);
        AddDivider(5);
        AddPadding(5);
        
        if (tooltipData.m_EmptyPrefix)
        {
            var prefixView:MovieClip = m_Clip.createEmptyMovieClip("m_Prefix", m_Clip.getNextHighestDepth());
            var prefixText:TextField = CreateTextField(prefixView, "<font size='11' color='#aaaaaa'> "+ LDBFormat.LDBGetText("ItemInforelatedtext", "Empty_Glyph") + " </font>", false);
            var prefixSlot:MovieClip = prefixView.attachMovie("EmptyItemSlot", "m_PrefixSlot", prefixView.getNextHighestDepth());
            prefixText._width = prefixText.textWidth + 5;
            prefixText._x = prefixSlot._width + 2;
            prefixSlot._y = 3;
            
            m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, prefixView));
        }
        else if (tooltipData.m_PrefixData != undefined)
        {
            var titleText:String = "<font size='12' color='#" + tooltipData.m_PrefixData.m_Color.toString(16) + "'>" + tooltipData.m_PrefixData.m_Title  + "</font> <font size='12' color = '#aaaaaa'>(" + LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "QualityLevelAcronym"), tooltipData.m_PrefixData.m_ItemRank) +")</font>";
			AddTextField(titleText, false );
            
            if (tooltipData.m_PrefixData.m_Attributes != undefined && tooltipData.m_PrefixData.m_Attributes.length > 0)
            {
                for ( var i = 0 ; i < tooltipData.m_PrefixData.m_Attributes.length ; ++i )
                {
                    var attribute:Object = tooltipData.m_PrefixData.m_Attributes[i];
                    
                    switch( attribute.m_Mode )
                    {
                        case TooltipData.e_ModeNormal:
                            AddTextField("<font size='11' color='#ffffff'>" + attribute.m_Right + "</font>", false);
                            break;
                        break;
                    }
                }
            }
        
            if ( tooltipData.m_PrefixData.m_Descriptions.length > 0 )
            {
                for (var i:Number = 0; i < tooltipData.m_PrefixData.m_Descriptions.length; i++)
                {
                    if (tooltipData.m_PrefixData.m_Descriptions[i].length > 0)
                    {
                        if (tooltipData.m_PrefixData.m_Descriptions[i] == "<hr>")
                        {
                            //Do nothing
                        }
                        else
                        {
                            AddPadding(5);
							var desc:String = tooltipData.m_PrefixData.m_Descriptions[i];
                            AddTextField("<font size='11' color='#ffffff'>" + Utils.SetupHtmlHyperLinks( desc, "_global.com.GameInterface.Tooltip.Tooltip.SlotHyperLinkClicked", true ) + "</font>");
                            if (i != tooltipData.m_PrefixData.m_Descriptions.length -1)
                            {
                                AddPadding(5);
                            }
                        }
                    }
                }
            }
        }
        
        //Add a divider unless both are empty
        if (!(tooltipData.m_EmptyPrefix && tooltipData.m_EmptySuffix))
        {
            AddPadding(5);
            AddDivider(5);
            AddPadding(5);
        }
        
        
        if (tooltipData.m_EmptySuffix)
        {
            var suffixView:MovieClip = m_Clip.createEmptyMovieClip("m_Suffix", m_Clip.getNextHighestDepth());
            var suffixText:TextField = CreateTextField(suffixView, "<font size='11' color='#aaaaaa'> "+ LDBFormat.LDBGetText("ItemInforelatedtext", "Empty_Signet") + " </font>", false);
            var suffixSlot:MovieClip = suffixView.attachMovie("EmptyItemSlot", "m_SuffixSlot", suffixView.getNextHighestDepth());
            suffixText._width = suffixText.textWidth + 5;
            suffixText._x = suffixSlot._width + 2;
            suffixSlot._y = 3;
            
            m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, suffixView));
        }
        else if (tooltipData.m_SuffixData != undefined)
        {
            var titleText:String = "<font size='12' color='#" + tooltipData.m_SuffixData.m_Color.toString(16) + "'>" + tooltipData.m_SuffixData.m_Title  + "</font> <font size='12' color = '#aaaaaa'>(" + LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "QualityLevelAcronym"), tooltipData.m_SuffixData.m_ItemRank) +")</font>";
			AddTextField(titleText, false );
            
            if (tooltipData.m_SuffixData.m_Attributes != undefined && tooltipData.m_SuffixData.m_Attributes.length > 0)
            {
                for ( var i = 0 ; i < tooltipData.m_SuffixData.m_Attributes.length ; ++i )
                {
                    var attribute:Object = tooltipData.m_SuffixData.m_Attributes[i];
                    
                    switch( attribute.m_Mode )
                    {
                        case TooltipData.e_ModeNormal:
                            AddTextField("<font size='11' color='#ffffff'>" + attribute.m_Right + "</font>", false);
                            break;
                        case TooltipData.e_ModeSplitter:
                            AddPadding(5);
                            AddDivider();
                        break;
                    }
                }
            }
        
            if ( tooltipData.m_SuffixData.m_Descriptions.length > 0 )
            {
                for (var i:Number = 0; i < tooltipData.m_SuffixData.m_Descriptions.length; i++)
                {
                    if (tooltipData.m_SuffixData.m_Descriptions[i].length > 0)
                    {
                        if (tooltipData.m_SuffixData.m_Descriptions[i] == "<hr>")
                        {
                            AddDivider();
                        }
                        else
                        {
                            AddPadding(5);
							var desc:String = tooltipData.m_SuffixData.m_Descriptions[i];
                            AddTextField("<font size='11' color='#ffffff'>" + Utils.SetupHtmlHyperLinks( desc, "_global.com.GameInterface.Tooltip.Tooltip.SlotHyperLinkClicked", true ) + "</font>");
                            if (i != tooltipData.m_SuffixData.m_Descriptions.length -1)
                            {
                                AddPadding(5);
                            }
                        }
                    }
                }
            }
        }
        
        AddPadding( 5 );
        AddDivider();
        AddPadding( 5 );
        		
		if (tooltipData.m_WeaponTypeRequirement != undefined && tooltipData.m_WeaponTypeRequirement > 0)
		{
            AddTextField("<font size='11' color='#CCCCCC'>" + TooltipUtils.GetWeaponRequirementString(tooltipData.m_WeaponTypeRequirement) + "</font>", false);
			AddPadding(10);
		}
        
		if (tooltipData.m_ItemCriteriaLevel != undefined && tooltipData.m_ItemCriteriaLevel > 0)
		{
			if (tooltipData.m_ItemCriteriaType != undefined && tooltipData.m_ItemCriteriaType > 0)
			{
                AddTextField("<font color='#FF0000'>" + LDBFormat.Printf(LDBFormat.LDBGetText("CharacterSkillsGUI", "RequireSkillPoints"), LDBFormat.LDBGetText("CharacterSkillsGUI", tooltipData.m_ItemCriteriaType), tooltipData.m_ItemCriteriaLevel) + "</font>", false);
			}
		}
                
        var durabilityIndex:Number = -1;
        if (tooltipData.m_MaxDurability != undefined && tooltipData.m_MaxDurability > 0)
		{
            var durabilityView = m_Clip.createEmptyMovieClip("durability", m_Clip.getNextHighestDepth());
            var durability:String = (tooltipData.m_MaxDurability - tooltipData.m_Durability)  + "/" + tooltipData.m_MaxDurability;
            var iconBackgroundName:String = "";
            var iconID:String = "";
            
            var color:String = "#FFFFFF";
            
            if (tooltipData.m_Durability == undefined)
            {
                tooltipData.m_Durability = 0;
            }
            
            if (tooltipData.m_Durability == tooltipData.m_MaxDurability)
            {
                iconBackgroundName = "DurabilityBroken";
                iconID = "rdb:1000624:7363471";
                color = "#FF0000";
            }
            else if (tooltipData.m_Durability / tooltipData.m_MaxDurability > (2/3))
            {
                iconBackgroundName = "DurabilityBreaking";
                iconID = "rdb:1000624:7363472";
                color = "#FF9900";
            }
            
            durability = "<font color='" + color +"'>" + durability +"</font>";
            
            var durabilityText:TextField = CreateTextField(durabilityView, "<font size='11' color='#FFFFFF'>" + LDBFormat.Printf(LDBFormat.LDBGetText("ItemInforelatedtext", "TooltipDurability"), durability) + "</font>", false);
            
            if (iconBackgroundName.length > 0)
            {
                var durabilityIcon:MovieClip = durabilityView.attachMovie(iconBackgroundName, "m_Background", durabilityView.getNextHighestDepth());
                var container:MovieClip = durabilityIcon.createEmptyMovieClip("m_Container", durabilityIcon.getNextHighestDepth());
                
                var imageLoader:MovieClipLoader = new MovieClipLoader();
                var imageLoaderListener:Object = new Object;
                imageLoaderListener.onLoadInit = function(target:MovieClip)
                {
                    target._x = 1;
                    target._y = 1;
                    target._xscale = 18;
                    target._yscale = 18;
                }
                
                imageLoader.addListener( imageLoaderListener );
                imageLoader.loadClip( iconID, container );
                
                durabilityText._x = 25;
            }
            
            m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, durabilityView));
            durabilityIndex = m_TooltipEntries.length - 1;
		}
        
        if (tooltipData.m_SellPrice > 0)
        {
            var sellPrice:String = tooltipData.m_SellPrice.toString();
            var sellPriceView:MovieClip = m_Clip.createEmptyMovieClip("i_SellPriceView", m_Clip.getNextHighestDepth());
            var label:TextField = CreateTextField(sellPriceView, "<font size='11' color='#ffffff'>" +sellPrice+"</font>", false );
            var icon:MovieClip = sellPriceView.attachMovie("PaxRomana", "m_CashSymbol", sellPriceView.getNextHighestDepth());
            label._width = label.textWidth + 5;
            icon._x = label._width + 5;
            icon._xscale = 80;
            icon._yscale = 80
            
            if (durabilityIndex != -1)
            {
                m_TooltipEntries[durabilityIndex].SetRightContent(TooltipEntry.TOOLTIPENTRY_TYPE_TEXTFIELD, sellPriceView);
            }
            else
            {
                var tooltipEntry:TooltipEntry = new TooltipEntry(undefined, undefined);
                tooltipEntry.SetRightContent(TooltipEntry.TOOLTIPENTRY_TYPE_TEXTFIELD, sellPriceView);
                m_TooltipEntries.push(tooltipEntry);
            }
        }        
        
        if (tooltipData.m_PlayerSellPrice > 0)
        {
            var sellFor:String = "<font size='11' color='#ffffff'>"+  LDBFormat.LDBGetText("ItemInforelatedtext","SellingItemFor" ) +"</font>" ;
            AddTextField(sellFor, true );
            
            var sellPrice:String = tooltipData.m_PlayerSellPrice.toString();
            var sellPriceView:MovieClip = m_Clip.createEmptyMovieClip("i_SellPriceView", m_Clip.getNextHighestDepth());
            var iconContainer:MovieClip = sellPriceView.createEmptyMovieClip("m_iconContainer", sellPriceView.getNextHighestDepth());
            
            var label:TextField = CreateTextField(sellPriceView, "<font size='11' color='#ffffff'>" +sellPrice + "</font>", false );
            label._x = 20;
            label._y = 1;
            
            var iconID:String = "rdb:1000624:7466286";
            var imageLoader:MovieClipLoader = new MovieClipLoader();
            var imageLoaderListener:Object = new Object;
            imageLoaderListener.onLoadInit = function(target:MovieClip)
            {
                target._x = 0;
                target._y = 0;
                target._xscale = 20;
                target._yscale = 20;
            }
            imageLoader.addListener( imageLoaderListener );
            imageLoader.loadClip( iconID, iconContainer );

            m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, sellPriceView));
        }
		
		if (tooltipData.m_MiscItemInfo != undefined)
        {
            AddTextField("<font size='11' color='#bbbbbb'>" + tooltipData.m_MiscItemInfo + "</font>", false);
        }
        
        if ( tooltipData.m_ItemSentTo != undefined )
        {
            var sentTo:String = "<font size='11' color='#ffffff'>" +  LDBFormat.LDBGetText("ItemInforelatedtext", "ItemSentTo" ) +"</font>" ;
            AddTextField(sentTo, true );
            AddTextField("<font size='11' color='#ffffff'>" + tooltipData.m_ItemSentTo +"</font>", true );
        }
        
		
		AddPadding(5);
		
		if (tooltipData.m_CompareAttributes  != undefined && tooltipData.m_CompareAttributes.length > 0)
        {
            var compareView:MovieClip = m_Clip.createEmptyMovieClip("i_CompareView", m_Clip.getNextHighestDepth());
            var compareViewBackground:MovieClip = compareView.createEmptyMovieClip("m_Background", compareView.getNextHighestDepth());
                        
            var y:Number = 4;
            
            var compareTitleLabel:TextField = CreateTextField(compareView, "<font size='10' color='#b19f79'>" + LDBFormat.LDBGetText("ItemInforelatedtext", "StatChanges") + "</font>", false)
            compareTitleLabel._y = y;
            y += compareTitleLabel._height;
			
			y += 3;
			
			var divider:MovieClip = compareView.attachMovie( "DividerLine", "", compareView.getNextHighestDepth());
			divider._width = m_Width - (m_Padding * 2);
			divider._y = y;
			
			y += 3 + divider._height;
            
            for (var i:Number = 0; i < tooltipData.m_CompareAttributes.length; i++ )
            {
				if (tooltipData.m_CompareAttributes[i] == "<hr>")
				{
					y += 3;
					var divider:MovieClip = compareView.attachMovie( "DividerLine", "", compareView.getNextHighestDepth());
					divider._width = m_Width - (m_Padding * 2);
					divider._y = y;
					y += 3 + divider._height;
				}
                var label:TextField = CreateTextField(compareView, "<font size='11' color='#ffffff'>" + tooltipData.m_CompareAttributes[i] + "</font>",false );
                label._y = y;
                y += label._height-2;
            }
            
            com.Utils.Draw.DrawRectangle(compareViewBackground, -3, 0, m_Width - (m_Padding * 2) + 6, compareView._height + 6, 0x666666, 40, [5, 5, 5, 5], 1, 0xFFFFFF, 0);
            
            m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP, compareView));
        }
        
        
        if (tooltipData.m_GMInfo.length > 0)
        {
            AddPadding(5);
            AddDivider();
            AddPadding(5);
            AddTextField("<font size='11' color='#ffffff'><b><i><localized category=ItemInfoGUI token=ItemInfoView_GMInfo></i></b></font>", false);
            AddTextField("<font size='11' color='#ffffff'>" + tooltipData.m_GMInfo + "</font>", false);
        }
        RemoveOverflowDividers();
        RemoveOverflowPadding();
        Layout();
		m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
		m_ResolutionScaleMonitor.SignalChanged.Connect( Layout, this );
    }
    
    private function CreateTextField(parent:MovieClip, htmlText:String, bold:Boolean) : TextField
    {
        var textField:TextField = parent.createTextField("m_TextField_" + parent.UID(), parent.getNextHighestDepth(), 0, 0, m_Width - m_Padding*2, 0);
        textField.wordWrap = true;
        textField.html = true;
        textField.autoSize = "left";
        textField.multiline = true;
		textField.selectable = false;
		
        if (bold)
        {
            htmlText = "<b><font face='_StandardFont'>" +ConvertNewLines(htmlText) + "</font></b>";
        }
        else
        {
            htmlText = "<font face='_StandardFont'>" +ConvertNewLines(htmlText) + "</font>";
        }
        
        textField.htmlText = htmlText;
        
        return textField;
    }
	
	function ConvertNewLines(text:String)
	{
		return text.split('\r\n').join('\n');
	}
    
    private function AddTextField(htmlText:String, bold:Boolean) : Void
    {
        var textField:TextField = CreateTextField(m_Clip, htmlText, bold);
        m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_TEXTFIELD, textField));
        
    }
    
    private function AddDivider()
    {
        var divider:MovieClip = m_Clip.attachMovie( "DividerLine", "", m_Clip.getNextHighestDepth());
        divider._width = m_Width - m_Padding * 2;
        m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_DIVIDER, divider));
    }
    
    private function RemoveOverflowDividers()
    {
        var lastDivider:Boolean = true;
        var lastDividerIndex:Number = -1;
        var i:Number = 0;
        while (i < m_TooltipEntries.length)
        {
            if (m_TooltipEntries[i].m_TypeLeft == TooltipEntry.TOOLTIPENTRY_TYPE_DIVIDER)
            {
                if (lastDivider)
                {
                    m_TooltipEntries[i].m_ContentLeft.removeMovieClip();
                    m_TooltipEntries.splice(i, 1);
                    continue;
                }
                lastDivider = true;
                lastDividerIndex = i;
            }
            else if(m_TooltipEntries[i].m_TypeLeft != TooltipEntry.TOOLTIPENTRY_TYPE_PADDING)
            {
                lastDivider = false;
            }
            i++;
        }
        
        //Remove the last divider if there is nothing after it
        if (lastDivider)
        {
            m_TooltipEntries[lastDividerIndex].m_ContentLeft.removeMovieClip();
            m_TooltipEntries.splice(lastDividerIndex, 1);
        }
    }
    
    private function RemoveOverflowPadding()
    {
        var lastPadding:Boolean = false;
        var i:Number = 0;
        while (i < m_TooltipEntries.length)
        {
            if (m_TooltipEntries[i].m_TypeLeft == TooltipEntry.TOOLTIPENTRY_TYPE_PADDING)
            {
                if (lastPadding)
                {
                    m_TooltipEntries.splice(i, 1);
                    continue;
                }
                lastPadding = true;
            }
            else
            {
                lastPadding = false;
            }
            i++;
        }
    }
    
    private function AddPadding(padding:Number)
    {
        m_TooltipEntries.push(new TooltipEntry(TooltipEntry.TOOLTIPENTRY_TYPE_PADDING, undefined, padding));
    }
    
    private function Layout() : Void
    {
        var y:Number = m_Padding;
        for (var i:Number = 0; i < m_TooltipEntries.length; i++)
        {
            if (m_TooltipEntries[i].m_TypeLeft != undefined)
            {
                switch(m_TooltipEntries[i].m_TypeLeft)
                {
                    case TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP:
                        if (m_TooltipEntries[i].m_ContentRight != undefined)
                        {
                            if (m_TooltipEntries[i].m_TypeRight == TooltipEntry.TOOLTIPENTRY_TYPE_TEXTFIELD)
                            {
                                m_TooltipEntries[i].m_ContentRight._width = m_TooltipEntries[i].m_ContentRight.textWidth + 5;
                            }
                            m_TooltipEntries[i].m_ContentRight._x = m_Width - m_Padding * 2 - m_TooltipEntries[i].m_ContentRight._width;
                            m_TooltipEntries[i].m_ContentRight._y = y;
                        }
                        m_TooltipEntries[i].m_ContentLeft._y = y;
                        m_TooltipEntries[i].m_ContentLeft._x = m_Padding;
                        y += m_TooltipEntries[i].m_ContentLeft._height;
                        break;
                    case TooltipEntry.TOOLTIPENTRY_TYPE_TEXTFIELD:
                        if (m_TooltipEntries[i].m_ContentRight != undefined)
                        {
                            if (m_TooltipEntries[i].m_TypeRight == TooltipEntry.TOOLTIPENTRY_TYPE_TEXTFIELD)
                            {
                                m_TooltipEntries[i].m_ContentRight._width = m_TooltipEntries[i].m_ContentRight.textWidth + 5;
                            }
                            m_TooltipEntries[i].m_ContentRight._x = m_Width - m_Padding * 2 - m_TooltipEntries[i].m_ContentRight._width;
                            m_TooltipEntries[i].m_ContentRight._y = y;
                            m_TooltipEntries[i].m_ContentLeft._width -= m_TooltipEntries[i].m_ContentRight._width - 30;
                        }
                        m_TooltipEntries[i].m_ContentLeft._y = y;
                        m_TooltipEntries[i].m_ContentLeft._x = m_Padding;
                        y += m_TooltipEntries[i].m_ContentLeft._height;
                        break;
                    case TooltipEntry.TOOLTIPENTRY_TYPE_DIVIDER:
                        m_TooltipEntries[i].m_ContentLeft._y = y;
                        m_TooltipEntries[i].m_ContentLeft._x = m_Padding;
                        break;
                    case TooltipEntry.TOOLTIPENTRY_TYPE_PADDING:
                        y += m_TooltipEntries[i].m_Padding;
                        break;
                }
            }
            else if (m_TooltipEntries[i].m_TypeRight != undefined)
            {
                switch(m_TooltipEntries[i].m_TypeRight)
                {
                    case TooltipEntry.TOOLTIPENTRY_TYPE_MOVIECLIP:
                        m_TooltipEntries[i].m_ContentRight._y = y;
                        m_TooltipEntries[i].m_ContentRight._x = m_Width - m_Padding * 2 - m_TooltipEntries[i].m_ContentRight._width;
                        y += m_TooltipEntries[i].m_ContentRight._height;
                        break;
                    case TooltipEntry.TOOLTIPENTRY_TYPE_TEXTFIELD:
                        m_TooltipEntries[i].m_ContentRight._y = y;
                        m_TooltipEntries[i].m_ContentRight._x = m_Width - m_Padding * 2 - m_TooltipEntries[i].m_ContentRight._width;
                        y += m_TooltipEntries[i].m_ContentRight._height;
                        break;
                }
            }
        }
        
        y += m_Padding;
        		
        m_ContentSize.y = y;
        m_ContentSize.x = m_Width;
        
		m_Clip.m_Stripes.x = 2;
		m_Clip.m_Stripes.y = 2;
		m_Clip.m_Stripes._width = m_ContentSize.x;
        m_Clip.m_Background._width  = m_ContentSize.x;
        m_Clip.m_Background._height = m_ContentSize.y;
		m_Clip.m_Frame._width  = m_Clip.m_Background._width + 1;
        m_Clip.m_Frame._height = m_Clip.m_Background._height + 2;
		
		if (m_CurrentlyEquipped)
		{
			m_Clip.m_Frame._alpha = 20;
		}
        m_Clip.m_CloseButton._x = m_ContentSize.x - m_Clip.m_CloseButton._width - m_Padding;
		m_Clip.m_CloseButton._y = 4;
        
        //var scale:Number = m_ResolutionScaleMonitor.GetValue();
		//m_Clip._xscale = scale * 120;
		//m_Clip._yscale = scale * 120;
        
        SignalSizeChanged.Emit();
    }
    
    public function GetSize() : flash.geom.Point
    {
        return m_ContentSize;
    }

    public function SetPosition( pos:flash.geom.Point ) : Void
    {
        m_Clip._x = pos.x;
        m_Clip._y = pos.y;
    }
    
    public function RemoveMovieClip() : Void
    {
        m_Clip.removeMovieClip();
    }
        
    public function CreateCastTimeView(castTime:Number, recastTime:Number):MovieClip
    {
        var movieClip:MovieClip = m_Clip.createEmptyMovieClip( "i_CastTimeView", m_Clip.getNextHighestDepth()/* { _width:36, _height:36 }*/ );
        var xPos:Number = 0;
        if (castTime != undefined)
        {
            movieClip.attachMovie("CastTimeIcon", "i_CastTimeIcon", movieClip.getNextHighestDepth(), {_x:xPos } )
            xPos += movieClip.i_CastTimeIcon._width;
            movieClip.attachMovie("CastTimerTextLabel", "i_CastTimeText", movieClip.getNextHighestDepth(), {_x:xPos } )
			movieClip.i_CastTimeText.autoSize = "left";
            if (castTime > 0)
            {
                movieClip.i_CastTimeText.htmlText = com.Utils.Format.Printf( "<font size='11' color='#ffffff'><b><i>%.1f</i></b></font>", castTime);
            }
            else
            {
                movieClip.i_CastTimeText.htmlText = "<font size='11' color='#ffffff'><b><i><localized category=ItemInfoGUI token=Instant></i></b></font>";
            }
            xPos += movieClip.i_CastTimeText.textField.textWidth + 10;
        }
        if(recastTime != undefined)
        {
            movieClip.attachMovie("RecastTimeIcon", "i_RecastTimeIcon", movieClip.getNextHighestDepth(), {_x:xPos } )
            xPos += movieClip.i_RecastTimeIcon._width;
            movieClip.attachMovie("CastTimerTextLabel", "i_RecastTimeText", movieClip.getNextHighestDepth(), { _x:xPos } )
			movieClip.i_RecastTimeText.autoSize = "left";
            if (recastTime > 0)
            {
                movieClip.i_RecastTimeText.htmlText = com.Utils.Format.Printf( "<font size='11' color='#ffffff'><b><i>%.1f</i></b></font>", recastTime);
            }
            else
            {
                movieClip.i_RecastTimeText.htmlText = "<font size='11' color='#ffffff'><b><i><localized category=ItemInfoGUI token=Instant></i></b></font>";
            }
        }
        return movieClip;
    }
	
	public function CreateIconFromName(iconName:String)
	{
        var iconView:MovieClip = m_Clip.attachMovie("IconFrame", "i_IconFrame", m_Clip.getNextHighestDepth());
        iconView._xscale = 80;
        iconView._yscale = 80;
        iconView.attachMovie(iconName, "m_Icon", iconView.getNextHighestDepth(), { _xscale:34, _yscale:34, _x:1, _y:1 });
        return iconView;
	}

    public function CreateWeaponsIcon(weaponType):MovieClip
    {
        var iconView:MovieClip = m_Clip.attachMovie("IconFrame", "i_IconFrame", m_Clip.getNextHighestDepth());
        iconView._xscale = 80;
        iconView._yscale = 80;
        if (!TooltipUtils.CreateItemIconFromType(iconView, weaponType, { _xscale:34, _yscale:34, _x:1, _y:1 } ))
        {
            iconView.removeMovieClip();
            return undefined;
        }
        
        return iconView;
    }
	
	public function CreateWeaponRequirementIcon(weaponRequirement):MovieClip
	{
        var iconView:MovieClip = m_Clip.attachMovie("IconFrame", "i_IconFrame", m_Clip.getNextHighestDepth());
        iconView._xscale = 80;
        iconView._yscale = 80;
        if (!TooltipUtils.CreateWeaponRequirementsIcon(iconView, weaponRequirement, { _xscale:34, _yscale:34, _x:1, _y:1 } ))
        {
            iconView.removeMovieClip();
            return undefined;
        }
        return iconView;
	}
	
    public function CreateIcon( iconID:com.Utils.ID32 ) : MovieClip
    {
        var iconMC:MovieClip = m_Clip.createEmptyMovieClip( "", m_Clip.getNextHighestDepth(), { _width:36, _height:36 } );
        
        var mclistener:Object = new Object();
        var moviecliploader:MovieClipLoader = new MovieClipLoader();
        moviecliploader.addListener( mclistener );

        var check:Boolean = moviecliploader.loadClip( com.Utils.Format.Printf( "rdb:%.0f:%.0f", iconID.GetType(), iconID.GetInstance() ), iconMC ); 
                
        mclistener.onLoadInit = Delegate.create( this, OnIconLoaded );
        return iconMC;
    }
    
    public function OnIconLoaded( iconMC:MovieClip )
    {
        var scale = Math.min( 36 / iconMC._width, 36 / iconMC._height ) * 100;

        iconMC._visible = m_ShowIcon;
        iconMC._xscale = scale;
        iconMC._yscale = scale;
        
        Layout();
    }
        
    public function ShowCloseButton( show:Boolean )
    {
        m_Clip.m_CloseButton._visible = show;
    }

    public function SetCompareMode( compareMode:Boolean ) : Void
    {
        if ( compareMode != m_CompareMode )
        {
            m_CompareMode = compareMode;
            Layout();
        }
    }
    public function ShowIcon( show:Boolean )
    {
        if ( show != m_ShowIcon )
        {
            m_ShowIcon = show;
            if ( m_IconView != null )
            {
                m_IconView._visible = show;
                Layout();
            }
        }
    }
}
