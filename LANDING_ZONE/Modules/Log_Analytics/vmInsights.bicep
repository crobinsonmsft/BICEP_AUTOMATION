
//=======This bicep file creates a VM Insights Solution to assist with VM Monitoring=======//

//=================Params=================//

param workspaceName string
param vmInsights object = {
  name: 'VMInsights(${workspaceName})'
  galleryName: 'VMInsights'
}

param workspace_id string
param location string
param tags object

//===============End Params===============//

//VM Insights   https://docs.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview
resource solutionsVMInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: vmInsights.name
  location: location
  tags: tags
  properties: {
    workspaceResourceId: workspace_id
  }
  plan: {
    name: vmInsights.name
    publisher: 'Microsoft'
    product: 'OMSGallery/${vmInsights.galleryName}'
    promotionCode: ''
  }
}
