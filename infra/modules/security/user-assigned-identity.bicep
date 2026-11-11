targetScope = 'resourceGroup'

param identityName string
param location string

resource workloadIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

output principalId string = workloadIdentity.properties.principalId
output resourceId string = workloadIdentity.id
