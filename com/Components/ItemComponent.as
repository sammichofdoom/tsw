//import mx.core.UIComponent
import com.Utils.Colors;
import com.GameInterface.Log;
import mx.utils.Delegate;
import com.GameInterface.InventoryItem;

class com.Components.ItemComponent extends MovieClip
{
    
    private var DECORATION_STRIPES:Number = 0;
    private var DECORATION_CIRCLES:Number = 1;
    private var DECORATION_GRID:Number = 2;
    private var DECORATION_NONE:Number = 3;

    private var PLAIN:Number = 0;
    private var CHAKRA1:Number = 1;
    private var CHAKRA2:Number = 2;
    private var CHAKRA3:Number = 3;
    private var CHAKRA4:Number = 4;
    private var CHAKRA5:Number = 5;
    private var CHAKRA6:Number = 6;
    private var CHAKRA7:Number = 7;
	
    private static var ITEM_RARITY_UNCOMMON:Number = 0;
    private static var ITEM_RARITY_RARE:Number = 1;
    private static var ITEM_RARITY_EPIC:Number = 2;
    private static var ITEM_RARITY_LEGENDARY:Number = 3;

    private var m_ItemShape:Number;
    private var m_StackSize:Number;
    private var m_Alpha:Number;
    private var m_Locked:Boolean;
    private var m_InventoryItem:InventoryItem;
    
    private var m_Content:MovieClip;
    private var m_Background:MovieClip;
    private var m_Grid:MovieClip;
    private var m_Circles:MovieClip;
    private var m_Stripes:MovieClip;
    private var m_Stroke:MovieClip;
   // private var m_OuterBorder:MovieClip;
    private var m_Gloss:MovieClip;
    private var m_Glow:MovieClip;
    private var m_Icon:MovieClip;
    private var m_StackSizeClip:MovieClip;
    private var m_CanNotUse:MovieClip;
    private var m_DurabilityBackground:MovieClip;
    
    private var m_BackgroundList:Array;
    private var m_DecorationList:Array;
    private var m_StrokeList:Array;
    
    private var m_BackgroundColor:Number;
    
	private var m_IconLoader:MovieClipLoader;
    
    private var m_StackSizeScale:Number;
	private var m_ShowCanUse:Boolean;
	
	private var m_CooldownIntervalID:Number;
	private var m_Increments:Number;
	private var m_ExpireTime:Number;
	private var m_HasCooldown:Boolean;
	private var m_TotalDuration:Number;
    private var m_CooldownTimer:MovieClip;
	private var m_CooldownTint:Number;
	
	private var m_IconLoadInterval:Number;
    
    public function ItemComponent()
    {
        super.init();
        
        Glow(false);
        
        m_StackSizeClip = undefined;
        
        m_StackSize = 0;
        m_Alpha = 100;
        m_Locked = false;
		m_IconLoadInterval = -1;
        
        m_StackSizeScale = 100;
		m_HasCooldown = false;
        
        /*
         * All backgrounds are contained in the m_Background clip 
         * The list below is used to turn individual backgrounds on and off and 
         * tint individual backgrounds
         */
        m_BackgroundList = []
        m_BackgroundList[PLAIN] = m_Background.m_Background_Plain
        m_BackgroundList[CHAKRA1] = m_Background.m_Background_Chakra1;
        m_BackgroundList[CHAKRA2] = m_Background.m_Background_Chakra2;
        m_BackgroundList[CHAKRA3] = m_Background.m_Background_Chakra3;
        m_BackgroundList[CHAKRA4] = m_Background.m_Background_Chakra4;
        m_BackgroundList[CHAKRA5] = m_Background.m_Background_Chakra5;
        m_BackgroundList[CHAKRA6] = m_Background.m_Background_Chakra6;
        m_BackgroundList[CHAKRA7] = m_Background.m_Background_Chakra7;
		
        m_DecorationList = [];
        m_DecorationList[DECORATION_STRIPES] = m_Stripes;
        m_DecorationList[DECORATION_CIRCLES] = m_Circles;
        m_DecorationList[DECORATION_GRID] = m_Grid;
        
		m_StrokeList = [];
        m_StrokeList[PLAIN]     = m_Stroke.m_Stroke_Plain;
        m_StrokeList[CHAKRA1]   = m_Stroke.m_Stroke_Chakra1;
        m_StrokeList[CHAKRA2]   = m_Stroke.m_Stroke_Chakra2;
        m_StrokeList[CHAKRA3]   = m_Stroke.m_Stroke_Chakra3;
        m_StrokeList[CHAKRA4]   = m_Stroke.m_Stroke_Chakra4;
        m_StrokeList[CHAKRA5]   = m_Stroke.m_Stroke_Chakra5;
        m_StrokeList[CHAKRA6]   = m_Stroke.m_Stroke_Chakra6;
        m_StrokeList[CHAKRA7]   = m_Stroke.m_Stroke_Chakra7;
        
		var mclistener:Object = new Object();
		m_IconLoader  = new MovieClipLoader();
		m_IconLoader.addListener( mclistener );
		
		m_CooldownIntervalID = -1;
		m_Increments = 20;
		m_ExpireTime = 0;
		m_TotalDuration = 0;
		
		m_ShowCanUse = true;
		
    }
    
