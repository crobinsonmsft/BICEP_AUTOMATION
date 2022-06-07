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
param env string = 'Production'                     // Set preferred environment here

@allowed([
  'PRD'
  'DEV'
  'SBX'
])
@description('Select the environment classification abbreviation. Ensure this is consistent with the environment that was previously selected')
param env_prefix string = 'PRD'

@allowed([
  'eastus'
  'eastus2'
  'westus2'
])
@description('Select the Azure region to deploy to')
//param location string = resourceGroup().location  //Will use the location of the resource group if resource group targeted. Comment this out if targeting subscription or mgt group
param location string = 'eastus'                    // Location that resource will be deployed to

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


//==Route Table Parameters==//
/*
param route_table_name string = '${subscriptionPrefix}rtbl-default-01'    //Set Route Table Name here
param bgp_disable bool = true                                             //Disable BGP route propogation?
param bgp_override bool = false
param nextHopType string = 'VirtualAppliance'
*/
//=====VNET Parameters=====//

//HUB VNET Parameters
param vnet_hub_name string = 'VNET-HUB-${env_prefix}-001'   //Desired name of the vnet
//param vnet_hub_id string = '/subscriptions/13a5d4c6-e4eb-4b92-9b1a-e044fe55d79c/resourceGroups/tss-hub-rsg-network-01/providers/Microsoft.Network/virtualNetworks/tss-hub-vnt-10.204.0.0_22'
param vnet_hub_address_space string = '10.0.0.0/20'          //Address space for entire vnet
//param vnet_hub_address_space_underscore string = replace(vnet_hub_address_space, '/', '_')        //Same as hub address space except that it includes an Azure name friendly underscore

//HUB Subnet Parameters
param subnet_hub_gw_name string = 'GatewaySubnet'                             //Name for Gateway Subnet - this must ALWAYS be GatewaySubnet
param subnet_hub_fw_name string = 'AzureFirewallSubnet'                       //Name for Azure Firewall Subnet - this must ALWAYS be AzureFirewallSubnet
param subnet_hub_bas_name string = 'AzureBastionSubnet'                   //Name for Azure Bastion Subnet - this must ALWAYS be AzureBastionSubnet
param subnet_ss_name string = 'Shared Services'                   //Name for Shared Services Subnet - Would host AD, DNS, etc.

param subnet_hub_gw_adress_space string = '10.0.0.0/24'           //Subnet address space for Gateway Subnet
param subnet_hub_fw_address_space string = '10.0.1.0/24'          //Subnet address space for Azure Firewall Subnet
param subnet_hub_bas_address_space string = '10.0.2.0/24'         //Subnet address space for Bastion Subnet
param subnet_hub_ss_address_space string = '10.0.3.0/24'           //Subnet address space for Public Subnet
            


/*
param peering_prefix_hub string = '10.204.0.0/22'                 //Address space for Peering Connections between spoke vnet and hub
param peering_prefix_hub_underscore string = replace(peering_prefix_hub, '/', '_')        //Same as peering prefix except that it includes an Azure name friendly underscore
*/

//==========================================//
//=====Monitoring and Alerting Parameters===//

//==Action Group Parameters==//

/*
param emailAddress array = [
  'EOTSS-DL-AzureCloudOpsSupport@mass.gov'        //The distribution group that will receive SMTP alert notifications
]
param sms array = [
  '9002022020'
  '8001232345'
]
*/

//=Log Analytics Workspace Parameters=//



//===========================================//
//==============Backup Parameters============//
/*
param vaultName string = 'TEST-VAULT2'      //Name of the Recovery Services Vault
@allowed([
  'GeoRedundant' 
  'LocallyRedundant'
  'ReadAccessGeoZoneRedundant'
  'ZoneRedundant'
])
param BackupType string = 'LocallyRedundant'
param policyName string = 'TSS-VM-DefaultBackup'
param sku object = {
  name: 'RS0'
  tier: 'Standard'
}
*/
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

//=======Start of Network Modules=======//


  //NSG Module
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

  
/*
  //Route Table Module
  module route_table 'Modules/Network/Route_Tables/route_table.bicep' = {
    name: 'route_table-module'
      params: {
        tags: tags
        location: location
        route_table_name: route_table_name
        bgp_disable: bgp_disable
        bgp_override: bgp_override
        nextHopType: nextHopType
        peering_prefix_hub: peering_prefix_hub
        peering_prefix_hub_underscore: peering_prefix_hub_underscore
        subscriptionPrefix : subscriptionPrefix
        vnet_address_space : vnet_address_space
        vnet_address_space_underscore : vnet_address_space_underscore
      }
  }
*/

  //VNET Module
  module vnet 'Modules/Network/VNet/VNet.bicep' = {
    name: 'vnet-module'
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
      subnet_ss_name : subnet_ss_name
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


/*
  //Peering Module
  module peering 'Modules/Network/Peerings/peering.bicep' = {
    name: 'peering_module'
      params: {
        name: '${vnet_name}/${vnet_name}-to-tss-hub-vnt-${peering_prefix_hub_underscore}'
        peering_prefix_hub : peering_prefix_hub
        vnet_hub_id: vnet_hub_id


      }
   dependsOn: [
     vnet
   ] 
  }

*/

//=======Start of Monitoring and Alerting Modules=======//      //Commented out to isolate testing to networking

/*

module action_group 'Monitoring/action_group.bicep' = {
  name: 'action_group-module'
  params: {
    tags: tags
    location: location
    emailAddress: emailAddress
    sms: sms
  }
}

module law 'analytics_workspace.bicep' = {
  name: 'law-module'
  params: {
    tags: tags
    location: location
  }
  dependsOn: [
      action_group
    ]
}

*/

//=======Start of Backup Modules=======//      

/*
module backup 'BackUp/backup_policies.bicep' = {
  name: 'backup-module'
  params: {
    tags: tags
    location: location
    vaultName: vaultName
    BackupType: BackupType
    policyName: policyName
    sku: sku
  }
}
*/
