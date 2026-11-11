using '../../resource-group/main.bicep'

param topologyRole = 'Hub'
param hubVirtualNetworkName = 'vnet-reference-hub-dev'
param spokeVirtualNetworkName = 'vnet-reference-spoke-dev'
param deploymentRegion = 'eastus'
param readerPrincipalObjectId = 'placeholder-principal-object-id'
param logAnalyticsWorkspaceResourceId = 'placeholder-log-analytics-workspace-resource-id'
