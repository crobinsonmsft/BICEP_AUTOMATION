//=======This bicep file Installs IIS on a Windows VM=======//

//=================Params=================//
param location string
param vmName string
var IISInstallandConfigure = 'powershell.exe -ExecutionPolicy Unrestricted -File installWebServer.ps1'

///===============End Params===============//



//=========== Start IIS Install ==========//

resource IISInstall 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: '${vmName}/InstallIIS'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/tutorial-vm-extension/installWebServer.ps1'
      ]
      commandToExecute: IISInstallandConfigure
    } 
  }
}
