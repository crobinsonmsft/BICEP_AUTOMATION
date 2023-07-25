//=======This bicep file creates Peering Connection from Hub to Spoke=======//

//=================Params=================//

param location string
param tags object
param virtualNetworkName string
param publicIPAddressAppGatewayName string
param applicationGateWayName string
param subnet_spoke_DMZ_APP_GW_name string
param pub_ip_appgw_quantity int = 1
param wafPolicyName string

//===============End Params===============//


//=========== Start App Gateway Deployment ==========//

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-11-01' = [for i in range(0, pub_ip_appgw_quantity): {
  name: '${publicIPAddressAppGatewayName}${i}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}]

// https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep


resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-11-01' = {
  name: wafPolicyName
  location: location
  tags: tags
  properties: {
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
      exclusions: [
        {
          matchVariable: 'RequestHeaderValues'
          selectorMatchOperator: 'Equals'
          selector: 'User-Agent'
          exclusionManagedRuleSets: [
            {
              ruleSetType: 'OWASP'
              ruleSetVersion: '3.2'
              ruleGroups: [
                {
                  ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                  rules: [
                    {
                      ruleId: '942150'
                    }
                    {
                      ruleId: '942410'
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}

output appGWpolicy string = wafPolicy.id



resource applicationGateWay 'Microsoft.Network/applicationGateways@2022-11-01' = {
  name: applicationGateWayName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnet_spoke_DMZ_APP_GW_name)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddressAppGatewayName}0')
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'myBackendPool'
        properties: {}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'myHTTPSetting'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'myListener'
        properties: {
          firewallPolicy: {
            id: wafPolicy.id
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateWayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateWayName, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateWayName, 'myListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'myBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateWayName, 'myHTTPSetting')
          }
        }
      }
    ]
    enableHttp2: false
    firewallPolicy: {
      id: wafPolicy.id
    }
    /*autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }*/
  }
  dependsOn: [
    publicIPAddress[0]
  ]
}
