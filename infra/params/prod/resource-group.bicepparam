using '../../resource-group/main.bicep'

param topologyRole = 'Spoke'
param hubVirtualNetworkName = 'vnet-reference-hub-prod'
param spokeVirtualNetworkName = 'vnet-reference-spoke-prod'
param deploymentRegion = 'eastus'
param readerPrincipalObjectId = 'placeholder-principal-object-id'
param logAnalyticsWorkspaceResourceId = 'placeholder-log-analytics-workspace-resource-id'
