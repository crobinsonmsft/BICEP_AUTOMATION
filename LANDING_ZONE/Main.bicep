//=========================================================================================//
//=====THIS MAIN BICEP FILE CAN ORCHESTRATE THE DEPLOYMENT OF MULTIPLE AZURE SERVICES======//
//=========================================================================================//

targetScope = 'subscription'                      // We will deploy these modules against our subscription

//=========================================================================================//
//================================== START OF PARAMETERS ==================================//
//=========================================================================================//


//===========================================//
//==============Global Parameters============//



@allowed([
  'Production'
  'Development'
  'Sandbox'
])
@description('Select the environment classification we will deploy to')
param env_array array = [
  'Production'  //0
  'Development' //1
  'Sandbox'     //2
]

param env string = env_array[0]  // 0 - Prod, 1 - Dev, 2 - Sandbox

@allowed([
  'PRD'
  'DEV'
  'SBX'
])
@description('Select the environment classification abbreviation. Ensure this is consistent with the environment that was previously selected')
param env_prefix_array array = [
  'PRD'
  'DEV'
  'SBX'
]


//param env_prefix_01 int = indexOf(env_array, env)

param env_prefix string = env_prefix_array[0]


@allowed([
  'eastus'
  'eastus2'
  'westus2'
])
@description('Select the Azure region to deploy to')
//param location string = resourceGroup().location  //Will use the location of the resource group if resource group targeted. Comment this out if targeting subscription or mgt group
param location string = 'eastus'                    // Location that resource will be deployed to.  This location param will drive the entire deployment

param tags object = {                               // Edit tags accordingly
  Environment: env
  Owner: 'Calvin Robinson'
  org: 'ABC-Corp'
}

//===========================================//
//===========End Global Parameters===========//

//=======Resource Group Parameters=====//

//Define your resource group names here
param rg_01_name string = 'RG-CONNECTIVITY-${env_prefix}-001'
param rg_02_name string = 'RG-MANAGEMENT-${env_prefix}-001'
param rg_03_name string = 'RG-RESOURCE-${env_prefix}-001'

//===========================================//
//==========Networking Parameters============//

//======NSG Parameters======//
//Define your NSG names here
param nsg_bastion_name string = 'NSG-BASTION-${env_prefix}-001'
param nsg_private_name string = 'NSG-PRIVATE-${env_prefix}-001'
param nsg_public_name string = 'NSG-PUBLIC-${env_prefix}-001'


//=====VNET Parameters=====//

//HUB VNET Parameters
param vnet_hub_name string = 'VNET-HUB-${env_prefix}'   //Desired name of the vnet
param vnet_hub_address_space string = '10.0.0.0/20'          //Address space for entire vnet

//HUB Subnet Parameters
param subnet_hub_gw_name string = 'GatewaySubnet'                             //Name for Gateway Subnet - this must ALWAYS be GatewaySubnet
param subnet_hub_fw_name string = 'AzureFirewallSubnet'                       //Name for Azure Firewall Subnet - this must ALWAYS be AzureFirewallSubnet
param subnet_hub_bas_name string = 'AzureBastionSubnet'                   //Name for Azure Bastion Subnet - this must ALWAYS be AzureBastionSubnet
param subnet_hub_ss_name string = 'SharedServicesSubnet'                   //Name for Shared Services Subnet - Would host AD, DNS, etc.

param subnet_hub_gw_adress_space string = '10.0.0.0/24'           //Subnet address space for Gateway Subnet
param subnet_hub_fw_address_space string = '10.0.1.0/24'          //Subnet address space for Azure Firewall Subnet
param subnet_hub_bas_address_space string = '10.0.2.0/24'         //Subnet address space for Bastion Subnet
param subnet_hub_ss_address_space string = '10.0.3.0/24'           //Subnet address space for Public Subnet

//SPOKE 001 VNET Parameters
param vnet_spoke_001_name string = 'VNET-SPOKE-${env_prefix}-001'   //Desired name of the vnet
param vnet_spoke_001_address_space string = '10.1.0.0/20'          //Address space for entire vnet

