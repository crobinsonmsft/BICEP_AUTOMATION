//=======This bicep file Installs Windows Features using DSC=======//

//=================Params=================//
param location string
param vmName string
var cmd = 'powershell.exe -ExecutionPolicy Unrestricted -File test.ps1'

///===============End Params===============//



//=========== Start DSC Features Install ==========//


resource domainControllerConfiguration 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${vmName}/Microsoft.Powershell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: 'https://raw.githubusercontent.com/crobinsonmsft/BICEP_AUTOMATION/main/LANDING_ZONE/Scripts/MgmtTools.ps1.zip'
      ConfigurationFunction: 'MgmtTools.ps1\\Deploy-DomainServices'
      Properties: {
        domainFQDN: domainFQDN
        adminCredential: {
          UserName: adminUsername
          Password: 'PrivateSettingsRef:adminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
          adminPassword: adminPassword
      }
    }
  }
}
