param location string
param appInsightsName string
param logAnalyticsWorkspaceName string
param containerEnvironmentName string
type identity = {
  id: string
  principalId: string
}
param managedIdentity identity

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

@description('Monitoring Metrics Publisher role https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#monitoring-metrics-publisher')
var aiMonitoringMetricsPublisherRole = resourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')

@description('assign role to the identity for pushing telemety to app insigts')
resource roleAiPublish 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, managedIdentity.id, aiMonitoringMetricsPublisherRole)
  scope: appInsightsComponents
  properties: {
    principalId: managedIdentity.principalId
    roleDefinitionId: aiMonitoringMetricsPublisherRole
    principalType: 'ServicePrincipal'
  }
}

resource containerEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: containerEnvironmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
  }
}

output containerEnvironmentId string = containerEnvironment.id
