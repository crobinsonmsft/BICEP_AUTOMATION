//=======This bicep file creates a VM Insights Solution to assist with VM Monitoring=======//

//=================Params=================//

param workspaceName string
param vmInsights object
param vmUpdates object
param automationAccountName string
param location_2 string

param workspace_id string
param location string
param tags object

//===============End Params===============//

resource patchingSchedule 'Microsoft.Automation/automationAccounts/softwareUpdateConfigurations@2019-06-01' = {
  name: '${workspaceName}/WeeklyPatchSchedule'
  // parent: resourceSymbolicName
  properties: {
    error: {
      code: 'string'
      message: 'string'
    }
    scheduleInfo: {
      advancedSchedule: {
        monthDays: [
          int
        ]
        monthlyOccurrences: [
          {
            day: 'string'
            occurrence: int
          }
        ]
        weekDays: [
          'string'
        ]
      }
      creationTime: 'string'
      description: 'string'
      expiryTime: 'string'
      expiryTimeOffsetMinutes: int
      frequency: 'string'
      interval: int
      isEnabled: bool
      lastModifiedTime: 'string'
      nextRun: 'string'
      nextRunOffsetMinutes: int
      startTime: 'string'
      timeZone: 'string'
    }
    tasks: {
      postTask: {
        parameters: {}
        source: 'string'
      }
      preTask: {
        parameters: {}
        source: 'string'
      }
    }
    updateConfiguration: {
      azureVirtualMachines: [
        'string'
      ]
      duration: 'string'
      linux: {
        excludedPackageNameMasks: [
          'string'
        ]
        includedPackageClassifications: 'string'
        includedPackageNameMasks: [
          'string'
        ]
        rebootSetting: 'string'
      }
      nonAzureComputerNames: [
        'string'
      ]
      operatingSystem: 'string'
      targets: {
        azureQueries: [
          {
            locations: [
              'string'
            ]
            scope: [
              'string'
            ]
            tagSettings: {
              filterOperator: 'string'
              tags: {}
            }
          }
        ]
        nonAzureQueries: [
          {
            functionAlias: 'string'
            workspaceId: 'string'
          }
        ]
      }
      windows: {
        excludedKbNumbers: [
          'string'
        ]
        includedKbNumbers: [
          'string'
        ]
        includedUpdateClassifications: 'string'
        rebootSetting: 'string'
      }
    }
  }
}
