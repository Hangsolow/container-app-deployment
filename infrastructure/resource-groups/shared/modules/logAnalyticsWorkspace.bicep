param location string
param solutionName string
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string
param logAnalyticsWorkspaceName string = 'law-${solutionName}-${environment}-${uniqueString(resourceGroup().id)}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output name string = logAnalyticsWorkspace.name
output resourceGroupName string = resourceGroup().name
