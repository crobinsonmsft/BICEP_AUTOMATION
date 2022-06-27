targetScope = 'resourceGroup'
@description('The name of the Log Analytics Workspace')
param workspaceName string
param location string
@allowed([
  'PerGB2018'
])
param vaultSku string

// Log Analytics Workspace Declaration
resource workspace_ 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name:workspaceName
  location:location
  tags: {}
  properties: {
    sku: {
      name: vaultSku
    }
  }
}

//Variable Declaration
var vmInsights = {
  name: 'VMInsights(${workspaceName})'
  galleryName: 'VMInsights'
}

resource solutionsVMInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: vmInsights.name
  location: location
  /*
  dependsOn: [
    workspace_
  ]
  */
  properties: {
    workspaceResourceId: workspace_.id
  }
  plan: {
    name: vmInsights.name
    publisher: 'Microsoft'
    product: 'OMSGallery/${vmInsights.galleryName}'
    promotionCode: ''
  }
}