    public function PrintStats()
    {
        trace("ItemComponent rarity = " + m_InventoryItem.m_Rarity + " type = " + m_InventoryItem.m_ItemType);
    }
    
    public function SetData(inventoryItem:InventoryItem, iconLoadDelay:Number)
    {
        m_InventoryItem = inventoryItem;
        
        SetType();
        SetRarity();
		SetCanUse();
        SetColorLine();
		
		//Durability		
		if (m_DurabilityBackground != undefined)
		{
			m_DurabilityBackground.removeMovieClip();
			m_DurabilityBackground = undefined;
		}
        if (m_InventoryItem.m_MaxDurability > 0)
        {
            var iconBackgroundName:String = "";
            var iconID:String = "";
            if (m_InventoryItem.IsBroken())
            {
                iconBackgroundName = "DurabilityBroken";
                iconID = "rdb:1000624:7363471";
            }
            else if (m_InventoryItem.IsBreaking())
            {
                iconBackgroundName = "DurabilityBreaking";
                iconID = "rdb:1000624:7363472";
            }
            
            if (iconBackgroundName.length > 0)
            {
                m_DurabilityBackground = attachMovie(iconBackgroundName, "m_DurabilityBackground", getNextHighestDepth());
                m_DurabilityBackground._y = _height - 17;
                m_DurabilityBackground._x = -3;
                var container:MovieClip = m_DurabilityBackground.createEmptyMovieClip("m_Container", m_DurabilityBackground.getNextHighestDepth());
                     
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
            }
        }
		
		if (iconLoadDelay != undefined)
		{
			if (m_IconLoadInterval != -1)
			{
				clearInterval(m_IconLoadInterval);
				m_IconLoadInterval = -1;
			}
			m_IconLoadInterval = setInterval(Delegate.create(this, SetIcon), iconLoadDelay)
		}
		else
		{
			SetIcon();
		}
    }
    
    private function SetIcon() : Void
    {
        if (m_IconLoadInterval != -1)
		{
            clearInterval(m_IconLoadInterval);
            m_IconLoadInterval = -1;
        }
        
        var icon:com.Utils.ID32 = m_InventoryItem.m_Icon;
        
        if (icon != undefined && icon.GetType() != 0 && icon.GetInstance() != 0)
        {
            var iconString:String = com.Utils.Format.Printf( "rdb:%.0f:%.0f", icon.GetType(), icon.GetInstance() );
			
            m_IconLoader.loadClip( iconString, m_Content );

            var w = m_Background._width - 4;
            var h = m_Background._height - 4;
            
            m_Content._xscale = w;
            m_Content._yscale = h;
            m_Content._x = 2;
            m_Content._y = 2;
            
            m_Icon = m_Content;
        }
    }
    
    private function SetRarity()
    {
		var color:Number = GetRarityColor();
		if (color > -1)
		{
			SetStrokeColor( color );
		}
    }
	
	private function SetCanUse()
	{
		if (m_InventoryItem.m_CanUse != undefined && !m_InventoryItem.m_CanUse && m_ShowCanUse)
		{
            if ( m_CanNotUse == undefined )
            {
                m_CanNotUse = attachMovie("CannotUseIcon", "m_CanNotUse", getNextHighestDepth());	
            }
		}
        else if (m_CanNotUse != undefined)
        {
            m_CanNotUse.removeMovieClip();
            m_CanNotUse = undefined;
        }

	}
    
