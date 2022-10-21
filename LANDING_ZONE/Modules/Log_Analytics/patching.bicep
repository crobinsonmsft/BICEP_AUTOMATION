@description('OMS log analytics workspace name')
param omsWorkspaceName string

@description('OMS log analytics service tier: Free, Standalone, or PerNode')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
])
param omsServiceTier string = 'Free'

@description('OMS log analytics number of days of retention. Free plans can only have 7 days, Standalone and OMS plans include 30 days for free')
@minValue(7)
@maxValue(730)
param omsDataRetention int = 7

@description('Automation account name')
param automationAccountName string = ''

var apiVersion = {
  oms: '2017-03-15-preview'
  omssolutions: '2015-11-01-preview'
  automation: '2015-10-31'
}
var updates = {
  name: 'Updates(${omsWorkspaceName})'
  galleryName: 'Updates'
}

resource omsWorkspace 'Microsoft.OperationalInsights/workspaces@[variables(\'apiVersion\').oms]' = {
  name: omsWorkspaceName
  location: resourceGroup().location
  properties: {
    sku: {
      Name: omsServiceTier
    }
    retention: omsDataRetention
  }
}

resource omsWorkspaceName_updates_name 'Microsoft.OperationalInsights/workspaces/Microsoft.OperationsManagement/solutions@[variables(\'apiVersion\').omssolutions]' = {
  location: resourceGroup().location
  name: '${omsWorkspaceName}/${updates.name}'
  properties: {
    workspaceResourceId: omsWorkspace.id
  }
  plan: {
    name: updates.name
    publisher: 'Microsoft'
    promotionCode: ''
    product: 'OMSGallery/${updates.galleryName}'
  }
}

resource automationAccount 'Microsoft.Automation/automationAccounts@[variables(\'apiVersion\').automation]' = {
  name: automationAccountName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource omsWorkspaceName_Automation 'Microsoft.OperationalInsights/workspaces/linkedServices@[variables(\'apiVersion\').omssolutions]' = {
  name: '${omsWorkspaceName}/Automation'
  location: resourceGroup().location
  properties: {
    resourceId: automationAccount.id
  }
  dependsOn: [
    omsWorkspace

  ]
}