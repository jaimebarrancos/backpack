import Result "mo:base/Result";

module Backpack {
    public type Result<Ok, Err> = Result.Result<Ok, Err>;

    public type Asset = {
        principal : Principal;
        name : Text;
        isPrivate : Bool;
        quantity : Nat;
    };

    public type TradeRequest = {
        id : Nat;
        destinyBackpack : Principal;
        giveQuantity : Nat;
        receiveQuantity : Nat;
        giveAsset : ?Principal;
        receiveAsset : ?Principal;
    };
    
    public type BackpackCanister = actor {
        reboot_backpack_receiveTradeRequest : shared (Principal, ?Principal, Nat, Nat) -> async Result<(), Text>;
        reboot_backpack_receiveHandledTradeRequest : shared (Nat, Text) -> async Result<(), Text>;
    };
}