    private function GetRarityColor():Number
    {
        var color:Number = -1;
        switch(m_InventoryItem.m_Rarity)
        {
            case _global.Enums.ItemPowerLevel.e_Superior:
                color = Colors.e_ColorBorderItemSuperior;
				break;
            case _global.Enums.ItemPowerLevel.e_Enchanted:
                color = Colors.e_ColorBorderItemEnchanted;
				break;
            case _global.Enums.ItemPowerLevel.e_Rare:
                color = Colors.e_ColorBorderItemRare;
				break;
			case _global.Enums.ItemPowerLevel.e_Epic:
                color = Colors.e_ColorBorderItemEpic;
				break;
			case _global.Enums.ItemPowerLevel.e_Legendary:
                color = Colors.e_ColorBorderItemLegendary;
				break;
        }
        return color;
    }
    
    private function SetType()
    {
        switch(m_InventoryItem.m_ItemType)
        {
            case _global.Enums.ItemType.e_ItemType_CraftingItem:
                SetTypeCrafting();
            break;
            case _global.Enums.ItemType.e_ItemType_MissionItem:
                SetTypeMission();
            break;
            case _global.Enums.ItemType.e_ItemType_MissionItemConsumable:
                SetTypeMissionUsable();
            break;
            case _global.Enums.ItemType.e_ItemType_Weapon:
                SetTypeWeapons();
            break;
            case _global.Enums.ItemType.e_ItemType_Chakra:
                SetTypeChakras()
            break;
            case _global.Enums.ItemType.e_ItemType_Consumable:
                SetTypeConsumable();
            break;
            case    _global.Enums.ItemType.e_ItemType_None:
                    default:
                SetTypeNone();

        }
    }
    
    
    private function SetColorLine()
    {
        var colorObject:Object = Colors.GetColorlineColors( m_InventoryItem.m_ColorLine );
        
        Colors.ApplyColor( m_BackgroundList[ m_ItemShape ].background, colorObject.background);
        Colors.ApplyColor( m_BackgroundList[ m_ItemShape ].highlight, colorObject.highlight);
        
    }
    

    
    /// iterates the stroke array and the background array setting the correct viaibility.
    /// after settingt this we can manuipulate a single m_Background and m_Stroke for this item
    /// @param index:Number - the type (position in array) of icon to set visible
    private function SetItemShape( index:Number )
    {
        m_ItemShape = index;
        for (var i:Number = 0; i < m_BackgroundList.length; i++ )
        {
            MovieClip( m_BackgroundList[i] )._visible = (index == i);
            MovieClip( m_StrokeList[i] )._visible = (index == i);
        }
    }
	public function SetShowCanUse(show:Boolean)
	{
		m_ShowCanUse = show;
	}
	
    public function SetStackSize(stackSize:Number)
    {
        m_StackSize = stackSize;
        
        if (m_StackSize > 1)
        {
            if (m_StackSizeClip == undefined)
            {
                m_StackSizeClip = attachMovie("_BuffCharge", "m_StackSizeClip", getNextHighestDepth(), { _x:_width, _y:_height, _xscale:m_StackSizeScale, _yscale:m_StackSizeScale } );
            }

            m_StackSizeClip.SetMax(m_StackSize);
            m_StackSizeClip.SetCharge(m_StackSize);
        }
        else
        {
            if (m_StackSizeClip != undefined)
            {
                m_StackSizeClip.removeMovieClip();
                m_StackSizeClip = undefined;
            }
        }
    }
    
    public function SetStackSizeScale(scale:Number)
    {
        m_StackSizeScale = scale;
        m_StackSizeClip._xscale = m_StackSizeClip._yscale = m_StackSizeScale;
    }
    
    public function SetAlpha(alpha:Number)
    {
        m_Alpha = alpha;
        if (!m_Locked)
        {
            _alpha = m_Alpha;
        }
    }

    public function GetAlpha() : Number
    {
        return (m_Locked) ? 30 : m_Alpha;
    }
    
    public function SetLocked(locked:Boolean)
    {
        m_Locked = locked
        _alpha = (m_Locked) ? 30 : m_Alpha;
    }
    

    
    public function Glow(glow:Boolean)
    {
        m_Glow._visible = glow;
        var scale:Number = (glow ? 69 : 35);
    }
    
