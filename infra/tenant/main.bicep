targetScope = 'tenant'

@description('Illustrative management group name. This template does not create, move, or assign subscriptions.')
param rootManagementGroupName string

@description('Illustrative platform management group name.')
param platformManagementGroupName string

@description('Illustrative shared workload management group name.')
param workloadManagementGroupName string

@description('Illustrative DEV workload management group name.')
param developmentWorkloadManagementGroupName string

@description('Illustrative PROD workload management group name.')
param productionWorkloadManagementGroupName string

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

resource developmentWorkloadManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: developmentWorkloadManagementGroupName
  properties: {
    details: {
      parent: {
        id: workloadManagementGroup.id
      }
    }
  }
}

resource productionWorkloadManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: productionWorkloadManagementGroupName
  properties: {
    details: {
      parent: {
        id: workloadManagementGroup.id
      }
    }
  }
}

output subscriptionBoundary string = 'Existing subscriptions are selected only by a future deployment target; this tenant-scope template never provisions or moves them.'
output managementGroupNames object = {
  root: rootManagementGroup.name
  platform: platformManagementGroup.name
  workload: workloadManagementGroup.name
  development: developmentWorkloadManagementGroup.name
  production: productionWorkloadManagementGroup.name
}
