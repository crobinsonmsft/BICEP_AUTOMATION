
param location string = 'East US' // Update with your desired location
param virtualWanName string = 'myVirtualWan'
param virtualHubName string = 'myVirtualHub'
param tags object
param vwanHubAddressPrefix string

resource virtualWan 'Microsoft.Network/virtualWans@2021-02-01' = {
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
  }
}

output virtualHubId string = virtualHub.id
