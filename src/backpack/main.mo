import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Backpack "./types";
import Result "mo:base/Result";
import Array "mo:base/Array";

actor {

    public type Asset = Backpack.Asset;
    public type Result<Ok, Err> = Result.Result<Ok, Err>;
    public type BackpackCanister = Backpack.BackpackCanister;
    public type TradeRequest = Backpack.TradeRequest;

    stable let owner : Principal = Principal.fromText("some-principal");
    let backpack = HashMap.HashMap<Principal, Asset>(10, Principal.equal, Principal.hash); // TODO: i want the items to be stable
    var tradeRequests : [TradeRequest] = [];


    public shared ({ caller }) func reboot_backpack_requestTrade(
        toBackpackPrincipal : Principal,
        giveAsset : Principal,
        receiveAsset : ?Principal,
    ) : async Result<(), Text> {

        if (caller != owner) {
            return #err("Caller must be the owner of the backpack.");
        };
        switch (backpack.get(giveAsset)) {
            case (null) {
                return #err("Asset not in your backpack");
            };
            case (?asset) {
                let toBackpack : BackpackCanister =  actor(Principal.toText(toBackpackPrincipal));

                try {
                    await toBackpack.reboot_backpack_receiveTradeRequest(giveAsset, receiveAsset);
                    return #ok(());
                } catch (err) {
                    return #err("Failed to send trade request.");
                };
            };
        };
    };


    public shared ({ caller }) func reboot_backpack_receiveTradeRequest(
        giveAsset : Principal,
        receiveAsset : ?Principal,
    ) : async Result<(), Text> {

        let trade : TradeRequest = {
            giveAsset = receiveAsset;
            receiveAsset = giveAsset;
        };

        tradeRequests := Array.append<TradeRequest>(tradeRequests, [trade]);
        return #ok();
    };





    // if the asset is private, this function will return false
    public query func reboot_backpack_checkOwnership(assetPrincipal : Principal) : async Bool {
        switch (backpack.get(assetPrincipal)) {
            case (null) {
                return false;
            };
            case (?asset) {
                if (asset.isPrivate == true) {
                    return false;
                };
                return true;
            };
        };
    };

};
