//=====================================================================================================//
//===========THIS MAIN BICEP FILE CAN ORCHESTRATE THE DEPLOYMENT OF MULTIPLE AZURE SERVICES============//
//=====================================================================================================//

targetScope = 'subscription'        // We will deploy these modules against our subscription
                                    //Can't use decorator here.  Can be managementgroup, 
                                    //subscription or resourcegroup

//=====================================================================================================//
//========================================= START OF PARAMETERS =======================================//
//=====================================================================================================//


//What will we deploy?  Select to true or false for each
      param deployNSGflowLogs bool = false
      param azureFirewallDeploy bool = true
      param storageCommonDeploy bool = true        //Can be used for File Storage etc.  We store DSC scripts here in our example
      param appGatewayDeploy bool = true
      param privateDnsDeploy bool = false

      //Virtual Machine Options
      param deployBastion bool = true
      param deployVM1 bool = true
      param deployVM2 bool = false

            //Post Virtual Machine Deployment Software Installs
            param IISdeployEnabled bool = false
            param SSMSdeployEnabled bool = false
            param outputdeployEnabled bool = false
            param MgmtToolsDeploy bool = false

      //Backups and Recovery
      param recoveryServicesVault bool = false    
      param vmBackupEnabled bool = false  //Cannot be True if Recovery Services Vault is false

      //Logging and Monitoring
      param actionGroupEnabled bool = false
      param logAnalyticsWorkspaceEnabled bool = true    // Must be true if VM provisioning is true
      param vmLogAnalyticsSolutionsEnabled bool = false
      param vmMonitorCPUenabled bool = false  // Cannot be True if Log Analytics Solutions is false
      param vmMonitorDiskEnabled bool = false   // Cannot be True if Log Analytics Solutions is false
      param vmMonitorMemoryEnabled bool = false   // Cannot be True if Log Analytics Solutions is false
      param vmMonitorSystemState bool = false   // Cannot be True if Log Analytics Solutions is false

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
    param DeploymentDate string = utcNow('yyyy-MMM-dd')  //Let's grab the date and time for our resource deployments

  
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
      Department: 'Finance'
      Division: 'ABC-123'
      DeploymentDate: DeploymentDate
    }

//============================================================//
//====================End Global Parameters===================//


//============================================================//
//===================Begin Resource Parameters================//

  //=======Resource Group Parameters=====//

    param rg_01_name string = 'RG-CONNECTIVITY-${env_table[env].envPrefix}-001'
    param rg_02_name string = 'RG-MANAGEMENT-${env_table[env].envPrefix}-001'
    param rg_03_name string = 'RG-RESOURCE-${env_table[env].envPrefix}-001'
    //param rg_04_name string = 'NetworkWatcherRG'

