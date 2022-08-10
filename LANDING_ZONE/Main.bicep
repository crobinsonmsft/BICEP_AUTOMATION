//=====================================================================================================//
//===========THIS MAIN BICEP FILE CAN ORCHESTRATE THE DEPLOYMENT OF MULTIPLE AZURE SERVICES============//
//=====================================================================================================//

targetScope = 'subscription'        // We will deploy these modules against our subscription
                                    //Can't use decorator here.  Can be managementgroup, 
                                    //subscription or resourcegroup

//=====================================================================================================//
//========================================= START OF PARAMETERS =======================================//
//=====================================================================================================//


//============================================================//
//=======================Global Parameters====================//

  //Environment Parameters

    @allowed([
      'Production'
      'Development'
      'Sandbox'
    ])
    @description('Defines the environment classification our deployment will be based on')
    param env string = 'Development'  // Set this value

    //---------------------------------//

    param env_prefix object = {
      Production: {
        envPrefix : 'PRD'
      }
      Development: {
        envPrefix: 'DEV'
      }
      Sandbox: {
        envPrefix: 'SBX'
      }
    }

  //Location

    @allowed([
      'eastus'
      'eastus2'
      'westus2'
    ])
    @description('Select the Azure region to deploy to')
    //param location string = resourceGroup().location  //Will use the location of the resource group if resource group targeted. Comment this out if targeting subscription or mgt group
    param location string = 'eastus'                    // Location that resource will be deployed to.  This location param will drive the entire deployment

  //Tagging object

    param tags object = {                               // Edit tags accordingly
      Environment: env
      Owner: 'Calvin Robinson'
      org: 'ABC-Corp'
    }

//============================================================//
//====================End Global Parameters===================//


//============================================================//
//===================Begin Resource Parameters================//

  //=======Resource Group Parameters=====//

    var rg_01_name = 'RG-CONNECTIVITY-${env_prefix[env].envPrefix}-001'
    var rg_02_name = 'RG-MANAGEMENT-${env_prefix[env].envPrefix}-001'
    var rg_03_name = 'RG-RESOURCE-${env_prefix[env].envPrefix}-001'

//============================================================//
//===================Networking Parameters====================//

  //======NSG Parameters======//
    
    var nsg_bastion_name = 'NSG-BASTION-${env_prefix[env].envPrefix}-001'
    var nsg_private_name = 'NSG-PRIVATE-${env_prefix[env].envPrefix}-001'
    var nsg_public_name = 'NSG-PUBLIC-${env_prefix[env].envPrefix}-001'


  //=====VNET Parameters=====//

    //HUB VNET Parameters
      param vnet_hub_name string = 'VNET-HUB-${env_prefix[env].envPrefix}'   //Desired name of the vnet
      param vnet_hub_address_space string = '10.0.0.0/20'          //Address space for entire vnet

    //HUB Subnet Parameters
      //Names
        param subnet_hub_gw_name string = 'GatewaySubnet'         //Name for Gateway Subnet - this must ALWAYS be GatewaySubnet
        param subnet_hub_fw_name string = 'AzureFirewallSubnet'   //Name for Azure Firewall Subnet - this must ALWAYS be AzureFirewallSubnet
        param subnet_hub_bas_name string = 'AzureBastionSubnet'   //Name for Azure Bastion Subnet - this must ALWAYS be AzureBastionSubnet
        param subnet_hub_ss_name string = 'SharedServicesSubnet'  //Name for Shared Services Subnet - Would host AD, DNS, etc.

      //Addresses
        param subnet_hub_gw_adress_space string = '10.0.0.0/24'   //Subnet address space for Gateway Subnet
        param subnet_hub_fw_address_space string = '10.0.1.0/24'  //Subnet address space for Azure Firewall Subnet
        param subnet_hub_bas_address_space string = '10.0.2.0/24' //Subnet address space for Bastion Subnet
        param subnet_hub_ss_address_space string = '10.0.3.0/24'  //Subnet address space for Public Subnet

    //SPOKE 001 VNET Parameters
      param vnet_spoke_001_name string = 'VNET-SPOKE-${env_prefix[env].envPrefix}-001'   //Desired name of the vnet
      param vnet_spoke_001_address_space string = '10.1.0.0/20'          //Address space for entire vnet

    //SPOKE 001 Subnet Parameters
      var subnet_spoke_001_name = 'WEB-VMs-${env_prefix[env].envPrefix}-001'                             //Name for Gateway Subnet - this must ALWAYS be GatewaySubnet
      param subnet_spoke_001_address_space string = '10.1.0.0/24'           //Subnet address space for Gateway Subnet


