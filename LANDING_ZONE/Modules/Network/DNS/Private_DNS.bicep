@description('private dns zone name')
param dnsZoneName string
@description('location of this reosurce')
param location string = 'global'

@description('virtual network id')
param vnetId string
@description('enable auto registration for private dns')
param autoRegistration bool = false
@description('Tag information')
param tags object

resource privateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: location
}

resource vnLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dnsZoneName}-link'
  location: location
  parent: privateDns
  properties: {
    registrationEnabled: autoRegistration
    virtualNetwork: {
      id: vnetId
    }
  }
  tags: tags
}


output id string = privateDns.id
output name string = privateDns.name
