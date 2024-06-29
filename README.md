

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