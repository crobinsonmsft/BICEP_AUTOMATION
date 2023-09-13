//=======This bicep file creates Peering Connection from Hub to Spoke=======//

//=================Params=================//

param peering_name_hub_to_spoke string
param vnet_spoke_id string


// Hub to Spoke Params
param huballowForwardedTraffic bool
param huballowGatewayTransit bool
param huballowVirtualNetworkAccess bool
param hubdoNotVerifyRemoteGateways bool
param hubpeeringState string
param hubuseRemoteGateways bool   


//===============End Params===============//



//=========== Start Peering Hub to Spoke ==========//


resource peering_hub_to_spoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: peering_name_hub_to_spoke 
  properties: {
    allowForwardedTraffic : huballowForwardedTraffic
    allowGatewayTransit: huballowGatewayTransit //If gateway links can be used in remote virtual networking to link to this virtual network
    allowVirtualNetworkAccess: huballowVirtualNetworkAccess
    doNotVerifyRemoteGateways: hubdoNotVerifyRemoteGateways
    peeringState: hubpeeringState
    useRemoteGateways: hubuseRemoteGateways  //this should be FALSE for the hub peering connection
    

    remoteVirtualNetwork: {
      id: vnet_spoke_id
    }    
  }
}
