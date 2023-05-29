param location string
param solutionName string
param environment string
param containerAppName string = 'ca-${solutionName}-${environment}-${uniqueString(resourceGroup().id)}'
param identityName string
param identityResourceGroup string = resourceGroup().name
param containerRegistryServer string
param containerImage string
param containerEnvironmentId string

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
  scope: resourceGroup(identityResourceGroup)
}

module roles 'roles.bicep' = {
  name: 'roles'
  scope: resourceGroup(identityResourceGroup)
  params: {
    identityName: identity.name
    identityResourceGroup: identityResourceGroup
  }
  
}

resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerEnvironmentId
    configuration: {
      ingress: {
        transport: 'auto'
        targetPort: 80
        external: true
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          identity: identity.id
          server: containerRegistryServer
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: containerImage
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                port: 80
                path: '/'
              }
            }
            {
              type: 'Readiness'
              httpGet: {
                port: 80
                path: '/'
              }
            }
            {
              type: 'Startup'
              httpGet: {
                port: 80
                path: '/'
              }
            }
          ]
        }
      ]
    }
  }
}
