
module Backpack {
    public type Asset = {
        principal : Principal;
        name : Text;
        isPrivate : Bool;
        quantity : Nat;
    };

    public type TradeRequest = {
        id : Nat;
        giveQuantity : Nat;
        receiveQuantity : Nat;
        giveAsset : ?Principal;
        receiveAsset : Principal;
    };
    
    public type BackpackCanister = actor {
        reboot_backpack_receiveTradeRequest : shared (Principal, ?Principal, Nat, Nat) -> async ();
    };
}