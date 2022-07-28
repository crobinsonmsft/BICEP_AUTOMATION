//=======This bicep file creates a Public IP Address.  Commonly used for services like Bastion =======//

//=================Params=================//

param publicIPAddressName string
param location string
param publicIPsku string 
param publicIPAllocationMethod string
param publicIPAddressVersion string
param dnsLabelPrefix string //Unique DNS Name for the Public IP used to access the Virtual Machine
param tags object

//===============End Params===============//

//====== Start Peering Spoke to Hub ======//


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
      domainNameLabel: dnsLabelPrefix
    }
    idleTimeoutInMinutes: 4
  }
}

//Set ID Output here to be used by other modules

output public_ip_id string = publicIP.id
