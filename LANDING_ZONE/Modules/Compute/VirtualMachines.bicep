//=======This bicep file creates a Virtual Machine =======//

//=================Params=================//

//global params
param adminUsername string
param adminpass string
param tags object
param OSVersion string
param vmSize string
param location string
param vmName string
param storageAccountName string
param nicName string
param nicSubnetId string
param workspace_id string
param workspace_id2 string
param workspace_key string
//param dnsLabelPrefixvm string

//===============End Params===============//

//Create the Storage Account
resource stg 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

//Create the NIC
resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          /*
          publicIPAddress: {
            id: pip.id
          }
          */
          subnet: {
            id: nicSubnetId 
          }
        }
      }
    ]
  }
}

//Create the VM
resource vm_001 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminpass
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'

        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: stg.properties.primaryEndpoints.blob
      }
    }
  }
}

output vm_001_id string = vm_001.id

//=========================//
//Onboard to VM Insights
//=========================//

param osType string = 'windows'

//var VmName_var = split(vm_001.id, '/')[8]
var DaExtensionName = ((toLower(osType) == 'windows') ? 'DependencyAgentWindows' : 'DependencyAgentLinux')
var DaExtensionType = ((toLower(osType) == 'windows') ? 'DependencyAgentWindows' : 'DependencyAgentLinux')
var DaExtensionVersion = '9.5'
var MmaExtensionName = ((toLower(osType) == 'windows') ? 'MMAExtension' : 'OMSExtension')
var MmaExtensionType = ((toLower(osType) == 'windows') ? 'MicrosoftMonitoringAgent' : 'OmsAgentForLinux')
var MmaExtensionVersion = ((toLower(osType) == 'windows') ? '1.0' : '1.4')


resource daExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: vm_001
  name: DaExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: DaExtensionType
    typeHandlerVersion: DaExtensionVersion
    autoUpgradeMinorVersion: true
  }
}

resource mmaExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: vm_001
  name: MmaExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: MmaExtensionType
    typeHandlerVersion: MmaExtensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: workspace_id2
      azureResourceId: vm_001.id
      stopOnMultipleConnections: true
    }
    protectedSettings: {
      workspaceKey: workspace_key
    }
  }
}

resource diagnosticSetting 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: vm_001
  name: 'vm_diagnostic_settings_01'
  properties: {
    workspaceId: workspace_id
    logs: [
      /*
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
      */
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
