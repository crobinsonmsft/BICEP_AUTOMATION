param scheduledqueryrules_VM_Memory_Average_Usage_Exceeds_80_Percent_name string = 'VM Memory - Average Usage Exceeds 80 Percent'
param virtualMachines_VM_DEV_004_externalid string = '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a/resourceGroups/RG-RESOURCE-DEV-001/providers/Microsoft.Compute/virtualMachines/VM-DEV-004'
param actiongroups_admins_externalid string = '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a/resourceGroups/rg-management-dev-001/providers/microsoft.insights/actiongroups/admins'

resource scheduledqueryrules_VM_Memory_Average_Usage_Exceeds_80_Percent_name_resource 'microsoft.insights/scheduledqueryrules@2021-08-01' = {
  name: scheduledqueryrules_VM_Memory_Average_Usage_Exceeds_80_Percent_name
  location: 'eastus'
  properties: {
    displayName: scheduledqueryrules_VM_Memory_Average_Usage_Exceeds_80_Percent_name
    description: '${scheduledqueryrules_VM_Memory_Average_Usage_Exceeds_80_Percent_name}.  Looks at the average usage and issues an alert if value exceeds 80%'
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      virtualMachines_VM_DEV_004_externalid
    ]
    targetResourceTypes: [
      'Microsoft.Compute/virtualMachines'
    ]
    windowSize: 'PT5M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'Perf \n| where ObjectName == "Memory"\n| where CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use" \n| where TimeGenerated > ago(5m)\n| summarize avg = avg(CounterValue) by Computer \n| where avg > 20\n'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 1
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
        actiongroups_admins_externalid
      ]
      customProperties: {
      }
    }
  }
}