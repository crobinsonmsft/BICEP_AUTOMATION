//=======This bicep file creates an NSG Flow Log=======//

//=================Params=================//
param networkWatcherName string
param location string
param retentionDays int
param storageAccountNameNsg string
param flowLogsVersion int
param nsgStorageAccountType string
param bastion_nsg_id string
param public_nsg_id string
param private_nsg_id string
param tags object

//===============End Params===============//

//======== Start Resource Creation =======//
//-Storage Account for NSG Flow Logs


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountNameNsg
  location: location
  sku: {
    name: nsgStorageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}


resource networkWatcher 'Microsoft.Network/networkWatchers@2022-01-01' = {
  name: networkWatcherName
  location: location
  tags: tags
  properties: {}
}


resource flowLogPrivate 'Microsoft.Network/networkWatchers/flowLogs@2022-01-01' = {
  name: 'private_flowLog'
  tags: tags
  location: location
  parent: networkWatcher
  properties: {
    targetResourceId: private_nsg_id
    storageId: storageAccount.id
    enabled: true
    retentionPolicy: {
      days: retentionDays
      enabled: true
    }
    format: {
      type: 'JSON'
      version: flowLogsVersion
    }
  }
}

resource flowLogPublic 'Microsoft.Network/networkWatchers/flowLogs@2022-01-01' = {
  name: 'public_flowLog'
  tags: tags
  location: location
  parent: networkWatcher
  properties: {
    targetResourceId: public_nsg_id
    storageId: storageAccount.id
    enabled: true
    retentionPolicy: {
      days: retentionDays
      enabled: true
    }
    format: {
      type: 'JSON'
      version: flowLogsVersion
    }
  }
}


resource flowLogBastion 'Microsoft.Network/networkWatchers/flowLogs@2022-01-01' = {
  name: 'bastion_flowLog'
  tags: tags
  location: location
  parent: networkWatcher
  properties: {
    targetResourceId: bastion_nsg_id
    storageId: storageAccount.id
    enabled: true
    retentionPolicy: {
      days: retentionDays
      enabled: true
    }
    format: {
      type: 'JSON'
      version: flowLogsVersion
    }
  }
}

output nsg_flow_storage_id string = storageAccount.id
