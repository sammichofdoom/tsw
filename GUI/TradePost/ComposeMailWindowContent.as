//Imports
import com.Utils.LDBFormat;
import com.Utils.ID32;
import com.Utils.Signal;
import mx.utils.Delegate;
import com.GameInterface.Tradepost;
import com.GameInterface.Game.Character;
import com.Utils.DragObject;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.DistributedValue;
import com.Components.ItemSlot;
import com.Components.WindowComponentContent;
import GUI.TradePost.ItemCounter;
import GUI.TradePost.ComposeMailFriendsList;
import gfx.controls.Button;
import gfx.controls.TextInput;
import gfx.controls.TextArea;
import com.GameInterface.Friends;
import com.GameInterface.Guild.GuildBase;
import com.Components.FCButton;

//Class
class GUI.TradePost.ComposeMailWindowContent extends WindowComponentContent
{
    //Constants
    private static var MAX_EMAIL_CHARACTERS:Number = 3000;
    private static var HEADER_BUTTONS_GAP:Number = 4;
    
    private static var TO_LABEL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ToLabel");
    private static var MESSAGE_LABEL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_MessageLabel");
    private static var ATTACHMENTS_LABEL:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_AttachmentsLabel");
    private static var ERROR_SENDING_MAIL_MESSAGE:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_ErrorSendingMail");
    private static var SEND_MAIL_SUCCESS:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_SendMailSuccess");
    private static var ERROR_ATTACHING_TO_MAIL:String = LDBFormat.LDBGetText("Tradepost", "AttachItemToMailError_ItemCanNotBeMailed");
    private static var SEND:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_Send");
    private static var ATTACH_MONEY:String = LDBFormat.LDBGetText("MiscGUI", "TradePost_AttachMoney");
    private static var FRIENDS_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("Tradepost", "composeMailFriendRecipientTooltip");
    private static var CABAL_BUTTON_TOOLTIP:String = LDBFormat.LDBGetText("Tradepost", "composeMailGuildMemberRecipientTooltip");
    
    //Properties
    public var SignalCloseWindow:Signal;
    
    private var m_ToLabel:MovieClip;
    private var m_ToInput:TextInput;
    private var m_FriendsButton:FCButton;
    private var m_CabalButton:FCButton;
    private var m_BodyLabel:MovieClip;
    private var m_BodyInput:TextArea;
    private var m_AttachmentsLabel:MovieClip;
    private var m_MailAttachments:MovieClip;
    private var m_SendButton:MovieClip;
    private var m_FriendsList:MovieClip;
    
    private var m_AttachmentSlots:Array;
    private var m_BankID:ID32;
    private var m_BankInventory:Inventory;
    
    private var m_KeyListener:Object;
    
    //Constructor
    public function ComposeMailWindowContent()
    {
        super();
        
        SignalCloseWindow = new Signal();
		
        var keylistener:Object = new Object();
        keylistener.onKeyUp = Delegate.create(this, KeyUpEventHandler);
        Key.addListener(keylistener);
    }
    
    //Config UI
    private function configUI():Void 
    {
        super.configUI();
        
        m_ToLabel.text = TO_LABEL;
        m_BodyLabel.text = MESSAGE_LABEL;
        m_AttachmentsLabel.text = ATTACHMENTS_LABEL;
        
        m_ToInput.addEventListener("textChange", this, "UpdateSendButtonState");
        m_ToInput.textField.restrict = "0-9a-zA-ZàáâäåÀÁÂÃæÆçÇêéëèÊËÉÈïíîìÍÌÎÏñÑœŒôöòõóøÓÔÕØÖÒšŠúüûùÙÚÜÛÿŸýÝžŽ\\-"; //Character nicknames may only contain letters, numbers and hyphens.
        m_ToInput.maxChars = 40;
        
        m_FriendsButton.disabled = (Friends.GetTotalFriends() == 0) ? true : false;
        m_FriendsButton.disableFocus = true;
        m_FriendsButton.addEventListener("click", this, "ButtonClickHandler");
        m_FriendsButton.SetTooltipText(FRIENDS_BUTTON_TOOLTIP);
        
        m_CabalButton.disabled = (!GuildBase.HasGuild()) ? true : false;
        m_CabalButton.disableFocus = true;
        m_CabalButton.addEventListener("click", this, "ButtonClickHandler");
        m_CabalButton.SetTooltipText(CABAL_BUTTON_TOOLTIP);
        
        m_BodyInput.addEventListener("textChange", this, "UpdateSendButtonState");
        m_BodyInput.maxChars = MAX_EMAIL_CHARACTERS;
        
        m_AttachmentSlots = new Array();
        m_BankID = new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_BankContainer, Character.GetClientCharID().GetInstance());
        m_BankInventory = new Inventory(m_BankID);
        m_MailAttachments.m_ItemCounter.icon = "PaxRomana";
        m_MailAttachments.m_ItemCounter.ShowBackground(false);
        m_MailAttachments.m_ItemCounter.minAmount = 0;
        m_MailAttachments.m_ItemCounter.maxAmount = ItemCounter.MAX_VALUE;
      
