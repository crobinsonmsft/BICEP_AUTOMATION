//Install SQL on an Azure VM using the Custom Script Extension Feature

//Params
param location string
param vmName string
param fileUrl string = 'https://raw.githubusercontent.com/majkinetor/Install-SqlServer/master/Install-SqlServer.ps1'
var PowershellString = 'powershell -ExecutionPolicy Bypass -File Install-SqlServer.ps1'


resource sqlInstall 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: '${vmName}/InstallSQL'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        fileUrl
      ]
      commandToExecute: PowershellString
    } 
  }
}
