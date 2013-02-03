//Imports
import com.GameInterface.DistributedValue;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.InventoryItem;
import com.GameInterface.NeedGreed;
import com.GameInterface.Utils;
import com.Utils.GlobalSignal;
import com.Utils.ID32;

//Constants
var m_StaticCounter:Number = 0;
var m_WindowHeight:Number = 204;
var m_WindowOffset:Number = 50;
var m_WindowGap:Number = 20;

//Properties
var m_NeedGreedWindows:Object;
var m_ResolutionScaleMonitor:DistributedValue;
var m_Prompts:Array = new Array();

//On Load
function onLoad():Void
{
    m_NeedGreedWindows = new Object();
    
    m_ResolutionScaleMonitor = DistributedValue.Create( "GUIResolutionScale" );
    m_ResolutionScaleMonitor.SignalChanged.Connect( LayoutHandler, this );
    LayoutHandler();
    
    NeedGreed.SignalCreateNeedGreedWindow.Connect(SlotShowNeedGreedWindow, this);
    NeedGreed.SignalItemOffered.Connect(SlotItemOfferReceived, this);
    
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF( "GenericHideModule" );
	moduleIF.SignalStatusChanged.Connect( SlotHideModuleStateUpdated, this );
		
    NeedGreed.SignalCloseNeedGreedWindows.Connect(SlotCloseNeedGreedWindow, this);
    NeedGreed.SignalNeedGreedForItemFromClientChar.Connect(SlotCloseNeedGreedWindow, this);
    NeedGreed.CloseNonModuleControlledGui.Connect(SlotCloseNeedGreedWindow, this);
}

//Layout Handler
function LayoutHandler():Void
{
    var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
    _x = visibleRect.x;
    _y = visibleRect.y;
    /*
    var scale:Number = m_ResolutionScaleMonitor.GetValue();
    _xscale = scale * 100;
    _yscale = scale * 100;
    */
    
    for (var clipName:String in m_Prompts)
    {
        var clip:MovieClip = this[clipName];
        if (clip)
        {
            clip.CorrectPostion();
        }
    }
    
}

//Slot Show Need Greed Window
function SlotShowNeedGreedWindow(lootBagId:ID32, itemPos:Number, item:InventoryItem, timeout:Number):Void
{
	var key:String = lootBagId.toString() + "-" + itemPos;
    
    if ( m_NeedGreedWindows[key] == undefined )
    {
        var needGreedWindow = attachMovie("NeedGreedWindow", "i_NeedGreedWindow_" + UID(), getNextHighestDepth());
        needGreedWindow.UpdateData(lootBagId, itemPos, item, timeout);
        
        /*
         *  The following is some totally radical math, brought to you by German The Math Star!!!
         * 
         *  The Code will lay the first 3 windows below each other and all subsequent groups
         *  of 3 windows will be shifted both left and down by 50 pixels
         * 
         */
        
        var a:Number = m_StaticCounter % 3;
        var b:Number = Math.floor(m_StaticCounter / 3);
        
        m_StaticCounter++;
        
        needGreedWindow._x = 200 + b * m_WindowOffset;
        needGreedWindow._y = 200 + a * (m_WindowHeight + m_WindowGap) + b * m_WindowOffset;
        
        //needGreedWindow._xscale = 125;
        //needGreedWindow._yscale = 125;
        
        needGreedWindow.SignalWindowSelected.Connect(SlotNeedGreedWindowSelected, this);
        
        m_NeedGreedWindows[key] = needGreedWindow;
    }
}

//Slot Need Greed Windows Selected
function SlotNeedGreedWindowSelected(selectedWindow:MovieClip):Void
{
    selectedWindow.swapDepths(getNextHighestDepth() - 1);
}

//Slot Close Need Greed Window
function SlotCloseNeedGreedWindow():Void
{
	var numArgs:Number = arguments.length;
	
	if (numArgs == 0)  //Close All Windows
	{
        for ( var key in m_NeedGreedWindows )
        {
            m_NeedGreedWindows[key].Close();
            m_NeedGreedWindows[key] = undefined;
            
            m_StaticCounter--;
        }
	}
	else if (numArgs == 1)  //Close Matching
	{
		var lootBagId:ID32 = arguments[0];
        
        for ( var key in m_NeedGreedWindows )
        {
            if (key.substr(0, lootBagId.toString().length) == lootBagId.toString())
            {
                m_NeedGreedWindows[key].Close();
                m_NeedGreedWindows[key] = undefined;
                
                m_StaticCounter--;
            }
        }
	}
	else if (numArgs == 2)  //Close Matching
	{
		var lootBagId:ID32 = arguments[0];
		var itemPos:Number = arguments[1];
	    var key:String = lootBagId.toString() + "-" + itemPos;
        
        if (m_NeedGreedWindows[key] != undefined)
        {
            m_NeedGreedWindows[key].Close();
            m_NeedGreedWindows[key] = undefined;
            
            m_StaticCounter--;
        }
	}
	
	if (m_StaticCounter == 0)
	{
		m_NeedGreedWindows = new Object(); // reset this to avoid accumulating undefined keys
	}
}

function SlotItemOfferReceived(name:String, lootBagId:ID32, itemPosition:Number):Void
{
    var promptName:String = "acceptItemPromptWindow_" + itemPosition + "_" + lootBagId;
    var lootOfferPrompt:MovieClip = attachMovie("AcceptItemPromptWindow", promptName, getNextHighestDepth());
    lootOfferPrompt.SignalPromptResponse.Connect(SlotLootOfferPromptResponse, this);
    lootOfferPrompt._xscale = 125;
    lootOfferPrompt._yscale = 125;
    lootOfferPrompt.SetData(lootBagId, itemPosition);
    
    m_Prompts[promptName] = lootOfferPrompt;
}

function SlotLootOfferPromptResponse(acceptItem:Boolean, lootBagId:ID32, itemPosition:Number)
{
    var promptName:String = "acceptItemPromptWindow_" + itemPosition + "_" + lootBagId;
    m_Prompts[promptName] = undefined;
    NeedGreed.AcceptMasterLooterItem(lootBagId, itemPosition, acceptItem);
}