//============================================================//
//===================Networking Parameters====================//

  //======NSG Parameters======//
    
    var nsg_bastion_name = 'NSG-BASTION-${env_table[env].envPrefix}-001'
    var nsg_private_name = 'NSG-PRIVATE-${env_table[env].envPrefix}-001'
    var nsg_public_name = 'NSG-PUBLIC-${env_table[env].envPrefix}-001'

  //=======NSG FLow Log Parameters=======//
  
  @description('Name of the Network Watcher attached to your subscription. Format: NetworkWatcher_<region_name>')
  param networkWatcherName string = 'NetworkWatcher_${location}'
  
  @description('Retention period in days. Default is zero which stands for permanent retention. Can be any Integer from 0 to 365')
  @minValue(0)
  @maxValue(365)
  param retentionDays int = 1
  
  @description('FlowLogs Version. Correct values are 1 or 2 (default)')
  @allowed([
    1
    2
  ])
  param flowLogsVersion int = 2
  
  @description('Storage Account type')
  param nsgStorageAccountType string = 'Standard_LRS'    //NSG flow logs only support Standard-tier storage accounts.  No other options permitted at this time.
  
  param guidValue string = newGuid()
  var storageAccountNameNsg = 'flowlogs${uniqueString(guidValue)}'

  // Network Watcher Resource Group Name
  // This Resource Group will host the Network Watcher object
  param networkWatcherRGName string = 'NetworkWatcherRG'

  //======Firewall Parameters========//

  param firewallName string = 'FIREWALL-${env_table[env].envPrefix}-001'
  param firewallPolicyName string = 'FIREWALL-POLICY-${env_table[env].envPrefix}-001'
  param azurepublicIpname string = 'PUB-IP-AZUREFIREWALL-00'

  //App Gateway
  
  param publicIPAddressAppGatewayName string = 'PUB-IP-APPGATEWAY-00'
  param applicationGateWayName string = 'APPGATEWAY-${env_table[env].envPrefix}-001'
  param wafPolicyName string = 'WAF-POLICY-${env_table[env].envPrefix}-001'


  //=====VNETS=====//
  

    //SPOKE VNETS

      param env_table object = {
        Production: {
            envPrefix : 'PRD'
            //subscription : '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a'   //Visual Studio Enterprise Subscription
            subscription : subscription().subscriptionId //Current Subscription
          
              //SPOKE 001 VNET Parameters
              vnet_spoke_001_name : 'VNET-SPOKE-PRD-001'   //Desired name of the vnet
              vnet_spoke_001_address_space : '10.2.0.0/20'          //Address space for entire vnet
            
              //SPOKE 001 Subnet Parameters
              subnet_spoke_001_name : 'WEB-VMs-PRD-001'             
              subnet_spoke_001_test_name : 'TEST-VMs-PRD-001'
              subnet_spoke_001_address_space : '10.2.0.0/24'           //Subnet address space for the WEB spoke
              subnet_spoke_001_test_address_space : '10.2.1.0/24'           //Subnet address space for the test spoke

        }
        Development: {
            envPrefix : 'DEV'
            //subscription: '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a'   //Visual Studio Enterprise Subscription
            subscription : subscription().subscriptionId //Current Subscription

            
              //HUB VNET Parameters
              vnet_hub_name : 'VNET-HUB-DEV'   //Desired name of the vnet
              vnet_hub_address_space : '10.50.0.0/20'          //Address space for entire vnet

                //HUB Subnet Parameters
                  //Names
                    subnet_hub_gw_name : 'GatewaySubnet'         //Name for Gateway Subnet - this must ALWAYS be GatewaySubnet
                    subnet_hub_fw_name : 'AzureFirewallSubnet'   //Name for Azure Firewall Subnet - this must ALWAYS be AzureFirewallSubnet
                    subnet_hub_bas_name : 'AzureBastionSubnet'   //Name for Azure Bastion Subnet - this must ALWAYS be AzureBastionSubnet
                    subnet_hub_ss_name : 'SharedServicesSubnet'  //Name for Shared Services Subnet - Would host AD, DNS, etc.

                  //Addresses
                    subnet_hub_gw_adress_space : '10.50.0.0/24'   //Subnet address space for Gateway Subnet
                    subnet_hub_fw_address_space : '10.50.1.0/24'  //Subnet address space for Azure Firewall Subnet
                    subnet_hub_bas_address_space : '10.50.2.0/24' //Subnet address space for Bastion Subnet
                    subnet_hub_ss_address_space : '10.50.3.0/24'  //Subnet address space for Shared Services Subnet
          
              //SPOKE 001 VNET Parameters
              vnet_spoke_001_name : 'VNET-SPOKE-DEV-001'   //Desired name of the vnet
              vnet_spoke_001_address_space : '10.51.0.0/20'          //Address space for entire vnet
            
                //SPOKE 001 Subnet Parameters
                subnet_spoke_001_name : 'WEB-VMs-DEV-001'             
                subnet_spoke_001_test_name : 'TEST-VMs-DEV-001'
                subnet_spoke_001_address_space : '10.51.0.0/24'           //Subnet address space for the spoke
                subnet_spoke_001_test_address_space : '10.51.1.0/24'           //Subnet address space for the test spoke

              //SPOKE 002 VNET Parameters
              vnet_spoke_002_name : 'VNET-SPOKE-DEV-002'   //Desired name of the vnet
              vnet_spoke_002_address_space : '10.52.0.0/20'          //Address space for entire vnet
            
                //SPOKE 002 Subnet Parameters
                subnet_spoke_002_name : 'WEB-VMs-DEV-002'             
                subnet_spoke_002_test_name : 'TEST-VMs-DEV-002'
                subnet_spoke_002_address_space : '10.52.0.0/24'           //Subnet address space for the spoke
                subnet_spoke_002_test_address_space : '10.52.1.0/24'           //Subnet address space for the test spoke

              
              //DMZ SPOKE VNET Parameters
              vnet_spoke_DMZ_name : 'VNET-SPOKE-DEV-DMZ'   //Desired name of the vnet
              vnet_spoke_DMZ_address_space : '10.53.0.0/20'          //Address space for entire vnet
            
                //SPOKE DMZ Subnet Parameters
                subnet_spoke_DMZ_name : 'WEB-VMs-DEV-DMZ'             
                subnet_spoke_DMZ_APP_GW_name : 'AppGatewaySubnet'
                subnet_spoke_DMZ_address_space : '10.53.0.0/24'           //Subnet address space for the spoke
                subnet_spoke_DMZ_APP_GW_address_space : '10.53.1.0/24'           //Subnet address space for the test spoke


        }
        Sandbox: {
            envPrefix : 'SBX'
            //subscription: '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a'   //Visual Studio Enterprise Subscription
            subscription : subscription().subscriptionId //Current Subscription
                    
              //SPOKE 001 VNET Parameters
              vnet_spoke_001_name : 'VNET-SPOKE-SBX-001'   //Desired name of the vnet
              vnet_spoke_001_address_space : '10.3.0.0/20'          //Address space for entire vnet
            
              //SPOKE 001 Subnet Parameters
              subnet_spoke_001_name : 'WEB-VMs-SBX-001'
              subnet_spoke_001_test_name : 'TEST-VMs-SBX-001'  
              subnet_spoke_001_address_space : '10.3.0.0/24'           //Subnet address space for the spoke
              subnet_spoke_001_test_address_space : '10.3.1.0/24'           //Subnet address space for the test spoke
        }
      }