        m_SendButton.textField.autoSize = "center";
        m_SendButton.label = SEND;
        m_SendButton.disabled = true;
        m_SendButton.disableFocus = true;
        m_SendButton.addEventListener("click", this, "ButtonClickHandler");
        
        m_MailAttachments.disableFocus = true;
        m_MailAttachments.m_ItemCounter.disableFocus = true;
        m_MailAttachments.m_ItemCounter.m_TextInput.disableFocus = true;
        m_MailAttachments.m_ItemCounter.maxAmount = ItemCounter.MAX_VALUE;
        m_MailAttachments.m_ItemCounter.SignalValueChanged.Connect(UpdateSendButtonState, this);
        
        InitializeAttachments();
        UpdateAttachments();        
        
        Tradepost.SignalMailItemAttached.Connect(AttachItemIconToMail, this);
        Tradepost.SignalMailItemDetached.Connect(DetachItemIconFromMail, this);
        
        gfx.managers.DragManager.instance.addEventListener( "dragEnd", this, "onDragEnd" );
        
        if ( DistributedValue.DoesVariableExist("compose_mail_reply_to") )
        {
            var replyTo:String = DistributedValue.GetDValue("compose_mail_reply_to");
            DistributedValue.DeleteVariable("compose_mail_reply_to");
            m_ToInput.text = replyTo;
        }
        
        m_FriendsList = attachMovie("FriendsList", "m_FriendsList", getNextHighestDepth());
        m_FriendsList.SignalButtonResponse.Connect(SlotFriendsListResponse, this);
        m_FriendsList._x = width / 2 - m_FriendsList._width / 2;
        m_FriendsList._y = height / 2 - m_FriendsList._height / 2;
        
