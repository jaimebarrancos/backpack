Guide to creating an asset / a store (where you sell assets)

## Rules:
1. The network must accept your store canister to be part of the network.
2. Your store needs to have a backpack with your assets
3. The only way to know if the person calling your canister is the owner is to call the reboot_backpack_checkOwnership of the caller canister.


# Methods

#### reboot_backpack_checkOwnership(asset : principal)
check if any asset of that collection is in the backpack

#### reboot_backpack_requestTrade(toBackpackPrincipal : Principal, assetPrincipal : Principal, receiveAsset : ?Principal)
send a request transfer 
only owner

#### reboot_backpack_handleTradeRequest(asset)
accept or decline a transfer request
only owner

#### reboot_backpack_removeAsset(asset)
remove an asset from your backpack
only owner