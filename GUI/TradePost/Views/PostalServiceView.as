//Imports
import com.Components.ItemSlot;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tradepost;
import com.GameInterface.MailData;
import com.GameInterface.ItemPrice;
import com.GameInterface.ProjectUtils;
import com.GameInterface.InventoryItem;
import com.GameInterface.Utils;
import com.Utils.LDBFormat;
import com.Utils.ID32;
import GUI.TradePost.Views.SortButton;
import GUI.TradePost.Views.PromptWindow;
import mx.utils.Delegate;
import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.controls.ScrollBar;
import com.Components.MultiColumnListView;
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;
import com.Utils.Format;

//Class
class GUI.TradePost.Views.PostalServiceView extends UIComponent
{
    //Constants
    private static var HEADER_BUTTONS_GAP:Number = 4;
    private static var SCROLL_WHEEL_SPEED:Number = 10;
    private static var DRAG_PADDING:Number = 40;
    private static var COLUMN_ATTACHMENTS:Number = 0;
    private static var COLUMN_FROM:Number = 1;
    private static var COLUMN_DATE:Number = 2;
    private static var COLUMN_EXPIRES:Number = 3;
    private static var COLUMN_SUBJECT:Number = 4;
    private static var DEFAULT_MAIL_BODY_TEXT_HEIGHT:Number = 139;
    private static var DEFAULT_MAIL_BODY_TEXT_WIDTH:Number = 575;
    
    private static var RECEIVED_MAIL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ReceivedMail");
    private static var COMPOSE_LETTER:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ComposeLetter");
    private static var DELETE_MAIL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_DeleteMail");
    private static var TAKE_ALL_ATTACHMENTS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_TakeAllAttachments");
    private static var REPLY:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Reply");
    private static var TO:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ToColon");
    private static var SEND:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Send");
    private static var EXPIRATION_DAYS:String = LDBFormat.LDBGetText("MiscGUI", "expirationDays");
    
    //Properties
    private var m_ReceivedMailHeader:MovieClip;
    private var m_ComposeLetterButton:MovieClip;
    
    private var m_ListScrollBar:ScrollBar;
    private var m_MailScrollBar:MovieClip;
    private var m_ScrollBarPosition:Number;
    
    private var m_ReadMailHeader:MovieClip;
    private var m_DeleteMailButton:MovieClip;
    private var m_TakeAllAttachmentsButton:MovieClip;
    private var m_ReadMailBody:MovieClip;
    
    private var m_MailList:MultiColumnListView;
    private var m_ReplyButton:Button;
    
    private var m_SelectedID:Number;
    private var m_SelectedIndex:Number;
    private var m_ConfirmDeleteMailPrompt:MovieClip;
    
    private var m_AttachmentItemSlots:Array;
    private var m_ItemIds:Array;
    
