//=======This bicep file creates Action Groups for Alerting Notifications=======//


//=================Params=================//

param tags object
//param location string
param actionGroups_Admins_name string = 'Admins'
param emailAddress array
param sms array
//===============End Params===============//


//======== Start Resource Creation =======//

resource actionGroups_Admins_name_resource 'microsoft.insights/actionGroups@2021-09-01' = {
  name: actionGroups_Admins_name
  location: 'Global'
  tags:tags
  properties: {
    groupShortName: actionGroups_Admins_name
    enabled: true
    emailReceivers: [
      {
        name: 'Email Account_-EmailAction-'
        emailAddress: emailAddress[0]
        useCommonAlertSchema: false
      }
      {
        name: 'Email Microsoft Account_-EmailAction-'
        emailAddress: emailAddress[1]
        useCommonAlertSchema: false
      }
    ]
    smsReceivers: [
      {
        name: 'Text Me_-SMSAction-'
        countryCode: '1'
        phoneNumber: sms[0]
      }
    ]
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: []
  }
}

output actionGroups_Admins_name_resource_id string = actionGroups_Admins_name_resource.id
