
param stg string
param tags object
param location string
param vmName string
param containerName string

var _artifactsLocationSasToken = stg.listServiceSAS('2021-04-01', {
  canonicalizedResource: '/blob/${stg.name}/${containerName}'
  signedResource: 'c'
  signedProtocol: 'https'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: dateTimeAdd(baseTime, 'PT1H')
}).serviceSasToken 


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
        url: '${stg.properties.primaryEndpoints.blob}${containerName}/MgmtTools.ps1.zip' 
        script: 'common.ps1' 
        function: 'Common' 
      }
      configurationArguments: {}
    }
    protectedSettings: {
      configurationUrlSasToken: '?${_artifactsLocationSasToken}' 
    }
  }
}