//=======Peering Parameters========//

  param peering_name_hub_to_spoke_001 string = '${env_table[env].vnet_hub_name}/${env_table[env].vnet_hub_name}-peering-to-${env_table[env].vnet_spoke_001_name}'      // hub to spoke 001 peering name
  param peering_name_hub_to_spoke_002 string = '${env_table[env].vnet_hub_name}/${env_table[env].vnet_hub_name}-peering-to-${env_table[env].vnet_spoke_002_name}'      // hub to spoke 002 peering name
  param peering_name_hub_to_DMZ string = '${env_table[env].vnet_hub_name}/${env_table[env].vnet_hub_name}-peering-to-${env_table[env].vnet_spoke_DMZ_name}'      // hub to spoke DMZ peering name


  param peering_name_spoke_001_to_hub string = '${env_table[env].vnet_spoke_001_name}/${env_table[env].vnet_spoke_001_name}-peering-to-${env_table[env].vnet_hub_name}'      // spoke 001 to hub peering name
  param peering_name_spoke_002_to_hub string = '${env_table[env].vnet_spoke_002_name}/${env_table[env].vnet_spoke_002_name}-peering-to-${env_table[env].vnet_hub_name}'      // spoke 002 to hub peering name
  param peering_name_spoke_DMZ_to_hub string = '${env_table[env].vnet_spoke_DMZ_name}/${env_table[env].vnet_spoke_DMZ_name}-peering-to-${env_table[env].vnet_hub_name}'      // spoke 002 to hub peering name

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

//Public IP Address Parameters for Bastion
var publicIPAddressName = 'PUB-IP-${env_table[env].envPrefix}-BASTION'
param publicIPsku string = 'Standard'   //Should be Standard for Bastion Usage
param publicIPAllocationMethod string = 'Static' //Should ALWAYS be Static for Bastion Usage
param publicIPAddressVersion string = 'IPv4'
param dnsLabelPrefixBastion string = 'bastionpubip01' //Unique DNS Name for the Public IP used to access the Virtual Machine

//Bastion Host Parameters
var bastionName = 'BASTION-${env_table[env].envPrefix}-001'

//Private DNS Zone Parameters
@description('private dns zone name')
param dnsZoneName string = 'widgetsabc.com'  //name dot format

@description('enable auto registration for private dns')
param autoRegistration bool = true


//============================================================//
//===================Begin Monitoring Parameters================//



  //==Action Group Parameters==//
  @description('Enter Emails or Distribution lists in SMTP format to direct Email alerts to.')
  param emailAddress array = [] // Sensitive.  Supply at command line

  @description('Enter phone number in numerical format to direct SMS alerts to.')
  param sms array = [] // Sensitive.  Supply at command line

  param ag_admins_name string = 'Admins'    //Name of Action Group


  //Log Analytics Workspace
  @description('The name of the Log Analytics Workspace')
  param workspaceName string = 'LAW-${env_table[env].envPrefix}-001'            //Name of the Log Analytics Workspace
  @allowed([
    'PerGB2018'
  ])
  param logAnalyticsWorkspaceSku string = 'PerGB2018'


  //VM Insights Solution Parameters
  param vmInsights_ object = {
    name: 'VMInsights(${workspaceName})'
    galleryName: 'VMInsights'
  }

  //VM Updates Solution Parameters
  param vmUpdates_ object = {
    name: 'Updates(${workspaceName})'
    galleryName: 'Updates'
  }

  param automationAccountName string = 'AzureVMPatchingAccount'

  // This parameter is specifically used for the automation account's location
  //This value CANNOT be the same value that is set for the 'location' parameter
  //If location parameter is set to 'eastus', then this value should be 'eastus2'
  param location_2 string = 'eastus2'  



//=====CPU Alerting Parameters=//

param metricAlerts_vm_cpu_percentage_name string = 'vm_cpu_percentage'    //Name of the Alert
param vmCpuPercentageAlert_location string = 'global'        //Region alert will apply to
param vmCpuPercentageAlert_severity int = 2                          //Severity Level {0-Critical, 1-Error, 2-Warning, 3-Informational, 4-Verbose}
param vmCpuPercentageAlert_enabled bool = true

param vmCpuPercentageAlert_scopes string = '${env_table[env].subscription}/resourceGroups/${rg_03_name}'
param vmCpuPercentageAlert_evaluationFrequency string = 'PT5M'     //How Often Alert is Evaluated in ISO 8601 format

@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param vmCpuPercentageAlert_windowSize string = 'PT5M'             //The period of time (in ISO 8601 duration format) that is used to monitor alert activity based on the threshold
                                                                  //WindowSize of 1 minutes is not supported. Supported granularities are: 5, 10, 15, 30, 45, 60, 120, 180, 240, 300, 360, 1440, 2880
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
param vmSysStateAlertScope_ids string = '${env_table[env].subscription}/resourceGroups/${rg_03_name}'

@description('how often the metric alert is evaluated represented in ISO 8601 duration format')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param vmSysStateAlertEvalFrequency string = 'PT5M'  //how often the metric alert is evaluated represented in ISO 8601 duration format
param vmSysStateAlertwindowSize string = 'PT5M'
param vmSysStateAlertQueryTimeRange string = 'P2D'

@description('The amount of time since the last failure was encounterd')
param vmSysStateAlert_timeGenerated string = '5m'
param vmSysStateAlertQueryInterval string = '2m'    //Lastcall value.  How long ago did the VM stop sending heartbeats?


//==========VM Memory Alerting Parameters=============//

param metricAlerts_vm_memory_percentage_name string = 'VM Memory - Average Usage Exceeds ${vmMemoryPercentageAlert_percentageVal} percent'
param vmMemoryPercentageAlert_percentageVal string = '5' //Percentage threshold which would trigger an alert
param vmMemoryPercentageAlert_description string = '${metricAlerts_vm_memory_percentage_name}.  Looks at the average usage and issues an alert if value exceeds ${vmMemoryPercentageAlert_percentageVal} percent'

