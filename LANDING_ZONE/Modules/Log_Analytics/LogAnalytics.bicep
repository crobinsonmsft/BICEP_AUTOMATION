//=======This bicep file creates a Log Analytics Workspace=======//

//=================Params=================//

param workspaceName string
param location string
param logAnalyticsWorkspaceSku string
param tags object

//===============End Params===============//

//======== Start Resource Creation =======//
//Log Analytics Workspace
resource workspace_ 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name:workspaceName
  location:location
  tags: tags
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
    retentionInDays: 120
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}


resource table 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspace_
  name: 'Heartbeat'
  properties: {
    retentionInDays: 30
  }
}

//Create Data Sources for log collection from VMs
resource windowsEventsSystemDataSource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace_
  name: 'WindowsEventsSystem'
  kind: 'WindowsEvent'
  properties: {
    eventLogName: 'System'
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
}

resource WindowsEventApplicationDataSource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: workspace_
  name: 'WindowsEventsApplication'
  kind: 'WindowsEvent'
  properties: {
    eventLogName: 'Application'
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
}


resource syslogKernDataSource 'Microsoft.OperationalInsights/workspaces/datasources@2020-08-01' = {
  parent: workspace_
  name: 'SyslogKern'
  kind: 'LinuxSyslog'
  properties: {
    syslogName: 'kern'
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
      {
        severity: 'notice'
      }
      {
        severity: 'info'
      }
      {
        severity: 'debug'
      }
    ]
  }
}

resource syslogDaemonDataSource 'Microsoft.OperationalInsights/workspaces/datasources@2020-08-01' = {
  parent: workspace_
  name: 'SyslogDaemon'
  kind: 'LinuxSyslog'
  properties: {
    syslogName: 'daemon'
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
    ]
  }
}

resource syslogCollectionDataSource 'Microsoft.OperationalInsights/workspaces/datasources@2020-08-01' = {
  parent: workspace_
  name: 'SyslogCollection'
  kind: 'LinuxSyslogCollection'
  properties: {
    state: 'Enabled'
  }
}


output workspace_id string = workspace_.id
output workspaceIdOutput string = reference(workspace_.id, '2015-11-01-preview').customerId
output workspaceKeyOutput string = listKeys(workspace_.id, '2015-11-01-preview').primarySharedKey
