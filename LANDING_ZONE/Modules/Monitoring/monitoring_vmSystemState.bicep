//=======This bicep file creates a System Monitoring Alert Rule=======//

//=================Params=================//

param vmSysStateAlertName string
param location string
param tags object
param vmSysStateAlertDescription string
param vmSysStateAlertSeverity int
param vmSysStateAlertEnabled bool
param vmSysStateAlertScope_ids string
param vmSysStateAlertwindowSize string
param vmSysStateAlertEvalFrequency string
param vmSysStateAlertQueryTimeRange string
param actiongroups_externalid string
param vmSysStateAlertQueryInterval string
//===============End Params===============//


//====== Start VM System State Monitoring ======//

resource vm_system_state_resource 'microsoft.insights/scheduledqueryrules@2021-08-01' = {
  name: vmSysStateAlertName
  location: location
  tags: tags
  properties: {
    displayName: vmSysStateAlertName
    description: vmSysStateAlertDescription
    severity: vmSysStateAlertSeverity
    enabled: vmSysStateAlertEnabled
    evaluationFrequency: vmSysStateAlertEvalFrequency
    scopes: [
      vmSysStateAlertScope_ids
    ]
    targetResourceTypes: [
      'Microsoft.Compute/virtualMachines'
    ]
    windowSize: vmSysStateAlertwindowSize
    overrideQueryTimeRange: vmSysStateAlertQueryTimeRange //'P2D'
    criteria: {
      allOf: [
        {
          query: '// Not reporting VMs \n// VMs that have not reported a heartbeat in the last 2 minutes. \n// To create an alert for this query, click \'+ New alert rule\'\nHeartbeat \n| where TimeGenerated > ago(24h)\n| summarize LastCall = max(TimeGenerated) by Computer, _ResourceId\n| where LastCall < ago(${vmSysStateAlertQueryInterval})\n\n'
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