    public function SetThrottle(throttle:Boolean)
    {
        var color:Number = GetRarityColor();
        if (color == -1)
        {
            color = 0xFFFFFF;
        }
        var throttleSpeed:Number = (arguments.length > 1) ? arguments[1] : 20; // time it takes for a throttle to complete in secounds
        m_Background.m_Color = (arguments.length > 2) ? arguments[2] : color;        
        if (throttle)
        {
            m_Background.m_Increase = true;
            m_Background.m_CurrentBlend = 0;
            /// method for the throttle
            m_Background.Throttle = function()
            {
                if (this.m_Increase)
                {
                    this.m_CurrentBlend += 2;
                    if (this.m_CurrentBlend >= 100)
                    {
                        this.m_Increase = false;
                    }
                }
                else
                {
                    this.m_CurrentBlend -= 2;
                    if (this.m_CurrentBlend <= 0)
                    {
                        this.m_Increase = true;
                    }
                }
                com.Utils.Colors.Tint(this, this.m_Color, this.m_CurrentBlend);
            }
            
            // execute
            m_Background.m_IntervalId = setInterval( m_Background, "Throttle", throttleSpeed);
           
        }
        else
        {
            if (!isNaN( m_Background.m_IntervalId))
            {
                clearInterval( m_Background.m_IntervalId );
            }
            
            if (m_Background.Throttle != undefined)
            {
                m_Background.Throttle = undefined;
                com.Utils.Colors.Tint(m_Background, m_Background.m_Color, 0);
            }
        }
    }
    
    public function HasThrottle()
    {
        return (m_Background.Throttle != undefined && !isNaN( m_Background.m_IntervalId))
      
    } 
    /*
    public function SetOuterBorderColor(color:Number):Void
    {
     //   Colors.ApplyColor(m_OuterBorder, color);
    }
    
    private function SetNoBorderColor()
    {
        if (m_InventoryItem.m_ItemType != _global.Enums.ItemType.e_ItemType_MissionItem || m_InventoryItem.m_ItemType != _global.Enums.ItemType.e_ItemType_MissionItemConsumable)
        {
            m_Stroke._visible = false;
        }
    }
 
    private function SetBorderColor(color:Number)
    {
        
       /* 
        if ( m_InventoryItem.m_ItemType == _global.Enums.ItemType.e_ItemType_Chakra )
		{
			m_InnerBorder._visible = false;
			
			for (var i:Number = 1; i <= 7; i++)
			{
				Colors.ApplyColor(this["m_Chakra"+i].m_Stroke, color);
			}
			
		}
		else
		{
			m_InnerBorder._visible = true;
			Colors.ApplyColor(m_InnerBorder, color);
		}
    }
    */
    private function SetDecoration(index:Number)
    {
            for (var i:Number = 0; i < m_DecorationList.length; i++ )
        {
            MovieClip( m_DecorationList[i] )._visible = (i == index);
			
        }
    }
    
    private function SetBackgroundColor(color:Number)
    {
        Colors.ApplyColor( m_BackgroundList[ m_ItemShape ], color);
    }
    
    private function SetStrokeColor(color:Number)
    {
        m_Stroke._visible = true;
        Colors.ApplyColor( m_StrokeList[ m_ItemShape ], color);
    }
    
    private function SetTypeCrafting()
    {
        m_Gloss._visible = false;
        m_Stroke._visible = false;
        SetItemShape( PLAIN );
      //  SetBackgroundColor( Colors.e_ColorItemTypeCrafting )
        SetDecoration( DECORATION_GRID  );
    }
    
    private function SetTypeMission()
    {
        m_Gloss._visible = false;
    //    m_InnerBorder._visible = true;
        
        SetItemShape( PLAIN );        
      //  SetBackgroundColor( Colors.e_ColorItemTypeMission )
        SetStrokeColor( Colors.e_ColorBorderItemMission );
        SetDecoration( DECORATION_NONE  );
    }

    private function SetTypeMissionUsable()
    {
        m_Gloss._visible = false;
   //     m_InnerBorder._visible = true;
        
        SetItemShape( PLAIN );
        SetBackgroundColor( Colors.e_ColorItemTypeMissionUsable )
        SetStrokeColor( Colors.e_ColorBorderItemMissionUsable );
        SetDecoration( DECORATION_NONE  );
    }
    
    private function SetTypeWeapons()
    {
        m_Gloss._visible = false;
     //   m_InnerBorder._visible = false;
        
        SetItemShape( PLAIN );
     //   SetBackgroundColor( Colors.e_ColorItemTypeWeapons )
        SetDecoration( DECORATION_STRIPES  );
    }
    
