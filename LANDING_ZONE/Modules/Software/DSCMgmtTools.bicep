





resource dscExtension 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  location: location
  parent: vm
  name: 'Microsoft.Powershell.DSC'
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: '${stg.properties.primaryEndpoints.blob}${containerName}/common.ps1.zip' 
        script: 'common.ps1' 
        function: 'Common' 
      }
      configurationArguments: {}
    }
    protectedSettings: {
      configurationUrlSasToken: '?${_artifactsLocationSasToken}' 
    }
  }
