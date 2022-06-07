//=======This bicep file creates all Virtual NEtworks (VNETs))=======//

//=================Params=================//

//global params

param tags object
param location string


//nsg params

param bastion_nsg_id string
//param public_nsg_id string
param private_nsg_id string


//vnet params

param vnet_hub_name string
param vnet_hub_address_space string

//HUB Subnet Parameters
param subnet_hub_gw_name string
param subnet_hub_fw_name string
param subnet_hub_bas_name string
param subnet_ss_name string

param subnet_hub_gw_adress_space string
param subnet_hub_fw_address_space string
param subnet_hub_bas_address_space string
param subnet_hub_ss_address_space string
            


//===============End Params===============//

//======== Start Resource Creation =======//

resource vnet_hub 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnet_hub_name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_hub_address_space
      ]
    }
    subnets: [
      {
        name: subnet_hub_gw_name
        properties: {
          addressPrefix: subnet_hub_gw_adress_space
          networkSecurityGroup: {
            id: private_nsg_id
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
        name: subnet_hub_fw_name
        properties: {
          addressPrefix: subnet_hub_fw_address_space
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_hub_bas_name
        properties: {
          addressPrefix: subnet_hub_bas_address_space
          networkSecurityGroup: {
            id: bastion_nsg_id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_ss_name
        properties: {
          addressPrefix: subnet_hub_ss_address_space
          networkSecurityGroup: {
            id: private_nsg_id
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
    enableDdosProtection: false
  }
}
