//=======This bicep file creates Memory Monitoring Alert Rule=======//

//=================Params=================//

param metricAlerts_vm_memory_percentage_name string
param actiongroups_externalid string
param location string
param vmMemoryPercentageAlert_description string
param vmMemoryPercentageAlert_severity int
param vmMemoryPercentageAlert_enabled bool
param vmMemoryPercentageAlert_scopes string
param vmMemoryPercentageAlert_evaluationFrequency string
param vmMemoryPercentageAlert_windowSize string
param vmMemoryPercentageAlert_threshold int
param vmMemoryPercentageAlert_overrideQueryTimeRange string
param vmMemoryPercentageAlert_percentageVal string
param tags object

//===============End Params===============//



//====== Start Memory Monitoring ======//

//resource metricAlerts_vm_memory_percentage_name_resource 'Microsoft.Insights/metricAlerts@2018-03-01' = {
resource metricAlerts_vm_memory_percentage_name_resource 'microsoft.insights/scheduledqueryrules@2021-08-01' = {
  name: metricAlerts_vm_memory_percentage_name
  location: location
  tags: tags
  properties: {
    displayName: metricAlerts_vm_memory_percentage_name
    description: vmMemoryPercentageAlert_description
    severity: vmMemoryPercentageAlert_severity
    enabled: vmMemoryPercentageAlert_enabled
    evaluationFrequency: vmMemoryPercentageAlert_evaluationFrequency
    scopes: [
      vmMemoryPercentageAlert_scopes
    ]
    targetResourceTypes: [
      'Microsoft.Compute/virtualMachines'
    ]
    windowSize: vmMemoryPercentageAlert_windowSize
    overrideQueryTimeRange: vmMemoryPercentageAlert_overrideQueryTimeRange
    criteria: {
      allOf: [
        {
          query: 'Perf \n| where ObjectName == "Memory"\n| where CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use" \n| where TimeGenerated > ago(5m)\n| summarize avg = avg(CounterValue) by Computer \n| where avg > ${vmMemoryPercentageAlert_percentageVal}\n' //if fails ensure there are spaces after \n
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: vmMemoryPercentageAlert_threshold
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [
        actiongroups_externalid
      ]
      customProperties: {
      }
    }
  }
}
