//=======This bicep file creates a Bastion Host=======//

//=================Params=================//
param tags object
param bastionName string
param location string
param bastionSubnetid string

param publicIPAddressName string
param publicIPsku string 
param publicIPAllocationMethod string
param publicIPAddressVersion string
param dnsLabelPrefixBastion string //Unique DNS Name for the Public IP used to access the Virtual Machine
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
             id: publicIP.id
           }
           subnet: {
             id: bastionSubnetid
           }
         }
       }
    ]
  }
}




resource publicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicIPAddressName
  location: location
  tags: tags
  sku: {
    name: publicIPsku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPAddressVersion: publicIPAddressVersion
    dnsSettings: {
      domainNameLabel: dnsLabelPrefixBastion
    }
    idleTimeoutInMinutes: 4
  }
}

//Set ID Output here to be used by other modules

output public_ip_id string = publicIP.id