    private var m_DefaultButtonWidth:Number;
    private var m_CheckInterval:Number;
    
    
    //Constructor
    public function PostalServiceView()
    {
        super();
        
        var mouseListener:Object = new Object();
		mouseListener.onMouseWheel = Delegate.create(this, MouseWheelEventHandler);
		Mouse.addListener(mouseListener);
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_ReceivedMailHeader.m_Title.text = RECEIVED_MAIL;
        
        m_MailList.SetItemRenderer("MailItemRenderer");
        m_MailList.SetHeaderSpacing(3);
        m_MailList.SetShowBottomLine(true);
        m_MailList.SetScrollBar(m_ListScrollBar);
        m_MailList.SignalItemClicked.Connect(SlotItemClicked, this);
        m_MailList.SignalSortClicked.Connect(SlotSortClicked, this);
        
        m_MailList.AddColumn(COLUMN_ATTACHMENTS, "", 38, ColumnData.COLUMN_NON_RESIZEABLE | ColumnData.COLUMN_HIDE_LABEL);
        m_MailList.AddColumn(COLUMN_FROM, LDBFormat.LDBGetText("MiscGUI", "TradePost_From"), 188, 0);
        m_MailList.AddColumn(COLUMN_DATE, LDBFormat.LDBGetText("MiscGUI", "TradePost_DateTime"), 188, 0);
        m_MailList.AddColumn(COLUMN_EXPIRES, LDBFormat.LDBGetText("MiscGUI", "TradePost_Expires"), 116, 0);
        m_MailList.AddColumn(COLUMN_SUBJECT, LDBFormat.LDBGetText("MiscGUI", "TradePost_Letter"), 222, 0);
        m_MailList.SetSize(760, 273);
        m_MailList.SetSecondarySortColumn(COLUMN_EXPIRES);

        m_ScrollBarPosition = 0;
        m_SelectedIndex = -1;
        m_ListScrollBar._height = m_MailList._height - 10;
        
        m_SelectedID = 0;
        
        m_ItemIds = new Array();
        m_AttachmentItemSlots = new Array();
        
        CreateEmptySlots();
        
        m_ReplyButton.textField.autoSize = "center";
        m_ReplyButton.label = REPLY;
        m_ReplyButton.disabled = true;
        m_ReplyButton.disableFocus = true;
        m_ReplyButton.addEventListener("click", this, "ButtonClickHandler");
        
        m_ReadMailBody.m_BodyTextContainer.m_BodyText.autoSize = "left";
        ProjectUtils.SetMovieClipMask(m_ReadMailBody.m_BodyTextContainer, null, DEFAULT_MAIL_BODY_TEXT_HEIGHT, m_ReadMailBody.m_BodyTextContainer._width);
        
        Tradepost.SignalNewMail.Connect(SlotNewMail, this);
        Tradepost.SignalMailUpdated.Connect(SlotMailUpdate, this);
        Tradepost.SignalMailDeleted.Connect(SlotMailDelete,this);
        
        m_ConfirmDeleteMailPrompt = attachMovie("ConfirmDeleteMailPromptWindow", "m_ConfirmDeleteMailPrompt", getNextHighestDepth());
        m_ConfirmDeleteMailPrompt.SignalPromptResponse.Connect(SlotConfirmDeleteMailPromptResponse, this);
        
       /*
        *  Tragedy strikes!
        * 
        *  Overriding UIComponent() doesn't work, so here I will employ a super ghetto interval check before calling the Layout
        *  function so the precious component can have its beauty sleep before updating its width after the auto-sizing
        *  label has been assigned.
        * 
        */
        
        m_ComposeLetterButton = m_ReceivedMailHeader.attachMovie("ComposeLetterButton", "m_ComposeLetterButton", m_ReceivedMailHeader.getNextHighestDepth());
        m_DefaultButtonWidth = m_ComposeLetterButton._width;
        m_ComposeLetterButton.textField.autoSize = "left";
        m_ComposeLetterButton.label = COMPOSE_LETTER;
        
        m_TakeAllAttachmentsButton = m_ReadMailHeader.attachMovie("TakeAllAttachmentsButton", "m_TakeAllAttachmentsButton", m_ReadMailHeader.getNextHighestDepth());
        m_TakeAllAttachmentsButton.autoSize = "left";
        m_TakeAllAttachmentsButton.label = TAKE_ALL_ATTACHMENTS;
        
        m_DeleteMailButton = m_ReadMailHeader.attachMovie("DeleteMailButton", "m_DeleteMailButton", m_ReadMailHeader.getNextHighestDepth());
        m_DeleteMailButton.autoSize = "left";
        m_DeleteMailButton.label = DELETE_MAIL;
                
        m_CheckInterval = setInterval(CheckButtonResize, 20, this);
        
        UpdateMailView();
        
        _parent.SignalViewChanged.Connect(HidePromptIfVisible, this);
    }
    
    //Check Button Resize
    private function CheckButtonResize(scope:Object):Void
    {
        if (scope.m_ComposeLetterButton._width != m_DefaultButtonWidth)
        {
            clearInterval(scope.m_CheckInterval);
            scope.LayoutButtons();
        }
    }
    
    //Layout Buttons
    private function LayoutButtons():Void
    {
        m_ComposeLetterButton._y = 2;
        m_ComposeLetterButton._x = m_ReceivedMailHeader._x + m_ReceivedMailHeader._width - m_ComposeLetterButton._width - HEADER_BUTTONS_GAP;
        m_ComposeLetterButton.disableFocus = true;
        m_ComposeLetterButton.addEventListener("click", this, "ButtonClickHandler");
        
        m_TakeAllAttachmentsButton._y = 2;
        m_TakeAllAttachmentsButton._x = m_ReadMailHeader._x + m_ReadMailHeader._width - m_TakeAllAttachmentsButton._width - HEADER_BUTTONS_GAP;
        m_TakeAllAttachmentsButton.disabled = true;
        m_TakeAllAttachmentsButton.disableFocus = true;
        m_TakeAllAttachmentsButton.addEventListener("click", this, "ButtonClickHandler");
        
        m_DeleteMailButton._y = 2;
        m_DeleteMailButton._x = m_TakeAllAttachmentsButton._x - m_DeleteMailButton._width - HEADER_BUTTONS_GAP;
        m_DeleteMailButton.disabled = true;
        m_DeleteMailButton.disableFocus = true;
        m_DeleteMailButton.addEventListener("click", this, "ButtonClickHandler");
    }
    
