targetScope = 'resourceGroup'

@description('Resource ID to be evaluated by a provider-specific diagnostic-settings deployment.')
param targetResourceId string

@description('Existing Log Analytics workspace resource ID supplied only by a real deployment environment.')
param workspaceResourceId string

output validationBoundary string = 'This reference records diagnostic-setting inputs only. Category selection and provider aliases must be validated for each target resource before a deployment is authored.'
output targetContract object = {
  targetResourceId: targetResourceId
  workspaceResourceId: workspaceResourceId
}
