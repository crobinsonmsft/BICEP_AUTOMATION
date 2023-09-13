
param storageAccountName string
param tags object
param location string
param vmName string
param containerName string

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

/*
var allBlobDownloadSAS = listAccountSAS(storageAccountName, '2022-09-01', {
  signedProtocol: 'https'
  signedResourceTypes: 'sco'
  signedPermission: 'rl'
  signedServices: 'b'
  signedExpiry: '2024-01-01T00:00:00Z'
}).accountSasToken

output sasToken string = allBlobDownloadSAS 
var DSCSAS = storageAccountName.outputs.sasToken
*/


resource dscExtension 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  location: location
  //parent: vmName
  name: '${vmName}/Microsoft.Powershell.DSC'
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        //url: '${stg.properties.primaryEndpoints.blob}${containerName}/MgmtTools.ps1.zip' 
        url: 'https://raw.githubusercontent.com/crobinsonmsft/BICEP_AUTOMATION/main/LANDING_ZONE/Scripts/MgmtTools.ps1.zip'
        script: 'MgmtTools.ps1' 
        function: 'WebServerConfiguration' 
      }
      configurationArguments: {}
    }
  }
}
