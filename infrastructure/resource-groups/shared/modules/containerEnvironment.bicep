param location string
param solutionName string
param enviromment string
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceRg string
param containerEnvironmentName string = 'cae-${solutionName}-${enviromment}-${uniqueString(resourceGroup().id)}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceRg)
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
