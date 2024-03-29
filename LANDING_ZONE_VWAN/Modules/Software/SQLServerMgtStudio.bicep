//=======This bicep file installs SQL Server Management Studio on a Windows VM=======//

//=================Params=================//
param location string
param vmName string
var cmd = 'powershell.exe -ExecutionPolicy Unrestricted -File SSMS.ps1'

///===============End Params===============//



//=========== Start SSMS Install ==========//

resource cmd_run 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: '${vmName}/SSMS'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/crobinsonmsft/BICEP_AUTOMATION/main/LANDING_ZONE/Scripts/SSMS.ps1'
      ]
      commandToExecute: cmd
    } 
  }
}

