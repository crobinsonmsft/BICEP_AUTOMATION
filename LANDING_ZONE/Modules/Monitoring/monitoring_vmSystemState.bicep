//=======This bicep file creates a System Monitoring Alert Rule=======//

//=================Params=================//

@description('Name of the alert')
@minLength(1)
param vmSysStateAlertName string = 'VM_is_OFFLINE_and_UNRESPONSIVE'
param location string
param tags object

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
param vmSysStateAlertScope_ids string = '/subscriptions/be5b442a-b163-4072-ac83-2cb81ef9654a'

@description('how often the metric alert is evaluated represented in ISO 8601 duration format')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param vmSysStateAlertEvalFrequency string = 'PT5M'

@description('The ID of the action group that is triggered when the alert is activated or deactivated')
param actiongroups_externalid string

@description('The amount of time since the last failure was encounterd')
param vmSysStateAlertQueryInterval string = '2m'
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
    windowSize: 'PT1M'
    overrideQueryTimeRange: 'P2D'
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
