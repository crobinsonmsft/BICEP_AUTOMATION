


param vmName string
param location string
param userAssignedManagedIdentityName string

resource windowsAgent 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: '${vmName}/AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': userAssignedManagedIdentityName
        }
      }
    }
  }
}
