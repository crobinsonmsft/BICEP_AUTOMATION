//=======This bicep file creates all Virtual NEtworks (VNETs))=======//

//=================Params=================//

//Global params
param tags object
param location string


//nsg params
param private_nsg_id string


//Spoke 001 vnet params
param vnet_spoke_001_name string
param vnet_spoke_001_address_space string

//Spoke 001 Subnet Parameters
param subnet_spoke_001_name string
param subnet_spoke_001_test_name string
param subnet_spoke_001_address_space string
param subnet_spoke_001_test_address_space string


//===============End Params===============//

//======== Start Resource Creation =======//

resource vnet_spoke_001 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnet_spoke_001_name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_spoke_001_address_space
      ]
    }
    subnets: [
      {
        name: subnet_spoke_001_name
        properties: {
          addressPrefix: subnet_spoke_001_address_space
          networkSecurityGroup: {
            id: private_nsg_id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                'eastus'
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
                'eastus'
                'eastus2'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }

      //Testing Subnet
      {
        name: subnet_spoke_001_test_name
        properties: {
          addressPrefix: subnet_spoke_001_test_address_space
          /*networkSecurityGroup: {
            id: 
          }
          */
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                'eastus'
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
                'eastus'
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


//Set ID Output here to be used by other modules

output vnet_spoke_001_id string = vnet_spoke_001.id
//output subnet_spoke_001_id string =  vnet_spoke_001.properties.subnets[0].id
output subnet_spoke_001_id string =  '${vnet_spoke_001.id}/subnets/${subnet_spoke_001_name}'
output subnet_spoke_test_id string =  '${vnet_spoke_001.id}/subnets/${subnet_spoke_001_test_name}'

