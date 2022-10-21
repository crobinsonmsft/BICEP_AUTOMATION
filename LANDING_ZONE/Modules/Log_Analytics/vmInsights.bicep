
//=======This bicep file creates a VM Insights Solution to assist with VM Monitoring=======//

//=================Params=================//

param workspaceName string
param vmInsights object
param vmUpdates object
param automationAccountName string
param loc2 string = 'eastus2'

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

//VM Updates 
resource solutionsUpdates 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  //name: vmUpdates.name
  name: vmUpdates.name
  location: location
  tags: tags
  //id: '/subscriptions/'
  properties: {
    workspaceResourceId: workspace_id
  }
  plan: {
    name: vmUpdates.name
    publisher: 'Microsoft'
    product: 'OMSGallery/${vmUpdates.galleryName}'
    promotionCode: ''
  }
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: automationAccountName
  location: loc2
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: false
    sku: {
      name: 'Basic'
    }
  }
}

resource workspaceName_Automation 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {

  name: '${workspaceName}/Automation'
  tags: tags
  //location: location
  properties: {
    resourceId: automationAccount.id
  }
}