//=======Peering Parameters========//

  param peering_name_hub_to_spoke_001 string = '${vnet_hub_name}/${vnet_hub_name}-peering-to-${vnet_spoke_001_name}'      // hub to spoke 001 peering name
  param peering_name_spoke_001_to_hub string = '${vnet_spoke_001_name}/${vnet_spoke_001_name}-peering-to-${vnet_hub_name}'      // spoke 001 to hub peering name

  // Hub to Spoke Params 
  param huballowForwardedTraffic bool = true
  param huballowGatewayTransit bool = true
  param huballowVirtualNetworkAccess bool = true
  param hubdoNotVerifyRemoteGateways bool = false
  param hubpeeringState string = 'Connected'
  param hubuseRemoteGateways bool = false    


  // Spoke to Hub Params
  param spokeallowForwardedTraffic bool = true
  param spokeallowGatewayTransit bool = false
  param spokeallowVirtualNetworkAccess bool = true
  //param spokedoNotVerifyRemoteGateways bool = true
  param spokepeeringState string = 'Connected'
  param spokeuseRemoteGateways bool = false   // Should be true unless you have no gateway in the hub

//Public IP Address Parameters
var publicIPAddressName = 'PUB-IP-${env_prefix[env].envPrefix}-BASTION'
param publicIPsku string = 'Standard'   //Should be Standard for Bastion Usage
param publicIPAllocationMethod string = 'Static' //Should be Static for Bastion Usage
param publicIPAddressVersion string = 'IPv4'
param dnsLabelPrefix string = 'bastionpubip' //Unique DNS Name for the Public IP used to access the Virtual Machine

//Bastion Host Parameters
var bastionName = 'BASTION-${env_prefix[env].envPrefix}-001'


//============================================================//
//===================Begin Monitoring Parameters================//

param subscription_scopes_array object = {
  Production: {
    subscription : '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a'   //Visual Studio Enterprise Subscription
  }
  Development: {
    subscription: '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a'   //Visual Studio Enterprise Subscription
  }
  Sandbox: {
    subscription: '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a'   //Visual Studio Enterprise Subscription
  }
}

  //==Action Group Parameters==//
  @description('Enter Emails or Distribution lists in SMTP format to direct Email alerts to.')
  param emailAddress array = [] // Sensitive.  Supply at command line

  @description('Enter phone number in numerical format to direct SMS alerts to.')
  param sms array = [] // Sensitive.  Supply at command line

  param ag_admins_name string = 'Admins'    //Name of Action Group


  //Log Analytics Workspace
  @description('The name of the Log Analytics Workspace')
  param workspaceName string = 'LAW-${env_prefix[env].envPrefix}-001'            //Name of the Log Analytics Workspace
  @allowed([
    'PerGB2018'
  ])
  param logAnalyticsWorkspaceSku string = 'PerGB2018'


  //VM Insights Parameters
  param vmInsights_ object = {
    name: 'VMInsights(${workspaceName})'
    galleryName: 'VMInsights'
  }


//=====CPU Alerting Parameters=//

param metricAlerts_vm_cpu_percentage_name string = 'vm_cpu_percentage'    //Name of the Alert
param vmCpuPercentageAlert_location string = 'global'        //Region alert will apply to
param vmCpuPercentageAlert_severity int = 2                          //Severity Level {0-Critical, 1-Error, 2-Warning, 3-Informational, 4-Verbose}
param vmCpuPercentageAlert_enabled bool = true

param vmCpuPercentageAlert_scopes array = [
  subscription_scopes_array[env].subscription
]
param vmCpuPercentageAlert_evaluationFrequency string = 'PT5M'     //How Often Alert is Evaluated in ISO 8601 format
param vmCpuPercentageAlert_windowSize string = 'PT15M'             //The period of time (in ISO 8601 duration format) that is used to monitor alert activity based on the threshold
param vmCpuPercentageAlert_threshold int = 70
param vmCpuPercentageAlert_targetResourceRegion string = location

