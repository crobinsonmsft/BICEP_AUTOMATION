//=======This bicep file creates a Bastion Host=======//

//=================Params=================//
param tags object
param bastionName string
param location string
param publicipid string
param bastionSubnetid string
//===============End Params===============//

//======== Start Resource Creation =======//
//Bastion

resource azureBastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bastionName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
       {
         name: 'ipConf'
         properties: {
           publicIPAddress: {
             id: publicipid
           }
           subnet: {
             id: bastionSubnetid
           }
         }
       }
    ]
  }
}
