import com.GameInterface.TradepostSearchData;
import com.GameInterface.ItemPrice;
import com.Utils.Signal;
import com.Utils.ID32;

intrinsic class com.GameInterface.Tradepost
{
    static public var m_TradepostItemTypes : Object; // Dictionary of [TradepostTDBItemTypes_e:String]->Array[TradepostTDBItemSubTypes_e:Number]
    static public var m_Mail : Object;  //Dictionary of [MailData.m_MailId]->MailData 
    static public var m_BankSlotsItemsToSend : Array; //Array of ItemSlotIDs (Number)
    static public var m_SearchResults : Array;  //Array of TradepostSearchResultData objects
    static public var m_SearchCriteria : TradepostSearchData;

    static public var SignalComposeMail : Signal; //<void>
    static public var SignalNewMailNotification : Signal; // <void>
    static public var SignalNewMail : Signal; // <mailID:Number> --> Data in m_Mail
    static public var SignalMailUpdated : Signal; // <mailID:Number> --> Data in m_Mail
    static public var SignalMailDeleted : Signal; // <mailID:Number> --> Data in m_Mail
    static public var SignalAllMailRead : Signal; // <void>
    static public var SignalMailResult : Signal; // <bool sendSucceeded, String error>
    static public var SignalSearchResult : Signal; //<void>  --> Data in m_SearchResults
    static public var SignalMailItemAttached : Signal; //<bankItemPosition:Number, posInMailAttachments:Number>
    static public var SignalMailItemDetached : Signal; //<bankItemPosition:Number>
    static public var SignalGuildCashUpdated : Signal; //<newCash:Number>
    
    static public function UpdateMail() : Void; //Call to fill up m_Mail. needed everytime tradepost is enabled
    static public function SendMail( receiverName:String, messageBody:String, money:Number ) : Boolean;
    static public function MarkAsRead( mailId:Number ) : Void;
    static public function GetMailItems( mailId:Number ) : Void;
    static public function GetMailItem( mailId:Number, itemId:Number ) : Void;
    static public function GetMailIDByItem( bankItemSlot:Number ) : Number;
    static public function GetSentToName( bankItemSlot:Number ) : String; //Get the name player's to whom the item was sent
    static public function DeleteMail( mailId:Number ) : Void; //Delete is for your inbox
    static public function CancelMail( mailId:Number ) : Void; //Cancel is for your outbox
    static public function HasUnreadMail() : Boolean;
    static public function AttachItemToMail(inventoryID:ID32, itemSlot:Number, posInMailAttachments:Number) : Number; //posInMailAttachments is the mail slot where we want to attach the item
    static public function DetachItemFromMail( itemSlot:Number, notifyGUI:Boolean ) : Boolean; 
    static public function CanAttachToMail(inventoryID:ID32, itemSlot:Number, showFeedback:Boolean) : Boolean;
    static public function OpenComposeMail() : Void;
    static public function CancelComposeMail() : Void;
    static public function SellItem( bankItemSlot:Number, price:ItemPrice ) : Boolean;
    static public function ChangeItemPrice( bankItemSlot:Number, price:ItemPrice ) : Boolean;
    static public function CancelSellItem( bankItemSlot:Number ) : Boolean;
    static public function IsItemForSale( bankItemSlot:Number ) : Boolean;
    static public function GetItemSalePrice( bankItemSlot:Number ) : ItemPrice;
    static public function BuyItem( itemID:Number, searchID:Number ); //TradepostResultSearchData items have a m_SearchID property
    static public function IsItemAttachedToMail( bankItemSlot:Number ) : Boolean;
    static public function IsItemInComposeMail( bankItemSlot:Number ) : Boolean;
    static public function MakeSearch() : Void;
    static public function GuildWithdrawMoney(cash:Number) : Void;
    static public function GuildTransferMoney(cash:Number) : Void;
    static public function GetGuildCash() : Number;
    static public function CanItemBeRemovedFromGuildBank( bankItemSlot:Number ) : Boolean;
}