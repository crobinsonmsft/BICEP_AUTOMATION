//=======This bicep file sets Backup Policies =======//

//=================Params=================//

//global params

param vaultName string
param location string
param tags object
param BackupType string
param backupPolicyName string
param env_prefix string


// Create the customized recovery service vault backup policy for Azure virtual machines
resource backup_pol_001 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-01-01'= {
  
  //name: '${RecoveryServicesVault.name}/${backupPolicyName}'
  name: '${vaultName}/${backupPolicyName}'
  location: location
  tags: tags
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRPDetails: {
      azureBackupRGNamePrefix: '${env_prefix}-restore-01'
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
  //name: '${RecoveryServicesVault.name}/VaultStorageConfig'
  name: '${vaultName}/VaultStorageConfig'
  properties: {
    crossRegionRestoreFlag: false
    storageModelType: BackupType
  }
}