@description('Severity of alert {0,1,2,3,4}')
@allowed([
  0
  1
  2
  3
  4
])
param vmMemoryPercentageAlert_severity int = 0   //Severity Level {0-Critical, 1-Error, 2-Warning, 3-Informational, 4-Verbose}
param vmMemoryPercentageAlert_enabled bool = true //Is alert enabled or disabled?  'True' indicates that the alert is enabled
param vmMemoryPercentageAlert_scopes string = '${env_table[env].subscription}/resourceGroups/${rg_03_name}' //'${env_table[env].subscription}/resourceGroups/${rg_03_name}' //What area of the Azure hierarchy are we targeting
param vmMemoryPercentageAlert_evaluationFrequency string = 'PT5M' //how often the metric alert is evaluated represented in ISO 8601 duration format

@allowed([
  'PT5M'
  'PT10M'
  'PT15M'
  'PT30M'
  'PT45M'
  'PT1H'
])
param vmMemoryPercentageAlert_windowSize string = 'PT5M' //Period of time used to monitor alert activity based on the threshold. Must be between one minute and one day. ISO 8601 duration format.
                                                         //WindowSize of 1 minutes is not supported. Supported granularities are: 5, 10, 15, 30, 45, 60, 120, 180, 240, 300, 360, 1440, 2880
param vmMemoryPercentageAlert_threshold int = 1
param vmMemoryPercentageAlert_overrideQueryTimeRange string = 'P2D'


//=======VM Disk Utilization Parameters===//

param vmDiskUtilizationAlert__name string = 'Less than 10 Percent Free Disk Space Remaining on Drive'
param vmDiskUtilizationAlert_description string = 'Less than 10 Percent Free Disk Space Remaining on Drive'
param vmDiskUtilizationAlert_severity int = 0   //Severity Level {0-Critical, 1-Error, 2-Warning, 3-Informational, 4-Verbose}
param vmDiskUtilizationAlert_enabled bool = true
param vmDiskUtilizationAlert_scopes string = '${env_table[env].subscription}/resourceGroups/${rg_03_name}'
param vmDiskUtilizationAlert_evaluationFrequency string = 'PT5M'
param vmDiskUtilizationAlert_windowSize string = 'PT5M'
param vmDiskUtilizationAlert_percentageVal string = '10' //The remaining percentage that when breached, will signal an alert

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
    var backupPolicyName = 'ABC-VM-${env_table[env].envPrefix}-DefaultBackup'
    param vaultName string = 'RSV-${env_table[env].envPrefix}-001'
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
@secure()
param adminpass string = '**************'

@description('Name of the virtual machine.')
param vmName_001 string = 'VM-${env_table[env].envPrefix}-001'
param vmName_002 string = 'VM-${env_table[env].envPrefix}-002'


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
//param vmSize string = 'Standard_B1s'      //azureprice.net - reference for full list and costs
param vmSize string = 'Standard_B2s'  // this image works with log insight agent.  Some images do not work with the agent

param storageAccountName string = 'bootdiags${uniqueString(subscription().subscriptionId)}'
param nicName_001 string = '${vmName_001}-nic'
param nicName_002 string = '${vmName_002}-nic'

//Managed Identity Params
param userAssignedIdentityName string = 'UAMIUser'

