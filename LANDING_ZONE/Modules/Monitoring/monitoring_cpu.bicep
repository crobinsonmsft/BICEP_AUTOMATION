//=======This bicep file creates CPU Monitoring Alert Rule=======//

//=================Params=================//

param metricAlerts_vm_cpu_percentage_name string
param actiongroups_externalid string
param p_location string
param p_severity int
param p_enabled bool
param p_scopes array
param p_evaluationFrequency string
param p_windowSize string
param p_threshold int
param p_targetResourceRegion string

//===============End Params===============//



//====== Start CPU Monitoring ======//

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
        actionGroupId: actiongroups_externalid
        webHookProperties: {}
      }
    ]
  }
}
