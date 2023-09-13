//=======This bicep file creates all Virtual NEtworks (VNETs))=======//

//=================Params=================//

//Global params
param tags object
param location string


//nsg params
param private_nsg_id string


//Spoke ss vnet params
param vnet_spoke_ss_name string
param vnet_spoke_ss_address_space string

//Spoke ss Subnet Parameters
param subnet_spoke_ss_name string
param subnet_spoke_ss_address_space string

param virtualHubName string


//===============End Params===============//

//======== Start Resource Creation =======//

resource vnet_spoke_ss 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnet_spoke_ss_name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_spoke_ss_address_space
      ]
    }
    subnets: [
      {
        name: subnet_spoke_ss_name
        properties: {
          addressPrefix: subnet_spoke_ss_address_space
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

      
    ]
    enableDdosProtection: false
  }
}

resource virtualHub 'Microsoft.Network/virtualHubs@2021-02-01' existing = {
  name: virtualHubName
}


resource hubVNetconnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-08-01' = {
  parent: virtualHub
  name: '${vnet_spoke_ss_name}-connection'
  properties: {
    remoteVirtualNetwork: {
      id: vnet_spoke_ss.id
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: false
    enableInternetSecurity: true

    }
  }

//Set ID Output here to be used by other modules

output vnet_spoke_ss_id string = vnet_spoke_ss.id
//output subnet_spoke_ss_id string =  vnet_spoke_ss.properties.subnets[0].id
output subnet_spoke_ss_id string =  '${vnet_spoke_ss.id}/subnets/${subnet_spoke_ss_name}'

