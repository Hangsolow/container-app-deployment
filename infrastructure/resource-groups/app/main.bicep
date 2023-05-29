param location string = resourceGroup().location
param solutionName string = 'app'
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'dev'
param sharedResourceGroupName string = 'rg-${solutionName}-shared-${environment}'
param containerImagePath string

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: sharedResourceGroupName
  scope: subscription()
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' existing = {
  name: 'cr${solutionName}${environment}${uniqueString(sharedResourceGroup.id)}'
  scope: sharedResourceGroup
}

resource containerEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: 'cae-${solutionName}-${environment}-${uniqueString(sharedResourceGroup.id)}'
  scope: sharedResourceGroup
}

resource managedIdentityContainerApp 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${solutionName}-app-${environment}-${uniqueString(resourceGroup().id)}'
  location: location
}

module containerApp 'modules/containerApp.bicep' = {
  name: 'container app'
  params: {
    location: location
    containerEnvironmentId: containerEnvironment.id
    containerImage: containerImagePath
    containerRegistryServer: containerRegistry.properties.loginServer
    environment: environment
    identityName: managedIdentityContainerApp.name
    solutionName: solutionName
  }
  
}
