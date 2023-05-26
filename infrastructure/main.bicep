param location string = resourceGroup().location
param enviromment string = 'dev'
param solutionName string = 'await'
param logWorkspaceName string = 'law-${solutionName}-${enviromment}-${uniqueString(resourceGroup().id)}'
param appInsightsName string = 'ai-${solutionName}-${enviromment}-${uniqueString(resourceGroup().id)}'
param containerRegistryName string = 'cr${solutionName}${enviromment}${uniqueString(resourceGroup().id)}'
param containerAppName string = 'ca-${solutionName}-${enviromment}-${uniqueString(resourceGroup().id)}'
param containerEnvironmentName string = 'cae-${solutionName}-${enviromment}-${uniqueString(resourceGroup().id)}'

@description('Specifies the docker container image to deploy.')
param containerImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

resource managedIdentityContainerApp 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${containerAppName}'
  location: location
}

@description('This module seeds the ACR with the public version of the app')
module acrImportImage 'br/public:deployment-scripts/import-acr:3.0.1' = {
  name: 'importContainerImage'
  params: {
    acrName: containerRegistry.name
    location: location
    images: array(containerImage)
  }
}

module containerEnvironment 'modules/containerEnvironment.bicep' = {
  name: 'logs'
  params: {
    location: location
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceName: logWorkspaceName
    containerEnvironmentName: containerEnvironmentName
    managedIdentity: {
      id: managedIdentityContainerApp.id
      principalId: managedIdentityContainerApp.properties.principalId
    }
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: containerRegistryName
  params: {
    name: containerRegistryName
    location: location
    managedIdentity: {
      id: managedIdentityContainerApp.id
      principalId: managedIdentityContainerApp.properties.principalId
    }
  }
}

module containerApps 'modules/containerApp.bicep' = {
  name: containerAppName
  params: {
    name: containerAppName
    location: location
    containerEnvironmentId: containerEnvironment.outputs.containerEnvironmentId
    containerImage: acrImportImage.outputs.importedImages[0].acrHostedImage
    containerRegistryServer: containerRegistry.outputs.server
    managedIdentity: {
      id: managedIdentityContainerApp.id
      principalId: managedIdentityContainerApp.properties.principalId
    }
  }
}