//SPOKE 001 Subnet Parameters
param subnet_spoke_001_name string = 'WEB-VMs-${env_prefix}-001'                             //Name for Gateway Subnet - this must ALWAYS be GatewaySubnet
param subnet_spoke_001_address_space string = '10.1.0.0/24'           //Subnet address space for Gateway Subnet

//Peering Parameters
param peering_name_hub_to_spoke_001 string = '${vnet_hub_name}/peering-to-${vnet_spoke_001_name}'      // hub to spoke 001 peering name
param peering_name_spoke_001_to_hub string = '${vnet_spoke_001_name}/peering-to-${vnet_hub_name}'      // spoke 001 to hub peering name
param allowForwardedTraffic bool = true
param allowGatewayTransit bool = false
param allowVirtualNetworkAccess bool = true
param doNotVerifyRemoteGateways bool = false
param peeringState string = 'Connected'
param useRemoteGateways bool = false    // would normally be true, but I have no gateway right now in the hub

//Public IP Address Parameters
param publicIPAddressName string = 'PUB-IP-${env_prefix}-BASTION'
param publicIPsku string = 'Standard'   //Should be Standard for Bastion Usage
param publicIPAllocationMethod string = 'Dynamic'
param publicIPAddressVersion string = 'IPv4'
param dnsLabelPrefix string = 'bastionpubip' //Unique DNS Name for the Public IP used to access the Virtual Machine

//Bastion Host Parameters
param bastionName string = 'BASTION-${env_prefix}'

//=====Backup and Recovery Parameters=====//

//Recovery Services Vault Parameters
param vaultName string = 'RSV-${env_prefix}-001'                //Name of the Recovery Services Vault
param vaultSku object = {
  name: 'RS0'
  tier: 'Standard'
}

//Backup Parameters
@allowed([
  'GeoRedundant' 
  'LocallyRedundant'
  'ReadAccessGeoZoneRedundant'
  'ZoneRedundant'
])
param BackupType string = 'LocallyRedundant'
param backupPolicyName string = 'ABC-VM-${env_prefix}-DefaultBackup'


//=========================================================================================//
//================================== START OF MODULES =====================================//
//=========================================================================================//

//===Start of Resource Group Modules====//
  //Resource Group Module
  module rg 'Modules/Resource_Groups/resourceGroups.bicep' = {
    name: 'rg-module'
      params: {
        tags: tags
        location: location
        rg_01_name: rg_01_name
        rg_02_name: rg_02_name
        rg_03_name: rg_03_name
      }
    }

//======End of Resource Group Modules====//

