
module Backpack {
    public type Asset = {
        principal : Principal;
        name : Text;
        isPrivate : Bool;
    };

    public type TradeRequest = {
        giveAsset : ?Principal;
        receiveAsset : Principal;
    };
    
    public type BackpackCanister = actor {
        reboot_backpack_receiveTradeRequest : shared (Principal, ?Principal) -> async ();
    };
}