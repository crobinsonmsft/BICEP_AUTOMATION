//=======This bicep file creates a DMZ spoke VNET=======//

//=================Params=================//

//Global params
param tags object
param location string


//nsg params
param public_nsg_id string


//Spoke DMZ vnet params
param vnet_spoke_DMZ_name string
param vnet_spoke_DMZ_address_space string

//Spoke DMZ Subnet Parameters
param subnet_spoke_DMZ_name string
param subnet_spoke_DMZ_APP_GW_name string
param subnet_spoke_DMZ_address_space string
param subnet_spoke_DMZ_APP_GW_address_space string


//===============End Params===============//

//======== Start Resource Creation =======//

resource vnet_spoke_DMZ 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnet_spoke_DMZ_name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_spoke_DMZ_address_space
      ]
    }
    subnets: [
      {
        name: subnet_spoke_DMZ_name
        properties: {
          addressPrefix: subnet_spoke_DMZ_address_space
          networkSecurityGroup: {
            id: public_nsg_id
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

      //App Gateway Subnet
      {
        name: subnet_spoke_DMZ_APP_GW_name
        properties: {
          addressPrefix: subnet_spoke_DMZ_APP_GW_address_space
          /*networkSecurityGroup: {
            id: 
          }
          */
          
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

output vnet_spoke_DMZ_id string = vnet_spoke_DMZ.id
//output subnet_spoke_DMZ_id string =  vnet_spoke_DMZ.properties.subnets[0].id
output subnet_spoke_DMZ_id string =  '${vnet_spoke_DMZ.id}/subnets/${subnet_spoke_DMZ_name}'
output subnet_spoke_test_id string =  '${vnet_spoke_DMZ.id}/subnets/${subnet_spoke_DMZ_APP_GW_name}'

