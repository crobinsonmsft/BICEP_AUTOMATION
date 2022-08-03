//=======This bicep file creates a Log Analytics Workspace=======//

//=================Params=================//

param workspaceName string
param location string
param logAnalyticsWorkspaceSku string
param tags object

//===============End Params===============//

//======== Start Resource Creation =======//
//Log Analytics Workspace
resource workspace_ 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name:workspaceName
  location:location
  tags: tags
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
  }
}

output workspace_id string = workspace_.id
