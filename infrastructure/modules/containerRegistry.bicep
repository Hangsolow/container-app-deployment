param location string
param name string

type identity = {
  id: string
  principalId: string
}
param managedIdentity identity

@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
param sku string = 'Basic'
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: false
  }
}
@description('Pull artifacts from a container registry role https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull')
var acrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

@description('assign pull role to managedIdentity')
resource roleCrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, managedIdentity.id, acrPullRole)
  scope: containerRegistry
  properties: {
    principalId: managedIdentity.principalId
    roleDefinitionId: acrPullRole
    principalType: 'ServicePrincipal'
  }
}

output server string = containerRegistry.properties.loginServer