//Common Storage params
param storageAccountName_01 string = uniqueString(subscription().id)
param containerName_01 string = 'general-blobcontainer'


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
        rg_01_name: rg_01_name      //CONNECTIVITY - NETWORK CONSTRUCTS GO HERE
        rg_02_name: rg_02_name      //MANAGEMENT - MANAGEMENT RESOURCES GO HERE
        rg_03_name: rg_03_name      //RESOURCE - RESOURCES SUCH AS SERVERS AND STORAGE ACCOUNTS GO HERE
        network_watcher_name: networkWatcherRGName
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
      networkSecurityGroups_public_nsg_name:  nsg_public_name
      networkSecurityGroups_private_nsg_name: nsg_private_name
    }
    dependsOn: [
      rg
    ]
  }


   
  //NSG Flow Logs
    module nsgFlow 'Modules/Network/NSG/nsg_flow_logs.bicep' = if (deployNSGflowLogs) {
      name: 'nsgFlow-module'
      //scope: resourceGroup(rg_01_name)
      scope: resourceGroup(networkWatcherRGName)
      params: {
        location: location
        networkWatcherName: networkWatcherName
        retentionDays: retentionDays
        flowLogsVersion: flowLogsVersion
        nsgStorageAccountType: nsgStorageAccountType
        storageAccountNameNsg: storageAccountNameNsg
        bastion_nsg_id: nsg.outputs.bastion_nsg_id
        //public_nsg_id: nsg.outputs.public_nsg_id    https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-faq Flow logs not supported on App Gateway Subnet
        private_nsg_id: nsg.outputs.private_nsg_id
        tags: tags
      }
      dependsOn: [
        vnet_spoke_001
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
      private_nsg_id: nsg.outputs.private_nsg_id
      vnet_hub_name: env_table[env].vnet_hub_name
      vnet_hub_address_space : env_table[env].vnet_hub_address_space
      subnet_hub_gw_name : env_table[env].subnet_hub_gw_name
      subnet_hub_fw_name : env_table[env].subnet_hub_fw_name
      subnet_hub_bas_name : env_table[env].subnet_hub_bas_name
      subnet_ss_name : env_table[env].subnet_hub_ss_name
      subnet_hub_gw_adress_space : env_table[env].subnet_hub_gw_adress_space
      subnet_hub_fw_address_space : env_table[env].subnet_hub_fw_address_space
      subnet_hub_bas_address_space : env_table[env].subnet_hub_bas_address_space
      subnet_hub_ss_address_space : env_table[env].subnet_hub_ss_address_space
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
      vnet_spoke_001_name: env_table[env].vnet_spoke_001_name
      vnet_spoke_001_address_space : env_table[env].vnet_spoke_001_address_space
      subnet_spoke_001_name : env_table[env].subnet_spoke_001_name
      subnet_spoke_001_address_space : env_table[env].subnet_spoke_001_address_space
      subnet_spoke_001_test_name : env_table[env].subnet_spoke_001_test_name
      subnet_spoke_001_test_address_space : env_table[env].subnet_spoke_001_test_address_space
    }
    dependsOn: [
      vnet_hub
      //route_table
    ]
  }

    //VNET Spoke 002 Module
    module vnet_spoke_002 'Modules/Network/VNet/VNet-Spoke-002.bicep' = {
      name: 'vnet-spoke_002-module'
      scope: resourceGroup(rg_01_name)
      params: {
        tags: tags
        location: location
        private_nsg_id: nsg.outputs.private_nsg_id
        vnet_spoke_002_name: env_table[env].vnet_spoke_002_name
        vnet_spoke_002_address_space : env_table[env].vnet_spoke_002_address_space
        subnet_spoke_002_name : env_table[env].subnet_spoke_002_name
        subnet_spoke_002_address_space : env_table[env].subnet_spoke_002_address_space
        subnet_spoke_002_test_name : env_table[env].subnet_spoke_002_test_name
        subnet_spoke_002_test_address_space : env_table[env].subnet_spoke_002_test_address_space
      }
      dependsOn: [
        vnet_hub
        //route_table
      ]
    }


        //VNET Spoke DMZ Module
        module vnet_spoke_DMZ 'Modules/Network/VNet/VNet-Spoke-DMZ.bicep' = {
          name: 'vnet-spoke_DMZ-module'
          scope: resourceGroup(rg_01_name)
          params: {
            tags: tags
            location: location
            public_nsg_id: nsg.outputs.public_nsg_id
            vnet_spoke_DMZ_name: env_table[env].vnet_spoke_DMZ_name
            vnet_spoke_DMZ_address_space : env_table[env].vnet_spoke_DMZ_address_space
            subnet_spoke_DMZ_name : env_table[env].subnet_spoke_DMZ_name
            subnet_spoke_DMZ_APP_GW_name : env_table[env].subnet_spoke_DMZ_APP_GW_name
            subnet_spoke_DMZ_APP_GW_address_space : env_table[env].subnet_spoke_DMZ_APP_GW_address_space
          }
          dependsOn: [
            vnet_hub
            //route_table
          ]
        }

    

  //===Peering Modules

    //Peering Module Spoke 001 to Hub
    module peering_spoke_to_hub 'Modules/Network/Peerings/peering_spoke_to_hub.bicep' = {
      name: 'peering_module_spoke_001_to_hub'
      scope: resourceGroup(rg_01_name)     
      params: {
        peering_name_spoke_to_hub : peering_name_spoke_001_to_hub     // spoke 001 to hub peering name
        vnet_hub_id: vnet_hub.outputs.vnet_hub_id
        spokeallowForwardedTraffic : spokeallowForwardedTraffic
        spokeallowGatewayTransit : spokeallowGatewayTransit
        spokeallowVirtualNetworkAccess : spokeallowVirtualNetworkAccess
        //spokedoNotVerifyRemoteGateways : spokedoNotVerifyRemoteGateways  // May not need this.  Safe to remove 25-Jan-2023
        spokepeeringState : spokepeeringState
        spokeuseRemoteGateways : spokeuseRemoteGateways
      }
      dependsOn: [
        vnet_spoke_001
        //route_table
      ] 
    }


    //Peering Module Spoke 002 to Hub
    module peering_spoke_to_hub_02 'Modules/Network/Peerings/peering_spoke_to_hub.bicep' = {
      name: 'peering_module_spoke_002_to_hub'
      scope: resourceGroup(rg_01_name)     
      params: {
        peering_name_spoke_to_hub : peering_name_spoke_002_to_hub     // spoke 001 to hub peering name
        vnet_hub_id: vnet_hub.outputs.vnet_hub_id
        spokeallowForwardedTraffic : spokeallowForwardedTraffic
        spokeallowGatewayTransit : spokeallowGatewayTransit
        spokeallowVirtualNetworkAccess : spokeallowVirtualNetworkAccess
        //spokedoNotVerifyRemoteGateways : spokedoNotVerifyRemoteGateways  // May not need this.  Safe to remove 25-Jan-2023
        spokepeeringState : spokepeeringState
        spokeuseRemoteGateways : spokeuseRemoteGateways
      }
      dependsOn: [
        vnet_spoke_002
        //route_table
      ] 
    }


    //Peering Module Spoke DMZ to Hub
    module peering_spoke_DMZ_to_hub 'Modules/Network/Peerings/peering_spoke_to_hub.bicep' = {
      name: 'peering_module_spoke_DMZ_to_hub'
      scope: resourceGroup(rg_01_name)     
      params: {
        peering_name_spoke_to_hub : peering_name_spoke_DMZ_to_hub     // spoke 001 to hub peering name
        vnet_hub_id: vnet_hub.outputs.vnet_hub_id
        spokeallowForwardedTraffic : spokeallowForwardedTraffic
        spokeallowGatewayTransit : spokeallowGatewayTransit
        spokeallowVirtualNetworkAccess : spokeallowVirtualNetworkAccess
        //spokedoNotVerifyRemoteGateways : spokedoNotVerifyRemoteGateways  // May not need this.  Safe to remove 25-Jan-2023
        spokepeeringState : spokepeeringState
        spokeuseRemoteGateways : spokeuseRemoteGateways
      }
      dependsOn: [
        vnet_hub
        vnet_spoke_DMZ
      ] 
    }


    // Peering Hub to Spoke 001
    module peering_to_hub_001 'Modules/Network/Peerings/peering_hub_to_spoke.bicep' = {
      name: 'peering_module_hub_to_spoke_001'
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


        // Peering Hub to Spoke 002
        module peering_to_hub_002 'Modules/Network/Peerings/peering_hub_to_spoke.bicep' = {
          name: 'peering_module_hub_to_spoke_002'
          //scope: resourceGroup('13a5d4c6-e4eb-4b92-9b1a-e044fe55d79c', 'tss-hub-rsg-network-01')     
          scope: resourceGroup(rg_01_name)
          params: {
            peering_name_hub_to_spoke : peering_name_hub_to_spoke_002      // hub to spoke 001 peering name
            vnet_spoke_id: vnet_spoke_002.outputs.vnet_spoke_002_id
            huballowForwardedTraffic : huballowForwardedTraffic
            huballowGatewayTransit : huballowGatewayTransit
            huballowVirtualNetworkAccess : huballowVirtualNetworkAccess
            hubdoNotVerifyRemoteGateways : hubdoNotVerifyRemoteGateways
            hubpeeringState : hubpeeringState
            hubuseRemoteGateways : hubuseRemoteGateways
          }
          dependsOn: [
            vnet_hub
            vnet_spoke_002
          ] 
        }


        
        // Peering Hub to Spoke DMZ
        module peering_to_hub_DMZ 'Modules/Network/Peerings/peering_hub_to_spoke.bicep' = {
          name: 'peering_module_hub_to_spoke_DMZ'
          scope: resourceGroup(rg_01_name)
          params: {
            peering_name_hub_to_spoke : peering_name_hub_to_DMZ     // hub to spoke 001 peering name
            vnet_spoke_id: vnet_spoke_DMZ.outputs.vnet_spoke_DMZ_id
            huballowForwardedTraffic : huballowForwardedTraffic
            huballowGatewayTransit : huballowGatewayTransit
            huballowVirtualNetworkAccess : huballowVirtualNetworkAccess
            hubdoNotVerifyRemoteGateways : hubdoNotVerifyRemoteGateways
            hubpeeringState : hubpeeringState
            hubuseRemoteGateways : hubuseRemoteGateways
          }
          dependsOn: [
            vnet_hub
            vnet_spoke_DMZ
          ] 
        }


  
  //Bastion Host Module
  module bastionHost 'Modules/Network/Bastion/bastion.bicep' = if (deployBastion) {
    name: 'bastion-host-module'
    scope: resourceGroup(rg_01_name)
      params: {
        tags: tags
        location: location
        bastionName: bastionName
        bastionSubnetid: '${vnet_hub.outputs.vnet_hub_id}/subnets/${env_table[env].subnet_hub_bas_name}'
        publicIPAddressName: publicIPAddressName
        publicIPsku: publicIPsku
        publicIPAllocationMethod : publicIPAllocationMethod
        publicIPAddressVersion : publicIPAddressVersion
        dnsLabelPrefixBastion : dnsLabelPrefixBastion
      }
      dependsOn: [
        vnet_spoke_001
      ]
  } 


//Azure Firewall Module
module azureFirewall 'Modules/Network/Firewall/Firewall.bicep' = if (azureFirewallDeploy) {
  name: 'azure-firewall-module'
  scope: resourceGroup(rg_01_name)
    params: {
      tags: tags
      location: location
      firewallName: firewallName
      firewallPolicyName: firewallPolicyName
      azurepublicIpname: azurepublicIpname
      fw_vnet: env_table[env].vnet_hub_name
    }
    dependsOn: [
      vnet_spoke_001
    ]
} 

//App Gateway Module
module appGateway 'Modules/Network/App_Gateway/App_Gateway.bicep' = if (appGatewayDeploy) {
  name: 'app-gateway-module'
  scope: resourceGroup(rg_01_name)
    params: {
      tags: tags
      location: location
      virtualNetworkName: env_table[env].vnet_spoke_DMZ_name
      publicIPAddressAppGatewayName: publicIPAddressAppGatewayName
      applicationGateWayName: applicationGateWayName
      subnet_spoke_DMZ_APP_GW_name: env_table[env].subnet_spoke_DMZ_APP_GW_name
      wafPolicyName: wafPolicyName
    }
    dependsOn: [
      vnet_spoke_DMZ
    ]
} 


//Private DNS Zone Module
module privateDNS 'Modules/Network/DNS/Private_DNS.bicep' = if (privateDnsDeploy) {
  name: 'dns-zone-module'
  scope: resourceGroup(rg_01_name)
    params: {
      tags: tags
      location: 'global'  // Do not change from Global
      dnsZoneName: dnsZoneName
      autoRegistration: autoRegistration
      vnetId: vnet_hub.outputs.vnet_hub_id
    }
    dependsOn: [
      vnet_spoke_DMZ
    ]
} 


//===========================================//
//=========End of Network Modules=======//
//===========================================//

//===========================================//
//=======Start of Backup and Recovery Modules=======//
//===========================================//


  module rsv_001 'Modules/BackUp/RecoveryServicesVault.bicep' = if (recoveryServicesVault) {
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



  module backup 'Modules/BackUp/backup_policies.bicep' =  if (vmBackupEnabled) {
    name: 'backup-policies-module'
    scope: resourceGroup(rg_02_name)
    params: {
      vaultName: vaultName
      location: location
      tags: tags
      BackupType: BackupType
      backupPolicyName: backupPolicyName
      env_prefix: env_table[env]
    }
    dependsOn: [
      rsv_001
    ]
  }


//===========================================//
//====End of Backup and Recovery Modules=====//
//===========================================//

//=====================================================//
//=======Start of Monitoring and Alerting Modules======//  
//=====================================================//



//Action Group to direct SMTP and SMS alerts to
module action_group 'Modules/Monitoring/action_group.bicep' = if (actionGroupEnabled) {
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
module law 'Modules/Log_Analytics/LogAnalytics.bicep' = if (logAnalyticsWorkspaceEnabled) {
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

//Log Analytics Solutions Module
module solutions 'Modules/Log_Analytics/LogAnalytics_Solutions.bicep' = if (vmLogAnalyticsSolutionsEnabled) {
  name: 'vm-insights-module'
  scope: resourceGroup(rg_02_name)
  params: {
    tags: tags
    location: location
    location_2: location_2
    workspaceName: workspaceName
    vmInsights : vmInsights_
    vmUpdates: vmUpdates_
    workspace_id : law.outputs.workspace_id
    automationAccountName: automationAccountName
  }
  dependsOn: [
      law
    ]
}

/*
// VM Monitoring CPU
module monitoring_cpu 'Modules/Monitoring/monitoring_vmCpu.bicep' = if (vmMonitorCPUenabled) {
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



// VM Monitoring System State
module monitoring_vm_system_state 'Modules/Monitoring/monitoring_vmSystemState.bicep' = if (vmMonitorSystemState) {
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
    vmSysStateAlertwindowSize : vmSysStateAlertwindowSize
    vmSysStateAlertEvalFrequency : vmSysStateAlertEvalFrequency
    vmSysStateAlertQueryTimeRange : vmSysStateAlertQueryTimeRange
    actiongroups_externalid : action_group.outputs.actionGroups_Admins_name_resource_id
    vmSysStateAlertQueryInterval : vmSysStateAlertQueryInterval
    vmSysStateAlert_timeGenerated : vmSysStateAlert_timeGenerated
  }
  dependsOn: [
    action_group
  ]
}
 
// VM Monitoring VM Memory
module monitoring_vm_memory 'Modules/Monitoring/monitoring_vmMemory.bicep' = if (vmMonitorMemoryEnabled) {
  name: 'monitoring_vm_memory_module'
  scope: resourceGroup(rg_02_name)
  params: {
    location : location
    tags : tags
    metricAlerts_vm_memory_percentage_name : metricAlerts_vm_memory_percentage_name
    vmMemoryPercentageAlert_percentageVal : vmMemoryPercentageAlert_percentageVal
    actiongroups_externalid : action_group.outputs.actionGroups_Admins_name_resource_id
    vmMemoryPercentageAlert_description : vmMemoryPercentageAlert_description
    vmMemoryPercentageAlert_severity : vmMemoryPercentageAlert_severity
    vmMemoryPercentageAlert_enabled : vmMemoryPercentageAlert_enabled
    vmMemoryPercentageAlert_scopes : vmMemoryPercentageAlert_scopes
    vmMemoryPercentageAlert_evaluationFrequency : vmMemoryPercentageAlert_evaluationFrequency
    vmMemoryPercentageAlert_windowSize : vmMemoryPercentageAlert_windowSize
    vmMemoryPercentageAlert_threshold : vmMemoryPercentageAlert_threshold
    vmMemoryPercentageAlert_overrideQueryTimeRange : vmMemoryPercentageAlert_overrideQueryTimeRange
  }
  dependsOn: [
    action_group
  ]
}


module monitoring_vm_disk 'Modules/Monitoring/monitoring_vmDiskUtilization.bicep' = if (vmMonitorDiskEnabled) {
  name: 'monitoring_vm_disk_module'
  scope: resourceGroup(rg_02_name)
  params: {
    location : location
    tags : tags
    actiongroups_externalid : action_group.outputs.actionGroups_Admins_name_resource_id
    vmDiskUtilizationAlert__name : vmDiskUtilizationAlert__name
    vmDiskUtilizationAlert_description : vmDiskUtilizationAlert_description
    vmDiskUtilizationAlert_severity : vmDiskUtilizationAlert_severity
    vmDiskUtilizationAlert_enabled : vmDiskUtilizationAlert_enabled
    vmDiskUtilizationAlert_scopes : vmDiskUtilizationAlert_scopes
    vmDiskUtilizationAlert_evaluationFrequency : vmDiskUtilizationAlert_evaluationFrequency
    vmDiskUtilizationAlert_windowSize : vmDiskUtilizationAlert_windowSize
    vmDiskUtilizationAlert_percentageVal : vmDiskUtilizationAlert_percentageVal
  }
  dependsOn: [
    action_group
  ]
}
*/

//==============================================//
//====End of Monitoring and Alerting Modules====//
//==============================================//

//===========================================//
//=======Start of Compute Modules============//
//===========================================//


  module vm_001 'Modules/Compute/VirtualMachines.bicep' = if (deployVM1) {
    name: 'vm_001-module'
    scope: resourceGroup(rg_03_name)
    
    params: {
      adminUsername: adminUsername
      adminpass: adminpass
      vmName: vmName_001
      storageAccountName: storageAccountName
      OSVersion: OSVersion
      vmSize: vmSize
      nicName: nicName_001
      tags: tags
      location: location
      nicSubnetId: vnet_spoke_001.outputs.subnet_spoke_001_id
      userAssignedIdentityName: userAssignedIdentityName
      workspace_id : law.outputs.workspace_id
      workspace_id2 : law.outputs.workspaceIdOutput
      workspace_key: law.outputs.workspaceKeyOutput
    }
    dependsOn: [
      law
    ]
  }


  module vm_002 'Modules/Compute/VirtualMachines.bicep' = if (deployVM2) {
    name: 'vm_002-module'
    scope: resourceGroup(rg_03_name)
    
    params: {
      adminUsername: adminUsername
      adminpass: adminpass
      vmName: vmName_002
      storageAccountName: storageAccountName
      OSVersion: OSVersion
      vmSize: vmSize
      nicName: nicName_002
      tags: tags
      location: location
      nicSubnetId: vnet_spoke_002.outputs.subnet_spoke_002_id
      workspace_id : law.outputs.workspace_id
      workspace_id2 : law.outputs.workspaceIdOutput
      workspace_key: law.outputs.workspaceKeyOutput
      userAssignedIdentityName: userAssignedIdentityName
    }
    dependsOn: [
      law
    ]
  }

  //Storage Account for Common Use in the Landing Zone
  module storage 'Modules/Storage/storageblob.bicep' = if (storageCommonDeploy) {
    name: 'storage-module'
    scope: resourceGroup(rg_02_name)
    params: {
      storageAccountName_01: storageAccountName_01
      containerName_01: containerName_01
      location: location
      tags: tags
    }
    dependsOn: [
      rg
    ]
  }
  

//==============================================//
//==============================================//
//VM Post deployment Customizations
//==============================================//
//==============================================//


/*
module vmPostDeploymentScript_05_DSC_IIS 'Modules/Software/IIS_DSC.bicep' = if (IISdeployEnabled) {
  name: 'vm-post-deployment-script-module-dsc-iis'
  scope: resourceGroup(rg_03_name)
  params: {
    storageAccountName: storageAccountName_01
    vmName: vmName_001
    location: location
    containerName: containerName_01
    tags: tags
  }
  dependsOn: [
    vm_001
  ]
}


module vmPostDeploymentScript_01_IIS 'Modules/Software/IIS.bicep' = if (IISdeployEnabled) {
  name: 'vm-post-deployment-script-module-IIS'
  scope: resourceGroup(rg_03_name)
  params: {
    vmName: vmName_001
    location: location
  }
  dependsOn: [
    vm_001
  ]
}


module vmPostDeploymentScript_02_output 'Modules/Software/output.bicep' = if (outputdeployEnabled) {
  name: 'vm-post-deployment-script-module-output'
  scope: resourceGroup(rg_03_name)
  params: {
    vmName: vmName_001
    location: location
  }
  dependsOn: [
    vm_001
  ]
}

module vmPostDeploymentScript_03_SSMS 'Modules/Software/SQLServerMgtStudio.bicep' = if (SSMSdeployEnabled) {
  name: 'vm-post-deployment-script-module-ssms'
  scope: resourceGroup(rg_03_name)
  params: {
    vmName: vmName_001
    location: location
  }
  dependsOn: [
    vm_001
  ]
}


module vmPostDeploymentScript_04_DSC 'Modules/Software/MgmtTools.bicep' = if (MgmtToolsDeploy) {
  name: 'vm-post-deployment-script-module-dsc-mgmttools'
  scope: resourceGroup(rg_03_name)
  params: {
    storageAccountName: storageAccountName_01
    vmName: vmName_001
    location: location
    containerName: containerName_01
    tags: tags
  }
  dependsOn: [
    vm_001
  ]
}



//User Assigned Managed Identity for Install of AMA agent
module managedIdentity 'Modules/ManagedIdentity/ManagedIdentity.bicep' = if (deployVM1) {
  name: 'userAssignedIdentity-module'
  scope: resourceGroup(rg_03_name)
  params: {
   location: location
   userAssignedIdentityName: userAssignedIdentityName
   tags: tags
  }
  dependsOn: [
    vm_001
  ]
}

module amaAgent 'Modules/Software/SQLServerMgtStudio.bicep' = if (SSMSdeployEnabled) {
  name: 'vm-post-deployment-script-module-ssms'
  scope: resourceGroup(rg_03_name)
  params: {
    vmName: vmName_001
    location: location
  }
  dependsOn: [
    vm_001
  ]
}
*/