    //Slot Item Clicked
    private function SlotItemClicked(index:Number, buttonIndex:Number):Void
    {
        if ( buttonIndex == 1)
        {
            m_SelectedIndex = index;
            SelectMailListIndex(m_SelectedIndex);
            
            HidePromptIfVisible();
        }
    }
    
    //Hide Prompt If Visible
    private function HidePromptIfVisible():Void
    {
        if (m_ConfirmDeleteMailPrompt._visible)
        {
            m_ConfirmDeleteMailPrompt._visible = false;
        }
    }
    
    //Button Click Handler
    private function ButtonClickHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_ComposeLetterButton:         Tradepost.OpenComposeMail();
                                                HidePromptIfVisible();
                                                
                                                break;
                                            
            case m_DeleteMailButton:            var mail:MailData = Tradepost.m_Mail[Format.Printf("%.20llu", m_SelectedID)];
                                                var hasAttachments:Boolean = mail.m_HasItems || mail.m_Money > 0;
                                                m_ConfirmDeleteMailPrompt.ShowPrompt(hasAttachments);
                                                
                                                break;
            
            case m_TakeAllAttachmentsButton:    Tradepost.GetMailItems(m_SelectedID);
                                                HidePromptIfVisible();
                                                
                                                break;
            
            case m_ReplyButton:                 var mail:MailData = Tradepost.m_Mail[Format.Printf("%.20llu", m_SelectedID)];
                                                
                                                if ( m_SelectedID != 0 && mail != undefined )
                                                {
                                                    DistributedValue.AddVariable("compose_mail_reply_to", mail.m_SenderName, false);
                                                }
                                                
                                                DistributedValue.SetDValue("compose_mail_window", true);
                                                HidePromptIfVisible();
                                                
