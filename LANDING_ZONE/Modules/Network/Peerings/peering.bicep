//=======This bicep file creates all Peering Connections=======//

//=================Params=================//

param peering_name string
param peering_prefix_hub string
param vnet_hub_id string
param allowForwardedTraffic bool
param allowGatewayTransit bool
param allowVirtualNetworkAccess bool
param doNotVerifyRemoteGateways bool
param peeringState string

//===============End Params===============//

//====== Start Peering Creation ======//

resource peering_hub_to_spoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: peering_name
  properties: {
    allowForwardedTraffic : allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    doNotVerifyRemoteGateways: doNotVerifyRemoteGateways
    peeringState: peeringState
    
    remoteAddressSpace: {
      addressPrefixes: [
        peering_prefix_hub
      ]
    }
    remoteVirtualNetwork: {
      id: vnet_hub_id
    }
    /*
    remoteBgpCommunities: {
      virtualNetworkCommunity: 'string'
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        'string'
      ]
    }
    */
    useRemoteGateways: true
  }
}
