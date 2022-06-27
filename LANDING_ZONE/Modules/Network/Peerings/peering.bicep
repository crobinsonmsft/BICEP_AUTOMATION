//=======This bicep file creates all Peering Connections=======//

//=================Params=================//

param peering_name_hub_to_spoke_001 string
param peering_name_spoke_001_to_hub string
param peering_prefix_hub string
param vnet_hub_id string
param vnet_spoke_001_id string
param allowForwardedTraffic bool
param allowGatewayTransit bool
param allowVirtualNetworkAccess bool
param doNotVerifyRemoteGateways bool
param peeringState string
param useRemoteGateways bool

//===============End Params===============//

//====== Start Peering Spoke to Hub ======//

resource peering_hub_to_spoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: peering_name_spoke_001_to_hub
  properties: {
    allowForwardedTraffic : allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    doNotVerifyRemoteGateways: doNotVerifyRemoteGateways
    peeringState: peeringState
    useRemoteGateways: useRemoteGateways
    
    /*
    remoteAddressSpace: {
      addressPrefixes: [
        peering_prefix_hub
      ]
    }
    */
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
    
  }
}

//=========== Start Peering Hub to Spoke ==========//

resource peering_spoke_to_hub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: peering_name_hub_to_spoke_001 
  properties: {
    allowForwardedTraffic : allowForwardedTraffic
    allowGatewayTransit: false
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    doNotVerifyRemoteGateways: doNotVerifyRemoteGateways
    peeringState: peeringState
    useRemoteGateways: false
    
    /*
    remoteAddressSpace: {
      addressPrefixes: [
        peering_prefix_hub
      ]
    }
    */
    remoteVirtualNetwork: {
      id: vnet_spoke_001_id
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
    
  }
}