        SelectToInputField();
    }
    
    //On Unload
    private function onUnload():Void
    {
        ClearAttachments();
        Key.removeListener(m_KeyListener);
        Tradepost.CancelComposeMail();
    }
    
    //Initialize Attachments
    private function InitializeAttachments():Void
    {
        InitializeSlot(1, m_MailAttachments.m_Slot1);
        InitializeSlot(2, m_MailAttachments.m_Slot2);
        InitializeSlot(3, m_MailAttachments.m_Slot3);
        InitializeSlot(4, m_MailAttachments.m_Slot4);
        InitializeSlot(5, m_MailAttachments.m_Slot5);
        InitializeSlot(6, m_MailAttachments.m_Slot6);
    }
    
    //Slot Friends List Response
    private function SlotFriendsListResponse(selectedName:String):Void
    {
        if (selectedName)
        {
            m_ToInput.text = selectedName;
        }
        
        DisableControls(false);
        SelectToInputField();
    }
    
    //Initialize Slot
    function InitializeSlot(itemPos:Number, emptyClip:MovieClip):Void
    {
        var itemSlot:ItemSlot = new ItemSlot(m_BankID, undefined, emptyClip.m_Content);
        
        emptyClip.m_Content._x = 6;
        emptyClip.m_Content._y = 6;
        m_AttachmentSlots[itemPos] = itemSlot;
        itemSlot.SignalMouseDown.Connect(SlotMouseDownItem, this);
        itemSlot.SignalMouseUp.Connect(SlotMouseUpItem, this);
        itemSlot.SignalStartDrag.Connect(onDragBegin, this);
    }
	
    //Slot Mouse Down Item
	function SlotMouseDownItem(itemSlot:ItemSlot, buttonIndex:Number, clickCount:Number):Void
	{
		if (clickCount == 2 && buttonIndex == 1)
		{
			SlotRemoveAttachment(itemSlot);
		}
	}

    //Slot Mouse Up Item
	function SlotMouseUpItem(itemSlot:ItemSlot, buttonIndex:Number):Void
	{
		if (buttonIndex == 2 && !Key.isDown(Key.CONTROL))
		{
			SlotRemoveAttachment(itemSlot);
		}
	}
    
    //Clear Attachments
    function ClearAttachments():Void
    {
        for ( var i:Number = 0;  i < Tradepost.m_BankSlotsItemsToSend.length; ++i )
        {
            var bankSlot:Number = Tradepost.m_BankSlotsItemsToSend[i];
            DetachItemIconFromMail(bankSlot);
        }
    }
    
    //Update Attachments
    private function UpdateAttachments():Void
    {
        for ( var i:Number = 0;  i < Tradepost.m_BankSlotsItemsToSend.length; ++i )
        {
            var bankSlot:Number = Tradepost.m_BankSlotsItemsToSend[i];
            
            if ( GetAttachmentPosition(bankSlot) < 0 )
            {
                AttachItemIconToMail(bankSlot, GetFirstEmptySlotPosition());
            }
        }
    }
    
    //Update Send Button State
    private function UpdateSendButtonState():Void
    {
        var cash:Number = m_MailAttachments.m_ItemCounter.amount;
        var bodyString:String = m_BodyInput.text.split(" ").join("");
        
        m_SendButton.disabled = ((m_ToInput.text == "") || ((bodyString == "") && !HasItemsAttached() && cash == 0)) ? true : false;
    }
    
    //Key Up Event Handler
    private function KeyUpEventHandler():Void
    {
        switch(Key.getCode())
        {
            case Key.TAB:       if (Selection.getFocus() == m_ToInput.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? m_MailAttachments.m_ItemCounter.TakeFocus() : Selection.setFocus(m_BodyInput.textField);
                                }
                                else if (Selection.getFocus() == m_BodyInput.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? Selection.setFocus(m_ToInput.textField) : m_MailAttachments.m_ItemCounter.TakeFocus();
                                }
                                else if (Selection.getFocus() == m_MailAttachments.m_ItemCounter.m_TextInput.textField)
                                {
                                    (Key.isDown(Key.SHIFT)) ? Selection.setFocus(m_BodyInput.textField) : Selection.setFocus(m_ToInput.textField);
                                }
                                
                                break;

            case Key.ENTER:     if (Selection.getFocus() == m_ToInput.textField)
                                {
                                    Selection.setFocus(m_BodyInput.textField);
                                }	
                                
                                break;
        }
        
    }
    
    //Button Click Handler
    private function ButtonClickHandler(event:Object):Void
    {
        switch (event.target)
        {
            case m_FriendsButton:   DisableControls(true);
                                    m_FriendsList.OpenList(ComposeMailFriendsList.FRIENDS_LIST_TYPE);
                                    
                                    break;
                                    
            case m_CabalButton:     DisableControls(true);
                                    m_FriendsList.OpenList(ComposeMailFriendsList.CABAL_LIST_TYPE);
                                    
                                    break;
                                    
            case m_SendButton:      m_SendButton.disabled = true;
                                    Tradepost.SignalMailResult.Connect(SlotMailSent, this);
                                    Tradepost.SendMail( m_ToInput.text, m_BodyInput.text, m_MailAttachments.m_ItemCounter.m_TextInput.text );
                                    
                                    break;
        }
    }

    //Disable Controls
    private function DisableControls(toggle:Boolean):Void
    {
        m_ToInput.disabled = toggle;
        m_BodyInput.disabled = toggle;
        
        UpdateSendButtonState();
    }
    
    //Select To Input Field
    private function SelectToInputField():Void
    {
        Selection.setFocus(m_ToInput.textField);
        Selection.setSelection(m_ToInput.textField.text.length, m_ToInput.textField.text.length);
    }
    
    private function SlotMailSent(succeed:Boolean, message:String):Void
    {
        Tradepost.SignalMailResult.Disconnect(SlotMailSent, this);
        if (succeed)
        {
            m_ToInput.text = "";
            m_BodyInput.text = "";
            com.GameInterface.Chat.SignalShowFIFOMessage.Emit(SEND_MAIL_SUCCESS, 0)
            SignalCloseWindow.Emit();
        }
    }
    
    //Slot Remove Attachment
    function SlotRemoveAttachment(itemSlot:ItemSlot):Void
    {
        if ( itemSlot != undefined && itemSlot.HasItem() )
        {
            Tradepost.DetachItemFromMail(itemSlot.GetData().m_InventoryPos);
        }
    }
    
    //On Drag Begin
    private function onDragBegin(item:ItemSlot, stackSize:Number):Void
    {
        if (item.HasItem())
        {
            item.SetDragItemType("mailAttachment");
            var dragObject:DragObject = com.Utils.DragManager.StartDragItem(this, item, stackSize);
            dragObject.SignalDroppedOnDesktop.Connect(SlotDettachDragging, this);
            dragObject.SignalDragHandled.Connect(SlotDragHandled, this);
        }
    }
    
    private function SlotDragHandled()
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        var attachmentSlot:Number = GetAttachmentPosition(currentDragObject.inventory_slot);
        if (attachmentSlot >= 0)
        {
            var itemSlot:ItemSlot = m_AttachmentSlots[attachmentSlot]
        
            if (itemSlot != undefined)
            {
                itemSlot.SetAlpha(100);
                itemSlot.UpdateFilter();
            }
        }
    }
    
    private function SlotDettachDragging()
    {
        var currentDragObject:DragObject = DragObject.GetCurrentDragObject();
        if (currentDragObject.type == "mailAttachment")
        {        
            var attachmentSlot:Number = GetAttachmentPosition(currentDragObject.inventory_slot);
            if (attachmentSlot >= 0)
            {
                var itemSlot:ItemSlot = m_AttachmentSlots[attachmentSlot]
                
                SlotRemoveAttachment(itemSlot);
            }
        }
    }
    
    //On Drag End
    function onDragEnd(event:Object):Void
    {
        if (event.cancelled)
        {
            event.data.DragHandled();
            return;
        }
        
        var succeed:Boolean = false;
        var playSound:Boolean = false;

        if ( event.data.type == "item" && Mouse["IsMouseOver"](this) )
        {
            if ( Tradepost.CanAttachToMail(event.data.inventory_id, event.data.inventory_slot, true) )
            {
                var bankSlot:Number = Tradepost.AttachItemToMail(event.data.inventory_id, event.data.inventory_slot, GetMouseSlotID());
                if ( bankSlot < 0 )
                {
                    com.GameInterface.Chat.SignalShowFIFOMessage.Emit(ERROR_ATTACHING_TO_MAIL, 0)  
                }
                else
                {
                    succeed = true;
                }
            }
            playSound = true;
        }
        else if ( event.data.type == "mailAttachment" && Mouse["IsMouseOver"](this) )
        {
            DetachItemIconFromMail(event.data.inventory_slot);
            AttachItemIconToMail(event.data.inventory_slot, GetMouseSlotID())
            succeed = true;
            playSound = true;
        }
        
        if (playSound)
        {
            Character.GetClientCharacter().AddEffectPackage((succeed) ? "sound_fxpackage_GUI_item_slot.xml" : "sound_fxpackage_GUI_item_slot_fail.xml");
        }
        
        if (Mouse["IsMouseOver"](this))
        {
            event.data.DragHandled();
        }
    }
    
    //Attach Item Icon To Mail
    function AttachItemIconToMail(bankSlot:Number, attachmentSlotPosition:Number):Void
    {
        if ( attachmentSlotPosition < 0 )
        {
            //Find an empty slot or replace the object in the first one
            attachmentSlotPosition = Math.max(GetFirstEmptySlotPosition(), 1);
        }
        
        if ( attachmentSlotPosition >= 0 && Tradepost.IsItemInComposeMail(bankSlot))
        {
            var itemSlot:ItemSlot = m_AttachmentSlots[attachmentSlotPosition];
            
            //Maybe we are draging over a previously attached item
            if (itemSlot.HasItem() && itemSlot.GetData().m_InventoryPos != bankSlot)
            {
                SlotRemoveAttachment(itemSlot);
            }
            
            var itemData:InventoryItem = m_BankInventory.GetItemAt(bankSlot);
            
            itemSlot.SetSlotID(bankSlot);
            itemSlot.SetData(itemData);
        }
        
        UpdateSendButtonState();
    }

    //Detatch Item Icon From Mail
    function DetachItemIconFromMail(bankSlot:Number):Void
    {
        var attachmentSlot:Number = GetAttachmentPosition(bankSlot);

        if (attachmentSlot >= 0)
        {
            var itemSlot:ItemSlot = m_AttachmentSlots[attachmentSlot]

            itemSlot.Clear();
            UpdateSendButtonState();
        }
    }
    
    //Get Mouse Slot ID
    function GetMouseSlotID():Number
    {
        for (var key in m_AttachmentSlots)
        {
            if( m_AttachmentSlots[key].GetSlotMC()._parent.hitTest(_root._xmouse, _root._ymouse) ) return key;
        }
        
        return -1;
    }
    
    //Get Attachment Position
    private function GetAttachmentPosition(bankSlot:Number):Number
    {
        for (var key in m_AttachmentSlots)
        {
            var itemSlot:ItemSlot = m_AttachmentSlots[key];

            if ( itemSlot.GetData().m_InventoryPos == bankSlot )
            {
                return key;
            }
        }
        
        return -1;
    }
    
    //Get First Empty Slot Position
    private function GetFirstEmptySlotPosition() : Number
    {
        var emptyPositions:Array = new Array();
        
        for (var key in m_AttachmentSlots)
        {
            var itemSlot:ItemSlot = m_AttachmentSlots[key];
            
            if ( !itemSlot.HasItem() )
            {
                emptyPositions.push( key );
            }
        }
        
        emptyPositions.sort(Array.NUMERIC);
        
        if (emptyPositions.length > 0)
        {
            return parseInt(emptyPositions[0],10);
        }

        return -1;
    }
    
    //Has Items Attached
    private function HasItemsAttached() : Boolean
    {
        for (var key in m_AttachmentSlots)
        {
            var itemSlot:ItemSlot = m_AttachmentSlots[key];
            
            if ( itemSlot.HasItem() )
            {
                return true;
            }
        }
        return false;
    }
}