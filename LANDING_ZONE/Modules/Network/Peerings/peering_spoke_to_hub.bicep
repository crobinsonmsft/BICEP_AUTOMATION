//=======This bicep file creates Peering Connection from Spoke to Hub=======//

//=================Params=================//


param peering_name_spoke_to_hub string
param vnet_hub_id string


// Spoke to Hub Params
param spokeallowForwardedTraffic bool
param spokeallowGatewayTransit bool
param spokeallowVirtualNetworkAccess bool
//param spokedoNotVerifyRemoteGateways bool
param spokepeeringState string
param spokeuseRemoteGateways bool   // Should be true unless you have no gateway in the hub


//===============End Params===============//



//====== Start Peering Spoke to Hub ======//

resource peering_spoke_to_hub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  name: peering_name_spoke_to_hub
  properties: {
    allowForwardedTraffic : spokeallowForwardedTraffic
    allowGatewayTransit: spokeallowGatewayTransit
    allowVirtualNetworkAccess: spokeallowVirtualNetworkAccess
    //doNotVerifyRemoteGateways: spokedoNotVerifyRemoteGateways
    peeringState: spokepeeringState
    useRemoteGateways: spokeuseRemoteGateways
    
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

