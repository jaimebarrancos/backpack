# Backpack

## Description:
A different ownership system that Web3 hasn't yet seen.



### Creating an asset / a store (where you sell assets):

1. The network must accept your store canister to be part of the network.
2. Your store needs to have a backpack with your assets
3. The only way to know if the person calling your canister is the owner is to call the reboot_backpack_checkOwnership of the caller canister.


### Available methods

#### reboot_backpack_checkOwnership(asset : principal)
check if any asset of that collection is in the backpack

```
reboot_backpack_requestTrade
        toBackpackPrincipal : Principal,
        giveAssetPrincipal : Principal,
        receiveAssetPrincipal : ?Principal,
        giveQuantity : Nat,
        receiveQuantity : Nat,
```
send a trade request to `toBackpackPrincipal` to give `giveQuantity` amount of `giveAssetPrincipal` in exchange of `receiveQuantity` amount of `receiveAssetPrincipal` (only owner)

#### reboot_backpack_handleTradeRequest(asset)
accept or decline a transfer request
(only owner)

#### reboot_backpack_removeAsset(asset)
remove an asset from your backpack
(only owner)