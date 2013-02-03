import com.Utils.Signal;

intrinsic class com.GameInterface.Claim
{
    static public var m_Claims : Array; //Array of ClaimItemData objects
    
    static public var SignalClaimsUpdated : Signal; // ()
    
    static public function ClaimAllItems() : Boolean;    
    static public function ClaimItem( ClaimItemId:Number ) : Boolean;
    static public function DeleteClaimItem( ClaimItemId:Number ) : Void;
}