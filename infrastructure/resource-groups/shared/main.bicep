targetScope = 'subscription'
param location string = 'West Europe'
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'dev'
param solutionName string = 'app'
param sharedResourceGroupName string = 'rg-${solutionName}-shared-${environment}'
param appResourceGroupName string = 'rg-${solutionName}-app-${environment}'

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: sharedResourceGroupName
  location: location
}

resource appResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: appResourceGroupName
  location: location
}

module logWorkspace 'modules/logAnalyticsWorkspace.bicep' = {
  name: 'log-workspace'
  scope: sharedResourceGroup
  params: {
    location: location
    environment: environment
    solutionName: solutionName
  }
}

module containerEnvironment 'modules/containerEnvironment.bicep' = {
  name: 'container-environment'
  scope: sharedResourceGroup
  params: {
    location: location
    enviromment: environment
    logAnalyticsWorkspaceName: logWorkspace.outputs.name 
    logAnalyticsWorkspaceRg: logWorkspace.outputs.resourceGroupName
    solutionName: solutionName
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'cr'
  scope: sharedResourceGroup
  params: {
    location: location
    sku: 'Basic'
    environment: environment
    solutionName: solutionName
  }
}