    private function SetTypeChakras()
    {
        m_Gloss._visible = false;
      //  var backgroundColor:Number = Colors.e_ColorItemTypeChakras;
        
        switch(  m_InventoryItem.m_DefaultPosition )
        {
            case _global.Enums.ItemEquipLocation.e_Chakra_1:
                SetItemShape( CHAKRA1  );
            break;
            case _global.Enums.ItemEquipLocation.e_Chakra_2:
                SetItemShape( CHAKRA2  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_3:
                SetItemShape( CHAKRA3  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_4:
                SetItemShape( CHAKRA4  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_5:
                SetItemShape( CHAKRA5  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_6:
                SetItemShape( CHAKRA6  );
            break;
            
            case _global.Enums.ItemEquipLocation.e_Chakra_7:
                SetItemShape( CHAKRA7  );
      //          backgroundColor = Colors.e_ColorItemTypeCenterChakra;
            break;
        }
   //     SetBackgroundColor( backgroundColor );
        SetDecoration( DECORATION_NONE );
    }
	
    private function SetTypeConsumable()
    {
        m_Gloss._visible = true;
        m_Stroke._visible = false;
        
        SetItemShape( PLAIN );
     //   SetBackgroundColor( Colors.e_ColorItemTypeConsumable )
        SetDecoration( DECORATION_NONE  );
    }
    
    private function SetTypeNone()
    {
        m_Gloss._visible = false;
        m_Stroke._visible = false;
        
        SetItemShape( PLAIN );
        SetDecoration( DECORATION_NONE  );
    }
	
	public function UnloadIcon()
	{
		clearInterval( m_CooldownIntervalID );		
		m_IconLoader.unloadClip(m_Icon);
	}
    
    public function GetIcon(): MovieClip
    {
        return m_Icon;
    }
	
	public function SetCooldown( secondsRemaining:Number, showTimer:Boolean)
	{
		if (m_HasCooldown)
		{
			RemoveCooldown();
		}
		
		m_HasCooldown = true;
		
        m_Gloss._visible = false;
        
        m_TotalDuration = secondsRemaining;
        m_ExpireTime = com.GameInterface.Utils.GetGameTime() + m_TotalDuration;
              		
		if (showTimer)
		{
			m_CooldownTimer = attachMovie( "CooldownTimer", "cooldown", getNextHighestDepth() );
		}
		
		m_CooldownIntervalID = setInterval(this,  "UpdateTimer", m_Increments);
	}
	
    public function RemoveCooldown()
    {
		m_Gloss._visible = true;
        clearInterval( m_CooldownIntervalID );
		if (m_CooldownTimer != undefined)
		{
			m_CooldownTimer.removeMovieClip();
			m_CooldownTimer = undefined
		}
		m_HasCooldown = false;
		Colors.Tint(m_Background, 0x000000, 0);
		Colors.Tint(m_Icon, 0x000000, 0);
    }
	
	/// Method that updates
	private function UpdateTimer() : Void
	{
		var timeLeft:Number = m_ExpireTime - com.GameInterface.Utils.GetGameTime();

        if ( timeLeft > 0 )
        {
			if (m_TotalDuration > 0)
			{
				var percentage:Number = timeLeft / m_TotalDuration;
				var tint:Number = Math.round(10  + percentage * 80);
				if (tint != m_CooldownTint)
				{
					m_CooldownTint = tint;
				}
				Colors.Tint(m_Background, 0x000000, tint);
				Colors.Tint(m_Icon, 0x000000, tint);
			}
            if (m_CooldownTimer != undefined)
            {
				var hours:Number = Math.floor(timeLeft / 3600);
				var minutes:Number = Math.floor(timeLeft / 60 % 60);
				var seconds:Number = Math.floor(timeLeft) % 60;
				if (hours > 0)
				{
					m_CooldownTimer.ms_txt.text = com.Utils.Format.Printf( "%02.0f:%02.0f:%02.0f", hours, minutes, seconds);
				}
				else
				{
					m_CooldownTimer.ms_txt.text = com.Utils.Format.Printf( "%02.0f:%02.0f", minutes, seconds);
				}
            }
        }
        else
		{
            clearInterval( m_CooldownIntervalID );
			RemoveCooldown();
				
		}
	}    
}
