//=======This bicep file creates all Route Tables=======//

//=================Params=================//
param tags object
param location string
param route_table_name string = 'AllTraffic-Spoke-001'
param bgp_disable bool 
param bgp_override bool
param nextHopType string
param peering_prefix_hub_underscore string
param peering_prefix_hub string
param subscriptionPrefix string
param vnet_address_space string
param vnet_address_space_underscore string

//===============End Params===============//

//====== Start Route Table Creation ======//

resource routeTable 'Microsoft.Network/routeTables@2022-11-01' = {
  name: route_table_name
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: bgp_disable
    routes: [
      {
        //id: 'string'
        name: '${subscriptionPrefix}rte-vnt-${peering_prefix_hub_underscore}'
        properties: {
          addressPrefix: peering_prefix_hub
          nextHopType: nextHopType
          nextHopIpAddress: '10.204.3.4'    //This is the Firewall's Private (inside) adapter Address
          hasBgpOverride: bgp_override
        }
      }
      {
        name: '${subscriptionPrefix}rte-vnt-0.0.0.0_0-ALLTRAFFIC'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: nextHopType
          nextHopIpAddress: '10.204.3.4'    //This is the Firewall Address
          hasBgpOverride: bgp_override
        }
      }
      {
        name: '${subscriptionPrefix}rte-vnt-${vnet_address_space_underscore}'
        properties: {
          addressPrefix: vnet_address_space
          nextHopType: 'VnetLocal'
          hasBgpOverride: bgp_override
        }
      }
    ]
  }
}


//Set ID Output here to be used by other modules

output route_table_id string = routeTable.id
