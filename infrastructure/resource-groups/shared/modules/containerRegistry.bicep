param location string
param solutionName string
param environment string
@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
param sku string
param containerRegistryName string = 'cr${solutionName}${environment}${uniqueString(resourceGroup().id)}'
// param identityName string
// param identityResourceGroup string = resourceGroup().name


// resource identity 'Microsoft.ManagedIdentity/identities@2023-01-31' existing = {
//   name: identityName
//   scope: resourceGroup(identityResourceGroup)
// }

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
  }
}

// @description('Pull artifacts from a container registry role https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull')
// var acrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// @description('assign pull role to managedIdentity')
// resource roleCrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id, identity.id, acrPullRole)
//   scope: containerRegistry
//   properties: {
//     principalId: identity.properties.principalId
//     roleDefinitionId: acrPullRole
//     principalType: 'ServicePrincipal'
//   }
// }

output containerRegistryName string = containerRegistry.name
