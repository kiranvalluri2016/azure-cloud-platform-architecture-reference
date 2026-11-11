targetScope = 'tenant'

@description('Illustrative management group name. This template does not create, move, or assign subscriptions.')
param rootManagementGroupName string

@description('Illustrative platform management group name.')
param platformManagementGroupName string

@description('Illustrative workload management group name.')
param workloadManagementGroupName string

resource rootManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: rootManagementGroupName
}

resource platformManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: platformManagementGroupName
  properties: {
    details: {
      parent: {
        id: rootManagementGroup.id
      }
    }
  }
}

resource workloadManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: workloadManagementGroupName
  properties: {
    details: {
      parent: {
        id: rootManagementGroup.id
      }
    }
  }
}

output subscriptionBoundary string = 'Existing subscriptions are selected only by a future deployment target; this tenant-scope template never provisions or moves them.'
output managementGroupNames object = {
  root: rootManagementGroup.name
  platform: platformManagementGroup.name
  workload: workloadManagementGroup.name
}
