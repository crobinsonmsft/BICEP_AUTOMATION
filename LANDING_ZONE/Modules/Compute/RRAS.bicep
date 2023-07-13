param location string
param vmName string


// Constructing the PowerShell commands to execute once VM is running
//var RRASInstallandConfigure = 'powershell.exe -ExecutionPolicy Unrestricted -File RRAS-Configuration.ps1 -localIP 172.1.0.4 -localSubnet "172.1.0.0/16" -peerPublicIP00 ${vHubVpnGatewayPublicIp00} -psk "rolightn3494" -peerPublicIP01 ${vHubVpnGatewayPublicIp01}'
var RRASInstallandConfigure = 'powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools'




// VM Extensions Here

resource RRASInstall 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  name: '${vmName}/InstallRRAS'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/DaFitRobsta/vWAN-Lab/master/artifacts/RRAS-Configuration.ps1'
      ]
      //  .\RRAS-Configuration.ps1 -localIP 172.1.0.4 -localSubnet "172.1.0.0/16" -peerPublicIP00 "20.150.153.222" -psk "rolightn3494" -peerPublicIP01 20.150.153.241
      // commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File RRAS-Configuration.ps1 -localIP 172.1.0.4 -localSubnet "172.1.0.0/16" -peerPublicIP00 "20.150.153.222" -psk "rolightn3494" -peerPublicIP01 20.150.153.241'
      commandToExecute: RRASInstallandConfigure
    } 
  }
}
