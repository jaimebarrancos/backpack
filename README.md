# Backpack

## Description:
A different ownership system that Web3 hasn't yet seen.

## Creating an asset / a store (where you sell assets):

1. The network must accept your store canister to be part of the network.
2. Your store needs to have a backpack with your assets
3. The only way to know if the person calling your canister is the owner is to call the reboot_backpack_checkOwnership of the caller canister.


## Exploring further / takeaways:

- maybe we need some sort of deal standard in which 2 people agree on something, because more than one module uses it and more will

- instead of trading directly, it is possible to allow someone to put an asset for sale to anyone

- Undercollateralized borrowing is possible with the backpack if:
  -  Each real world person can have one and one only person canister
  - A penalisation system, like a fine if you break your promise (or maybe a trust factor)

- Still need a way to know if someone is part of the network and can be trusted


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
send a trade request to `toBackpackPrincipal` to give `giveQuantity` amount of assets of the  `giveAssetPrincipal` in exchange of `receiveQuantity` amount of assets of the `receiveAssetPrincipal` (only owner)

#### reboot_backpack_receiveTradeRequest(asset)
store a new trade request

#### reboot_backpack_handleTradeRequest(asset)
accept or decline a transfer request (only owner)

#### reboot_backpack_removeAsset(asset)
remove an asset from your backpack - this will make the object permenantly dissapear (only owner)