                                                break;
        }
    }
    
    //Slot Confirm Delete Mail Prompt Response
    private function SlotConfirmDeleteMailPromptResponse():Void
    {
        ClearShowMail();
        Tradepost.DeleteMail(m_SelectedID);
    }
    
    //Select Mail List Index
    private function SelectMailListIndex(index:Number):Void
    {
        var mailID:Number = m_MailList.GetItems()[m_SelectedIndex].GetId();
        SlotSelectedRow(mailID); 
    }
    
    private function CreateEmptySlots()
    {
        if ( m_AttachmentItemSlots.length == 0 )
        {
            var slot1:ItemSlot = new ItemSlot(undefined, undefined, m_ReadMailBody.m_MailAttachments.m_Slot1.m_Content, undefined);
            var slot2:ItemSlot = new ItemSlot(undefined, undefined, m_ReadMailBody.m_MailAttachments.m_Slot2.m_Content, undefined);
            var slot3:ItemSlot = new ItemSlot(undefined, undefined, m_ReadMailBody.m_MailAttachments.m_Slot3.m_Content, undefined);
            var slot4:ItemSlot = new ItemSlot(undefined, undefined, m_ReadMailBody.m_MailAttachments.m_Slot4.m_Content, undefined);
            var slot5:ItemSlot = new ItemSlot(undefined, undefined, m_ReadMailBody.m_MailAttachments.m_Slot5.m_Content, undefined);
            var slot6:ItemSlot = new ItemSlot(undefined, undefined, m_ReadMailBody.m_MailAttachments.m_Slot6.m_Content, undefined);

            m_AttachmentItemSlots.push(slot1);
            m_AttachmentItemSlots.push(slot2);
            m_AttachmentItemSlots.push(slot3);
            m_AttachmentItemSlots.push(slot4);
            m_AttachmentItemSlots.push(slot5);
            m_AttachmentItemSlots.push(slot6);
            
            slot1.SignalMouseDown.Connect(SlotMouseDownItem, this);
            slot1.SignalMouseUp.Connect(SlotMouseUpItem, this);
            slot2.SignalMouseDown.Connect(SlotMouseDownItem, this);
            slot2.SignalMouseUp.Connect(SlotMouseUpItem, this);
            slot3.SignalMouseDown.Connect(SlotMouseDownItem, this);
            slot3.SignalMouseUp.Connect(SlotMouseUpItem, this);
            slot4.SignalMouseDown.Connect(SlotMouseDownItem, this);
            slot4.SignalMouseUp.Connect(SlotMouseUpItem, this);
            slot5.SignalMouseDown.Connect(SlotMouseDownItem, this);
            slot5.SignalMouseUp.Connect(SlotMouseUpItem, this);
            slot6.SignalMouseDown.Connect(SlotMouseDownItem, this);
            slot6.SignalMouseUp.Connect(SlotMouseUpItem, this);
        }
    }

    function SlotMouseDownItem(itemSlot:ItemSlot, buttonIndex:Number, clickCount:Number)
    {
        if (clickCount == 2 && buttonIndex == 1)
        {
            UseAttachedItem(itemSlot);
        }
    }

    function SlotMouseUpItem(itemSlot:ItemSlot, buttonIndex:Number)
    {
        if (buttonIndex == 2 && !Key.isDown(Key.CONTROL))
        {
            UseAttachedItem(itemSlot);
        }
    }

    function UseAttachedItem(slot:ItemSlot)
    {
        var slotId:Number = GetMouseSlotID();
        if ( slotId >= 0 && m_ItemIds[slotId] > 0 )
        {
            Tradepost.GetMailItem( m_SelectedID, m_ItemIds[slotId]);
            m_ItemIds[slotId] = 0;
            slot.Clear();
        }
        
        var mail:MailData = Tradepost.m_Mail[Format.Printf("%.20llu", m_SelectedID)];
        
        m_TakeAllAttachmentsButton.disabled = false;
        for (var i:Number = 0; i < m_ItemIds.length; ++i )
        {
            if ( m_ItemIds[i] > 0 && mail.m_Money == 0 )
            {
                m_TakeAllAttachmentsButton.disabled = true;
                break;
            }
        }
    }
    
    private function ClearAttachedItems() : Void
    {
        m_ItemIds = new Array();
        
        for( var i:Number = 0; i < m_AttachmentItemSlots.length; ++i )
        {
            if ( m_AttachmentItemSlots[i] != undefined )
            {
                ItemSlot(m_AttachmentItemSlots[i]).Clear();
            }
        }
    }
    
    private function SlotNewMail(mailId:Number):Void
    {
        AddMailToList(mailId);
        UpdateMailView();
    }
    
    private function SlotMailUpdate(mailId:Number):Void
    {
        var hasItem:Boolean = m_MailList.HasItemById(mailId);
        
        AddMailToList(mailId);
        
        if (!hasItem)
        {
            UpdateMailView();
        }
        
        if (mailId == m_SelectedID)
        {
            SlotSelectedRow(mailId)
        }
    }
    
    private function SlotMailDelete(mailId:Number):Void
    {
        var deletedIndex:Number = m_MailList.GetIndexById(mailId);
        
        m_MailList.RemoveItemById(mailId);
        
        UpdateMailView();
        
        if (deletedIndex == m_SelectedIndex)
        {
            if (m_SelectedIndex >= m_MailList.GetItems().length )
            {
                m_SelectedIndex -= 1;
            }
            
            if (m_MailList.GetItems()[m_SelectedIndex] != undefined)
            {
                m_MailList.SetSelection(m_SelectedIndex);
            }
            else
            {
                m_SelectedIndex = -1;
                m_SelectedID = 0;
            }
        }
    }
    
    private function AddMailToList(mailId:Number):Void
    {
        var mail:MailData = Tradepost.m_Mail[Format.Printf("%.20llu", mailId)];
        if ( mail != undefined )
        {
            var mailItem:MCLItemDefault = new MCLItemDefault(mail.m_MailId);
            var textColor:Number = (mail.m_IsRead) ? 0x999999 : 0xFFFFFF;
            
            var attachmentValueData:MCLItemValueData = new MCLItemValueData();
            if (mail.m_HasItems || mail.m_Money!=0)
            {
                attachmentValueData.m_MovieClipName = "AttachmentIcon";
                attachmentValueData.m_MovieClipWidth = 30;
                attachmentValueData.m_Number = -mail.m_TimeOut; //For icon sorting
            }
            else //For icon sorting
            {
                attachmentValueData.m_MovieClipName = "NoAttachmentIcon";
                attachmentValueData.m_MovieClipWidth = 30;
                attachmentValueData.m_Number = 0; 
            }
            mailItem.SetValue(COLUMN_ATTACHMENTS, attachmentValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_SYMBOL);

            var fromValueData:MCLItemValueData = new MCLItemValueData();
            fromValueData.m_Text = mail.m_SenderName;
            fromValueData.m_TextColor = textColor;
            mailItem.SetValue(COLUMN_FROM, fromValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);

            var sentValueData:MCLItemValueData = new MCLItemValueData();
            var date:Date = new Date(mail.m_SendTime*1000);
            sentValueData.m_Text = date.getDate() + " " +LDBFormat.LDBGetText("Months", date.getMonth()) + " " + date.getFullYear() + ", " + date.getHours() + ":" + PrefixZeroToMinutesCheck(date.getMinutes());
            sentValueData.m_TextColor = textColor;
            sentValueData.m_Number = mail.m_SendTime;
            mailItem.SetValue(COLUMN_DATE, sentValueData, MCLItemDefault.LIST_ITEMTYPE_STRING_SORT_BY_NUMBER);
            
            var expiredValueData:MCLItemValueData = new MCLItemValueData();
            var expirationInDays:String =  (Math.round( mail.m_TimeLeft / 86400)).toString() + " " + EXPIRATION_DAYS;
            expiredValueData.m_Text = expirationInDays;
            expiredValueData.m_TextColor = textColor;
            expiredValueData.m_Number = mail.m_TimeOut;
            mailItem.SetValue(COLUMN_EXPIRES, expiredValueData, MCLItemDefault.LIST_ITEMTYPE_STRING_SORT_BY_NUMBER);
            
            var subjectValueData:MCLItemValueData = new MCLItemValueData();
            subjectValueData.m_Text = GetTextSummary(mail.m_MessageBody);
            subjectValueData.m_TextColor = textColor;
            mailItem.SetValue(COLUMN_SUBJECT, subjectValueData, MCLItemDefault.LIST_ITEMTYPE_STRING);

            m_MailList.SetItem(mailItem);
        }
    }
    
    private function UpdateMailView():Void
    {
        var sortColumn:Number = m_MailList.GetSortColumn();
        var sortDirection:Number = m_MailList.GetSortDirection();
        if ( sortColumn < 0)
        {
            sortColumn = COLUMN_DATE;
            sortDirection = Array.DESCENDING;
        }
        if (sortDirection != undefined)
        {
            m_MailList.SetSortDirection(sortDirection);
        }
        m_MailList.SetSortColumn(sortColumn);
        m_MailList.Resort();
        m_MailList.DrawItemRenderers();

        m_ReplyButton.disabled = true;
        
        if (m_MailList.HasItemById(m_SelectedID))
        {
            SlotSelectedRow(m_SelectedID);
            
            m_ReplyButton.disabled = Tradepost.m_Mail[Format.Printf("%.20llu", m_SelectedID)].m_IsSendByTradepost;
        }
        else
        {
            UnSelectRows();
        }
    }
    
    function GetTextSummary(text:String) :String
    {
        //Take the first line only, and translate if it is a text coming from tradepost
        var formatedText:String = LDBFormat.Translate(text).split('\n')[0].split('\r')[0]; 
        return formatedText;
    }
    
    //Prefix Zero To Minutes
    private function PrefixZeroToMinutesCheck(value:Number):String
    {
        return (value < 10) ? "0" + value.toString() : value.toString();
    }
    
    //Slot Selected Row
    private function SlotSelectedRow(ID:Number):Void
    {
        var mail:MailData = Tradepost.m_Mail[Format.Printf("%.20llu", ID)];
        if ( mail != undefined )
        {
            m_SelectedID = ID;
            
            if (!mail.m_IsRead)
            {
                Tradepost.m_Mail[Format.Printf("%.20llu", ID)].m_IsRead = true; //Server is not sending update signal
                Tradepost.MarkAsRead(m_SelectedID);
            }
            
            m_ReadMailHeader.m_Title.text =  mail.m_SenderName;
                        
            m_ReadMailBody.m_BodyTextContainer.m_BodyText.htmlText = LDBFormat.Translate(mail.m_MessageBody).split('\r\n').join('\r');
            m_ReadMailBody.m_MailAttachments.m_Cash.m_Label.text = mail.m_Money;
            
            if ( m_MailScrollBar != undefined )
            {
                m_MailScrollBar.removeMovieClip();
                m_MailScrollBar = undefined;
            }
            
            if (m_ReadMailBody.m_BodyTextContainer.m_BodyText._height > DEFAULT_MAIL_BODY_TEXT_HEIGHT)
            {
                m_ReadMailBody.m_BodyTextContainer.m_BodyText._width = DEFAULT_MAIL_BODY_TEXT_WIDTH - 10; //Make some room for the scrollbar
                
                m_MailScrollBar = m_ReadMailBody.m_BodyTextContainer.attachMovie("ScrollBar", "m_MailScrollBar", m_ReadMailBody.m_BodyTextContainer.getNextHighestDepth());
                m_MailScrollBar._x = m_ReadMailBody.m_BodyTextContainer._x + m_ReadMailBody.m_BodyTextContainer._width - 10; 
                m_MailScrollBar._y = m_ReadMailBody.m_BodyTextContainer._y - 12;
                m_MailScrollBar._visible = true;
                m_MailScrollBar.setScrollProperties(m_ReadMailBody.m_BodyTextContainer._height, 0, m_ReadMailBody.m_BodyTextContainer._height - DEFAULT_MAIL_BODY_TEXT_HEIGHT); 
                m_MailScrollBar._height = DEFAULT_MAIL_BODY_TEXT_HEIGHT + 11;
                m_MailScrollBar.addEventListener("scroll", this, "OnScrollbarUpdate");
                m_MailScrollBar.position = m_ScrollBarPosition = 0;
                m_MailScrollBar.trackMode = "scrollPage";
            }
 
            m_DeleteMailButton.disabled = false;
            m_TakeAllAttachmentsButton.disabled = false;
            
            m_ReplyButton.disabled = mail.m_IsSendByTradepost;
            
            ClearAttachedItems();
            
            for ( var jKey:String in mail.m_Items )
            {
                var item:InventoryItem = mail.m_Items[jKey];
                var slot:ItemSlot = GetFirstEmptyItmeSlot();
                slot.SetData(item);
                slot.SetPos(5,5);
                
                m_ItemIds.push(jKey);
            }
            m_TakeAllAttachmentsButton.disabled = !(mail.m_HasItems) && (mail.m_Money == 0);
        }
    }
    
    private function ClearShowMail():Void
    {
        m_ReadMailHeader.m_Title.text =  "";

        if (m_MailScrollBar)
        {
            m_MailScrollBar.removeMovieClip();
            m_MailScrollBar = null;
        }
        
        m_DeleteMailButton.disabled = true;
        
        m_ReadMailBody.m_BodyTextContainer.m_BodyText.htmlText = "";
        m_ReadMailBody.m_MailAttachments.m_Cash.m_Label.text = "";
        
        ClearAttachedItems();
    }
    
    private function GetFirstEmptyItmeSlot() : ItemSlot
    {
        return m_AttachmentItemSlots[m_ItemIds.length];
    }
    
    //Get Mouse Slot ID
    function GetMouseSlotID():Number
    {
        for( var i:Number = 0; i < m_AttachmentItemSlots.length; ++i )
        {
            if( m_AttachmentItemSlots[i].GetSlotMC().hitTest(_root._xmouse, _root._ymouse) ) return i;
        }
        
        return -1;
    }
    
    //On Scroll Bar Update
    private function OnScrollbarUpdate(event:Object):Void
    {
        var target:MovieClip = event.target;
        var pos:Number = event.target.position;
        
        m_ReadMailBody.m_BodyTextContainer.m_BodyText._y = m_ReadMailBody.m_BodyTextContainer._y - pos;
        
        Selection.setFocus(null);
    }
    
    //Mouse Wheel Event handler
    private function MouseWheelEventHandler(delta:Number):Void
    {
        if (m_ReadMailBody.m_BodyTextContainer.hitTest(_root._xmouse, _root._ymouse, true) && m_MailScrollBar)
        {
            var newPos:Number = m_MailScrollBar.position + -(delta * SCROLL_WHEEL_SPEED);
            var event:Object = {target: m_MailScrollBar};
            
            m_MailScrollBar.position = Math.min(Math.max(0.0, newPos), m_MailScrollBar.maxPosition);
            
            OnScrollbarUpdate(event);
        }
    }
    
    //Slot Sort Clicked
    private function SlotSortClicked():Void
    {
        m_MailList.SetSelectionById(m_SelectedID);
    }
    
    //Unselect Rows
    private function UnSelectRows():Void
    {
        m_SelectedID = 0;
        m_MailList.ClearSelection();
        ClearShowMail();
    }
}