//=========================================================================================//
//=====THIS MAIN BICEP FILE CAN ORCHESTRATE THE DEPLOYMENT OF MULTIPLE AZURE SERVICES======//
//=========================================================================================//




targetScope = 'subscription'

//=========================================================================================//
//================================== START OF PARAMETERS ==================================//
//=========================================================================================//


//===========================================//
//==============Global Parameters============//
param subscriptionPrefix string = 'dot-edl-np-'         //Enter a dash formatted subscription prefix name
                                                    //Will be passed to any entry that requires subscription name
param subscriptionPrefix_underscore string = replace(subscriptionPrefix, '-', '_')        //Same as subscription prefix except that it includes an Azure name friendly underscore
                                                                                          //Don't modify this parameter!


@allowed([
  'Production'
  'Development'
  'Sandbox'
])
@description('Select the environment we will deploy to')
param environment string = 'Sandbox'                // Set preferred environment here

//param location string = resourceGroup().location  //Will use the location of the resource group
param location string = 'eastus'                    // Location that resource will be deployed to
param tags object = {                               // Edit tags accordingly
  Environment: environment
  Owner: 'Calvin Robinson'
  org: 'ABC-Corp'
}

//=======Resource Group Parameters=====//

//var env string = condition ? TrueValue : FalseValue
param env string = ((environment != 'Production' && environment != 'Development') ) ? 'SBX' : 'null' 

param rg_01_name string = 'RG-CONNECTIVITY-${env}-001'
param rg_02_name string = 'RG-MANAGEMENT-${env}-001'
param rg_03_name string = 'RG-RESOURCE-${env}-001'



//===========================================//
//==========Networking Parameters============//

//=====NSG Parameters=====//

//These params will combine to form the actual NSG names that are used in the NSG module below



param bastion_prefix_underscore string = replace(subnet_bastion_prefix, '/', '_')     //Same as subnet_bastion_prefix except that it includes an Azure name friendly underscore
param db_prefix_underscore string = replace(subnet_db_prefix, '/', '_')               //Same as subnet_db_prefix except that it includes an Azure name friendly underscore
param public_prefix_underscore string = replace(subnet_pub_prefix, '/', '_')          //Same as subnet_public_prefix except that it includes an Azure name friendly underscore
param private_prefix_underscore string = replace(subnet_priv_prefix, '/', '_')        //Same as subnet_private_prefix except that it includes an Azure name friendly underscore

param nsg_name array = [
  '${subscriptionPrefix}snt-bastion-${bastion_prefix_underscore}-nsg'     // Bastion
  '${subscriptionPrefix}snt-db-${db_prefix_underscore}-nsg'               // DB
  '${subscriptionPrefix}snt-public-${public_prefix_underscore}-nsg'       // Public
  '${subscriptionPrefix}snt-private-${private_prefix_underscore}-nsg'     // Private
]

//==Route Table Parameters==//

param route_table_name string = '${subscriptionPrefix}rtbl-default-01'    //Set Route Table Name here
param bgp_disable bool = true                                             //Disable BGP route propogation?
param bgp_override bool = false
param nextHopType string = 'VirtualAppliance'

//=====VNET Parameters=====//

param vnet_name string = '${subscriptionPrefix}vnt-${vnet_address_space_underscore}'   //Desired name of the vnet
param vnet_hub_id string = '/subscriptions/13a5d4c6-e4eb-4b92-9b1a-e044fe55d79c/resourceGroups/tss-hub-rsg-network-01/providers/Microsoft.Network/virtualNetworks/tss-hub-vnt-10.204.0.0_22'
param vnet_address_space string = '10.204.170.0/23'          //Address space for entire vnet
param vnet_address_space_underscore string = replace(vnet_address_space, '/', '_')        //Same as subnet_private_prefix except that it includes an Azure name friendly underscore

