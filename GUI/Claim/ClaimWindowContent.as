//Imports
import com.GameInterface.Claim;
import com.GameInterface.ClaimItemData;
import com.GameInterface.InventoryItem;
import com.GameInterface.ProjectUtils;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;
import gfx.controls.Button;
import gfx.core.UIComponent;
import GUI.Claim.SortButton;
import GUI.Claim.PromptWindow;
import com.Utils.Colors;
import com.Components.WindowComponentContent;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.InventoryItemList.MCLItemInventoryItem;

// Class
class GUI.Claim.ClaimWindowContent extends WindowComponentContent
{
    //Constnats
    private static var DELETE:String = LDBFormat.LDBGetText("GenericGUI", "Delete");
    private static var CLAIM:String = LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_claim");
    private static var CLAIM_ALL:String = LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_claimAll");
    private static var EXPIRE_NEVER:String = LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_ExpireNever");
    private static var EXPIRATION_DAYS:String = LDBFormat.LDBGetText("MiscGUI", "expirationDays");
    
    private static var SCROLL_WHEEL_SPEED:Number = 10;
    
    //Properties
    private var m_ClaimList:MultiColumnListView;
    
    private var m_ScrollBar:MovieClip;
    private var m_ItemsArray:Array;
    
    private var m_PromptWindow:MovieClip;
    private var m_ReponseTarget:MovieClip;
    
    private var m_DeleteButton:Button;
    private var m_ClaimButton:Button;
    private var m_ClaimAllButton:Button;
    
    private var m_SelectedID:Number;
    private var m_SortTarget:String;
    private var m_SortDirection:String;
    private var m_ScrollBarPosition:Number;
    
    //Constructor
    public function ClaimWindowContent()
    {
        super();
        
        _xscale = _yscale = 100;
    }
    
	//Configure UI
	private function configUI():Void
    {
        m_ClaimList.SetItemRenderer("ClaimItemRenderer");
        m_ClaimList.SetHeaderSpacing(3);
        m_ClaimList.SetShowBottomLine(true);
        m_ClaimList.SetScrollBar(m_ScrollBar);
        m_ClaimList.SignalItemClicked.Connect(SlotItemSelected, this);
        m_ClaimList.SignalSortClicked.Connect(SlotUnselectRows, this);
        m_ClaimList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ICON, LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_item"), 58, ColumnData.COLUMN_NON_RESIZEABLE);
        m_ClaimList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_NAME, LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_name"), 216, 0);
        m_ClaimList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_RECURRENT, LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_recurrent"), 115, 0);
        m_ClaimList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_EXPIRES, LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_expires"), 138, 0);
        m_ClaimList.AddColumn(MCLItemInventoryItem.INVENTORY_ITEM_COLUMN_ORIGIN, LDBFormat.LDBGetText("GenericGUI", "ClaimWindow_origin"), 216, 0);
        m_ClaimList.SetSize(762, 289);
        m_ClaimList.DisableRightClickSelection(false);
        
        m_ScrollBar._height = m_ClaimList._height;
        
        m_DeleteButton.label = DELETE;
        m_ClaimButton.label = CLAIM;
        m_ClaimAllButton.label = CLAIM_ALL;
        
        m_DeleteButton.textField.autoSize = m_ClaimButton.textField.autoSize = m_ClaimAllButton.textField.autoSize = "center";
        m_ClaimButton.disabled = true;
        m_DeleteButton.disabled = true;
        
        m_DeleteButton.addEventListener("click", this, "ResponseButtonEventHandler");
        m_ClaimButton.addEventListener("click", this, "ResponseButtonEventHandler");
        m_ClaimAllButton.addEventListener("click", this, "ResponseButtonEventHandler");
                
        m_ScrollBarPosition = 0;
    
        SlotClaimsUpdated();
        Claim.SignalClaimsUpdated.Connect(SlotClaimsUpdated, this);
        
        m_PromptWindow = attachMovie("PromptWindow", "m_PromptWindow", getNextHighestDepth());
        m_PromptWindow.SignalPromptResponse.Connect(SlotPromptResponse, this);
        
        m_DeleteButton._y -= 2;
        m_ClaimButton._y -= 2;
        m_ClaimAllButton._y -= 2;
    }
    