//=======Start of Network Modules=======//

  //NSG Module    // Creates all NSGs throughout deployment
  module nsg 'Modules/Network/NSG/NSGCreation.bicep' = {
  name: 'nsg-module'
  scope: resourceGroup(rg_01_name)
    params: {
      tags: tags
      location: location
      networkSecurityGroups_bastion_nsg_name: nsg_bastion_name
      networkSecurityGroups_public_nsg_name: nsg_private_name
      networkSecurityGroups_private_nsg_name: nsg_public_name
    }
    dependsOn: [
      rg
    ]
  }

  //VNET HUB Module
  module vnet_hub 'Modules/Network/VNet/VNet-Hub.bicep' = {
    name: 'vnet-hub-module'
    scope: resourceGroup(rg_01_name)
    params: {
      tags: tags
      location: location
      bastion_nsg_id: nsg.outputs.bastion_nsg_id
      //public_nsg_id: nsg.outputs.public_nsg_id
      private_nsg_id: nsg.outputs.private_nsg_id
      vnet_hub_name: vnet_hub_name
      vnet_hub_address_space : vnet_hub_address_space
      subnet_hub_gw_name : subnet_hub_gw_name
      subnet_hub_fw_name : subnet_hub_fw_name
      subnet_hub_bas_name : subnet_hub_bas_name
      subnet_ss_name : subnet_hub_ss_name
      subnet_hub_gw_adress_space : subnet_hub_gw_adress_space
      subnet_hub_fw_address_space : subnet_hub_fw_address_space
      subnet_hub_bas_address_space : subnet_hub_bas_address_space
      subnet_hub_ss_address_space : subnet_hub_ss_address_space
    }
    dependsOn: [
      rg
      nsg
      //route_table
    ]
  }

  //VNET Spoke 001 Module
  module vnet_spoke_001 'Modules/Network/VNet/VNet-Spoke-001.bicep' = {
    name: 'vnet-spoke_001-module'
    scope: resourceGroup(rg_01_name)
    params: {
      tags: tags
      location: location
      private_nsg_id: nsg.outputs.private_nsg_id
      vnet_spoke_001_name: vnet_spoke_001_name
      vnet_spoke_001_address_space : vnet_spoke_001_address_space
      subnet_spoke_001_name : subnet_spoke_001_name
      subnet_spoke_001_address_space : subnet_spoke_001_address_space
    }
    dependsOn: [
      rg
      nsg
      vnet_hub
      //route_table
    ]
  }

  //Peering Module
  module peering_001 'Modules/Network/Peerings/peering.bicep' = {
    name: 'peering_001-module'
    scope: resourceGroup(rg_01_name)
    params: {
      allowForwardedTraffic: allowForwardedTraffic
      allowGatewayTransit: allowGatewayTransit
      allowVirtualNetworkAccess: allowVirtualNetworkAccess
      doNotVerifyRemoteGateways:  doNotVerifyRemoteGateways
      peeringState: peeringState
      peering_name_hub_to_spoke_001 : peering_name_hub_to_spoke_001
      peering_name_spoke_001_to_hub : peering_name_spoke_001_to_hub
      vnet_hub_id: vnet_hub.outputs.vnet_hub_id
      vnet_spoke_001_id : vnet_spoke_001.outputs.vnet_spoke_001_id
      peering_prefix_hub: vnet_hub_address_space
      useRemoteGateways: useRemoteGateways
    }
    dependsOn: [
      rg
      nsg
      vnet_hub
      vnet_spoke_001
      //route_table
    ]
  }

  //Public IP Module    // Creates Public IP for Bastion
  module publicIP 'Modules/Network/Public_IP/Public_IP.bicep' = {
    name: 'public-ip-module'
    scope: resourceGroup(rg_01_name)
      params: {
        tags: tags
        location: location
        publicIPAddressName: publicIPAddressName
        publicIPsku: publicIPsku
        publicIPAllocationMethod : publicIPAllocationMethod
        publicIPAddressVersion : publicIPAddressVersion
        dnsLabelPrefix : dnsLabelPrefix
      }
      dependsOn: [
        rg
      ]
  }

  //Bastion Host Module
  module bastionHost 'Modules/Network/Bastion/bastion.bicep' = {
    name: 'bastion-host-module'
    scope: resourceGroup(rg_01_name)
      params: {
        tags: tags
        location: location
        bastionName: bastionName
        publicipid: publicIP.outputs.public_ip_id
        bastionSubnetid: '${vnet_hub.outputs.vnet_hub_id}/subnets/${subnet_hub_bas_name}'

      }
      dependsOn: [
        rg
        vnet_spoke_001
        publicIP
      ]
  } 


  //=========End of Network Modules=======//


  //=======Start of Backup and Recovery Modules=======//

  module rsv_001 'Modules/BackUp/RecoveryServicesVault.bicep' = {
    name: 'rsv-module'
    scope: resourceGroup(rg_02_name)
    params: {
      tags: tags
      location: location
      vaultName: vaultName
      sku: vaultSku
    }
    dependsOn: [
      rg
    ]
  }

module backup 'Modules/BackUp/backup_policies.bicep' = {
  name: 'backup-policies-module'
  scope: resourceGroup(rg_02_name)
  params: {
    vaultName: vaultName
    location: location
    tags: tags
    BackupType: BackupType
    backupPolicyName: backupPolicyName
    env_prefix: env_prefix
  }
  dependsOn: [
    rsv_001
  ]
}

  //=======End  of Backup and Recovery Modules=======//
