//=======This bicep file creates CPU Monitoring Alert Rule=======//

//=================Params=================//

param metricAlerts_vm_cpu_percentage_name string
param actiongroups_externalid string
param vmCpuPercentageAlert_location string
param vmCpuPercentageAlert_severity int
param vmCpuPercentageAlert_enabled bool
param vmCpuPercentageAlert_scopes string
param vmCpuPercentageAlert_evaluationFrequency string
param vmCpuPercentageAlert_windowSize string
param vmCpuPercentageAlert_threshold int
param vmCpuPercentageAlert_targetResourceRegion string

//===============End Params===============//



//====== Start CPU Monitoring ======//

resource metricAlerts_vm_cpu_percentage_name_resource 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: metricAlerts_vm_cpu_percentage_name
  location: vmCpuPercentageAlert_location
  properties: {
    severity: vmCpuPercentageAlert_severity
    enabled: vmCpuPercentageAlert_enabled
    scopes: [
      vmCpuPercentageAlert_scopes
    ]
    evaluationFrequency: vmCpuPercentageAlert_evaluationFrequency
    windowSize: vmCpuPercentageAlert_windowSize
    criteria: {
      allOf: [
        {
          threshold: vmCpuPercentageAlert_threshold
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
    targetResourceRegion: vmCpuPercentageAlert_targetResourceRegion
    actions: [
      {
        actionGroupId: actiongroups_externalid
        webHookProperties: {}
      }
    ]
  }
}
