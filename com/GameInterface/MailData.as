
intrinsic class  com.GameInterface.MailData
{
    public var m_MailId : Number;
    public var m_SenderId : Number;
    public var m_SenderName : String;
    public var m_MessageBody : String;
    public var m_IsRead : Boolean;
    public var m_HasItems : Boolean;
    public var m_IsSendByTradepost : Boolean;
    public var m_Items : Array; //Dictionary [itemID:Number]->(itemIcon:ID32)
    public var m_Money : Number;
    public var m_SendTime : Number;
    public var m_TimeOut : Number;
    public var m_TimeLeft : Number;
}