param subnet_db_prefix string = '10.204.171.0/25'            //Subnet address space for Database Subnet
param subnet_gw_prefix string = '10.204.171.224/27'          //Subnet address space for Gateway Subnet
param subnet_fw_prefix string = '10.204.171.192/27'          //Subnet address space for Azure Firewall Subnet
param subnet_bastion_prefix string = '10.204.171.128/26'     //Subnet address space for Bastion Subnet
param subnet_pub_prefix string = '10.204.170.128/25'           //Subnet address space for Public Subnet
param subnet_priv_prefix string = '10.204.170.0/25'          //Subnet address space for Private Subnet



//********************************** Subscription Specific DATA to be edited**************************************

param subnet_db_name string = '${subscriptionPrefix_underscore}snt-db-${db_prefix_underscore}'              //Name for DB Subnet              
param subnet_gw_name string = 'GatewaySubnet'                             //Name for Gateway Subnet - this must ALWAYS be GatewaySubnet
param subnet_fw_name string = 'AzureFirewallSubnet'                       //Name for Azure Firewall Subnet - this must ALWAYS be AzureFirewallSubnet
param subnet_bastion_name string = 'AzureBastionSubnet'                   //Name for Azure Bastion Subnet - this must ALWAYS be AzureBastionSubnet
param subnet_pub_name string = '${subscriptionPrefix_underscore}snt-external-${public_prefix_underscore}'       //Name for External Subnet
param subnet_priv_name string = '${subscriptionPrefix_underscore}snt-internal-01-${private_prefix_underscore}'   //Name for Internal Subnet

param peering_prefix_hub string = '10.204.0.0/22'               //Address space for Peering Connections between spoke vnet and hub
param peering_prefix_hub_underscore string = replace(peering_prefix_hub, '/', '_')        //Same as peering prefix except that it includes an Azure name friendly underscore
                                                                                      //Don't modify this parameter!

//==========================================//
//=====Monitoring and Alerting Parameters===//

//==Action Group Parameters==//

param emailAddress array = [
  'EOTSS-DL-AzureCloudOpsSupport@mass.gov'        //The distribution group that will receive SMTP alert notifications
]
param sms array = [
  '9002022020'
  '8001232345'
]


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

/*
  //NSG Module
  module nsg 'Modules/Network/NSG/NSGCreation.bicep' = {
  name: 'nsg-module'
    params: {
      tags: tags
      location: location
      networkSecurityGroups_bastion_nsg_name: nsg_name[0]
      networkSecurityGroups_db_nsg_name: nsg_name[1]
      networkSecurityGroups_public_nsg_name: nsg_name[2]
      networkSecurityGroups_private_nsg_name: nsg_name[3]
    }
  }

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


  //VNET Module
  module vnet 'Modules/Network/VNet/VNet.bicep' = {
    name: 'vnet-module'
    params: {
      tags: tags
      location: location
      vnet_hub_id: vnet_hub_id
      vnet_name: vnet_name
      bastion_nsg_id: nsg.outputs.bastion_nsg_id
      public_nsg_id: nsg.outputs.public_nsg_id
      private_nsg_id: nsg.outputs.private_nsg_id
      db_nsg_id: nsg.outputs.db_nsg_id
      route_table_public_id: route_table.outputs.route_table_id
      subnet_db_prefix : subnet_db_prefix
      subnet_gw_prefix : subnet_gw_prefix
      subnet_fw_prefix : subnet_fw_prefix
      subnet_bastion_prefix : subnet_bastion_prefix
      subnet_pub_prefix : subnet_pub_prefix
      subnet_priv_prefix : subnet_priv_prefix
      peering_prefix_hub : peering_prefix_hub
      subnet_db_name : subnet_db_name
      subnet_gw_name : subnet_gw_name
      subnet_fw_name : subnet_fw_name
      subnet_bastion_name : subnet_bastion_name
      subnet_pub_name : subnet_pub_name
      subnet_priv_name : subnet_priv_name
      vnet_address_space : vnet_address_space
      peering_prefix_hub_underscore : peering_prefix_hub_underscore
    }
    dependsOn: [
      nsg
      route_table
    ]
  }

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
