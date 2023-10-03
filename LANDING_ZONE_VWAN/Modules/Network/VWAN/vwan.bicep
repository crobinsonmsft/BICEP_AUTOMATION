
param location string
param virtualWanName string
param virtualHubName string
param tags object
param vwanHubAddressPrefix string

resource virtualWan 'Microsoft.Network/virtualWans@2023-05-01' = {
  name: virtualWanName
  location: location
  tags: tags
  properties: {
    //disableVpnEncryption: false
    //allowBranchToBranchTraffic: true
    type: 'Standard'
  }
}

resource virtualHub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: virtualHubName
  location: location
  tags: tags
  properties: {
    virtualWan: {
      id: virtualWan.id
    }
    addressPrefix: vwanHubAddressPrefix
    //type: standard
  }
}

output virtualHubId string = virtualHub.id
