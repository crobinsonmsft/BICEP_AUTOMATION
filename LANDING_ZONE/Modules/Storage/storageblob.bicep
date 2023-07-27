param storageAccountName_01 string
param containerName_01 string
param location string
param tags object

/*
var allBlobDownloadSAS = listAccountSAS(storageAccountName_01, '2022-09-01', {
  signedProtocol: 'https'
  signedResourceTypes: 'sco'
  signedPermission: 'rl'
  signedServices: 'b'
  signedExpiry: '2024-01-01T00:00:00Z'
}).accountSasToken

output sasToken string = allBlobDownloadSAS 
//var DSCSAS = storageAccountName.outputs.sasToken
*/

resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName_01
  kind: 'StorageV2'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  
  properties: {
    accessTier: 'Hot'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${sa.name}/default/${containerName_01}'
}


output stg_id string =  sa.id
output container_id string = container.id

