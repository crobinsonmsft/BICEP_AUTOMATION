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


//=====VNET Parameters=====//

//HUB VNET Parameters
param vnet_hub_name string = 'VNET-HUB-${env_prefix}-001'   //Desired name of the vnet
param vnet_hub_address_space string = '10.0.0.0/20'          //Address space for entire vnet


//HUB Subnet Parameters
param subnet_hub_gw_name string = 'GatewaySubnet'                             //Name for Gateway Subnet - this must ALWAYS be GatewaySubnet
param subnet_hub_fw_name string = 'AzureFirewallSubnet'                       //Name for Azure Firewall Subnet - this must ALWAYS be AzureFirewallSubnet
param subnet_hub_bas_name string = 'AzureBastionSubnet'                   //Name for Azure Bastion Subnet - this must ALWAYS be AzureBastionSubnet
param subnet_ss_name string = 'SharedServicesSubnet'                   //Name for Shared Services Subnet - Would host AD, DNS, etc.

param subnet_hub_gw_adress_space string = '10.0.0.0/24'           //Subnet address space for Gateway Subnet
param subnet_hub_fw_address_space string = '10.0.1.0/24'          //Subnet address space for Azure Firewall Subnet
param subnet_hub_bas_address_space string = '10.0.2.0/24'         //Subnet address space for Bastion Subnet
param subnet_hub_ss_address_space string = '10.0.3.0/24'           //Subnet address space for Public Subnet
            


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
  module vnet 'Modules/Network/VNet/VNet-Hub.bicep' = {
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

  //=========End of Network Modules=======//

  //=======Start of Backup Modules=======//
