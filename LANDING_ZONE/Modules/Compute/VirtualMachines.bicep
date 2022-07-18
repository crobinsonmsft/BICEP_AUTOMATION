//=======This bicep file creates a Virtual Machine =======//

//=================Params=================//

//global params
param adminUsername string
param adminPassword string
param tags object
param OSVersion string
param vmSize string
param location string
param vmName string
param storageAccountName string
param nicName string
param nicSubnetId string
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
            //id: resourceId('Microsoft.Network/virtualNetworks/subnets', vn.name, subnetName)
            id: nicSubnetId 
          }
        }
      }
    ]
  }
}

//Create the VM
resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
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
      adminPassword: adminPassword
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

//output hostname string = pip.properties.dnsSettings.fqdn
