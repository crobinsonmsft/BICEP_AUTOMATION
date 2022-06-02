// Creates a recovery services vault and backup policy intended for backup of virtual machines
//
//Parameters

param location string = ''
param tags object = {}
param vaultName string = ''
/*
@allowed([
  'GeoRedundant' 
  'LocallyRedundant'
  'ReadAccessGeoZoneRedundant'
  'ZoneRedundant'
])
*/
param BackupType string = ''
param policyName string = ''
param sku object = {}
//
//
//Create the Recovery Services Vault
resource RecoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-01-01' = {
  name: vaultName
  location: location
  tags: tags
  sku: sku
  properties: {}
}
//
//
// Create the customized recovery service vault backup policy for Azure virtual machines
resource vaults_tss_np_rsv_infra_01_name_TSS_VM_DefaultBackup 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-01-01'= {
  //parent: vaults_tss_np_rsv_infra_01_name_resource
  //name: 'TSS-VM-DefaultBackup'
  name: '${RecoveryServicesVault.name}/${policyName}'
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRPDetails: {
      azureBackupRGNamePrefix: 'tss-np-rsg-restore-01'
    }
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [
        '3/30/2022 11:00:00 PM'
      ]
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '3/30/2022 11:00:00 PM'
        ]
        retentionDuration: {
          count: 8
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: [
          'Friday'
        ]
        retentionTimes: [
          '3/30/2022 11:00:00 PM'
        ]
        retentionDuration: {
          count: 4
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Daily'
        retentionScheduleDaily: {
          daysOfTheMonth: [
            {
              date: 28
              isLast: false
            }
          ]
        }
        retentionTimes: [
          '3/30/2022 11:00:00 PM'
        ]
        retentionDuration: {
          count: 4
          durationType: 'Months'
        }
      }
    }
    instantRpRetentionRangeInDays: 2
    timeZone: 'Eastern Standard Time'
    protectedItemsCount: 0
  }
}


resource VaultConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2022-01-01' = {
  name: '${RecoveryServicesVault.name}/VaultStorageConfig'
  properties: {
    crossRegionRestoreFlag: false
    storageModelType: BackupType
  }
}