//=======VM System State Alerting Parameters===//

@description('Name of the alert')
@minLength(1)
param vmSysStateAlertName string = 'VM_is_OFFLINE_and_UNRESPONSIVE'

@description('Description of alert')
param vmSysStateAlertDescription string = 'VM that is offline or unresponsive will generate an alert'

@description('Severity of alert {0,1,2,3,4}')
@allowed([
  0
  1
  2
  3
  4
])
param vmSysStateAlertSeverity int = 0   //Severity Level {0-Critical, 1-Error, 2-Warning, 3-Informational, 4-Verbose}

@description('Enable or Disable the VM State Alert')
param vmSysStateAlertEnabled bool = true
param vmSysStateAlertScope_ids string = subscription_scopes_array[env].subscription

@description('how often the metric alert is evaluated represented in ISO 8601 duration format')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param vmSysStateAlertEvalFrequency string = 'PT5M'

@description('The amount of time since the last failure was encounterd')
param vmSysStateAlertQueryInterval string = '2m'

//====================================================//
//==========Backup and Recovery Parameters============//


    //Backup Parameters
    @allowed([
      'GeoRedundant' 
      'LocallyRedundant'
      'ReadAccessGeoZoneRedundant'
      'ZoneRedundant'
    ])
    param BackupType string = 'LocallyRedundant'
    var backupPolicyName = 'ABC-VM-${env_prefix[env].envPrefix}-DefaultBackup'
    param vaultName string = 'RSV-${env_prefix[env].envPrefix}-001'
    param vaultSku object = {
      name: 'RS0'
      tier: 'Standard'
    }


//========================================================//
//==============Compute and Storage Parameters============//

//Virtual Machine
@description('Username for the Virtual Machine.')
param adminUsername string = 'azureadmin'

@description('Password for the Virtual Machine.')
@minLength(12)
//@secure()
param adminpass string = 'Incredibl3#512ABC'

@description('Name of the virtual machine.')
param vmName string = 'VM-${env_prefix[env].envPrefix}-004'

/*
@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefixvm string = toLower('${vmName}-${uniqueString(rg_03_name, vmName)}')
*/

/*
@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'myPublicIP'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'
*/

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
'2008-R2-SP1'
'2008-R2-SP1-smalldisk'
'2012-Datacenter'
'2012-datacenter-gensecond'
'2012-Datacenter-smalldisk'
'2012-datacenter-smalldisk-g2'
'2012-Datacenter-zhcn'
'2012-datacenter-zhcn-g2'
'2012-R2-Datacenter'
'2012-r2-datacenter-gensecond'
'2012-R2-Datacenter-smalldisk'
'2012-r2-datacenter-smalldisk-g2'
'2012-R2-Datacenter-zhcn'
'2012-r2-datacenter-zhcn-g2'
'2016-Datacenter'
'2016-datacenter-gensecond'
'2016-datacenter-gs'
'2016-Datacenter-Server-Core'
'2016-datacenter-server-core-g2'
'2016-Datacenter-Server-Core-smalldisk'
'2016-datacenter-server-core-smalldisk-g2'
'2016-Datacenter-smalldisk'
'2016-datacenter-smalldisk-g2'
'2016-Datacenter-with-Containers'
'2016-datacenter-with-containers-g2'
'2016-datacenter-with-containers-gs'
'2016-Datacenter-zhcn'
'2016-datacenter-zhcn-g2'
'2019-Datacenter'
'2019-Datacenter-Core'
'2019-datacenter-core-g2'
'2019-Datacenter-Core-smalldisk'
'2019-datacenter-core-smalldisk-g2'
'2019-Datacenter-Core-with-Containers'
'2019-datacenter-core-with-containers-g2'
'2019-Datacenter-Core-with-Containers-smalldisk'
'2019-datacenter-core-with-containers-smalldisk-g2'
'2019-datacenter-gensecond'
'2019-datacenter-gs'
'2019-Datacenter-smalldisk'
'2019-datacenter-smalldisk-g2'
'2019-Datacenter-with-Containers'
'2019-datacenter-with-containers-g2'
'2019-datacenter-with-containers-gs'
'2019-Datacenter-with-Containers-smalldisk'
'2019-datacenter-with-containers-smalldisk-g2'
'2019-Datacenter-zhcn'
'2019-datacenter-zhcn-g2'
'2022-datacenter'
'2022-datacenter-azure-edition'
'2022-datacenter-azure-edition-core'
'2022-datacenter-azure-edition-core-smalldisk'
'2022-datacenter-azure-edition-smalldisk'
'2022-datacenter-core'
'2022-datacenter-core-g2'
'2022-datacenter-core-smalldisk'
'2022-datacenter-core-smalldisk-g2'
'2022-datacenter-g2'
'2022-datacenter-smalldisk'
'2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter'


