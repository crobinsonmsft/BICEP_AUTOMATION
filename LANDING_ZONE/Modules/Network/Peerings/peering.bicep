param name string
param peering_prefix_hub string
param vnet_hub_id string


resource symbolicname 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: name
 
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    doNotVerifyRemoteGateways: false
    peeringState: 'Connected'
    
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
