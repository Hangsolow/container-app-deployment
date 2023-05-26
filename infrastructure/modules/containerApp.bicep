param location string
param name string
type identity = {
  id: string
  principalId: string
}
param managedIdentity identity
param containerRegistryServer string
param containerImage string
param containerEnvironmentId string

// resource test 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
//   name: 'id-${namae}'
// }

resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
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
          identity: managedIdentity.id
          server: containerRegistryServer
        }
      ]
    }
    template: {
      containers: [
        {
          name: name
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
