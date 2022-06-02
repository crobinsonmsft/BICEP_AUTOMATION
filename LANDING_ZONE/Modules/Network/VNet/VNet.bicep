//=======This bicep file creates all Virtual NEtworks (VNETs))=======//

//=================Params=================//

//global params

param tags object
param location string


//nsg params

param bastion_nsg_id string
param public_nsg_id string
param private_nsg_id string
param db_nsg_id string


//route table params

param route_table_public_id string


//vnet params
param vnet_name string
param vnet_hub_id string

param vnet_address_space string

param subnet_db_prefix string
param subnet_gw_prefix string
param subnet_fw_prefix string
param subnet_bastion_prefix string
param subnet_pub_prefix string
param subnet_priv_prefix string

param subnet_db_name string
param subnet_gw_name string
param subnet_fw_name string
param subnet_bastion_name string
param subnet_pub_name string
param subnet_priv_name string

param peering_prefix_hub string
param peering_prefix_hub_underscore string

//===============End Params===============//

//======== Start Resource Creation =======//

resource virtualNetworks_hhs_aapaas_vnt_10_204_80_0_22_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnet_name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_address_space
      ]
    }
    subnets: [
      {
        name: subnet_db_name
        properties: {
          addressPrefix: subnet_db_prefix
          networkSecurityGroup: {
            id: db_nsg_id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                'eastus2'
                'centralus'
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
            {
              service: 'Microsoft.EventHub'
              locations: [
                '*'
              ]
            }
            {
              service: 'Microsoft.Sql'
              locations: [
                'eastus2'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_gw_name
        properties: {
          addressPrefix: subnet_gw_prefix
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_fw_name
        properties: {
          addressPrefix: subnet_fw_prefix
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_bastion_name
        properties: {
          addressPrefix: subnet_bastion_prefix
          networkSecurityGroup: {
            id: bastion_nsg_id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_pub_name
        properties: {
          addressPrefix: subnet_pub_prefix
          networkSecurityGroup: {
            id: public_nsg_id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                'eastus2'
                'centralus'
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
            {
              service: 'Microsoft.EventHub'
              locations: [
                '*'
              ]
            }
            {
              service: 'Microsoft.Sql'
              locations: [
                'eastus2'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_priv_name
        properties: {
          addressPrefix: subnet_priv_prefix
          networkSecurityGroup: {
            id: private_nsg_id
          }
          routeTable: {
            id: route_table_public_id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                'eastus2'
                'centralus'
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
            {
              service: 'Microsoft.EventHub'
              locations: [
                '*'
              ]
            }
            {
              service: 'Microsoft.Sql'
              locations: [
                'eastus2'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    /*
    virtualNetworkPeerings: [
      {
        name: '${vnet_name}-to-tss-hub-vnt-${peering_prefix_hub_underscore}'
        properties: {
          peeringState: 'Connected'
          remoteVirtualNetwork: {
            id: vnet_hub_id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: false
          useRemoteGateways: true
          remoteAddressSpace: {
            addressPrefixes: [
              peering_prefix_hub
            ]
          }
        }
      }
    ]
    */
    enableDdosProtection: false
  }
}
