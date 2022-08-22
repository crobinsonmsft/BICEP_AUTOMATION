
//=======This bicep file creates Memory Monitoring Alert Rule=======//


//=================Params=================//

param actiongroups_externalid string
param location string
param tags object
param vmDiskUtilizationAlert__name string = 'Less than 10 Percent Free Disk Space Remaining on Drive'
param vmDiskUtilizationAlert_description string
param vmDiskUtilizationAlert_severity int
param vmDiskUtilizationAlert_enabled bool
param vmDiskUtilizationAlert_scopes string
param vmDiskUtilizationAlert_evaluationFrequency string
param vmDiskUtilizationAlert_windowSize string
param vmDiskUtilizationAlert_percentageVal string //The remaining percentage that when breached, will signal an alert
//param vmDiskUtilizationAlert_threshold int
//param vmDiskUtilizationAlert_overrideQueryTimeRange string

//===============End Params===============//



//====== Start Memory Monitoring ======//

resource vmDiskUtilization_resource 'microsoft.insights/scheduledqueryrules@2021-08-01' = {
  name: vmDiskUtilizationAlert__name
  tags: tags
  location: location
  properties: {
    displayName: vmDiskUtilizationAlert__name
    description: vmDiskUtilizationAlert_description
    severity: vmDiskUtilizationAlert_severity
    enabled: vmDiskUtilizationAlert_enabled
    evaluationFrequency: vmDiskUtilizationAlert_evaluationFrequency //'PT5M'
    scopes: [
      vmDiskUtilizationAlert_scopes
    ]
    targetResourceTypes: [
      'Microsoft.Compute/virtualMachines'
    ]
    windowSize: vmDiskUtilizationAlert_windowSize //'PT5M'
    criteria: {
      allOf: [
        {
          query: 'let PercentSpace = ${vmDiskUtilizationAlert_percentageVal};\nPerf\n| where ObjectName == "LogicalDisk" and CounterName == "% Free Space"\nor ObjectName == "Logical Disk" and CounterName == "% Free Space"\n| summarize FreeSpace = avg(CounterValue) by Computer, InstanceName\n| where InstanceName contains ":" or InstanceName == "/"\n| where FreeSpace < PercentSpace\n'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: true
    actions: {
      actionGroups: [
        actiongroups_externalid
      ]
      customProperties: {
      }
    }
  }
}
