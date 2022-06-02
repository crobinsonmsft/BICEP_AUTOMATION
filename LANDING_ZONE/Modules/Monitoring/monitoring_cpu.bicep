param metricAlerts_vm_cpu_percentage_name string = 'vm_cpu_percentage'
param actiongroups_tss_cpu_alert_test_externalid string = '/subscriptions/7dbf4ab4-2b74-49a0-96a6-74750a214a21/resourceGroups/tss-np-rsg-infra-01/providers/microsoft.insights/actiongroups/tss-cpu-alert-test'
param p_location string = 'global'
param p_severity int = 2
param p_enabled bool = true
param p_scopes array = [
  '/subscriptions/7dbf4ab4-2b74-49a0-96a6-74750a214a21'
]
param p_evaluationFrequency string = 'PT5M'
param p_windowSize string = 'PT15M'
param p_threshold int = 70
param p_targetResourceRegion string = 'eastus2'

resource metricAlerts_vm_cpu_percentage_name_resource 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: metricAlerts_vm_cpu_percentage_name
  location: p_location
  properties: {
    severity: p_severity
    enabled: p_enabled
    scopes: p_scopes
    evaluationFrequency: p_evaluationFrequency
    windowSize: p_windowSize
    criteria: {
      allOf: [
        {
          threshold: p_threshold
          name: 'CPU_Metric'
          metricNamespace: 'microsoft.compute/virtualmachines'
          metricName: 'Percentage CPU'
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'microsoft.compute/virtualmachines'
    targetResourceRegion: p_targetResourceRegion
    actions: [
      {
        actionGroupId: actiongroups_tss_cpu_alert_test_externalid
        webHookProperties: {}
      }
    ]
  }
}
