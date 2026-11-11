targetScope = 'resourceGroup'

@description('Object ID supplied by an approved Entra group or managed identity in a real environment.')
param principalObjectId string

var readerRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')

resource readerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalObjectId, readerRoleDefinitionId)
  properties: {
    roleDefinitionId: readerRoleDefinitionId
    principalId: principalObjectId
    principalType: 'Group'
  }
}

output assignmentId string = readerAssignment.id