@description('Size of the virtual machine.')
param vmSize string = 'Standard_B2s'      //azureprice.net - reference for full list and costs

param storageAccountName string = 'bootdiags${uniqueString(subscription().subscriptionId)}'
param nicName string = '${vmName}-nic'


//=========================================================================================//
//=========================================================================================//
//=========================================================================================//
//=========================================================================================//
//=========================================================================================//
//=========================================================================================//
//================================== START OF MODULES =====================================//
//=========================================================================================//
//=========================================================================================//
//=========================================================================================//
//=========================================================================================//
//=========================================================================================//
//=========================================================================================//

//===========================================//
//===Start of Resource Group Modules====//
//===========================================//
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
//===========================================//
//======End of Resource Group Modules====//
//===========================================//

//===========================================//
//=======Start of Network Modules=======//
//===========================================//

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
      vnet_hub
      //route_table
    ]
  }

  //===Peering Modules

    //Peering Module Spoke to Hub
    module peering_spoke_to_hub 'Modules/Network/Peerings/peering_spoke_to_hub.bicep' = {
      name: 'peering_module_spoke_to_hub'
      scope: resourceGroup(rg_01_name)     
      params: {
        peering_name_spoke_to_hub : peering_name_spoke_001_to_hub     // spoke 001 to hub peering name
        vnet_hub_id: vnet_hub.outputs.vnet_hub_id
        spokeallowForwardedTraffic : spokeallowForwardedTraffic
        spokeallowGatewayTransit : spokeallowGatewayTransit
        spokeallowVirtualNetworkAccess : spokeallowVirtualNetworkAccess
        //spokedoNotVerifyRemoteGateways : spokedoNotVerifyRemoteGateways
        spokepeeringState : spokepeeringState
        spokeuseRemoteGateways : spokeuseRemoteGateways
      }
      dependsOn: [
        vnet_spoke_001
        //route_table
      ] 
    }


    // Peering Hub to Spoke
    module peering 'Modules/Network/Peerings/peering_hub_to_spoke.bicep' = {
      name: 'peering_module_hub_to_spoke'
      //scope: resourceGroup('13a5d4c6-e4eb-4b92-9b1a-e044fe55d79c', 'tss-hub-rsg-network-01')     
      scope: resourceGroup(rg_01_name)
      params: {
        peering_name_hub_to_spoke : peering_name_hub_to_spoke_001      // hub to spoke 001 peering name
        vnet_spoke_id: vnet_spoke_001.outputs.vnet_spoke_001_id
        huballowForwardedTraffic : huballowForwardedTraffic
        huballowGatewayTransit : huballowGatewayTransit
        huballowVirtualNetworkAccess : huballowVirtualNetworkAccess
        hubdoNotVerifyRemoteGateways : hubdoNotVerifyRemoteGateways
        hubpeeringState : hubpeeringState
        hubuseRemoteGateways : hubuseRemoteGateways
      }
      dependsOn: [
        vnet_hub
        vnet_spoke_001
      ] 
    }

    /*
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
  */

  /*
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
        vnet_spoke_001
        publicIP
      ]
  } 
*/

//===========================================//
//=========End of Network Modules=======//
//===========================================//

//===========================================//
//=======Start of Backup and Recovery Modules=======//
//===========================================//

/*
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
      env_prefix: env_prefix[env].envPrefix
    }
    dependsOn: [
      rsv_001
    ]
  }
  */
