import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Backpack "./types";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";

// TODO: only allow trades of trusted people
// add cycle costs

actor {

    public type Asset = Backpack.Asset;
    public type Result<Ok, Err> = Result.Result<Ok, Err>;
    public type BackpackCanister = Backpack.BackpackCanister;
    public type TradeRequest = Backpack.TradeRequest;

    stable let owner : Principal = Principal.fromText("some-principal");
    let backpack = HashMap.HashMap<Principal, Asset>(10, Principal.equal, Principal.hash); // TODO: i want the items to be stable
    let tradeRequests = Buffer.Buffer<TradeRequest>(0);
    let nextTradeId = 0;

    // for now you always need to give an asset
    public shared ({ caller }) func reboot_backpack_requestTrade(
        toBackpackPrincipal : Principal,
        giveAssetPrincipal : ?Principal,
        receiveAssetPrincipal : ?Principal,
        giveQuantity : Nat,
        receiveQuantity : Nat,
    ) : async Result<(), Text> {
        assert (caller == owner);
        if (caller != owner) {
            return #err("Caller must be the owner of the backpack.");
        };
        
        switch (giveAssetPrincipal) {
            case (null) {
                return #err("You must give an asset.");
            };
            case (?_giveAssetPrincipal) {
                switch (backpack.get(_giveAssetPrincipal)) {
                    case (null) {
                        return #err("Asset not in your backpack");
                    };
                    case (?asset) {
                        let trade : TradeRequest = {
                            id = nextTradeId;
                            destinyBackpack = caller;
                            giveAsset = giveAssetPrincipal;
                            receiveAsset = receiveAssetPrincipal;
                            giveQuantity = giveQuantity;
                            receiveQuantity = receiveQuantity;
                        };
                        tradeRequests.add(trade);

                        let toBackpack : BackpackCanister = actor (Principal.toText(toBackpackPrincipal));
                        try { // if this call fails, the trade request will still exist
                            
                            return await toBackpack.reboot_backpack_receiveTradeRequest(
                                _giveAssetPrincipal,
                                receiveAssetPrincipal,
                                giveQuantity,
                                receiveQuantity,
                            );
                        } catch (err) {
                            return #err("Failed to send trade request.");
                        };
                    };
                };
            };
        }

    };


    public shared ({ caller }) func reboot_backpack_receiveTradeRequest(
        giveAssetPrincipal : ?Principal,
        receiveAssetPrincipal : ?Principal,
        giveQuantity : Nat,
        receiveQuantity : Nat,
    ) : async Result<(), Text> {

        //TODO: check if caller is part of the network

        let trade : TradeRequest = {
            id = nextTradeId;
            destinyBackpack = caller;
            giveAsset = receiveAssetPrincipal;
            receiveAsset = giveAssetPrincipal;
            giveQuantity = giveQuantity;
            receiveQuantity = receiveQuantity;
        };

        tradeRequests.add(trade);
        return #ok();
    };

    public shared ({ caller }) func reboot_backpack_receiveHandledTradeRequest(
        id : Nat,
        name : Text,
    ) : async Result<(), Text> {
        for (tradeRequest in tradeRequests.vals()) {
            if (tradeRequest.id == id and tradeRequest.destinyBackpack == caller) {
                switch (tradeRequest.receiveAsset) {
                    case (null) {};
                    case (?receive) {
                        backpack.put(
                            receive,
                            {
                                quantity = tradeRequest.receiveQuantity;
                                principal = receive;
                                name = name;
                                isPrivate = false;
                            },
                        );
                    };
                };
                switch (tradeRequest.giveAsset) {
                    case (null) {};
                    case (?give) {
                        switch (backpack.remove(give)) {
                            case (null) {
                                return #err("Asset not in your backpack.");
                            };
                            case (?asset) {};
                        };                
                        return #ok();
                    };
                };
                let _ = tradeRequests.remove(tradeRequest.id);

                return #ok();
            };
        };
        return #err("No trade request found.");
    };


    public shared ({ caller }) func reboot_backpack_handleTradeRequest(
        id : Nat,
        acceptTrade : Bool,
        isPrivate : Bool,
        name : Text,
    ) : async Result<(), Text> {
        assert (caller == owner);
        
        for (tradeRequest in tradeRequests.vals()) {
            if (tradeRequest.id == id) {
                if (acceptTrade == true) {
                    switch (tradeRequest.giveAsset) {
                        case (null) {};
                        case (?asset) {
                            let toBackpack : BackpackCanister = actor (Principal.toText(tradeRequest.destinyBackpack));
                            try { // if this call fails, the trade request will still exist
                                return await toBackpack.reboot_backpack_receiveHandledTradeRequest(
                                    id,
                                    name,
                                );
                            } catch (err) {
                                return #err("Failed to send trade request.");
                            };
                        };
                    };
                    switch (tradeRequest.receiveAsset) {
                        case (null) {
                            return #err("You must receive an asset.");
                        };
                        case (?receive) {
                            backpack.put(
                                receive,
                                {
                                    quantity = tradeRequest.receiveQuantity;
                                    principal = receive;
                                    name = name;
                                    isPrivate = isPrivate;
                                },
                            );
                            return #ok();
                        };
                    };
                };
                switch (tradeRequest.giveAsset) {
                    case (null) {};
                    case (?give) {
                        switch (backpack.remove(give)) {
                            case (null) {
                                return #err("Asset not in your backpack.");
                            };
                            case (?asset) {};
                        };
                    };
                };
                let _ = tradeRequests.remove(tradeRequest.id);
                return #ok();
            };
        };
        return #err("No trade request found.");
    };


    public shared ({caller}) func reboot_backpack_removeAsset(assetPrincipal : Principal) : async Result<(), Text> {
        assert (caller == owner);
        switch (backpack.remove(assetPrincipal)) {
            case (null) {
                return #err("Asset not in your backpack.");
            };
            case (?asset) {
                return #ok();
            };
        };
    };


    public shared func reboot_backpack_viewPublicBackpack() : async [Asset] {
        let result = Iter.filter(backpack.vals(), func (asset : Asset) : Bool {
            if (asset.isPrivate == true) {
                return false
            };
            return true;
        });
        return Iter.toArray(result);
    };

    public shared ({caller}) func reboot_backpack_viewBackpack() : async [Asset] {
        assert (caller == owner);
        return Iter.toArray(backpack.vals());
    };

    public shared ({caller}) func reboot_backpack_viewTradeRequests() : async [TradeRequest] {
        assert (caller == owner);
        return Iter.toArray(tradeRequests.vals());
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