    //Slot Item Selected
    private function SlotItemSelected(index:Number):Void
    {
        m_SelectedID = m_ClaimList.GetItems()[index].GetId();
        m_ClaimButton.disabled = m_ClaimList.GetSelectedIndex() < 0
        m_DeleteButton.disabled = m_ClaimButton.disabled;
        
        if ( m_PromptWindow.IsVisible() )
        {
            m_PromptWindow.Hide();
        }
    }

    //Slot Sort Clicked
    private function SlotUnselectRows():Void
    {
        m_SelectedID = 0;
        m_ClaimList.ClearSelection();
        if ( m_PromptWindow.IsVisible() )
        {
            m_PromptWindow.Hide();
        }
    }
    
    //Slot Claims Updated
    private function SlotClaimsUpdated():Void
    {
        m_ClaimList.ClearSelection();
        m_ClaimList.RemoveAllItems();
        
        m_ItemsArray = new Array();        

        for (var i:Number = 0; i < Claim.m_Claims.length; i++)
        {
            var item:MCLItemInventoryItem = new MCLItemInventoryItem(Claim.m_Claims[i].m_InventoryItem, undefined);
            item.SetId(Claim.m_Claims[i].m_ID);
            item.m_Recurrent = Claim.m_Claims[i].m_MaxClaims == -1 || Claim.m_Claims[i].m_NumClaimsLeft <= 0 ? true:false;
            var expiration:Number = Claim.m_Claims[i].m_ExpireDate;
            if (expiration == 0)
            {
                item.m_Expires = EXPIRE_NEVER;
            }
            else
            {
                var currentTime:Number = Utils.GetServerSyncedTime();
                var expirationInDays:String  = Math.floor((result.m_ExpireDate-currentTime) / 86400) + " " + EXPIRATION_DAYS;
                item.m_Expires = expirationInDays.toString();
            }
            
            item.m_Origin = Claim.m_Claims[i].m_OriginDescription;
            
            m_ItemsArray.push(item);
        }
        
        m_ClaimAllButton.disabled = (Claim.m_Claims.length == 0);
        m_ClaimButton.disabled = true;
        m_DeleteButton.disabled = true;
        m_SelectedID = 0;
        
        m_ClaimList.AddItems(m_ItemsArray);
    }
        
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_DeleteButton:    m_PromptWindow.ShowPrompt(PromptWindow.DELETE_ACTION, m_SelectedID);
                                    break;
                                    
            case m_ClaimButton:     m_PromptWindow.ShowPrompt(PromptWindow.CLAIM_ACTION, m_SelectedID);
                                    break;
                                    
            case m_ClaimAllButton:  m_PromptWindow.ShowPrompt(PromptWindow.CLAIM_ALL_ACTION, m_SelectedID);
        }
        
        m_ReponseTarget = event.target;
        
        DisableMainWindow(true);
    }
    
    //Slot Prompt Response
    private function SlotPromptResponse(response:String, id:Number):Void
    {
        if (response == PromptWindow.RESPONSE_OK)
        {
            switch (m_ReponseTarget)
            {
                case m_DeleteButton:    Claim.DeleteClaimItem(id);
                                        break;
                                        
                case m_ClaimButton:     Claim.ClaimItem(id);
                                        break;
                                        
                case m_ClaimAllButton:  Claim.ClaimAllItems();
            }
            m_SelectedID = 0;
            m_ClaimList.ClearSelection();
        }
        
        DisableMainWindow(false);
    }
    
    //Disable Main Window
    private function DisableMainWindow(value:Boolean):Void
    {
        Selection.setFocus(null);
        /*
        var selectableObjects:Array = m_ClaimRowsArray.concat(m_SortButtonArray);
        
        for (var i:Number = 0; i < selectableObjects.length; i++)
        {
            selectableObjects[i].enabled = !value;
        }
        */
        var isThereSelection:Boolean = (m_SelectedID != undefined) && (m_SelectedID > 0);
        
        m_DeleteButton.disabled = m_ClaimButton.disabled = (value || !isThereSelection);
        m_ClaimAllButton.disabled = value || (Claim.m_Claims.length == 0);
    }
}