//===========================================//
//====End  of Backup and Recovery Modules====//
//===========================================//

//===========================================//
//=======Start of Compute Modules=======//
//===========================================//


  module vm_001 'Modules/Compute/VirtualMachines.bicep' = {
    name: 'vm_001-module'
    scope: resourceGroup(rg_03_name)
    
    params: {
      adminUsername: adminUsername
      adminpass: adminpass
      vmName: vmName
      storageAccountName: storageAccountName
      OSVersion: OSVersion
      vmSize: vmSize
      nicName: nicName
      tags: tags
      location: location
      nicSubnetId: vnet_spoke_001.outputs.subnet_spoke_001_id
      workspace_id2 : law.outputs.workspaceIdOutput
      workspace_key: law.outputs.workspaceKeyOutput
    }
    dependsOn: [
      vnet_spoke_001
    ]
  }

//===========================================//
//=======Start of Monitoring and Alerting Modules=======//  
//===========================================//

//Action Group to direct SMTP and SMS alerts to
module action_group 'Modules/Monitoring/action_group.bicep' = {
  name: 'action_group-module'
  scope: resourceGroup(rg_02_name)
  params: {
    tags: tags
    actionGroups_Admins_name: ag_admins_name
    emailAddress: emailAddress
    sms: sms
  }
  dependsOn: [
    rg
  ]
}

//Log Analytics Workspace
module law 'Modules/Log_Analytics/LogAnalytics.bicep' = {
  name: 'law-module'
  scope: resourceGroup(rg_02_name)
  params: {
    tags: tags
    location: location
    logAnalyticsWorkspaceSku: logAnalyticsWorkspaceSku
    workspaceName: workspaceName
  }
  dependsOn: [
      rg
    ]
}

//VM Insights Module
module vmInsights 'Modules/Log_Analytics/vmInsights.bicep' = {
  name: 'vm-insights-module'
  scope: resourceGroup(rg_02_name)
  params: {
    tags: tags
    location: location
    workspaceName: workspaceName
    vmInsights : vmInsights_
    workspace_id : law.outputs.workspace_id
  }
  dependsOn: [
      law
    ]
}

module monitoring_cpu 'Modules/Monitoring/monitoring_vmCpu.bicep' = {
  name: 'monitoring_cpu_module'
  scope: resourceGroup(rg_02_name)
  params: {
    metricAlerts_vm_cpu_percentage_name : metricAlerts_vm_cpu_percentage_name
    actiongroups_externalid : action_group.outputs.actionGroups_Admins_name_resource_id
    vmCpuPercentageAlert_location : vmCpuPercentageAlert_location
    vmCpuPercentageAlert_severity : vmCpuPercentageAlert_severity
    vmCpuPercentageAlert_enabled : vmCpuPercentageAlert_enabled
    vmCpuPercentageAlert_scopes : vmCpuPercentageAlert_scopes
    vmCpuPercentageAlert_evaluationFrequency : vmCpuPercentageAlert_evaluationFrequency
    vmCpuPercentageAlert_windowSize : vmCpuPercentageAlert_windowSize
    vmCpuPercentageAlert_threshold : vmCpuPercentageAlert_threshold
    vmCpuPercentageAlert_targetResourceRegion : vmCpuPercentageAlert_targetResourceRegion
  }
  dependsOn: [
    action_group
  ]
}

module monitoring_vm_system_state 'Modules/Monitoring/monitoring_vmSystemState.bicep' = {
  name: 'monitoring_vm_system_state_module'
  scope: resourceGroup(rg_02_name)
  params: {
    vmSysStateAlertName : vmSysStateAlertName
    location : location
    tags : tags
    vmSysStateAlertDescription : vmSysStateAlertDescription
    vmSysStateAlertSeverity : vmSysStateAlertSeverity
    vmSysStateAlertEnabled : vmSysStateAlertEnabled
    vmSysStateAlertScope_ids : vmSysStateAlertScope_ids
    vmSysStateAlertEvalFrequency : vmSysStateAlertEvalFrequency
    actiongroups_externalid : action_group.outputs.actionGroups_Admins_name_resource_id
    vmSysStateAlertQueryInterval : vmSysStateAlertQueryInterval
  }
  dependsOn: [
    action_group
  ]
}

