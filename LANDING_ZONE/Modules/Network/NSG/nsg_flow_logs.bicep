//=======This bicep file creates an NSG Flow Log=======//

//=================Params=================//
param networkWatcherName string
param flowLogName string
param location string
param existingNSG string
param retentionDays int
param storageAccountNameNsg string
param flowLogsVersion int
param storageAccountType string

//===============End Params===============//

//======== Start Resource Creation =======//
//Storage Account


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountNameNsg
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}


resource networkWatcher 'Microsoft.Network/networkWatchers@2022-01-01' = {
  name: networkWatcherName
  location: location
  properties: {}
}

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2022-01-01' = {
  name: '${networkWatcherName}/${flowLogName}'
  location: location
  properties: {
    targetResourceId: existingNSG
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
